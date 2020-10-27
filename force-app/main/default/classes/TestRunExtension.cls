/*******************************************************************************
 * File:  TestRunExtension
 * Date:  June 4, 2010
 * Author:  Evan Hartig
 *
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of Roadnet Technologies is strictly prohibited.
 *
 * Confidential, unpublished property of Roadnet Technologies.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, Roadnet Technologies, Inc.  All rights reserved.
 *
 * Purpose: 
 *   Class used for logic related to the Test Run page.
 *******************************************************************************/

public class TestRunExtension {

    public Test_Run__c testRun {get; set;}
    public Test_Case__c testCase {get; set;}
    
    public Boolean isExistingRecord {get; set;}
    public Boolean showProductPatchTextbox {get; set;}
    public Boolean showPerformanceConfigs {get; set;}
    public Boolean showNewCRButton {get; set;}
    public Boolean testCaseExists {get; set;}
    public Boolean runFailed {get; set;}
    public Boolean runNeedsResolve {get; set;}
    public Boolean runBeingResolved {get; set;}
    
    public String selectedVersion {get; set;}
    public String selectedResult {get; set;}
    
    public static String noneItemId = 'NONE';
    public static String noneItemLabel = 'None';
    
    public Id testRunId {get; set;}
    private Id unresolvedRunId {get;set;}
    
    //
    // Constructor
    //
    public TestRunExtension(apexpages.standardController stdController)
    {
        testCaseExists = true;
        runBeingResolved = false;
        
        // Creates a new test run
        if(stdController.getId() == null)
        {
            if(stdController.getRecord() != null)
            {
                testRun = (Test_Run__c)stdController.getRecord();
                
                if(testRun.Test_Case__c == null && apexPages.currentPage().getParameters().get('testCase') == null)
                {
                    testCaseExists = false;
                }
                else
                {
                    if(apexPages.currentPage().getParameters().get('testCase') != null)
                    {
                        testRun.Test_Case__c = apexPages.currentPage().getParameters().get('testCase');
                    }
                    testCase = [select Id, 
                                        Name, 
                                        //Product_Family__c,
                                        Product_Family_PL__c, 
                                        Steps__c, 
                                        Expected_Result__c,
                                        RecordTypeId,
                                        Prerequisites__c,
                                        Notes__c,
                                        Product_Area_PL__c,
                                        Function_PL__c,
                                        //Function__c,
                                        //Function__r.Name,
                                        SubFunction_PL__c, 
                                        //Subfunction__r.Name,
                                        Test_Objective__c,
                                        Last_Run_Date__c,
                                        Earliest_Version_PL__c
                                from Test_Case__c t 
                                where t.Id = :testRun.Test_Case__c];
                    /*          
                    List<Product_Version__c> caseProductVersion = 
                        [select Id 
                        from Product_Version__c 
                        where Name = :testCase.Earliest_Version_PL__c];
                    
                   
                    
                    if(caseProductVersion.size() > 0)
                    {
                        selectedVersion = caseProductVersion[0].Id;
                    }
                    else
                    {
                    
                        List<Product_Version__c> defaultVersion = 
                            [select Id 
                            from Product_Version__c 
                            where Version__c = '1.0' 
                            and Product_Family__c = :testCase.Product_Family__c 
                            limit 1];
                            
                        if(defaultVersion.size() > 0)
                        {
                            selectedVersion = defaultVersion[0].Id;
                        }
                        
                    }
                    */
                }
            }
            isExistingRecord = false;
            selectedResult = 'Not yet run';

            testRun.Assigned_To__c = UserInfo.getUserId();
            showProductPatchTextbox=false;
        }
        // Edits an existing test run
        else
        {
            isExistingRecord = true;
            testRun = [select Id, 
                                Name, 
                                Test_Case__c, 
                                Notes__c, 
                                Product_Patch__c, 
                                //Product_Version__c, 
                                Product_Version_PL__c,
                                Result__c,
                                Captured_Metrics__c,
                                Test_Environment__c,
                                Target_Completion_Date__c,
                                Assigned_To__c,
                                Change_Request_txt__c,
                                //Change_Request__r.Name,
                                Parameters__c,
                                Resolved__c,
                                Mobile_Device_Version__c
                        from Test_Run__c q 
                        where q.id = :stdController.getId()];
            
            testCase = [select Id, 
                                Name, 
                                Product_Family_PL__c,
                                //Product_Family__c, 
                                Steps__c, 
                                Expected_Result__c,
                                RecordTypeId,
                                Prerequisites__c,
                                Notes__c,
                                Product_Area_PL__c,
                                Function_PL__c,
                                //Function__r.Name,
                                SubFunction_PL__c,
                                //Subfunction__r.Name,
                                Test_Objective__c,
                                Last_Run_Date__c
                        from Test_Case__c t 
                        where t.Id = :testRun.Test_Case__c];
            
            //selectedVersion = testRun.Product_Version__c;
            selectedResult = testRun.Result__c;
            showProductPatchTextbox=false;
            
            testRunId = testRun.Id;
            
            if(apexPages.currentPage().getParameters().get('resolving') == '1')
            {
                isExistingRecord = false;
                runBeingResolved = true;
                unresolvedRunId = testRun.Id;
                testRun = testRun.clone(false, true);
                testRun.Target_Completion_Date__c = null;
                testRun.Result__c = 'Not yet run';
                selectedResult = 'Not yet run';
                testRun.Resolved__c = false;
                testRun.Notes__c = '';
                //testRun.Change_Request__c = null;
                testRun.Product_Patch__c = null;
            }
            
            if(selectedResult == 'Fail')
            {
                runFailed = true;
                if(testRun.Resolved__c == false)
                {
                    runNeedsResolve = true;
                }
            }
        }
        
        showNewCRButton = false;
        
        showPerformanceConfigs = false;
        RecordType perfType = [select Id 
                               from RecordType r 
                               where r.Name = 'Performance' 
                                    AND r.SobjectType='Test_Case__c' limit 1];

        if(testCaseExists && testCase.RecordTypeId == perfType.Id)
        {
            showPerformanceConfigs = true;
        }
    }
    
    //
    // Saves a new test run or saves changes to an existing one
    //
    public PageReference saveTestRun()
    {
        /*if(selectedVersion != noneItemId)
        {
            testRun.Product_Version__c = selectedVersion;
        }
        else
        {
            testRun.Product_Version__c = null;
        }
        */
        if((selectedResult == 'Pass' || selectedResult == 'Fail') && selectedResult != testRun.Result__c)
        {
            testCase.Last_Run_Date__c = System.now();
            testRun.Test_Date__c = System.now();
            update testCase;
        }
        if(isExistingRecord)
        {
            if(selectedResult != testRun.Result__c)
            {
                testRun.Result__c = selectedResult;
                testRun.Status_Change_Date__c = System.now();
                if(testRun.Result__c == 'Blocked')
                {
                    testRun.Blocked_Date__c = System.now();
                }
            }
            update testRun;
        }
        else
        {
            testRun.Result__c = selectedResult;
            testRun.Status_Change_Date__c = System.now();
            if(testRun.Result__c == 'Blocked')
            {
                testRun.Blocked_Date__c = System.now();
            }
            Database.saveResult sr = Database.insert(testRun);
            testRunId = sr.getId();
        }
        
        if(runBeingResolved)
        {
            List<Test_Plan_Instance_Run_Junction__c> prevPlanInstJunction = 
                [select Id,
                    Order__c,
                    Description__c,
                    Test_Plan_Instance__c 
                from Test_Plan_Instance_Run_Junction__c
                where Test_Run__c = :unresolvedRunId];
            
            // If this run was tied to a plan instance, then tie the re-run to the same plan instance
            if(prevPlanInstJunction.size() > 0)
            {
                Test_Plan_Instance_Run_Junction__c newJunction = 
                    new Test_Plan_Instance_Run_Junction__c();
                newJunction.Order__c = prevPlanInstJunction[0].Order__c;
                newJunction.Description__c = prevPlanInstJunction[0].Description__c;
                newJunction.Test_Plan_Instance__c = prevPlanInstJunction[0].Test_Plan_Instance__c;
                newJunction.Test_Run__c = testRunId;
                
                insert newJunction;
                
                return new PageReference('/' + newJunction.Test_Plan_Instance__c);
            }
        }
        
        if(ApexPages.currentPage().getParameters().get('retURL') != null)
        {
            return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        }
        
        return new PageReference('/' + testCase.Id);
    }
    
    public PageReference saveAndCreateCR()
    {
        saveTestRun();
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        if(retURL == null)
        {
            retURL = '/' + testCase.Id;
        }
        
        //return new PageReference('/apex/ChangeRequestEditPage?testRun_id=' + testRunId + '&retURL=' + retURL);
        //  vf pages wont exist in new mibos environment so just return a null
        /*PageReference pr = Page.ChangeRequestEditPage;
        pr.getParameters().put('testRun_id', testRunId);
        pr.getParameters().put('retURL', retURL);
        
        pr.setRedirect(true);
        return pr;
        */
        return null;
        
    }
    
    public PageReference cancel()
    {
        if(apexPages.currentPage().getParameters().get('retURL') == null)
        {
            return new PageReference('/apex/TestRunTabPage');
        }
        return new PageReference(apexPages.currentPage().getParameters().get('retURL'));
        
    }
    
    public PageReference continueToNewTestRun()
    {
        if([select Id from Test_Case__c where Id=:testRun.Test_Case__c].size() > 0)
        {
            String retURL = ApexPages.currentPage().getParameters().get('retURL');
            if(retURL == null)
            {
                retURL = '/apex/TestRunTabPage';
            }
            
            PageReference newPage = new PageReference('/apex/TestRunEditPage?testCase=' + testRun.Test_Case__c + '&retURL=' + retURL);
            return newPage.setRedirect(true);
        }
        return null;
    }
    
    //
    // Property containing SelectOptions representing all build versions for a given Product Family
    //
    /*
    public List<SelectOption> productVersions
    {
        get
        {
            List<SelectOption> versions = 
                getVersionsForProductFamilyPickList(testCase.Product_Family__c);
            
            if (versions != null && versions.size() > 0)
            {
                versions.add(0,new SelectOption(noneItemId, noneItemLabel));
            }
            return versions;
            
            return null;
        }
    }
    
    //
    // Property containing SelectOptions representing all patch numbers for a given build
    //
    /*
    public List<SelectOption> productPatches
    {
        get
        {
            List<SelectOption> patchOptions =  new List<SelectOption>();
            patchOptions.add(new SelectOption(noneItemId, noneItemLabel));
            patchOptions.add(new SelectOption('Other', 'Other...'));
            List<Product_Patch__c> patches = [select Id, Name 
                                                from Product_Patch__c p 
                                                where p.Product_Version__c = :selectedVersion order
                                                by p.Patch_Number__c desc];
            
            for(Product_Patch__c patch: patches)
            {
                patchOptions.add(new SelectOption(patch.Name, patch.Name));
            }
            return patchOptions;
        }
    }
    */
    
    //
    // Property containing SelectOptions representing all pick list options for Result
    //
    public List<SelectOption> resultOptions
    {
        get
        {
            List<Schema.PickListEntry> resultOpts = 
                Test_Run__c.Result__c.getDescribe().getPickListValues();
            List<selectoption> options = new List<selectoption>();
        
            for(Schema.PickListEntry result: resultOpts)
            {
                options.add(new selectoption(result.getValue(), result.getLabel()));
            }
            
            return options;
        }
    }
/*
    //
    // Property containing all performance configurations from the parent test case
    //
    public List<Performance_Test_Configuration__c> performanceConfigData
    {
        get
        {
            if(testcaseexists)
            {
                List<Performance_Test_Configuration__c> configurations = 
                    [select Id, Name, Notes__c, Parameters__c 
                     from Performance_Test_Configuration__c ptc 
                     where ptc.Test_Case__c = :testCase.Id order by ptc.Name asc ];
                
                return configurations;
            }
            return null;
        }
    }
    */
/*
    //
    // Property containing SelectOptions representing performance configurations
    // from the parent test case
    //
    public List<SelectOption> performanceConfigOptions
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            
            for (Performance_Test_Configuration__c config : performanceConfigData)
            {
                options.add(new selectoption('' + config.Id, '' + config.Name));
            }
            
            return options;
        }
    }

*/
    //
    // Returns a list of SelectOptions representing the build versions for a given Product Family
    // 
/*    
    public static List<SelectOption> getVersionsForProductFamilyPickList(ID productFamilyId)
    {
        // Create a selection list of software versions for the 
        // selected product family.
        List<Product_Version__c> versions;
        List<SelectOption> versionPickList = new List<SelectOption>();

        if (productFamilyId == null)
        {
            // Return all the product versions.
            versions = 
                [select id, Name
                 from Product_Version__c 
                 order by Version__c];

            for (Product_Version__c pv : versions)
            {
                versionPickList.add(new SelectOption(pv.Id, pv.Name));
            }
        }
        else
        {
            versions = 
                [select id, Version__c 
                 from Product_Version__c 
                 where Product_Family__c = :productFamilyId
                 order by Version__c];
                 
            for (Product_Version__c pv : versions)
            {
                versionPickList.add(new SelectOption(pv.Id, pv.Version__c));
            }
        }             

        return versionPickList;
    }
    */
    private Test_Plan_Instance__c testPlanInstance;
    
    public Test_Plan_Instance__c PlanInstance
    {
        get
        {
            if(testPlanInstance == null)
            {
                List<Test_Plan_Instance_Run_Junction__c> runJunctions = 
                    [select Test_Plan_Instance__c,Test_Plan_Instance__r.Name 
                     from Test_Plan_Instance_Run_Junction__c 
                     where Test_Run__c = :testRun.Id];
                     
                if(runJunctions.size() > 0)
                {
                    testPlanInstance = 
                        [select Id,Name 
                         from Test_Plan_Instance__c 
                         where Id=:runJunctions[0].Test_Plan_Instance__c];
                }
            }
            return testPlanInstance;
        }
    }
    
    public Boolean OnPlan
    {
        get
        {
            return PlanInstance != null;
        }
    }
    
    public void UpdateResult()
    {
        if(selectedResult == 'Fail')
        {
            showNewCRButton = true;
        }
        else
        {
            showNewCRButton = false;
        }
    }
    
    public PageReference resolveFailedRun()
    {
        testRun.Resolved__c = true;
        update testRun;
        
        PageReference a = new PageReference('/apex/TestRunEditPage?id=' + testRun.id + '&resolving=1');
        a.setRedirect(true);
        return a;
    }
}