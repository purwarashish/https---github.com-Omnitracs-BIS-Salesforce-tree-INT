/**
 * @description The modeler class for CaseListViewRecentCases page.
 * @date Sep 19, 2011
 */
public class RecentCasesModeler
{
    /**
     * @description This object shall never be initialized by the code in the class.
     * This object would be populated by the MainController via a setter method.
     */
    private CaseCacheManager caseCache;
    
    private QESUnityWebServicesClientManager wsClientManager = null;
    
    private List<QESUnityTopArticle> topArticlesList;
    
    /**
     * @description Setter method for the caseCache
     * @param ccm An object of the CaseCacheManager class
     */
    public void setCaseCache(CaseCacheManager ccm) {
        caseCache = ccm;
    }

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
     * @description The default constructor. Does nothing.
     */
    public RecentCasesModeler()
    {
    }

    /**
     * @description The parametrized constructor. Does nothing.
     */
    public RecentCasesModeler(CaseCacheManager ccm)
    {
        caseCache = ccm;
        refreshInitializationData();
    }
    
    /**
     * @description An object of List<Case>
     */
    public List<Case> AllCases {get;set;}

    /**
     * @description An object of List<SelectOption>
     */
    public List<Selectoption> lstSelectedOptions {get; set;} {lstSelectedOptions = new List<Selectoption>();}

    /**
     * @description An object of List<String>
     */
    public List<String> options {get; set; } {options = new List<String>();}

    /**
     * @description An object of String
     */
    public string abc {get;set;}

    /**
     * @description An object of Case
     */
    public Case currentCase {get; set;} {currentCase = null;}

    /**
     * @description An object of String
     */
    public String caseSubject {get; set;}

    /**
     * @description An object of List<Case>
     */
    public List<Case> AllOpenCases =  new List<Case>();

    /**
     * @description An object of List<Case>
     */
    public List<Case> AllClosedCases =  new List<Case>();

    /**
     * @description An object of List<Case>
     */
    public List<Case> RecentCases {get; set;}

    /**
     * @description An object of String
     */
    public String ErrorMsg {get;set;}

    /**
     * @description An object of Boolean
     */
    public Boolean ShowErrorMsg {get;set;}

    /**
     * @description An object of Boolean
     */
    public Boolean ShowTable {get;set;}
    
    public String hiddenInputField {get; set;} {hiddenInputField = '';}

    /**
     * @description Method to refresh the initialization data for the RecentCasesModeler
     * whenever a page loads that makes use of the RecentCasesModeler.
     */
    public void refreshInitializationData()
    {
        lstSelectedOptions.add(new SelectOption('Email','Email'));
        lstSelectedOptions.add(new SelectOption('Phone','Phone'));
        
        if(null == wsClientManager) {
            wsClientManager = new QESUnityWebServicesClientManager(0);
        }        
    }

    /**
     * @description Method to let the page display the different views of the case list
     */
    public List<SelectOption> getCaseViews() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All Cases','All Cases'));
        options.add(new SelectOption('All Open Cases','All Open Cases'));
        options.add(new SelectOption('All Closed Cases','All Closed Cases'));
        return options;
    }

    /**
     * @description Method to show the list of recent cases.
     */
    public PageReference displayrecentCase()
    {
        ShowErrorMsg = false;
        ShowTable = true;
        AllCases = new List<Case>();
        RecentCases = new List<Case>();
        AllCases.clear();
        AllClosedCases.clear();
        AllOpenCases.clear();

//DAR - 20 Dec 2011 - Modified following code to find user...  and then use user to find proper cases
        List<User> userList = [SELECT Id, ContactId FROM User where Id = :UserInfo.getUserId() LIMIT 1];
        String linkedContactId = userList.size() > 0 ? userList[0].ContactId : '';

//DAR - 20 Dec 2011 - modified SELECT 
//NOTE - THIS NEEDS TO PULL CASES WHERE THE CUSTOMER PORTAL USER OF THE CONTACT ASSOCIATED WITH THE CASE = CURRENT USER
        //AllCases = [Select Id,CaseNumber,Subject,Status,Account.name,Contact.Account.name,ClosedDate,CreatedDate,IsClosed from Case where CreatedById =:UserInfo.getUserId() AND Subject <> 'Customer Portal Feedback' Order By CreatedDate DESC limit 1000 ] ;
        if(!Test.isRunningTest() || (Test.isRunningTest() && linkedContactId != null))
        {
        AllCases = [Select Id, CaseNumber, Subject, Status, Account.name, Contact.Account.name, ClosedDate, CreatedDate, IsClosed, Origin from Case where ContactId = :linkedContactId AND Subject <> 'Customer Portal Feedback' AND Origin = 'Customer Portal' Order By CaseNumber DESC limit 1000] ;
        
        if('' != caseCache.getCachedCaseNumber()){
            caseSubject = caseCache.getCachedCase().Subject;
        }

        RecentCases = [Select Id, CaseNumber, Subject, PreferredContactMethodField__c, Origin FROM Case WHERE ContactId = :linkedContactId AND Subject <> 'Customer Portal Feedback' AND Origin = 'Customer Portal' Order By CreatedDate DESC LIMIT 5] ;
        }
        if(abc == 'All Open Cases')
        {
            for(Case temp : AllCases)
            {
               //if(temp.status == 'Open')
                if(temp.IsClosed == false || temp.ClosedDate == null)
                {
                   AllOpenCases.add(temp);
                }
            }
            if(AllOpenCases.size()>0)
            {
                AllCases.clear();
                for(Case tempopen : AllOpenCases)
                {
                    AllCases.add(tempopen);
                }
            }
            else
            {
                ErrorMsg  = 'No records were found matching your selection';
                ShowErrorMsg = true;
                ShowTable = false ;
            }
        }
        else
        {
            if(abc == 'All Closed Cases')
            {
                system.debug( '---------abc ' + abc  );
                system.debug('closed cases');
                for(Case temp : AllCases)
                {
                    system.debug(temp.IsClosed +' ------- closed status ------'+ temp.status);
                    if(temp.IsClosed == true || temp.ClosedDate != null )
                    {
                        system.debug('--------- Closed--------');
                        AllClosedCases.add(temp);
                    }
                }
                if(AllClosedCases.size()>0)
                {
                    AllCases.clear();
                    for(Case tempclosed : AllClosedCases)
                    {
                        AllCases.add(tempclosed);
                    }
                }
                else
                {
                    ErrorMsg  = 'No records were found matching your selection';
                    ShowErrorMsg = true;
                    ShowTable = false;
                }
            }
        }
        return null;
    }

    public PageReference redirectToCaseDetail() {
        PageReference pg = new PageReference('/apex/supportcasedetails?id=' + hiddenInputField);
        pg.setRedirect(false);
        return pg;
    }
    public PageReference redirectToArticles()
     {
        PageReference pg = new PageReference('/apex/' + hiddenInputField);
        pg.setRedirect(false);
        return pg;
     }

    private List<QESUnityTopArticle> suggestedSolutionsList;     
    private void updateSuggestedSolutionsList() {
        suggestedSolutionsList = new List<QESUnityTopArticle>();        
        String subject = '';

        if(null != caseCache){
            Case cachedCase = caseCache.getCachedCase();
            if((null == cachedCase.Subject) || ('' == cachedCase.Subject) || (1 == cachedCase.Subject.length()) ) {
                return;
            }else{
                subject = cachedCase.Subject + '*';
            }
        }else{
            return;
        }
        
        SuggestedSolutionModeler ssm = new SuggestedSolutionModeler();
        suggestedSolutionsList = ssm.getSuggestedSolutions(subject);
    }     
}