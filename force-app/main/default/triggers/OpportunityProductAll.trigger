/*@Description: Populate the opportunity owner field on opportunity product (CR 89473)
 *@Author:Amrita
 
 Modified By    : Rittu Roy
 Modified Date  : 9/26/2015
 Objective      : Added validateOpptyItemEditability method call to prevent Sales users from 
                  editing Opportunity line items if the related Opportunity is Closed
*/

trigger OpportunityProductAll on OpportunityLineItem (before Insert, before update)
{
    if (TriggerExecutionUtil.isFirstTimeOptyLineItem) {
        TriggerExecutionUtil.isFirstTimeOptyLineItem = false;
        OpportunityProductUtils.updateOpportunityOwner(trigger.new);
        OpportunityProductUtils.updateProductSubTypeField(Trigger.new);
        
        if (trigger.isBefore){
            if (trigger.isUpdate){
                OpportunityProductUtils.validateOpptyItemEditability(Trigger.new,Trigger.oldMap);
            }
        }
    }
}