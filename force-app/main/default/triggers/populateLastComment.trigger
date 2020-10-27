/***********************************************************************************
Date: September 25, 2012
Author: Thileepa Asokan
        Tata Consultancy Services Limited
Done for:   QForce Case #00060665 which is a CR for ITES Unified Console implementation
Purpose:    To populate the Last Case Comment field with the last case comment that
            was created/edited on a case. It also includes the user who is updating the 
            comment/ creating a comment and the time it is being done.
************************************************************************************/
trigger populateLastComment on CaseComment (after insert,after update,before delete) { 

     BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }
        
    System.debug('*** Commenting out as this class is not being used ***');  
    LastCommentUpdate.updateLastCommentAndCommenter(Trigger.newMap, false);
    /*if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
        LastCommentUpdate.updateLastCommentAndCommenter(Trigger.newMap, false);
    }
    if(Trigger.isBefore && Trigger.isDelete){
        LastCommentUpdate.updateLastCommentAndCommenter(Trigger.oldMap, Trigger.isDelete);         
    }*/
}