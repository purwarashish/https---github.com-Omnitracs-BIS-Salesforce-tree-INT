trigger updateFundRequestChannelManager on SFDC_MDF__c (before insert, before update) {

    /**
    *   Update the Partner Owner field when the record is owned by a partner
    *
    */
     
     Set<Id> ownerIds = new Set<Id>();
     //Loop through each fund request and create a Set of all the UserIds for the fund request owners 
     for (SFDC_MDF__c fundRequest : Trigger.new) {
         //Figure out the owner ids of the fund requests 
         ownerIds.add(fundRequest.OwnerId);
     }
     
     //Create a map of the owernids to their partner accounts
     Map<Id,User> partnerAccts = new Map<Id,User>([Select Id, Contact.Account.OwnerId from User where id in :ownerIds]);
     
     //Now loop through each fund request to set the Partner Account Id on the request
     for (SFDC_MDF__c fundRequest : Trigger.new) {
     //Update the partner account manager 
     if ((partnerAccts.get(fundRequest.OwnerId).Contact.Account.OwnerId != NULL) && (fundRequest.Partner_Owner__c == NULL)) {
        fundRequest.Partner_Owner__c = partnerAccts.get(fundRequest.OwnerId).Contact.Account.OwnerId;
     }
 }
 
}