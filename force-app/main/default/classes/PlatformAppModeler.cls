/**
 * @description The modeler class for PlatformApp page.
 * Extends the KnowledgeController class.
 * @date Sep 19, 2011
 */
public class PlatformAppModeler extends KnowledgeController
{
    /**
     * @description An object of List<String>
     */
    public List<String> lstString = new List<String>();

    /**
     * @description An object of List<Application__c>
     */
    public List<Application__c> lstApplication;

    /**
     * @description An object of List<Platform__c>
     */
    public List<Platform__c> lstPlatform;

    /**
     * @description An object of List<Attachment>
     */
    public List<Attachment> lstAttachment = new List<Attachment>();

    /**
     * @description An object of List<SelectOption>
     */
    public List<SelectOption> lstAllPlatformsAndApps {get;set;}

    /**
     * @description An object of List<Application__c>
     */
    public List<Application__c> lstAllApplications;

    /**
     * @description An object of List<Platform__c>
     */
    public List<Platform__c> lstAllPlatforms;

    /**
     * @description An object of List<Platform_Application_Junction__c>
     */
    public List<Platform_Application_Junction__c> lstTopPlatformsOrApps  {get;set;}

    /**
     * @description An object of List<SelectOption>
     */
    public List<SelectOption> lstTopPlatformsOrAppsSelected {get;set;}

    /**
     * @description An object of Integer
     */
    public integer intTopPlatformsOrAppsSelected {get; set;}

    /**
     * @description An object of String
     */
    public String strServiceOptionPicklistValue {get; set;}

    /**
     * @description An object of String
     */
    public String strBrowseSupportPicklistValue {get; set;}

    /**
     * @description An object of Attachment
     */
    public Attachment imageAttachment {get; set;}

    /**
     * @description An object of Platform__c
     */
    public Platform__c platform {get; set;}

    /**
     * @description An object of Application__c
     */
    public Application__c application {get; set;}

    /**
     * @description An object of Boolean
     */
    public boolean blntest {get;set;}

    /**
     * @description An object of Boolean
     */
    public boolean blnPlatform {get;set;}

    /**
     * @description An object of Boolean
     */
    public boolean blnApplication {get;set;}

    /**
     * @description An object of String
     */
    public String strName {get;set;}

    /**
     * @description An object of List<Platform_Application_Junction__c>
     */
    public List<Platform_Application_Junction__c> lstTop4PlatsOrApps  {get;set;}

    /**
     * @description List of top support questions for a product/app
     */
     public List<QESUnityTopArticle> topArticlesList {get; set;}
     
    /**
    * CR 83883
    * @description List of top documents for a product/app
    */
     public List<QESUnityTopArticle> topDocumentList {get; set;}

    /**
     *
     */
    public String trainingLinkGuid {get; set;}
    
    /**
     *
     */
    public QESUnityWebServicesClientManager wscm {get; set;} 
    
    /**
     * @description A hidden input-field used for redirection/navigation
     */
    public String hiddenInputField {get; set;} {hiddenInputField = '';}
         
    /**
     * @description The default constructor
     */
    public PlatformAppModeler ()
    {
        strName = Apexpages.currentPage().getParameters().get('name');
        refreshInitializationData();
    }
    
    /**
     * @description Platform or App Name
     */
    public String platformAppName {get; set;}
    
    /**
     * @description Parametrized constructor - To be used by classes which do not
     * need all the information fetched by the PlatformAppModeler. Just an attempt
     * to override the default behavior.
     * @param String platformAppName - The name of the Platform/App for which you are
     * instantiating this object. Can be 'null' as well.
     */
    public PlatformAppModeler(String platformAppName) {
        strName = platformAppName;
        refreshInitializationData();
    }

     public void refreshInitializationData() {
        // Initializations
        wscm = new QESUnityWebServicesClientManager(-1);
        intTopPlatformsOrAppsSelected = 0;
        blntest = false;
        blnPlatform = false;
        blnApplication = false;
        lstPlatform = new List<Platform__c>();
        lstApplication = new List<Application__c>();
        lstTop4PlatsOrApps = new List<Platform_Application_Junction__c>();
        lstTopPlatformsOrAppsSelected = new list<SelectOption> ();
        lstTopPlatformsOrApps = new List<Platform_Application_Junction__c>();
        lstAllPlatformsAndApps = new list<SelectOption> ();
        lstAllPlatforms = [select name from Platform__c];
        lstAllApplications = [select name from Application__c];
        
        if(null == strName) {
            strName = Apexpages.currentPage().getParameters().get('name');
        }
        
        if(null != strName) {
            platformAppName = strName;
            lstPlatform = [ Select 
                                name,
                                Description__c,
                                Id,
                                Display_on_Left_Nav_Bar__c,
                                Downloads__c,
                                Technical_Specification_URL__c,
                                User_Guide_URL__c,
                                SuperLinks_Article_Group_Id__c, 
                                SuperLinks_Training_Group_Id__c,
                                SuperLinks_Document_Group_Id__c //CR 83883
                            from 
                                Platform__c  
                            where 
                                name = :strName
                            limit 
                                1
                          ];
    
            if(lstPlatform.size() > 0)
            {
                resetApplicationData();    
                platform = lstPlatform.get(0);
                blnPlatform = true;
                lstAttachment = [select name, body from Attachment where parentId = :platform.id limit 1];
                if (lstAttachment.size() > 0)
                    imageAttachment = lstAttachment.get(0);
 
                trainingLinkGuid = platform.SuperLinks_Training_Group_Id__c;
                wscm.refreshTrainingData(platform.SuperLinks_Training_Group_Id__c); 
                
                System.debug('*********** platform.SuperLinks_Article_Group_Id__c : ' +platform.SuperLinks_Article_Group_Id__c);
                               
                if( (null != platform.SuperLinks_Article_Group_Id__c) && 
                    ('' != platform.SuperLinks_Article_Group_Id__c.trim()) ) {                    
                    topArticlesList = wscm.getTopArticlesList(10, platform.SuperLinks_Article_Group_Id__c);
                }
                System.debug('*********** topArticlesList : ' +topArticlesList);
                
                System.debug('*********** platform.SuperLinks_Article_Group_Id__c : ' +platform.SuperLinks_Document_Group_Id__c);
                
                //CR 83883
                if( (null != platform.SuperLinks_Document_Group_Id__c) && 
                    ('' != platform.SuperLinks_Document_Group_Id__c.trim()) ) {
                    topDocumentList = wscm.getTopArticlesList(10, platform.SuperLinks_Document_Group_Id__c);
                }
                System.debug('*********** topDocList : ' +topDocumentList);
    
                lstTopPlatformsOrApps = [ select 
                                              p.Top_Platform__c, 
                                              p.name, 
                                              p.Top_Platform_Ordinal__c, 
                                              p.Top_Application__c, 
                                              p.Top_Application__r.name, 
                                              p.Top_Application_Ordinal__c 
                                          From 
                                              Platform_Application_Junction__c p 
                                          where 
                                              p.Top_Platform__c = :platform.id 
                                          order by 
                                              p.Top_Application_Ordinal__c];
    
                for (Platform_Application_Junction__c pa : lstTopPlatformsOrApps)
                {
                    blntest = true;
                    intTopPlatformsOrAppsSelected++;
                    if (intTopPlatformsOrAppsSelected > 5)
                        lstString.add(pa.Top_Application__r.name);
                }
    
                lstString.sort();
                for(String s: lstString)
                    lstTopPlatformsOrAppsSelected.add(new selectOption(s,s));
    
            } // End if - (lstPlatform.size > 0)
            else if(lstPlatform.size() == 0)
            {
                resetPlatformData();
                lstApplication = [ Select 
                                       name, 
                                       Id,
                                       Description__c,
                                       Display_on_Left_Rail_as_Link__c,
                                       Downloads_URL__c,
                                       Parent_App__c,
                                       Technical_Specification_URL__c,
                                       User_Guide_URL__c,
                                       SuperLinks_Article_Group_Id__c,
                                       Superlinks_Training_Group_Id__c,
                                       SuperLinks_Document_Group_Id__c //CR 83883
                                   from 
                                       Application__c 
                                   where 
                                       name= :strName 
                                   limit 1 
                                 ];
                                 
                //For CR 00111871                 
                if(lstApplication.size() > 0)
                {
                    if(lstApplication[0].Parent_App__c != null)
                    {
                        System.debug('************** 00111871 :' +  lstApplication[0].Parent_App__c); 
                        List<Application__c> parentApp = [ Select 
                                       name, 
                                       Id,
                                       Description__c,
                                       Display_on_Left_Rail_as_Link__c,
                                       Downloads_URL__c,
                                       Parent_App__c,
                                       Technical_Specification_URL__c,
                                       User_Guide_URL__c,
                                       SuperLinks_Article_Group_Id__c,
                                       Superlinks_Training_Group_Id__c,
                                       SuperLinks_Document_Group_Id__c //CR 83883
                                   from 
                                       Application__c 
                                   where 
                                       id = :lstApplication[0].Parent_App__c 
                                   limit 1 
                                 ];
                        System.debug('************** 00111871 parentApp :' +  parentApp);
                       if(!parentApp.isEmpty())
                       {
                        lstApplication.clear();
                        lstApplication.addAll(parentApp);
                       }
                    }
                }
                
                if(lstApplication.size() > 0)
                {
                    blnApplication = true;
                    application = lstApplication.get(0);
                    lstAttachment = [select name, body  from Attachment where parentId = :application.id limit 1];
                    if (lstAttachment.size() > 0)
                        imageAttachment = lstAttachment.get(0);
                                        
                    trainingLinkGuid = application.SuperLinks_Training_Group_Id__c;
                    wscm.refreshTrainingData(application.SuperLinks_Training_Group_Id__c);
                    if( (null != application.SuperLinks_Article_Group_Id__c) && 
                        ('' != application.SuperLinks_Article_Group_Id__c.trim()) ) {
                        topArticlesList = wscm.getTopArticlesList(10, application.SuperLinks_Article_Group_Id__c);
                    }
                    //CR 83883
                    if( (null != application.SuperLinks_Document_Group_Id__c) && 
                        ('' != application.SuperLinks_Document_Group_Id__c.trim()) ) {
                        topDocumentList = wscm.getTopArticlesList(10, application.SuperLinks_Document_Group_Id__c);
                    }
            
                    lstTopPlatformsOrApps = [select p.Top_Platform__c, p.name, p.Top_Platform_Ordinal__c, p.Top_Platform__r.name, p.Top_Application__c, p.Top_Application_Ordinal__c From Platform_Application_Junction__c p where p.Top_Application__c = :application.id order by p.Top_Platform_Ordinal__c];
                    for (Platform_Application_Junction__c pa : lstTopPlatformsOrApps)
                    {
                        intTopPlatformsOrAppsSelected++;
                        if (intTopPlatformsOrAppsSelected > 5)
                            lstString.add(pa.Top_Platform__r.name);
                    }
    
                    lstString.sort();
                    for(String s: lstString)
                        lstTopPlatformsOrAppsSelected.add(new selectOption(s,s));
                }    
            } // End else if
        } // End if - (null != strName)
        else {
            platformAppName = ' ';
        }
        lstString.clear();
        for (Platform__c p : lstAllPlatforms)
            lstString.add(p.Name);
        for (Application__c a : lstAllApplications)
            lstString.add(a.Name);

        lstString.sort();
        for (String s : lstString)
            lstAllPlatformsAndApps.add(new selectoption(s,s));
        if(null != strName) {    
            if(lstTopPlatformsOrApps.size() < 5)
                lstTop4PlatsOrApps = lstTopPlatformsOrApps;
            else
            {
                for (integer i=0;i<5;i++)
                    lstTop4PlatsOrApps.add(lstTopPlatformsOrApps.get(i));
            }
        }
     }

    public String rUrl {get; set;}

    public PageReference redirectNow()
    {
        system.debug('redirect me Now' + rUrl);
        PageReference pg = new PageReference('/apex/supportanswers');
        pg.setRedirect(false);
        return pg;
    }
    public PageReference redirectToPlatformApp() {
        PageReference pg = new PageReference('/apex/' + hiddenInputField);        
        pg.setRedirect(false);        
        strName = null;        
        return pg;
    }    
    
    private void resetPlatformData() {  
        platform = null;
        blnPlatform = false;
        blnApplication = false;
        lstAttachment = null;
        imageAttachment = null;
        lstTopPlatformsOrApps = new List<Platform_Application_Junction__c>();    
        blntest = false;
        intTopPlatformsOrAppsSelected = 0;            
        lstString = new List<String>();  
        lstTopPlatformsOrAppsSelected = new List<SelectOption>();
        topArticlesList = new List<QESUnityTopArticle>();
        //CR 83883
        topDocumentList = new List<QESUnityTopArticle>();
        trainingLinkGuid = '';
    }
    
    private void resetApplicationData() {
        lstApplication = null;    
        blnApplication = false;
        blnPlatform = false;
        application = null;
        lstAttachment = null;
        imageAttachment = null;
        lstTopPlatformsOrApps = new List<Platform_Application_Junction__c>();
        intTopPlatformsOrAppsSelected = 0;
        lstString = new List<String>();
        lstTopPlatformsOrAppsSelected = new List<SelectOption>();
        topArticlesList = new List<QESUnityTopArticle>();
        //CR 83883
        topDocumentList = new List<QESUnityTopArticle>();
        trainingLinkGuid = '';
    }
}