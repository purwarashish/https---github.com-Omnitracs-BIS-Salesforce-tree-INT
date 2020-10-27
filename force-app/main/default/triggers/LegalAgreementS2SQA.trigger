trigger LegalAgreementS2SQA on Custom_Legal_Agreement__c (after insert,after update) {
    List<PartnerNetworkRecordConnection> prnc = new List<PartnerNetworkRecordConnection>();
    if(trigger.isafter && trigger.size==1){
        if(trigger.new[0].ConnectionReceivedId != null && trigger.new[0].ConnectionReceivedId == '04P3F000000007hUAA'){
            Contract c = new Contract();
            system.debug('trigger.new[0].Account_Legacy_Id_S2S__c:'+trigger.new[0].Account_Legacy_Id_S2S__c);
            system.debug('trigger.new[0].Account_Id_S2S__c:'+trigger.new[0].Account_Id_S2S__c);
            if(trigger.new[0].Account_Legacy_Id_S2S__c != null && trigger.new[0].Account_Legacy_Id_S2S__c != ''){
                    c.AccountId = trigger.new[0].Account_Legacy_Id_S2S__c;
                }
                else{
                   prnc = [SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE ConnectionId='04P3F000000007hUAA' AND Status='Received' AND PartnerRecordId=:trigger.new[0].Account_Id_S2S__c LIMIT 1];
                   system.debug('prnc:'+prnc);
                    if(prnc.size()>0)
                    c.AccountId = prnc[0].LocalRecordId;
                }
            c.Affiliate_Language__c = trigger.new[0].Affiliate_Language__c;
            c.Customer_Indemnification__c = trigger.new[0].Omnitracs_Indemnification__c;
            c.Counterparty_Limitation_of_Liability__c = trigger.new[0].Omnitracs_Limitation_of_Liability__c;
            c.Cap_Percentage__c = String.valueof(trigger.new[0].Cap_Percentage__c);
            c.Agreement_Type__c = trigger.new[0].Agreement_Type__c;
            c.Contract_Grade__c = trigger.new[0].Contract_Grade__c;
            c.Convenience_Clause__c = trigger.new[0].Convenience_Clause__c;
            c.Customer_s_Assignability_Rights__c = trigger.new[0].Customer_Assignment_Rights__c;
            c.Data_Policy_c__c = trigger.new[0].Data_Policy__c;
            c.Data_Policy_Exceptions_Notes__c = trigger.new[0].Data_Policy_Exceptions_Notes__c;
            c.Equipment_Development_Obligations__c = trigger.new[0].Equipment_Development_Obligations__c;
            if(trigger.new[0].Future_Products_Obsolescence_Clause__c){
                c.Future_Products_Obsolescence_Clause__c = 'Yes';
            }else if(trigger.new[0].Future_Products_Obsolescence_Clause__c==false){
                c.Future_Products_Obsolescence_Clause__c = 'No';
            }
            c.Governing_Law_Venue_Notes__c = trigger.new[0].Governing_Law_Venue_Notes__c;
            c.Governing_Law_Venue__c = trigger.new[0].Governing_Law_Venue__c;
            c.Insurance__c = trigger.new[0].Insurance__c;
            c.Non_Standard_Payment_Terms_Details__c  = trigger.new[0].Non_Standard_Payment_Terms_Details__c ;
            c.Notice_Period_in_days__c = trigger.new[0].Notice_Period_in_days__c;
            c.Original_Expiration_Date__c = trigger.new[0].Original_Expiration_Date__c;
            c.Other_Non_Standard_Credits__c = trigger.new[0].Other_Non_Standard_Credits__c;
            c.Other_Non_Standard_Discounts__c = trigger.new[0].Other_Non_Standard_Discounts__c;
            c.Other_Non_Standard_Terms__c = trigger.new[0].Other_Non_Standard_Terms__c;
            c.Other_Shipment_Terms_Details__c = trigger.new[0].Other_Shipment_Terms_Details__c;
            //c.OwnerExpirationNotice = trigger.new[0].Owner_Expiration_Notice__c;
            //c.Owner_Notice_Date__c = trigger.new[0].Owner_Notice_Date__c;
            if(trigger.new[0].Remarketing_Rights__c){
                c.Remarketing_Rights__c = 'Yes';
            }else if(trigger.new[0].Remarketing_Rights__c==false){
                c.Remarketing_Rights__c = 'No';
            }
            c.Renewal_Term_Length_in_months__c = trigger.new[0].Renewal_Term_Length_in_months__c;
            c.Service_Development_Obligations__c = trigger.new[0].Service_Development_Obligations__c;
            c.SLA__c = trigger.new[0].SLA__c;
            c.SLApercentage__c = String.valueof(trigger.new[0].SLApercentage__c);
            c.SLA_Credit__c = trigger.new[0].SLA_Credit__c;
            c.SLA_Details__c = trigger.new[0].SLA_Details__c;
            c.Status = trigger.new[0].Status__c;
            c.Software_Development_Obligations__c = trigger.new[0].Software_Development_Obligations__c;
            c.Term_Type__c = trigger.new[0].Term_Type__c;
            c.Contract_Title__c = trigger.new[0].Agreement_Title__c;
            c.ID_S2S__c = trigger.new[0].Id_S2S__c;
            c.Master_Agreement_Id_S2S__c = trigger.new[0].Master_Agreement_Id_S2S__c;
            c.Legal_Entity_Name__c = trigger.new[0].Legal_Entity_Name__c;
            c.Ownerid = '0051T000008kK9RQAU';
            c.Omni_Assignability_Rights__c = trigger.new[0].Omnitracs_Assignment_Rights__c;
            c.Payment_Terms__c = trigger.new[0].Payment_Terms__c;
            c.StartDate = trigger.new[0].Effective_Date__c;
            c.EndDate = trigger.new[0].Expiration_Date__c;
            c.Agreement_Sub_Type__c = trigger.new[0].Agreement_Sub_Type__c;
            if(trigger.new[0].Record_Type_Name__c=='Customer'){
                c.recordtypeid = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Customer Agreement').getRecordTypeId();
            }
            if(trigger.new[0].Record_Type_Name__c=='Strategic'){
                c.recordtypeid = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Strategic Alliance Agreement').getRecordTypeId();
            }
            List<Contract> lstcon = new List<Contract>();
            lstcon.add(c);
            Schema.SObjectField ftoken = Contract.Fields.ID_S2S__c;
            Database.UpsertResult[] srList = Database.upsert(lstcon,ftoken,false);
        }
    }

}