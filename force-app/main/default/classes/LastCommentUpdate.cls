/***********************************************************************************
Date: September 25, 2012
Author: Thileepa Asokan
        Tata Consultancy Services Limited
Used in: populateLastComment trigger
************************************************************************************/

public class LastCommentUpdate{

    /***********************************************************************************
    Purpose: To populate the Last Case Comment field with the last case comment that
            was created/edited on a case. It also includes the user who is updating the 
            comment/ creating a comment and the time it is being done.
    Highlight: This functionality is restricted to only shared cases         
    ************************************************************************************/
    public static void updateLastCommentAndCommenter(Map<Id,CaseComment> newCaseCommentsMap, boolean isDelete){
        
        System.debug('*** Commenting out as this class is not being used ***');
    
       /* List<Case> toBeUpdatedCases = new List<Case>();

        // Populate the set of case Ids                
        Set<Id> caseIds = new Set<Id>();        
        for(Id caseCommentId:newCaseCommentsMap.keySet()){
            caseIds.add(newCaseCommentsMap.get(caseCommentId).parentId);            
        }                        

        // Use the set of case Ids to query the connection records( if any)       
        // Add the shared case Ids to a new set
        Set<Id> sharedRecordIds = new Set<Id>();
        List<PartnerNetworkRecordConnection> sharedRecords = new List<PartnerNetworkRecordConnection>([select localRecordId from PartnerNetworkRecordConnection where localRecordId in :caseIds limit 50000]);                                                            
        for(PartnerNetworkRecordConnection sharedRecord:sharedRecords){
            sharedRecordIds.add(sharedRecord.localRecordId);
        }
         
        if(sharedRecordIds.size() > 0){        
            // Query the shared cases along with the comments
            Set<Id> commenterIds = new Set<Id>();
            List<Case> lstSharedCases = new List<Case>();
            if(isDelete){
                lstSharedCases = [select Id, Last_Case_Comment__c, (select commentBody, LastModifiedDate, LastModifiedBy.Name from CaseComments where parentId in :sharedRecordIds and Id not in : newCaseCommentsMap.keySet() order by LastModifiedDate desc limit 1) from Case where Id in :sharedRecordIds limit 50000];                                    
            }else{
                lstSharedCases = [select Id, Last_Case_Comment__c, (select commentBody, LastModifiedDate, LastModifiedBy.Name from CaseComments where parentId in :sharedRecordIds and Id in : newCaseCommentsMap.keySet() order by LastModifiedDate desc limit 1) from Case where Id in :sharedRecordIds limit 50000];                                   
            }
            
            // Use BusinessHours object to convert the GMT DateTime to local DateTime
            BusinessHours corpBH = [select Id, TimeZoneSidKey from BusinessHours where isDefault = true limit 1];                                        
            
            // Populate the last case comment on the shared cases
            if(corpBH != null){
                for(Case theCase:lstSharedCases){
                    if(theCase.caseComments.size() > 0){
                        theCase.Last_Case_Comment__c = 'Created/Updated By: '+theCase.caseComments[0].LastModifiedBy.Name+' ('+theCase.caseComments[0].LastModifiedDate.format('MM/dd/yyyy HH:mm a', corpBH.TimeZoneSidKey)+')'+'\n'+theCase.caseComments[0].commentBody;
                        toBeUpdatedCases.add(theCase);
                    }else{
                        theCase.Last_Case_Comment__c = '';
                        toBeUpdatedCases.add(theCase);
                    }
                }
           }
                                                       
            // Update the shared cases with the last case comment
            if(toBeUpdatedCases != null && toBeUpdatedCases.size() > 0){
                try{
                    update toBeUpdatedCases;
                }catch(Exception e){
                    System.debug(e);
                }        
            }        
        }*/
    }
}