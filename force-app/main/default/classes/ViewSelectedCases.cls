/*********************************************************************
Name    : ViewSelectedCases 
Author  : David Ragsdale
Date    : 19 August 2010

Usage   : Visualforce page controller to replace the statndard related list on Account
    
Dependencies : none

Modified Date : 14 Sept 2010 - 28 Sept 2010 By Shruti Karn
Comment : Added "New NMC" and "Go to List" functionality
*********************************************************************/
public with sharing class ViewSelectedCases {

    public list<Case> CaseList {get;set;}
    public transient list<case> goToCaseList {get;set;}
    list<list<ID>> tempList = new list<list<Id>>();
    
    public integer currentPage {get; set;}
    public long totalPages {get;set;}
    //public Integer totalCases {get; set;}//remove
    //public Decimal size {get; set;}
    
    public String AccountId {get; set;}
    public String URL {get; set;}
    public String current_Value {get; set;}
    String order;
    public String showAlphaBar {get; set;}
    public String alphabet{get; set;}
    
    public Boolean asce {get; set;}
    public Boolean showGotoList {get;set;}
    public Boolean displayMore {get;set;}
       
    public ViewSelectedCases(ApexPages.StandardController controller)
    {
        AccountId = Apexpages.currentPage().getParameters().get('Id');
        currentPage = 1;        /* Current page and total pages is same so that 'Next' and 'Prevoius' links donot*/
        totalpages = 1;            // appear if no records exists.
        current_Value = 'CaseNumber';
        asce = false;
        alphabet = 'All';
        showCases(); 
    }

    public void showCases()
    {
        CaseList = new list<Case>();
        CaseList = [SELECT id, AccountId, Account.Name , CaseNumber, Contact.name, ContactId , Subject, Priority, 
           Status, OwnerId 
           FROM Case WHERE AccountId = :AccountId ORDER BY CaseNumber Desc LIMIT 6];
       // If there are more than 5 records then only "Go to List" should appear on page.
       if(CaseList.size() == 6)
       {
           showGotoList = true;
           CaseList.remove(5);
       }
       else
            showGotoList = false;
      
              
    }
    // for "New NMC Request" Button
    public PageReference NewCase() {
        Account currAccount = [Select Name from Account where id = : AccountId limit 1];
        URL = '/500/e?retURL=%2F500%2Fo&RecordType=01250000000DaMS';
        URL += '&cas4=' + EncodingUtil.urlEncode(currAccount.Name , 'UTF-8');
        URL += '&cas4_lkid=' + AccountId ;
        URL += '&cas14='+ EncodingUtil.urlEncode('NMC Account Request -','UTF-8') + EncodingUtil.urlEncode(currAccount.Name , 'UTF-8');
        URL += '&cas15=' + EncodingUtil.urlEncode('NMC Account Request Details (optional):' , 'UTF-8');
        URL += '&00N50000001Kkos=' + EncodingUtil.urlEncode('Not Submitted' , 'UTF-8');
        URL += '&00N50000001cXos=' + EncodingUtil.urlEncode('New NMC Account' , 'UTF-8');
        URL += '&00N50000001f8Aj=' + EncodingUtil.urlEncode('14 days' , 'UTF-8');
        URL += '&00N50000001f86e=' + EncodingUtil.urlEncode('Not a Defualt NMC Account' , 'UTF-8');
        URL += '&cancelURL=' + AccountId ;
        PageReference pageRef = new PageReference(URL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    // for Go to List Link
    public void getCaseList()
    {
         system.debug('Account Id:'+AccountId);
         goToCaseList = new list<Case>();
         String strSubQuery;
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
         if(current_Value == 'Contact')
             current_Value = 'Contact.Name';
         if(current_Value == 'OwnerId')
             current_Value = 'Owner.Name';
                 
         if(showAlphaBar == 'true' && alphabet != 'All')
             strSubQuery =  ' and '+current_Value+' like ' +'\'' + alphabet + '%\'';
         else
             strSubQuery = '';
         
         String strCaseQuery = 'SELECT id, CaseNumber, CreatedDate, Contact.name, ContactId , Subject, Priority, Status, OwnerId  FROM Case WHERE AccountId = :AccountId '+ strSubQuery +' ORDER BY '+ current_Value+' '+order+' limit 9990';
system.debug('strCaseQuery:'+strCaseQuery);
         goToCaseList = database.query(strCaseQuery);
         if(goToCaseList.size() > 5)
             showGotoList = true;
         else
            showGotoList = false;
         Decimal size = goToCaseList.size();
         Decimal pages = (size/100);
         totalPages = pages.round(System.RoundingMode.UP);
         tempList.clear();
         pagination();
         
    }
    //To display 100 records per page        
    public PageReference pagination()
    {
        transient list<id> IdList = new list<Id>();
        transient  list<Case> tempCaseList = new list<Case>();
        Integer size;
        if(goToCaseList.size() >100)
            size = 100;
        else
            size = goToCaseList.size();
        for(integer i=0;i<size;i++)
        {
            tempCaseList.add(goToCaseList[i]);
            IdList.add(goToCaseList[i].Id);
        } 
         currentPage = 1;
         goToCaseList.clear();
         goToCaseList = tempCaseList;
         tempList.add(IdList);
         return null;
    }
    
    // Function to go the next page
    public Pagereference next()
    {
        transient list<id> IdList = new list<Id>();
system.debug('tempList.size():'+tempList.size());
        for(integer i=0;i<currentPage;i++)
        {
            IdList.addAll(tempList[i]);
        }
system.debug('IdList.size():'+IdList.size());
        String strCaseQuery ='SELECT id, CaseNumber, CreatedDate, Contact.name, ContactId , Subject, Priority, Status, OwnerId FROM Case WHERE id NOT in:IdList and AccountId = :AccountId  ORDER BY '+current_Value+' '+order+' limit 100';
        goToCaseList = database.query(strCaseQuery);  
        IdList.clear();
        Integer size;
        if(goToCaseList.size() >100)
            size = 100;
        else
            size = goToCaseList.size();
        for(integer i=0;i<size;i++)
        {
            IdList.add(goToCaseList[i].Id);
        }
//system.debug('IdList:'+IdList[0]);
        tempList.add(IdList);
system.debug('tempList.size():'+tempList.size()+'0th:'+tempList[0]+'last:'+tempList[tempList.size()-1]);
        currentPage++;
system.debug('Current Page:'+currentPage);
        return null;
        
    }
    
    // Function to go to previous page
    public PageReference previous()
    {
        
       transient list<id> IdList = new list<Id>();
system.debug('tempList.size():'+tempList.size());
system.debug('curr page value:'+(currentPage-2));
        IdList.addAll(tempList[currentPage-2]);
system.debug('tempList.size():'+tempList.size()+'0th:'+tempList[0]+'last:'+tempList[tempList.size()-1]);
        String strCaseQuery ='SELECT id, CaseNumber, CreatedDate, Contact.name, ContactId , Subject, Priority, Status, OwnerId FROM Case WHERE id in: IdList and AccountId = :AccountId ORDER BY '+current_Value+' '+order+' limit 100';
        goToCaseList = database.query(strCaseQuery);
        currentPage--;
        return null;
        
    }
 
    public void showMore()
    {
        if(!(CaseList.isEmpty()))
        {
            list<Id> IdList = new list<Id>();
            for(integer i=0;i<CaseList.size();i++)
            {
                 IdList.add(CaseList[i].Id);   
            }
            //CaseList.clear();
            list<Case> lstTempCase = new list<Case>();
            lstTempCase = [Select id, AccountId, Account.Name , CaseNumber, Contact.name, ContactId , Subject, Priority, 
                           Status, OwnerId 
                           FROM Case WHERE AccountId = :AccountId and id NOT IN : IdList ORDER BY CaseNumber Desc LIMIT 5];
            CaseList.addAll(lstTempCase);
         }
    } 
}