@isTest
public class UpdateAccountPrimaryProduct_test {
	public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    @testSetup
    static void setupData() {
        TestUtils.defineCustomSettings();
    }
    
    static testMethod void myUnitTest() {
        List<Account> tstAcct = New List<Account>();
        
        Account account = TestUtils.getAccount('ABC Test Account');
        account.QWBS_Cust_ID__c = 'Test12345678';
        account.segment__c = 'TL';
        account.Fleet_Size__c = 150; 
       	account.BillingStreet = 'Harwood St';
		account.BillingCity = 'Dallas';
		account.BillingPostalCode = '75201';
        account.BillingCountry = 'USA';
        account.BillingState = 'TX';
        Insert account;
        tstAcct.add(account);
        
        Account account1 = TestUtils.getAccount('INCLINETEST Account');
        account1.QWBS_Cust_ID__c = '82145678';
        account1.segment__c = 'TL';
        account1.Fleet_Size__c = 150; 
       	account1.BillingStreet = 'Mccullum RD';
		account1.BillingCity = 'Richardson';
		account1.BillingPostalCode = '75252';
        account1.BillingCountry = 'USA';
        account1.BillingState = 'TX';
        Insert account1;
        tstAcct.add(account1);
        
        tstAcct[0].QWBS_Market__c = 'Channel';
        tstAcct[1].QWBS_Market__c = 'Channel';
        update tstAcct;
        
        Revenue__c Rev1 = new revenue__c();
        Rev1.Account__c = account.id;
        Rev1.Type__c = 'Recurring';
        Rev1.Billed_Units__c = 300;
        Rev1.Fiscal_Year__c = 2019;
        Rev1.Fiscal_Period__c = 3;
        Rev1.Net_Revenue__c = 30.25;
        Rev1.Product_Line__c = 'XRS';
        
        Revenue__c Rev2 = new revenue__c();
        Rev2.Account__c = account.id;
        Rev2.Type__c = 'Recurring';
        Rev2.Billed_Units__c = 300;
        Rev2.Fiscal_Year__c = 2019;
        Rev2.Fiscal_Period__c = 3;
        Rev2.Net_Revenue__c = 35.25;
        Rev2.Product_Line__c = 'XN';
        
        Revenue__c Rev3 = new revenue__c();
        Rev3.Account__c = account.id;
        Rev3.Type__c = 'Recurring';
        Rev3.Billed_Units__c = 300;
        Rev3.Fiscal_Year__c = 2019;
        Rev3.Fiscal_Period__c = 3;
        Rev3.Net_Revenue__c = 38.25;
        Rev3.Product_Line__c = 'IVG';
        
        Revenue__c Rev4 = new revenue__c();
        Rev4.Account__c = account1.id;
        Rev4.Type__c = 'Recurring';
        Rev4.Billed_Units__c = 300;
        Rev4.Fiscal_Year__c = 2019;
        Rev4.Fiscal_Period__c = 3;
        Rev4.Net_Revenue__c = 30.25;
        Rev4.Product_Line__c = 'XRS';
        
        Insert Rev1;
        Insert Rev2;
        Insert Rev3;
        Insert Rev4;
        
        String rectype = 'Recurring';
        List<String> ProductLines = new List<String>{'MCP50','MCP110','Omnitracs IVG','XRS','XTP','XN','MCP100S','RNA - Roadnet Anywhere','MCP200','MCP100T','RTS','Roadnet Telematics','RNA','RDC','RNT - Telematics','RTS - Transportation Services'};
		List<Account> acclist = [Select name,QWBS_Market__c,(select type__c,Product_Line__c from Revenue__r Where (type__c =: rectype AND Product_Line__c=:ProductLines)) from account where ID IN (select account__c from revenue__c Where (type__c =: rectype AND Product_Line__c=:ProductLines))];        
        system.debug('Account List'+acclist);
        
        Test.startTest();
        //Database.executebatch(new UpdateAccountPrimaryProduct());
       	String SchTime = '0 0 18 10,20 * ? *';
        UpdateAccountPrimaryProduct obj1 = new UpdateAccountPrimaryProduct();
       	system.schedule('UpdateAccountPrimaryProduct', SchTime, obj1);
        Test.stopTest();
    }
    
}