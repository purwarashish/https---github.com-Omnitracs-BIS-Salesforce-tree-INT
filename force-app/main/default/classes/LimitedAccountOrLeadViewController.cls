public class LimitedAccountOrLeadViewController
{
public Lead selectedLead {get;set;}
public Account selectedAcc {get;set;}
public  String id;



public LimitedAccountOrLeadViewController()
{
 if(ApexPages.currentPage().getParameters().containsKey('id'))
 {
  id = ApexPages.currentPage().getParameters().get('id');
  if(id.contains('001'))
  selectedAcc = [SELECT Name,QWBS_Cust_ID__c, QWBS_Status__c ,BillingCity, BillingState, OwnerId, 
                  (Select WhoId, Subject, Status, IsTask, ActivityDate, LastModifiedDate, OwnerId, WhatId From ActivityHistories order by LastModifiedDate desc  limit 11 ), 
                  (Select WhoId, WhatId, IsTask, Subject, OwnerId, Status, Priority, ActivityDate From OpenActivities order by LastModifiedDate desc  limit 11 )                  
                  FROM Account where id = :id];
  if(id.contains('00Q'))
  selectedLead = [SELECT Name, Title, Status, Company, City, State, ownerId, 
                  (Select WhoId, Subject, Status, IsTask, ActivityDate, LastModifiedDate, OwnerId From ActivityHistories order by LastModifiedDate desc  limit 11 ), 
                  (Select WhoId, WhatId, IsTask, Subject, OwnerId, Status, Priority, ActivityDate From OpenActivities order by LastModifiedDate desc limit 11 ) 
                  FROM Lead where id = :id ];
  
 }
 
}

  // ApexPages.StandardSetController must be instantiated
    // for standard list controllers
    public ApexPages.StandardSetController setConCont{
        get {
             if(id.contains('001'))
               { 
system.debug('@@@@@@@@@@  AccountId is : '+ id);
system.debug('@@@@@@@@@@  setConCont is : '+ id);
                if(setConCont == null)
                {
                setConCont = new ApexPages.StandardSetController([Select Name, MobilePhone, Phone, Email, Title, Inactive__c, Notification_Type__c,MailingCity, MailingState, Account.Name  From Contact where AccountId = :id order by Name limit 1000]);
                // sets the number of records in each page set   
                setConCont.setPageSize(10);
                }
                
               } 
          
            return setConCont;
        }
        set;
    }

    // Initialize setCon and return a list of records
    public List<Contact> getContacts() {
        if(setConCont != null)
        return (List<Contact>) setConCont.getRecords();
        else
        return null;
    }
    
}