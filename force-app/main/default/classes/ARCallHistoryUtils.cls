public class ARCallHistoryUtils{
    public static void ARCallHistoryInsert(List<AR_Call_History__c> ARCallData){

        Set<ID> acctIdSet = new Set<ID>();
        for(AR_Call_History__c arHistory : ARCallData){
            acctIdSet.add(arHistory.Account__c);
        }
        Map<ID, Account> acctMap = new Map<ID, Account>([Select Id, Name, Owner.Email, Owner.CPQ_Manager__r.Email, Owner.Sales_VP__r.Email, CSR__r.Email, Customer_Success_Lead__r.Email, Contracts_Administrator__r.Email from Account where Id in :acctIdSet]);
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'omnitracs.sfdc.noreply@omnitracs.com'];
        for(AR_Call_History__c arHistory : ARCallData){
            List<String> emailList = new List<String>();
            emailList.add(UserInfo.getUserEmail());
            Account acct = acctMap.get(arHistory.Account__c);
            emailList.add(acct.Owner.Email);
            if(null != acct.Owner.CPQ_Manager__r.Email)
                emailList.add(acct.Owner.CPQ_Manager__r.Email);
            if(null != acct.Owner.Sales_VP__r.Email)
                emailList.add(acct.Owner.Sales_VP__r.Email);
            if(null != acct.CSR__r.Email)
                emailList.add(acct.CSR__r.Email);
            if(null != acct.Customer_Success_Lead__r.Email)
                emailList.add(acct.Customer_Success_Lead__r.Email);
            if(null != acct.Contracts_Administrator__r.Email)
                emailList.add(acct.Contracts_Administrator__r.Email);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
            String htmlBody;
            email.setToAddresses(emailList);
            email.setSubject('New AR Call History record created for '+acct.Name+'. Please review');
            if(owea.size() > 0){
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }else{
                email.setSenderDisplayName('New AR Call History Creation');
            }
            htmlBody ='<html> <body> <font size = "3"> </br>'
                + 'The following AR Call History has been entered into Salesforce.com. It is important to review and make the actions according to the comments of the Collector. </br></br>'
                + 'Please find more details about the new AR Call History record:</br>'
                + '<b><u>ARCH#</u>:</b>&nbsp;&nbsp;' + arHistory.Name + '</br>'
                + '<b><u>Account</u>:&nbsp;&nbsp;</b> <a href="' + baseUrl + arHistory.Account__c + '" style="text-decoration:none !important;">'+acct.Name+'</a> </br>'
                + '<b><u>Call Type</u>:</b>&nbsp;&nbsp;' + arHistory.Call_Type__c + '</br>'
                + '<b><u>Subject</u>:</b>&nbsp;&nbsp;' + arHistory.Subject__c + '</br>'
                + '<b><u>Subject Details</u>:</b>&nbsp;&nbsp;' + arHistory.Subject_Details__c + '</br>'
                + '<b><u>Call Details</u>:</b>&nbsp;&nbsp;' + arHistory.Call_Details__c + '</br></br>'
                + 'Link to &nbsp;&nbsp;<a href="' + baseUrl + arHistory.Id + '" style="text-decoration:none !important;"><b>AR Call History</b> </a>'
                + '</font> </body> </html>';
            email.setHtmlBody(htmlBody);
            emailsToSend.add(email);
        }
        if(emailsToSend.size() > 0)
            Messaging.sendEmail(emailsToSend);     
    }    
}