Public Class CallReportController{
	Public CallReportController(ApexPages.StandardController controller)
    {
    }
/*******************************************************************************************************
Date: 29 June 2010
Author: Shruti Karn, Salesforce.com Developer
Tata Consultancy Services Limited

Overview: This class is used as a controller for visualforce page "Call Report" whcih shows all the information related to Call report.
QForce Case# 22189
*******************************************************************************************************/

    /*Public Call_Report__c callReportObj {get; set;}
    Public Account Acct {get; set;}
    
    Public list<Call_Report_Product__c> callReportProd {get;set;}
    //10May2011 - DAR - Competitive Threats no longer used
    //Public list<Competitive_Threat__c> compThreats {get; set;}
    Public list<Contract_Product_Services__c> contProdServ {get; set;}
    Public list<Contract_Product_Services__c> evalProdServ {get; set;}
    Public list<Opportunity> OppList {get;set;}
    Public list<X3rd_Party_Contract_Service__c> partyList {get;set;}
    Public list< Task> taskList {get;set;}
    Public list<Event> eventList {get; set;}
    Public list<OpportunityLineItem> OppLineList{get;set;}
    Public list<OpportunityTable> OppTable {get;set;}

    Private String callReportId {get; set;}
    String oppProduct {get; set;}
    
    Public Map<Id, String> prodMap {get; set;}
    
    Public Date currDate {get;set;}
    
    Public CallReportController(ApexPages.StandardController controller)
    {
        
        callReportId = Apexpages.currentPage().getParameters().get('Id');
        callReportObj = new Call_Report__c();
        try
        {
            callReportObj = [Select c.SystemModstamp, c.Status__c, c.Siebel_ID__c, c.Requires_Prewire_Products__c, 
                                    c.Quantity_Of_Trucks__c, c.QWBS_Attendees__c, c.Purpose__c, c.Operations_IT_Maintenance__c, 
                                    c.OEM_Used__c,c.Next_Objective_Strategy__c, c.Name, c.Method__c, c.Meeting_Summary__c, 
                                    c.Meeting_Objective_Agenda__c, c.LastActivityDate, c.Id, c.Date__c, c.Customer_Attendees__c, 
                                    c.CreatedDate , c.Account__c From Call_Report__c c where c.Id =: callReportId limit 1];
        
            Acct = [Select  Trailers__c, Equiped__c, Total_Vehicles__c,Tankers__c, Regional_Vehicles__c, 
                            Reefers__c, QWBS_Annual_Revenues__c, Owner_Operators__c, OTR_Vehicles__c, OEM_Tractor__c, OEM_Tanker_Trailer__c, 
                            OEM_Reefer_Trailer__c, OEM_Flatbed_Trailer__c, OEM_Dry_Van_Trailer__c, Flatbeds__c, Dry_Vans__c, Dollies__c, Contract_Expiration__c, 
                            CSR__c, CSR__r.Name , QWBS_Cust_ID__c, Name, Contract_Type__c, Total_Vehicles_Equipped__c , Account_Manager__c, Account_Manager__r.Name From Account where id = :callReportObj.Account__c limit 1];
            
            callReportProd = new list<Call_Report_Product__c>();
            callReportProd = [Select c.Product__c, c.Comments__c, c.Call_Report__c, c.Application__c From Call_Report_Product__c c where c.Call_Report__c = : callReportId limit 1000];
            
            //10May2011 - DAR - Competitive Threats no longer used
            //compThreats = new list<Competitive_Threat__c>();
            //compThreats = [Select c.Status__c, c.Quantity__c, c.Product__c, c.Competitor__c, c.Competitive_Contract_Expiration_Date__c, c.Comments__c From Competitive_Threat__c c where  c.Account__c =:callReportObj.Account__c  limit 1000];
            
            evalProdServ = new list<Contract_Product_Services__c>();
            contProdServ = new list<Contract_Product_Services__c>();
            contProdServ =[Select c.Services__c, c.Platform_Type__c, Type__c , c.Mobile_Platform__c, c.Host_Platform__c, c.Contracted_Price__c, c.Comments__c , c.Account__c From Contract_Product_Services__c c where c.Account__c =:callReportObj.Account__c and Type__c!='Eval' limit 1000];
            evalProdServ =[Select c.Services__c, c.Platform_Type__c, Type__c , c.Mobile_Platform__c, c.Host_Platform__c, c.Contracted_Price__c, c.Comments__c , c.Account__c From Contract_Product_Services__c c where c.Account__c =:callReportObj.Account__c and Type__c='Eval' limit 1000];
                  
            DateTime currDateTime = system.now();
            currDate = Date.newInstance(currDateTime.year(),currDateTime.month(),currDateTime.day());
            DateTime newDateTime = system.now()+90;
            Date newDate = Date.newInstance(newDateTime.year(),newDateTime.month(),newDateTime.day());
            
            OppList = new list<Opportunity>();
            OppList = [Select o.Start_Date__c, CloseDate , o.StageName, o.Probability, o.Oppty_Quantity__c, o.Name, o.Id, o.Expected_Revenue__c, o.Contract_Type__c From Opportunity o where o.AccountId =:callReportObj.Account__c  and (o.CloseDate>=:currDate and o.CloseDate <=:newDate) and stageName!='Closed Lost' order by CloseDate asc limit 1000];
            
            OppLineList = new list<OpportunityLineItem>();
            list<Id> idList = new list<Id>();
            // To mergge all the products related to one Opportunity in commas separated string
            if(!(OppList.isEmpty()))
                for(integer i=0;i<OppList.size();i++)
                {
                    idList.add(OppList[i].id);
                }
            if(!(idList.isEmpty()))
                OppLineList = [Select PricebookEntry.Name,OpportunityId from OpportunityLineItem where OpportunityId IN: idList limit 1000];
            
            prodMap = new Map<Id, String>();
            if((!OppLineList.isEmpty()))
                for(integer i=0;i<OppLineList.size();i++)       
                {
                    
                    if(i==0)
                        oppProduct = OppLineList[i].PricebookEntry.Name;
                    else
                        if(!(oppProduct.contains(OppLineList[i].PricebookEntry.Name)))
                            oppProduct = oppProduct +','+OppLineList[i].PricebookEntry.Name;
                prodMap.put(OppLineList[i].OpportunityId,oppProduct);
                }
            //Creates list of OpportunityTable which is used to display Opportunity and its related Product string    
            OppTable = new list<OpportunityTable>();
            for(integer i=0;i<OppList.size();i++)
            {
                OpportunityTable newObj = new OpportunityTable();
                newObj = newObj.createTable(OppList[i],prodMap);
                OppTable.add(newObj);
            }
                    
            partyList = new list<X3rd_Party_Contract_Service__c>();
            partyList = [Select x.X3rd_Party__c, x.Partner_Type__c, x.Comments__c From X3rd_Party_Contract_Service__c x where  x.Account__c =:callReportObj.Account__c limit 1000];
            
            taskList = new list< Task>();
            taskList = [Select t.Subject, Owner.Name , t.WhoId , t.Who.Name , t.Status, t.OwnerId, t.Description, t.ActivityDate From Task t where  t.WhatId = :callReportId limit 1000];
        
            eventList = new list<Event>();
            eventList = [Select e.Subject,Owner.Name , e.OwnerId, e.Who.Name , e.Description, e.ActivityDate , e.WhoId From Event e where  e.WhatId = :callReportId limit 1000];
        }
        catch(exception e)
        {
            system.debug('Error in Call Report');
        }
  }

//Inner class used to display all the Opportunity and its corresponding Product string    
public class OpportunityTable{
    public Opportunity Opp {get; set;}
    public String Prod {get; set;}
    
    public OpportunityTable()
    {
    }
    
    public OpportunityTable(Opportunity Opp, String prod)
    {
        this.Opp = Opp;
        this.prod = prod;
    }
    
    public OpportunityTable createTable(Opportunity tempOpp , Map<id,String> prodMap)
    {
        if(!(prodMap.isEmpty()))      
            if(prodMap.containsKey(tempOpp.Id))
                {
                    this.prod = prodMap.get(tempOpp.Id);
                    this.Opp = tempOpp;
                 }
        OpportunityTable newObj = new OpportunityTable(Opp,prod);
        return newObj;
    }
}*/
}