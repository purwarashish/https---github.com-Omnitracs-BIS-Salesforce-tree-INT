@isTest(SeeAllData=true) 
public class NewCaseRedirect_CtrlTest {
    private static testMethod void testController() {
		CaseTestData caseTestData  = new CaseTestData();
		//insert Account
		List<Account> accountList = caseTestData.CreateAcccount('guessWorkEffort', null, 1, null);
		insert accountList;
		//Insert Contact
		List<Contact> contactList =  caseTestData.CreateContact('guessWorkEffort', 1, accountList.get(0).id);
		insert contactList;
		Case tempCase = caseTestData.CreateCase('guessWorkEffort', 'Call Center', accountList, contactList, null, 1).get(0);
		insert tempCase;
		ApexPages.StandardController sc = new ApexPages.StandardController(tempCase);
		
		Test.startTest();
		NewCaseRedirect_Ctrl controller = new NewCaseRedirect_Ctrl(sc);
		String nextPage = controller.doRedirect().getUrl();
		system.assert(nextPage != null,'Exception in getting Page Reference');
		
		controller = new NewCaseRedirect_Ctrl(sc);
		// Add parameters to page URL
		String recordTypeIdCase = String.valueOf(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call Center').getRecordTypeId()).substring(0,15);
		
		ApexPages.currentPage().getParameters().put('retURL', '/500/o');
		ApexPages.currentPage().getParameters().put('RecordType', recordTypeIdCase);
		ApexPages.currentPage().getParameters().put('ent', 'Case');
		ApexPages.currentPage().getParameters().put('cas4_lkid', 'Test');
		ApexPages.currentPage().getParameters().put('cas3_lkid', 'Test');
		ApexPages.currentPage().getParameters().put('cas3', 'Test');
		ApexPages.currentPage().getParameters().put('cas4', 'Test');
		ApexPages.currentPage().getParameters().put('def_account_id', accountList.get(0).id);
		ApexPages.currentPage().getParameters().put('def_contact_id', contactList.get(0).id);
		ApexPages.currentPage().getParameters().put('def_parent_id', accountList.get(0).id);
		ApexPages.currentPage().getParameters().put('Id', tempCase.Id);
		nextPage = controller.doRedirect().getUrl();
		system.assert(nextPage != null,'Exception in getting Page Reference');
		Test.stopTest();
    }
}