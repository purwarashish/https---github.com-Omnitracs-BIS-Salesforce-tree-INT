/*******************************************************************************
 * File:  TestCaseExtension
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
 * Copyright 2009, Roadnet Technologies, Inc.  All rights reserved.
 *
 * Purpose: 
 *   Class used for logic related to the Test Case page.
 *******************************************************************************/

public class TestCaseExtension { 
    
    public Test_Case__c testCase {get; set;}

    public Boolean isNewTestCase {get; set;}
    public Boolean showTitleHeader {get; set;}
    public Boolean showCloneHeader {get; set;}
    public Boolean showApproveButtons {get; set;}
    public Boolean showReworkedButton{get; set;}
    public Boolean showApprovalReasonInput {get; set;}
    public Boolean noReviewer {get; set;}

    //public String selectedEarliestVersion {get; set;}
    //public String selectedSunsetVersion {get; set;}
    //public String selectedProductArea {get; set;}
    //public String selectedFunction {get; set;}
    public String selectedSubfunction {get; set;}
    
    public String approvalReason {get; set;}
    
    public List<Test_Parameter__c> clonedParameters {get;set;}
    
    public static String noneItemId = 'NONE';
    public static String noneItemLabel = 'None';
    
    public static final String pendingStatus = 'Awaiting approval';
    public static final String approvedStatus = 'Approved';
    public static final String rejectedStatus = 'Rework needed';
    public static final String reworkedStatus = 'Rework complete';
    public static final String notSubmittedStatus = 'Not submitted';
    
    //
    // Constructor
    // 
    public TestCaseExtension(apexpages.standardController stdController)
    {
        showCloneHeader = false;
        showTitleHeader = true;
        noReviewer = false;
        //selectedFunction = noneItemId; //[select Id from Test_Case_Function__c limit 1].Id;
        //selectedSubfunction = noneItemId;
        
        // Creates a new test case
        if(stdController.getId() == null)
        {
            isNewTestCase = true;
            
            testCase = new Test_Case__c();
            testCase.OwnerId = UserInfo.getUserId();
            if(((Test_Case__c)stdController.getRecord()).RecordTypeId != null)
            {
                testCase.RecordTypeId = ((Test_Case__c)stdController.getRecord()).RecordTypeId;
            }
            /*
            List<RALL_Product_Family__c> productFamilies = [select Id, Name 
                                                    from RALL_Product_Family__c 
                                                    where Name = 'Roadnet Apex'];
            
            if(productFamilies.size() == 0)
            {
                productFamilies = [select Id, Name from RALL_Product_Family__c];
            }
            
            testCase.Product_Family__c = productFamilies[0].Id;
            
            if(((Test_Case__c)stdController.getRecord()).RecordTypeId != null)
            {
                testCase.RecordTypeId = ((Test_Case__c)stdController.getRecord()).RecordTypeId;
            }
            
            List<Product_Version__c> versions = [select Id, Name 
                 from Product_Version__c 
                 where Version__c ='1.0' and Product_Family__c = :testCase.Product_Family__c];
             
            if(versions.size() == 0)
            {
                selectedEarliestVersion = noneItemId;
            }
            else
            {
                selectedEarliestVersion = versions[0].Id;
            }
                 
            selectedSunsetVersion = noneItemId;
            
            List<Product_Area__c> productAreas = [select Id, Name from Product_Area__c where Name='Interface' limit 1];
            if(productAreas.size() == 0)
            {
                productAreas = [select Id, Name from Product_Area__c];
            }
            
            //selectedProductArea = productAreas[0].Id;
            */

        }
        // Edits an existing test case
        else
        {
            
            isNewTestCase = false;
            testCase = [select Id, 
                                Name,
                                OwnerId,
                                Earliest_Version_PL__c, 
                                Enabled__c, 
                                Expected_Result__c,
                                Function_PL__c,
                                Subfunction_PL__c,
                                Notes__c,
                                Prerequisites__c,
                                Priority__c,
                                Product_Family_PL__c,
                                Steps__c,
                                Product_Area_PL__c,
                                Sunset_Version_PL__c,
                                Test_Objective__c,
                                CreatedById,
                                CreatedDate,
                                LastModifiedById,
                                LastModifiedDate,
                                Approval_Status__c,
                                Reviewer_Id__c,
                                //Related_CR__c,
                                Approval_Reasons__c
                        from Test_Case__c 
                        where Id = :stdController.getId()];
                        
            //selectedEarliestVersion = testCase.Earliest_Version__c;
            //selectedSunsetVersion = testCase.Sunset_Version__c;
            //selectedProductArea = testCase.Product_Area__c;
            //selectedFunction = testCase.Function__c;
            //selectedSubfunction = testCase.Subfunction__c;
            
            showApproveButtons = false;
            showReworkedButton = false;
            showApprovalReasonInput = false;
            
            if(testCase.Approval_Status__c == pendingStatus || testCase.Approval_Status__c == reworkedStatus)
            {
                showApproveButtons = true;
            }
            else if(testCase.Approval_Status__c == rejectedStatus)
            {
                showReworkedButton = true;
            }
            
            // Clones data from an existing test case into a new one
            if(apexPages.currentPage().getParameters().get('clone') == '1')
            {
                clonedParameters = [select Id,Name,Key__c,Value__c from Test_Parameter__c where Test_Case__r.Id = :testCase.Id];
                
                testCase = testCase.clone(false, true);
                testCase.OwnerId = UserInfo.getUserId();
                testCase.Approval_status__c = null;
                testCase.Need_Rework_Date__c = null;
                testCase.Approval_Reasons__c = null;
                testCase.Approval_Status_Date__c = null;
                isNewtestCase = true;
                showTitleHeader = false;
                showCloneHeader = true;
            }
        }
    }
    
    //
    // Saves the test case, whether it is new or existing
    //
    public PageReference saveFromEdit()
    {
        /*if(selectedEarliestVersion != noneItemId)
        {
            testCase.Earliest_Version__c = selectedEarliestVersion;
        }
        else
        {
            testCase.Earliest_Version__c = null;
        }
        
        if(selectedSunsetVersion != noneItemId)
        {
            testCase.Sunset_Version__c = selectedSunsetVersion;
        }
        else
        {
            testCase.Sunset_Version__c = null;
        }
        */
        /*
        if(selectedFunction != noneItemId)
        {
            testCase.Function__c = selectedFunction;
        }
        else
        {
            testCase.Function__c = null;
        }
        
        
        
        if(selectedSubfunction != noneItemId)
        {
            testcase.Subfunction__c = selectedSubfunction;
        }
        else
        {
            testCase.Subfunction__c = null;
        }
        
        if(selectedProductArea != noneItemId)
        {
            testCase.Product_Area__c = selectedProductArea;
        }
        else
        {
            testCase.Product_Area__c = null;
        }
        */
        if(isNewTestCase)
        {
            if(testCase.Approval_Status__c == null)
            {
                testCase.Approval_Status__c = notSubmittedStatus;
            }
            insert testCase;
        }
        else
        {
            update testCase;
        }
        
        if(clonedParameters != null && clonedParameters.size() > 0)
        {
            for(Integer i = 0; i < clonedParameters.size(); i++)
            {
                Test_Parameter__c newParam = clonedParameters[i].clone(false, true);
                newParam.Test_Case__c = testCase.id;
                insert newParam;
            }
        }
        
        return new PageReference('/' + testCase.id);
    }
    
    //
    // Sets a test case up for initial review and approval
    //
    public PageReference caseCreated()
    {
        testCase.Approval_Status__c = pendingStatus;
        if(testCase.Reviewer_Id__c == null)
        {
            noReviewer = true;
            return null;
        }
        return saveFromEdit();
    }
    
    //
    // Creates a test case without submitting it for approval
    //
    public PageReference caseCreatedWithoutReview()
    {
        testCase.Approval_Status__c = notSubmittedStatus;
        return saveFromEdit();
    }
    
    //
    // Approves a test case during review, and reassigns it to its owner for running
    //
    public PageReference caseApproved()
    {
        testCase.Approval_Status__c = approvedStatus;
        showApprovalReasonInput = true;
        showApproveButtons = false;
        showReworkedButton = false;
        return null;
    }
    
    //
    // Rejects a test case during review, and reassigns it to its owner for rework
    //
    public PageReference caseRejected()
    {
        testCase.Approval_Status__c = rejectedStatus;
        showApprovalReasonInput = true;
        showApproveButtons = false;
        showReworkedButton = false;
        noReviewer = false;
        testCase.Need_Rework_Date__c = System.now();
        return null;
    }
    
    //
    // Returns a test case to a reviewer after necessary changes have been made
    //
    public PageReference caseReworked()
    {
        if(testCase.Reviewer_Id__c == null)
        {
            noReviewer = true;
            return null;
        }
        testCase.Approval_Status__c = reworkedStatus;
        showApprovalReasonInput = true;
        showApproveButtons = false;
        showReworkedButton = false;
        return null;
    }
    
    //
    // Resubmits an already-approved test case for review and approval
    //
    public PageReference caseResubmitted()
    {
        if(testCase.Reviewer_Id__c == null)
        {
            noReviewer = true;
            return null;
        }
        testCase.Approval_Status__c = pendingStatus;
        showApprovalReasonInput = true;
        showApproveButtons = false;
        showReworkedButton = false;
        return null;
    }
    
    //
    // When an approval action is submitted (not cancelled), saves changes
    //
    public PageReference approvalActionSubmitted()
    {
        testCase.Approval_Reasons__c = approvalReason;
        testCase.Approval_Status_Date__c = System.now();
        update testCase;
        return null;
    }
    
    /*
    //
    // Property containing SelectOptions representing UPSLT product families
    //
    public List<SelectOption> productFamilyOptions
    {
        get
        {
            return GetProductFamilyPickList();
        }
        
    }
    
    //
    // Property containing SelectOptions representing product areas for a given Product Family
    //
    public List<SelectOption> productAreaOptions
    {
        get
        {
            return getAreasForProductFamilyPickList(testCase.Product_Family__c);
        }
    }
    
    //
    // Property containing SelectOptions representing all build versions for a given Product Family
    //
    public List<SelectOption> getVersions
    {
        get
        {
            List<SelectOption> versionOpts = 
                getVersionsForProductFamilyPickList(testCase.Product_Family__c);
            versionOpts.add(0,new SelectOption(noneItemId,'--None--'));
            return versionOpts;
        }
    }
    */
    //
    // Property containing SelectOptions for all pick list options for test case priority
    //
    public static List<SelectOption> priorityOptions
    {
        get
        {
            List<Schema.PickListEntry> priorities = 
                Test_Case__c.Priority__c.getDescribe().getPickListValues();
            return GetSelectOptions(priorities);
        }
        set;
    }
    
    //
    // Property containing SelectOptions for all pick list options for test case enabled
    //
    public static List<SelectOption> enabledOptions
    {
        get
        {
            List<Schema.PickListEntry> enabledOpts = 
                Test_Case__c.Enabled__c.getDescribe().getPickListValues();
            return GetSelectOptions(enabledOpts);
        }
        set;
    }
    
    //  THIS HAS BEEN CONVERTED TO A PICKLIST AND WE CAN NO LONGER REFERENCE 
    // Returns a list of SelectOptions representing different tester-defined product functions,
    // which are used to group test cases.
    //
    /*
    public List<SelectOption> productFunctionOptions
    {
        get
        {
            List<SelectOption> functionOpts = new List<SelectOption>();
            functionOpts.add(new SelectOption(noneItemId, noneItemLabel));

            List<Test_Case_Function__c> functions = [select Id, Name from Test_Case_Function__c order by Name asc];
            
            for(Test_Case_Function__c function: functions)
            {
                functionOpts.add(new SelectOption(function.Id, function.Name));
            }
            
            return functionOpts;
        }
    }
    */
    
    //
    // Returns a list of SelectOptions representing different tester-defined subfunctions,
    // which are used to group test cases.
    //
    /*
    public List<SelectOption> productSubfunctionOptions
    {
        get
        {
            List<SelectOption> subfunctionOpts = new List<SelectOption>();
            subfunctionOpts.add(new SelectOption(noneItemId, noneItemLabel));
            
            List<Test_Case_Subfunction__c> subfunctions = 
                [select Id, Name 
                 from Test_Case_Subfunction__c
                 where Test_Case_Function__c = :selectedFunction order by Name asc];
            
            for(Test_Case_Subfunction__c subfunction : subfunctions)
            {
                subfunctionOpts.add(new SelectOption(subfunction.Id, subfunction.Name));
            }
            
            
            return subfunctionOpts;
        }
    }
    
    
    //
    // Returns a list of SelectOptions representing UPSLT's different Product Families
    //
    public static List<SelectOption> getProductFamilyPickList()
    {
        List<SelectOption> productFamilyPicklist;
        
        // Get a selection list of product families.
        if (productFamilyPickList == null)
        {
            productFamilyPickList = new List<SelectOption>();
    
            List<RALL_Product_Family__c> productFamilies = 
                [select id, Name 
                 from RALL_Product_Family__c];
    
            for (RALL_Product_Family__c pf : productFamilies)
            {
                productFamilyPickList.add(new SelectOption(pf.Id, pf.Name));
            }
        }
        
        return productFamilyPickList;
    }
    */
    //
    // Returns all of this case's test runs
    //
    public List<Test_Run__c> relatedRuns
    {
        get
        {
            return [select Id, Name, Captured_Metrics__c, 
                            Notes__c, 
                            Product_Patch__c, Test_Case__c, Test_Environment__c, 
                            Test_Result__c, Product_Version_PL__c, 
                            Assigned_To__c
                    from Test_Run__c tr where tr.Test_Case__c = :testCase.Id];
        }
    }
    
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
    //
    // Returns a list of SelectOptions representing the product areas of a given Product Family
    //
    /*
    public static List<SelectOption> getAreasForProductFamilyPickList(ID productFamilyId)
    {
        // Create a selection list of Product Areas for the 
        // selected Product Family.
        List<SelectOption> areaPickList = new List<SelectOption>();
        areaPickList.add(new SelectOption(noneItemId, noneItemLabel));

        if (productFamilyId == null)
        {
            // Return all the product areas.
            List<Product_Area__c> areas = 
                [select id, Name
                 from Product_Area__c 
                 order by Name];

            for (Product_Area__c area : areas)
            {
                areaPickList.add(new SelectOption(area.Id, area.Name));
            }
        }
        else
        {
            List<Product_Family_Area_Junction__c> familyAreas = 
                [select Product_Area__c, Product_Area__r.Name
                 from Product_Family_Area_Junction__c 
                 where Product_Family__c = :productFamilyId
                 order by Product_Area__r.Name];
                 
            for (Product_Family_Area_Junction__c pfa : familyAreas)
            {
                areaPickList.add(new SelectOption(pfa.Product_Area__c, pfa.Product_Area__r.Name));
            }
        }            

        return areaPickList;
    }
    */
    
    //
    // Converts PickListOptions into SelectOptions
    //
    public static List<SelectOption> GetSelectOptions(List<Schema.PickListEntry> listOptions)
    {
        List<selectoption> options = new List<selectoption>();
        
        for(Schema.PickListEntry listOption: listOptions)
        {
            options.add(new selectoption(listOption.getValue(), listOption.getLabel()));
        }
        
        return options;
    } 
    /*
    //
    // Sets the selected Product Area to None. Used when the selected Product Family is changed
    //
    public void updateSelectedArea()
    {
        selectedProductArea = noneItemId;
    }
    
    //
    // Sets the selected Subfunction to None. Used when the selected Function is changed
    //
    public void updateSubfunction()
    {
        selectedSubfunction = noneItemId;
    }
    */
}