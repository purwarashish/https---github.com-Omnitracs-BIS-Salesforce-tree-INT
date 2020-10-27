@isTest public class ChangecaseownerExtension_test {
    @isTest public static void changecaseowner_Testnew() {
        Testutils.defineCustomSettings();
        Account account = new Account();
        account.Name = 'ABC Test Account';
        account.QWBS_Cust_ID__c = 'Test12345678';
        account.segment__c = 'TL';
        account.Fleet_Size__c = 150; 
        account.phone = '9640046008';
        account.account_type__c = 'Acquired';
        account.Lead_Source__c = '800#';
        account.Average_Length_of_Haul__c = 'Local (Less than 100 miles)';
        account.Regional_Vehicles__c = 100;
        account.Primary_Business__c = 'Distribution';
        account.BillingStreet = 'Harwood St';
        account.BillingCity = 'Dallas';
        account.BillingPostalCode = '75201';
        account.BillingCountry = 'USA';
        account.BillingState = 'TX';
        account.createddate = System.today();
        account.RecordTypeId = '01250000000DQBA';
        account.QWBS_Status__c = 'Active Prospect';
        account.QWBS_Market__c = 'Strategic';
        Insert account;
        
        Contact Contactnew= new Contact();
        Contactnew.AccountId= account.Id;
        Contactnew.RecordTypeId='01250000000DQCh';
        Contactnew.FirstName='TestFname';
        Contactnew.LastName='TestContact';
        Contactnew.Title='TestTitle';
        Contactnew.Decision_Maker_Influencer__c='Yes';        
        Contactnew.LeadSource='800#';
        Contactnew.Lead_Origin__c='XRS';
        Contactnew.Email = 'testemail@email.com';
        Contactnew.inactive__c=false;
        insert Contactnew;
        
        Case randomCase = new Case();
        randomCase.Subject = 'changecaseownerTest';
        randomCase.RecordTypeId = '01250000000Qz8C';
        randomCase.AccountId = Account.id;
        randomCase.ContactId = Contactnew.id;
        randomCase.Work_Effort_In_Minutes__c = 10;
        randomCase.Business_Unit__c = 'Roadnet';
        randomCase.Origin = 'Email';
        randomCase.Status = 'Open';
        randomCase.Substatus__c = 'In Progress';
        randomCase.Priority = '3-Low';
        randomCase.Subject = 'Test Case Subject';
        randomCase.Resolution__c = 'Test';
        randomCase.Queue__c = 'Field CS';
        insert randomCase;
        
        ApexPages.StandardController sc = ChangeCaseOwnerExtension.generateController(randomCase);
        ChangeCaseOwnerExtension testChangeCaseOwnerExtension = new ChangeCaseOwnerExtension(sc);
        List<SelectOption> tstSelectOption = testChangeCaseOwnerExtension.userPickList;
        testChangeCaseOwnerExtension.supportOrAll = 'Test Support';
        tstSelectOption = testChangeCaseOwnerExtension.userPickList;
        tstSelectOption = testChangeCaseOwnerExtension.queuePickList;
        testChangeCaseOwnerExtension.businessUnit = 'Roadnet';
        tstSelectOption = testChangeCaseOwnerExtension.queuePickList;
        testChangeCaseOwnerExtension.businessUnit = 'Sylectus';
        tstSelectOption = testChangeCaseOwnerExtension.queuePickList;
        testChangeCaseOwnerExtension.businessUnit = 'Omnitracs MX';
        tstSelectOption = testChangeCaseOwnerExtension.queuePickList;
        testChangeCaseOwnerExtension.emailComments = 'Test Comment';
        PageReference pr = testChangeCaseOwnerExtension.radioButtonOnchange();
        pr = testChangeCaseOwnerExtension.changeOwner();
        String testcaseownername = testChangeCaseOwnerExtension.findNameOfCaseOwner(randomCase.ownerId);
        testChangeCaseOwnerExtension.queueOrUser = 'queue';
        pr = testChangeCaseOwnerExtension.radioButtonOnchange();
        pr = testChangeCaseOwnerExtension.changeOwner();
        QueueSobject[] queues = [select queueid from QueueSobject where sobjecttype = 'Case' Limit 1]; 
        testcaseownername = testChangeCaseOwnerExtension.findNameOfCaseOwner(queues[0].queueid);

    }
}