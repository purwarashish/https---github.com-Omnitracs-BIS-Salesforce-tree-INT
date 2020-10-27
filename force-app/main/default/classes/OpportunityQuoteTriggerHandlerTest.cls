/**
 * Created by arman_shah on 10/29/18.
 */

@isTest // ARMAN: (SeeAllData=True)
public  class OpportunityQuoteTriggerHandlerTest {

    @testSetup
    static void SetupData() {
        TestUtils.defineCustomSettings();
    }

    //test method to test updation of Quote's Start Date when there is no Contracts
    static testmethod void testOppQuoteDateswithoutContracts(){

        Account acc= new Account(Name='Test');
        acc.Primary_Business_Unit__c ='Roadnet';
        insert acc;

        Opportunity oppty= new Opportunity(Name='Test New Opportunity');
        oppty.Type = 'New Customer';
        oppty.AccountId =acc.ID;
        oppty.Order_Type__c = 'New';
        oppty.StageName = 'Sales Acceptance';
        oppty.CloseDate=System.today();
        oppty.Forecast_Category__c ='Best Case';
        oppty.CurrencyIsoCode ='USD';
        oppty.Probability=10;
        insert oppty;

        List<Opportunity> oppts = new List<Opportunity>();
        oppts.add(oppty);

        SBQQ__Quote__c qt=new SBQQ__Quote__c();
        qt.SBQQ__Account__c=acc.ID;
        qt.SBQQ__Opportunity2__c= oppty.Id;
        qt.SBQQ__StartDate__c = System.today();
        qt.SBQQ__Status__c='Draft';
        qt.SBQQ__Primary__c=true;
        qt.SBQQ__Status__c = 'Accepted';
        qt.SBQQ__Type__c='Quote';
        qt.SBQQ__SubscriptionTerm__c=2;
        insert qt;

        List<SBQQ__Quote__c> qtList= new List<SBQQ__Quote__c>();
        qtList.add(qt);

        OpportunityQuoteTriggerHandler.isFirstTime =true;
        oppty.CloseDate=System.today()+10;
        oppty.StageName = 'Closed Won';
        oppty.Closed_Won_Flag__c = true;
        oppty.Probability=100;
        update oppty;

        qt.SBQQ__StartDate__c = oppty.CloseDate;
        update qt;

    }

    // test method to test updation of Quote's Start date when Contracts are there on Opportunity.
    static testmethod void testOppQuoteDateswithContracts(){

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User userU = new User(Alias = 'standu', Email='standarduser@testorg.com.test',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.test');


        Account acc= new Account(Name='Test');
        acc.Primary_Business_Unit__c ='Roadnet';
        insert acc;

        Opportunity oppty= new Opportunity(Name='Test New Opportunity');
        oppty.Type = 'New Customer';
        oppty.AccountId =acc.ID;
        oppty.Order_Type__c = 'New';
        oppty.StageName = 'Sales Acceptance';
        oppty.CloseDate=System.today();
        oppty.Forecast_Category__c ='Best Case';
        oppty.CurrencyIsoCode ='USD';
        oppty.Probability=10;
        insert oppty;

        OpportunityQuoteTriggerHandler.isFirstTime =true;
        List<Opportunity> oppts = new List<Opportunity>();
        oppts.add(oppty);

        Contract cont =new Contract();
        cont.Contract_Title__c='TEst';
        cont.AccountId =acc.Id;
        cont.SpringCM_Opportunity__c =oppty.Id;
        cont.Status='Draft';
        cont.Affiliate_Language__c='Yes';
        cont.Version__c='2';
        cont.Legal_Entity_Name__c ='Omnitracs, LLC';
        cont.Agreement_Type__c ='Master';
        cont.Current_Contract_Manager__c =userU.Id;
        cont.Term_Type__c ='Fixed';
        cont.StartDate =System.today();
        cont.Contract_Renewal__c='No';
        insert cont;

        List<Contract> conList= new List<Contract>();
        conList.add(cont);

        SBQQ__Quote__c qt=new SBQQ__Quote__c();
        qt.SBQQ__Account__c=acc.ID;
        qt.SBQQ__Opportunity2__c= oppty.Id;
        qt.SBQQ__StartDate__c = cont.StartDate;
        qt.SBQQ__Status__c='Draft';
        qt.SBQQ__Primary__c=true;
        qt.SBQQ__Status__c = 'Accepted';
        qt.SBQQ__Type__c='Quote';
        qt.SBQQ__SubscriptionTerm__c=2;
        insert qt;

        List<SBQQ__Quote__c> qtList= new List<SBQQ__Quote__c>();
        qtList.add(qt);

        OpportunityQuoteTriggerHandler.isFirstTime =true;
        oppty.Forecast_Category__c='Commit';
        oppty.StageName='Closed Won';
        oppty.Closed_Won_Flag__c = true;
        oppty.Probability=100;
        update oppty;

        cont.StartDate =System.today()+ 10;
        update cont;

        qt.SBQQ__StartDate__c = cont.StartDate;
        update qt;

    }
}