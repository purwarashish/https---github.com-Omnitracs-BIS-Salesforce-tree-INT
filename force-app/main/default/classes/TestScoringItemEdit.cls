/*********************************************************************************
* Name: TestScoringItemEdit
* Created by Omnitracs {DateCreated 7/1/2016} 
----------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This is used as test class of controller ScoringItemEdit
----------------------------------------------------------------------------------
* Unit Test: TestScoringItemEdit
---------------------------------------------------------------------------------- 
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 7/1/2016 INITIAL DEVELOPMENT
 
*********************************************************************************/

@isTest
private class TestScoringItemEdit {
    
    static testMethod void myUnitTest1() {
        
        //Creating Scoring_Model__c by calling ScoringModel method of TestScoringUtility
        Scoring_Model__c sm = TestScoringUtility.createScoringModel();
        
        //Creating Scoring_Item__c by calling createScoringItem method of TestScoringUtility
        Scoring_Item__c s = TestScoringUtility.createScoringItem();
        s.Scoring_Model__c = sm.Id;
        insert s;
        
        PageReference pageRef = Page.ScoringModelEdit;
        Test.setCurrentPageReference(pageRef);
        
        ApexPages.currentPage().getParameters().put(Label.ScoringModelFieldID,sm.Id);
        
        ScoringItemEdit se = new ScoringItemEdit(new ApexPages.StandardController(s));
        
        se.DoSave();
        se.getAccountFields();
        
                
            }
    
   
}