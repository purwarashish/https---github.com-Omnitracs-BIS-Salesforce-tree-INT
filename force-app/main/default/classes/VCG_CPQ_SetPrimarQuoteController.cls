/*****************************************************************************************
Modified By   : Rittu Roy
Modified Date : 9/26/2015
Objective     : Case# 01923267 - Prevent Sales users from editing closed opportunities. As part
                of this, locked changing primary quote for closed opportunities. Modified 'Set Primary Quote'
                button and constructor in this class
******************************************************************************************/

public without sharing class VCG_CPQ_SetPrimarQuoteController {
    
    private ApexPages.StandardSetController setCon;
    
    public VCG_CPQ_SetPrimarQuoteController(ApexPages.StandardSetController ctlr)
    {
        List<VCG_CPQ_Quote__c> lstQuotes = new List<VCG_CPQ_Quote__c>();
        String strIds = ApexPages.currentPage().getParameters().get('ids');
                 
        //Create a list of quotes based on ids passed in URL parameter
        if (String.isNotBlank(strIds)){
            for (String strId : strIds.split(',',0)){
                lstQuotes.add(new VCG_CPQ_Quote__c(id=Id.valueof(strId)));        
            }
        }
        
        //Sets the list of quotes as standsetcontroller
        this.setCon = new ApexPages.StandardSetController(lstQuotes); 
    }
    
    public PageReference applyPrimaryQuote()
    {
        //
        //Check for errors
        //
        if(setCon.getRecords().size() > 1)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select a single Quote to set as Primary'));
            return null;
        }
        if(setCon.getRecords().size() < 1)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select a Quote to set as Primary'));
            return null;
        }
        
        //
        // Run the process
        //
        list<VCG_CPQ_Quote__c> quotes = (list<VCG_CPQ_Quote__c>)setCon.getRecords();
        
        //
        // Query Quote Record to grab all of the quote fields
        //
        set<string> quoteFieldSet = new set<string>();
        string quoteQuery = 'Select Id, Name, OwnerId ';
        for(String q : VCG_CPQ_PricingUtility.describeObjectFields('VCG_CPQ_Quote__c').keySet())
        {
            if(q.endsWith('__c')) quoteQuery += ','+q;
        }
        quoteQuery += ' From VCG_CPQ_Quote__c where Id = \''+quotes[0].Id+'\'';
        
        VCG_CPQ_Quote__c quote = Database.query(quoteQuery);
        
        //
        // Set this quote to primary
        //
        quote.Is_Primary__c = true;
        update quote;
        
        //
        // Call the utility to sync the quote
        //
        try{
            VCG_CPQ_PricingUtility.syncPrimaryQuote( quote);
            return new PageReference(ApexPages.currentPage().getParameters().get('retUrl'));
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Errors in configuration are preventing this action: ['+e.getMessage()+']'));
            return null;
        }
       
    }

}