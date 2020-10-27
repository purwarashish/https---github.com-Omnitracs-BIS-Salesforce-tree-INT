@isTest(SeeAllData=true) 
public class CaseCommentTriggerTest {
    private static testMethod void testSearch() {
        CaseTestData caseTestData  = new CaseTestData();
		//insert Account
		List<Account> accountList = caseTestData.CreateAcccount('guessWorkEffort', null, 1, null);
		insert accountList;
		//Insert Contact
		List<Contact> contactList =  caseTestData.CreateContact('guessWorkEffort', 1, accountList.get(0).id);
		insert contactList;
		//Get 'Email Agent' User
		List<User> lstemailAgentUser = [Select id, FirstName, LastName from User where username like: 'emailagent@omnitracs.com%'];
		Case tempCase = caseTestData.CreateCase('guessWorkEffort', 'Call Center', accountList, contactList, null, 1).get(0);
		insert tempCase;
		Test.startTest();
		System.runAs(lstemailAgentUser.get(0)){
			CaseComment ccomment = new CaseComment();
			ccomment.CommentBody = 'body';
			ccomment.ParentId = tempCase.Id;
			ccomment.IsPublished = true;
			insert ccomment;
			system.debug('****test: Case Comment 1 inserted. ');
			system.assert(ccomment.id != null,'Exception in Case Comment Creation');
			CaseComment createdComment = [Select Id, CommentBody From CaseComment where id = :ccomment.Id];
			createdComment.CommentBody = 'Updated Comment Body';
			update createdComment;
		}
		Test.stopTest();
    }
}