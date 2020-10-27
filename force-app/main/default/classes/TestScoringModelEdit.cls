/*********************************************************************************
* Name: TestScoringModelEdit
* Created by Omnitracs {DateCreated 7/1/2016} 
----------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This is used as test class of controller ScoringModelEdit
----------------------------------------------------------------------------------
* Unit Test: TestScoringModelEdit
---------------------------------------------------------------------------------- 
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 7/1/2016 INITIAL DEVELOPMENT
 
*********************************************************************************/

@isTest
private class TestScoringModelEdit {
    
    static testMethod void myUnitTest1() {
        
        //Creating Scoring_Model__c by calling ScoringModel method of TestScoringUtility
        Scoring_Model__c sm = TestScoringUtility.createScoringModel();
        
        PageReference pageRef = Page.ScoringModelEdit;
        Test.setCurrentPageReference(pageRef);
        
        ApexPages.currentPage().getParameters().put('id',sm.Id);
        
        ScoringModelEdit se = new ScoringModelEdit(new ApexPages.StandardController(sm));
        
        se.DoSave();
        
    }
        
}