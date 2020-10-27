@isTest(seealldata=true)
public class TestSrArticleModeler
{
    static testmethod void testMethodSrArticleModeler()
    {
        Test.startTest();
        ApexPages.currentPage().getParameters().put('pn','MsrSearch');
        ApexPages.currentPage().getParameters().put('retUrl','www.google.com');
        SrArticleModeler tst = new SrArticleModeler();
        Test.stopTest();
    }
  
   
    static testmethod void testMethodSrArticleModeler2()
    {
        Test.startTest();
        
        List<Known_Issue__kav> tmpList
                         = [select id,KnowledgeArticleId,Resolution_Status__c from  Known_Issue__kav
                            where PublishStatus ='Online' AND  Language='en_US' AND Resolution_Status__c != null limit 1];
        PageReference pageRef = new PageReference('Test');
        Test.setCurrentPage(pageRef);
        if(tmpList!=null && tmpList.size()>0)
            {
                Apexpages.currentPage().getParameters().put('id',tmpList [0].KnowledgeArticleId );
            }   
        ApexPages.currentPage().getParameters().put('type','Known_Issue');
        
        
       // SrArticleModeler.isAttachment = true;
             
        SrArticleModeler tst = new SrArticleModeler();
        Test.stopTest();
    }
    
    static testmethod void testMethodSrArticleModeler3()
    {
        Test.startTest();

        List<Documentation__kav> tmpList = [select id,KnowledgeArticleId,Related_Links__c,Attachment_1__Name__s from  Documentation__kav
                            where PublishStatus ='Online' AND  Language='en_US' limit 1];
         
        if(tmpList!=null && tmpList.size()>0)
           {
                Apexpages.currentPage().getParameters().put('id',tmpList [0].KnowledgeArticleId );
                                
           }
            ApexPages.currentPage().getParameters().put('type','Documentation');
           // SrArticleModeler.isAttachment = true;
                    
            SrArticleModeler tst = new SrArticleModeler();
            Test.stopTest();
    }
    
    
    static testmethod void testMethodSrArticleModeler4()
    {
        Test.startTest();
        List<How_To__kav> tmpList = [select id,KnowledgeArticleId from  How_To__kav
                            where PublishStatus ='Online' AND  Language='en_US' limit 1];
        PageReference pageRef = new PageReference('Test');
        Test.setCurrentPage(pageRef);
        if(tmpList!=null && tmpList.size()>0)
            {
                Apexpages.currentPage().getParameters().put('id',tmpList [0].KnowledgeArticleId );
            }         
        ApexPages.currentPage().getParameters().put('type','How_To');
        //SrArticleModeler.isAttachment = true;
        
        SrArticleModeler tst = new SrArticleModeler();
        Test.stopTest();
    }
    
     static testmethod void testMethodSrArticleModeler5()
    {
        Test.startTest();
        List<Glossary__kav> tmpList = [select id,KnowledgeArticleId,Term__c from  Glossary__kav
                            where PublishStatus ='Online' AND  Language='en_US' AND Term__c!=null limit 1];
        PageReference pageRef = new PageReference('Test');
        Test.setCurrentPage(pageRef);
        if(tmpList!=null && tmpList.size()>0)
            {
                Apexpages.currentPage().getParameters().put('id',tmpList [0].KnowledgeArticleId );
            }        
        ApexPages.currentPage().getParameters().put('type','Glossary');
       // SrArticleModeler.isAttachment = true;
        
        SrArticleModeler tst = new SrArticleModeler();
        Test.stopTest();
    }
    
     static testmethod void testMethodSrArticleModeler6()
    {
        Test.startTest();
        List<Product_Information__kav> tmpList = [select id,KnowledgeArticleId from  Product_Information__kav
                            where PublishStatus ='Online' AND  Language='en_US' limit 1];
        PageReference pageRef = new PageReference('Test');
        Test.setCurrentPage(pageRef);
        if(tmpList!=null && tmpList.size()>0)
            {
                Apexpages.currentPage().getParameters().put('id',tmpList [0].KnowledgeArticleId );
            }        
        ApexPages.currentPage().getParameters().put('type','Product_Information');
       // SrArticleModeler.isAttachment = true;
        
        SrArticleModeler tst = new SrArticleModeler();
        Test.stopTest();
    }
    
    static testmethod void testMethodSrArticleModeler7()
    {
        Test.startTest();
        List<Technical_Bulletin__kav> tmpList = [select id,KnowledgeArticleId,Release_Date__c from  Technical_Bulletin__kav
                            where PublishStatus ='Online' AND  Language='en_US' AND Release_Date__c != null limit 1];
        PageReference pageRef = new PageReference('Test');
        Test.setCurrentPage(pageRef);
        if(tmpList!=null && tmpList.size()>0)
            {
                Apexpages.currentPage().getParameters().put('id',tmpList [0].KnowledgeArticleId );
            }        
        ApexPages.currentPage().getParameters().put('type','Technical_Bulletin');
       // SrArticleModeler.isAttachment = true;
        
        SrArticleModeler tst = new SrArticleModeler();
        Test.stopTest();
    }
    
    static testmethod void testMethodSrArticleModeler8()
    {
        Test.startTest();
        List<Solution__kav> tmpList = [select id,KnowledgeArticleId from  Solution__kav
                            where PublishStatus ='Online' AND  Language='en_US' limit 1];
        PageReference pageRef = new PageReference('Test');
        Test.setCurrentPage(pageRef);
        if(tmpList!=null && tmpList.size()>0)
            {
                Apexpages.currentPage().getParameters().put('id',tmpList [0].KnowledgeArticleId );
            }        
        ApexPages.currentPage().getParameters().put('type','Solution');
      //  SrArticleModeler.isAttachment = true;
        
        SrArticleModeler tst = new SrArticleModeler();
        Test.stopTest();
    }
   
}