/**
 * @description : Trigger to handle after insert, before delete and after updation of Needs field on VCG_CPQ_Pricing_Sequence_Condition__c object.
 *
 * @author : Ataullah Khan
 * @since : 15-Apr-2014
 */
trigger VCG_CPQ_NeedsFields_On_Pricing_Seq_Cond on VCG_CPQ_Pricing_Sequence_Condition__c (after update, after insert,before delete) {
    // Instantiating the trigger handler class
    VCG_CPQ_NeedsFieldsTrigHandler handler = new VCG_CPQ_NeedsFieldsTrigHandler();
    
    if (trigger.isInsert)
        handler.afterinsert(trigger.new); // calling the concerned handler to handle Insertion.
    else if (trigger.isdelete)
        handler.beforeDeleteMiddleObject(Trigger.oldMap); // calling the concerned handler to handle deletion.
    else
        handler.reparenting(Trigger.OldMap,Trigger.NewMap); // calling the concerned handler to handle updation.
}