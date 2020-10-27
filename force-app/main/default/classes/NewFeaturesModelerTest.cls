@isTest (seeAllData=true)
private class NewFeaturesModelerTest
{
    public static testMethod void NewFeaturesModelerTest()
        {
            NewFeaturesModeler nfm = new NewFeaturesModeler();
            
            PageReference pageRef = new PageReference('/apex/TestPage');
            
            pageRef = new PageReference('/apex/TestPage');
            Test.setCurrentPage(pageRef);
            //pageRef.getParameters().put('retURL','testStr');
            Apexpages.currentPage().getParameters().put('retURL','testStr');

            nfm = new NewFeaturesModeler();
        }
       public static testMethod void NewFeaturesModelerTest1()
        {

            
            PageReference pageRef = new PageReference('/apex/TestPage');
            
            pageRef = new PageReference('/apex/TestPage');
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('retURL','testStr');
            //Apexpages.currentPage().getParameters().put('retURL','testStr');
            NewFeaturesModeler nfm = new NewFeaturesModeler();
        } 
}