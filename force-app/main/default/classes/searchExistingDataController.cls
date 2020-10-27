public class searchExistingDataController
{
    public String searchString{get;set;}
    
    public boolean AccountFlag{get;set;}
    public boolean ContactFlag{get;set;}
    public boolean LeadFlag{get;set;}
    
    // public List<Account> lstAcc {set;get;} {lstAcc = new List<Account>();}
    // public List<Lead> lstLead {set;get;} {lstLead = new List<Lead>();}
    public String AccId {get;set;}
    public String LeadId {get;set;}
    
    public List<Account> listOfAccounts{get;set;}
    public List<Lead> listOfLeads{get;set;}
    public List<Contact> listOfContacts{get;set;}
    
    public Account selectedAcc {get;set;}
    public Lead selectedLead {get;set;}
    public String selectedRecOwner {get;set;}
    public String selectedRecPartnerOwner  {get;set;}
    
    /*
    transient public ApexPages.StandardSetController setConAccTest {get;set;}
    transient public ApexPages.StandardSetController setConContTest {get;set;}
    transient public ApexPages.StandardSetController setConLeadTest {get;set;}
    */
    
    public searchExistingDataController()
    {
     searchString = '';
     AccountFlag = true;
     ContactFlag = true;
     LeadFlag = true;
     
     if(ApexPages.currentPage().getParameters().containsKey('searchString'))
     searchString  = ApexPages.currentPage().getParameters().get('searchString');
     
     if(ApexPages.currentPage().getParameters().containsKey('AccountFlag'))
     {
      if(ApexPages.currentPage().getParameters().get('AccountFlag') == 'true')
      AccountFlag = true;
      if(ApexPages.currentPage().getParameters().get('AccountFlag') == 'false')
      AccountFlag = false;
     }
     
     if(ApexPages.currentPage().getParameters().containsKey('ContactFlag'))
     {
      if(ApexPages.currentPage().getParameters().get('ContactFlag') == 'true')
      ContactFlag= true;
      if(ApexPages.currentPage().getParameters().get('ContactFlag') == 'false')
      ContactFlag= false;
     }
     
     if(ApexPages.currentPage().getParameters().containsKey('LeadFlag'))
     {
      if(ApexPages.currentPage().getParameters().get('LeadFlag') == 'true')
      LeadFlag= true;
       if(ApexPages.currentPage().getParameters().get('LeadFlag') == 'false')
      LeadFlag= false;
     }
     
    }
    // ApexPages.StandardSetController must be instantiated
    // for standard list controllers
    public ApexPages.StandardSetController setConAcc {
        get {
            system.debug('********************************'+setConAcc+'@@@@@@'+searchString+'$$$$$$$$$'+AccountFlag);
            if(setConAcc == null && searchString != null && searchString != '' && AccountFlag == true) {

                String searchTxt= '%'+searchString +'%';
                
                setConAcc = new ApexPages.StandardSetController([SELECT Name,QWBS_Cust_ID__c, QWBS_Status__c ,BillingCity, BillingState, BillingCountry, District__c, RecordOwner__c, ownerId FROM Account where name like :searchTxt or US_DOT__c like:searchTxt order by name limit 750 ] );
                
                // sets the number of records in each page set   
                   setConAcc.setPageSize(15);
                
            }
            //setConAccTest = setConAcc;
            return setConAcc;
        }
        set;
    }

    // Initialize setCon and return a list of records
    public List<Account> getAccounts() {
        if(setConAcc != null)
        return (List<Account>) setConAcc.getRecords();
        else
        return null;
    }
    
    // ApexPages.StandardSetController must be instantiated
    // for standard list controllers
    public ApexPages.StandardSetController setConCont {
        get {
            if(setConCont == null && searchString != null && searchString != '' && ContactFlag == true) {
               
                String searchTxt= '%'+searchString +'%';
                
                setConCont = new ApexPages.StandardSetController([SELECT Name,Title, MailingCity, MailingState, Account.Name,ownerId  FROM Contact where name like :searchTxt or Email like:searchTxt or Account.Name like :searchTxt order by name limit 750]);
                
                // sets the number of records in each page set   
                   setConCont.setPageSize(15);
                
            }
            //setConContTest = setConCont;
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
    
    // ApexPages.StandardSetController must be instantiated
    // for standard list controllers
    public ApexPages.StandardSetController setConLead {
        get {
            if(setConLead == null && searchString != null && searchString != '' && LeadFlag ==true) {
                
                String searchTxt= '%'+searchString +'%';
                
                setConLead = new ApexPages.StandardSetController([SELECT Name, Title, Status, Company, City, State, ownerId FROM Lead where (name like :searchTxt or Email like:searchTxt or DOT__c like:searchTxt or Company like :searchTxt) and (isConverted=false) order by name limit 750]);
                
                // sets the number of records in each page set   
                   setConLead.setPageSize(15);
                
            }
            //setConLeadTest = setConLead;
            return setConLead;
        }
        set;
    }

    // Initialize setCon and return a list of records
    public List<Lead> getLeads() {
        if(setConLead != null)
        return (List<Lead>) setConLead.getRecords();
        else
        return null;
    }
    
    public pageReference search()
    {
     System.debug('**********searchString: '+searchString);  
     System.debug('**********AccountFlag: '+AccountFlag); 
     System.debug('**********ContactFlag: '+ContactFlag); 
     System.debug('**********LeadFlag: '+LeadFlag); 
    
     searchString=  EncodingUtil.urlEncode(searchString, 'UTF-8');
     String URL = '/apex/SearchExistingRecordsPRM?searchString='+searchString;
     if(AccountFlag)
     URL = URL + '&AccountFlag=true';
     else
     URL = URL + '&AccountFlag=false';
     if(ContactFlag)
     URL = URL + '&ContactFlag=true';
      else
     URL = URL + '&ContactFlag=false';
     if(LeadFlag)
     URL = URL + '&LeadFlag=true';
      else
     URL = URL + '&LeadFlag=false';
     
     
     
     pageReference pg =  new pageReference(URL );
     
     pg.setRedirect(true);
     
     
     return pg;
    }
    
    public pageReference checkAccountOwner()
    {
    
        
        UserRecordAccess  u = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :AccId limit 1];
         PageReference pg ;
        if(!u.HasReadAccess )
         pg = new PageReference('/apex/LimitedAccountOrLeadView?id='+AccId);
        else
         pg = new PageReference('/'+AccId);              
        return pg;
        
    }
    
    public pageReference checkLeadOwner()
    {        
      
         UserRecordAccess  u = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :LeadId limit 1];
         PageReference pg ;
        if(!u.HasReadAccess )
         pg = new PageReference('/apex/LimitedAccountOrLeadView?id='+LeadId );
        else
         pg = new PageReference('/'+LeadId );              
        return pg;
        
        
    }

}