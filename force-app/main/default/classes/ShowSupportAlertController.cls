/*********************************************************************
Name : ShowSupportAlertController
Author : Shruti Karn
Date : 27 December 2010

Usage : This class is used for displaying Support Alert related to the Case's Account
        to the Call Center Users 
    
CR # 23403
Dependencies : Custom Setting -> ShowSupportAlertsProfiles
               Cutom Label -> CALL_CENTER_RECORDTYPEID

*********************************************************************/
public class ShowSupportAlertController{
    public Integer totalSuppAlert {get;set;}
    public Integer critSupportAlert {get;set;}
    public String accSupportAlert {get; set;}
    public Id supportAlertId {get;set;}
    public String descSupportAlert {get;set;} 
    public String acctName{get;set;}
    String argList = '&cas7=Open&00N50000001Kkos=In Progress';
    public Case currCase {get;set;}
    public String acctId {get;set;}
    public String contId {get;set;}
    public Boolean isSuppAlert{get;set;}
    public String caseNum {get;set;}
    public list<Support_Alert__c> lstSupportAlert;
    public list<Support_Alert__c> lstAllSupportAlert;
    private ApexPages.StandardController controller;
    public boolean showSupportAlerts {get; set;}
    public Boolean showAll {get; set;}
    public String caseRecType {get; set;}
    String TemplateID;
    list<TemplateDetail__c> templateDetailList;
  /************************************Getters and Setters *******************************/     
      
    public void setTotalSuppAlert(Integer totalSuppAlert)
    {
        this.totalSuppAlert = totalSuppAlert;
    }
    public Integer getTotalSuppAlert()
    {
        return this.totalSuppAlert;
    }
    
    public void setLstSupportAlert(list<Support_Alert__c> lstSupportAlert)
    {
        this.lstSupportAlert = lstSupportAlert;
    }
    
    public list<Support_Alert__c> getLstSupportAlert()
    {
        Date currDate = date.today();
        lstSupportAlert = [Select id , Account__c,Critical__c, Critical_Flag__c, Description__c , Name, summary__c,end_date__c from Support_Alert__c where Account__c = :acctId     
                                AND (End_Date__c > : currDate OR End_Date__c =null) limit 6 ];
        
        if(lstSupportAlert.size() > 5)
        {
            showAll= true;
            lstSupportAlert.remove(5);
        }
        else
            showAll=false;
       return lstSupportAlert ;
    }
    
    public void setLstAllSupportAlert(list<Support_Alert__c> lstAllSupportAlert)
    {
        this.lstAllSupportAlert = lstAllSupportAlert;
    }
    
    public list<Support_Alert__c> getLstAllSupportAlert()
    {
        acctId  = Apexpages.currentPage().getParameters().get('AccountId');
        Date currDate = date.today();
        lstAllSupportAlert = [Select id , Account__c,Critical__c, Critical_Flag__c, Description__c , Name, summary__c,end_date__c from Support_Alert__c where Account__c = :acctId 
     
                                AND (End_Date__c > : currDate OR End_Date__c =null) limit 200 ];
       return lstAllSupportAlert ;
    }
    
    /************************************************************************************
    * Gathers information from Custom Setting ShowSupportAlertsProfiles__c and returns
    * true if profile is in list (i.e. should see custom VF page)
    ************************************************************************************/
    public boolean showSupportAlerts()
    {
        string userProfileId = userinfo.getProfileId();
        Id recType = Apexpages.currentPage().getParameters().get('RecordType');
        if(recType == null)
            recType = caseRecType;
        List<ShowSupportAlertsProfiles__c> listProfileId = 
            [SELECT profileID__c from ShowSupportAlertsProfiles__c 
             WHERE ProfileID__c = :userProfileID LIMIT 1];
               
        if (recType == System.Label.Call_Center_RecordTypeId)
        {
            if (listProfileId.size() > 0)
            {
               showSupportAlerts = true;
            } else {
                showSupportAlerts = false;      
            }
        }else{
            showSupportAlerts = false;
        }      
        
        return showSupportAlerts;
    }   
    
   /************************Contructor for setting the default values of picklist and variables*********/
   
   public ShowSupportAlertController(){
   }
    public ShowSupportAlertController(ApexPages.StandardController controller){
        currCase =  (Case) controller.getRecord();
        
        if(currCase.Id != null)
            currCase = [Select Id , CaseNumber , AccountId , recordTypeId from Case where id = : currCase.Id limit 1];

        String ContfrmURL = '';
        String AccountIDfrmURL ='';
        String recordTypeIdURL = '';
        String NMCAccountfrmURL ='';
        AccountIDfrmURL = Apexpages.currentPage().getParameters().get('acctId');
        ContfrmURL = Apexpages.currentPage().getParameters().get('contId');
        NMCAccountfrmURL = Apexpages.currentPage().getParameters().get('nmc');
        TemplateID = Apexpages.currentPage().getParameters().get('templateID');
        if(TemplateID != null && templateID != '')
            findCase(TemplateID);
        this.controller = controller;

        currCase.origin = 'Phone';
        currCase.OwnerId = UserInfo.getUserId();
        
        if(AccountIDfrmURL != null && AccountIDfrmURL != 'null' && AccountIDfrmURL.trim() != '')
            currCase.AccountId = AccountIDfrmURL;

        if(ContfrmURL != null && ContfrmURL != 'null' && ContfrmURL.trim() != '')
            currCase.ContactId = ContfrmURL;

        if(NMCAccountfrmURL != null &&  NMCAccountfrmURL != 'null' && NMCAccountfrmURL.trim() != '')
            currCase.NMC_Account__c = NMCAccountfrmURL;
        currCase.RecordTypeId = Apexpages.currentPage().getParameters().get('RecordType');
        critSupportAlert =0;

        totalSuppAlert = 0;        
    }
    
    /*****************************************************************
        Functionality for "Save&New" button. This will save the Case and
        will take User to New Case page.
    ******************************************************************/
    public PageReference SaveandNew()
    {
        
        try
        {
            if(currCase.Id == null)
                insert currCase;
            else
                currCase =  (Case) controller.getRecord();
                update currCase;
        }
        catch(Exception e)
        {
            ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'Case was not updated/inserted due to some problem.Please contact your System Administrator.');
            ApexPages.addmessage(msg1); 
            return null;
        }
        
        PageReference PageRef = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Case&retURL=%2F500%2Fo&save_new_url=%2F500%2Fe%3FretURL%3D%252F500%252Fo');

        PageRef.setRedirect(true);

        return PageRef; 
    }
    
    
     /*****************************************************************
        Functionality for "Save" button. This will save the Case and
        will take User to New Case page.
    ******************************************************************/
    public PageReference Save()
    {
             
        try
        {
            if(currCase.Id == null)
            {
                insert currCase;
            }else{
                currCase =  (Case) controller.getRecord();
                update currCase;
            }
        }
        catch(Exception e)
        {
            ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'Case was not updated/inserted due to some problem.Please contact your System Administrator.');
            ApexPages.addmessage(msg1); 
            return null;
        }
        PageReference PageRef = new PageReference('/'+currCase.Id);

        PageRef.setRedirect(true);

        return PageRef; 
    }
    
    
    /**************************************************************************
        Redirecting to the standard Case page or the Visualforce page 
        depending on the Record type.
    ****************************************************************************/
    
    public PageReference redirectToNewCase()
    {      
       String URL1 ='';
       String finalAcctID='';
       String recId ='';
       String currURL = 'https://'+ApexPages.currentPage().getHeaders().get('Host');
       Id recType = Apexpages.currentPage().getParameters().get('RecordType');

       
       /**********For NMC Account's New Case Button******************/
       
       String nmcName= Apexpages.currentPage().getParameters().get('CF00N50000001cc33');
       String nmcId = Apexpages.currentPage().getParameters().get('CF00N50000001cc33_lkid');
       
       // If the control is coming from "CaseTemplate" visualforce page
       if(nmcId == null || nmcId== '')
             nmcId = Apexpages.currentPage().getParameters().get('nmc');
       
       String nmcAcctName = Apexpages.currentPage().getParameters().get('cas4');
       String nmcAcctID = Apexpages.currentPage().getParameters().get('cas4_lkid');
       String CI = Apexpages.currentPage().getParameters().get('00N50000001KkqR');
       
       /************For Contact's New Case Button***************************/
       String cntId = Apexpages.currentPage().getParameters().get('cas3_lkid');
             
       // If the control is coming from "CaseTemplate" visualforce page
       if(cntId == '' || cntId == null)
             cntId = Apexpages.currentPage().getParameters().get('contId');
       
       String cntName = Apexpages.currentPage().getParameters().get('cas3');
       String contAcctName = Apexpages.currentPage().getParameters().get('cas4');
       String contAcctID = Apexpages.currentPage().getParameters().get('cas4_lkid');
       
       /***************For Account's New Case Button***********************************************************/       
       String acctName = Apexpages.currentPage().getParameters().get('cas4');    
       String acctId = Apexpages.currentPage().getParameters().get('cas4_lkid');
       
       // If the control is coming from "CaseTemplate" visualforce page
       if(acctId == null || acctId == '')
             acctId = Apexpages.currentPage().getParameters().get('acctId');
       
       PageReference PageRef;

        // Call "FindURL()" of "CaseTemplateListController" which will build the URL with default values
        CaseTemplateListController newObj = new CaseTemplateListController();
        if(nmcId == 'null')
            nmcId =null;
        String argList = newObj.findURL(templateDetailList,nmcId);

       if (showSupportAlerts() == false)     
       {
          if(nmcId != '' && nmcId != null && nmcName != '' && nmcName != null)
          {
              nmcName = EncodingUtil.urlEncode(nmcName , 'UTF-8');
              nmcAcctName = EncodingUtil.urlEncode(nmcAcctName , 'UTF-8');
              URL1 = '&CF00N50000001cc33='+nmcName+'&CF00N50000001cc33_lkid='+nmcId+'&cas4='+nmcAcctName+'&cas4_lkid='+nmcAcctID+'&00N50000001KkqR='+CI+argList;
              recId  = nmcId ;
          }
          else if(cntId != '' && cntId != null && cntName != '' && cntName != null)
          {
              contAcctName = EncodingUtil.urlEncode(contAcctName , 'UTF-8');
              URL1 = '&cas4='+contAcctName+'&cas4_lkid='+contAcctID+'&cas3='+cntName+'&cas3_lkid='+cntId+argList;
              recId = cntId;
          }
          
          else if(acctId != '' && acctId != null && acctName != '' && acctName != null)
          {
              acctName = EncodingUtil.urlEncode(acctName , 'UTF-8');
              URL1 = '&cas4='+acctName+'&cas4_lkid='+acctId +argList;
              recId = acctId;
          }
          
          else
            recId = '/500/o';
            String URL = '';
            if(recType != null)
                URL = '/500/e?retURL='+recId+'&RecordType='+recType+'&ent=Case&nooverride=1'+URL1+'&templateID='+templateID+argList;
            else
                URL = '/500/e?retURL='+recId+'&ent=Case&nooverride=1'+URL1+'&templateID='+templateID+argList;
               
          PageRef = new PageReference(URL);
                   
       }else{

           String URL ='';
           String nmc ='';
           if(nmcAcctID != null && nmcAcctID !='')
           {
               finalAcctID = nmcAcctID ;
               recId  = nmcId;    
                          
           }else if(contAcctID != null && contAcctID != ''){
               finalAcctID = contAcctID ;
               recId  = cntId;
           }else{
               finalAcctID = acctId;
               recId  = acctId;
           }
           
           if(cntId == null)
               cntId ='';
           
           if(finalAcctID == null)
               finalAcctID ='';    
           if(nmcId != null)
               nmc = nmcId;
           else
               nmc ='';
           if(finalAcctID.trim() == '' && cntId.trim() == null  )
               URL = '/apex/CallCenterCase?retURL=%2F500%2Fo'+'&templateID='+templateID;
           else
               URL = '/apex/CallCenterCase?acctId='+finalAcctID+'&contId='+cntId + '&nmc='+nmc + '&RecordType=' + recType + '&retURL=%2F500%2Fo'+'&templateID='+templateID;
           
           PageRef = new PageReference(URL);
       }
       PageRef.setRedirect(true);
       return PageRef; 
    }
    
    
    /**************************************************************************    
    * To find all the Support Alert associated with the Case's Account
    **************************************************************************/
    public void findSupportAlert()
    {
        isSuppAlert = false;
        totalSuppAlert  =0;
        critSupportAlert =0;
 
        Date currDate = date.today();
             
        lstSupportAlert = new list<Support_Alert__c>();        
        lstSupportAlert = [Select id , Account__c,Critical__c, Critical_Flag__c, Description__c , Name, summary__c,end_date__c 
                            from Support_Alert__c where Account__c = :acctId    
                            AND (End_Date__c > : currDate OR End_Date__c =null) limit 200 ];

        if(!(lstSupportAlert.isEmpty()))
        {
            totalSuppAlert = lstSupportAlert.size();
            isSuppAlert = true;
            for(integer i=0;i<lstSupportAlert.size();i++)
            {                
                if(lstSupportAlert[i].Critical__c ==true)
                {
                    critSupportAlert += 1;
                                        
                }
                accSupportAlert = lstSupportAlert[i].Account__c;
                
            }
        }

        list<Account> lstAccount = new list<Account>();
        lstAccount = [select Name,id from Account where id=: accSupportAlert limit 1];
        
        if(!(lstAccount.isEmpty()))
        {
            for(Integer i=0;i<lstAccount.size();i++)
            {
                acctName =  lstAccount[i].Name;
            }
        //NEEDED???    
        //DAR - 23 Mar 2011 - Added to try to see Account without Support Alerts
        } else {
            //list<Account> lstTempAccount = new list<Account>();
            lstAccount = [SELECT Name, Id FROM Account WHERE Id = :AcctId LIMIT 1];
               
            if (!(lstAccount.isEmpty()))
            {               
                acctName = lstAccount[0].Name;
            }
        }          
        
        if(totalSuppAlert  > 0)
            isSuppAlert = true;
       
        lstSupportAlert = getLstSupportAlert();

    }

/***********************************************************************************
    * This method is used to pre-populate the corresponding NMC Account, Account 
      or Contact when a new Case is created from the respective object's record.
************************************************************************************/
    public PageReference findRec()
    {
       String NMCAccoutId = Apexpages.currentPage().getParameters().get('NMCAccountId');
       String ContactId = Apexpages.currentPage().getParameters().get('ContactId');
       String AccntId = Apexpages.currentPage().getParameters().get('AccountId');
       String RecTypeId = ApexPages.currentPage().getParameters().get('RecordType');
       String URL1 ='';String finalURL ='';

       NMC_Account__c NMCAcct = new NMC_Account__c();

       if(NMCAccoutId != null && NMCAccoutId != '')
       {
          NMCAcct = [Select Id, Name, Customer_Interface__c, Account__r.Name, Account__r.Id, Account__c 
            From NMC_Account__c where id = :NMCAccoutId limit 1]; 
          
          NMCAcct.Name = EncodingUtil.urlEncode(NMCAcct.Name , 'UTF-8');          
          NMCAcct.Account__r.Name = EncodingUtil.urlEncode(NMCAcct.Account__r.Name , 'UTF-8');
          
          String AcctId = NMCAcct.Account__r.Id;
          
          AcctId = AcctId.substring(0,15);
          URL1 = '&CF00N50000001cc33='+NMCAcct.Name+'&CF00N50000001cc33_lkid='+NMCAccoutId+'&cas4='+NMCAcct.Account__r.Name+'&cas4_lkid='+AcctId+'&00N50000001KkqR='+NMCAcct.Customer_Interface__c+'&cas7=Open&00N50000001Kkos=In Progress';
         
          if(NMCAcct  != null)
          finalURL = '/setup/ui/recordtypeselect.jsp?ent=Case&retURL=%2F500%2Fo&save_new_url=%2F500%2Fe%3FretURL%3D%252F500%252Fo'+URL1;
       }
       
       else if(ContactId  != null && ContactId!= '')
       {
           
           Contact Cnt = [Select Account.Name, Account.Id, AccountId , name from Contact where Id = : ContactId  limit 1];
           
           if(Cnt.Account.Name!= null)
               Cnt.Account.Name = EncodingUtil.urlEncode(Cnt.Account.Name , 'UTF-8');
           
           String cntName = EncodingUtil.urlEncode(Cnt.Name , 'UTF-8');
           
           String ContAcctId ='';
           if(Cnt.Account.Name!= null)
           {   
               
               ContAcctId = Cnt.Account.Id;
               ContAcctId = ContAcctId.substring(0,15);
           }
           
           URL1 = '&cas4='+Cnt.Account.Name+'&cas4_lkid='+ContAcctId +'&cas3='+cntName+'&cas3_lkid='+ContactId +argList;
           finalURL =  '/setup/ui/recordtypeselect.jsp?ent=Case&retURL=%2F500%2Fo&save_new_url=%2F500%2Fe%3FretURL%3D%252F500%252Fo'+URL1;
       }else if(AccntId != null && AccntId != ''){
           Account Acct = [Select id , name from Account where id =:AccntId  limit 1 ];
           Acct.Name = EncodingUtil.urlEncode(Acct.Name , 'UTF-8');
           URL1 = '&cas4='+Acct.Name+'&cas4_lkid='+AccntId +argList;
           finalURL =  '/setup/ui/recordtypeselect.jsp?ent=Case&retURL=%2F500%2Fo&save_new_url=%2F500%2Fe%3FretURL%3D%252F500%252Fo'+URL1;
       }
       
       PageReference PageRef = new PageReference(finalURL);
       PageRef.setRedirect(true);
       
       return PageRef; 
    }

/*************************************************************************
    this method will redirect the User the Case Edit Page
************************************************************************/    
    public PageReference redirectionOnEdit()
    {
        currCase =  (Case) controller.getRecord();
        caseRecType = Apexpages.currentPage().getParameters().get('RecordType');
        if(caseRecType ==null || caseRecType== 'null' )
        {
            caseRecType = currCase.recordtypeId;
        }
        
        String URL ='';
        currCase.recordtypeid = caseRecType;
        if (showSupportAlerts() == false)
        {           
             URL = '/'+currCase.Id+'/e?retURL='+currCase.Id+'&nooverride=1&RecordType='+caseRecType;
        }else{  
            URL = '/apex/CallCenterCase?Id='+currCase.Id+'&RecordType='+caseRecType;
        }
        
        PageReference PageRef = new PageReference(URL);
        PageRef.setRedirect(true);
        
        return PageRef; 
    }
    
/***************************************************************************
    * This method will find the corresponding Account when Contact is eneterd
        by the User.
***************************************************************************/
    public void findRelAccount()
    {

        Contact cont = new Contact();
        if(contId != null && contId.trim() != '')
        {
            try
            {
                cont = [SELECT id , AccountId FROM Contact WHERE id = :contId limit 1];
            }
            catch(Exception e)
            {
                system.debug('Exception in querying Contact:'+e);
                acctId = null;
                currCase.AccountId = null;
                acctName='';
                
            }
             
        }
      
        if(cont.AccountId != null)
        {
            acctId = cont.AccountId;
            currCase.ContactId = cont.Id;
            findSupportAlert();
            currCase.AccountId = cont.AccountId;  
        }

    }
    
    
    public Boolean testTemplate(String recType)
    {
        caseRecType = recType;
        return showSupportAlerts();
    }
    
    public void findCase(String templateID)
    {
        list<Template__c> newtemplate = [select name,NumTotal__c from template__c where id=:templateID];
        templateDetailList = [Select Id,Name,Value__c from TemplateDetail__c Where TemplateId__c =:templateID];
        for(Integer i=0;i<templateDetailList.size();i++)
        {
            String fieldAPI = templateDetailList[i].Name;
            //currCase.templateDetailList[i].Name = templateDetailList[i].Value__c;
            currCase.put(templateDetailList[i].Name,templateDetailList[i].Value__c);
            templateDetailList[i].Value__c = EncodingUtil.urlEncode(templateDetailList[i].Value__c , 'UTF-8');
        }
        
       // argList = 
    }
    
}