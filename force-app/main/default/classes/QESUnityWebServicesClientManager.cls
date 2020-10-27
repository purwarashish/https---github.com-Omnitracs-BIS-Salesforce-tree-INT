/**
 * @description A class that handles all of the web-service calls made to
 * Superlinks WebServices and maintains the data associated with them.
 * This class may be extended by others to fetch the various Superlinks
 * WebServices.
 * @author Pratyush Kumar
 * @date October 1, 2011
 * TODO Implement the code for fetching the federation-id of a user and pass it along
 * while making callouts to the various WebServices
 */
public class QESUnityWebServicesClientManager
{
    
    /**
     * @description String in HTML format that represents the data for the SHOP, MANAGE,
     * SERVICES PORTAL and SUPPORT menus. This data is fetched from the
     * Superlinks WebServices and parsed and stored in HTML format. Fetched
     * using SHOP_MENU, SVC_PORTAL_MENU, SUPPORT_MENU.
     */
    public String menuLinks;
    
    /**
     * @description String in HTML format that represents the data for the QUICKLINKS.
     * This data is fetched from the Superlinks WebServices and parsed 
     * and stored in HTML format. Fetched using QUICKLINKS_MENU.
     */
    public String quicklinks;
    
    /**
     * @description String in HTML format that represents the data for a USER's profile.
     * This data is fetched from the Superlinks WebServices and parsed 
     * and stored in HTML format. Fetched using USER_PROFILE_MENU.  
     */
    public String userProfileLinks;

    /**
     * @description String in HTML format that represents the Global Search Options
     * This data is fetched from the Superlinks WebServices and parsed 
     * and stored in HTML format. Fetched using SEARCH_MENU.  
     */
    public String globalSearchOptions;
    
    /**
     * @description String that contains the CriticalAlert to be shown on a page. This
     * data is fetched from the Superlinks WebServices. Fetched using 
     * ALERTS and parsed for ALERTS_CRITICAL.
     */
    public String criticalAlerts;

    /**
     * @description List of Trainings as defined in the Superlinks Database
     */
     public List<QESUnityTraining> trainingList {get; set;}
              
    /**
     * @description List of Strings that contain the notifications to be shown on a page. 
     * This data is fetched from the Superlinks WebServices. Fetched using
     * ALERTS and parsed for ALERTS_NOTIFY.
     */
    public String notifications;
    
    /**
     * @description List of top-articles as defined in the SuperLinks database
     */
    public List<QESUnityTopArticle> topArticlesList;

    /**
     * @description User's display-name as defined in the SuperLinks database
     */
    public String userNameFromUnity {get; set;}
            
    // TODO: Remove the following variable - Currently being used for Testing
    public String whichUchData {get; set;}
    
    /**
     * @description Selected option for Global Search
     */
    public SelectOption globalSearchSelectedOption {get; set;}
    
    /**
     * @description Heading/Message for the New Features as fetched from the Superlinks
     */
    public String newFeaturesHeading {get; set;}

    /**
     * @description List of new trainings
     */
    public List<QESUnityNewFeature> listNewFeaturesTraining {get; set;}
    
    /**
     * @description List of new Support Features
     */    
    public List<QESUnityNewFeature> listNewFeaturesSupport  {get; set;}    
        
    /**
     * @description Default Constructor
     */
    public QESUnityWebServicesClientManager() {
        resetAllData();
        initUserDetails();
        refreshInitializationData();
    }

    /**
     * @description Parametrized constructor. The callers would be instantiating an object of 
     * this class by calling this constructor, if they do not want the default-initializations
     * to be done.
     * @param Integer An integer value to differentiate this constructor from the default.
     */
    public QESUnityWebServicesClientManager(Integer n) {
        // Reset All Data and do nothing
        resetAllData();
        initUserDetails();
    }
    
    
    //private String usernamePwd = 'sf-non-prod@service.qes.qualcomm.com:saleSm3ggs';
    //private String usernamePwd = 'unitybg_integration_nonprod:Qwerty01';
    private String usernamePwd = System.Label.UnamePwdLinkWebservice;
    /**
     * @description Method to get the user-type of the logged-in user
     */
    public String getUserType() {
        return UserType;
    }
    
    /**
     * @description Method to obtain the training data for a particular LinkGroupId
     */
    public void refreshTrainingData(String LinkGroupId) {
        QESUnitySuperLinkWebServices.LinkServiceSoapImplPort port = null;    
        QESUnitySuperLinkWebServices.standardResponse response = null;
        QESUnitySuperLinkWebServices.LinkGroup[] LinkGroups = null;    
        Integer retries = 1;
   
        // Call the web-service method, keep trying until we are successful or
        // MAX_CALLOUT_RETRIES have been reached.
        while(true) {
            try {        
                port = new QESUnitySuperLinkWebServices.LinkServiceSoapImplPort();               
                String authorization = EncodingUtil.base64Encode(
                                       Blob.valueOf(usernamePwd));
                port.inputHttpHeaders_x = new Map<String, String>();
                port.inputHttpHeaders_x.put('Authorization', 'Basic ' + authorization);
                if( (null == LinkGroupId) || ('' == LinkGroupId.trim()) ) {
                    //response = port.getLinksByGroup('TRAINING', 'Y');
                    response = port.getMyActiveLinksByGroup('TRAINING', federationId, 'Y');
                }
                else {
                    //response = port.getLinksByGroup(LinkGroupId, 'Y');
                    response = port.getMyActiveLinksByGroup(LinkGroupId, federationId, 'Y');
                }                
                
                // Fault Handling
                if( (null == response) || ('SUCCESS' != response.status) ) {
                    String errorMessage = '';
                    if(null == response) {
                        errorMessage += 'WebService Callout returned "null"';
                    }
                    else {
                        errorMessage += response.message;
                    }
                    System.debug(LoggingLevel.ERROR, errorMessage);
                    return;
                }            
                    
                break;               
            }
            catch(Exception e) {
                if(MAX_CALLOUT_RETRY <= retries) {                    
                    throw e;
                }
                else {
                    retries++;
                    continue;
                }
            } // End - catch
        } // End - while
                                                  
        if( (null == response) ||
            (null == response.responseElement) ||
            (null == response.responseElement.LinkGroup) ) {
            // Nothing to parse
            return;    
        }
        
        refreshTrainingData(response.responseElement.LinkGroup);
    }

    /**
     * @description Method to obtain the new-features data
     */
    public void refreshNewFeaturesData() {
        QESUnitySuperLinkWebServices.LinkServiceSoapImplPort port = null;    
        QESUnitySuperLinkWebServices.standardResponse response = null;
        QESUnitySuperLinkWebServices.LinkGroup[] LinkGroups = null;    
        Integer retries = 1;
   
        // Call the web-service method, keep trying until we are successful or
        // MAX_CALLOUT_RETRIES have been reached.
        while(true) {
            try {        
                port = new QESUnitySuperLinkWebServices.LinkServiceSoapImplPort();               
                String authorization = EncodingUtil.base64Encode(
                                       Blob.valueOf(usernamePwd));
                port.inputHttpHeaders_x = new Map<String, String>();
                port.inputHttpHeaders_x.put('Authorization', 'Basic ' + authorization);
                response = port.getActiveLinksByGroup('NEW_FEATURES', 'Y');
                //response = port.getLinksByGroup('NEW_FEATURES', 'Y');
                
                // Fault Handling
                if( (null == response) || ('SUCCESS' != response.status) ) {
                    String errorMessage = '';
                    if(null == response) {
                        errorMessage += 'WebService Callout returned "null"';
                    }
                    else {
                        errorMessage += response.message;
                    }
                    System.debug(LoggingLevel.ERROR, errorMessage);
                    return;
                }            
                    
                break;               
            }
            catch(Exception e) {
                if(MAX_CALLOUT_RETRY <= retries) {                    
                    throw e;
                }
                else {
                    retries++;
                    continue;
                }
            } // End - catch
        } // End - while
                                                  
        if( (null == response) ||
            (null == response.responseElement) ||
            (null == response.responseElement.LinkGroup) ) {
            // Nothing to parse
            return;    
        }

        System.debug(response.responseElement.LinkGroup);
        LinkGroups = response.responseElement.LinkGroup.LinkGroupList.LinkGroup;
        listNewFeaturesSupport = new List<QESUnityNewFeature>();
        listNewFeaturesTraining = new List<QESUnityNewFeature>();        

        if( (null != response.responseElement.LinkGroup.LinkList) && 
            (null != response.responseElement.LinkGroup.LinkList.Link) ) {
            QESUnitySuperLinkWebServices.Link[] LinkList = 
                                    QESUnityWebServicesResponseParser.mergeSortLinkList(
                                                   response.responseElement.LinkGroup.LinkList.Link,
                                                   0, 
                                                   response.responseElement.LinkGroup.LinkList.Link.size() - 1);

            for(Integer m = 0; m < LinkGroups.size(); m++) {
                if('G' == LinkList[m].LinkType) {
                    continue;
                }
                
                if(null != LinkList[m].body) {
                    newFeaturesHeading = LinkList[m].Body.replaceAll('\n', '<br/>');
                }
                else {
                    newFeaturesHeading = '';
                }
                
                break;
            }
        }    
  
        for(Integer m = 0; m < LinkGroups.size(); m++) {
            if('NEW_FEATURES_SUPPORT' == LinkGroups[m].LinkGroupId) {
                QESUnitySuperLinkWebServices.Link[] LinkList = 
                                        QESUnityWebServicesResponseParser.mergeSortLinkList(
                                                       LinkGroups[m].LinkList.Link,
                                                       0, 
                                                       LinkGroups[m].LinkList.Link.size() - 1);

                for(Integer n = 0; n < LinkList.size(); n++) {
                    if('G' == LinkList[n].LinkType) {
                        continue;
                    }
                    QESUnityNewFeature newFeature = new QESUnityNewFeature();
                    if(null != LinkList[n].title) {
                        newFeature.title = LinkList[n].Title.replaceAll('\n', '<br/>');            
                    }
                    
                    if(null != LinkList[n].body) {
                        newFeature.body = LinkList[n].Body.replaceAll('\n', '<br/>');
                    }
                    if(null != LinkList[n].linkUrl) {                
                        newFeature.linkURL = LinkList[n].linkURL.replaceAll('\n', '<br/>');
                    }
                    else {
                        newFeature.linkURL = '#';
                    }
                    
                    newFeature.sortOrder = LinkList[n].sortOrder;    
                        
                    listNewFeaturesSupport.add(newFeature);                    
                }
            }
            else if('NEW_FEATURES_TRAINING' == LinkGroups[m].LinkGroupId) {
                QESUnitySuperLinkWebServices.Link[] LinkList = 
                                        QESUnityWebServicesResponseParser.mergeSortLinkList(
                                                       LinkGroups[m].LinkList.Link,
                                                       0, 
                                                       LinkGroups[m].LinkList.Link.size() - 1);

                for(Integer n = 0; n < LinkList.size(); n++) {
                    if('G' == LinkList[n].LinkType) {
                        continue;
                    }
                    QESUnityNewFeature newFeature = new QESUnityNewFeature();
                    if(null != LinkList[n].title) {
                        newFeature.title = LinkList[n].Title.replaceAll('\n', '<br/>');            
                    }
                    
                    if(null != LinkList[n].body) {
                        newFeature.body = LinkList[n].Body.replaceAll('\n', '<br/>');
                    }
                    if(null != LinkList[n].linkUrl) {                
                        newFeature.linkURL = LinkList[n].linkURL.replaceAll('\n', '<br/>');
                    }
                    else {
                        newFeature.linkURL = '#';
                    }
                    
                    newFeature.sortOrder = LinkList[n].sortOrder;    
                        
                    listNewFeaturesTraining.add(newFeature);                    
                }
            }// End else
        }        
    }
    
    /**
     * @description Method to set the default Global-Search option
     * @param String The default Search Option
     */
    public void setDefaultSearchOption(String option) {
        if(null == option) {
            return;
        }
        
        defaultSearchMenuOption = '<option value="' + option +
                                  '" selected="selected">' + option +
                                  '</option>';    
        
        globalSearchOptions = defaultSearchMenuOption + searchMenuOptions;
    }

    /**
     * @description Method to return the URL for the provided search-option.
     * @param String The search-option for which the URL is required
     */
    public String getSearchOptionUrl(String option) {
        if( (null == option) || (null == mapSearchMenuUrls) ) {
            return '';
        }

        String optionUrl = mapSearchMenuUrls.get(option);
        if(null == optionUrl) {
            optionUrl = '';
        }        
        
        return optionUrl;
    }
            
    /**
     * @description Method to return the Training Data in HTML format for 
     * Support Landing Page
     */
     public String getSupportLandingTrainingData() {
         String str = '';
         boolean blnLinkTypeGFound = false;
         
         if( (null == trainingList) || (0 == trainingList.size()) ) {
             return str;
         }
         
         if(0 < trainingList.size()) {
             if(1 != trainingList.size()) {
                 str += '<li class="training-cer" style="' +
                        'background-repeat:no-repeat; background-position:0 15px;">' +
                        '<h4><a href="' +
                        ( (null == trainingList[0].linkUrl) ? '#' : trainingList[0].linkUrl.replaceAll('\n', ' ') ) +
                        '">' +
                        trainingList[0].title.replaceAll('\n', ' ') +
                        '</a></h4>' +
                        trainingList[0].body.replaceAll('\n', ' ') + 
                        '</li>';
             }

             Integer last = -1;
             if(2 <= trainingList.size()) {
                 last = 1;
             }
             else {
                 last = 0;
             }
                 str += '<li class="training-hos" style="' +
                        'background-repeat:no-repeat; background-position:0 15px;">' +
                        '<h4><a href="' +
                        ( (null == trainingList[last].linkUrl) ? '#' : trainingList[last].linkUrl.replaceAll('\n', ' ') ) +
                        '">' +
                        trainingList[last].title.replaceAll('\n', ' ') +
                        '</a></h4>' +
                        trainingList[last].body.replaceAll('\n', ' ') + 
                        '</li>';                    
         }
         str.replaceAll('\n', ' ' );
         str.replaceAll('\r', ' ');
         return str;
    }

    /**
     * @description Method to return the Training Data in HTML format for 
     * PlatformApp
     */
     public String getPlatformAppTrainingData() {
         String str = '';
         
         if( (null == trainingList) || (0 == trainingList.size()) ) {
             return str;
         }
         
         if(0 < trainingList.size()) {
             if(1 != trainingList.size()) {
                 str += '<li><a href="' + 
                        trainingList[0].linkURL.replaceAll('\n', ' ') + 
                        '" style="margin-top:0px;margin-left:2px;">' +
                        trainingList[0].title.replaceAll('\n', ' ') +
                        '</a></li>'; 
             }
             if(3 <= trainingList.size()) {
                 str += '<li><a href="' +
                        trainingList[1].linkURL.replaceAll('\n', ' ') +
                        '" style="margin-top:0px;margin-left:2px;">' +
                        trainingList[1].title.replaceAll('\n', ' ') +
                        '</a></li>';
             }
             
             Integer last = -1;
             if(1 == trainingList.size()) {
                 last = 0;
             }
             else if(2 == trainingList.size()) {
                 last = 1;
             }
             else {
                 last = 2;
             }
             str += '<li ><a  href="' +
                    trainingList[last].linkURL.replaceAll('\n', ' ') +
                    '" style="margin-top:0px;margin-left:2px;">' +
                    trainingList[last].title.replaceAll('\n', ' ') +
                    '</a></li>';
         }
         return str;
     }
    
    /**
     * @description Getter method for the menuLinks.
     * @return String The SHOP, MANAGE, SERVICE PORTAL and SUPPORT menus in HTML format
     * to be displayed on the page
     */
    public String getMenuLinks() {
        DateTime currentTime = System.now();

        // Check if the data was never fetched or if the time-difference between the
        // current time and the last-fetched-time is greater than the specified interval.
        // If yes, fetch the data from Superlinks.        
        if( (null == uchDataLastFetched) || 
             (UCH_DATA_FETCH_INTERVAL <= (currentTime.getTime() - 
                                   uchDataLastFetched.getTime())) ) {
            refreshUchData();      
        }
    
        return menuLinks;
    }

    /**
     * @description Getter method for the quickLinks.
     * @return String The QUICKLINKS in HTML format to be displayed on the page.
     */    
    public String getQuickLinks() {
        DateTime currentTime = System.now();

        // Check if the data was never fetched or if the time-difference between the
        // current time and the last-fetched-time is greater than the specified interval.
        // If yes, fetch the data from Superlinks.        
        if( (null == uchDataLastFetched) || 
             (UCH_DATA_FETCH_INTERVAL <= (currentTime.getTime() - 
                                   uchDataLastFetched.getTime())) ) {
            refreshUchData();      
        }
        
        return quickLinks;
    }

    /**
     * @description Getter method for the userProfileLinks.
     * @return String The User's profile-links in HTML format to be displayed on the page.
     */        
    public String getUserProfileLinks() {
        DateTime currentTime = System.now();

        // Check if the data was never fetched or if the time-difference between the
        // current time and the last-fetched-time is greater than the specified interval.
        // If yes, fetch the data from Superlinks.        
        if( (null == uchDataLastFetched) || 
             (UCH_DATA_FETCH_INTERVAL <= (currentTime.getTime() - 
                                   uchDataLastFetched.getTime())) ) {
            refreshUchData();      
        }
        
        return userProfileLinks;
    }

    /**
     * @description Getter method for the globalSearchOptions.
     * @return String The Global Search Options in HTML format to be displayed on the page.
     */        
    public String getGlobalSearchOptions() {
        DateTime currentTime = System.now();

        // Check if the data was never fetched or if the time-difference between the
        // current time and the last-fetched-time is greater than the specified interval.
        // If yes, fetch the data from Superlinks.        
        if( (null == uchDataLastFetched) || 
             (UCH_DATA_FETCH_INTERVAL <= (currentTime.getTime() - 
                                   uchDataLastFetched.getTime())) ) {
            refreshUchData();      
        }
        
        return globalSearchOptions;
    }
    
    /**
     * @description Getter method for the criticalAlerts.
     * @return String Critical Alert as fetched from the Superlinks WebServices.
     */
    public String getCriticalAlerts() {
        DateTime currentTime = System.now();

        // Check if the data was never fetched or if the time-difference between the
        // current time and the last-fetched-time is greater than the specified interval.
        // If yes, fetch the data from Superlinks.
        if( (null == uchDataLastFetched) || 
             (UCH_DATA_FETCH_INTERVAL <= (currentTime.getTime() - 
                                   uchDataLastFetched.getTime())) ) {
            refreshUchData();
        }        
        return criticalAlerts;
    }

    /**
     * @description Getter method for the criticalAlerts.
     * @return String Notifications in HTML format as fetched from the Superlinks WebServices.
     */    
    public String getNotifications() {
        DateTime currentTime = System.now();

        // Check if the data was never fetched or if the time-difference between the
        // current time and the last-fetched-time is greater than the specified interval.
        // If yes, fetch the data from Superlinks.
        if( (null == uchDataLastFetched) || 
             (UCH_DATA_FETCH_INTERVAL <= (currentTime.getTime() - 
                                   uchDataLastFetched.getTime())) ) {
            refreshUchData();
        }
        return notifications;
    }
     
    public List<QESUnityTopArticle> getTopArticlesList() {
        return getTopArticlesList(-1, null);
    }
    
    /**
     * @description Getter method for the  Top Articles
     * @param Integer limitBy - Putting an upper limit on the number of Articles to be returned.
     * Use -1, if all the articles need to be returned.
     * @param String The name of the platform/app for which the data is required. Can be NULL,
     * if data is not required to any specific product/App.
     * @return List<QESUnityTopArticle> TopArticles as fetched from the Superlinks Database
     */
    public List<QESUnityTopArticle> 
        getTopArticlesList(Integer limitBy, 
                           String platformAppGroupId) {
        QESUnitySuperLinkWebServices.LinkServiceSoapImplPort port = null;    
        QESUnitySuperLinkWebServices.standardResponse response = null;
        QESUnitySuperLinkWebServices.Link[] LinkList = null;   
        Integer retries = 1;         
        
        // Fetch all the TOP ARTICLES data
        while(true) {
            try {
                port = new QESUnitySuperLinkWebServices.LinkServiceSoapImplPort();
                String authorization = EncodingUtil.base64Encode(
                                       Blob.valueOf(usernamePwd));
                System.debug('@@@@@@@@..' + authorization);
                port.inputHttpHeaders_x = new Map<String, String>();
                port.inputHttpHeaders_x.put('Authorization', 'Basic ' + authorization);
                
                if(null != platformAppGroupId) {
                    //response = port.getActiveLinksByGroup(platformAppGroupId, 'Y');
                    response = port.getMyActiveLinksByGroup(platformAppGroupId, federationId, 'Y');
                }
                else {
                    //response = port.getActiveLinksByGroup('SUP_HOME_TOP_KB', 'Y');
                    response = port.getMyActiveLinksByGroup('SUP_HOME_TOP_KB', federationId, 'Y');
                }
                
                // Fault Handling
                if( (null == response) || ('SUCCESS' != response.status) ) {
                    String errorMessage = '';
                    if(null == response) {
                        errorMessage += 'WebService Callout returned "null"';
                    }
                    else {
                        errorMessage += response.message;
                    }
                    System.debug(LoggingLevel.ERROR, errorMessage);
                }    
                break;        
            }
            catch(Exception e) {
                if( (null != topArticlesList) ) {
                    return topArticlesList;
                }
                else {
                    if(MAX_CALLOUT_RETRY <= retries) {                    
                        throw e;
                    }
                    else {
                        retries++;
                        continue;
                    }
                }
            } // End catch
        }// End while
        
        topArticlesList = new List<QESUnityTopArticle>();
                
        // Fault Handling on response
        if( (null == response) ||
            (null == response.responseElement) ||
            (null == response.responseElement.LinkGroup) ||
            (null == response.responseElement.LinkGroup.LinkList) ||
            (null == response.responseElement.LinkGroup.LinkList.Link) ) {
            return topArticlesList;
        }
        
        LinkList = response.responseElement.LinkGroup.LinkList.Link;
        LinkList = QESUnityWebServicesResponseParser.mergeSortLinkList(LinkList,
                                                                       0,
                                                                       LinkList.size() - 1);
        
        if(-1 == limitBy) {
            limitBy = LinkList.size();
        }
        else {
            limitBy = (limitBy < LinkList.size()) ? limitBy : LinkList.size();
        }

        Integer count = 0;
        // Go through all the Links in the response     
        for(Integer m = 0; m < LinkList.size(); m++) {                            
            if( (null == LinkList[m].linkURL) || ('G' == LinkList[m].linkType) ) {
                continue;
            }
            
            QESUnityTopArticle topArticle = new QESUnityTopArticle();
            topArticle.title = LinkList[m].Title;
            topArticle.body = LinkList[m].Body;
            topArticle.linkURL = LinkList[m].linkURL;
            topArticle.type = LinkList[m].AltText; 
            topArticle.sortOrder = LinkList[m].sortOrder;
            
            topArticlesList.add(topArticle);
            
            count++;
            if(count == limitBy) {
                break;
            }
        }
        
        return topArticlesList;
    }
    
    /**
     * @description Method to refresh the initialization-data for the 
     * variables of this class
     */
    public void refreshInitializationData() {  
        DateTime currentTime = System.now();  
    
        // Fetch menus-data if required
        if( (null == uchDataLastFetched) || 
             (UCH_DATA_FETCH_INTERVAL <= (currentTime.getTime() - 
                                   uchDataLastFetched.getTime())) ) {
            refreshUchData();   
            refreshUserNameFromUnity();
            
            // TODO: Remove the following - Currently being used for Testing
            whichUchData = 'Fresh UCH Data';   
        }
    }

    /*--------- PRIVATE MEMBERS -------------*/
    
    /**
     * @description Global Search Page Name
     */
    private final String GLOBAL_SEARCH_SUPPORT_PAGE = 'supportsearch?searchText=';
    
    /**
     * @description DateTime to represent the last-fetched time for the UCH data
     */
    private DateTime uchDataLastFetched = null;
            
    /**
     * @description Long variable to represent the DATA_FETCH_NTERVAL (milli-seconds)
     * for UCH Data
     */    
    private final Long UCH_DATA_FETCH_INTERVAL         = 3600000;
    
    /**
     * @description Maximum number of Callout-retries to make in case the data is not cached.
     */
    private final Integer MAX_CALLOUT_RETRY            = 3;

    /**
     * @description Salesforce UserId of the logged-in user
     */
     private String userId;

    /**
     * @description FederationId of the logged-in user
     */
     private String federationId;
         
    /**
     * @description Map to store the different search-URLs as fetched from
     * the SuperLinks DB
     */
    private Map<String, String> mapSearchMenuUrls;
    
    /**
     * @description The default search-options
     */
    private String defaultSearchMenuOption;

    /**
     * @description The search-options excluding the default search-option
     */
    private String searchMenuOptions;
    
    /**
     * @description UserType of the logged-in User
     */
    private String userType;
              
    /**
     * @description Method to initialize the user-details of the logged-in user
     */
    private void initUserDetails() {
        userId = UserInfo.getUserId();
        
        List<User> userDetailsList = [ SELECT
                                           ID,
                                           FederationIdentifier,
                                           UserType
                                       FROM
                                           USER
                                       WHERE
                                           ID = :userId
                                       LIMIT
                                           1
                                     ];
        if( (null != userDetailsList) && (0 < userDetailsList.size()) ) {
            federationId = userDetailsList[0].FederationIdentifier;
            userType = userDetailsList[0].UserType;
        }                                 
    }
     
    /**
     * @description Method to refresh the UCH data
     * TODO Implement retries once the AdminServices issues are fixed
     */
     private void refreshUchData() {
        QESUnitySuperLinkWebServices.LinkServiceSoapImplPort port = null;    
        QESUnitySuperLinkWebServices.standardResponse response = null;
        QESUnitySuperLinkWebServices.LinkGroup[] LinkGroups = null;    
        Integer retries = 1;
   
        // Call the web-service method, keep trying until we are successful or
        // MAX_CALLOUT_RETRIES have been reached.
        while(true) {
            try {        
                port = new QESUnitySuperLinkWebServices.LinkServiceSoapImplPort();               
                String authorization = EncodingUtil.base64Encode(
                                       Blob.valueOf(usernamePwd));
                port.inputHttpHeaders_x = new Map<String, String>();
                port.inputHttpHeaders_x.put('Authorization', 'Basic ' + authorization);
                //response = port.getActiveLinksByGroup('UCH', 'Y');
                response = port.getMyActiveLinksByGroup('UCH', federationId, 'Y');
                
                // Fault Handling
                if( (null == response) || ('SUCCESS' != response.status) ) {
                    String errorMessage = '';
                    if(null == response) {
                        errorMessage += 'WebService Callout returned "null"';
                    }
                    else {
                        errorMessage += response.message;
                    }
                    System.debug(LoggingLevel.ERROR, errorMessage);
                    if('Invalid User GUID' == errorMessage) {
                        uchDataLastFetched = System.now();
                    }

                    return;
                }            
                    
                break;               
            }
            catch(Exception e) {
                if( (null != menuLinks) && (null != quickLinks) && 
                    (null != userProfileLinks) && (null != globalSearchOptions) ) {
                    return;
                }
                else {
                    if(MAX_CALLOUT_RETRY <= retries) {                    
                        throw e;
                    }
                    else {
                        retries++;
                        continue;
                    }
                }
            } // End - catch
        } // End - while
        
        if(null == response || 'SUCCESS' != response.status) {
            // Error scenario
            return;        
        }
                                                  
        if( (null == response.responseElement.LinkGroup) || 
            (null == response.responseElement.LinkGroup.LinkGroupList) ||
            (null == response.responseElement.LinkGroup.LinkGroupList.LinkGroup) ||
            (0 >= response.responseElement.LinkGroup.LinkGroupList.LinkGroup.size()) ) {
            // Nothing to parse
            uchDataLastFetched = System.now();
            return;    
        }
        
        // Extract the list of LinkGroups for parsing.
        LinkGroups = response.responseElement.LinkGroup.LinkGroupList.LinkGroup;
  
        for(Integer m = 0; m < LinkGroups.size(); m++) {
            if('MAIN_MENU' == LinkGroups[m].LinkGroupId) {
                refreshMenuData(LinkGroups[m]);
            }
            else if('QUICKLINKS_MENU' == LinkGroups[m].LinkGroupId) {
                refreshQLData(LinkGroups[m]);
            }
            else if('USER_PROFILE_MENU' == LinkGroups[m].LinkGroupId) {
                refreshUserProfileData(LinkGroups[m]);
            }
            else if('SEARCH_MENU' == LinkGroups[m].LinkGroupId) {
                refreshSearchMenuData(LinkGroups[m]);
            }            
            else if('TRAINING' == LinkGroups[m].LinkGroupId) {
                refreshTrainingData(LinkGroups[m]);
            }            
            else if('ALERTS' == LinkGroups[m].LinkGroupId) {
                refreshAlertsData(LinkGroups[m]);
            }                        
        }
        
        uchDataLastFetched = System.now();     
    }
    
    /**
     * @description Method to refresh the User-Name from the Unity Database
     * TODO Add retries and error-handling once the AdminServices issues are fixed
     */
    private void refreshUserNameFromUnity() {     
        QESUnityAdminLinkWebServices.AdminServiceSoapImplPort port = null;    
        QESUnityAdminLinkWebServices.standardResponse response = null;
        Integer retries = 1;
        
        while(true) {
            try {        
                port = new QESUnityAdminLinkWebServices.AdminServiceSoapImplPort();
                String authorization = EncodingUtil.base64Encode(
                                       Blob.valueOf(usernamePwd));
                port.inputHttpHeaders_x = new Map<String, String>();
                port.inputHttpHeaders_x.put('Authorization', 'Basic ' + authorization);
                response = port.getUser(federationId);
                //response = port.getUser('ADF53AE33CCCA368E04016AC77E66DB3');
                break;
            }
            catch(Exception e) {
                if(null != userNameFromUnity) {
                    return;
                }
                else {
                    if(MAX_CALLOUT_RETRY <= retries) {                    
                        throw e;
                    }
                    else {
                        retries++;
                        continue;
                    }                
                }        
            } // End - catch
        } // End - while
                            
        if( (null != response) &&
            (null != response.responseElement) &&
            (null != response.responseElement.UserProfile) &&
            (null != response.responseElement.UserProfile.DisplayName) ) {
            userNameFromUnity = response.responseElement.UserProfile.DisplayName;
        }       
    }
    

    /**
     * @description Method to refresh the MENU-data 
     */    
    private void refreshMenuData(QESUnitySuperLinkWebServices.LinkGroup LinkGroup) {
        QESUnitySuperLinkWebServices.LinkGroupList_element LinkGroupList = null;        
        QESUnitySuperLinkWebServices.LinkGroup[] LinkGroups = null; 
        String svcPortalLinks = '';
        String manageLinks    = '';
        String shopLinks      = '';
        String supportLinks   = '';
                
                                          
        if( (null == LinkGroup) || 
            (null == LinkGroup.LinkGroupList) ||
            (null == LinkGroup.LinkGroupList.LinkGroup) ||
            (0 >= LinkGroup.LinkGroupList.LinkGroup.size()) ) {
            // Nothing to parse
            return;    
        }
        
        // Extract the list of LinkGroups for parsing.
        LinkGroups = LinkGroup.LinkGroupList.LinkGroup;

        // Reinitialize menuLinks
        menuLinks = '';
        for(Integer m = 0; m < LinkGroups.size(); m++) {
            if('SVC_PORTAL_MENU' == LinkGroups[m].LinkGroupId) {
                LinkGroupList = new QESUnitySuperLinkWebServices.LinkGroupList_element();
                LinkGroupList.LinkGroup = new List<QESUnitySuperLinkWebServices.LinkGroup>();
                LinkGroupList.LinkGroup.add(LinkGroups[m]);

                svcPortalLinks += QESUnityWebServicesResponseParser.parseLinkGroupList(
                                  LinkGroupList, 
                                  QESUnityWebServicesResponseParser.MENU_LINKS_TYPE, 
                                  'monitor', false);
            }
            else if('SUPPORT_MENU' == LinkGroups[m].LinkGroupId) {
                LinkGroupList = new QESUnitySuperLinkWebServices.LinkGroupList_element();
                LinkGroupList.LinkGroup = new List<QESUnitySuperLinkWebServices.LinkGroup>();
                LinkGroupList.LinkGroup.add(LinkGroups[m]);

                supportLinks += QESUnityWebServicesResponseParser.parseLinkGroupList(
                                LinkGroupList, 
                                QESUnityWebServicesResponseParser.MENU_LINKS_TYPE, 
                                'support', false);
            }
            else if('SHOP_MENU' == LinkGroups[m].LinkGroupId) {
                LinkGroupList = new QESUnitySuperLinkWebServices.LinkGroupList_element();
                LinkGroupList.LinkGroup = new List<QESUnitySuperLinkWebServices.LinkGroup>();
                LinkGroupList.LinkGroup.add(LinkGroups[m]);

                shopLinks += QESUnityWebServicesResponseParser.parseLinkGroupList(
                             LinkGroupList, 
                             QESUnityWebServicesResponseParser.MENU_LINKS_TYPE, 
                            'shop', false);
            }
            else if('MANAGE_MENU' == LinkGroups[m].LinkGroupId) {     
                LinkGroupList = new QESUnitySuperLinkWebServices.LinkGroupList_element();
                LinkGroupList.LinkGroup = new List<QESUnitySuperLinkWebServices.LinkGroup>();
                LinkGroupList.LinkGroup.add(LinkGroups[m]);                

                manageLinks += QESUnityWebServicesResponseParser.parseLinkGroupList(
                               LinkGroupList, 
                               QESUnityWebServicesResponseParser.MENU_LINKS_TYPE, 
                               'manage', false);
            }
            menuLinks = svcPortalLinks + manageLinks + shopLinks + supportLinks;            
        }        
    }
    
    /**
     * @description Method to refresh the QUICKLINKS-data
     */
    private void refreshQLData(QESUnitySuperLinkWebServices.LinkGroup LinkGroup) {
        QESUnitySuperLinkWebServices.LinkGroupList_element LinkGroupList = null;    
        
        // Extract the LinkGroup in the response and attach it to a LinkGroupList for parsing.
        LinkGroupList = new QESUnitySuperLinkWebServices.LinkGroupList_element();
        LinkGroupList.LinkGroup = new List<QESUnitySuperLinkWebServices.LinkGroup>();
        LinkGroupList.LinkGroup.add(LinkGroup);
        
        // Parse the LinkGroupList
        quickLinks = '' + QESUnityWebServicesResponseParser.parseLinkGroupList(LinkGroupList, 
                          QESUnityWebServicesResponseParser.QUICK_LINKS_TYPE, 
                          '', false);    
    }
    
    /**
     * @description Method to refresh the UserProfile data
     */
    private void refreshUserProfileData(QESUnitySuperLinkWebServices.LinkGroup LinkGroup) {
        QESUnitySuperLinkWebServices.LinkGroupList_element LinkGroupList = null;    
        
        // Extract the LinkGroup in the response and attach it to a LinkGroupList for parsing.
        LinkGroupList = new QESUnitySuperLinkWebServices.LinkGroupList_element();
        LinkGroupList.LinkGroup = new List<QESUnitySuperLinkWebServices.LinkGroup>();
        LinkGroupList.LinkGroup.add(LinkGroup);
        
        userProfileLinks = QESUnityWebServicesResponseParser.parseLinkGroupList(LinkGroupList, 
                         QESUnityWebServicesResponseParser.USER_PROFILE_TYPE, 
                         '', false);
    }

    /**
     * @description Method to refresh the SEARCH_MENU-data
     */
    private void refreshSearchMenuData(QESUnitySuperLinkWebServices.LinkGroup LinkGroup) {
        Integer m = 0;
        Integer n = 0;
   
        if( (null == LinkGroup) ||
            (null == LinkGroup.LinkList) ||
            (null == LinkGroup.LinkList.Link) ||
            (0 >= LinkGroup.LinkList.Link.size()) ) {
            // Nothing to process
            return;
        }
        
        LinkGroup.LinkList.Link = QESUnityWebServicesResponseParser.mergeSortLinkList(
                                               LinkGroup.LinkList.Link,
                                               0, 
                                               LinkGroup.LinkList.Link.size() - 1);

        String linkUrl = '';
        globalSearchOptions = '';                                               

        if( (null == defaultSearchMenuOption) || ('' == defaultSearchMenuOption) ) {
            // Loop to figure out the default Search-URL
            for(m = 0; m < LinkGroup.LinkList.Link.size(); m++) {
                if( (null == LinkGroup.LinkList.Link[m].LinkType) || 
                    ('G' == LinkGroup.LinkList.Link[m].LinkType) ) {
                    continue;
                }
                if( 0 < 
                     LinkGroup.LinkList.Link[m].LinkUrl.toLowerCase().indexOf(
                         GLOBAL_SEARCH_SUPPORT_PAGE.toLowerCase())) {
                    Integer index = LinkGroup.LinkList.Link[m].LinkUrl.indexOf('//', 0);
                    if(-1 == index) {
                        linkUrl = LinkGroup.LinkList.Link[m].LinkUrl;
                    }
                    else {
                        index = LinkGroup.LinkList.Link[m].LinkUrl.indexOf('/', index + 2);
                        if(-1 == index) {
                            linkUrl = LinkGroup.LinkList.Link[m].LinkUrl;
                        }
                        else {
                            linkUrl = '/apex' + LinkGroup.LinkList.Link[m].LinkUrl.subString(index,  
                                              LinkGroup.LinkList.Link[m].LinkUrl.length());
                        }
                    }
                }
                else {
                    linkUrl = LinkGroup.LinkList.Link[m].LinkUrl;
                }
                
                break;
            }
            
            if(m > LinkGroup.LinkList.Link.size()) {
                return;
            }
            
            defaultSearchMenuOption = '<option value="' + LinkGroup.LinkList.Link[m].Title +
                                      '" selected="selected">' + LinkGroup.LinkList.Link[m].Title +
                                      '</option>';
        }
        
        searchMenuOptions = '';
        // Initilalize the map of Search-URLs
        mapSearchMenuURLs = new Map<String, String>();
        
        for(n = 0; n < LinkGroup.LinkList.Link.size(); n++) {
            if( (null == LinkGroup.LinkList.Link[n].LinkType) ||
                ('G' == LinkGroup.LinkList.Link[n].LinkType) ) {
                continue;
            }
            
            linkUrl = '';
            if( 0 < 
                 LinkGroup.LinkList.Link[n].LinkUrl.toLowerCase().indexOf(
                     GLOBAL_SEARCH_SUPPORT_PAGE.toLowerCase())) {
                Integer index = LinkGroup.LinkList.Link[n].LinkUrl.indexOf('//', 0);
                if(-1 == index) {
                    linkUrl = LinkGroup.LinkList.Link[n].LinkUrl;
                }
                else {
                    index = LinkGroup.LinkList.Link[n].LinkUrl.indexOf('/', index + 2);
                    if(-1 == index) {
                        linkUrl = LinkGroup.LinkList.Link[n].LinkUrl;
                    }
                    else {
                        linkUrl = '/apex' + LinkGroup.LinkList.Link[n].LinkUrl.subString(index,  
                                          LinkGroup.LinkList.Link[n].LinkUrl.length());
                    }
                }
            }
            else {
                linkUrl = LinkGroup.LinkList.Link[n].LinkUrl;
            }
            
            searchMenuOptions += '<option value="' + LinkGroup.LinkList.Link[n].Title +
                                 '">' + LinkGroup.LinkList.Link[n].Title +
                                 '</option>';
            mapSearchMenuURLs.put(LinkGroup.LinkList.Link[n].Title, linkUrl);
        }
        
        globalSearchOptions = defaultSearchMenuOption + searchMenuOptions;
    }

    /**
     * @description Method to refresh the training data
     * @param LinkGroup A link-group that would contain all of the training data
     */
    private void refreshTrainingData(QESUnitySuperLinkWebServices.LinkGroup LinkGroup) {
        trainingList = new List<QESUnityTraining>();
        if( (null == LinkGroup) ||
            (null == LinkGroup.LinkList) ||
            (null == LinkGroup.LinkList.Link) ||
            (0 >= LinkGroup.LinkList.Link.size()) ) {
            // Nothing to process
            return;
        }
        
        LinkGroup.LinkList.Link = QESUnityWebServicesResponseParser.mergeSortLinkList(
                                               LinkGroup.LinkList.Link,
                                               0, 
                                               LinkGroup.LinkList.Link.size() - 1);
        QESUnitySuperLinkWebServices.Link[] LinkList = LinkGroup.LinkList.Link;
        
        // Go through all the Links in the response     
        for(Integer m = 0; m < LinkList.size(); m++) {                            
            if( (null == LinkList[m].Body) || ('G' == LinkList[m].LinkType) ) {
                continue;
            }
            QESUnityTraining training = new QESUnityTraining();
            training.myInternalId = 'training' + m;
            if(null != LinkList[m].title) {
                training.title = LinkList[m].Title.replaceAll('\n', '<br/>');            
            }
            
            if(null != LinkList[m].body) {
                training.body = LinkList[m].Body.replaceAll('\n', '<br/>');
            }
            if(null != LinkList[m].linkUrl) {                
                training.linkURL = LinkList[m].linkURL.replaceAll('\n', '<br/>');
            }
            if(null != LinkList[m].iconUrl) {    
                training.iconURL = LinkList[m].iconURL.replaceAll('\n', '<br/>');
            }
            
            training.sortOrder = LinkList[m].sortOrder;    
                
            trainingList.add(training);
        }
    }
         
    /**
     * @description Method to refresh the ALERTS-data
     */
    private void refreshAlertsData(QESUnitySuperLinkWebServices.LinkGroup LinkGroup) {
        QESUnitySuperLinkWebServices.LinkGroup tmpLinkGroup = null;
        String tmpStr = null;
        
        if( (null == LinkGroup) ||
            (null == LinkGroup.LinkGroupList) ||
            (null == LinkGroup.LinkGroupList.LinkGroup) ||
            (0 >= LinkGroup.LinkGroupList.LinkGroup.size()) ) {
            // Nothing to process
            return;
        }        
        
        boolean criticalAlertsUpdated = false;
        boolean notificationsUpdated = false; 
        Integer retries = 1;
        
        // Go through all the LinkGroupLists in the response     
        for(Integer m = 0; 
            m < LinkGroup.LinkGroupList.LinkGroup.size(); 
            m++) {
                    
            tmpLinkGroup = LinkGroup.LinkGroupList.LinkGroup[m];
                        
            if('ALERTS_CRITICAL' == tmpLinkGroup.LinkGroupId) {
                // Process the ALERTS_CRITICAL LinkGroup
                if( (null != tmpLinkGroup.LinkList) && 
                    (null != tmpLinkGroup.LinkList.Link) &&
                    (0 < tmpLinkGroup.LinkList.Link.size()) ) {
                    for(Integer n = 0; n < tmpLinkGroup.LinkList.Link.size(); n++) {    
                        if( (null == tmpLinkGroup.LinkList.Link[n].LinkType) || 
                            ('G' == tmpLinkGroup.LinkList.Link[n].LinkType) ) {
                            continue;
                        }
                        //criticalAlerts = tmpLinkGroup.LinkList.Link[n].Title.replaceAll('\n', ' ');
                        criticalAlerts = '' + tmpLinkGroup.LinkList.Link[n].Body.replaceAll('\n', ' ');
                        criticalAlertsUpdated = true;
                        break;
                    }    
                }            
            }
            else if('ALERTS_NOTIFY' == tmpLinkGroup.LinkGroupId) {
                // Process the ALERTS_NOTIFY LinkGroup
                if( (null != tmpLinkGroup.LinkList) && 
                    (null != tmpLinkGroup.LinkList.Link) &&
                    (0 < tmpLinkGroup.LinkList.Link.size()) ) {
                    // Prepare the list of notifications
                    notifications = '';
                    tmpLinkGroup.LinkList.Link = QESUnityWebServicesResponseParser.mergeSortLinkList(
                                                     tmpLinkGroup.LinkList.Link,
                                                     0, 
                                                     tmpLinkGroup.LinkList.Link.size() - 1);
                    for(Integer n = 0; n < tmpLinkGroup.LinkList.Link.size(); n++) 
                    {
                        if( (null == tmpLinkGroup.LinkList.Link[n].LinkType) || 
                            ('G' == tmpLinkGroup.LinkList.Link[n].LinkType) ) {
                            continue;
                        }
                            
                        if(tmpLinkGroup.LinkList.Link[n].Body != null && tmpLinkGroup.LinkList.Link[n].Body.trim() != '')
                        {
                            notifications += '<li>' + tmpLinkGroup.LinkList.Link[n].Body.replaceAll('\n', ' ');
                            
                            if( (null != tmpLinkGroup.LinkList.Link[n].LinkUrl) &&
                                ('' != tmpLinkGroup.LinkList.Link[n].LinkUrl.trim()) ) {
                                notifications += '<a href="' + tmpLinkGroup.LinkList.Link[n].LinkUrl +
                                                 '">Click here to Learn More.</a>';
                            }
                            notifications += '</li>'; 
                        }                  
                        notificationsUpdated = true;
                    }
                } // END - if
            } // END - else if
        } // End - for(m)
        
        /* Nullify the Alerts/Notifications if not updated */        
        if(false == criticalAlertsUpdated) {
            criticalAlerts = '';
        }        
        if(false == notificationsUpdated) {
            notifications = '';
        }
    }    
    
    /**
     * @description Method to reset all the variables associated with this class
     */
    private void resetAllData() {
        menuLinks             = null;
        quicklinks            = null;
        userProfileLinks      = null;
        globalSearchOptions   = null;
        criticalAlerts        = '';
        trainingList          = null;
        notifications         = '';
        topArticlesList       = null;
        userNameFromUnity     = null;
    }    
}