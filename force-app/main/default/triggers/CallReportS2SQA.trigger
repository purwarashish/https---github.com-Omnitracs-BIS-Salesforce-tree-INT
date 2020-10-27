trigger CallReportS2SQA on Call_Report__c (before insert,before update) {
    List<PartnerNetworkRecordConnection> prnc = new List<PartnerNetworkRecordConnection>();
    if(trigger.isbefore && trigger.size==1){
        if(trigger.new[0].ConnectionReceivedId != null && trigger.new[0].ConnectionReceivedId == '04P3F000000007hUAA'){
            try{
                if(trigger.new[0].Account_Legacy_Id_S2S__c != null && trigger.new[0].Account_Legacy_Id_S2S__c != ''){
                    trigger.new[0].Account__c = trigger.new[0].Account_Legacy_Id_S2S__c;
                }
                else{
                   prnc = [SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE ConnectionId='04P3F000000007hUAA' AND Status='Received' AND PartnerRecordId=:trigger.new[0].Account_S2S__c LIMIT 1];
                   //trigger.new[0].Account__c = prnc[0].LocalRecordId;
                }
                if(trigger.new[0].Contact_Legacy_Id_S2S__c != null && trigger.new[0].Contact_Legacy_Id_S2S__c != ''){
                    trigger.new[0].Contact_Name__c = trigger.new[0].Contact_Legacy_Id_S2S__c;
                }
                else{
                   prnc = [SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE ConnectionId='04P3F000000007hUAA' AND Status='Received' AND PartnerRecordId=:trigger.new[0].Contact_S2S__c LIMIT 1];
                    if(prnc[0]!=null){
                    trigger.new[0].Contact_Name__c = prnc[0].LocalRecordId;
                    }
                }
            }
            catch(DmlException e){
                System.debug(e.getMessage());
            }               
        }
    }
}