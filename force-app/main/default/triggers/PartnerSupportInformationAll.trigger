trigger PartnerSupportInformationAll on Partner_Support_Information__c (before insert, after insert, after update) {

    List<Partner_Support_Information__c> lstPSI = new List<Partner_Support_Information__c>();
    
    if(Trigger.isBefore && Trigger.isInsert) {
        for(Partner_Support_Information__c psi : Trigger.new) {
            Integer count = [SELECT COUNT() FROM Partner_Support_Information__c WHERE Partner_Account__c = :psi.partner_account__c];
            
            if(0 < count) {
                psi.addError('A Partner Support Information Record already exists. Please delete that record first before adding a new one.');
                return;
            }
        }    
    }
    
    if(Trigger.isAfter) {
        List<String> lstAccountId = new List<String>();
        for(Partner_Support_Information__c psi : Trigger.new) {
            lstAccountId.add(psi.Partner_Account__c);
        }    
               
        PartnerSupportInformationUtils.updatePartnerSupportDetails(lstAccountId);
    }    
}