trigger AssetTrigger on Asset__c (after insert, after update, after delete, after undelete) {

     BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }
     
     /*if (Trigger.isAfter && Trigger.isInsert) {
        AssetUtility.bundlePostProcessing(Trigger.newMap);
     }*/
	 
	 if(trigger.isInsert || trigger.isUpdate||trigger.isUndelete||trigger.isDelete){
	 	if(!trigger.isDelete){
 			calculateRevenueSum.trigNew(Trigger.New); //Case #02275674, Sripathi Gullapalli, Method to update Total ARR field on Contract
	 	}
	 	//calculateRevenueSum.updateContract(Trigger.New,Trigger.Old, trigger.isDelete);
 	 }
 
	if(trigger.isDelete){
  		calculateRevenueSum.trigOld(Trigger.Old); 
	}
}