/* 
 Modified By    : Rittu Roy
 Modified Date  : 9/26/2015
 Objective      : Added validateOpptyItemEditability method to prevent Sales users from 
                  editing Opportunity line items if the related Opportunity is Closed
 
 Modified By    : Rittu Roy
 Modified Date  : 11/14/2015
 Objective      : Case #02133107 - To allow opportunity product edit if opportunity is closed within same context
                  Added condition in line 129 - '!OpportunityUtils.setClosedOppty.contains(opptyItem.OpportunityId)'
 */

public class OpportunityProductUtils{

	public static boolean validateOLIEditabilityRunOnce = false;//To prevent recursive run of method validateOpptyItemEditability
	
    //Called from OpportunityProductAll Trigger. 
    //This method updates the field Opportunity Owner with the related opportunities owner field
    //This field is used in expired opportunity line item fields.
    public static boolean updateForecastDatesRunOnce = false;//To prevent recursive run of method updateForecastDates
    public static void updateOpportunityOwner( List<OpportunityLineItem> lstOpportunityLineItem){
       Map<String,String> mapOppPdtParentOpp =  new Map<String,String>();
        
        List<String> lstParentOppId =  new List<String>();
        
        
        
        List<String> lstOppPdtLineItemId = new List<String>();
      
        
        for(OpportunityLineItem oppLineItem:lstOpportunityLineItem){
        
         if( oppLineItem.Opportunity_Owner__c == null)
         {
            lstParentOppId.add(oppLineItem.OpportunityId);
            lstOppPdtLineItemId.add(oppLineItem.id);
         }
        }
        
    
        if(!lstOpportunityLineItem.isEmpty()) {
            for(OpportunityLineItem oppLineItem:lstOpportunityLineItem){
                mapOppPdtParentOpp.put(oppLineItem.id,oppLineItem.OpportunityId);
            }
        }   
        Map<String,Opportunity> mapOpportunity =  new Map<String,Opportunity>([Select 
                                                                                   ownerId 
                                                                              from 
                                                                                 Opportunity 
                                                                              where 
                                                                                  id IN :lstParentOppId
                                                                              limit 50000]);
         
        
        if(!mapOppPdtParentOpp.isEmpty()){
            for(OpportunityLineItem oppLineItem:lstOpportunityLineItem){
                System.debug(LoggingLevel.FINE, '@@@@@@mapOppPdtParentOpp: ' + mapOppPdtParentOpp);
                if( oppLineItem.Opportunity_Owner__c == null)
                {
                    if(!mapOpportunity.isEmpty() && mapOpportunity.containsKey(mapOppPdtParentOpp.get(oppLineItem.id))){
                        oppLineItem.Opportunity_Owner__c = mapOpportunity.get(mapOppPdtParentOpp.get(oppLineItem.id)).OwnerId;
                    
                    }
                }
            }           
            
        }
    }

    public static void updateProductSubTypeField(List<OpportunityLineItem> triggerRecords)
    {
        //  we can't requery the records as this can get called on isInsert or isUpdate, so we'll query the product records that the oppt line items
        //  point to
        set<id> productIds = new Set<Id>();
        for (OpportunityLineItem oli : triggerRecords)
        {
            if (oli.Product2Id != null && !productIds.Contains(oli.product2Id))
            {
                productIds.add(oli.Product2Id);
            }
        }
        if (productIds != null && productIds.Size() > 0)
        {
            //  now we scroll thru the trigger records looking for the product, and then updating the field on the oli
            Product2[] productsOfOpptLineItems = [select id, Product_Sub_Type__c, Name from Product2 where id in: productIds];
            for (OpportunityLineItem oli : triggerRecords)
            {
                Product2 productOfOpptLineItem = findProduct(oli.Product2Id, productsOfOpptLineItems);
                if (productOfOpptLineItem != null)
                {
                    oli.Product_Sub_Type__c = productOfOpptLineItem.Product_Sub_Type__c;
                }
            }
        }
    }
    
    private static Product2 findProduct(Id productId, List<Product2> products)
    {
        for (product2 singleProduct : products)
        {
            if (singleProduct.id == productId)
            {
                return singleProduct;
            }
        }
        return null;
    }
 
    /*Prevents sales users  editing Opportunity line items if the related Opportunity is Closed*/
    public static void validateOpptyItemEditability(List<OpportunityLineItem> lstOppItems, Map<Id,OpportunityLineItem> oldMap){
        Set<String> setAllowedFields = new Set<String>();
        Set<String> setOpptyItemFields  = new Set<String>();
        Map<Id,String> mapOpptyItemToStage = new Map<Id,String>();
        
        validateOLIEditabilityRunOnce = true;
        
        //Creates a map of Opportunity LineItem Id to its Opportunity StageName
        for (OpportunityLineItem opptyItem : [select id,Opportunity.StageName FROM OpportunityLineItem WHERE Id IN :lstOppItems LIMIT 50000]){
            mapOpptyItemToStage.put(opptyItem.Id, opptyItem.Opportunity.StageName);     
        }
        
        //Gets list of fields that can be edited, from custom settings.
        if (Global_Variable__c.getInstance('OpptyLock_AllowedFieldsForLineItem') != null && String.isNotBlank(Global_Variable__c.getInstance('OpptyLock_AllowedFieldsForLineItem').value__c)){
            setAllowedFields.addAll(Global_Variable__c.getInstance('OpptyLock_AllowedFieldsForLineItem').value__c.split(',',0));
        }
        
        //Get list of fields on OpportunityLineItem from object schema
        Map<String, Schema.SObjectField> mapOpptyItemFields = Schema.SObjectType.OpportunityLineItem.fields.getMap();
        for (String strField : mapOpptyItemFields.keyset()){
            setOpptyItemFields.add(String.valueOf(mapOpptyItemFields.get(strField)));
        
        }
        system.debug('setAllowedFields: '+ setAllowedFields);
        
        if (ApexUserInfo.validateUserForOpptyLock(userInfo.getUserId(),UserInfo.getProfileId())){
            for (OpportunityLineItem opptyItem : lstOppItems){
                if (mapOpptyItemToStage.containsKey(opptyItem.Id) && (mapOpptyItemToStage.get(opptyItem.Id) == 'Closed Won' || mapOpptyItemToStage.get(opptyItem.Id) == 'Closed Lost') && !OpportunityUtils.setClosedOppty.contains(opptyItem.OpportunityId)){
                    for (String field : setOpptyItemFields){
                        system.debug('field: ' + field );
                        if(!setAllowedFields.contains(field) && opptyItem.get(field) != oldMap.get(opptyItem.id).get(field)){
                            if(EditShipmentScheduleExt.verifyShipmentEdit != true)// Edited only by Shipped Checkbox in Shipment Forecast Object..
                            {
                                opptyItem.AddError('Closed Opportunity cannot be edited');
                            }
                        }
                    
                    }
                }
            }
        }
    }
   
 }