public with sharing class SalesReversalController{
    
    public Opportunity opp {get; set;}
    public List<OpportunityLineItem> oli {get;set;}
	public List<OpportunityLineItem> oliToReverse = new List<OpportunityLineItem>();
	public PricebookEntry pbe {get; set;}
	
	public Id idStore {get; set;}
	
	public List<Asset__c> assetToDelete = new List<Asset__c>();
	
	
    public SalesReversalController(ApexPages.StandardController ctrl){
        this.opp = (Opportunity)ctrl.getRecord();
        this.oli = [select name, arr__c, unitprice, sales_reverse__c, cgm__c, net_new_annual_recurring_revenue__c, 
						annual_recurring_revenue__c, totalprice, total_amount__c, software_to_omni__c, non_recurring_revenue__c, unit_sales_price__c,
								pricebookentryid, pricebookentry.pricebook2id, pricebookentry.isActive, standard_cost__c, total_revenue__c, quantity, discount_amount__c, license_metric_quantity__c, 
										contract_term_months__c, Line_Type__c, Product_Sub_Type__c, Description, product_type__c, Business_Unit__c, License_Type__c from OpportunityLineItem
                            				where OpportunityId = :ApexPages.currentPage().getParameters().get('id')];

	}
    
	public PageReference save(){
		Opportunity currentOppToClone = [Select AccountId, Primary_Contact__c, CloseDate, Contact__c, IsClosed, Name, Role__c, StageName from Opportunity where id =: opp.Id];
		Opportunity currentOpp = currentOppToClone.clone(false, false, true, false);
		
		
		//pbe = [Select IsStandard, Id from Pricebook2 where Id =: oli.pricebookentry.pricebook2id];

		List<OpportunityLineItem> oliToAdd = new List<OpportunityLineItem>();
		
		for(OpportunityLineItem currentOli : oli){
			if(currentOli.sales_reverse__c == true){
				oliToReverse.add(currentOli);
			}
		}
		
		update oliToReverse;
		
		
		
		Opportunity salesReversedOpp = new Opportunity();
		salesReversedOpp.Name = 'Sales Reversal - ' + currentOpp.Name; 
		salesReversedOpp.AccountId = currentOpp.accountId;
		salesReversedOpp.CloseDate = currentOpp.closeDate;
		salesReversedOpp.Role__c = currentOpp.Role__c;
		salesReversedOpp.Primary_Contact__c = currentOpp.Primary_Contact__c;
		salesReversedOpp.StageName = currentOpp.StageName;
		salesReversedOpp.Type = 'Existing Customer';
		salesReversedOpp.Order_Type__c = 'Decommission';
		salesReversedOpp.Order_Sub_Type__c = 'Sales Reversal';
		salesReversedOpp.Contact__c = currentOpp.Contact__c;
		insert salesReversedOpp;
		
		for(OpportunityLineItem curOli : oliToReverse){
			OpportunityLineItem salesReversedItem = new OpportunityLineItem();

			salesReversedItem.Quantity = curOli.Quantity*-1;
			
			if(curOli.CGM__c != null){
				salesReversedItem.CGM__c = curOli.CGM__c*-1;
			}
				salesReversedItem.software_to_omni__c = curOli.Software_to_Omni__c;
			if(curOli.Total_Amount__c != null){
				salesReversedItem.total_amount__c = curOli.Total_Amount__c*-1;
			}
				//salesReversedItem.UnitPrice = curOli.UnitPrice*-1;
				salesReversedItem.Product_Type__c = curOli.Product_Type__c;
			
			if(curOli.non_recurring_revenue__c != null){
				salesReversedItem.non_recurring_revenue__c = curOli.non_recurring_revenue__c*-1;
			}
			
			if(curOli.annual_recurring_revenue__c != null){
				salesReversedItem.annual_recurring_revenue__c = curOli.annual_recurring_revenue__c*-1;
			}
			if(curOli.net_new_annual_recurring_revenue__c != null){
				salesReversedItem.net_new_annual_recurring_revenue__c = curOli.net_new_annual_recurring_revenue__c*-1;
			}
			if(curOli.Discount_Amount__c != null){
				salesReversedItem.Discount_Amount__c = curOli.Discount_Amount__c*-1;
			}
				salesReversedItem.OpportunityId = salesReversedOpp.Id;
			
				salesReversedItem.PricebookEntryId = curOli.PricebookEntryId;
		
			if(curOli.License_Metric_Quantity__c != null){
				salesReversedItem.License_Metric_Quantity__c = curOli.License_Metric_Quantity__c*-1;
			}
			
			if(curOli.Contract_term_months__c != null){
				salesReversedItem.Contract_term_months__c = curOli.Contract_Term_months__c*-1;
			}
				salesReversedItem.TotalPrice = curOli.TotalPrice*-1;
				salesReversedItem.License_Type__c = curOli.License_Type__c;
				salesReversedItem.Line_Type__c = curOli.Line_Type__c;
				salesReversedItem.Product_Sub_Type__c = curOli.Product_Sub_Type__c;
				salesReversedItem.Business_Unit__c = curOli.Business_Unit__c;
				salesReversedItem.Description = curOli.Description;
				
				oliToAdd.add(salesReversedItem);
		}
		
		
		insert oliToAdd;

		PageReference pg = new PageReference('/'+ salesReversedOpp.id); 
		return pg;
	}
	
	public PageReference cancel(){
		PageReference pg = new PageReference('/'+ this.opp.id); 
		return pg;
	}
	}