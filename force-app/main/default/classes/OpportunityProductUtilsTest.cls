/**
 * Created by Arman Shah on 9/24/18.
 */

@istest

private class OpportunityProductUtilsTest {

    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    @TestSetup
    static void SetupData() {
        TestUtils.defineCustomSettings();

        List<OpportunityLineItem> opportunityLineItems =
                new List<OpportunityLineItem>();

        Account acct = TestUtils.getAccount('acct1');
        insert acct;

        Opportunity opp = TestUtils.getOpportunity(acct, 'Opp 1');
        insert opp;

       // SBQQ__Quote__c sbQuote = util.createSBQuote(opp, acct, Date.today()+2, true);
       SBQQ__Quote__c sbQuote = new SBQQ__Quote__c();
       sbQuote.SBQQ__Account__c=acct.Id;
       sbQuote.SBQQ__Opportunity2__c = opp.id;
       sbQuote.SBQQ__SubscriptionTerm__c = 12;
       sbQuote.SBQQ__Status__c = 'Accepted';
       insert sbQuote;

        opp.SBQQ__PrimaryQuote__c = sbQuote.Id;
        opp.stageName = 'Closed Won';
        update opp;

        OpportunityLineItem oli = TestUtils.getOLI(opp);
        System.assert(oli != null);
        opportunityLineItems.add(oli);
        insert opportunityLineItems;
    }

    static testMethod void testUpdateOpportunityOwner() {
        List<Opportunity> opps = [SELECT Id, Name, OwnerId FROM Opportunity];

        List<OpportunityLineItem> opportunityLineItems =
            [SELECT Id, OpportunityId, Opportunity_Owner__c FROM OpportunityLineItem];

        Test.startTest();
        OpportunityProductUtils.updateOpportunityOwner(opportunityLineItems);
        Test.stopTest();

        OpportunityLineItem oli = [SELECT Id, Opportunity_Owner__c
            FROM OpportunityLineItem
            WHERE Id =: opportunityLineItems[0].Id];

        System.assertEquals(opps[0].ownerId, oli.Opportunity_Owner__c);
    }

    static testMethod void testValidateOpptyItemEditability() {
        List<OpportunityLineItem> opportunityLineItems =
            [SELECT Id, Opportunity_Owner__c FROM OpportunityLineItem];

        Map<Id, OpportunityLineItem> oldMap = new Map<Id, OpportunityLineItem>(
            [SELECT Id, Opportunity_Owner__c FROM OpportunityLineItem]);

        Test.startTest();
        OpportunityProductUtils.validateOpptyItemEditability(opportunityLineItems, oldMap);
        Test.stopTest();
    }
}