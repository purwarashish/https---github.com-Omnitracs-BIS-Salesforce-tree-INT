@isTest (seeallData=true)
private class TestSrContentVersionModeler
{
    public static testMethod void TestSrContentVersionModeler()
    {
         List<ContentVersion> cv = [select id ,
                                        ContentSize,
                                        ContentDocumentId
                                 from  
                                       ContentVersion
                                 where 
                                       ContentSize < 1000
                                 limit 1];
                                 
            PageReference pageRef = new PageReference('/apex/TestPage');
            Test.setCurrentPage(pageRef);
            if(cv != null && cv.size() > 0)
                {
                    Apexpages.currentPage().getParameters().put('id',cv[0].ContentDocumentId);
                }    
            SrContentVersionModeler cvm = new SrContentVersionModeler();
			Cookie counter = new Cookie('external_cookie','1',null,-1,false);
			ApexPages.currentPage().setCookies(new Cookie[]{counter});
            cvm.redirectToDownload();
            cvm.redirectTo();
			
            cv = [select id ,
                         ContentSize,
                         ContentDocumentId
                  from  
                          ContentVersion
                  where 
                          ContentSize > 1500 
                  limit 1];
            
            pageRef = new PageReference('/apex/TestPage');
            Test.setCurrentPage(pageRef);
            if(cv != null && cv.size() > 0)
                {
                    Apexpages.currentPage().getParameters().put('id',cv[0].ContentDocumentId);
                }    
            cvm = new SrContentVersionModeler();
            
            cv = [select id ,
                         ContentSize,
                         ContentDocumentId
                  from  
                          ContentVersion
                  where 
                          ContentSize > 1050000 
                  limit 1];
            
            pageRef = new PageReference('/apex/TestPage');
            Test.setCurrentPage(pageRef);
            if(cv != null && cv.size() > 0)
                {
                    Apexpages.currentPage().getParameters().put('id',cv[0].ContentDocumentId);
                }    
            cvm = new SrContentVersionModeler();
            
            cv = [select id ,
                         ContentSize,
                         ContentDocumentId
                  from  
                          ContentVersion
                  where 
                          ContentSize > 1075000000 
                  limit 1];
            
            pageRef = new PageReference('/apex/TestPage');
            Test.setCurrentPage(pageRef);
            if(cv != null && cv.size() > 0)
            {
                Apexpages.currentPage().getParameters().put('id',cv[0].ContentDocumentId);
            }    
           cvm = new SrContentVersionModeler();      
        }
}