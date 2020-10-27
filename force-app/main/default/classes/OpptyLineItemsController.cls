public with sharing class OpptyLineItemsController {
    public List<OpportunityLineItem> opptyLineItems{get;set;}
    
    public Integer selectedRowNumber{get;set;}
    
    public Integer topIndexValue {get;set;}
    
   public Overlay_Oppty_Extension pageController{get;set;}
     
    private String opptyId;
    
    private String opptyName;
    
    private Integer rowNumber;
    
    private boolean hideOverlay;
    
    
    public boolean getHideOverlay(){
        return hideOverlay;
    }
 
    public void setHideOverlay(Boolean overlayFlag){
        hideOverlay=overlayFlag;
    }
    
    Double quantitySum;
    
    public  Integer getRowNumber(){
        return rowNumber;
    }
    
    public void setRowNumber(Integer rowNumValue){
        if(rowNumValue!=null){
           rowNumber=rowNumValue;
        }
    }
    
    public String getOpptyId(){
        return opptyId;
    }
    
    public void setOpptyId(String opptyIdValue){
        if(opptyIdValue!=null){
            opptyId=opptyIdValue;
            System.debug('====pageController====' + pageController);
            if(pageController!=null){
              opptyLineItems=pageController.opptyLineItemMap.get(opptyId);
            }
        }
         
    }
    
    public String getOpptyName(){
        return opptyName;
    }
    
    public void setOpptyName(String opptyNameValue){
        if(opptyNameValue!=null){
            opptyName=opptyNameValue;
        }
         
    }
    
    public OpptyLineItemsController(){
         //initialize overlay flag
       hideOverlay=false;
    }
    
    public PageReference saveOpptyLineItems(){
        try{
        quantitySum=0;
        System.debug('=====opptyLineItems====' + opptyLineItems);
        update opptyLineItems;
        
        for(OpportunityLineItem opptyLineItemInstance:opptyLineItems){
            quantitySum+=opptyLineItemInstance.Quantity;
        }
        
        pageController.selectedOpportunity.get(selectedRowNumber).opportunityInstance.TotalOpportunityQuantity=quantitySum;
        hideOverlay=true;
        opptyLineItems=null;
        return null;
        }
        catch(Exception e){
            hideOverlay=false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error occurred when creating a task. Please contact System administrator');
             ApexPages.addMessage(myMsg);
            return null;
        }
    }
    
    public PageReference cancelRecord(){
        return null;
    }

}