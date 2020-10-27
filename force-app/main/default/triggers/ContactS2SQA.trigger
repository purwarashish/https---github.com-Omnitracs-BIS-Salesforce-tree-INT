trigger ContactS2SQA on Contact (before insert,before update) {
    Map<String,Id> ownerMap = new Map<String,Id>();
    Map<String,Id> reportsMap = new Map<String,Id>();
    set<String> ownerset = new set<String>();
    list<String> reportsset = new list<String>();

    if(trigger.size == 1){
        if(trigger.new[0].ConnectionReceivedId != null && trigger.new[0].ConnectionReceivedId == '04P3F000000007hUAA'){
            if(trigger.new[0].Account_Legacy_Id_S2S__c != null && trigger.new[0].Account_Legacy_Id_S2S__c != ''){
                trigger.new[0].AccountId = trigger.new[0].Account_Legacy_Id_S2S__c;
            }
            else{
                List<PartnerNetworkRecordConnection> prnc = [SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE ConnectionId='04P3F000000007hUAA' AND Status='Received' AND PartnerRecordId=:trigger.new[0].Account_Id_s2s__c LIMIT 1];
                system.debug('prnc:'+prnc);
                if(prnc.size()>0)
                trigger.new[0].AccountId = prnc[0].LocalRecordId;
            }
            if(trigger.new[0].Reports_To_Id_s2s__c!=null && trigger.new[0].Reports_To_Id_s2s__c!=''){
                reportsset.add(trigger.new[0].Reports_To_Id_s2s__c);
            }
            ownerset.add(trigger.new[0].Owner_Id_s2s__c);
        }
    }
    
    system.debug('ownerset:'+ownerset);
    system.debug('reportsset:'+reportsset);
    
    if(ownerset.size()>0 && ownerset!=null){
        for(User u:[select id,email from user where email=:ownerset limit 1]){
            ownerMap.put(u.email,u.Id);
        }
    }
    
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
    
    system.debug('reportsMap:'+reportsMap);
    system.debug('ownerMap:'+ownerMap);
    
    for(Contact c:trigger.new){
        if(c.ConnectionReceivedId != null && c.ConnectionReceivedId == '04P3F000000007hUAA'){
            c.RecordTypeId = '01250000000DQCh'; 
            //Send extra field and map it in S2S and then find Id here
            c.ReportsToId = reportsMap.get(c.Reports_To_Id_s2s__c);
            c.OwnerId = ownerMap.get(c.Owner_Id_s2s__c);
            if(c.OwnerId == null){
                c.OwnerId = System.Label.OmnitracsHouseAccountUser;
            }
        }
    }
}