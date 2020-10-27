/*********************************************************************
Name    : IdeaReportController
Author  : Shruti Karn
Date    : 8 August 2011

Usage   : This controller is used to display reports on Customer Idea.

Qforce Case # 39183
*********************************************************************/
Public Class IdeaReportController{
    
    list<Idea> lstIdea;
    list<Customer_Idea__c> lstCustIdea;
    public map<Id,list<Customer_Idea__c>> mapIdeaCustomerIdea{get;set;}
    public map<Id,Decimal> mapIdeaTotalNumofTrucks {get;set;}
    public map<Id,Idea> mapIdeaIdName {get;set;}
    
    public list<IdeaTotalNumberofTrucks> lstIdeaTotNumofTrucks {get;set;}
    list<Id> lstAcctId = new list<Id>();
    list<Id> lstIdeaId = new list<Id>();
    public IdeaReportController()
    {
        lstCustIdea = new list<Customer_Idea__c>();
        lstCustIdea = [Select id,Account__c,Account__r.Name,Account__r.QWBS_Status__c,Idea__r.Title,Number_of_Trucks__c,Idea__c from Customer_Idea__c limit 10000 ];
        for(integer i=0;i<lstCustIdea.size();i++)
        {
            lstAcctId.add(lstCustIdea[i].Account__c);
            lstIdeaId.add(lstCustIdea[i].Idea__c);
        }    
    }
    
    public void showIdeasByNumofTrucks()
    { 
        lstIdeaTotNumofTrucks = new list<IdeaTotalNumberofTrucks>();
        mapIdeaCustomerIdea = new map<Id,list<Customer_Idea__c>>();
        map<Id,Decimal> mapIdeaTotalNumofTrucks = new map<Id,Decimal>();
        
        lstIdea = new list<Idea>();
                 
        lstIdea = [Select id,Title from Idea where id in : lstIdeaId limit 50000];
        for(integer i=0;i<lstCustIdea.size();i++)
        {
            if(mapIdeaCustomerIdea.containsKey(lstCustIdea[i].Idea__c))
            {
                mapIdeaCustomerIdea.get(lstCustIdea[i].Idea__c).add(lstCustIdea[i]);
                mapIdeaTotalNumofTrucks.put(lstCustIdea[i].Idea__c,(mapIdeaTotalNumofTrucks.get(lstCustIdea[i].Idea__c)+ lstCustIdea[i].Number_of_Trucks__c));
                                
            }
            else
            {
                mapIdeaCustomerIdea.put(lstCustIdea[i].Idea__c,new list<Customer_Idea__c>{lstCustIdea[i]});
                mapIdeaTotalNumofTrucks.put(lstCustIdea[i].Idea__c,lstCustIdea[i].Number_of_Trucks__c);
            }
        } 

        mapIdeaIdName = new map<Id,Idea>([Select id,title from Idea where id in :mapIdeaCustomerIdea.keyset() limit 10000]); 
        for(integer i=0;i<lstIdea.size();i++)
        {
            if(mapIdeaCustomerIdea.containsKey(lstIdea[i].Id))
            {
                IdeaTotalNumberofTrucks newObj = new IdeaTotalNumberofTrucks(lstIdea[i], mapIdeaCustomerIdea.get(lstIdea[i].Id),Integer.valueOf(mapIdeaTotalNumofTrucks.get(lstIdea[i].Id)));
                lstIdeaTotNumofTrucks.add(newObj);
            }
            
        }
                
    }
    
    public void showIdeasByCustomers()
    {
        map<Id,Decimal> mapAccountTotalNumofTrucks = new map<Id,Decimal>();
        lstIdeaTotNumofTrucks = new list<IdeaTotalNumberofTrucks>();
        list<Account> lstAccount = [Select id,name from Account where id in :lstAcctId limit 50000];
                
        map<Id, list<Customer_Idea__c>> mapAcctCustomerIdea = new map<Id, list<Customer_Idea__c>>();
        for(Integer i=0;i<lstCustIdea.size();i++)
        {

            if(mapAcctCustomerIdea.containsKey(lstCustIdea[i].Account__c))
            {
                mapAcctCustomerIdea.get(lstCustIdea[i].Account__c).add(lstCustIdea[i]);
                mapAccountTotalNumofTrucks.put(lstCustIdea[i].Account__c,(mapAccountTotalNumofTrucks.get(lstCustIdea[i].Account__c)+ lstCustIdea[i].Number_of_Trucks__c));
            }
            else
            {
                mapAcctCustomerIdea.put(lstCustIdea[i].Account__c,new list<Customer_Idea__c>{lstCustIdea[i]});
                mapAccountTotalNumofTrucks.put(lstCustIdea[i].Account__c,lstCustIdea[i].Number_of_Trucks__c);
            }
            
        }
        
        for(integer i=0;i<lstAccount.size();i++)
        {
            if(mapAccountTotalNumofTrucks.containsKey(lstAccount[i].Id))
            {
                IdeaTotalNumberofTrucks newObj = new IdeaTotalNumberofTrucks(lstAccount[i],mapAcctCustomerIdea.get(lstAccount[i].Id),Integer.valueOf(mapAccountTotalNumofTrucks.get(lstAccount[i].Id)));
                lstIdeaTotNumofTrucks.add(newObj);
            }
            
        }
        
            
    }

   public class IdeaTotalNumberofTrucks{
    public Idea ideaRec {get;set;}
    public list<Customer_Idea__c> lstRelCustomerIdea {get;set;}
    public Integer totNumofTrucks {get;set;}
    public Account acctRec {get;set;}
       
    public IdeaTotalNumberofTrucks(Idea ideaRec, list<Customer_Idea__c> lstRelCustomerIdea, Integer totNumofTrucks )
    {
        this.ideaRec= ideaRec;
        this.lstRelCustomerIdea = lstRelCustomerIdea;
        this.totNumofTrucks = totNumofTrucks;
    }
    
    public IdeaTotalNumberofTrucks(Account acctRec, list<Customer_Idea__c> lstRelCustomerIdea , Integer totNumofTrucks)
    {
        this.acctRec= acctRec;
        this.lstRelCustomerIdea = lstRelCustomerIdea;
        this.totNumofTrucks = totNumofTrucks;
    }
   }
}