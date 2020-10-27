public with sharing class LightningService {
    
	 @AuraEnabled
     public static List<SObject> executeQuery(String query){
         try{
             return Database.query(query);
         }catch(Exception e){
             throw new AuraHandledException('Error doing the query: '+query+' Error: '+e.getMessage());       
         }   
     }

    @AuraEnabled
    public static List<Account> getAccountList(){
        return [select Id, Name, Phone from Account limit 600];
    }

    @AuraEnabled
    public static String getTokenUrl(){
        OAuth_Connection_Details__c oauthConn = OAuth_Connection_Details__c.getOrgDefaults();
        return oauthConn.Instance_Url__c + '#####' + oauthConn.Access_Token__c;
    }

    public static String getLocalDate(String gmtDateStr){
        DateTime dateGMT = String.isNotBlank(gmtDateStr) ? DateTime.valueOf(gmtDateStr.replace('T', ' ')) : null;
        if(dateGMT != null)
            dateGMT = DateTime.newInstanceGMT(dateGMT.year(), dateGMT.month(), dateGMT.day(), dateGMT.hour(), dateGMT.minute(), dateGMT.second());
        return dateGMT == null ? '' : dateGMT.format();
    }
 
 }