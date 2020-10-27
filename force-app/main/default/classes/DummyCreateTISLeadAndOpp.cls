public class DummyCreateTISLeadAndOpp {
/*
    public Static String USER_PREF = '005';
    public static String GROUP_PREF = '00G';
    public static boolean isExecute = true;
    
    public static void UpdateTISRecords(Map<String, opportunity> mapOfOppUpdt, Map<Id, opportunity> mapOfOldOpp)
    {
        List<TIS_Detail_Opp_Lead__c> lstNewTIS = new List<TIS_Detail_Opp_Lead__c>();        
        map<String,User> mapIdUser = new map<String,User>();
        Set<String> setOppUsrOwnerId = new Set<String>();
        
        for(String opp:mapOfOldOpp.keySet()){
            String ownerIdOfOpp = mapOfOldOpp.get(opp).ownerId;
            if(ownerIdOfOpp.startsWith(USER_PREF))
                setOppUsrOwnerId.add(ownerIdOfOpp);
        }       
        
        if(setOppUsrOwnerId != null && !setOppUsrOwnerId.isEmpty())
            mapIdUser = new map<String,User>([Select Name,UserType from User where Id IN :setOppUsrOwnerId Limit 50000]);
                   
        for(TIS_Detail_Opp_Lead__c oppTIS:[select Id,state__C,opportunity__c,Date_Time_Out__c from TIS_Detail_Opp_Lead__c where opportunity__c IN :mapOfOppUpdt.keySet() and Date_Time_Out__c = null limit 50000]){
            
            Opportunity opp = mapOfOldOpp.get(oppTIS.opportunity__c);
            if(oppTIS.state__c == mapIdUser.get(opp.ownerId).name){
                oppTIS.Date_Time_Out__c = System.now();
                lstNewTIS.add(oppTIS);    
            }        
        }
        try{
            if(!lstNewTIS.isEmpty()){
                update lstNewTIS;                  
            }
            
            CreateNewTISRecord(mapOfOppUpdt.values(),'opportunity',null);
                
        }catch(Exception e){
            System.debug('@@Error in update@@ ' + e.getMessage());    
        }    
    }

    public static void UpdateTISRecordsLead(Map<String, Lead> mapOfLeadUpdt, Map<Id, Lead> mapOfOldLead)
    {
        List<TIS_Detail_Opp_Lead__c> lstNewTIS = new List<TIS_Detail_Opp_Lead__c>();
        Set<String> setLeadUsrOwnerId = new Set<String>();
        Set<String> setLeadQueOwnerId = new Set<String>();        
        map<String,User> mapIdUser = new map<String,User>();
        Map<string,group> mapGroup = new Map<string,group>();
        
        for(String oldLeadId:mapOfOldLead.keySet()){
            String ownerIdOfLead = mapOfOldLead.get(oldLeadId).ownerId;
            
            if(ownerIdOfLead != null && ownerIdOfLead.startsWith(USER_PREF)){        //Owner is user
                setLeadUsrOwnerId.add(ownerIdOfLead);
            }    
            else if(ownerIdOfLead != null && ownerIdOfLead.startsWith(GROUP_PREF)){  //Owner is Queue
                setLeadQueOwnerId.add(ownerIdOfLead);
            }    
        }
        //Get name of user
        if(setLeadUsrOwnerId.size()>0 && !setLeadUsrOwnerId.isEmpty())
            mapIdUser = new map<String,User>([Select Name,UserType from User where Id IN :setLeadUsrOwnerId Limit 50000]);
        //Get name of queue  
        if(setLeadQueOwnerId.size()>0 && !setLeadQueOwnerId.isEmpty()){
            mapGroup = new Map<string,group>([Select name from group where id IN :setLeadQueOwnerId Limit 50000]);    
        }
        
        for(TIS_Detail_Opp_Lead__c leadTIS:[select Id,lead__c,state__c,Date_Time_Out__c from TIS_Detail_Opp_Lead__c where lead__c =:mapOfLeadUpdt.keySet() and Date_Time_Out__c = null limit 1000])
        {    
            Lead objtemplead = mapOfOldLead.get(leadTIS.lead__c);           
            if((mapGroup != null && mapGroup.containsKey(objtemplead.ownerId) && leadTIS.state__c == mapGroup.get(objtemplead.ownerId).name)||
               (mapIdUser != null && mapIdUser.containsKey(objtemplead.ownerId) && leadTIS.state__c == mapIdUser.get(objtemplead.ownerId).name))
               {
                   leadTIS.Date_Time_Out__c = System.now();
                   lstNewTIS.add(leadTIS);    
               }      
        }        
        try{
            if(lstNewTIS.size()>0 && !lstNewTIS.isEmpty()){
                update lstNewTIS;
            }
            CreateNewTISRecord(null,'Lead',mapOfLeadUpdt.values());
                
        }catch(Exception e){
            System.debug('@@Error in update@@ ' + e.getMessage());    
        }    
    } 
    

    public static void CreateNewTISRecord(List<Opportunity> lstOpp, String objName, List<Lead> lstLead)
    {
         List<TIS_Detail_Opp_Lead__c> lstNewTIS = new List<TIS_Detail_Opp_Lead__c>();
         Set<String> setOppUsrOwnerId = new Set<String>();
         Set<String> setOppQueOwnerId = new Set<String>();
         Map<String,User> mapIdUser = new Map<String,User>();
         Map<string,group> mapGroup = new Map<string,group>();
         
         if(objName == 'Opportunity'){
            for(Opportunity opp:lstOpp){
                 setOppUsrOwnerId.add(opp.ownerId);                 
            }
            
            if(setOppUsrOwnerId != null && !setOppUsrOwnerId.isEmpty())
                mapIdUser = new map<String,User>([Select Name,UserType from User where Id IN :setOppUsrOwnerId Limit 50000]);            
             
            for(Opportunity opp:lstOpp){
                 String strOwnerId = opp.ownerId;
                 TIS_Detail_Opp_Lead__c newTIS = new  TIS_Detail_Opp_Lead__c();
                 
                 NewTIS.Opportunity__c = opp.Id;
                 NewTIS.name = 'owner';
                 if(strOwnerId.startsWith(USER_PREF)){
                   NewTIS.State__c = mapIdUser.get(strOwnerId).name;                     
                 }
                 NewTIS.Date_Time_In__c = System.now();
                 NewTIS.Who__c = UserInfo.getUserId();
                 
                 lstNewTIS.add(NewTIS);
             }   
         }
         else{
                            
              for(Lead objnewlead:lstLead){
                 String ownerIdVal = objnewlead.ownerId;
                 if(ownerIdVal.startsWith(USER_PREF)){
                     setOppUsrOwnerId.add(objnewlead.ownerId);
                 }    
                 else if(ownerIdVal.startsWith(GROUP_PREF)){
                     setOppQueOwnerId.add(objnewlead.ownerId);
                 }    
              }
                   
              if(setOppUsrOwnerId.size() > 0 && !setOppUsrOwnerId.isEmpty())
                mapIdUser = new map<String,User>([Select Name,UserType from User where Id IN :setOppUsrOwnerId Limit 50000]);
              if(setOppQueOwnerId.size() > 0 && !setOppQueOwnerId.isEmpty())
                mapGroup = new Map<string,group>([Select name from group where id IN :setOppQueOwnerId Limit 50000]);            
              
              for(Lead objnewlead:lstLead){
                 String strOwnerId = objnewlead.ownerId;
                 //creating new 'Time and State Detail' record
                 TIS_Detail_Opp_Lead__c newTIS = new TIS_Detail_Opp_Lead__c();
                 
                 NewTIS.Lead__c = objnewlead.Id;
                 NewTIS.name = 'owner';                                  
                 if(strOwnerId.startsWith(USER_PREF)){
                      if(mapIdUser.size() > 0 && !mapIdUser.isEmpty())
                      NewTIS.State__c = mapIdUser.get(strOwnerId).name;
                 }
                 else if(strOwnerId.startsWith(GROUP_PREF)){
                      if(mapGroup.size() > 0 && !mapGroup.isEmpty())
                      NewTIS.State__c = mapGroup.get(strOwnerId).name;
                  }                 
                 NewTIS.Date_Time_In__c = System.now();
                 NewTIS.Who__c = UserInfo.getUserId();
                 
                 lstNewTIS.add(NewTIS);
             }        
             
         }
        try
        {
            if(lstNewTIS != null && !lstNewTIS.isEmpty()){
                insert lstNewTIS;
            }
            
        }catch (exception e)
        {
            System.debug('@@Error@@ ' + e.getMessage());
            
        }
    
    }
    */
}