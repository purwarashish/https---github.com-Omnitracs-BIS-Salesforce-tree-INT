public class LeadOwnerReAssignmentController
{
    /******** Final Constant **********************/
    
    final string USERTYPE = 'PowerPartner';
    final string GROUPTYPE = 'queue';
    final string CHECKUSRID = '005';
    final string CHECKEDGRPID ='00G';
    
    
    /************ public variable *****************/

    /*@Description : boolean varible to check if 
     * form validation is succesfull 
    */
    public Boolean isValid {get; set;}

    /*@Description : boolean varible to check if 
     * open activities are present the for the lead
    */
    
    public boolean isOpenActivity {get; set;}
    /*@Description : varible to store the reason for 
     * transfer of lead 
    */
    public string description {get; set;}
    
    /*@Description : varible to store the status as selected in the radio 
     * button in front end
    */
    //Commented by Anand
    //public string leadStatus {get;set;}
    
    /*@Description : varible to store the lead owner 
     * as selected in the dropdown list in front end
    */
    public string newOwner{get; set;}
    
    /*@Description : varible to store user name and id ,queue name and id 
     * name and id is split by ':'
    */
    public List<string> finalLstOfIdsOfUsrNQueue = new List<string>();
    
    /*@Description : varible to store current lead owner 
     * and is used in front end to check if the lead is assigned to 
     * same owner , requesting transfer
    */
    public string currentOwnerId {get; set;}
          
    /*@Description : varible to store the status of the lead and 
     * select the radio button in front end.
    */
    public string currentLeadStatus {get; set;}
    /*@Description: List to store Lead records 
     */
    public list<lead> lstLead = new list<lead>();
    /*@Description: value to determine if email will 
     *be send to the lead owner
     */
   // public static boolean isRedirect{get; set;}
    public  List<Id> lstTempOfId = new list<id>();

    
    public static boolean isSendEmail = false;
    
    /*@Description:String value to store the letter from 
     *front end
     */
    public String alphabet {get; set;}
    
     /*@Description:List of ids of user and queue 
      */
    public list<string> lstOfIdsOfUser {get; set;} //Id type replaced by string type
    public list<string> lstOfIdsOfQueue {get; set;}
    /*@description: string variable to store 
     *logged in user Id
    */
    public String usrId {get; set;}
    
    /*@Description: String variable to store the ownerId 
     *of the selected owner
    */
    public String SelectedOwnerId {get; set;}
    
    /*@description:String variable to store 
     *Current lead Id
     */
    public String leadId {get; set;}
    
    public Boolean isPortalUser {get; set;}
    
    /*@description:Map to store user and queue name
     */
    public map<Id,String> mapOfQueueNUsr{get; set;} {mapOfQueueNUsr= new map<Id,String>();} 
    
   // public boolean isDetailPage {get;set;}
     /*@Description: list to store users ids 
     *  present in a queue 
     *  
     */
    
    public static List<Id> lstOfUsrId = new List<Id>(); 
    /****** Private Members ***********/
    
    //Commented by Anand
    //private set<string> setPRMMasterLeadQueueIds = new set<string>();
    /*@Description: Variable to store the id of master partner Queue
     */
    private string masterPartnerQueueId ;
   
    /*@Description: list to store users ids 
     *  having the same role and Account as the 
     *  user
     */
    private list<User> lstUser {get; set;}
    
    private list<Lead> lstCurrentLead;
    
    /*@Description: list to store Queue ids 
     */
    private List<Group> lstQueue;
    
    /*@Description:Store logged in user account Id
     */   
    private String loggedUsrAcct;
    
    /*@Description:Store logged in user Role
     */   
    private String loggedUsrRole;
    
     /*@Description:Store logged in user Queue
     */  
    private List<String> loggedUsrQueue = new List<String>();
    
    /*@Description:Stores Copy of Map containing the user and Queue
     */  
    private map<Id,String> masterMapOfQueueNUser = new map<Id,String>(); 
    
      /*@Description:Stores Copy of list  containing the user and Queue ids
     */    
    private list<Id> MasterLstOfIds;
    
    private Lead currentLead ;
   
    public LeadOwnerReAssignmentController(ApexPages.StandardController controller) 
    {
        
         list<string> lstGrpId = new list<string>();
         leadId = Apexpages.currentPage().getParameters().get('Id');
         
         lstLead = [select 
                        id,
                        OwnerId,
                        status,
                        (Select 
                            Id, 
                            Subject,
                            ownerId,
                            IsTask 
                         From 
                            OpenActivities) 
                    from 
                        Lead 
                    where 
                        id =:leadId
                    limit 1];
                  
         if(lstLead != null && lstLead.size() >0)
         {
             Integer noOfOpenActivity ;
             set<string> setOpenActivityOwnerId = new set<string>();
             currentLeadStatus = lstLead[0].status;        
             currentOwnerId = lstLead[0].OwnerId;
             
             if(lstLead[0].OpenActivities !=null && lstLead[0].OpenActivities.size() > 0)
             {
                 for(integer i=0;i<lstLead[0].OpenActivities.size();i++)
                 {
                    setOpenActivityOwnerId.add(lstLead[0].OpenActivities[i].ownerId);
                 } 
             }
             if(lstLead[0].OpenActivities != null )
                noOfOpenActivity = lstLead[0].OpenActivities.size();
             if(noOfOpenActivity > 0 && setOpenActivityOwnerId.contains(currentOwnerId))
             {
                isOpenActivity = true;
             }
             else
             {
                isOpenActivity = false;
             }
         }
         usrId =  UserInfo.getUserId();
         lstOfIdsOfUser = new List<string>();
         lstOfIdsOfQueue = new List<string>();
         List<User> lstloggedUsr = new List<User>();
         List<GroupMember> lstGrpMem = new List<GroupMember>(); 
         List<Group> lstGrp = new List<Group>();
         try
         {
            lstloggedUsr = [select contactid,Accountid,UserRoleId,Queue__c,isPortalEnabled  
                                       from user where id =: usrId limit 1];
            lstGrpMem = [select groupid  from GroupMember 
                                        where UserOrGroupId = :usrId]; 
            
         }
         catch(Exception e)
         {
             system.debug('Exception querying User');
         }
         if(lstloggedUsr.size() != 0)
         {
            loggedUsrAcct = lstloggedUsr[0].Accountid;
            loggedUsrRole = lstloggedUsr[0].UserRoleId;
            
            if(lstloggedUsr[0].isPortalEnabled)
            {
             isPortalUser = true;
            }
         }
         if(lstGrpMem != null && lstGrpMem.size()>0)
         {
             for(GroupMember ids:lstGrpMem)
                lstGrpId.add(ids.groupid);
         }
          //checking sharing setting
         
         list<leadShare> lstLeadShare = [Select 
                                              LeadAccessLevel,
                                              UserOrGroupId
                                         From 
                                              LeadShare  
                                         Where 
                                              LeadId = :lstLead[0].id
                                          AND (UserOrGroupId = :usrId
                                               OR  UserOrGroupId IN :lstGrpId)];
          if(lstLeadShare != null && lstLeadShare.size()>0)
          {
              system.debug('$$$$$$$$'+lstLeadShare);
          
          }
         try
         {
              lstGrp = [select id,name from group where id IN : lstGrpId and  type =:GROUPTYPE ]; 
              
         }
         catch(Exception e)
         {
            system.debug('Exception querying User');    
         }
         if(lstGrp != null && lstGrp.size()!=0 )
         {
            for(Group grp:lstGrp)
                loggedUsrQueue.add(grp.name); 
         } 
         ShowAllUsers(); 
    }
    
    public PageReference ShowAllUsers()
    {
        if(lstOfIdsOfUser.size()>0)
        {
            lstOfIdsOfUser.clear();
        }
        if(lstOfIdsOfQueue.size()>0)
        {
            lstOfIdsOfQueue.clear();
        }
        List<String> lstQueueId = new List<String>();
        string blank = '-None-:none';
        finalLstOfIdsOfUsrNQueue.add(blank);
        
        /*****************Query Master Partner Queue*****************************************/ 
        
        //Commented by Anand
        /*List<PRMMasterLeadQueue__c> lstCustomQueueName = PRMMasterLeadQueue__c.getall().values();
        if(lstCustomQueueName != null && lstCustomQueueName.size() >0)
        {
            for(PRMMasterLeadQueue__c lst:lstCustomQueueName)
                lstQueueId.add(lst.PRMMasterQueue__c);
            if(lstQueueId != null && lstQueueId.size() > 0)
            { 
                for(string ids:lstQueueId )
                    setPRMMasterLeadQueueIds.add(ids );
            }
        }*/
        try
        {
                list<Group> reqdGroupId = new List<Group>();
                if(loggedUsrQueue != null && loggedUsrQueue.size() >0)
                {
                    
                    reqdGroupId  = [Select Id from Group 
                                           where name IN :loggedUsrQueue];
                }                            
                list<string> lsttempUserId = new list<string>();
                
                /**Recursively find users in the Queue of the logged in user's queue **/
                
                if(reqdGroupId != null && reqdGroupId.size() > 0)
                {
                   
                    for(Group grp:reqdGroupId) 
                    {   
                        list<id> lstTempUsrId = getGroupMembers(grp.id);
                        for(Integer i=0;i<lstTempUsrId.size();i++)
                        {
                            lsttempUserId.add(lstTempUsrId[i]);
                        }                      
                        
                    }
                }
                if(lsttempUserId != null && lsttempUserId.size()>0)
                {
                     
                     lstUser = [select lastname , firstname ,name from user 
                               where id IN :lsttempUserId
                               AND IsActive = true  
                               AND userType =: USERTYPE
                               order by name asc limit 1000];
                }
                
                User u = [select id, AccountId, profileId from User where id = : UserInfo.getUserId() limit 1];
                List<User> userListSameVarAcc;
                if(u.AccountId != null)
                {
                 userListSameVarAcc =  new List<User>();
                 userListSameVarAcc = [select id, FirstName, LastName from User where AccountId = :u.AccountId and profileId =:u.profileId and isActive = true];
                }
                
                if(lstUser != null && lstUser.size() != 0)
                {
                    
                    for(User usr:lstUser)
                    {
                        string lstVal = usr.LastName+','+usr.FirstName+':'+usr.Id;
                        lstOfIdsOfUser.add(lstVal); 
                        
                    }
                }
                
                Set<String> setOfUsers = new  Set<String>();
                setOfUsers.addAll(lstOfIdsOfUser);

                for(User usr:userListSameVarAcc)
                {
                     string lstVal = usr.LastName+','+usr.FirstName+':'+usr.Id;
                        
                     if(!setOfUsers.contains(lstVal))
                     lstOfIdsOfUser.add(lstVal); 
                        
                 }
                
                /** To query different queues to which a lead can be assigned. Fetched based on the 
                  the partner Account of the logged in user id **/
                
                //Commented for CR 90785: Remove Partner queue from list
                /*List<PRMAcctQueueCombination__c> lstAcctQueueCombination = PRMAcctQueueCombination__c.getall().values();
                List<string> lstStrOfQueueIds = new list<string>();
                if(lstAcctQueueCombination != null && lstAcctQueueCombination.size() > 0)
                {
                    for(PRMAcctQueueCombination__c lst:lstAcctQueueCombination)
                    {
                        if(lst.AccountId__c ==loggedUsrAcct.substring(0,15))
                        {
                            
                            string strOfQueueIds = lst.QueueIds__c;
                            if(strOfQueueIds.contains(','))
                                lstStrOfQueueIds = strOfQueueIds.split(',',0);
                            else{
                                lstStrOfQueueIds.add(strOfQueueIds);
                            }
                        }
                    }
                }
                if(lstStrOfQueueIds != null && lstStrOfQueueIds.size() > 0)
                    lstQueueId.addAll(lstStrOfQueueIds);
                
                lstQueue = [Select Name,
                                   Id 
                            From Group 
                            where type = :GROUPTYPE 
                                   AND 
                                  id  IN :lstQueueId];
               if(lstQueue != null && lstQueue.size() != 0)
               {                    
                    
                    map<string,string> newMap = new map<string,string>();
                    List<PRMQueueLabel__c> lstQueueLabel = PRMQueueLabel__c.getall().values();
                    if(lstQueueLabel != null && lstQueueLabel.size() >0)
                    {
                        for(PRMQueueLabel__c temp:lstQueueLabel)
                        {
                            newMap.put(temp.name ,temp.User_Friendly_Label__c); 
                        }
                    }
                    for(Group grp:lstQueue)
                    {
                        string str = grp.Name;
                        string usrfrndLabel;                        
                        if(newMap.containsKey(str))
                            usrfrndLabel = newMap.get(str);
                        string strVal;
                        string grId = grp.Id;*/
                        
                        //Commented by Anand                        
                        //if(setPRMMasterLeadQueueIds != null && setPRMMasterLeadQueueIds.size() > 0)
                        //{
                        /*    if(setPRMMasterLeadQueueIds.contains(grId.substring(0,15)))
                            {
                                
                                if(usrfrndLabel != null && usrfrndLabel != '')
                                    strVal = usrfrndLabel +':'+grp.Id;
                                else
                                {
                                    strVal = grp.Name +':'+grp.Id;  
                                }
                                finalLstOfIdsOfUsrNQueue.add(strVal);   
                            } */
                        //    else
                        //    {
                        /*        if(usrfrndLabel != null && usrfrndLabel != '')
                                    strVal = usrfrndLabel + ':'+ grp.Id;
                                else
                                    strVal = grp.Name + ':'+ grp.Id;    
                                lstOfIdsOfQueue.add(strVal);
                                 
                        //    }
                        //}
                        
                    }
               }*/
                mapOfQueueNUsr = masterMapOfQueueNUser.Clone();
               
        } 
        catch(Exception e)
        {
            system.debug('Exception querying User'+e);
        }
        return null;
    }
    
    
    
     public list<id> getGroupMembers(Id groupId)
    {
        
        List<GroupMember> lstGroupMembers = new List<GroupMember>();//List of group members
                
        //Queries group members
        lstGroupMembers = [select UserOrGroupId from GroupMember where GroupId = :groupId LIMIT 50000];
        
        for (GroupMember groupMember : lstGroupMembers){
            //If the queried members contain another group, calls the function again
            if (String.valueOf(groupMember.UserOrGroupId).startsWith('00G'))
            {
                getGroupMembers(groupMember.UserOrGroupId);
            }
            else
            {
                lstTempOfId.add(groupMember.UserOrGroupId);    
            }
        }
        
        return lstTempOfId;

    }    
    public  List<SelectOption> getItems()
    {
        
        List<SelectOption> options = new List<SelectOption>();
        finalLstOfIdsOfUsrNQueue.sort();
        //Commented for CR 90785: Remove Partner queue from list
        /*if(lstOfIdsOfQueue != null && lstOfIdsOfQueue.size()>0)
        {
            lstOfIdsOfQueue.sort();
            finalLstOfIdsOfUsrNQueue.addAll(lstOfIdsOfQueue);
        }*/
        if(lstOfIdsOfUser != null && lstOfIdsOfUser.size()>0)
        {
            lstOfIdsOfUser.sort();
            finalLstOfIdsOfUsrNQueue.addAll(lstOfIdsOfUser);
        }
        
        if(finalLstOfIdsOfUsrNQueue != null && finalLstOfIdsOfUsrNQueue.size()>0)
        {
            for(string str:finalLstOfIdsOfUsrNQueue)
            {
                List<string> splitStr = str.split(':',2 );
                options.add(new selectOption(splitStr[1],splitStr[0]));
            } 
        }
        return options;
    }
    //Commented by Anand
    /*public List<SelectOption> getTypes()
    {
        Schema.sObjectType sobject_type = Lead.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get('status').getDescribe().getPickListValues();
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry a : pick_list_values)
        {
            if(a.getLabel() != 'Pending Approval')
                options.add(new selectOption(a.getLabel(), a.getValue()));
            
        }
        return options;
    }*/
    
    
    
    public void AssignUserOrQueue()
    {
        
        if(newOwner == 'none')
        {
            isValid = false ;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select new owner .');
            ApexPages.addMessage(msg);
        }
        else if(description == '')
        {
           
            isValid = false ;
            //Commented by Anand
            //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please enter notes describing why you are re-assigning the lead.  Use the examples displayed to guide your entry.');
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please enter notes describing why you are re-assigning the lead.');
            ApexPages.addMessage(msg);
        }
        else if(newOwner == currentOwnerId)
        {
            isValid = false ;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select new owner, you cannot leave yourself as owner for this process.');
            ApexPages.addMessage(msg);  
        }
        //Commented by Anand
        /*else if(leadStatus == '')
        {
            isValid = false ;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, ' Please select a lead status . ' );
            ApexPages.addMessage(msg);

        }*/
        else
        {
            
            if(lstLead!=null && lstLead.size()>0)
                currentLead=lstLead[0];
            Note note = new Note(title = 'Lead Reassignment/Rejection',Body=description ,parentId=currentLead.id );
            insert note;    
   
            if(currentLead != null)
            {
                if(newOwner.substring(0, 3)==CHECKUSRID)
                {
                    
                    lstUser = [Select Id, Name,UserRoleId, Queue__c ,email from User 
                                      where id =:newOwner limit 1];
                    if(lstUser != null && lstUser.size() != 0)
                    {
                        if(currentLead != null)
                        {
                            currentLead.OwnerId = lstUser[0].Id;
                            /*
                            string OwnerRoleId = lstUser[0].UserRoleId;
                            system.debug('UserRoleId'+ OwnerRoleId);
                            list<userRole> lstusrRole = [Select Name From UserRole 
                                                         where id = :OwnerRoleId];
                            if(lstusrRole != null && lstusrRole.size()>0) 
                                currentLead.Lead_Owner_Role__c = lstusrRole[0].Name;
                            */    
                           //assign the open activities to the new owner
                           
                           if(currentLead.openActivities != null && currentLead.openActivities.size() > 0)
                           {
                               list<string> lstTaskIds = new list<string>();
                               list<string> lstEventIds = new list<string>();
                               for(integer i=0;i<currentLead.openActivities.size();i++)
                               {
                                   if(currentLead.openActivities[i].isTask == true)
                                   {
                                       
                                       lstTaskIds.add(currentLead.openActivities[i].id);     
                                   }
                                   else
                                   {
                                       lstEventIds.add(currentLead.openActivities[i].id);
                                   }
                               }
                               
                               
                               
                               if(lstTaskIds != null && lstTaskIds.size() >0)
                               {
                                   list<Task> lstTask = [select 
                                                           id,
                                                           ownerId
                                                         from
                                                            Task
                                                         where 
                                                             id IN :lstTaskIds];
                                   if(lstTask !=null && lstTask.size() > 0)
                                   {
                                       for(task records:lstTask)
                                       {
                                           records.ownerId = newOwner ;   
                                       }
                                       
                                       try
                                       {
                                           update lstTask;
                                       }
                                       catch(Exception e)
                                       {
                                        system.debug('could not update task'+ e);   
                                       }    
                                   }   
                               }
                               if(lstEventIds!= null && lstEventIds.size() >0)
                               {
                                   list<Event> lstEvent = [select 
                                                           id,
                                                           ownerId
                                                         from
                                                            Event
                                                         where 
                                                             id IN :lstEventIds];
                                   if(lstEvent !=null && lstEvent.size() > 0)
                                   {
                                       for(Event records:lstEvent)
                                       {
                                           records.ownerId = newOwner ;   
                                       }
                                       
                                       try
                                       {
                                           update lstEvent;
                                       }
                                       catch(Exception e)
                                       {
                                        system.debug('could not update event'+ e);   
                                       }    
                                   }   
                               }
                           }
                           
                                
                        }
                    }
                    
                }
                
                else if(newOwner.substring(0, 3) == '00G')
                {
                    system.debug(newOwner);
                    lstQueue = [Select 
                                    Name,
                                    Id
                                From 
                                    Group 
                                where
                                    type = :GROUPTYPE
                                    AND id = :newOwner]; 
                    if(lstQueue != null && lstQueue.size() != 0)
                    {
                        if(currentLead != null){
                            currentLead.OwnerId = lstQueue[0].Id;
                            //currentLead.Lead_Owner_Role__c = '';
                        }    
                    }
                    getGroupMembers(currentLead.OwnerId); //fetches the groupmembers in queue.
                }
           //Commented by Anand
           // currentLead.status =  leadStatus ;
                        
            try
            {
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.useDefaultRule = false;
                dmlOpts.EmailHeader.triggerUserEmail = true;
               // dmlOpts.optAllOrNone = true;
                currentLead.setOptions(dmlOpts);
                update currentLead;
                isValid = true;
               
            }
            catch(Exception e) 
            {    
                system.debug('update failed');
                isValid = false;
            }
            
        
            }
        }
        
    }
}