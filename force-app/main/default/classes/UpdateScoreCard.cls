global class UpdateScoreCard
{
    webservice static string updatePartnerScoreCard(string id) 
    {
        string acctId = id;
        string AcctOwnerId;
        String ownerAcct;
        List<Partner_Scorecard__c> lstPS = new List<Partner_Scorecard__c>();
               
        system.debug('@@@@acctId'+acctId);
        list<string> lstAcctId = new list<string>();
        if(acctId != null)
            lstAcctId.add(acctId);
      
        string partnerScoreCardId = ''; 
        list<User> lstUsr = new list<User>();
        if(lstAcctId != null && lstAcctId.size() >0)
        {
            lstPS = [SELECT 
                         Name
                     FROM
                         Partner_Scorecard__c
                     WHERE
                         Account__c IN :lstAcctId
                     AND
                         Current_Scorecard__c = true 
                     LIMIT
                         50000];
            if(lstPS != null && lstPS.size() > 0) 
            {
                partnerScoreCardId = lstPS[0].id;
                try{
                    update lstPS;
                }
                catch(Exception e)
                {
                    system.debug('Update failed......');    
                }
            } 
            
        }
        return partnerScoreCardId;
    }
}