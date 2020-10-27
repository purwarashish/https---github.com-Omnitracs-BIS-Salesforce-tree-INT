/******************************************************************************************
 * File:  		CallReportEmail_Test.cls
 * Date:  		October 5th, 2018
 * Author:		Sai Krishna Kakani
 * Description: Test Class for CallReportEmail.cls
 * ****************************************************************************************/
@istest(SeeAllData=True)
public class CallReportEmail_Test {
    public static testMethod void TestCREmail() {
       
        Account a = TestUtils.getAccount('ut1 Acc');
        a.QWBS_Cust_ID__c = 'Test12345678';
        a.segment__c = 'TL';
        a.Fleet_Size__c = 150; 
       	a.BillingStreet = 'Harwood St';
		a.BillingCity = 'Dallas';
		a.BillingPostalCode = '75201';
        a.BillingCountry = 'USA';
        a.BillingState = 'TX';
        insert a;
        
        
            
        Call_Report__c CallReport = new Call_Report__c(
        	Account__c= a.Id,
        	Status__C = 'Draft',
            Date__c = system.today(),
            QWBS_Attendees__c = 'TEST Attendees',
          	Customer_Attendees__c = 'Customer Attendees Test',
            Purpose__c = 'Business Development',
            Method__c = 'Phone',
        	Type_of_Competitor__c='No Competitor');
        insert CallReport;
    
    	Contract ctrct = TestUtils.getContract(a);
        ctrct.Contract_Title__c='INTELLIGENT VEHICLE GATEWAY SERVICE SCHEDULE';
        ctrct.Contract_Category_1__c='IVG';
        ctrct.accountid=a.id;
        ctrct.Status='Active';
        ctrct.enddate=system.today();
        ctrct.Agreement_Type__c='Schedule';
        insert ctrct;
        
        Contract ctrct1 = TestUtils.getContract(a);
        ctrct1.Contract_Title__c='Untethered Asset Management Service Schedule';
        ctrct1.Contract_Category_1__c='T2';
        ctrct1.accountid=a.id;
        ctrct1.Status='Active';
        ctrct1.enddate=system.today();
        ctrct1.Agreement_Type__c='Schedule';
        insert ctrct1;
        
        Contract ctrct2 = TestUtils.getContract(a);
        ctrct2.Contract_Title__c='Relay Unit Schedule';
        ctrct2.Contract_Category_1__c='XRS';
        ctrct2.accountid=a.id;
        ctrct2.Status='Active';
        ctrct2.enddate=system.today();
        ctrct2.Agreement_Type__c='Schedule';
        insert ctrct2;
        
        Contract ctrct3 = TestUtils.getContract(a);
        ctrct3.Contract_Title__c='MOBILE COMPUTING PLATFORM 200 SERIES SERVICE SCHEDULE';
        ctrct3.Contract_Category_1__c='MCP200';
        ctrct3.accountid=a.id;
        ctrct3.Status='Active';
        ctrct3.enddate=system.today();
        ctrct3.Agreement_Type__c='Schedule';
        insert ctrct3;
        
        Contract ctrct4 = TestUtils.getContract(a);
        ctrct4.Contract_Title__c='Mobile Computing Platform 100 Series Satellite Service Schedule';
        ctrct4.Contract_Category_1__c='MCP100S';
        ctrct4.accountid=a.id;
        ctrct4.Status='Active';
        ctrct4.enddate=system.today();
        ctrct4.Agreement_Type__c='Schedule';
        insert ctrct4;
    
    	Contract ctrct5 = TestUtils.getContract(a);
        ctrct5.Contract_Title__c='MOBILE COMPUTING PLATFORM 50 SERIES SERVICE SCHEDULE';
        ctrct5.Contract_Category_1__c='MCP50';
        ctrct5.accountid=a.id;
        ctrct5.Status='Active';
        ctrct5.enddate=system.today();
        ctrct5.Agreement_Type__c='Schedule';
        insert ctrct5;
    
    	Contract ctrct6 = TestUtils.getContract(a);
        ctrct6.Contract_Title__c='Mobile Computing Platform 110 Series Schedule';
        ctrct6.Contract_Category_1__c='MCP110';
        ctrct6.accountid=a.id;
        ctrct6.Status='Active';
        ctrct6.enddate=system.today();
        ctrct6.Agreement_Type__c='Schedule';
        insert ctrct6;
    
    	Contract ctrct7 = TestUtils.getContract(a);
        ctrct7.Contract_Title__c='TRAILER TRACKS 210 SERVICE SCHEDULE';
        ctrct7.Contract_Category_1__c='TT210';
        ctrct7.accountid=a.id;
        ctrct7.Status='Active';
        ctrct7.enddate=system.today();
        ctrct7.Agreement_Type__c='Schedule';
        insert ctrct7;
    
    	Contract ctrct8 = TestUtils.getContract(a);
        ctrct8.Contract_Title__c='OmniVision Terrestrial Service Schedule';
        ctrct8.Contract_Category_1__c='MCP100T';
        ctrct8.accountid=a.id;
        ctrct8.Status='Active';
        ctrct8.enddate=system.today();
        ctrct8.Agreement_Type__c='Schedule';
        insert ctrct8;
    
    	Contract ctrct9 = TestUtils.getContract(a);
        ctrct9.Contract_Title__c='TRAILER TRACKS 150 SERVICE SCHEDULE';
        ctrct9.Contract_Category_1__c='TT150';
        ctrct9.accountid=a.id;
        ctrct9.Status='Active';
        ctrct9.enddate=system.today();
        ctrct9.Agreement_Type__c='Schedule';
        insert ctrct9;
    
    	Contract ctrct10 = TestUtils.getContract(a);
        ctrct10.Contract_Title__c='Software License Schedule';
        ctrct10.Contract_Category_1__c='Dom. SAAS';
        ctrct10.accountid=a.id;
        ctrct10.Status='Active';
        ctrct10.enddate=system.today();
        ctrct10.Agreement_Type__c='Schedule';
        insert ctrct10;
    	
    	Contract ctrct11 = TestUtils.getContract(a);
        ctrct11.Contract_Title__c='Roadnet Telematics Device, Wireless Services, and Software As A Service Schedule (Bundled)';
        ctrct11.Contract_Category_1__c='RN Telematics/SaaS (Lease)';
        ctrct11.accountid=a.id;
        ctrct11.Status='Active';
        ctrct11.enddate=system.today();
        ctrct11.Agreement_Type__c='Schedule';
        insert ctrct11;
    
    	Contract ctrct12 = TestUtils.getContract(a);
        ctrct12.Contract_Title__c='SOFTWARE AS A SERVICE SCHEDULE';
        ctrct12.Contract_Category_1__c='RN SaaS';
        ctrct12.accountid=a.id;
        ctrct12.Status='Active';
        ctrct12.enddate=system.today();
        ctrct12.Agreement_Type__c='Schedule';
        insert ctrct12;
    	
        Test.startTest();
    	CallReportEmail testEmail = new CallReportEmail();
    	testEmail.callReportID = CallReport.Id;
    	CallReport.Meeting_Objective_Agenda__c = 'test';
        CallReport.Meeting_Summary__c = 'Test';
        CallReport.Next_Objective_Strategy__c= 'Test';
        CallReport.Operations_IT_Maintenance__c= 'Test';
        update CallReport;
       	
    
        Revenue__c rr = new Revenue__c();
        rr.Account__c=a.id;
        rr.product_line__c='TT200';
        rr.Net_Revenue__c =12;
        rr.Fiscal_Year__c =2018;
        rr.Fiscal_Period__c=12;
        rr.Billed_Units__c=6;
    
        insert rr;
		
        testEmail.init();
        testEmail.mostRecentRev=system.today();
    	Test.stopTest(); 
    	
	}

}