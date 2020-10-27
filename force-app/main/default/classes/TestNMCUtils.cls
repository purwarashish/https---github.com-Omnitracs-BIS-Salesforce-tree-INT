@isTest(SeeAllData=true)
private class TestNMCUtils{
    Static list<NMC_Account__c> lstNMCAcct = new list<NMC_Account__c>();
    
    static Account testAccount1 = GenericTestClass.insertAccount();
    //static Account testAccount2 = GenericTestClass.insertAccount();
    //static Account testAccount3 = GenericTestClass.insertAccount();
    
    static Case testCase1 = GenericTestClass.insertCase(testAccount1.id,null);
    //static Case testCase2 = GenericTestClass.insertCase(testAccount2.id,null);
    //static Case testCase3 = GenericTestClass.insertCase(testAccount3.id,null);
    
    static map<String, Id> mapNMCAccount = new map<String, Id>();
    
    static NMC_Account__c  testNMCAcct1 = GenericTestClass.insertNMCAccount(testAccount1.Id);
    //static NMC_Account__c  testNMCAcct2 = GenericTestClass.insertNMCAccount(testAccount2.Id);
    //static NMC_Account__c  testNMCAcct3 = GenericTestClass.insertNMCAccount(testAccount3.Id);
    
    static Map<Id,NMC_Account__c> newAcctNMCAcctMap = new Map<Id,NMC_Account__c>();
    private static testMethod void testNMC(){
     User depUser = [select Id from User where alias = 'Depuser'];
        System.runas(depUser){
        lstNMCAcct.add(testNMCAcct1);
        //lstNMCAcct.add(testNMCAcct2);
        //lstNMCAcct.add(testNMCAcct3);
        testCase1.NMC_Account_Number__c = testNMCAcct1.NMC_Account__c;
        //testCase2.NMC_Account_Number__c = testNMCAcct1.NMC_Account__c;
        //testCase3.NMC_Account_Number__c = testNMCAcct1.NMC_Account__c;
    
        //update testCase3;
        //update testCase2;
        update testCase1;
        
        mapNMCAccount.put(testNMCAcct1.NMC_Account__c,testNMCAcct1.id);
        //mapNMCAccount.put(testNMCAcct2.NMC_Account__c,testNMCAcct2.id);
        //mapNMCAccount.put(testNMCAcct3.NMC_Account__c,testNMCAcct3.id);
       
        newAcctNMCAcctMap.put(testAccount1.id,testNMCAcct1);
        //newAcctNMCAcctMap.put(testAccount2.id,testNMCAcct2);
        //newAcctNMCAcctMap.put(testAccount3.id,testNMCAcct3);
       
        NMCUtils nmc = new NMCUtils();
        NMCUtils.trackCompletedNMCSetup(newAcctNMCAcctMap);
        NMCUtils.retrieveCaseNMCRequest(mapNMCAccount,lstNMCAcct);
        NMCUtils.changeNMCAccountToUpperCase(lstNMCAcct);
        }
    }
}