trigger CustomerInformationSheetS2S on Customer_Information_Sheet__c (before insert,before update) {
    List<PartnerNetworkRecordConnection> prnc = new List<PartnerNetworkRecordConnection>();
    if(trigger.isbefore && trigger.size==1){
        if(trigger.new[0].ConnectionReceivedId != null && trigger.new[0].ConnectionReceivedId == '04P3F000000007cUAA'){
            try{
                if(trigger.new[0].Implementation_Contact_Legacy_S2S__c != null && trigger.new[0].Implementation_Contact_Legacy_S2S__c != ''){
                    trigger.new[0].Implementation_Contact__c = trigger.new[0].Implementation_Contact_Legacy_S2S__c;
                }
                else{
                    prnc = [SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE ConnectionId='04P3F000000007cUAA' AND Status='Received' AND PartnerRecordId=:trigger.new[0].Implementation_Contact_S2S__c LIMIT 1];
                    if(prnc.size()>0){
                        trigger.new[0].Implementation_Contact__c = prnc[0].LocalRecordId;
                    }
                }
                if(trigger.new[0].Implementation_Contact_Legacy_S2S__c != null && trigger.new[0].Implementation_Contact_Legacy_S2S__c != ''){
                    trigger.new[0].Installer_Contact__c = trigger.new[0].Implementation_Contact_Legacy_S2S__c;
                }
                else{
                    prnc = [SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE ConnectionId='04P3F000000007cUAA' AND Status='Received' AND PartnerRecordId=:trigger.new[0].Installer_Contact_Id_S2S__c LIMIT 1];
                    if(prnc.size()>0){
                        trigger.new[0].Installer_Contact__c = prnc[0].LocalRecordId;
                    }
                }
                if(trigger.new[0].Primary_Contact_Legacy_S2S__c != null && trigger.new[0].Primary_Contact_Legacy_S2S__c != ''){
                    trigger.new[0].Primary_Contact__c = trigger.new[0].Primary_Contact_Legacy_S2S__c;
                }
                else{
                    prnc = [SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE ConnectionId='04P3F000000007cUAA' AND Status='Received' AND PartnerRecordId=:trigger.new[0].Primary_Contact_S2S__c LIMIT 1];
                    if(prnc.size()>0){
                        trigger.new[0].Primary_Contact__c = prnc[0].LocalRecordId;
                    }
                }
            }
            catch(DmlException e){
                System.debug(e.getMessage());
            }               
        }
    }
    
}