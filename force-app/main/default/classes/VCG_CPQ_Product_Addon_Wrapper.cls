public without sharing class VCG_CPQ_Product_Addon_Wrapper {
    public VCG_CPQ_Quote_Product__c addOnTo;
    public Product2 addonProduct;
    
    /* Do not use these fields */
    public Double min {get;set;}
    public Double max {get;set;}
    public Decimal recQty;
    /* ------ */
    
    /* Use these fields going forward. */ 
    public Boolean required {get;set;}
    public Boolean compatible {get;set;}
    /* ------ */
    
    public VCG_CPQ_Product_Addon_Wrapper(VCG_CPQ_Quote_Product__c addOnTo, Product2 addonProduct, Double min, Double max){
        this.addOnTo = addOnTo;
        this.addonProduct = addonProduct;
        this.min = min;
        this.max = max;
    } 
    
    public VCG_CPQ_Product_Addon_Wrapper(VCG_CPQ_Quote_Product__c addOnTo, Product2 addonProduct){
        this.addOnTo = addOnTo;
        this.addonProduct = addonProduct;
        this.min = 0;
        this.max = 9999999;
        
        this.required = false;
        this.compatible = false;
    }
    
    public VCG_CPQ_Product_Addon_Wrapper(VCG_CPQ_Quote_Product__c addOnTo, Product2 addonProduct, Boolean req, Boolean incompat){
        this.addOnTo = addOnTo;
        this.addonProduct = addonProduct;
        this.required = req;
        this.compatible = incompat;
    }   
    
}