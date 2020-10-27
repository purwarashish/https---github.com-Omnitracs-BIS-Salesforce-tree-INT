@isTest (seeallData=true)
private class ContentVersionModelerTest
{
    public static testMethod void ContentVersionModelerTest()
        {
            
            ContentVersionModeler cvm = new ContentVersionModeler();
            
            ContentDocument cd = [select Id from ContentDocument limit 1];           
                       
            PageReference pageRef = new PageReference('/apex/TestPage');
            Test.setCurrentPage(pageRef);
            Apexpages.currentPage().getParameters().put('id',cd.id);
            
           Cookie counter = new Cookie('external_cookie','1',null,-1,false);
           ApexPages.currentPage().setCookies(new Cookie[]{counter});
            cvm = new ContentVersionModeler();
            cvm.redirectToDownload();
            cvm.redirectTo();          
        }
}