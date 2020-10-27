/**********************************************************************************************
 Date: 11/04/2012 
 Author: Subha, Tata Consultancy Services        
 
 Overview: 
  This Test class covers the QES Unity ArticleModeler class 
       
 ***************************************************************************************/   

@isTest(seealldata=true)
public class TestArticleModeler
{
    static testmethod void testMethodArticleModeler()
    {
        Test.startTest();
        ArticleModeler tst = new ArticleModeler();
        tst.getCaseCreationAllowed();
        tst.redirectToCaseSubmission();
       
        Test.stopTest();
    }
    
     static testmethod void testMethodArticleModeler2()
    {
        Test.startTest();
        
        Case tstcase =  new Case(Subject='Test subject');
        insert tstcase;
        
               
        List<Known_Issue__kav> tmpList
                         = [select id,KnowledgeArticleId from  Known_Issue__kav
                            where PublishStatus ='Online' AND  Language='en_US' limit 1];
        PageReference pageRef = new PageReference('Test');
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',tmpList [0].KnowledgeArticleId );
                
        ApexPages.currentPage().getParameters().put('type','Known_Issue');
             
        ArticleModeler tst = new ArticleModeler();
        tst.getCaseCreationAllowed();
       
        Test.stopTest();
    }
    
    static testmethod void testMethodArticleModeler3()
    {
        Test.startTest();
        
             
        List<Documentation__kav> tmpList = [select id,KnowledgeArticleId from  Documentation__kav
                            where PublishStatus ='Online' AND  Language='en_US' limit 1];
        PageReference pageRef = new PageReference('Test');
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',tmpList [0].KnowledgeArticleId );
                
        ApexPages.currentPage().getParameters().put('type','Documentation');
             
        ArticleModeler tst = new ArticleModeler();
        tst.getCaseCreationAllowed();
       
        Test.stopTest();
    }
    
    
    static testmethod void testMethodArticleModeler4()
    {
        Test.startTest();
        
             
        List<How_To__kav> tmpList = [select id,KnowledgeArticleId from  How_To__kav
                            where PublishStatus ='Online' AND  Language='en_US' limit 1];
        PageReference pageRef = new PageReference('Test');
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',tmpList [0].KnowledgeArticleId );
                
        ApexPages.currentPage().getParameters().put('type','How_To');
             
        ArticleModeler tst = new ArticleModeler();
        tst.getCaseCreationAllowed();
       
        Test.stopTest();
    }
    
     static testmethod void testMethodArticleModeler5()
    {
        Test.startTest();
        
             
        List<Glossary__kav> tmpList = [select id,KnowledgeArticleId from  Glossary__kav
                            where PublishStatus ='Online' AND  Language='en_US' limit 1];
        PageReference pageRef = new PageReference('Test');
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',tmpList [0].KnowledgeArticleId );
                
        ApexPages.currentPage().getParameters().put('type','Glossary');
             
        ArticleModeler tst = new ArticleModeler();
        tst.getCaseCreationAllowed();
       
        Test.stopTest();
    }
    
     static testmethod void testMethodArticleModeler6()
    {
        Test.startTest();
        
             
        List<Product_Information__kav> tmpList = [select id,KnowledgeArticleId from  Product_Information__kav
                            where PublishStatus ='Online' AND  Language='en_US' limit 1];
        PageReference pageRef = new PageReference('Test');
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',tmpList [0].KnowledgeArticleId );
                
        ApexPages.currentPage().getParameters().put('type','Product_Information');
             
        ArticleModeler tst = new ArticleModeler();
        tst.getCaseCreationAllowed();
       
        Test.stopTest();
    }
    
    static testmethod void testMethodArticleModeler7()
    {
        Test.startTest();
        
             
        List<Technical_Bulletin__kav> tmpList = [select id,KnowledgeArticleId from  Technical_Bulletin__kav
                            where PublishStatus ='Online' AND  Language='en_US' limit 1];
        PageReference pageRef = new PageReference('Test');
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',tmpList [0].KnowledgeArticleId );
                
        ApexPages.currentPage().getParameters().put('type','Technical_Bulletin');
             
        ArticleModeler tst = new ArticleModeler();
        tst.getCaseCreationAllowed();
       
        Test.stopTest();
    }
    
    static testmethod void testMethodArticleModeler8()
    {
        Test.startTest();
        
             
        List<Solution__kav> tmpList = [select id,KnowledgeArticleId from  Solution__kav
                            where PublishStatus ='Online' AND  Language='en_US' limit 1];
        PageReference pageRef = new PageReference('Test');
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',tmpList [0].KnowledgeArticleId );
                
        ApexPages.currentPage().getParameters().put('type','Solution');
             
        ArticleModeler tst = new ArticleModeler();
        tst.getCaseCreationAllowed();
       
        Test.stopTest();
    }
}