/* Commented by Arindam Laik Aug 26,2015
   As same functionality we are achieving in DummyCreateTISLeadAndOpp class
   This is done as part of Lead and opprtunity trigger consolidation */   
public class CreateTISLeadAndOpp {
/*
    public Static String USER_PREF = '005';
    public static String GROUP_PREF = '00G';
    public static boolean isExecute = true;
    
    public static void UpdateTISRecords(Map<String, opportunity> mapOfOppUpdt, Map<Id, opportunity> mapOfOldOpp)
    {
        List<TIS_Detail_Opp_Lead__c> lstNewTIS = new List<TIS_Detail_Opp_Lead__c>();
        
        map<String,User> mapIdUser = new map<String,User>();
        map<String,GroupMember> mapIdGroupMember = new map<String,GroupMember>();
        List<String> lstOppUsrOwnerId = new List<String>();
        List<String> lstOppQueOwnerId = new List<String>();
        for(String opp:mapOfOldOpp.keySet()){
            String ownerIdOfOpp = mapOfOldOpp.get(opp).ownerId;
            system.debug('@@@@ownerIdOfOpp:::'+ownerIdOfOpp);
            if(ownerIdOfOpp.startsWith(USER_PREF))
                lstOppUsrOwnerId.add(mapOfOldOpp.get(opp).ownerId);
            else
                lstOppQueOwnerId.add(mapOfOldOpp.get(opp).ownerId);
        }
        
        system.debug('@@@@lstOppUsrOwnerId::::'+ lstOppUsrOwnerId);
        system.debug('@@@@lstOppQueOwnerId::::'+ lstOppQueOwnerId);
        if(lstOppUsrOwnerId != null && !lstOppUsrOwnerId.isEmpty())
            mapIdUser = new map<String,User>([Select Name,UserType from User where Id IN :lstOppUsrOwnerId]);
        else{
            mapIdGroupMember = new map<String,GroupMember>([Select groupId,UserOrGroupId from GroupMember where UserOrGroupId IN :lstOppQueOwnerId]);    
        }
        
        system.debug('@@@@mapIdUser::::'+ mapIdUser);
        system.debug('@@@@mapIdGroupMember::::'+ mapIdGroupMember);
        Map<string,group> mapGroup = new Map<string,group>();
        if(mapIdGroupMember != null && !mapIdGroupMember.isEmpty()){
            mapGroup = new Map<string,group>([Select name from group where id IN :mapIdGroupMember.keyset()]);            
        }
        system.debug('@@@@mapGroup::::'+ mapGroup);
        
        for(TIS_Detail_Opp_Lead__c oppTIS:[select Id,state__C,opportunity__c,Date_Time_Out__c from TIS_Detail_Opp_Lead__c where opportunity__c IN :mapOfOppUpdt.keySet() and Date_Time_Out__c = null limit 50000]){
            system.debug('@@@@oppTIS::::'+ oppTIS);
            Opportunity opp = mapOfOldOpp.get(oppTIS.opportunity__c);
            system.debug('@@@@opp::::'+ opp);
            system.debug('@@@@opp owner::::'+ mapIdUser.get(opp.ownerId));
            if(oppTIS.state__c == mapIdUser.get(opp.ownerId).name){
                oppTIS.Date_Time_Out__c = System.now();
                lstNewTIS.add(oppTIS);    
            }        
        }
        system.debug('@@@@lstNewTIS'+lstNewTIS);
        try{
            if(!lstNewTIS.isEmpty()){
                update lstNewTIS;
                   
            }
            
            CreateNewTISRecord(mapOfOppUpdt.values(),'opportunity',null);    
        }catch(Exception e){
            System.debug('@@Error in update@@ ' + e.getMessage());    
        }    
    }

    public static void UpdateTISRecordsLead(Map<String, Lead> mapOfLeadUpdt, Map<Id, Lead> mapOfOldOpp)
    {
        List<TIS_Detail_Opp_Lead__c> lstNewTIS = new List<TIS_Detail_Opp_Lead__c>();
        List<String> lstOppUsrOwnerId = new List<String>();
        List<String> lstOppQueOwnerId = new List<String>();
        
        map<String,User> mapIdUser = new map<String,User>();
        map<String,GroupMember> mapIdGroupMember = new map<String,GroupMember>();
        Map<string,group> mapGroup = new Map<string,group>();
        
        system.debug('Lead update called:::'+isExecute);
        
        for(String opp:mapOfOldOpp.keySet()){
            String ownerIdOfOpp = mapOfOldOpp.get(opp).ownerId;
            system.debug('@@@@ownerIdOfOpp:::'+ownerIdOfOpp);
            if(ownerIdOfOpp != null && ownerIdOfOpp.startsWith(USER_PREF))
                lstOppUsrOwnerId.add(mapOfOldOpp.get(opp).ownerId);
            else
                lstOppQueOwnerId.add(mapOfOldOpp.get(opp).ownerId);
        }
        if(lstOppUsrOwnerId != null && !lstOppUsrOwnerId.isEmpty())
            mapIdUser = new map<String,User>([Select Name,UserType from User where Id IN :lstOppUsrOwnerId]);
        else{
            mapIdGroupMember = new map<String,GroupMember>([Select groupId,UserOrGroupId from GroupMember where groupId IN :lstOppQueOwnerId]);    
        }
        system.debug('lstOppUsrOwnerId'+ lstOppUsrOwnerId);
        system.debug('lstOppQueOwnerId'+ lstOppQueOwnerId);
        system.debug('mapIdGroupMember'+ mapIdGroupMember);
        List<String> lstGroupId =  new List<String>();
        if(mapIdGroupMember != null && !mapIdGroupMember.isEmpty()){
            for(String key:mapIdGroupMember.keyset())
                  {
                      lstGroupId.add(mapIdGroupMember.get(key).groupId);    
                  }
                  system.debug('@@@@lstGroupId'+lstGroupId);
                  if(lstGroupId != null && !lstGroupId.isEmpty())
                      mapGroup = new Map<string,group>([Select name from group where id IN :lstGroupId]);             
        }
        system.debug('mapGroup'+ mapGroup);
        for(TIS_Detail_Opp_Lead__c oppTIS:[select Id,lead__c,state__c,Date_Time_Out__c from TIS_Detail_Opp_Lead__c where lead__c =:mapOfLeadUpdt.keySet() and Date_Time_Out__c = null limit 1000]){
            Lead opp = mapOfOldOpp.get(oppTIS.lead__c);
            
            if( (mapGroup != null 
                    && mapGroup.containsKey(opp.ownerId) 
                    && oppTIS.state__c == mapGroup.get(opp.ownerId).name)){
                        system.debug('@@@@@mapIdGroupMember'+ mapIdGroupMember);
                        oppTIS.Date_Time_Out__c = System.now();
                        lstNewTIS.add(oppTIS);    
            }
            else if(mapIdUser != null && mapIdUser.containsKey(opp.ownerId) && oppTIS.state__c == mapIdUser.get(opp.ownerId).name){
                system.debug('@@@@@mapIdUser in side if'+ mapIdUser);
                        oppTIS.Date_Time_Out__c = System.now();
                        lstNewTIS.add(oppTIS);          
            }        
        }
        system.debug('@@@@lstNewTIS'+lstNewTIS);
        try{
            if(lstNewTIS != null && !lstNewTIS.isEmpty()){
                update lstNewTIS;    
            }
            CreateNewTISRecord(null,'Lead',mapOfLeadUpdt.values());    
        }catch(Exception e){
            System.debug('@@Error in update@@ ' + e.getMessage());    
        }    
    } 
    

    public static void CreateNewTISRecord(List<Opportunity> lstOpp, String objName, List<Lead> lstLead)
    {
         system.debug('call insert');
         List<TIS_Detail_Opp_Lead__c> lstNewTIS = new List<TIS_Detail_Opp_Lead__c>();
         List<String> lstOppUsrOwnerId = new List<String>();
         List<String> lstOppQueOwnerId = new List<String>();
         Map<String,String> mapRecIdOwnerId = new Map<String,String>();
         map<String,User> mapIdUser = new map<String,User>();
         System.debug('objName objName ::: ' + objName);
         if(objName == 'Opportunity'){
            for(Opportunity opp:lstOpp){
                 maprecIdOwnerId.put(opp.id,opp.ownerId);
                 String ownerIdVal = opp.ownerId;
                 lstOppUsrOwnerId.add(opp.ownerId);
                 
            }
            if(lstOppUsrOwnerId != null && !lstOppUsrOwnerId.isEmpty())
                mapIdUser = new map<String,User>([Select Name,UserType from User where Id IN :lstOppUsrOwnerId]);
            
             
             for(Opportunity opp:lstOpp){
             
                 System.debug('opp opp in for loop :::: ' + opp);
                 TIS_Detail_Opp_Lead__c newTIS = new  TIS_Detail_Opp_Lead__c();
                 NewTIS.Opportunity__c = opp.Id;
                 NewTIS.name = 'owner';
                 if(mapRecIdOwnerId.get(opp.Id).startsWith(USER_PREF))
                     NewTIS.State__c = mapIdUser.get(mapRecIdOwnerId.get(opp.Id)).name;
                     
                 system.debug('@@@@NewTIS.State__c:::'+NewTIS.State__c);
                 NewTIS.Date_Time_In__c = System.now();
                 NewTIS.Who__c = UserInfo.getUserId();
                 lstNewTIS.add(NewTIS);
             }   
         }
         else{
             for(Lead l:lstLead){
             system.debug('inside for '+lstLead);
                 maprecIdOwnerId.put(l.id,l.ownerId);
                 String ownerIdVal = l.ownerId;
                 if(ownerIdVal.startsWith(USER_PREF))
                     lstOppUsrOwnerId.add(l.ownerId);
                 else
                     lstOppQueOwnerId.add(l.ownerId);
            }
             system.debug('@@@@lstOppUsrOwnerId::::'+ lstOppUsrOwnerId);
             system.debug('@@@@lstOppQueOwnerId::::'+ lstOppQueOwnerId);
             
             
             map<String,GroupMember> mapIdGroupMember = new map<String,GroupMember>();
             if(lstOppUsrOwnerId != null && !lstOppUsrOwnerId.isEmpty())
                mapIdUser = new map<String,User>([Select Name,UserType from User where Id IN :lstOppUsrOwnerId]);
             else{
                mapIdGroupMember = new map<String,GroupMember>([Select groupId,UserOrGroupId from GroupMember where groupId IN :lstOppQueOwnerId]);    
             }
              List<String> lstGroupId  =  new List<String>();
              
              system.debug('@@@@mapIdUser::::'+ mapIdUser);
              system.debug('@@@@mapIdGroupMember::::'+ mapIdGroupMember);
              
              Map<string,group> mapGroup = new Map<string,group>();
              if(mapIdGroupMember != null && !mapIdGroupMember.isEmpty()){
                  for(String key:mapIdGroupMember.keyset())
                  {
                      lstGroupId.add(mapIdGroupMember.get(key).groupId);    
                  }
                  system.debug('@@@@lstGroupId'+lstGroupId);
                  if(lstGroupId != null && !lstGroupId.isEmpty())
                      mapGroup = new Map<string,group>([Select name from group where id IN :lstGroupId]);            
              }
              system.debug('@@@@mapGroup::::'+ mapGroup);
              for(Lead l:lstLead){
                 TIS_Detail_Opp_Lead__c newTIS = new  TIS_Detail_Opp_Lead__c();
                 NewTIS.Lead__c = l.Id;
                 NewTIS.name = 'owner';
                 if(mapRecIdOwnerId.get(l.Id).startsWith(USER_PREF))
                     NewTIS.State__c = mapIdUser.get(mapRecIdOwnerId.get(l.Id)).name;
                 else{
                         if(mapGroup != null && !mapGroup.isEmpty()){
                             NewTIS.State__c = mapGroup.get(mapRecIdOwnerId.get(l.Id)).name;
                     } 
                 }
                 NewTIS.Date_Time_In__c = System.now();
                 NewTIS.Who__c = UserInfo.getUserId();
                 lstNewTIS.add(NewTIS);
             }        
             
         }
        system.debug('@@@@@lstNewTIS in insert::'+ lstNewTIS);
        try
        {
            if(lstNewTIS != null && !lstNewTIS.isEmpty()){
                insert lstNewTIS;
            }
            
        }catch (exception e)
        {
            System.debug('@@Error@@ ' + e.getMessage());
            
        }
    
    }*/
    
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
    /*
    
    */
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
    
    /*
    */
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
}