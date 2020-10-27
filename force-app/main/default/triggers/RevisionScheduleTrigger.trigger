/**
    * RevisionScheduleTrigger - <Manages approval process for Activation Schedules Revision>
    * Created by Yasir Arafat
    * @author: Yasir Arafat
    * @version: 1.0
*/

trigger RevisionScheduleTrigger on Revision_Schedule__c (after insert, after update) {
    if(Trigger.isAfter){
        List<Revision_Schedule__c> newRecords = Trigger.new;
        Set<ID> quoteIds = new Set<ID>();
        Map<ID, String> quoteStatusMap = new Map<ID, String>();
        List<String> statusToUpdate = new list<String> { 'Draft', 'Pending Finance Approval', 'Pending Legal Approval', 'Approved', 'Rejected' };
        if(Trigger.isUpdate){
            List<Revision_Schedule__c> revShedToUpdate = new List<Revision_Schedule__c>();
            Map<ID, Revision_Schedule__c> oldRecsMap = Trigger.oldMap;
            Set<ID> approvedIdsToUnlock = new Set<ID>();
            for(Revision_Schedule__c newRec : newRecords){
                Revision_Schedule__c oldRec = oldRecsMap.get(newRec.Id);
                ID quoteId = newRec.Quote__c;
                if(newRec.Status__c != oldRec.Status__c && statusToUpdate.contains(newRec.Status__c)){
                    quoteIds.add(quoteId);
                    quoteStatusMap.put(quoteId, newRec.Status__c);
                }
                if(newRec.Status__c != oldRec.Status__c && newRec.Status__c == 'Approved'){
                    approvedIdsToUnlock.add(newRec.Id);
                    List<Revision_Schedule__c> revisionSchedules = [Select Id, Revision__c, Status__c from Revision_Schedule__c where Quote__c = :quoteId AND Status__c = 'Active'];
                    if(revisionSchedules.size() > 0){
                        revisionSchedules[0].Status__c = 'Frozen';
                        revShedToUpdate.add(revisionSchedules[0]);
                    }
                }
            }
            List<Revision_Schedule__c> approvedRevisions = [Select Id, Status__c from Revision_Schedule__c where Id IN :approvedIdsToUnlock];
            for(Revision_Schedule__c revision : approvedRevisions){
                Approval.unlock(revision.Id);
                revision.Status__c = 'Active';
                revShedToUpdate.add(revision);
            }
            if(revShedToUpdate.size() > 0)
                update revShedToUpdate;
            for(Revision_Schedule__c revision : approvedRevisions){
                Approval.lock(revision.Id);
            }
        }else if(Trigger.isInsert){
            for(Revision_Schedule__c newRec : newRecords){
                if(statusToUpdate.contains(newRec.Status__c)){
                    quoteIds.add(newRec.Quote__c);
                    quoteStatusMap.put(newRec.Quote__c, newRec.Status__c);
                }
            }
        }
        if(quoteIds.size() > 0){
            List<SBQQ__Quote__c> quotesToUpdate = [Select Id, Revision_Approval_Status__c from SBQQ__Quote__c where Id IN :quoteIds];
            for(SBQQ__Quote__c quote : quotesToUpdate){
                quote.Revision_Approval_Status__c = quoteStatusMap.get(quote.Id);
            }
            update quotesToUpdate;
        }
    }
}