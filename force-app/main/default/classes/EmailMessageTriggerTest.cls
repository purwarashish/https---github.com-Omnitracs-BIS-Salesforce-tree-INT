@isTest(SeeAllData=true) 
public class EmailMessageTriggerTest {
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
        Case tempCase1 = caseTestData.CreateCase('guessWorkEffort', 'Call Center', accountList, contactList, null, 1).get(0);
        tempCase1.Status = 'Closed';
        insert tempCase1;
        Test.startTest();
        System.runAs(lstemailAgentUser.get(0)){
            EmailMessage tempEmailMsg1 = new EmailMessage(ParentId = tempCase.Id, BccAddress = 'test@test.com', CcAddress = 'test@test.com',FromAddress = 'test@test.com', FromName = 'test@test.com', HtmlBody = 'test@test.com', Headers = 'test@test.com',Subject = 'ref:_test@test.com',TextBody = 'ref:_test@test.com', ToAddress = 'test@test.com', Incoming = true);
            insert tempEmailMsg1 ;
            system.debug('****test: Email 1 inserted. ');
            system.assert(tempEmailMsg1.id != null,'Exception in Email Message Creation');
            
            EmailMessage tempEmailMsg2 = new EmailMessage(ParentId = tempCase1.Id, BccAddress = 'test@test.com', CcAddress = 'test@test.com',FromAddress = 'test@test.com', FromName = 'test@test.com', HtmlBody = 'test@test.com', Headers = 'test@test.com',Subject = 'ref:_test@test.com',TextBody = 'ref:_test@test.com', ToAddress = 'test@test.com', Incoming = true);
            insert tempEmailMsg2 ;
            system.debug('****test: Email 2 inserted. ');
            system.assert(tempEmailMsg2.id != null,'Exception in Email Message Creation');
            
            String mailBody = 'The following AUTO transaction requires your completion.\nCustomer Name  Customer ID  Contact Name\nABC 12345 TEST\nUnits to be returned by Customer\nMCP50\nIVG\nMCP200\nCONTRACT DETAILS\n';
            EmailMessage tempEmailMsg3 = new EmailMessage(ParentId = tempCase.Id, BccAddress = 'test@test.com', CcAddress = 'test@test.com',FromAddress = 'test@test.com', FromName = 'test@test.com', HtmlBody = 'test@test.com', Headers = 'test@test.com',Subject = 'AUTO - 832192: SERVICE_SHUTOFF - Brescome Barton - Roadnet -  Approve', TextBody = mailBody, ToAddress = 'test@test.com', Incoming = true);
            insert tempEmailMsg3;
            system.debug('****test: Email 3 inserted.');
            system.assert(tempEmailMsg3.id != null,'Exception in Email Message Creation');
            
            EmailMessage tempEmailMsg4 = new EmailMessage(ParentId = tempCase1.Id, BccAddress = 'test@test.com', CcAddress = 'test@test.com',FromAddress = 'test@test.com', FromName = 'test@test.com', HtmlBody = 'test@test.com', Headers = 'test@test.com',Subject = 'AUTO - 832191: STANDARD_TERMINATION - Bretz Trucking  - XRS -  Approve', TextBody = mailBody, ToAddress = 'test@test.com', Incoming = true);
            insert tempEmailMsg4;
            system.debug('****test: Email 4 inserted.');
            system.assert(tempEmailMsg4.id != null,'Exception in Email Message Creation');
            
            EmailMessage tempEmailMsg5 = new EmailMessage(ParentId = tempCase1.Id, BccAddress = 'test@test.com', CcAddress = 'test@test.com',FromAddress = 'test@test.com', FromName = 'test@test.com', HtmlBody = 'test@test.com', Headers = 'test@test.com',Subject = 'AUTO - 832191: EARLY_TERMINATION - Bretz Trucking  - XRS -  Approve', TextBody = 'The following AUTO transaction requires your completion.\nContact Name\nABC', ToAddress = 'test@test.com', Incoming = true);
            insert tempEmailMsg5;
            system.debug('****test: Email 5 inserted.');
            system.assert(tempEmailMsg5.id != null,'Exception in Email Message Creation');
        }
        Test.stopTest();
    }
}