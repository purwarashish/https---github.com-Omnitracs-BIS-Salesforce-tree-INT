trigger OpportunityS2S on Opportunity (before insert,before update) {
    List<PartnerNetworkRecordConnection> prnc = new List<PartnerNetworkRecordConnection>();
    List<PartnerNetworkRecordConnection> prnc1 = new List<PartnerNetworkRecordConnection>();
    List<PartnerNetworkRecordConnection> prnc2 = new List<PartnerNetworkRecordConnection>();
    List<PartnerNetworkRecordConnection> prnc3 = new List<PartnerNetworkRecordConnection>();
    set<String> ownerset = new set<String>();
    Map<String,Id> ownermap = new Map<String,Id>();
    if(trigger.isbefore && trigger.size==1){
        if(trigger.new[0].ConnectionReceivedId != null && trigger.new[0].ConnectionReceivedId == '04P3F000000007cUAA'){
            if(trigger.new[0].Owner_Id_S2S__c!=null && trigger.new[0].Owner_Id_S2S__c!=''){
                ownerset.add(trigger.new[0].Owner_Id_S2S__c);
            }
            if(ownerset.size()>0){
                for(User u:[select id,email from user where email=:ownerset limit 1]){
                    ownermap.put(u.email,u.Id);
                }
            }
            if(ownermap.size()>0){
                trigger.new[0].OwnerId = ownermap.get(trigger.new[0].Owner_Id_S2S__c);
            }
            if(trigger.new[0].OwnerId == null){
                trigger.new[0].OwnerId = System.Label.OmnitracsHouseAccountUser;
            }
            try{
                if(trigger.new[0].Account_Legacy_Id_S2S__c != null && trigger.new[0].Account_Legacy_Id_S2S__c != ''){
                    trigger.new[0].AccountId = trigger.new[0].Account_Legacy_Id_S2S__c;
                }
                else{
                   prnc = [SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE ConnectionId='04P3F000000007cUAA' AND Status='Received' AND PartnerRecordId=:trigger.new[0].Account_Id_S2S__c LIMIT 1];
                   trigger.new[0].AccountId = prnc[0].LocalRecordId;
                }
                if(trigger.new[0].Company_Transferred_from_Legacy_S2S__c != null && trigger.new[0].Company_Transferred_from_Legacy_S2S__c != ''){
                    trigger.new[0].Company_Transferred_from__c = trigger.new[0].Company_Transferred_from_Legacy_S2S__c;
                }
                else{
                   prnc1 = [SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE ConnectionId='04P3F000000007cUAA' AND Status='Received' AND PartnerRecordId=:trigger.new[0].Company_Transferred_from_Account_S2S__c LIMIT 1];
                   trigger.new[0].Company_Transferred_from__c = prnc1[0].LocalRecordId;
                }
                if(trigger.new[0].Eval_Parent_Opportunity_Legacy_S2S__c != null && trigger.new[0].Eval_Parent_Opportunity_Legacy_S2S__c != ''){
                    trigger.new[0].Eval_Parent_Opportunity__c = trigger.new[0].Eval_Parent_Opportunity_Legacy_S2S__c;
                }
                else{
                   prnc2 = [SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE ConnectionId='04P3F000000007cUAA' AND Status='Received' AND PartnerRecordId=:trigger.new[0].Eval_Parent_Opportunity_S2S__c LIMIT 1];
                   trigger.new[0].Eval_Parent_Opportunity__c = prnc2[0].LocalRecordId;
                }
                if(trigger.new[0].Primary_Contact_Legacy_Id_S2S__c != null && trigger.new[0].Primary_Contact_Legacy_Id_S2S__c != ''){
                    trigger.new[0].Primary_Contact__c = trigger.new[0].Primary_Contact_Legacy_Id_S2S__c;
                }
                else{
                   prnc3 = [SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE ConnectionId='04P3F000000007cUAA' AND Status='Received' AND PartnerRecordId=:trigger.new[0].Primary_Contact_Legacy_Id_S2S__c LIMIT 1];
                   trigger.new[0].Primary_Contact__c = prnc3[0].LocalRecordId;
                }
            }
            catch(DmlException e){
                System.debug(e.getMessage());
            }               
        }
    }
}