@IsTest
private class PlatformAppModelerTest {
    
    private static testmethod void test()
    {
    Platform__c testPlatform=new Platform__c(Name='test');
    insert testPlatform;
    Apexpages.currentPage().getParameters().put('name','test');
    try{
    PlatformAppModeler testPlatformAppModeler=new PlatformAppModeler();}catch(exception e){}
   
    Application__c testApplication=new Application__c(Name='test1');
    insert testApplication;
    Apexpages.currentPage().getParameters().put('name','test1');
    try{    
    PlatformAppModeler testPlatformAppModeler=new PlatformAppModeler();}catch(exception e){}
    Apexpages.currentPage().getParameters().put('name',null);
    
    PlatformAppModeler testPlatformAppModeler=new PlatformAppModeler();
    testPlatformAppModeler.redirectNow();
    testPlatformAppModeler.redirectToPlatformApp();
    testPlatformAppModeler=new platformAppModeler('');
     
    }
    
    
}