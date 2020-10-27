trigger AddressS2SQA on Address__c (before insert) {
    List<PartnerNetworkRecordConnection> prnc = new List<PartnerNetworkRecordConnection>();
    System.debug(trigger.new);
    for(Address__c ad: trigger.new){
        if(ad.ConnectionReceivedId != null && ad.ConnectionReceivedId == '04P3F000000007hUAA'){
            if(ad.Account_Legacy_Id_S2S__c != null && ad.Account_Legacy_Id_S2S__c != ''){
                ad.Account__c = ad.Account_Legacy_Id_S2S__c;
            }
            else{
                prnc = [SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE ConnectionId='04P3F000000007hUAA' AND Status='Received' AND PartnerRecordId=:ad.Account_Id_S2S__c LIMIT 1];
                if(prnc.size()>0) ad.Account__c = prnc[0].LocalRecordId;
            }
            
            System.debug(ad);
        }
    }
}