global class UpdateContractRecordtypeBatch implements Database.Batchable<sObject>{
    Public String query;
    Public String keyFields;
    global Database.querylocator start(Database.BatchableContext BC){
        // Query = 'Select id,Contract_Title__c,Contract_Group__c,Contract_Type__c,Agreement_Type__c,Contract_Category_1__c,Contract_Category_2__c,Recordtype.Name from Contract WHERE Contract_Title__c = \'TESTTEST\' Limit 1 ';   
        Query = 'Select id,Contract_Title__c,Contract_Type__c,Agreement_Type__c,Contract_Category_1__c,Contract_Category_2__c,Recordtype.Name from Contract';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contract> scope){
        List<Contract> conToUpdateList = new List<Contract>();
        List<ContractRecordTypeCS__c> conRectypeCS = ContractRecordTypeCS__c.getAll().values();
        Map<String,String> conRecTypeCSMap = new Map<String,String>();
        Map<String,String> conRecTypeCSMap2 = new Map<String,String>();
        List<RecordType> rtList = [SELECT Id,Name FROM RecordType WHERE SobjectType='Contract'];
        Map<String,Id> conRecTypeMap = new Map<String,Id>();
        for(RecordType rt : rtList){
            conRecTypeMap.put(rt.Name,rt.Id);
        }
        System.debug('***conRecTypeMap'+conRecTypeMap);
        
        
        
        
        for(ContractRecordTypeCS__c con : conRectypeCS){
            //String congroup;
            String conagree;
            String concat1;
            String concat2;
            String contype;
            String conrectypename;
            
            // if(con.Contract_Group_c__c==null){
            //     congroup='';
            // }
            // else{
            //     congroup=con.Contract_Group_c__c;
            // }
            
            if(con.Agreement_Type__c==null){
                conagree='';
            }
            else{
                conagree=con.Agreement_Type__c;
            }
            
            if(con.Contract_Category_1__c==null){
                concat1='';
            }
            else{
                concat1=con.Contract_Category_1__c;
            }
            
            if(con.Contract_Category_2__c==null){
                concat2='';
            }
            else{
                concat2=con.Contract_Category_2__c;
            }
            
            if(con.Contract_Type__c==null){
                contype='';
            }
            else{
                contype=con.Contract_Type__c;
            }
            
            if(con.Recordtype_Name__c==null){
                conrectypename='';
            }
            else{
                conrectypename=con.Recordtype_Name__c;
            }
            
            conRecTypeCSMap.put(contype+conagree+concat1+concat2,conrectypename);
            conRecTypeCSMap2.put(con.Name+'/'+contype+'/'+conagree+'/'+concat1+'/'+concat2,conrectypename);
        }
        
        if(conRecTypeCSMap!=null && !conRecTypeCSMap.isEmpty()){
            System.debug('***conRecTypeCSMap'+conRecTypeCSMap);
            System.debug('***conRecTypeCSMap2'+conRecTypeCSMap2);
        }
        String rtString;
        String rtId;
        
        for(contract com : scope){
            // String congroup2;
            String conagree2;
            String concat12;
            String concat22;
            String contype2;
            
            // if(com.Contract_Group__c==null){
            //     congroup2='';
            // }
            // else{
            //     congroup2=com.Contract_Group__c;
            // }
            
            if(com.Agreement_Type__c==null){
                conagree2='';
            }
            else{
                conagree2=com.Agreement_Type__c;
            }
            
            if(com.Contract_Category_1__c==null){
                concat12='';
            }
            else{
                concat12=com.Contract_Category_1__c;
            }
            
            if(com.Contract_Category_2__c==null){
                concat22='';
            }
            else{
                concat22=com.Contract_Category_2__c;
            }
            
            if(com.Contract_Type__c==null){
                contype2='';
            }
            else{
                contype2=com.Contract_Type__c;
            }
            
            //keyFields = congroup2+contype2+conagree2+concat12+concat22;
            keyFields = contype2+conagree2+concat12+concat22;
            // s.Description = 'Updated in batch apex class'; 
            // accList.add(s);
            if(conRecTypeCSMap.containsKey(keyFields)){
                rtString = conRecTypeCSMap.get(keyFields);
                // rectypename
                if(conRecTypeMap.containsKey(rtString)){
                    System.debug('***contain');
                    rtId = conRecTypeMap.get(rtString);
                    System.debug('***containrtId'+rtId);
                    Contract con = new Contract();
                    con.Id=com.Id;
                    con.RecordTypeId=rtId;
                    conToUpdateList.add(con);
                }
            }
        }
        if(conToUpdateList!=null && !conToUpdateList.isEmpty()){
            system.debug('conToUpdateList'+conToUpdateList);
            update conToUpdateList;
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
}