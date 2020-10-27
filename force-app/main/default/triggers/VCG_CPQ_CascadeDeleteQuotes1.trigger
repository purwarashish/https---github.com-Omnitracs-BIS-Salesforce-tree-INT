/**
 * This trigger does a 'cascade delete' of all quotes related to an opp when the opp is deleted
 *
 * Since we are using a Lookup relationship from Quote to Opp (for specific reasons), we don't get
 * the standard Master-Detail functionality of cascade deletes. And while we could utilize the
 * Salesforce functionality to do cascade deletes for Lookup fields in the field config, this is
 * a feature that must be explicitly turned on for an org and would make that feature available
 * for the entire org. Since we can't be sure this is something that can/will be done for every
 * org that installs CPQ, we handle this functionality in a trigger - which can be ported to
 * any Salesforce org.
 *
 * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
 * @since   12.Jan.2015
 */
trigger VCG_CPQ_CascadeDeleteQuotes1 on Opportunity (before delete) {
    /*
    // Note, we do this *before* delete because *after* delete the Opp__c field has already been cleared
    // so no child quotes will be found.
    
    List<VCG_CPQ_Quote__c> quotes = [SELECT Id FROM VCG_CPQ_Quote__c WHERE Opportunity__c = :Trigger.oldMap.keySet()];
    
    delete quotes;*/
}