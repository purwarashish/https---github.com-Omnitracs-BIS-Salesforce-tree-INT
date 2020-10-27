trigger QuoteProductTrigger on VCG_CPQ_Quote_Product__c (after insert) {

   if(Trigger.isInsert)
     {
         QuoteProductUtil dataUtil = new QuoteProductUtil();
         dataUtil.UpdateSourceAddOn(Trigger.new);
     }    

}