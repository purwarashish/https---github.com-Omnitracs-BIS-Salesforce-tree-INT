/**
 * @description The modeler class for CaseSubmission, CaseConfirmation and
 * CaseReview pages.
 * @date Sep 19, 2011
 */
public class CaseSubmissionModeler
{    
    /**
     * @description This object shall never be initialized by the code in the class.
     * This object would be populated by the MainController via a setter method.
     */
    private CaseCacheManager caseCache;

    private QESUnityWebServicesClientManager wsClientManager = null;
    
    private List<QESUnityTopArticle> topArticlesList;

    private List<QESUnityTopArticle> suggestedSolutionsList;

    public List<QESUnityTopArticle> getSuggestedSolutionsList() {
        updateSuggestedSolutionsList();
        return suggestedSolutionsList;
    }
    
    public List<QESUnityTopArticle> getTopArticlesList() {
        if(null == topArticlesList) {
            if(null == wsClientManager) {
                wsClientManager = new QESUnityWebServicesClientManager(0);
            }         
            topArticlesList = wsClientManager.getTopArticlesList(5, null);
        }
        
        return topArticlesList;
    }
    
    /**
     * @description Setter method for the caseCache
     * @param ccm An object of the CaseCacheManager class
     */
    public void setCaseCache(CaseCacheManager ccm) {
        caseCache = ccm;
    }

    /**
     * @description An object of List<SelectOption>
     */    
    public List<Selectoption> lstSelectedOptions {get; set;} {lstSelectedOptions = new List<Selectoption>();}
    
    /**
     * @description The default constructor. Does nothing.
     */    
    public CaseSubmissionModeler()
    {
    }

    /**
     * @description The parametrized constructor. It calls the method, refreshInitializationData()
     */    
    public CaseSubmissionModeler(CaseCacheManager ccm)
    {
        caseCache = ccm;
        refreshInitializationData();
    }
    
    /**
     * @description An object of Case
     */
    public Case tempCase {get;set;} {tempCase = new Case();}

    /**
     * @description An object of Case
     */
    public Case cloneCase;

    /**
     * @description An object of String
     */
    public String caseid;

    /**
     * @description An object of String
     */
    public String editAction {get; set;} {editAction='Edit';}

    /**
     * @description An object of String
     */
    public String caseSubject {get; set;}

    /**
     * @description An object of String
     */
    public String strSuggestedSolutions {get;set;}

    /**
     * @description An object of List<Case>
     */
    public List<Case> RecentCase {get;set;}

    /**
     * @description An object of List<String>
     */
    public List<String> preferredConVal{get;set;}

    /**
     * @description An object of String
     */
    public String tempSubject {get;set;}

    /**
     * @description An object of String
     */
    public String strFirstLinkId {get;set;}

    /**
     * @description An object of String
     */
    public String strSecondLinkId {get;set;}

    /**
     * @description An object of String
     */
    public String strThirdLinkId {get;set;}

    /**
     * @description An object of String
     */
    public String strFourthLinkId {get;set;}

    /**
     * @description An object of String
     */
    public String strFifthLinkId {get;set;}
    
    public String hiddenInputField {get; set;} {hiddenInputField = '';}

    public void updateCaseCreationAllowed(Boolean allowed) {
        caseCreationAllowed = allowed;
    }
    
    /**
     * @description Method to stores the subject of the case to a String variable
     * called tempSubject.
     */
    public Pagereference getSubject()
    {
        tempSubject = tempCase.Subject;
        return null;
    }

    /**
     * @description Method to refresh the initialization data for the CaseSubmissionModeler
     * whenever a page loads that makes use of the CaseSubmissionModeler.
     */
    public void refreshInitializationData() {
        caseCreationAllowed = false;
        if(lstSelectedOptions!=null) 
        {
            lstSelectedOptions.add(new SelectOption('Email','Email'));
            lstSelectedOptions.add(new SelectOption('Phone','Phone'));
        }

        if( !Apexpages.currentPage().getURL().contains('supportcasesubmit') &&
            (Apexpages.currentPage().getParameters().get('id') != null) &&
            (Apexpages.currentPage().getParameters().get('id') != '') )
        {               
            List<Case> lst = new List<Case>();
            caseid = Apexpages.currentPage().getParameters().get('id');
            lst = [
                    SELECT 
                        Platform__c,
                        Application__c,
                        Origin, 
                        CaseNumber,
                        subject, 
                        QES_Unity_CP_Phone__c, 
                        description, 
                        Contract_Product__c,
                        Serial__c, 
                        Resolution__c, 
                        type, ContactId, 
                        status,PCMEmail__c,
                        PCMPhone__c 
                    FROM 
                        Case 
                    WHERE 
                        Id = :caseid 
                    LIMIT
                        1
                  ];
            if (lst != null && lst.size() > 0)
            {
                cloneCase = lst[0];
                tempCase.Subject = cloneCase.Subject;
                tempCase.description = cloneCase.description;
                tempCase.type = cloneCase.type;
                tempCase.Contract_Product__c = cloneCase.Contract_Product__c;
                tempCase.status = cloneCase.status;
                tempCase.Serial__c = cloneCase.Serial__c;
                tempCase.Resolution__c = cloneCase.Resolution__c;
                tempCase.PCMEmail__c = cloneCase.PCMEmail__c;
                tempCase.PCMPhone__c = cloneCase.PCMPhone__c;
                tempCase.QES_Unity_CP_Phone__c = cloneCase.QES_Unity_CP_Phone__c;
                tempCase.Origin= cloneCase.Origin;
                tempCase.Application__c= cloneCase.Application__c;
                tempCase.Platform__c= cloneCase.Platform__c;
                caseCache.updateCaseCache(cloneCase);                       
            }
        }
    }

    /**
     * @description Method to show the list of recent cases.
     */
    public PageReference displayrecentCase()
    {
        List<User> userList = [SELECT Id, ContactId FROM User where Id = :UserInfo.getUserId() LIMIT 1];
        String linkedContactId = userList.size() > 0 ? userList[0].ContactId : '';
        RecentCase = new List<Case>();
        RecentCase = [
                        Select 
                            Id,
                            CaseNumber,
                            Subject,
                            PreferredContactMethodField__c,
                            Origin 
                        FROM 
                            Case 
                        WHERE 
                            ContactId = :linkedContactId
                        AND 
                            Subject <> 'Customer Portal Feedback' 
                        AND 
                            Origin = 'Customer Portal' 
                        Order By 
                            CreatedDate DESC  
                        LIMIT 5 
                    ] ;
    
        if(RecentCase!= null && RecentCase.size() > 0)
            strFirstLinkId = ''+ RecentCase[0].id;
    
        if(RecentCase!= null && RecentCase.size() > 1)
            strSecondLinkId = ''+ RecentCase[1].id;
    
        if(RecentCase!= null && RecentCase.size() > 2)
            strThirdLinkId = ''+ RecentCase[2].id;
    
        if(RecentCase!= null && RecentCase.size() > 3)
            strFourthLinkId = ''+ RecentCase[3].id;
    
        if(RecentCase!= null && RecentCase.size() > 4)
            strFifthLinkId = ''+ RecentCase[4].id;
    
        if (caseId != null)
        {
            caseSubject = tempCase.Subject;
        }
        if(RecentCase.size()!=0)
        {
            if(RecentCase[0].PreferredContactMethodField__c != null)
            {
                preferredConVal=RecentCase[0].PreferredContactMethodField__c.split(',');
                for(integer i=0; i < preferredConVal.size(); i++)
                {
                    if(preferredConVal[i] == 'null')
                    {
                         preferredConVal.remove(i);
                    }
                }
            }
        }
        tempCase.PCMEmail__c = true;
        return null;
    }    

    /**
     * @description An object of List<String>
     */
    public List<String> options {get; set; } {options = new List<String>();}

    /**
     * @description Method to save the case, if there are suggested solutions
     */
    public PageReference customSave1()
    {
        String retURL = Apexpages.CurrentPage().getParameters().get('retURL');
        if(tempCase.Platform__c == null && tempCase.Application__c == null)
        {
             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select a Platform and/or Application');
             ApexPages.addMessage(msg);
             return null;
        }
        else if(tempCase.PCMPhone__c == true && (tempCase.QES_Unity_CP_Phone__c == null || tempCase.QES_Unity_CP_Phone__c == ''))
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please enter the Phone Number');
            ApexPages.addMessage(msg);
            return null;
        }
        else
        {      
            Pagereference page1 = new Pagereference('/apex/supportcaseconfirm?subject='+tempCase.Subject+'&retURL='+retURL);
            page1.setRedirect(false);
            return page1;
        }
    }


    /**
     * @description Method to save the case, if suggested solutions are not present
     */
    public PageReference customSave()
    {
        if(!caseCreationAllowed) {
            return null;
        }

        List<Contact> lstContact = new List<Contact>() ; 
        List<User> lstUser = new List<user>(); 
        Contact caseContact = new Contact();
        User tempUser = new User();
        if(tempCase.Platform__c == null && tempCase.Application__c == null)
        {
             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select a Platform and/or Application');
             ApexPages.addMessage(msg);
             return null;
        }
        else if(tempCase.PCMPhone__c == true && (tempCase.QES_Unity_CP_Phone__c == null || tempCase.QES_Unity_CP_Phone__c == ''))
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please enter the Phone Number');
            ApexPages.addMessage(msg);
            return null;
        }
        
        else
        {                  
            for(String s:options)
            {
                tempCase.PreferredContactMethodField__c = s +' ,'+tempCase.PreferredContactMethodField__c;
            }
            lstUser = [select name, contactId, email, phone from User where Username = :Userinfo.getUserName()];
            if (lstUser.size() > 0)
            {
                tempUser = lstUser[0];
                
            }
            lstContact = [select name, email, phone,accountid from Contact where id = :tempUser.contactId limit 1];
    
            if (lstContact.size() > 0)
            {
                caseContact = lstContact[0];
                tempCase.ContactId = caseContact.Id;
                tempCase.AccountId = caseContact.accountid;
            }
            
            tempCase.Origin = 'Customer Portal';
            tempCase.Status = 'New - Unassigned';
            tempCase.Substatus__c = '';
            
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = true;//assignmentRuleID = '01Q50000000AQsC';
            dmlOpts.EmailHeader.triggerUserEmail = true; 
            tempCase.setOptions(dmlOpts); 

            insert tempCase;
            caseCache.updateCaseCache(tempCase);
                                            
            tempCase= [Select id,subject  from Case where id=:tempCase.Id limit 1];
            tempCase.subject = tempCase.subject+'';
            tempCase.setOptions(dmlOpts);
            update tempCase;                                 

            Pagereference page = new Pagereference('/apex/supportcasedetails?id='+tempCase.id+'&action=CaseSubmitted');
            page.setRedirect(false);
            return page;
        }
    }


    public boolean bln {get;set;} {bln=false;}
    public Pagereference dummy()
    {
        bln = true;
        return null;
    }

    /**
     * @description Method to view the page redirection
     */
    public PageReference viewRedirect()
    {
         String URL = '';
         if(UserInfo.getUserType() == 'CustomerSuccess' || UserInfo.getUserType() == 'PowerCustomerSuccess' || UserInfo.getUserType() == 'CspLitePortal')
             URL = '/apex/supportcasedetails?id='+caseid;
         else
             URL = '/'+caseid+'?nooverride=1';
         PageReference pageRef = new PageReference(URL);
         pageRef.setRedirect(false);
         return pageRef;
    }

    /**
     * @description Method to edit the page redirection
     */
    public PageReference editRedirect()
    {
         String URL = '';
         if(UserInfo.getUserType() == 'CustomerSuccess' || UserInfo.getUserType() == 'PowerCustomerSuccess' || UserInfo.getUserType() == 'CspLitePortal')
             URL = '/apex/CaseReviewEdit?id='+caseid;
         else
             URL = '/'+caseid+'/e?nooverride=1&retURL=/'+caseid+'?nooverride=1&cancelURL=/'+caseid+'?nooverride=1&saveURL=/'+caseid+'?nooverride=1';
         PageReference pageRef = new PageReference(URL);
         pageRef.setRedirect(false);
         return pageRef;
    }

    /**
     * @description Method to cancel the case
     */
    public PageReference customCancel()
    {
         Set<String> urlParams = ApexPages.CurrentPage().getParameters().keySet();
         
         String retURL = ApexPages.CurrentPage().getParameters().get('retURL');
         Integer count = 0;
         for(String param : urlParams) {
            System.debug('@@@@@@@@@@..param=' + param);
            if(param != 'id' &&
               param != 'type' &&
               param != 'name' &&
               param != 'docType' &&
               param != 'retDocType' &&
               param != 'prodType') {
                continue;
            }
            
            if(0 == count) {
                retURL = retURL + '?';
            }
            else {
                retURL = retURL + '&';
            }
            
            retURL = retURL + param + '=' + ApexPages.CurrentPage().getParameters().get(param);
            count++;
         }
         System.debug('@@@@@@@@@@@@@@@@@@@@.....' + retURL);
         PageReference pageRef = new PageReference(retURL);
         pageRef.setRedirect(false);
         return pageRef;
    }

    /**
     * @description Method to redirect to caselistviewrecentcases page
     */
     public PageReference redirectToCases()
     {
         PageReference pageRef = new PageReference('/apex/supportcases');
         pageRef.setRedirect(false);
         return pageRef;
     }

      public PageReference redirectToCaseDetail()
     {
        PageReference pg = new PageReference('/apex/supportcasedetails?id=' + hiddenInputField);
        pg.setRedirect(false);
        return pg;
    }
     public PageReference redirectToArticles()
     {
        PageReference pg = new PageReference(hiddenInputField);
        pg.setRedirect(false);
        return pg;
     }

    private Boolean caseCreationAllowed;
    
    private void updateSuggestedSolutionsList() {
        suggestedSolutionsList = new List<QESUnityTopArticle>();        
        String subject = '';
        if( (null == tempCase) || 
            (null == tempCase.Subject) ||
            ('' == tempCase.Subject) ||
            (1 == tempCase.Subject.length()) ) {
            if(null != caseCache) {
                Case cachedCase = caseCache.getCachedCase();
                if( (null == cachedCase.Subject) ||
                    ('' == cachedCase.Subject) ||
                    (1 == cachedCase.Subject.length()) ) {
                    return;
                }
                else {
                    subject = cachedCase.Subject + '*';
                }
            }
            else {
                return;
            }
        }
        else {
            subject = tempCase.subject + '*';
        }        
        
        SuggestedSolutionModeler ssm = new SuggestedSolutionModeler();
        suggestedSolutionsList = ssm.getSuggestedSolutions(subject);
    }
}