/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=True)
private class ContractAddressExt_Test {
    public static Account accountInstance = new Account();
        public static Contract contractInstance = new Contract();
        public static Address__c addrInstance = new Address__c();
        public static Contract_Address__c contractAddrInstance = new Contract_Address__c();
    static testMethod void ContractAddressExt_Test() {
        
         accountInstance     =   new Account(    Name    =   'testAccount',
                                                    Phone   =   '12345',
                                                    Account_Classification__c   =   'Prospect',
                                                    Account_Status__c   =   'Active',
                                                    Account_Type__c =   'Association'
         
                                                );
            insert accountInstance;    
            
            addrInstance = new Address__c(  Address_Line_1__c = 'Test Address',
                                            City__c = 'Newark',
                                            State_Province__c = 'NJ',
                                            Zip_Postal_Code__c = '07017', 
                                            Account__c = accountInstance.id 
                                            );  
                                      
            insert addrInstance;
            contractInstance    =   new Contract(   Contract_Title__c   =   'testTitle',
                                                    //recordtypeid    =   contractRtId,
                                                    AccountId  =   accountInstance.id,
                                                    Status =   'Draft',
                                                    StartDate  =   date.today(),
                                                    EndDate    =   date.today(),
                                                    ContractTerm   =   1,
                                                    //CurrencyIsoCode    =   'USD',
                                                    Contract_ID__c =   null,
                                                    Term_type__c = 'Fixed',
                                                    Agreement_type__c = 'Individual',
                                                    Contract_Type__c = 'Customer',
                                                    Affiliate_Language__c = 'Yes',                                                 
                                                    Legal_Entity_Name__c ='Omnitracs, LLC'
                                                 );
            insert contractInstance;
            
            contractAddrInstance = new Contract_Address__c(  Address_Line_1__c = 'Test Address',
                                            City__c = 'Newark',
                                            State_Province__c = 'NJ',
                                            Zip_Postal_Code__c = '07017', 
                                            Address_ID__c = addrInstance.Id,
                                            Account_Address__c = addrInstance.Id,
                                            contract__c = contractInstance.id
                                            );  
                                            
            //insert contractAddrInstance;
            ContractAddressExt  con = new ContractAddressExt (new ApexPAges.StandardController(contractAddrInstance));
            con.ca = contractAddrInstance;
     
            con.ResetAddress();
            con.SaveAndNew();                               
  
        
    }
}