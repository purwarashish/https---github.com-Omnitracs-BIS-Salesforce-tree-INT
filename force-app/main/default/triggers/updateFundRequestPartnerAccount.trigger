trigger updateFundRequestPartnerAccount on SFDC_MDF__c (before insert, before update) {

    /**
    *   Update the account field when the record is owned by a partner
    *
    */

     Set<Id> ownerIds = new Set<Id>();
    
     //Loop through each fund request and create a Set of all the UserIds for the fund request owners 
     for (SFDC_MDF__c fundRequest : Trigger.new) {
         //Figure out the owner ids of the fund requests 
         ownerIds.add(fundRequest.OwnerId);
     }
     
     //Create a map of the owernids to their partner accounts
     Map<Id,User> partnerAccts = new Map<Id,User>([Select Id, Contact.Account.Id from User where id in :ownerIds]);
    
     //Now loop through each fund request to set the Partner Account Id on the request
     for (SFDC_MDF__c fundRequest : Trigger.new) {
    
         //Only update the value for records that have an owner = partnerAccount
         if ((partnerAccts.get(fundRequest.OwnerId).Contact.Account.Id != NULL) && (fundRequest.Account__c == NULL)) {
            fundRequest.Account__c = partnerAccts.get(fundRequest.OwnerId).Contact.Account.Id;
         }
     } 


}