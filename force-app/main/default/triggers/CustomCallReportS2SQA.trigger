trigger CustomCallReportS2SQA on Custom_Call_Report__c (after insert,after update) {
    List<PartnerNetworkRecordConnection> prnc = new List<PartnerNetworkRecordConnection>();
    List<PartnerNetworkRecordConnection> prnc2 = new List<PartnerNetworkRecordConnection>();
    system.debug('Custom call report:'+trigger.new);
    if(trigger.isafter && trigger.size==1){
        if(trigger.new[0].ConnectionReceivedId != null && trigger.new[0].ConnectionReceivedId == '04P3F000000007hUAA'){
            Call_Report__c c = new Call_Report__c();
            if(trigger.new[0].Account_Legacy_S2S__c != null && trigger.new[0].Account_Legacy_S2S__c != ''){
                c.Account__c = trigger.new[0].Account_Legacy_S2S__c;
            }
            else{
                prnc = [SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE ConnectionId='04P3F000000007hUAA' AND Status='Received' AND PartnerRecordId=:trigger.new[0].Account_S2S__c];
                	if(prnc.size()>0)
                    c.Account__c = prnc[0].LocalRecordId;
            }
            if(trigger.new[0].Contact_Legacy_Id_S2S__c != null && trigger.new[0].Contact_Legacy_Id_S2S__c != ''){
                c.Contact_Name__c = trigger.new[0].Contact_Legacy_Id_S2S__c;
            }
            else{
                prnc2 = [SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE ConnectionId='04P3F000000007hUAA' AND Status='Received' AND PartnerRecordId=:trigger.new[0].Contact_S2S__c];
                if(prnc2.size()>0)
                    c.Contact_Name__c = prnc2[0].LocalRecordId;
            }
            c.Applications_Services__c = trigger.new[0].Applications_Services__c;
            c.Customer_Attendees__c = trigger.new[0].Customer_Attendees__c;
            c.Date__c = trigger.new[0].Date__c;
            c.Follow_Up_Items_Next_Steps__c = trigger.new[0].Follow_Up_Items_Next_Steps__c;
            c.Hardware__c = trigger.new[0].Hardware__c;
            c.Items_for_Executive_Assistance__c = trigger.new[0].Items_for_Executive_Assistance__c;
            c.Meeting_Objective_Agenda__c = trigger.new[0].Meeting_Objective_Agenda__c;
            c.Meeting_Summary__c = trigger.new[0].Meeting_Summary__c;
            c.Method__c = trigger.new[0].Method__c;
            c.Next_Objective_Strategy__c = trigger.new[0].Next_Objective_Strategy__c;
            c.QWBS_Attendees__c = trigger.new[0].Omnitracs_Attendees__c;
            c.Operations_IT_Maintenance__c = trigger.new[0].Operations_IT_Maintenance__c;
            c.Product_Management_Attendees__c = trigger.new[0].Product_Management_Attendees__c;
            c.Purpose__c = trigger.new[0].Purpose__c;
            c.Sentiment__c = trigger.new[0].Sentiment__c;
            c.Status__c = trigger.new[0].Status__c;
            c.Top_Customer_Issues__c = trigger.new[0].Top_Customer_Issues__c;
            c.ID_S2S__c = trigger.new[0].ID_S2S__c;
            system.debug('Call Report:'+c);
            List<Call_Report__c> lstcon = new List<Call_Report__c>();
            lstcon.add(c);
            Schema.SObjectField ftoken = Call_Report__c.Fields.ID_S2S__c;
            Database.UpsertResult[] srList = Database.upsert(lstcon,ftoken,false);
            //upsert c;
        }
    }
    
}