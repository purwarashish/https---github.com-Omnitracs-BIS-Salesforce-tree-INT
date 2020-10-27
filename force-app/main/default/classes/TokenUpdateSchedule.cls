/***************************************************************************************************
 Created by: Yasir Arafat
 Date: 09/07/2020
 Service to update Access Token for Case Sync
****************************************************************************************************/
global class TokenUpdateSchedule implements Database.Batchable<OAuth_Connection_Details__c>, Database.Stateful, Database.AllowsCallouts, Schedulable {
    
    public boolean isAnyError = false;
    public String errorContent = '';
    public TokenUpdateSchedule(){}
        
    global List<OAuth_Connection_Details__c> start(Database.BatchableContext BC){
        List<OAuth_Connection_Details__c> outhConnList = new List<OAuth_Connection_Details__c>();
        OAuth_Connection_Details__c oauthConn = OAuth_Connection_Details__c.getOrgDefaults();
        outhConnList.add(oauthConn);
        return outhConnList;
    }
        
    global void execute(Database.BatchableContext BC, List<OAuth_Connection_Details__c> outhConnList) {
        try{
            OAuth_Connection_Details__c oauthConn = outhConnList.get(0);
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(oauthConn.Token_Endpoint_Url__c + oauthConn.Client_Id_Secret__c + oauthConn.Username_Password__c);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('Status Code: ' + res.getStatusCode() + '. Response Body: ' + res.getBody());
            isAnyError = res.getStatusCode() == 200 ? false : true;
            if(res.getStatusCode() == 200){
                Map<String, Object> respMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                oauthConn.Instance_Url__c = String.valueOf(respMap.get('instance_url'));
                oauthConn.Access_Token__c = String.valueOf(respMap.get('access_token'));
                oauthConn.Token_Updated_Time__c = DateTime.NOW();
                update oauthConn;
                System.debug('TokenUpdateSchedule successful');
            }else{
                isAnyError = true;
                errorContent = 'Error Occured while updating Access Token for Case Custom Adapter Service: ' + res.getBody();
                System.debug('TokenUpdateSchedule failed');
            }
        }catch(Exception e){
            isAnyError = true;
            errorContent = 'Error Occured while updating Access Token for Case Custom Adapter Service: ' + e.getMessage();
        }
    }
    
    //System.schedule('TokenUpdateSchedule', '0 0 0,4,8,12,16,20 * * ?', new TokenUpdateSchedule());    // Schedule to run evry 4 hours
    global void execute(SchedulableContext sc){
        Database.executeBatch(this, 1);
    }
     
    global void finish(Database.BatchableContext BC){
        if(isAnyError){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSenderDisplayName('Token Update Schedule Error');
            String[] toAddresses = new List<String> {UserInfo.getUserEmail()};
            String[] ccAddresses = new List<String> {'yarafat@omnitracs.com'};
            email.setSubject('Token Update Schedule Error');       
            email.setToAddresses(toAddresses);
            email.setCcAddresses(ccAddresses);
            email.setPlainTextBody(errorContent);
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
    }
}