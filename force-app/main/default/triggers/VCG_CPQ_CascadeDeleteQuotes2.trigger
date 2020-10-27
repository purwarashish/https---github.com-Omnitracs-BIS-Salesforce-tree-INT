/**
 * This trigger does a 'cascade delete' of all quotes related to an Account when the Account is deleted
 *
 * We do this for two reasons:
 *
 *   1) When the account is deleted, SF automatically deletes all related Opps, but the CascadeDeleteQuotes
 *      trigger on Opps is not triggered, so we need to delete all quotes related to all opps related to
 *      the deleted accounts.
 *
 *   2) It shouldn't happen, but in theory a quote can be related to a different account than the
 *      account related to the Opp. It's not really a valid scenario, but to make for good housekeeping
 *      we need to delete all quotes related to these accounts as well (assuming this is the account being
 *      deleted).
 *
 * Since we are using a Lookup relationship from Quote to Opp & Account (for specific reasons), we
 * don't get the standard Master-Detail functionality of cascade deletes. And while we could utilize
 * the Salesforce functionality to do cascade deletes for Lookup fields in the field config, this is
 * a feature that must be explicitly turned on for an org and would make that feature available
 * for the entire org. Since we can't be sure this is something that can/will be done for every
 * org that installs CPQ, we handle this functionality in a trigger - which can be ported to
 * any Salesforce org.
 *
 * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
 * @since   12.Jan.2015
 */
trigger VCG_CPQ_CascadeDeleteQuotes2 on Account (before update) {
  /*  
    // Note, we do this *before* delete because *after* delete the Account__c field has already been cleared
    // so no child quotes will be found.
    
    //prevent deletion of quotes whose parent account is deleted as the result of a merge
    set<Id> mergedAccountIds = new set<Id>();
    set<Id> deletedAccountIds = new set<Id>();
    for(Account a : [SELECT Id, MasterRecordId 
                       FROM Account 
                      WHERE IsDeleted = TRUE 
                        and Id IN :Trigger.new ALL ROWS])
    {
        if(a.MasterRecordId != null)
            mergedAccountIds.add(a.Id);//this is being deleted as the result of a merge
        else
            deletedAccountIds.add(a.Id);
    }
    
    //
    // Start with: Delete quotes related directly to this account
    //
    List<VCG_CPQ_Quote__c> quotes = [SELECT Id FROM VCG_CPQ_Quote__c 
                                      WHERE Account__c in :deletedAccountIds
                                        and Account__c Not In :mergedAccountIds];
    
    delete quotes;
    
    //
    // Next, delete any remaining quotes related through opps
    //
    quotes.clear();
    
    List<Opportunity> opps = [SELECT Id, (SELECT Id FROM Quotes__r) 
                                FROM Opportunity 
                               WHERE AccountId in :deletedAccountIds
                                 and AccountId Not In :mergedAccountIds];
    for (Opportunity opp : opps) {
        quotes.addAll(opp.Quotes__r);
    }
    
    if(quotes.size() > 0)
        delete quotes;
*/
}