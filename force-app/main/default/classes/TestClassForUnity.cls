/**********************************************************************************************
 Date: 04/04/2012 
 Author: Subha, Tata Consultancy Services        
 
 Overview: 
  This Test class covers the QES Unity classes 
       
 ***************************************************************************************/   
@isTest(seeAllData=true)
public class TestClassForUnity{
    
      static testmethod void TestQESUnityTraining()
     {
        Test.startTest();
        QESUnityTraining testQESUnityTraining = new QESUnityTraining();
        Test.stopTest();
     }
     
     static testmethod void TestQESUnityNewFeature()
     {
        Test.startTest();
        QESUnityNewFeature testQESUnityNewFeature = new QESUnityNewFeature();
        Test.stopTest();
     }
     
     static testmethod void TestQESUnityTopArticle()
     {
        Test.startTest();
        QESUnityTopArticle testQESUnityTopArticle = new QESUnityTopArticle();
        Test.stopTest();
     }
     
  
    
    static testmethod void TestGlobalSearchModeler()
    {
        Test.startTest();
        Apexpages.currentPage().getParameters().put('searchText','TestSearch');
        GlobalSearchModeler testGlobalSearchModeler = new GlobalSearchModeler();
        testGlobalSearchModeler.incrementPageNumber();
        testGlobalSearchModeler.decrementPageNumber();
        testGlobalSearchModeler.NextContent();
        testGlobalSearchModeler.PreviousContent();
        testGlobalSearchModeler.redirectToArticles();
        testGlobalSearchModeler.getLstContent();
        Test.stopTest();
    }
    
    static testmethod void TestCaseSubmissionModeler()
    {
        Test.startTest();
        CaseSubmissionModeler testCaseSubmissionModeler = new CaseSubmissionModeler();
        CaseCacheManager ccm = new CaseCacheManager ();
        ccm.getCachedCase();
        ccm.getCachedCaseNumber();
        
        Case tstCase =  new Case(Platform__c='OmniExpress', Application__c='Analytics Manager',Origin='Test Origin',subject='Test Class',QES_Unity_CP_Phone__c='997733636737'
                    ,description='Testing',Contract_Product__c='GlobalTRACS', Serial__c='SCR', Resolution__c='Test the class', type='AAA', status='Open',PCMEmail__c=true, PCMPhone__c=true);
        insert tstCase;
        
        PageReference pageRef = new PageReference('Test');
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',tstCase.Id);
        Apexpages.currentPage().getParameters().put('retURL',tstCase.Id);
        
        testCaseSubmissionModeler = new CaseSubmissionModeler(ccm);
        testCaseSubmissionModeler.setCaseCache(ccm);
        testCaseSubmissionModeler.updateCaseCreationAllowed(true);
        testCaseSubmissionModeler.getSubject();
        testCaseSubmissionModeler.displayrecentCase();
        testCaseSubmissionModeler.customSave1();
        testCaseSubmissionModeler.customSave();
        testCaseSubmissionModeler.dummy();
        testCaseSubmissionModeler.viewRedirect();
        testCaseSubmissionModeler.customCancel();
        testCaseSubmissionModeler.editRedirect();
        testCaseSubmissionModeler.redirectToCases();
        testCaseSubmissionModeler.redirectToCaseDetail();
        testCaseSubmissionModeler.redirectToArticles();
               
        tstCase =  new Case();
        insert tstCase;
        
        pageRef = new PageReference('Test2');
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',tstCase.Id);
        testCaseSubmissionModeler = new CaseSubmissionModeler(ccm);
        testCaseSubmissionModeler.customSave();
        testCaseSubmissionModeler.customSave1();
        
        tstCase =  new Case(Platform__c='OmniExpress', Application__c='Analytics Manager',PCMPhone__c = true);
        insert tstCase;
        
        pageRef = new PageReference('Test3');
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',tstCase.Id);
        testCaseSubmissionModeler = new CaseSubmissionModeler(ccm);
        testCaseSubmissionModeler.customSave();
        testCaseSubmissionModeler.customSave1();
        
        Test.stopTest();
    }
}