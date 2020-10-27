@isTest(SeeAllData= true)
private Class TestConnectionTypeUtils{
    //GenericTestClass

    static Account testAccount = GenericTestClass.insertAccount();
    static NMC_Account__c  testNMCAcct = GenericTestClass.insertNMCAccount(testAccount.Id);
    private static testMethod void testConType(){
        ConnectionTypeUtils  conTypeUtils = new ConnectionTypeUtils();
        ConnectionTypeUtils.createCase(testNMCAcct.id,'xyz');
    }
}