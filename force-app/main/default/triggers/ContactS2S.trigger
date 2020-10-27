trigger ContactS2S on Contact (before insert,before update) {
    Map<String,Id> ownerMap = new Map<String,Id>();
    Map<String,Id> reportsMap = new Map<String,Id>();
    Map<String,Id> accountMap= new Map<String,Id>();
    Map<String,Id> acccustMap = new Map<String,Id>();
    set<String> ownerset = new set<String>();
    list<String> reportsset = new list<String>();
    set<String> accset = new set<String>();
    if(trigger.isbefore){
        for(Contact c:trigger.new){
            if(c.ConnectionReceivedId != null && c.ConnectionReceivedId == '04P3F000000007cUAA'){
                ownerset.add(c.Owner_Id_s2s__c);
                if(c.Reports_To_Id_s2s__c!=null && c.Reports_To_Id_s2s__c!=''){
                    reportsset.add(c.Reports_To_Id_s2s__c);
                }
                accset.add(c.Account_Id_s2s__c);                
            }
        }
        system.debug('ownerset:'+ownerset);
        system.debug('reportsset:'+reportsset);
        system.debug('accset:'+accset);
        if(ownerset.size()>0 && ownerset!=null){
            for(User u:[select id,email from user where email=:ownerset limit 1]){
                ownerMap.put(u.email,u.Id);
            }
        }
        system.debug('line27');
        system.debug('reportsset size:'+reportsset.size());
        if(reportsset.size()>0 && reportsset!=null){
            system.debug('reportsset inside loop:'+reportsset);
            String sval = reportsset[0];
            String searchString = '\'*'+sval+'*\'';
            String soslQuery = 'FIND :searchString IN EMAIL FIELDS RETURNING Contact (Id,Email) Limit 1';
            System.debug('SOSL QUERY: '+soslQuery);
            List<List<SObject>> results =  Search.query(soslQuery);
            
            //List<SearchResult> output = new List<SearchResult>();
            if(results.size()>0){
                for(SObject sobj : results[0]){
                    //SearchResult sr = new SearchResult();
                    //sr.id = (String)sobj.get('Id');
                    //sr.value = (String)sobj.get('Email');
                    reportsMap.put((String)sobj.get('Id'),(String)sobj.get('Email'));
                    //output.add(sr)   ;
                }
            }
        }
        system.debug('line33');
        if(accset.size()>0 && accset!=null){
            for(Account a:[select id,NetSuite_Customer_ID__c from Account where NetSuite_Customer_ID__c =:accset limit 1]){
                accountMap.put(a.NetSuite_Customer_ID__c,a.Id);
            }
        }
        system.debug('line39');
        if(accset.size()>0 && accset!=null){
            for(Account a:[select id,QWBS_Cust_ID__c from Account where QWBS_Cust_ID__c =:accset limit 1]){
                acccustMap.put(a.QWBS_Cust_ID__c,a.Id);
            }
        }
        system.debug('accountMap:'+accountMap);
        system.debug('reportsMap:'+reportsMap);
        system.debug('ownerMap:'+ownerMap);
        for(Contact c:trigger.new){
            c.RecordTypeId = '01250000000DQCh'; 
            //c.Phone = '469-801-6226';
            if(accountMap.containsKey(c.Account_Id_s2s__c)){
                c.AccountId = accountMap.get(c.Account_Id_s2s__c);
            }
            if(acccustMap.containsKey(c.Account_Id_s2s__c)){
                c.AccountId = acccustMap.get(c.Account_Id_s2s__c);
            }
            //Send extra field and map it in S2S and then find Id here
            c.ReportsToId = reportsMap.get(c.Reports_To_Id_s2s__c);
            c.OwnerId = ownerMap.get(c.Owner_Id_s2s__c);
            if(c.OwnerId == null){
                c.OwnerId = System.Label.OmnitracsHouseAccountUser;
            }
        }
    }
    
}