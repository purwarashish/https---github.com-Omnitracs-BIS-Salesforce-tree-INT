/*******************************************************************************
 * File:  TestPlanInstanceExtension
 * Date:  November 9, 2012
 * Author:  Evan Hartig
 *
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of Roadnet Technologies is strictly prohibited.
 *
 * Confidential, unpublished property of Roadnet Technologies.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2012, Roadnet Technologies, Inc.  All rights reserved.
 *
 * Purpose: 
 *   Class used for logic related to the Test Case page.
 *******************************************************************************/


public class TestPlanInstanceExtension 
{
    public Test_Plan__c currentPlan {get;set;}
    public Test_Plan_Instance__c currentPlanInstance {get;set;}
    public List<Test_Plan_Instance_Run_Junction__c> testRunList {get;set;}
    public List<Test_Plan_Instance_Run_Junction__c> referenceRunList {get;set;}
    public User owner {get;set;}
    public Boolean showDeleteWarning {get;set;}
    
    public Boolean beingInitialized {get;set;}

    public Integer UnrunCases {get;set;}
    
    public Boolean allChecked{get;set;}

    public TestPlanInstanceExtension(apexpages.standardController stdController)
    {
        beingInitialized = true;
        showDeleteWarning = false;
        Id planInstanceID = stdController.getId();
        
        RefreshPlanInstance(planInstanceId);
        
        currentPlan = [select Id,Name,Description__c from Test_Plan__c where Id=:currentPlanInstance.Test_Plan__c];
        
        RefreshRuns();
        beingInitialized = false;
    }
    
    public void RefreshPlanInstance(Id planInstanceId)
    {
        currentPlanInstance = [select Id,
                              Name,
                              Test_Plan__c,
                              Owner__c,
                              Status__c,
                              Number_of_Runs__c,
                              Percent_Complete__c,
                              Product_Family__c,
                              Description__c,
                              Product_Version_PL__c,
                              Test_Plan__r.Product_Family_PL__c,
                              Test_Plan__r.Type__c,
                              Window_Height__c
                       from Test_Plan_Instance__c 
                       where Id=:planInstanceId];
    }
    
    public void TryDeleteInstance()
    {
        showDeleteWarning = true;
    }
    
    public void CancelDeleteInstance()
    {
        showDeleteWarning = false;
    }
    
    public void RefreshRuns()
    {
        RefreshPlanInstance(currentPlanInstance.Id);
        
        testRunList = [select Id,
                              Name,
                              Order__c,
                              Description__c,
                              Selected__c,
                              Test_Run__c,
                              Test_Plan_Case_Junction__c,
                              Test_Run__r.Id,
                              Test_Run__r.Name,
                              Test_Run__r.Assigned_To__c,
                              Test_Run__r.Test_Objective__c,
                              Test_Run__r.Result__c,
                              Test_Run__r.Resolved__c,
                              Test_Run__r.Test_Result__c,
                              Test_Run__r.Test_Case__c,
                              Test_Run__r.Test_Case__r.Last_Run_Date__c,
                              Test_Run__r.Parameters__c,
                              Test_Run__r.Product_Patch__c,
                              Test_Run__r.Mobile_Device_Version__c,
                              Test_Run__r.product_version_pl__c
                        from Test_Plan_Instance_Run_Junction__c
                        where Test_Plan_Instance__c = :currentPlanInstance.Id
                        order by Order__c asc nulls last,
                        Test_Run__r.Test_Case__r.Id asc,
                        Description__c asc nulls last,
                        Name];
                        
        referenceRunList = [select Id,
                              Name,
                              Test_Run__r.Result__c,
                              Test_Run__r.Product_Patch__c
                        from Test_Plan_Instance_Run_Junction__c
                        where Test_Plan_Instance__c = :currentPlanInstance.Id
                        order by Order__c asc nulls last,
                        Test_Run__r.Test_Case__r.Id asc,
                        Description__c asc nulls last,
                        Name];
                        
        RecalculatePctComplete();
    }
    
    public void UpdateCheckboxes()
    {
        for(Test_Plan_Instance_Run_Junction__c runJunction : testRunList)
        {
            runJunction.Selected__c = allChecked;
        }
    }
    
    public void RerunCase()
    {
        String param = ApexPages.currentPage().getParameters().get('rerunId');
        
        if(param == null || param == '')
        {
            return;
        }

        for(Test_Plan_Instance_Run_Junction__c runJunction : testRunList)
        {
            if(runJunction.Id == param)
            {
                Test_Run__c newRun = new Test_Run__c();
                newRun.Test_Case__c = runJunction.Test_Run__r.Test_Case__c;
                newRun.Assigned_To__c = runJunction.Test_Run__r.Assigned_To__c;
                newRun.Parameters__c = runJunction.Description__c;
                newRun.Result__c = 'Not yet run';
                newRun.Product_Version_PL__c = runJunction.Test_Run__r.Product_Version_PL__c;
                
                Database.saveResult sr = Database.insert(newRun);
                
                if(!sr.IsSuccess())
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unknown error while saving new test run'));
                    return;
                }
                
                Test_Plan_Instance_Run_Junction__c newRunJunction = new Test_Plan_Instance_Run_Junction__c();
                newRunJunction.Test_Run__c = sr.GetId();
                newRunJunction.Test_Plan_Instance__c = currentPlanInstance.Id;
                newRunJunction.Description__c = runJunction.Description__c;
                newRunJunction.Order__c = runJunction.Order__c;
                
                sr = Database.insert(newRunJunction);
                
                if(!sr.IsSuccess())
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unknown error while saving new test run junction'));
                    
                }
                
                RefreshRuns();
                
                return;
            }
        }
    }
    
    public void DeleteSelected()
    {
        List<Test_Plan_Instance_Run_Junction__c> testRunJunctionsToDelete = new List<Test_Plan_Instance_Run_Junction__c>();
        List<Test_Run__c> testRunstoDelete = new List<Test_Run__c>();
        for(Test_Plan_Instance_Run_Junction__c runJunction : testRunList)
        {
            if(runJunction.Selected__c == true)
            {
                Boolean runRemoved = false;
                if(runJunction.Test_Run__r.Result__c == 'Not yet run')
                {
                    testRunsToDelete.Add(runJunction.Test_Run__r);
                }
                else
                {
                    testRunJunctionsToDelete.Add(runJunction);
                }
            }
        }
        
        SaveChanges();
        
        delete testRunsToDelete;
        delete testRunJunctionsToDelete;
        
        RefreshRuns();
    }
    
    public PageReference DeleteInstanceWithRuns()
    {
        List<Test_Run__c> runsToDelete = new List<Test_Run__c>();
        List<Test_Plan_Instance_Run_Junction__c> runJunctionsToDelete = new List<Test_Plan_Instance_Run_Junction__c>();
        
        for(Test_Plan_Instance_Run_Junction__c testRunJunction : testRunList)
        {
            if(testRunJunction.Test_Run__r.Result__c == 'Not yet run')
            {
                runsToDelete.add(testRunJunction.Test_Run__r);
            }
            else
            {
                runJunctionsToDelete.add(testRunJunction);
            }
        }
        
        if(runsToDelete.size() > 0)
        {
            delete runsToDelete;
        }
        if(runJunctionsToDelete.size() > 0)
        {
            delete runJunctionsToDelete;
        }

        delete currentPlanInstance;
        
        String objectCode = Test_Plan_Instance__c.sObjectType.getDescribe().getKeyPrefix();
        
        PageReference pr = new PageReference('/' + objectCode);
        pr.setRedirect(true);
        
        return pr;
    }
    
    public void UpdateInstanceFromPlan()
    {
        List<Test_Plan_Case_Junction__c> testCaseJunctions = 
            [select Test_Case__c,Note__c,ListOrder__c 
            from Test_Plan_Case_Junction__c 
            where Test_Plan__c = :currentPlan.Id];
            
        Test_Plan_Instance_Run_Junction__c templateJunction = null;
        
        List<Test_Plan_Instance_Run_Junction__c> updateList = 
            new List<Test_Plan_Instance_Run_Junction__c>();
            
        List<Test_Run__c> testRunsToUpdate = new List<Test_Run__c>();
        List<Test_Run__c> testRunsToInsert = new List<Test_Run__c>();
        List<Test_Plan_Instance_Run_Junction__c> testRunJunctionsToInsert =
            new List<Test_Plan_Instance_Run_Junction__c>();
        
        if(testRunList.size() > 0)
            templateJunction = testRunList[0];
            
        for(Test_Plan_Case_Junction__c caseJunction : testCaseJunctions)
        {
            Boolean found = false;
            for(Integer i = 0; i < testRunList.size(); i++)
            {
                if(testRunList[i].Test_Plan_Case_Junction__c == caseJunction.Id)
                {
                    found = true;
                    testRunList[i].Description__c = caseJunction.Note__c;
                    testRunList[i].Order__c = caseJunction.ListOrder__c;
                    updateList.add(testRunList[i]);
                    
                    if(testRunList[i].Test_Run__r.Result__c == 'Not yet run')
                    {
                        Test_Run__c testRun = testRunList[i].Test_Run__r;
                        testRun.Parameters__c = testRunList[i].Description__c;
                        
                        testRunsToUpdate.Add(testRun);
                    }
                    
                    testRunList.remove(i);
                    
                    break;
                }
            }
            
            if(!found)
            {
                Test_Plan_Instance_Run_Junction__c newRunJunction = 
                    new Test_Plan_Instance_Run_Junction__c();
                    
                newRunJunction.Test_Plan_Instance__c = currentPlanInstance.Id;
                newRunJunction.Order__c = caseJunction.ListOrder__c;
                newRunJunction.Description__c = caseJunction.Note__c;
                newRunJunction.Test_Plan_Case_Junction__c = caseJunction.Id;
                
                testRunJunctionsToInsert.Add(newRunJunction);
                
                Test_Run__c newRun = new Test_Run__c();

                newRun.Test_Case__c = caseJunction.Test_Case__c;
                newRun.Parameters__c = caseJunction.Note__c;
                newRun.Assigned_To__c = UserInfo.getUserId();
                
                if(templateJunction != null)
                {
                    newRun.product_version_pl__c = templateJunction.Test_Run__r.product_version_pl__c;
                    newRun.Assigned_To__c = templateJunction.Test_Run__r.Assigned_To__c;
                }
                
                testRunsToInsert.Add(newRun);
            }
        }
        
        update testRunsToUpdate;
        
        update updateList;
        
        Database.saveResult[] sr = Database.insert(testRunsToInsert);
        
        List<Test_Plan_Instance_Run_Junction__c> finalRunJunctionsToInsert =
            new List<Test_Plan_Instance_Run_Junction__c>();
        
        Integer numFails = 0;
        
        for(Integer i = 0; i < sr.size(); i++)
        {
            if(sr[i].isSuccess())
            {
                testRunJunctionsToInsert[i].Test_Run__c = sr[i].getId();
                finalRunJunctionsToInsert.Add(testRunJunctionsToInsert[i]);
            }
            else
            {
                numFails++;
            }
        }
        
        if(numFails > 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, numFails + ' inserts failed'));
        }
        
        insert finalRunJunctionsToInsert;
        
        RefreshRuns();
    }
    
    public void RecalculatePctComplete()
    {
        Integer runCases = 0;
        
        if(testRunList == null || testRunList.size() == 0)
        {
            UnrunCases = 0;
            return;
        }
        
        for(Test_Plan_Instance_Run_Junction__c runJunction : testRunList)
        {
            if(runJunction.Test_Run__r.Result__c == 'Pass' ||
               (runJunction.Test_Run__r.Result__c == 'Fail' && runJunction.Test_Run__r.Resolved__c == true))
            {
                runCases += 1;
            }
        }
    
        UnrunCases = (Integer)currentPlanInstance.Number_of_Runs__c - runCases;
        
        currentPlanInstance.Percent_Complete__c = (Integer)(((runCases * 100) / currentPlanInstance.Number_of_Runs__c) + .5);
        
        if(!beingInitialized)
        {
            update currentPlanInstance;
        }
    }
    
    public void SaveChanges()
    {
        update currentPlanInstance;
        
        List<Test_Run__c> testRunsToUpdate = new List<Test_Run__c>();
        List<Test_Case__c> testCasesToUpdate = new List<Test_Case__c>();
        Map<Id, Boolean> testCaseExistsInList = new Map<Id, Boolean>();
        
        for(Integer i = 0; i < testRunList.size(); i++)
        {
            testRunList[i].Selected__c = false;
            Boolean differenceFound = false;
            if(testRunList[i].Test_Run__r.Result__c != referenceRunList[i].Test_Run__r.Result__c)
            {
                testRunList[i].Test_Run__r.Status_Change_Date__c = System.now();
                
                if(testRunList[i].Test_Run__r.Result__c == 'Blocked')
                {
                    testRunList[i].Test_Run__r.Blocked_Date__c = System.now();
                }
                if(testRunList[i].Test_Run__r.Result__c == 'Pass' || testRunList[i].Test_Run__r.Result__c == 'Fail')
                {
                    testRunList[i].Test_Run__r.Test_Date__c = System.now();
                    testRunList[i].Test_Run__r.Test_Case__r.Last_Run_Date__c = System.now();
                    
                    if(!testCaseExistsInList.containsKey(testRunList[i].Test_Run__r.Test_Case__r.Id))
                    {
                        testCasesToUpdate.Add(testRunList[i].Test_Run__r.Test_Case__r);
                        testCaseExistsInList.put(testRunList[i].Test_Run__r.Test_Case__r.Id, true);
                    }
                }
                differenceFound = true;
            }
            if(testRunList[i].Test_Run__r.Product_Patch__c != referenceRunList[i].Test_Run__r.Product_Patch__c)
            {
                differenceFound = true;
            }
            
            if(differenceFound)
            {
                testRunsToUpdate.Add(testRunList[i].Test_Run__r);
            }
        }
        
        if(testRunsToUpdate.size() > 0)
        {
            update testRunsToUpdate;
            
            if(testCasesToUpdate.size() > 0)
            {
                update testCasesToUpdate;
            }
            
            RefreshRuns();
        }

    }
}