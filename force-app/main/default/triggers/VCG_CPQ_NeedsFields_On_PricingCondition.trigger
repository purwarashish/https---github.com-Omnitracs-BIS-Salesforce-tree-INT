/**
 * @description : Trigger to handle before delete and after updation of Needs field on VCG_CPQ_Pricing_Condition__c object.
 *
 * @author : Ataullah Khan
 * @since : 15-Apr-2014
 */
trigger VCG_CPQ_NeedsFields_On_PricingCondition on VCG_CPQ_Pricing_Condition__c (before delete, after update) {
    // Instantiating the trigger handler class
    VCG_CPQ_NeedsFieldsTrigHandler handler = new VCG_CPQ_NeedsFieldsTrigHandler();
    
    if(Trigger.isUpdate){
        handler.afterupdate(Trigger.oldMap, Trigger.newMap);// calling the concerned handler to handle updation.
    }
    else
        handler.beforedelete(Trigger.OldMap);// calling the concerned handler to handle deletion.
}