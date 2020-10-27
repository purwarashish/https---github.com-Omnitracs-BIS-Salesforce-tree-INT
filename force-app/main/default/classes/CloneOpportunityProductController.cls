/*********************************************************************
Name    : CloneOpportunityProductController
Author  : Shruti Karn
Date    : 29 July 2011

Usage   : This controller is used for Cloning Products related to a Opportunity.
          It is used in 'CloneOpportunityProduct' Visualforce page.

Dependencies : No

QForce Case # 35396

Modified By : Shruti Karn for Qforce Case# 42607
*********************************************************************/

public class CloneOpportunityProductController{
    
public String strSelProdIDs {get;set;}
public String OppName {get;set;}
public String oppId {get;set;}

public map<Id,OpportunityLineItem> mapOppLineItem {get;set;}
public list<OpportunityLineItem> newLstoppLineItem {get;set;}


    public CloneOpportunityProductController()
    {
        oppId = Apexpages.currentPage().getParameters().get('Id');
        if(oppId != null && oppID.trim() != '')
        {
            list<Opportunity> lstOpp = [Select name from Opportunity where id = : oppId limit 1];
            OppName = lstOpp [0].Name;
        } 
        mapOppLineItem = new map<Id,OpportunityLineItem>([Select o.UnitPrice,  o.SortOrder, o.Shipped__c,
                          o.Quantity, o.Product_Description__c, o.PricebookEntryId,o.PricebookEntry.Name,
                           o.Oppty_Quantity__c, o.OpportunityId, o.Id, o.Description,o.ServiceDate, o.ListPrice 
                           From OpportunityLineItem o where OpportunityId =: OppId order by o.PricebookEntry.Name limit 10000 ]);       
    }
    
    public PageReference cloneObj()
    {
        if(strSelProdIDs != null && strSelProdIDs != '')
            strSelProdIDs = strSelProdIDs.trim();
        list<OpportunityLineItem> lstoppLineItem = new list<OpportunityLineItem>();
        newLstoppLineItem = new list<OpportunityLineItem>();
        if(mapOppLineItem.containsKey(strSelProdIDs))
             lstoppLineItem.add(mapOppLineItem.get(strSelProdIDs));
        newLstoppLineItem = lstoppLineItem.deepClone(false);
/**********************************Changes for Qforce Case 42607********************************/
        if(newLstoppLineItem.size()!=0)
        {
            for(integer i=0;i<newLstoppLineItem.size();i++)
                newLstoppLineItem[i].Shipped__c=false;
        }
/**********************************End of changes for Qforce Case 42607********************************/
        try
        {
            
            insert newLstoppLineItem;
        }
        catch(Exception e)
        {
            system.debug('Error in inserting Opportunity Line Item:'+e);
        }
        
        String URL = '/apex/EditClonedProducts';
        return Page.EditClonedProducts;
    }
    
    public PageReference save()
    {
        update newLstoppLineItem;
        String URL = '/'+OppId;
        PageReference PageRef = new PageReference(URL);
        PageRef.setRedirect(true);
        return PageRef;
        
    }
   
   
}