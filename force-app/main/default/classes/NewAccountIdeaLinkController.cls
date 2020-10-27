/*********************************************************************
Name : NewAccountIdeaLinkController
Author : Shruti Karn
Date : 2 February 2011

Usage : This class is used by the visualforce page "NewAccountIdeaLink" for 
        creating new Customer Idea record.
    
Dependencies : Used by the New button of Customer Idea Object.

Modified By : Shruti Karn
Comments: Updated the code to populate number of Trucks based on Idea's Category.

*********************************************************************/
public class NewAccountIdeaLinkController{
    private ApexPages.StandardController controller;
    public String acctId {get;set;}
    public string ideaId {get;set;}
    Decimal numOfTrucks {get;set;}
    public Customer_Idea__c acctIdea {get;set;}
    public Customer_Idea__c ideaAccount {get;set;}
    public boolean showInput {get;set;}
        
    public NewAccountIdeaLinkController(ApexPages.StandardController controller){
         acctIdea = (Customer_Idea__c) controller.getRecord();
         ideaAccount = (Customer_Idea__c) controller.getRecord();
                 
         if(acctIdea.Id != null )
         {
             acctIdea = [Select name,idea__c,account__c from Customer_Idea__c where Id = : acctIdea.Id limit 1];
             showInput = false;
         }
         else{
             showInput = true;
         }
         this.controller = controller;
         
    }
     
    public PageReference Save()
    {
        try
        {
            list<Customer_Idea__c> lstExistingIdea = new list<Customer_Idea__c>();
            lstExistingIdea = [Select Idea__c from Customer_Idea__c 
                                    where Account__c = :acctId
                                    and Idea__c = :ideaAccount.Idea__c 
                                    limit 10];
            
            if(lstExistingIdea.size() > 0)
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,'The Account and Idea are already linked.');
                ApexPages.addmessage(msg); 
                acctId = '';
                ideaId = '';
                return null;
            }
        }
        catch(exception e)
        {
            system.debug('Exception in Save()');        
        }
        
        PageReference PageRef = controller.save();
        return PageRef; 
    }
    public PageReference SaveandNew()
    {
        controller.save();
        PageReference PageRef = new PageReference('/apex/NewAccountIdeaLink');
        PageRef.setRedirect(true);
        return PageRef; 
    }
    
    public void findTotalUnits()
    {
        try
        {
            acctIdea.Number_of_Trucks__c = 0;
            Account acct = [Select Total_Units__c, Total_Trailers_Equipped__c, Total_In_Cab_On_Air_Units__c from Account where id=: acctId limit 1];
            list<Idea> lstIdea = [Select categories from Idea where id = : acctIdea.Idea__c limit 1];
            if(lstIdea[0].Categories != '')
            {
                Decimal totalTrailersEquipped;
                Decimal totalInCabOnAirUnits;
                if(acct.Total_Trailers_Equipped__c == null)
                    totalTrailersEquipped = 0;
                else
                    totalTrailersEquipped = acct.Total_Trailers_Equipped__c;
                    
                if(acct.Total_In_Cab_On_Air_Units__c == null)
                    totalInCabOnAirUnits = 0;
                else
                    totalInCabOnAirUnits = acct.Total_In_Cab_On_Air_Units__c;
                    
                list<string> lstCategories = lstIdea[0].Categories.split(';');
                if(lstCategories.size() == 1  && lstCategories[0].trim().tolowerCase() == 'trailer tracking')
                {
                    numOfTrucks  = totalTrailersEquipped ;
                }
                else if(lstCategories.size() == 1  && lstCategories[0].trim().tolowerCase() != 'trailer tracking')
                {
                    numOfTrucks  = totalInCabOnAirUnits;
                }
                else if(lstCategories.size() > 1  && lstIdea[0].Categories.trim().tolowercase().contains('trailer tracking'))
                {
                    numOfTrucks  = totalTrailersEquipped + totalInCabOnAirUnits;
                } 
            }
                        
            acctIdea.Number_of_Trucks__c = numOfTrucks;
        }
        catch(Exception e)
        {
            system.debug('Exception in findTotalUnits():'+e);
        }        
    }
       
    public PageReference redirectionOnEdit()
    {
       String URL = '/apex/NewAccountIdeaLink?Id='+acctIdea.Id;
       PageReference PageRef = new PageReference(URL);
       PageRef.setRedirect(true);
       return PageRef; 
    }
}