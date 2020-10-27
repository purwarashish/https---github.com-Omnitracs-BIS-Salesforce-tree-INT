@isTest(SeeAllData=true) 
private class CustomerSurveyUtilsTest {
	private static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
	static testMethod void myUnitTest() {
		Account acct = util.createAccount('Customer Survey Utils Test Account');
		List<pse__Proj__c> projList = new List<pse__Proj__c>();
		projList.add(new pse__Proj__c(Name = 'Test ODOnsiteTraining Project', Actual_start_date__c = Date.today()));
		projList.add(new pse__Proj__c(Name = 'Test ODTrainingWebinar Project', Actual_start_date__c = Date.today()));
		projList.add(new pse__Proj__c(Name = 'Test ODPSProjectClosure Project', Actual_start_date__c = Date.today()));
        insert projList;
		/*Omni_Survey_Tracking__c relatedOst = [Select Id, Omni_Survey__c, Survey_Responded_To__c from Omni_Survey_Tracking__c where Id =: cs.Omni_Survey_Tracking__c LIMIT 1];
		
		relatedOst.Survey_Responded_To__c = true;
		relatedOst.Omni_Survey__c = cs.Id;
		relatedOst.Completion_Date__c = Date.today();
		relatedOst.Initiated_By__c = cs.Initiated_By__c;*/
		
		Omni_Survey_Tracking__c ost1 = new Omni_Survey_Tracking__c();
		Customer_Survey__c cs1 = new Customer_Survey__c();

		ost1.Omni_Survey__c = cs1.Id;
		ost1.Survey_Responded_To__c = false;
		
		cs1.Response_1__c = '5 - Very Satisfied';
		cs1.Response_2__c = '5 - Very Satisfied';
		cs1.Response_3__c = '5 - Very Satisfied';
		cs1.Response_4__c = '5 - Very Satisfied';
		cs1.Response_5__c = '5 - Very Satisfied';
		
		cs1.Survey_Type__c = 'ODOnsiteTraining';
		cs1.Project__c = projList.get(0).Id;
		
		Omni_Survey_Tracking__c ost2 = new Omni_Survey_Tracking__c();
		Customer_Survey__c cs2 = new Customer_Survey__c();

		ost2.Omni_Survey__c = cs2.Id;
		ost2.Survey_Responded_To__c = false;
		
		cs2.Response_1__c = '5 - Very Satisfied';
		cs2.Response_2__c = '5 - Very Satisfied';
		cs2.Response_3__c = '5 - Very Satisfied';
		cs2.Response_4__c = '5 - Very Satisfied';
		cs2.Response_5__c = '5 - Very Satisfied';
		
		cs2.Survey_Type__c = 'ODTrainingWebinar';
		cs2.Project__c = projList.get(1).Id;
		
		Omni_Survey_Tracking__c ost3 = new Omni_Survey_Tracking__c();
		Customer_Survey__c cs3 = new Customer_Survey__c();

		ost3.Omni_Survey__c = cs3.Id;
		ost3.Survey_Responded_To__c = false;
		
		cs3.Response_1__c = '5 - Very Satisfied';
		cs3.Response_2__c = '5 - Very Satisfied';
		cs3.Response_3__c = '5 - Very Satisfied';
		cs3.Response_4__c = '5 - Very Satisfied';
		cs3.Response_5__c = '5 - Very Satisfied';
		
		cs3.Survey_Type__c = 'ODPSProjectClosure';
		cs3.Project__c = projList.get(2).Id;
		
		Contact con = TestUtils.getContact(acct, 'Test Contact');
		Customer_Survey__c cs4 = new Customer_Survey__c();
		cs4.Completion_Date_Time__c = Datetime.now();
		cs4.Account__c = acct.Id;
		cs4.Recipient_Contact__c = con.Id;
		cs4.Response_1__c = '5';
		cs4.Response_9__c = 'Billing is mediocre';
		cs4.Survey_Type__c = 'NPS';
		cs4.Survey_Initiated__c = 'Initiated';
		
		insert ost1;
		insert ost2;
		insert ost3;
		
		cs1.Omni_Survey_Tracking__c = ost1.Id;
		cs2.Omni_Survey_Tracking__c = ost2.Id;
		cs3.Omni_Survey_Tracking__c = ost3.Id;
		Test.startTest();
		insert cs1;
		insert cs2;
		insert cs3;
		insert cs4;
		Test.stopTest();
	}
}