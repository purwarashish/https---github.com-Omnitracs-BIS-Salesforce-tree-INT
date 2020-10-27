trigger updateFundClaimChannelManager on SFDC_MDF_Claim__c (before insert, before update) {

    /**
    *   Update the Partner Owner field when the record is owned by a partner
    *
    */
     
     Set<Id> ownerIds = new Set<Id>();
     
     
     //Loop through each fund claim and create a Set of all the UserIds for the fund claim owners 
     for (SFDC_MDF_Claim__c fundClaim : Trigger.new) {
         //Figure out the owner ids of the fund claims 
         ownerIds.add(fundClaim.OwnerId);
     }
         
     //Create a map of the owernids to their partner accounts
     Map<Id,User> partnerAccts = new Map<Id,User>([Select Id, Contact.Account.OwnerId from User where id in :ownerIds]);
     
     //Now loop through each fund claim to set the Partner Account Id on the claim
     for (SFDC_MDF_Claim__c fundClaim : Trigger.new) {
         //Update the partner account manager 
         if ((partnerAccts.get(fundClaim.OwnerId).Contact.Account.OwnerId != NULL) && (fundClaim.Partner_Owner__c == NULL)) {
            fundClaim.Partner_Owner__c = partnerAccts.get(fundClaim.OwnerId).Contact.Account.OwnerId;
         }
     }
 
}