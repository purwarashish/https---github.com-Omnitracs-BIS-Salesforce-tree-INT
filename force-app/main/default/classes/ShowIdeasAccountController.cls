/*********************************************************************
Name : ShowIdeasAccountController
Author : Shruti Karn
Date : 31 January 2011

Usage : This class is used by the visualforce page "showIdeasAccount" for displaying all Accounts related to the Idea
    
Dependencies : none

*********************************************************************/
public class ShowIdeasAccountController{
    public list<Customer_Idea__c> lstAccountIdea {get;set;}
    public String ideaTitle {get;set;}
    public String alphabet {get;set;}
    public String IdeaId {get;set;}
    list<list<Customer_Idea__c>> tempList = new list<list<Customer_Idea__c>>();
    public integer currentPage {get; set;}
    public integer totalPages {get;set;}   
    public Boolean asce {get; set;} 
    public String current_Value {get;set;}
    String query = '';
    
   
    public showIdeasAccountController()
    {
        currentPage = 1;        /* Current page and total pages is same so that 'Next' and 'Prevoius' links donot*/
        totalpages =1;            // appear if no records exists.
        asce =  true;
        current_Value = 'Name';
        lstAccountIdea = new list<Customer_Idea__c>();
        IdeaId = Apexpages.currentPage().getParameters().get('Id');
        ideaTitle = Apexpages.currentPage().getParameters().get('Title');
        lstAccountIdea = [Select Id, Name, Account__c , Number_of_Trucks__c, Idea__r.Title, Idea__c ,Account__r.Total_Units__c, value__c,Committed__c  from Customer_Idea__c where Idea__c = :IdeaId order by Account__r.Name asc limit 10000];
        if(lstAccountIdea.size()>0)
        {
           pagination();
        }
        
    }
    
    public PageReference alphabetOrdering()
    {
        
        if(alphabet == 'All')
        {
             query = 'Select Id,name,Value__c, Account__c, Number_of_Trucks__c, Account__r.Name , Idea__r.Title, Idea__c from Customer_Idea__c where Idea__c ='+ '\'' + IdeaId + '\'' +' order by '+current_Value+' limit 10000';
        }
        else
        {
            query = 'Select Id, name,Value__c,Account__c ,Number_of_Trucks__c, Account__r.Name , Idea__r.Title, Idea__c,Committed__c  from Customer_Idea__c where Idea__c ='+ '\'' + IdeaId + '\''+' and '+current_Value+' like ' +'\'' + alphabet + '%\'' +'  limit 10000';
        }
        

        try
        {
            lstAccountIdea = database.query(query);
        }
        catch(exception e)
        {
            system.debug('Exception in querying:'+e);
        }
        return null;
    }
    
    public PageReference changeOrder()
    {
        
        if(asce == true)
        {
            query = 'Select Name,Id,Value__c , Account__c ,Number_of_Trucks__c, Account__r.Name , Idea__r.Title, Idea__c ,Committed__c from Customer_Idea__c where Idea__c ='+ '\'' + IdeaId + '\'' +' order by '+current_Value+'  desc limit 10000';
            asce = false;
        }
        else
        {
            query = 'Select Name,Id, Value__c ,Account__c ,Number_of_Trucks__c, Account__r.Name , Idea__r.Title, Idea__c,Committed__c from Customer_Idea__c where Idea__c ='+ '\'' + IdeaId + '\'' +' order by '+current_Value+' asc limit 10000';
            asce = true;
        }
        
        try
        {
            lstAccountIdea = database.query(query);
        }
        catch(exception e)
        {
            system.debug('Exception in querying:'+e);
        }
        return null;
    }
   


    //To display 15 records per page
    public PageReference pagination()
    {

        if(lstAccountIdea.size()>0)
        {
            list<Customer_Idea__c> tempIdeaAccount = new list<Customer_Idea__c>();
            for(integer i=0;i<lstAccountIdea.size();i++)
            {
                tempIdeaAccount.add(lstAccountIdea[i]);
                if(tempIdeaAccount .size() == 15)
                {
                    
                    tempList.add(tempIdeaAccount.deepClone(true));
                    tempIdeaAccount.clear();
                }
            }
            if(tempIdeaAccount.size()>0)
            {
                tempList.add(tempIdeaAccount.deepClone(true));
            }
        }
        lstAccountIdea.clear();
        if(!tempList.isEmpty())
        {
            totalPages = tempList.size();
            lstAccountIdea = tempList[0];
            currentPage = 1;
        }
        return null;
    }
    // Function to go next page
    public Pagereference next()
    {
        lstAccountIdea = tempList[currentPage];
        currentPage++;
        asce=true;
        return null;
        
    }
    
    // Function to go to previous page
    public PageReference previous()
    {
        
        lstAccountIdea = tempList[currentPage-2];
        currentPage--;
        asce=true;
        return null;
        
    }
}