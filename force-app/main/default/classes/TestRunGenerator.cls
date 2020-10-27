/*******************************************************************************
 * File:  TestRunGenerator
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
 * Copyright 2010, Roadnet Technologies, Inc.  All rights reserved.
 *
 * Purpose: 
 *   Class used for generating Test Runs from a list of Test Cases
 *******************************************************************************/

public class TestRunGenerator {
    
    public List<Test_Case__c> testCases;
    public Test_Run__c baseRun {get; set;}
    public PageReference previousPage {get; set;}
    
    //
    // Constructor
    //
    public TestRunGenerator(ApexPages.Standardsetcontroller standardList)
    {
        previousPage = standardList.cancel();
        if(standardList.getRecords() != null)
        {
            baseRun = new Test_Run__c();
            testCases = standardList.getSelected();
            baseRun.Assigned_To__c = UserInfo.getUserId();
        }
    }
    
    //
    // Creates and assigns a new Test Run in 'not yet run' status for each 
    // test case selected in the Test Case list view
    //
    public PageReference saveTestRuns()
    {
        /*
        List<Product_Version__c> defaultProductVersion = [select Id 
            from Product_Version__c 
            where Version__c = '1.0' 
            and Product_Family__r.Name = 'Roadnet Apex' limit 1];
        */
        string defaultProductVersionname = 'Apex-1.0';
        
        for(Integer i = 0; i < testCases.size(); i++)
        {
            Test_Run__c newRun = new Test_Run__c();
            newRun.Assigned_To__c = baseRun.Assigned_To__c;
            newRun.Parameters__c = baseRun.Parameters__c;
            newRun.Target_Completion_Date__c = baseRun.Target_Completion_Date__c;
            newRun.Test_Case__c = testCases[i].Id;
            
            Test_Case__c currentCase = [select Id,Earliest_Version_PL__c,Product_Family_PL__c from Test_Case__c where Id = :testCases[i].Id];
            if(currentCase != null)
            {
            /*
                List<Product_Version__c> caseProductVersion = [select Id 
                    from Product_Version__c 
                    where Name = :currentCase.Earliest_Version_PL__c];
                 
                if(caseProductVersion.size() > 0)
                {
                    newRun.Product_Version__c = caseProductVersion[0].Id;
                }
                */
                newRun.Product_Version_PL__c = currentCase.Earliest_Version_PL__c;
            }
            
            if(newRun.Product_Version_PL__c == null)
            {
                newRun.Product_Version_PL__c = defaultProductVersionname;
            }
            
            insert newRun;
            
        }
        
        return previousPage;
    }
}