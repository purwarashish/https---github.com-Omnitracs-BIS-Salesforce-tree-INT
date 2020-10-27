/***********************************************************************************
Author: Shruti Karn, Salesforce.com Developer
Tata Consultancy Services Limited
For CR#44574
Description:Functionality to allow portal user to transfer ownership 
            of lead to another user or queue.
************************************************************************************/
public class LeadOwnerAssignmentController {
    /******** Constants ***************/
    final string USERTYPE = 'PowerPartner';
    final string GROUPTYPE = 'queue';
    final string CHECKUSRID = '005';
    final string CHECKEDGRPID ='00G';
    /************ public variable *****************/
    /*@Description: value to determine if email will 
     *be send to the lead owner
     */
    public  List<Id> lstTempOfId = new list<id>();

    public static boolean isSendEmail {get; set;}
    
    /*@Description:String value to store the letter from 
     *front end
     */
    public String alphabet {get; set;}
    
     /*@Description:List of ids of user and queue 
      */
    public list<Id> lstOfIdsOfUsernQueue {get; set;}
    
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
    
    /*@description:Map to store user and queue name
     */
    public map<Id,String> mapOfQueueNUsr{get; set;} {mapOfQueueNUsr= new map<Id,String>();} 
    
    public boolean isDetailPage {get;set;}
     /*@Description: list to store users ids 
     *  present in a queue 
     *  
     */
    
    public static List<Id> lstOfUsrId = new List<Id>(); 
    /****** Private Members ***********/
    
   
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
    
    /*@Description:Constructor method.Queries User information
    */
    
    public LeadOwnerAssignmentController(ApexPages.StandardController controller)
    {
       list<string> grpId = new list<string>();
       leadId = Apexpages.currentPage().getParameters().get('Id');
       alphabet = 'All';
       
       usrId = UserInfo.getUserId();
       lstOfIdsOfUsernQueue = new List<Id>();
       List<User> lstloggedUsr = new List<User>();
       List<GroupMember> lstGrpMem = new List<GroupMember>(); 
       List<Group> lstGrp = new List<Group>();
       try{
            lstloggedUsr = [select contactid,Accountid,UserRoleId,Queue__c 
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
       }
       for(GroupMember ids:lstGrpMem)
           grpId.add(ids.groupid);
       try{
            lstGrp = [select id,name from group where id IN : grpId and  type =:GROUPTYPE ]; 
            system.debug('%%%%%'+lstGrp);
       }
       catch(Exception e)
       {
            system.debug('Exception querying User');    
       }
       if(lstGrp.size()!=0)
       {
            for(Group grp:lstGrp)
                loggedUsrQueue.add(grp.name); 
       }
       ShowAllUsers();
        
    }
    /*@Description:For displaying the sorted list based on the 
     *alphabet selected in front End
    */
    public PageReference Alphabet_Ordering()
    {
         lstOfIdsOfUsernQueue = MasterLstOfIds;
         if(lstOfIdsOfUsernQueue != null && lstOfIdsOfUsernQueue.size()>0)
         {
             //If 'All' is selected full list should be displayed
             if(alphabet == 'All')
             {
                 return null;
             }
             else
             {
                 list<Id> sortedList = new list<Id>();
                 for(integer i=0;i<lstOfIdsOfUsernQueue.size();i++)
                 {
                     Id mapkey = lstOfIdsOfUsernQueue[i];
                     String name = masterMapOfQueueNUser.get(mapkey);
                     if(name.indexof(alphabet) == 0)
                     {
                         sortedList.add(lstOfIdsOfUsernQueue[i]);
                                      
                     }
                 }
                 lstOfIdsOfUsernQueue = sortedList;
             }
         }
         return null;
        }
    /* @Description:To Display all the user and Queue satisfying the following 
     * criteria
     */
    public PageReference ShowAllUsers()
    {
        if(lstOfIdsOfUsernQueue.size()>0)
        {
            lstOfIdsOfUsernQueue.clear();
        }
        List<String> lstNameOfUsernQueue = new List<String>();
        List<String> lstQueueId = new List<String>(); 
        List<PRMMasterLeadQueue__c> lstCustomQueueName = PRMMasterLeadQueue__c.getall().values();
        for(PRMMasterLeadQueue__c lst:lstCustomQueueName)
            lstQueueId.add(lst.PRMMasterQueue__c);  
        try
        {
               
                list<Group> reqdGroupId = [Select Id from Group 
                                           where name IN :loggedUsrQueue];
                                             
                list<string> lsttempUserId = new list<string>();
                
                              
                Map<string,list<id>> mapTempGrpIdNlist = new Map<string,list<id>>(); 
                
                for(Group grp:reqdGroupId) 
                {   
                    list<id> lstTempUsrId = getGroupMembers(grp.id);
                    for(Integer i=0;i<lstTempUsrId.size();i++)
                    {
                        lsttempUserId.add(lstTempUsrId[i]);
                    }                      
                    
                }
                system.debug('@@@@@@@@@lsttempUserId'+lsttempUserId.size());
                
                
                if(lsttempUserId.size()>0)
                     lstUser = [select name from user 
                               where id IN :lsttempUserId
                               AND IsActive = true  
                               AND userType =: USERTYPE
                               order by name asc limit 1000];
                
                if(lstUser.size() != 0)
                {
                    for(User usr:lstUser)
                    {
                        lstOfIdsOfUsernQueue.add(usr.Id); 
                         
                        masterMapOfQueueNUser.put(usr.Id ,usr.Name);
                    }
                }
               lstQueue = [Select Name, Id From Group 
                                   where type = :GROUPTYPE AND id  IN :lstQueueId];
               if(lstQueue.size() != 0)
               {                    
                    for(Group grp:lstQueue)
                    {
                        lstOfIdsOfUsernQueue.add(grp.Id);
                        
                        masterMapOfQueueNUser.put(grp.Id ,grp.Name);
                        
                    }
               }
                mapOfQueueNUsr = masterMapOfQueueNUser.Clone();
                MasterLstOfIds = lstOfIdsOfUsernQueue;
                system.debug('lstOfIdsOfUsernQueue'+lstOfIdsOfUsernQueue);
        } 
        catch(Exception e)
        {
            system.debug('Exception querying User'+e);
        }
        return null;
    }
 
        
 /* @Description:for assigning the selected user or queue to the Lead
  */   
   
    public void AssignUserOrQueue()
    {
        Boolean isUsrOrQueue = false;
        
        try
        {
            list<lead> lst ;
            lst = [select id, OwnerId from Lead where id =:leadId limit 1];
            if(lst!=null && lst.size()>0)
                currentLead=lst[0];
            if(currentLead != null)
            {
                if(SelectedOwnerId.substring(0, 3)==CHECKUSRID)
                {
                    isUsrOrQueue = true;
                    lstUser = [Select Id, Name,UserRoleId, Queue__c ,email from User 
                                      where id =:SelectedOwnerId limit 1];
                    if(lstUser.size() != 0)
                    {
                        if(currentLead != null)
                        {
                            currentLead.OwnerId = lstUser[0].Id;
                            string OwnerRoleId = lstUser[0].UserRoleId;
                            system.debug('UserRoleId'+ OwnerRoleId);
                            list<userRole> lstusrRole = [Select Name From UserRole 
                                                         where id = :OwnerRoleId];
                            if(lstusrRole !=null && lstusrRole.size()>0) 
                                currentLead.Lead_Owner_Role__c = lstusrRole[0].Name;
                                system.debug('@@@@@'+currentLead.Lead_Owner_Role__c);
                        }
                    }
                    
                }
                
                else if(SelectedOwnerId.substring(0, 3) == '00G')
                {
                    system.debug('in else');
                    system.debug(SelectedOwnerId);
                    isUsrOrQueue = false;
                    lstQueue = [Select Name, Id From Group 
                                       where type = :GROUPTYPE  AND id = :SelectedOwnerId]; 
                    if(lstQueue.size() != 0)
                    {
                        if(currentLead != null){
                            currentLead.OwnerId = lstQueue[0].Id;
                            currentLead.Lead_Owner_Role__c = '';
                        }    
                    }
                    getGroupMembers(currentLead.OwnerId); //fetches the groupmembers in queue.
                    
                    system.debug('Hi'+currentLead.OwnerId);
                 
                }
                
                system.debug('isUsrOrQueue value'+isUsrOrQueue);
               /* if(isSendEmail == true)
                {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    list<string> toAddresses = new list<string>();
                    mail.setSaveAsActivity(false);
                    if(isUsrOrQueue == true)
                        toAddresses.add(lstUser[0].email); 
                    
                    else
                    {
                        system.debug('@@@@@@@@@lstOfUsrId value'+lstOfUsrId);
                        List <user> lstEmailUser = [select email from
                                                    user where id IN :lstOfUsrId];
                
                        if(lstEmailUser.size()>0)
                        {
                            for(user emailId:lstEmailUser)
                            {
                                system.debug('@@@@@@@@@emailId'+emailId.email);
                                toAddresses.add(emailId.email);    
                            }
                        }
                    }
                    mail.setToAddresses(toAddresses);
                    
                        mail.setTargetObjectId(currentLead.id);
                    mail.setTemplateId(system.label.LeadTemplateId);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    system.debug('MAIL:'+mail);
                }*/
                /*SK if(isSendEmail == true)
                {

system.debug('Shruti:');
                    Database.DMLOptions dlo = new Database.DMLOptions();
                    dlo.EmailHeader.triggerOtherEmail = true;
                    currentLead.setOptions(dlo);

                }SK*/ 
            }
            system.debug('currentLead'+currentLead);
            update currentLead;
                
                
        } 
        catch(Exception e)
        {
            system.debug('Exception querying User for assigne user or queue ' + e);
        }
    } 
    
    /**
      *@Description:Recursive function to get users from a group
    **/
    public list<id> getGroupMembers(Id groupId)
    {
        system.debug('function is being called');
        List<GroupMember> lstGroupMembers = new List<GroupMember>();//List of group members
                
        //Queries group members
        lstGroupMembers = [select UserOrGroupId from GroupMember where GroupId = :groupId LIMIT 50000];
        system.debug('#####'+lstGroupMembers);
        for (GroupMember groupMember : lstGroupMembers){
            //If the queried members contain another group, calls the function again
            if (String.valueOf(groupMember.UserOrGroupId).startsWith('00G')){
                system.debug('in IF');
                getGroupMembers(groupMember.UserOrGroupId);}
            else
            {
                lstTempOfId.add(groupMember.UserOrGroupId);    
            }
        }
        system.debug('@@@@@@'+lstTempOfId);
        return lstTempOfId;

    }    

}