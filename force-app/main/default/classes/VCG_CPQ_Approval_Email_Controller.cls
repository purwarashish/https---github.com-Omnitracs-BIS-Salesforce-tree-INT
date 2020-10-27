public without sharing class VCG_CPQ_Approval_Email_Controller {
    
    public String quoteId {get;set;}
    public String recipientId {get;set;}
    public boolean showEmailMessage{get;set;}

    public List<VCG_CPQ_Quote_Approval__c> quoteApprovalList {get;set;}
    
    public VCG_CPQ_Approval_Email_Controller(){
        showEmailMessage = true;
    
    }
    
    public List<VCG_CPQ_Quote_Approval__c> getQuoteApprovals(){
        System.debug('Called getQuoteApprovals');
        System.debug('Quote Id : ' + quoteId);
        System.debug('recipientId : ' + recipientId);       


        Map<Id, ProcessInstance> instanceMap = new Map<Id, ProcessInstance>([SELECT Id, TargetObject.Name, TargetObjectID, TargetObject.Type 
                                                                            FROM ProcessInstance 
                                                                            WHERE TargetObjectId= :quoteId]);
        
        //Process Instance Step  -> Queue ID
        Map<Id, ProcessInstanceWorkItem> workItemMap = new Map<Id, ProcessInstanceWorkItem>([SELECT Id, ActorId 
                                                                                        FROM ProcessInstanceWorkItem 
                                                                                        WHERE ProcessInstanceId in :instanceMap.keySet()]);

        Set<Id> groupIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for(ProcessInstanceWorkItem workItem : workItemMap.values()){
            if(workItem.ActorId.getSObjectType().getDescribe().getName() == 'User'){
                userIds.add(workItem.ActorId);
            }
            else if(workItem.ActorId.getSObjectType().getDescribe().getName() == 'Group'){
                groupIds.add(workItem.ActorId); 
            }
System.debug('workItem : ' + workItem.ActorId.getSObjectType().getDescribe().getName());                        
        }

        if(groupIds != null && groupIds.size() > 0){
            showEmailMessage = false;
        }
        
        Map<Id, Group> groups = new Map<Id, Group>([SELECT Id, Name, DeveloperName, Type 
                                                    FROM Group 
                                                    WHERE Type='Queue' AND Id in :groupIds]);
                                                    
System.debug('groups : ' + groups);
        
        Map<Id, User> users = new Map<Id, User>([SELECT Id, Name 
                                                FROM User
                                                Where Id in :userIds]);
               
        
        List<String> groupNames = new List<String>();
        for(Group zgroup : groups.values()){
            groupNames.add(zgroup.DeveloperName);
        }              
        
        Map<Id, VCG_CPQ_Approval_Group__c> approvalGroups = new Map<Id, VCG_CPQ_Approval_Group__c>([SELECT Id, Queue_Name__c 
                                                                                                    FROM VCG_CPQ_Approval_Group__c 
                                                                                                    WHERE Queue_Name__c in :groupNames]);

System.debug('approvalGroups : ' + approvalGroups); 
    
        quoteApprovalList = [SELECT Id, Name, Quote__c, Approval_Reason__c, Approval_Condition__r.Name, Approval_Group__r.Id, Approval_Group__r.Name, Approver__c 
                                FROM VCG_CPQ_Quote_Approval__c 
                                WHERE Quote__c = :quoteId
                                AND (Approval_Group__c in :approvalGroups.keySet() OR Approver__c in :users.keySet())];
        
System.debug('quoteApprovalList : ' + quoteApprovalList);       
        return quoteApprovalList;
        
        
        
    }
}