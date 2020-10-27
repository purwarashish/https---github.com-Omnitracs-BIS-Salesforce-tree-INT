trigger updateFundClaimPartnerAccount on SFDC_MDF_Claim__c (before insert, before update) {
    
    /**
    *   Update the account field when the record is owned by a partner
    *
    */

    Set<Id> ownerIds = new Set<Id>();
    
    //Loop through each fund claim and create a Set of all the UserIds for the fund claim owners 
    for (SFDC_MDF_Claim__c fundClaim : Trigger.new) {
        //Figure out the owner ids of the fund claims
        ownerIds.add(fundClaim.OwnerId);
    }

    //Create a map of the owernids to their partner accounts
    Map<Id,User> partnerAccts = new Map<Id,User>([Select Id, Contact.Account.Id from User where id in :ownerIds]);
    
    //Now loop through each fund claim to set the Partner Account Id on the claim
    for (SFDC_MDF_Claim__c fundClaim : Trigger.new) {
    
        //Only update the value for records that have an owner = partnerAccount
        if ((partnerAccts.get(fundClaim.OwnerId).Contact.Account.Id != NULL) && (fundClaim.account__c == NULL)) {
            fundClaim.account__c = partnerAccts.get(fundClaim.OwnerId).Contact.Account.Id;
        }
    } 
}