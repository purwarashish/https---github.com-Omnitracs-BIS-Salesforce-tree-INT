/*******************************************************************************
 * File:  TestPlanExtension
 * Date:  November 8, 2012
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
 *   Class used for logic related to the Test Plan page.
 *******************************************************************************/

public class TestPlanExtension {
    
    public List<Test_Case__c> testCases;
    public List<Test_Plan__c> testPlans;
    public Test_Plan__c currentPlan {get;set;}
    public Test_Plan_Case_Junction__c newJunction {get;set;}
    public List<Test_Plan_Case_Junction__c> caseJunctions {get;set;}
    public String selectedPlan {get;set;}
    public PageReference previousPage {get;set;}
    public Test_Plan__c newPlanTemplate {get;set;}
    public String runParams {get;set;}
    public Boolean showNewFields {get;set;}
    public Boolean navigateToPlan {get;set;}
    
    public String newPlanName {get;set;}
    public String newPlanDescrip {get;set;}
    public String newInstanceDescrip {get;set;}
    
    public Boolean cloningMode {get;set;}
    public Boolean normalMode {get;set;}
    public Boolean generateInstanceMode {get;set;}
    
    public Boolean allChecked{get;set;}
    
    public Test_Run__c baseRun {get;set;}
    
    public TestPlanExtension(ApexPages.Standardsetcontroller standardList)
    {
        previousPage = standardList.cancel();
        newPlanTemplate = new Test_Plan__c();

        if(apexPages.currentPage().getParameters().get('testCase') != null)
        {
            String testCase = apexPages.currentPage().getParameters().get('testCase');
            testCases = [select Id,Name from Test_Case__c where Id=:testCase];
        }
        else if(standardList.getRecords() != null)
        {
            testCases = standardList.getSelected();
        }
        
        testPlans = [select Id,Name from Test_Plan__c];
        selectedPlan = 'New';
        showNewFields = true;
    }
    
    public TestPlanExtension(ApexPages.Standardcontroller stdController)
    {
        Id planID = stdController.getId();
        newPlanTemplate = new Test_Plan__c();
           
        newJunction = new Test_Plan_Case_Junction__c();
        newJunction.Test_Plan__c = planID;
        
        RefreshPlan(planID);
        
        normalMode = true;
        
        RefreshCaseList();
    }
    
    public void UpdateCheckboxes()
    {
        for(Test_Plan_Case_Junction__c caseJunction : caseJunctions)
        {
            caseJunction.Selected__c = allChecked;
        }
    }
    
    public void RefreshPlan(Id planId)
    {
        currentPlan = [select Id,
                      Name,
                      Description__c,
                      Type__c,
                      Number_of_Cases__c,
                      Product_Family_PL__c,
                      Window_Height__c
               from Test_Plan__c 
               where Id = :planId];
    }
    
    public void StartClone()
    {
        cloningMode = true;
        normalMode = false;
        generateInstanceMode = false;
        newPlanName = currentPlan.Name;
        newPlanDescrip = currentPlan.Description__c;
        newPlanTemplate.Type__c = currentPlan.Type__c;
        newPlanTemplate.Product_Family_PL__c = currentPlan.Product_Family_PL__c;
    }
    
    public PageReference CancelClone()
    {
        cloningMode = false;
        normalMode = true;
        generateInstanceMode = false;
        
        newPlanName = '';
        newPlanDescrip = '';
        return new PageReference('/' + currentPlan.Id);
    }
    
    public PageReference ClonePlan()
    {
        if(newPlanName == '')
        {
            newPlanName = currentPlan.Name;
        }   
        Test_Plan__c newPlan = new Test_Plan__c();
        newPlan.Name = newPlanName;
        newPlan.Description__c = newPlanDescrip;
        newPlan.Product_Family_PL__c = newPlanTemplate.Product_Family_PL__c;
        newPlan.Type__c = newPlanTemplate.Type__c;
        newPlan.Window_Height__c = 500;
        
        Database.SaveResult result = Database.Insert(newPlan, false);
        
        if(!result.isSuccess())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unknown error cloning test plan'));
            return null;
        }
        
        Id testPlanId = result.getId();
        
        List<Test_Plan_Case_Junction__c> newPlanItems = new List<Test_Plan_Case_Junction__c>();
        for(Integer i = 0; i < caseJunctions.size(); i++)
        {
            Test_Plan_Case_Junction__c newJunction = new Test_Plan_Case_Junction__c();
            newJunction.Test_Case__c = caseJunctions[i].Test_Case__c;
            newJunction.Test_Plan__c = testPlanId;
            newJunction.ListOrder__c = caseJunctions[i].ListOrder__c;
            newJunction.Note__c = caseJunctions[i].Note__c;
            
            newPlanItems.add(newJunction);
        }
        
        insert newPlanItems;
        
        return new PageReference('/' + testPlanId);     
    }

    public void SaveOrderAndNotes()
    {
        for(Test_Plan_Case_Junction__c caseJunction : caseJunctions)
        {
            caseJunction.Selected__c = false;
        }
        
        update caseJunctions;
        update currentPlan;
        
        RefreshCaseList();
    }
    
    public void AddNewCase()
    {
        if(newJunction.Test_Case__c != null)
        {
            newJunction.Test_Plan__c = currentPlan.Id;
            insert newJunction;
            newJunction = new Test_Plan_Case_Junction__c();
            
            SaveOrderAndNotes();
        }
    }
    
    public void DeleteSelected()
    {
        List<Test_Plan_Case_Junction__c> casesToDelete = new List<Test_Plan_Case_Junction__c>();
        for(Test_Plan_Case_Junction__c caseJunction : caseJunctions)
        {
            if(caseJunction.Selected__c == true)
            {
                casesToDelete.Add(caseJunction);
            }
        }
        
        SaveOrderAndNotes();
        
        delete casesToDelete;
        
        RefreshCaseList();
    }
    
    public void AddDuplicateCase()
    {
        Test_Plan_Case_Junction__c caseJunction = GetObjectFromParams('addDupeId');
        
        if(caseJunction != null)
        {
            for(Integer i = 0; i < caseJunctions.size(); i++)
            {
                if(caseJunctions[i].Id == caseJunction.Id)
                {
                    Test_Plan_Case_Junction__c newJunction = new Test_Plan_Case_Junction__c();
                    newJunction.Test_Plan__c = currentPlan.Id;
                    newJunction.Test_Case__c = caseJunctions[i].Test_Case__c;
                    newJunction.ListOrder__c = caseJunctions[i].ListOrder__c;
                    
                    insert newJunction;
                    SaveOrderAndNotes();
                    return;
                }
            }
        }
    }
    
    public void RefreshCaseList()
    {
        RefreshPlan(currentPlan.Id);
        
        caseJunctions = [select Id,
                                Name,
                                ListOrder__c,
                                Note__c,
                                Test_Case__c,
                                Selected__c,
                                Test_Case__r.Id,
                                Test_Case__r.Name,
                                Test_Case__r.Test_Objective__c,
                                Test_Case__r.Function_PL__c,
                                Test_Case__r.Subfunction_PL__c,
                                Test_Case__r.Priority__c,
                                Test_Case__r.Earliest_Version_PL__c
                         from Test_Plan_Case_Junction__c
                         where Test_Plan__c = :currentPlan.Id
                         order by ListOrder__c asc nulls last,
                         Test_Case__r.Id asc,
                         Note__c asc nulls last];
    }
    
    private Test_Plan_Case_Junction__c GetObjectFromParams(String paramName)
    {
        String param = ApexPages.currentPage().getParameters().get(paramName);

        List<Test_Plan_Case_Junction__c> junc = [select Id,Name,Note__c,ListOrder__c,Test_Case__c from Test_Plan_Case_Junction__c where Id=:param];
        if(junc.size() > 0)
        {
            return junc[0];
        }   
        return null;
    }
    
    public void MoveUp()
    {
        MoveRow(-1);
    }
    
    public void MoveDown()
    {
        MoveRow(1);
    }
    
    public void MoveRow(Integer direction)
    {
        String row = apexPages.currentPage().getParameters().get('moveId');
        for(Integer i = 0; i < caseJunctions.size(); i++)
        {
            Test_Plan_Case_Junction__c caseJunction = caseJunctions[i];
            
            if(caseJunction.Id == row && 
               i + direction >= 0 && 
               i + direction <= caseJunctions.size()-1)
            {
                Integer j = i + direction;
                
                if(caseJunctions[j].ListOrder__c == null ||
                   caseJunction.ListOrder__c == null)
                    return;
                
                Decimal prevNum;
                
                while(j >= 0 && j < caseJunctions.size())
                {
                    prevNum = caseJunctions[j].ListOrder__c;
                    
                    if(prevNum != caseJunction.ListOrder__c)
                        break;
                        
                    j += direction;
                }
                
                if(j < 0 || j > caseJunctions.size() - 1)
                    return;
                
                Decimal newNum = prevNum;
                
                while(j >= 0 && j < caseJunctions.size())
                {
                    newNum = caseJunctions[j].ListOrder__c;
                    
                    if(prevNum == newNum)
                        caseJunctions[j].ListOrder__c = caseJunction.ListOrder__c;
                    else
                        break;
                    
                    j += direction;
                }
                
                caseJunction.ListOrder__c = prevNum;
                
                SaveOrderAndNotes();
                return;
            }
        }
    }
    
    public List<SelectOption> testPlanOptions
    {
        get
        {
            List<SelectOption> plans = new List<SelectOption>();
            
            plans.add(new SelectOption('New','New'));
            
            for(Test_Plan__c plan : testPlans)
            {
                plans.add(new SelectOption(plan.Id, plan.Name));
            }

            return plans;
        }
    }
    
    public List<SelectOption> PlanTypes
    {
        get
        {
            List<Schema.PickListEntry> resultOpts = 
                Test_Plan__c.Type__c.getDescribe().getPickListValues();
            List<selectoption> options = new List<selectoption>();
        
            for(Schema.PickListEntry result: resultOpts)
            {
                options.add(new selectoption(result.getValue(), result.getLabel()));
            }
            
            return options;
        }
    }
    
    public void StartGenerateInstance()
    {
        cloningMode = false;
        normalMode = false;
        generateInstanceMode = true;
        
        baseRun = new Test_Run__c();
        baseRun.Assigned_To__c = UserInfo.getUserId();
        
        if(caseJunctions.size() > 0)
            baseRun.Product_Version_PL__c = caseJunctions[0].Test_Case__r.Earliest_Version_PL__c;
    }
    
    public void CancelGenerateInstance()
    {
        cloningMode = false;
        normalMode = true;
        generateInstanceMode = false;
    }
    
    public void AssignSequentialOrders()
    {
        double lastOrder = 0;
        for(Test_Plan_Case_Junction__c caseJunction : caseJunctions)
        {
            if(caseJunction.ListOrder__c != null && caseJunction.ListOrder__c != 0)
            {
                
                lastOrder = caseJunction.ListOrder__c;
            }
            else
            {
                caseJunction.ListOrder__c = ++lastOrder;
            }
        }
        
        SaveOrderAndNotes();
    }
    
    public void MultiplyOrderValues()
    {
        for(Test_Plan_Case_Junction__c caseJunction : caseJunctions)
        {
            if(caseJunction.ListOrder__c != null)
            {
                caseJunction.ListOrder__c = caseJunction.ListOrder__c * 10;
            }
        }
        
        SaveOrderAndNotes();
    }
    
    public PageReference GenerateInstance()
    {
        Test_Plan_Instance__c planInstance = new Test_Plan_Instance__c();
        planInstance.Test_Plan__c = currentPlan.Id;
        planInstance.Owner__c = baseRun.Assigned_To__c;
        planInstance.Status__c = 'Not Started';
        planInstance.Product_Version_PL__c = baseRun.Product_Version_PL__c;
        planInstance.Description__c = newInstanceDescrip;
        planInstance.Window_Height__c = currentPlan.Window_Height__c;
        
        Database.SaveResult planResult = Database.Insert(planInstance);
        
        if(!planResult.isSuccess())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not save new test plan instance'));
            return apexPages.currentPage();
        }
        
        List<Test_Run__c> runsToInsert = new List<Test_Run__c>();
        List<Test_Plan_Instance_Run_Junction__c> runJunctionsToInsert = new List<Test_Plan_Instance_Run_Junction__c>();
        
        for(Test_Plan_Case_Junction__c testCase : caseJunctions)
        {
            Test_Run__c testRun = new Test_Run__c();
            
            testRun.Test_Case__c = testCase.Test_Case__c;
            testRun.Parameters__c = testCase.Note__c;
            testRun.Assigned_To__c = baseRun.Assigned_To__c;
            testRun.Product_Version_PL__c = baseRun.Product_Version_PL__c;
            
            runsToInsert.Add(testRun);
        }
        Database.SaveResult[] runResults = Database.Insert(runsToInsert);
        
        Integer i = 0;
        for(Test_Plan_Case_Junction__c testCase : caseJunctions)
        {
            if(runResults[i].isSuccess())
            {
                Test_Plan_Instance_Run_Junction__c testRunJunction = new Test_Plan_Instance_Run_Junction__c();
                testRunJunction.Test_Run__c = runResults[i].getId();
                testRunJunction.Test_Plan_Instance__c = planResult.getId();
                testRunJunction.Description__c = testCase.Note__c;
                testrunJunction.Order__c = testCase.ListOrder__c;
                testRunJunction.Test_Plan_Case_Junction__c = testCase.Id;
                
                runJunctionsToInsert.Add(testRunJunction);
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not save a new test run'));
                return apexPages.currentPage();
            }
            
            i++;
        }
        
        Database.SaveResult[] junctionResults = Database.Insert(runJunctionsToInsert);
        for(Database.SaveResult junctionResult : junctionResults)
        {
            if(!junctionResult.isSuccess())
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not save a new test run/instance junction'));
                return apexPages.currentPage();
            }
        }
        
        return new PageReference('/' + planResult.getId());
    }
    
    public void UpdateSelectedPlan()
    {
        showNewFields = false;
        if(selectedPlan == 'New')
        {
            showNewFields = true;
        }
    }
    
    public PageReference saveCasesToPlan()
    {
        String testPlanId = '';
        
        if(selectedPlan == 'New')
        {
            if(newPlanName == '')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to save a new test plan with a blank name'));
                return null;
            }
            
            Test_Plan__c newPlan = new Test_Plan__c();
            newPlan.Type__c = newPlanTemplate.Type__c;
            newPlan.Name = newPlanTemplate.Name;
            newPlan.Description__c = newPlanTemplate.Description__c;
            newPlan.Product_Family_PL__c = newPlanTemplate.Product_Family_PL__c;
            newPlan.Window_Height__c = 500;
            
            Database.SaveResult result = Database.Insert(newPlan, false);
            
            if(!result.isSuccess())
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unknown error creating test plan'));
                return null;
            }
            else
            {
                testPlanId = result.getId();
            }
        }
        else
        {
            testPlanId = selectedPlan;
        }
        
        List<Test_Plan_Case_Junction__c> newPlanItems = new List<Test_Plan_Case_Junction__c>();
        for(Integer i = 0; i < testCases.size(); i++)
        {
            Test_Plan_Case_Junction__c newJunction = new Test_Plan_Case_Junction__c();
            newJunction.Test_Case__c = testCases[i].Id;
            newJunction.Test_Plan__c = testPlanId;
            newJunction.Note__c = runParams;
            
            newPlanItems.add(newJunction);
        }
        
        insert newPlanItems;
        
        if(navigateToPlan)
        {
            return new PageReference('/' + testPlanId);     
        }
        return previousPage;
    }
}