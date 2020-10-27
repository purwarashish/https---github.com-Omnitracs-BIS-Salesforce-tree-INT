Public class MyAccountsController{

/***********************************************************************************
Author: Shruti Karn, Salesforce.com Developer
Tata Consultancy Services Limited
For CR# 19673

************************************************************************************/

//Variable Decalration
public list<Account> userList {get;set;}
public list<list<Account>> tempList = new list<list<Account>>();
public integer currentPage {get; set;}
public integer totalPages {get;set;}
public String current_value ;
public Boolean asce {get; set;}
User currentUser;

//Getters and setters
public void setCurrent_value(String value)
{
    current_value = value;
}

public String getCurrent_Value()
{
    return current_value;
}

//Contructor where defualt values are set
public MyAccountsController(ApexPages.StandardController controller)
{
     
     asce = true;
     current_value = 'name';  // sorted by name by default
     currentPage = 1;        /* Current page and total pages is same so that 'Next' and 'Prevoius' links donot*/
     totalpages =1;            // appear if no records exists.
     retrieveUserList();
     
}

//Retrieves the list of accounts to which user belongs.
public void retrieveUserList()
{
    currentUser = [Select Id From User Where Id = : UserInfo.getUserId() Limit 1];
    system.debug('User Id:'+currentUser.Id);
    userList = [ Select Id, QWBS_Status__c, QWBS_Market__c, QWBS_Cust_ID__c, Phone, Name, /*District__c,*/ BillingState, BillingCity from Account where
                    Software_Application_Eng__c =: currentUser.Id OR
                    Professional_Services_Rep__c =: currentUser.Id OR
                    OwnerId =: currentUser.Id OR
                    Contracts_Administrator__c =: currentUser.Id OR
                    CSR__c =: currentUser.Id OR
                    Inside_CSR__c =: currentUser.Id OR
                    Account_Manager__c =: currentUser.Id order by Name limit 1000];
    
    system.debug('User List:'+userList);
    if(userList.size()>0)
    pagination();
}

//To display 15 records per page
public PageReference pagination()
{
    system.debug('Value inside Pagination:'+userList);
    if(userList.size()>0)
    {
        list<Account> tempAccount = new list<Account>();
        for(integer i=0;i<userList.size();i++)
        {
            tempAccount.add(userList[i]);
            if(tempAccount.size() == 100)
            {
                
                tempList.add(tempAccount.deepClone(true));
                tempAccount.clear();
            }
        }
        if(tempAccount.size()>0)
        {
            tempList.add(tempAccount.deepClone(true));
        }
    }
    system.debug('Size:'+tempList.size()+'Value:'+tempList[0]);
    for(integer i=0;i<tempList.size();i++)
    {
        system.debug('Temp List:'+tempList[i]);
    }
    totalPages = tempList.size();
    userList = tempList[0];
    currentPage = 1;
    system.debug('currentPage:'+currentPage+'TotalPages:'+totalPages);
    return null;
}
// Function to go next page
public Pagereference next()
{
    userList = tempList[currentPage];
    currentPage++;
    system.debug('Current Page:'+currentPage);
    asce=true;
    
    return null;
    
}

// Function to go to previous page
public PageReference previous()
{
    
    userList = tempList[currentPage-2];
    currentPage--;
    asce=true;
    
    return null;
    
}

//To change the sort order
public void ChangeOrder()
{
    system.debug('Inside Change Order:'+current_value);
    list<account> acctList = new list<Account>();
    system.debug('asce:'+asce);
    acctList = userList;
    if(userList.size()>0)
    {
    integer sizeofList = userList.size();
    String prevValue;
    String nextValue;

    
    if(asce == true)
    {
        for(integer i=1;i<sizeofList;i++)
        {
            for(integer j=0;j<sizeofList-i;j++)
            {
                if(current_value == 'name')
                {
                    prevValue = userList[j].name;
                    nextValue = userList[j+1].name;
                }
                if(current_value == 'QWBS_Market__c')
                {
                    prevValue = userList[j].QWBS_Market__c;
                    nextValue = userList[j+1].QWBS_Market__c;
                }
                /*if(current_value == 'District__c')
                {
                    prevValue = userList[j].District__c;
                    nextValue = userList[j+1].District__c;
                }*/
                if(current_value == 'QWBS_Status__c')
                {
                    prevValue = userList[j].QWBS_Status__c;
                    nextValue = userList[j+1].QWBS_Status__c;
                }
                if(current_value == 'QWBS_Cust_ID__c')
                {
                    prevValue = userList[j].QWBS_Cust_ID__c;
                    nextValue = userList[j+1].QWBS_Cust_ID__c;
                }
                if(current_value == 'Phone')
                {
                    prevValue = userList[j].Phone;
                    nextValue = userList[j+1].Phone;
                }
                if(current_value == 'BillingCity')
                {
                    prevValue = userList[j].BillingCity;
                    nextValue = userList[j+1].BillingCity;
                }
                if(current_value == 'BillingState')
                {
                    prevValue = userList[j].BillingState;
                    nextValue = userList[j+1].BillingState;
                }
                if(prevValue < nextValue)
                {
                    Account acct = userList[j+1];
                    userList[j+1]=userList[j];
                    userList[j] = acct;
                }
            }
        }
        system.debug('UserLst:'+userList);
        asce = false;
    }
    
    else
    {
        for(integer i=1;i<sizeofList;i++)
        {
            for(integer j=0;j<sizeofList-i;j++)
            {
                if(current_value == 'name')
                {
                    prevValue = userList[j].name;
                    nextValue = userList[j+1].name;
                }
                if(current_value == 'QWBS_Market__c')
                {
                    prevValue = userList[j].QWBS_Market__c;
                    nextValue = userList[j+1].QWBS_Market__c;
                }
                /*if(current_value == 'District__c')
                {
                    prevValue = userList[j].District__c;
                    nextValue = userList[j+1].District__c;
                }*/
                if(current_value == 'QWBS_Status__c')
                {
                    prevValue = userList[j].QWBS_Status__c;
                    nextValue = userList[j+1].QWBS_Status__c;
                }
                if(current_value == 'QWBS_Cust_ID__c')
                {
                    prevValue = userList[j].QWBS_Cust_ID__c;
                    nextValue = userList[j+1].QWBS_Cust_ID__c;
                }
                if(current_value == 'Phone')
                {
                    prevValue = userList[j].Phone;
                    nextValue = userList[j+1].Phone;
                }
                if(current_value == 'BillingCity')
                {
                    prevValue = userList[j].BillingCity;
                    nextValue = userList[j+1].BillingCity;
                }
                if(current_value == 'BillingState')
                {
                    prevValue = userList[j].BillingState;
                    nextValue = userList[j+1].BillingState;
                }
                if(prevValue > nextValue)
                {
                    Account acct = userList[j+1];
                    userList[j+1]=userList[j];
                    userList[j] = acct;
                }
            }
        }
        system.debug('UserLst:'+userList);    
        system.debug('asce1:'+asce);
        asce=true;
    }
    }
}
}