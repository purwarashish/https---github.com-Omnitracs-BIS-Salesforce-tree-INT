/**
 * @description : Trigger to handle after insert, before delete and after updation of Needs field on VCG_CPQ_Pricing_Procedure_Sequence__c object.
 *
 * @author : Ataullah Khan
 * @since : 15-Apr-2014
 */
trigger VCG_CPQ_NeedsFields_On_Pricing_Proc_Seq on VCG_CPQ_Pricing_Procedure_Sequence__c (after insert, after update,before Delete) {
    // Instantiating the trigger handler class
    VCG_CPQ_NeedsFieldsTrigHandler handler = new VCG_CPQ_NeedsFieldsTrigHandler();
    
    if (trigger.isInsert)
        handler.afterinsert(trigger.new);  // calling the concerned handler to handle Insertion.
    else if (trigger.isDelete) 
        handler.beforeDeleteMiddleObject(trigger.oldMap); // calling the concerned handler to handle deletion.
    else if(trigger.isupdate)
        handler.reparenting(Trigger.OldMap,Trigger.NewMap); // calling the concerned handler to handle updation.
}