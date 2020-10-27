/**
* @Author       Heidi Tang
* @Date         2016-04-25
* @Description  Trigger handler for KeyPlayersTrigger.trigger.
**/
public class KeyPlayersTriggerHandler{ 

    public static boolean runonce=false;
    
    public void onBeforeInsert(List<Key_Players_Influencers__c> newKeyPlayers){
        //check if Key Player with Contact, Opportunity already exist.
        checkAvailability(newKeyPlayers);
    }
    
    public static void updateAllPrimaryCheckboxFalse(){
        map<id,id> opportunityIdVsNewPrimaryKeyPlayerId = new map<id,id>();
        list<Key_Players_Influencers__c> toUpdate = new list<Key_Players_Influencers__c>();
        
        for(Key_Players_Influencers__c keyPlayInfInst : (list<Key_Players_Influencers__c>)Trigger.new){            
            if(keyPlayInfInst.Primary__c==true){
                opportunityIdVsNewPrimaryKeyPlayerId.put(keyPlayInfInst.Opportunity__c, keyPlayInfInst.id);
            }
        }
        
        for(Key_Players_Influencers__c keyPlayInst : [SELECT id,Primary__c,Opportunity__c FROM Key_Players_Influencers__c WHERE Opportunity__c in: opportunityIdVsNewPrimaryKeyPlayerId.keyset()]){
            if(keyPlayInst.Primary__c == true && opportunityIdVsNewPrimaryKeyPlayerId.containsKey(keyPlayInst.Opportunity__c) && opportunityIdVsNewPrimaryKeyPlayerId.get(keyPlayInst.Opportunity__c) != keyPlayInst.id){
                keyPlayInst.Primary__c = false;
                toUpdate.add(keyPlayInst);
            }
        }
        if(!toUpdate.isEmpty()){
            update toUpdate;
        }
        
    }
    
    public void onAfterInsert(Map<Id,Key_Players_Influencers__c> newKeyPlayersMap){

        //call the method to assign contact role
        assignContactRole(newKeyPlayersMap);
    }
    
     public void onBeforeUpdate(List<Key_Players_Influencers__c> newKeyPlayers,Map<Id,Key_Players_Influencers__c> oldKeyPlayersMap){
        
        List<Key_Players_Influencers__c> filterKeyPlayers = new List<Key_Players_Influencers__c>();
        
        for(Key_Players_Influencers__c keyPlayer : newKeyPlayers){
            Key_Players_Influencers__c oldKeyPlayer = oldKeyPlayersMap.get(keyPlayer.Id);
            
            // if old Name is not equal to Name and old Opportunity is not equal to Opportunity, check if it already exists.            
            if(!oldKeyPlayer.Name__c.equals(keyPlayer.Name__c)
                || !oldKeyPlayer.Opportunity__c.equals(keyPlayer.Opportunity__c)){
                filterKeyPlayers.add(keyPlayer);
            }
        }
        
        //check if Key Player with Contact, Opportunity already exist.
        checkAvailability(filterKeyPlayers);
    }
    
    public void onAfterUpdate(Map<Id,Key_Players_Influencers__c> newKeyPlayersMap, Map<Id,Key_Players_Influencers__c> oldKeyPlayersMap){
        
        Map<Id,Key_Players_Influencers__c> filteredKeyPlayersMap = new Map<Id,Key_Players_Influencers__c>();
        
        for(Key_Players_Influencers__c keyPlayer : newKeyPlayersMap.values()){
            
            Key_Players_Influencers__c oldKeyPlayer = oldKeyPlayersMap.get(keyPlayer.Id);
            
            // if old formal role is not equal to formal role, add the map to be reassign to contact role.            
            if(oldKeyPlayer.Formal_Role__c != keyPlayer.Formal_Role__c || oldKeyPlayer.Primary__c!= keyPlayer.Primary__c){
                system.debug('YES');
                filteredKeyPlayersMap.put(keyPlayer.Id,keyPlayer);
            }
        }
        system.debug('NO'+filteredKeyPlayersMap.values());
        //call the method to assign contact role
        assignContactRole(filteredKeyPlayersMap);
    }
    
    public void onBeforeDelete(List<Key_Players_Influencers__c> oldKeyPlayers){
        
        // call the method to remove contact role.
        removeContactRole(oldKeyPlayers);
    }
    
    /**
    * @Author       Heidi Tang
    * @Date         2016-04-25
    * @Description  Check if key player already exist
    * @Requirement  REQ-0482 Auto-populate Contact Roles with Key Players/Influencers value.
    * @param Map<Id,Case> newKeyPlayersMap : map list of the new key players.       
    **/
    public void checkAvailability(List<Key_Players_Influencers__c> newKeyPlayers){
        
        Set<Id> oppIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        for(Key_Players_Influencers__c keyPlayer : newKeyPlayers){
            
            // Contact and Opportunity should not be empty.
            if(!String.isEmpty(keyPlayer.Name__c) && !String.isEmpty(keyPlayer.Opportunity__c)){

                //Store contact id and Opportunity in a set. 
                oppIds.add(keyPlayer.Opportunity__c);
                contactIds.add(keyPlayer.Name__c);
            }
        }
        
        // check if the key player already exists
        for(Key_Players_Influencers__c existingKeyPlayer : new List<Key_Players_Influencers__c>([
                                                            SELECT Id,Name__c,Opportunity__c FROM Key_Players_Influencers__c 
                                                            WHERE Name__c IN :contactIds AND Opportunity__c IN :oppIds])){

            for(Key_Players_Influencers__c newKeyPlayer : newKeyPlayers){
                if(newKeyPlayer.Name__c.equals(existingKeyPlayer.Name__c) &&
                    newKeyPlayer.Opportunity__c.equals(existingKeyPlayer.Opportunity__c)){
                    newKeyPlayer.addError(System.Label.Existing_Key_Player);
                }
            }
        }        
        
    }    
    
    /**
    * @Author       Heidi Tang
    * @Date         2016-04-25
    * @Description  Auto assigned of OpportunityContactRole by Key Players object.
    * @Requirement  REQ-0482 Auto-populate Contact Roles with Key Players/Influencers value.
    * @param Map<Id,Case> newKeyPlayersMap : map list of the new key players.       
    **/
    public void assignContactRole(Map<Id,Key_Players_Influencers__c> newKeyPlayersMap){
        
        Set<Id> oppIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        List<OpportunityContactRole> oppContactRoleList = new List<OpportunityContactRole>();        
        List<OpportunityContactRole> newOppContactRoleList = new List<OpportunityContactRole>();        
        
        for(Key_Players_Influencers__c keyPlayer : newKeyPlayersMap.values()){
            
            // Contact,Opportunity and Formal Role should not be empty.
            if(!String.isEmpty(keyPlayer.Name__c) && !String.isEmpty(keyPlayer.Opportunity__c) && !String.isEmpty(keyPlayer.Formal_Role__c)){

                //Store contact id and Opportunity in a set. 
                oppIds.add(keyPlayer.Opportunity__c);
                contactIds.add(keyPlayer.Name__c);
                
                // create a new Opportunity Contact Role                
                newOppContactRoleList.add(createOpportunityContactRole(keyPlayer));
            }
        }
        
        // Get related Contact Roles
        oppContactRoleList = new List<OpportunityContactRole>([SELECT Id,ContactId,OpportunityId,Role FROM OpportunityContactRole
            WHERE OpportunityId IN :oppIds AND ContactId IN :contactIds]);
            
        // compare existing and new OpportunityContactRole
        for(Integer i=0;i<oppContactRoleList.size();i++){
            for(Integer j=0;j<newOppContactRoleList.size();j++){
                
                if(oppContactRoleList[i].ContactId.equals(newOppContactRoleList[j].ContactId) 
                    && oppContactRoleList[i].OpportunityId.equals(newOppContactRoleList[j].OpportunityId)){
                    
                    /** if new OpportunityContactRole Role is equal to existing, 
                    *   remove from the list to be upsert, 
                    *   else set the id to know that its for an update.
                    **/
                    //if(oppContactRoleList[i].Role != null){
                        //if(oppContactRoleList[i].equals(newOppContactRoleList[j])){
                            //newOppContactRoleList.remove(j);
                        //} else{
                            newOppContactRoleList[j].Id = oppContactRoleList[i].Id;
                       // }
                    //} else{
                        //newOppContactRoleList[j].Id = oppContactRoleList[i].Id;
                    //}
                }
            }
        }        
    
        if(newOppContactRoleList.size()>0){
            try{
                //insert or update the contact roles
                Database.upsert(newOppContactRoleList,false);
                //upsert newOppContactRoleList;
            } catch(DmlException dmle){
                // catch error on the dml statement
                for(Key_Players_Influencers__c keyPlayer : newKeyPlayersMap.values()){
                    keyPlayer.addError(dmle.getDmlMessage(0));
                }
            }
        }
    }
    
    /**
    * @Author       Heidi Tang
    * @Date         2016-04-25
    * @Description  Create an OpportunityContactRole from a Key Player.
    * @Requirement  REQ-0482 Auto-populate Contact Roles with Key Players/Influencers value.
    * @param  Key_Players_Influencers__c keyPlayer : the new key player.       
    **/
    public OpportunityContactRole createOpportunityContactRole(Key_Players_Influencers__c keyPlayer){
        
        OpportunityContactRole oppContactRole = new OpportunityContactRole();
        oppContactRole.ContactId = keyPlayer.Name__c;
        oppContactRole.OpportunityId = keyPlayer.Opportunity__c;
        oppContactRole.Role = keyPlayer.Formal_Role__c;
        oppContactRole.isPrimary = keyPlayer.Primary__c;
        
        return oppContactRole;
    }
    
    /**
    * @Author       Heidi Tang
    * @Date         2016-04-25
    * @Description  Remove assignment of OpportunityContactRole by Key Players object.
    * @Requirement  REQ-0482 Auto-populate Contact Roles with Key Players/Influencers value.
    * @param Map<Id,Case> oldKeyPlayersMap : map list of the old key players.       
    **/
    public void removeContactRole(List<Key_Players_Influencers__c> oldKeyPlayers){
        
        Set<Id> oppIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<String> roleNames = new Set<String>();
        
        
        for(Key_Players_Influencers__c keyPlayer : oldKeyPlayers){
            
            // Check if Related Contact, Opportunity and Role is not empty or null.
            if(!String.isEmpty(keyPlayer.Name__c) && !String.isEmpty(keyPlayer.Opportunity__c) && !String.isEmpty(keyPlayer.Formal_Role__c)){
                oppIds.add(keyPlayer.Opportunity__c);
                contactIds.add(keyPlayer.Name__c);
                roleNames.add(keyPlayer.Formal_Role__c);
                
            }
        }
        
        // Get related Contact Roles
        List<OpportunityContactRole> oppContactRoleList = new List<OpportunityContactRole>([SELECT Id FROM OpportunityContactRole
                                                                WHERE OpportunityId IN :oppIds AND ContactId IN :contactIds AND Role IN :roleNames]);
        
        if(oppContactRoleList.size()>0){
            try{
                //remove the contact roles
                delete oppContactRoleList;
            } catch(DmlException dmle){
                // catch error on the dml statement
                for(Key_Players_Influencers__c keyPlayer : oldKeyPlayers){
                    keyPlayer.addError(dmle.getDmlMessage(0));
                }
            }
        }   
    }
}