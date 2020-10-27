/*********************************************************************
Name    : ViewSelectedContacts 
Author  : David Ragsdale
Date    : 19 August 2010

Usage   : Visualforce page controller to replace the standard related list "Contacts" on Account
    
Dependencies : none

Modified Date : 14 Sept 2010 - 28 Sept 2010 By Shruti Karn
Comment : Added "Go to List" functionality
*********************************************************************/
public with sharing class ViewSelectedContacts {

    public list<Contact> ContactList {get;set;}
    public transient list<Contact> lstGotoContact {get;set;}
    list<list<ID>> lsttempContactId = new list<list<Id>>();
    
    public integer currentPage {get; set;}
    public long totalPages {get;set;}
    
    public String AccountId {get; set;}
    public String current_Value {get; set;}
    public String showAlphaBar {get; set;}
    public String alphabet{get; set;}
    String order;
    
    public Boolean asce {get; set;}
    public Boolean showGotoList {get;set;}
    
    public ViewSelectedContacts(ApexPages.StandardController controller)
    {
        AccountId = Apexpages.currentPage().getParameters().get('Id');     
        asce = false; 
        current_Value = 'Name';
        currentPage = 1;
        totalPages = 1;
        showAlphaBar = 'true';
        alphabet = 'All';
        showContacts(); 
    }

    public void showContacts()
    {
        ContactList = [SELECT id, AccountId, Name, Title, email, phone, 
           MobilePhone, inactive__c, notification_type__c 
           FROM Contact WHERE AccountId = :AccountId LIMIT 6];
       
       //To check if there are more than 5 records for displaying "Go To List" link    
       if((!(ContactList.isEmpty())) && ContactList.size() == 6)
       {
           showGotoList = true;
           ContactList.remove(5);
       }
       else
       {
           showGotoList = false;
       }
    }
    
//For Go to List Link
  public void getContactsList()
    {
         system.debug('Account Id:'+AccountId);
         lstGotoContact = new list<Contact>();
         String strSubQuery;
         //
         if(asce == true)
         {
             asce = false;
             order = 'desc';
         }
         else
         {   
             asce = true;
             order = 'asc';
         }
                          
         if(showAlphaBar == 'true' && alphabet != 'All')
             strSubQuery =  ' and '+current_Value+' like ' +'\'' + alphabet + '%\'';
         else
             strSubQuery = '';
         
         String strContactQuery = 'SELECT id, Name, Title, email, phone  FROM Contact WHERE AccountId = :AccountId '+ strSubQuery+' ORDER BY '+ current_Value+' '+order+' limit 9990';
system.debug('strCaseQuery:'+strContactQuery);
         lstGotoContact = database.query(strContactQuery);
         Decimal size = lstGotoContact.size();
         Decimal pages = (size/100);
         totalPages = pages.round(System.RoundingMode.UP);
         lsttempContactId.clear();
         pagination();
         
    }   
// to display 100 records per page   
    public PageReference pagination()
    {
        transient list<id> IdList = new list<Id>();
        transient  list<Contact> tempContactList = new list<Contact>();
        Integer size;
        if(lstGotoContact.size() >100)
            size = 100;
        else
            size = lstGotoContact.size();
        for(integer i=0;i<size;i++)
        {
            tempContactList.add(lstGotoContact[i]);
            IdList.add(lstGotoContact[i].Id);
        } 
         currentPage = 1;
         lstGotoContact.clear();
         lstGotoContact = tempContactList;
         lsttempContactId.add(IdList);
         return null;
    }
    
// Function to go next page
    public Pagereference next()
    {
        transient list<id> IdList = new list<Id>();
system.debug('tempList.size():'+lsttempContactId.size());
        for(integer i=0;i<currentPage;i++)
        {
            IdList.addAll(lsttempContactId[i]);
        }
system.debug('IdList.size():'+IdList.size());
        String strCaseQuery ='SELECT id, Name, Title, email, phone FROM Contact WHERE id NOT in:IdList and AccountId = :AccountId  ORDER BY '+current_Value+' '+order+' limit 100';
        lstGotoContact = database.query(strCaseQuery);  
        IdList.clear();
        Integer size;
        if(lstGotoContact.size() >100)
            size = 100;
        else
            size = lstGotoContact.size();
        for(integer i=0;i<size;i++)
        {
            IdList.add(lstGotoContact[i].Id);
        }
//system.debug('IdList:'+IdList[0]);
        lsttempContactId.add(IdList);
system.debug('lsttempContactId.size():'+lsttempContactId.size()+'0th:'+lsttempContactId[0]+'last:'+lsttempContactId[lsttempContactId.size()-1]);
        currentPage++;
system.debug('Current Page:'+currentPage);
        return null;
        
    }
    
    // Function to go to previous page
    public PageReference previous()
    {
        
       transient list<id> IdList = new list<Id>();
system.debug('tempList.size():'+lsttempContactId.size());
system.debug('curr page value:'+(currentPage-2));
        IdList.addAll(lsttempContactId[currentPage-2]);
system.debug('lsttempContactId.size():'+lsttempContactId.size()+'0th:'+lsttempContactId[0]+'last:'+lsttempContactId[lsttempContactId.size()-1]);
        String strCaseQuery ='SELECT id, Name, Title, email, phone  FROM Contact WHERE id in: IdList and AccountId = :AccountId ORDER BY '+current_Value+' '+order+' limit 100';
        lstGotoContact = database.query(strCaseQuery);
        currentPage--;
        return null;
        
    }
}