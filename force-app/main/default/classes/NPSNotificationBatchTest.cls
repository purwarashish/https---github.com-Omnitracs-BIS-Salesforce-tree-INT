@isTest(SeeAllData=true)
public class NPSNotificationBatchTest {
    
    static testMethod void myUnitTest() {
        Account acct = new Account(Name = 'Account NPS Notification Batch Test', QWBS_Market__c = 'Enterprise', QWBS_Cust_ID__c = '12345678', Segment__c = 'TL', Fleet_Size__c = 10, BillingStreet = 'Billing Street 578', BillingCity = 'Billing City 578', BillingCountry = 'Billing Country 578', BillingState = 'Billing State 578', BillingPostalCode = 'Postal Code 578');
        insert acct;
        Map<Integer, Integer> monthWaveMap = new Map<Integer, Integer>{1 =>3, 2=>4, 3=>5, 4=>6, 5=>1, 6=>2, 7=>3, 8=>4, 9=>5,10=>6, 11=>1, 12=>2};
        Integer nextMonth = date.today().month() + 1;
        String wave = String.valueOf(monthWaveMap.get(nextMonth));
        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Title = 'Title', Email = 'testemail@email.com', AccountId = acct.Id, Inactive__c = FALSE, HasOptedOutOfEmail = FALSE, NPS_Wave__c = wave);
        insert con;
        EmailTemplate emailTemplate = new EmailTemplate(DeveloperName = 'NPS_Batch_Notification_Owner', Name = 'NPS Batch Notification Owner', IsActive = TRUE, FolderId = UserInfo.getUserId(), TemplateType= 'custom', Subject = 'Strategic and Enterprise NPS Contacts for {nextMonth} - Action Required', HtmlValue = '{acctOwnerFirstName},\nAs part of the NPS program, this is the {nextMonth} survey list.');
        insert emailTemplate;
        Test.startTest();
        Database.executeBatch(new NPSNotificationBatch());
        Test.stopTest();
    }
}