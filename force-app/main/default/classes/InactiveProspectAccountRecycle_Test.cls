@isTest
public class InactiveProspectAccountRecycle_Test {
	public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    @testSetup
    static void setupData() {
        TestUtils.defineCustomSettings();
    }
    
    static testMethod void myUnitTest() {
        
        List<Account> tstAcct = New List<Account>();
        Date myDate = date.newInstance(2018,05,22);
        Account account = TestUtils.getAccount('ABC Test Account');
        account.QWBS_Cust_ID__c = 'Test12345678';
        account.segment__c = 'TL';
        account.Fleet_Size__c = 150; 
       	account.BillingStreet = 'Harwood St';
		account.BillingCity = 'Dallas';
		account.BillingPostalCode = '75201';
        account.BillingCountry = 'USA';
        account.BillingState = 'TX';
        account.createddate = myDate;
        account.RecordTypeId = '01250000000DQBA';
        account.QWBS_Status__c = 'Active Prospect';
        account.QWBS_Market__c = 'Strategic';
        Insert account;
        tstAcct.add(account);
        
        Account account1 = TestUtils.getAccount('XYZ Test Account');
        account1.QWBS_Cust_ID__c = 'T345678';
        account1.segment__c = 'TL';
        account1.Fleet_Size__c = 15; 
       	account1.BillingStreet = 'Rockwood St';
		account1.BillingCity = 'Irving';
		account1.BillingPostalCode = '75063';
        account1.BillingCountry = 'USA';
        account1.BillingState = 'TX';
        account1.createddate = myDate;
        account1.ParentId = account.id;
        account1.RecordTypeId = '01250000000DQBA';
        account1.QWBS_Status__c = 'Active Prospect';
        account1.QWBS_Market__c = 'Strategic';
        Insert account1;
        tstAcct.add(account1);
        
        Opportunity opportunity1 = new Opportunity();
       
       	opportunity1.StageName = 'Sales Acceptance';
       	opportunity1.CloseDate = myDate;
       	opportunity1.Accountid = account1.Id;
       	opportunity1.Name = 'Test Opportunity1';
        opportunity1.CreatedDate = myDate;
        
       	insert opportunity1;
       
        
        Test.startTest();
       	String SchTime = '0 0 0 2 * ? *';
        InactiveProspectAccountRecycle obj1 = new InactiveProspectAccountRecycle();
        obj1.execute(null,tstAcct);
       	system.schedule('InactiveProspectAccountRecycle', SchTime, obj1);
        Test.stopTest();
    }
}