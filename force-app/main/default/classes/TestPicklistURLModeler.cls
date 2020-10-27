@isTest 
private class TestPicklistURLModeler 
{  
    static testMethod void validateTestPicklistURLModeler()
    {
    Platform__c testplatform=new Platform__c(Name='test',Display_on_Left_Nav_Bar__c=true,Ordinal__c=123456789);
    
    Application__C testApp=new Application__C(Name='test',Display_on_Left_Rail_as_Link__c=true,Ordinal__c=1203456789);

    test.startTest();
    
    insert testplatform;

    insert testApp;
    
    PicklistURLModeler testPicklistURLModeler=new PicklistURLModeler();
    testPicklistURLModeler.refreshInitializationData();
    testPicklistURLModeler.redirectNow();
    
    test.stopTest();

    }
}