/**
 * @description The main-controller class that would be used for all the pages.
 * This class contains objects of all the modelers.
 * Note: Only 1 modeler would be alive at a time. If we are on
 * VFPage1, only modeler1 would have a valid reference and modeler2
 * will be NULL.
 * Acronyms: Object names are named conveniently as per the parent class name
 * If the parent class name is PlatformAppModeler, the object name is 'pam'
 * If the class name is CaseSubmissionModeler, the object name is 'csm'
 * and so on...
 * @author Pratyush Kumar
 * @date Sep 16, 2011
 */
public class MainController
{
    /* TODO Remove the following 2 variables - Currently being used for Testing */
    public integer count {get; set;} {count=0;}    
    public integer i {get; set;}
    public string standalone {get; set;}
    /**
     * An object of CaseCacheManager that will act as a cache for the last case viewed by the user
     */
    public CaseCacheManager caseCache;
    
    /**
     * @description Footer Year String
     */
    public String footerYearString {get; set;}
     
    /**
     * @description An object of QESUnityWebServicesClientManager
     */
    public QESUnityWebServicesClientManager wscm {get; set;}
    
    /**
     * @description An object of PlatformAppModeler
     */
    public PlatformAppModeler pam {get; set;}

    /**
     * @description An object of CaseSubmissionModeler
     */
    public CaseSubmissionModeler csm {get; set;}

    /**
     * @description An object of QESPKBModeler
     */
    public QESPKBModeler qpm {get; set;}

    /**
     * @description An object of RecentCasesModeler
     */
    public RecentCasesModeler rcm {get; set;}

    /**
     * @description An object of ArticleModeler
     */
    public ArticleModeler arm {get; set;}

    /**
     * @description An object of ArticleModeler
     */
    public GlobalSearchModeler gsm {get; set;}

    /**
     * @description An object of ContentVersionModeler
     */
    public ContentVersionModeler cvm {get; set;}

    /**
     * @description An object of ContentVersionModeler
     */
    public TrainingPagesModeler tpm {get; set;}

    /**
     * @description An object of ContentVersionModeler
     */
    public ProductDocumentationModeler pdm {get; set;}

    /**
     * @description An object of NewFeaturesModeler
     */
    public NewFeaturesModeler nfm {get; set;}
    
    /**
     *@description String variable to store global search Keyword
     */
    public String searchText {get; set;}  
    
    /**
     * @description Domain name used for the cookie
     */
    public String cookieDomainName {get; set;}  
    
    public String hiddenInputField {get; set;} {hiddenInputField = '';}
    
    /**
     * @description The default constructor.
     */
    public MainController()
    {
        // TODO Remove the following line
        i = 100;
        
        standalone = ApexPages.currentPage().getParameters().get('mode');
        standalone = (String.isNotBlank(standalone) && standalone=='standalone')?'1':standalone;
        System.debug('*************** standalone - '+standalone);
        if(String.isBlank(standalone)){
        	Cookie saCookie = ApexPages.currentPage().getCookies().get('CPStandAlone');
        	if(saCookie != null){
        		standalone = saCookie.getValue();
        	}
        }
        else{
        	Cookie saCookie = new Cookie('CPStandAlone', standalone,null,-1,false);
        	ApexPages.currentPage().setCookies(new Cookie[]{saCookie});
        	System.debug('*************** standalone - '+standalone);
        }
        
        caseCache = new CaseCacheManager();
        
        // Reset all the models
        resetAllModels();
        
        // Instantiate the WebServices Client Manager 
        wscm = new QESUnityWebServicesClientManager();
        setBoolCaseCreationPermission(wscm.getUserType());
        
        Integer currentYear = System.now().year();
        if(COPYRIGHT_START_YEAR >= currentYear) {
            footerYearString = '' + COPYRIGHT_START_YEAR;
        }
        else {
            footerYearString = '' + COPYRIGHT_START_YEAR + '-' + currentYear;
        }       
        
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=Edge');         
    }
    

    /**
     * @description Getter method to fetch the instance of the cached-case
     * @returns Case Object of cached object of Case
     */
    public Case getCachedCase() {
        return caseCache.getCachedCase();
    }
    
    /**
     * @description Getter method to fetch the instance of the cached CaseNumber
     * @returns String The cached case-number
     */
    public String getCachedCaseNumber() {
        return caseCache.getCachedCaseNumber();
    }    
    
    /**
     * @description The singleton method for initializing PlatformAppModeler.
     * The method is called whenever the VF page 'platformapp' loads.
     */
    public void pam_initSingleton()
    {
        i++;
        wscm.refreshInitializationData();
        searchText = 'Search Support';
        if(null == pam)
        {
            resetAllModels();
            pam = new PlatformAppModeler();
        }
        else {
            pam.refreshInitializationData();
        }
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }

    /**
     * @description The singleton method for initializing CaseSubmissionModeler.
     * The method is called whenever the VF pages 'CaseSubmission', 'CaseConfirmation',
     * 'CaseReview' load.
     */
    public void csm_initSingleton()
    {
        i++;
        wscm.refreshInitializationData();
        searchText = 'Search Support';        
        if(null == csm)
        {
            resetAllModels();
            csm = new CaseSubmissionModeler(caseCache);
        }
        else {
            csm.setCaseCache(caseCache);
            csm.refreshInitializationData();
        }
        csm.updateCaseCreationAllowed(caseCreationAllowed);        
        csm.displayrecentCase();
        
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }

    /**
     * @description The singleton method for initializing QESPKBModeler.
     * The method is called whenever the VF page 'searchunity' loads.
     */
    public void qpm_initSingleton()
    {
        i++;
        wscm.refreshInitializationData();
        searchText = 'Search Support';
        if(null == qpm)
        {
            resetAllModels();
            qpm = new QESPKBModeler();
            qpm.initListPKBCategoryGroups();
        }
        else {
            qpm.refreshInitializationData(false);
            qpm.initListPKBCategoryGroups();
            qpm.refreshInitializationData(true);
        }
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }

    /**
     * @description The singleton method for initializing QESPKBModeler.
     * The method is called whenever the VF page 'searchunity' loads.
     */
    public void qpm_initSupportLandingSingleton()
    {
        i++;
        wscm.refreshInitializationData();
        searchText = 'Search Support';
        if(null == qpm)
        {
            resetAllModels();
            qpm = new QESPKBModeler(true);
        }
        else {
            qpm.refreshInitializationData(true);
            qpm.refreshInitializationData(false);
        }
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }

    /**
     * @description The singleton method for initializing PlatformAppModeler.
     * The method is called whenever the VF page 'CaseListViewRecentCases' loads.
     */
    public void rcm_initSingleton()
    {
        i++;
        wscm.refreshInitializationData();
        searchText = 'Search Support';
        if(null == rcm)
        {
            resetAllModels();
            rcm = new RecentCasesModeler();
            rcm.setCaseCache(caseCache);
        }
        else {
            rcm.setCaseCache(caseCache);
            rcm.refreshInitializationData();
        }
        rcm.displayrecentCase();
        
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }

    /**
     * @description The singleton method for initializing ArticleModeler.
     * The method is called whenever a VF page displaying an article loads.
     */
    public void arm_initSingleton()
    {
        i++;
        wscm.refreshInitializationData();
        searchText = 'Search Support';
        if(null == arm)
        {
            resetAllModels();
            arm = new ArticleModeler();
        }
        else {
            arm.refreshInitializationData();
        }
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }

    /**
     * @description The singleton method for initializing GlobalSearchModeler.
     * The method is called whenever a VF page displaying the 
     * global search-results loads.
     */
    public void gsm_initSingleton()
    {
        i++;
        wscm.refreshInitializationData();
        if(null == gsm)
        {
            resetAllModels();
            gsm = new GlobalSearchModeler();
        }
        else {
            gsm.refreshInitializationData();
        }
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }

    /**
     * @description The singleton method for initializing ContentVersionModeler.
     * The method is called whenever a VF page displaying a Content's details loads.
     */
    public void cvm_initSingleton()
    {
        i++;
        wscm.refreshInitializationData();
        searchText = 'Search Support';
        if(null == cvm)
        {
            resetAllModels();
            cvm = new ContentVersionModeler();
        }
        else {
            cvm.refreshInitializationData();
        }
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }

    /**
     * @description The singleton method for initializing ContentVersionModeler.
     * The method is called whenever a VF page displaying a Content's details loads.
     */
    public void nfm_initSingleton()
    {
        wscm.refreshInitializationData();
        searchText = 'Search Support';
        if(null == nfm)
        {
            resetAllModels();
            nfm = new NewFeaturesModeler();
        }
        else {
            nfm.refreshInitializationData();
        }
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }
    
    /**
     * @description The singleton method for initializing ProductDocumentationModeler.
     * The method is called whenever a VF page displaying the ProductDocumentations loads.
     */
    public void pdm_initSingleton()
    {
        i++;
        wscm.refreshInitializationData();
        searchText = 'Search Support';        
        resetAllModels();
        pdm = new ProductDocumentationModeler();
        
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }

    /**
     * @description The singleton method for initializing TrainingPagesModeler.
     * The method is called whenever the VF page displaying all the Training data loads.
     */
    public void tpm_initSingleton()
    {
        i++;
        wscm.refreshInitializationData();
        searchText = 'Search Support';
        
        if(null == tpm)
        {
            resetAllModels();
            tpm = new TrainingPagesModeler();
        }
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }
    
    public Boolean getCaseCreationAllowed() {
        return caseCreationAllowed;
    }
    
    /**
     * @description This method is used for navigation during the GlobalSearch
     * @return PageReference Page Reference to GlobalSearch Results Page
     */
    public PageReference globalSearchRedirectTo()
    {              
        if( (null == searchText) ||
            ('' == searchText) ||
            ('Search Support' == searchText) ) {
            searchText = 'Search Support';
            return null;
        }
        if(1 == searchText.length()) {
            return null;
        }
        PageReference pg = new PageReference('/apex/supportsearch?searchText='+searchText);       
        pg.setRedirect(false);
        return pg;
        
    }    
      
    /**
     * @description This method is used to menu navigation
     * @return PageReference Page Reference to the corresponding Menu-URL
     */
    public PageReference menuHeaderRedirectTo()
    {
        // Create the page reference and redirect
        PageReference pg = new PageReference(hiddenInputField);
        pg.setRedirect(false);
        return pg;
    }    
    
    
    /*------------------------------ PRIVATE MEMBERS ------------------------*/
    
    /**
     * @description Copyright start Year
     * modified as part of CP Rebranding Requirement
     */
    private final Integer COPYRIGHT_START_YEAR = 2013;
    
    /**
     * @description Constant String that contains 
     * the URL of the GlobalSearchResults page
     */
    private final String GLOBAL_SEARCH_URL = '/apex/supportsearch';

    /**
     * @description Method for clearing all the models
     */
    private void resetAllModels() {
        pam = null;
        csm = null;
        qpm = null;
        rcm = null;
        arm = null;
        gsm = null;
        cvm = null;
        tpm = null;
        pdm = null;
        nfm = null;
    }     

    private Boolean caseCreationAllowed;
    private String userType;
    
    private final String SYS_ADMIN_PROFILE_ID = '00e50000000mzNu';
    private final String QES_DELEGATED_ADMIN_PROFILE_ID = '00e50000000owzT';

    private void setBoolCaseCreationPermission(String userType) {
        caseCreationAllowed = false;
    
        // If it is SysAdmin or QES Delegated Admin Profile, provide them the access
        if( (SYS_ADMIN_PROFILE_ID == UserInfo.getProfileId().substring(0, 15)) || 
            (QES_DELEGATED_ADMIN_PROFILE_ID == UserInfo.getProfileId().substring(0, 15)) ) {
            caseCreationAllowed = true;
            return;
        }
        
        List<SupportSiteCaseCreationUserType__c> allowedUserTypes = 
                                                    [
                                                        SELECT
                                                            Name,
                                                            UserType__c,
                                                            Allow_to_Create_Cases__c
                                                        FROM
                                                            SupportSiteCaseCreationUserType__c
                                                        WHERE
                                                            Allow_to_Create_Cases__c = true
                                                        LIMIT
                                                            100
                                                    ];
        if( (null != allowedUserTypes) ) {
            for(SupportSiteCaseCreationUserType__c tmpUserType : allowedUserTypes) {
                if( userType == tmpUserType.UserType__c ) {
                    caseCreationAllowed = tmpUserType.Allow_to_Create_Cases__c;
                    break;
                }
            }
        }                       
    }          
}