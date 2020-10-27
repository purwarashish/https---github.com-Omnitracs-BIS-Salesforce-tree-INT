/**
 * @description The modeler class for SupportLandingPage and SearchUnity pages.
 * @date Sep 19, 2011
 */
public class QESPKBModeler extends KnowledgeController
{

    public String ArticleURL {get;set;}
    public String ArticleType {get;set;}{ArticleType='';}
    public String ArticleId {get;set;}{ArticleId='';}
    public String rURL{get;set;}{rURL='NOURL';}
    public String hiddenInputField {get; set;} {hiddenInputField = '';}
    
    public string strArticleIdList {get;set;}
    public Map<Id, Double> mapArticleRating {get;set;} 
    public boolean blnShowArticles {get;set;} {blnShowArticles = false;}
    
    /**
     * @description Instantiating PicklistURLModeler
     */
     public PicklistURLModeler pum {get;set;}

    /**
     * @description A Static String constant
     */
    public static final String SITE_NAME = Site.getName();

    /**
     * @description An object of String
     */
    public String searchCriteria{get;set;}

    /**
     * @description An object of Map<String, String>
     */
    public Map<String, String> searchMap = new Map<String, String>();

    /**
     * @description An object of String
     */
    public String searchkeyword {get;set;}

    /**
     * @description A Static String constant
     */
    public static final String SORT_BY_MOST_VIEWED = 'mostViewed';

    /**
     * @description An Object of List<QES_Unity_Portal_Notification__c>
     */
   // public List<QES_Unity_Portal_Notification__c> lstNotification = new List<QES_Unity_Portal_Notification__c>();

    /**
     * @description An Object of QES_Unity_Portal_Notification__c
     */
    //public QES_Unity_Portal_Notification__c notifications {get;set;}

    /**
     * @description An Object of List<String>
     */
    //public List<String> notificationString {get;set;}

    /**
     * @description An Object of Boolean
     */
    //public Boolean notificationdis {get;set;}

    /**
     * @description An Object of List<String>
     */
    public Integer intListSize {get; set;} {intListSize = 0;}

    /**
     * @description A Static String constant
     */
    private static final String PAGE_PREFIX = '/apex';

    /**
     * @description A Static String constant
     */
    private static final String PKB_ARTICLE_PREFIX = 'articles';

    /**
     * @description A Static String constant
     */
    public static final String QES_PAGE_SEARCH = 'searchunity';

    /**
     * @description A Static String constant
     */
    public static final String QES_URL_SEARCH = PAGE_PREFIX + '/' + QES_PAGE_SEARCH;

    /**
     * @description A Static String constant
     */
    public static final String QES_PAGE_ListView = 'caselistviewrecentcases';

    /**
     * @description A Static String constant
     */
    public static final String QES_URL_ListView = PAGE_PREFIX + '/' + QES_PAGE_ListView;

    /**
     * @description A Static String constant
     */
    public static final String ALL_CATEGORY = 'All';

    /**
     * @description A Static String constant
     */
    public static final String NO_FILTER_VALUE = 'NONE';

    /**
     * @description A Static String constant
     */
    public static final String NO_FILTER_LABEL = '-- No filter --';

    /**
     * @description A Static Integer constant
     */
    public static final Integer DEFAULT_PAGE_SIZE = 10;
    
    public String hello {get; set;} {hello = null;}

    /**
     * @description Method to refresh the initialization data for the QESPKBModeler
     * whenever a page loads that makes use of the QESPKBModeler.
     */
    public void refreshInitializationData(Boolean isSupportLandingPage) {
        currentKeyWord = null;
        if(isSupportLandingPage) {
            if(null == pum) {
                pum = new PicklistURLModeler();
            }
            else {
                pum.refreshInitializationData();
            }
        }
        else {
            mapArticleRating = new Map<Id, Double>();
            searchPerformed = False;
            if( ApexPages.currentPage().getParameters().containsKey('k'))
            {
                currentKeyWord = ApexPages.currentPage().getParameters().get('k');
                system.debug(currentKeyWord);
                searchPerformed = true;
            }
        }

        if(null == wsClientManager) {
            wsClientManager = new QESUnityWebServicesClientManager(0);
        }
    }

    /**
     * @description Constructor that calls super and then prepares filter criteria
     * based on URL parameters
     */
    public QESPKBModeler()
    {
        //super();
        pum = null;
        refreshInitializationData(false);
    }

    /**
     * @description Parameterized constructor which will be called if the source page is
     * SupportLandingPage
     */
    public QESPKBModeler(Boolean isSupportLandingPage)
    {
        pum = null;
        refreshInitializationData(true);
    }

    /**
     * @description An Object of String.
     * It determines Sort Order.
     */
    public String sortByClause {
        get {
            // When there is a keyword default order by to relevance.
            if( currentKeyword == Null || currentKeyword == '' )
                sortByClause = SORT_BY_MOST_VIEWED;
            else
                sortByClause = '';  // Blank is order by relevance.

            return sortByClause;
        }
        set;
    }

    /**
     * @description An Object of Set<String>.
     * Category type select maintained as GroupName:GroupValue
     */
    public Set<String> selectedCategoryNames {
        get {
            if( selectedCategoryNames == Null ) {
                selectedCategoryNames = new Set<String>();
                if( currentCategory != '' ) {
                    selectedCategoryNames.addAll( currentCategory.split( ',', 0 ) );
                }
            }
            return selectedCategoryNames;
        }
        set;
    }

    /**
     * @description An Object of List<QES_Unity_Category_Group__c>.
     * List of category group configurations based on site name setup in QES Site setup.
     */
    public List<QES_Unity_Category_Group__c> listPKBCategoryGroups {get; set;}

    /**
     * @description Method to initialize the listPKBCategoryGroups list.
     */
    public void initListPKBCategoryGroups() {
        if( listPKBCategoryGroups == null ) {
            //try {
                listPKBCategoryGroups = [Select
                                             Root_Category__c, Ordinal__c, Name, Level_or_Depth__c, LastModifiedDate,
                                             LastModifiedById, IsDeleted, Inactive__c, Id,  CreatedDate,
                                             CreatedById, Category_Group_Name__c, Category_Group_Label__c, Ancestors_Of__c, Show_On_Navbar__c
                                         From
                                             QES_Unity_Category_Group__c
                                         Where
                                             Inactive__c != True
                                         Order By Ordinal__c
                                         ];
             //}
             //catch (QueryException  e) {
             //    listPKBCategoryGroups = new List<QES_Unity_Category_Group__c>();
             //}
        }
    }

    /**
     * @description A static object of List<QES_Unity_PKB_Top_Article__c>
     * List of top articles configured to be renderd on PKB landing page.
     */
    public List<QESUnityTopArticle> listPKBTopArticles {

        get {
            if( listPKBTopArticles == Null ) {
                listPKBTopArticles = wsClientManager.getTopArticlesList(8, null);
            }
            return listPKBTopArticles;
        }
        set;
    }
    
    /**
     * CR 83883
     * @description A static object of List<QES_Unity_PKB_Top_Article__c>
     * List of top documents configured to be renderd on support landing page.
     */
    public List<QESUnityTopArticle> listTopDocuments {

        get {
            if( listTopDocuments == Null ) {
                listTopDocuments = wsClientManager.getTopArticlesList(8, 'SUP_HOME_TOP_DOC');
            }
            return listTopDocuments;
        }
        set;
    }

    /**
     * @description An object of String
     */
    public String noFilterLabel {
        get {
            return NO_FILTER_LABEL;
        }
    }

    /**
     * @description An object of String
     */
    public String noFilterValue {
        get {
            return NO_FILTER_VALUE;
        }
    }

    /**
     * @description An object of String
     */
    public String articleBaseUrl {
        get {
            return siteUrl + PKB_ARTICLE_PREFIX;
        }
    }

    /**
     * @description An object of String
     */
    public String siteUrl {

        get {
            return Site.getCurrentSiteUrl();
        }
    }

    /**
     * @description An object of Boolean
     */
    public Boolean searchPerformed {
        get;
        set;
    }

    /**
     * @description An object of Integer.
     * Note: This proprty is introduced to handle two different needs.
     * 1. force user to page one anytime when they change category filter. Based search performed flag it returns 1
     * 2. The setter method is introdudced to get around a defect with component attribute not handling integer parameters.
     * Defect: Comonent parameter gets converted to real number and subsequent code ran into a runtime error
     * Workaround: Set the attribute to this property to ensure we pass an integer for current page URL parameter.
     */
    public Integer QESCurrentPageNumber = 1;

    public String getQESCurrentPageNumber() {
        return '' + QESCurrentPageNumber;
    }

    public void incrementPageNumber() {
        QESCurrentPageNumber++;
        currentPageNumber = QESCurrentPageNumber;
    }

    public void decrementPageNumber() {
        QESCurrentPageNumber--;
        currentPageNumber = QESCurrentPageNumber;
    }



    /**
     * @description An object of List<CategoryGroupSelection>.
     * Property that wraps category group configuration to capture selected
     * caregory group item.
     */
    public List<CategoryGroupSelection> listCategoryGroupSelection {

        get {

            if( listCategoryGroupSelection == Null ) {
                listCategoryGroupSelection = new List<CategoryGroupSelection>();
                initListPKBCategoryGroups();
                for( QES_Unity_Category_Group__c grpConf : listPKBCategoryGroups ) {

                    CategoryGroupSelection grpSelection = new CategoryGroupSelection( grpConf );
                    checkCurrentSelection( grpSelection );
                    listCategoryGroupSelection.add( grpSelection );
                }
            }
            return listCategoryGroupSelection;
        }
        set;
    }

    /**
     * @description A wrapper method to base implementation that returns a NONE when
     * current category is null.
     */
    public String getQESCurrentCategory()
    {
        if( currentCategory == Null || currentCategory == '' )
            currentCategory = NO_FILTER_VALUE;

        return currentCategory;
    }

    /**
     * @description Method that takes selected category values and converts into a coma
     * seperated string to be used as a filter with article list tag.
     * Note: This method passes a blank when no category filters are selected.
     */
    public String getCategoryFilters()
    {
        // return stringify( selectedCategoryNames );
        // Note: Quick hack to get category passed around pages
        // TODO: Need to revisit this later.
        // currentCategory = stringify( selectedCategoryNames );
        if( currentCategory != NO_FILTER_VALUE )
            return currentCategory;

        return '';
    }

    /**
     * @description The setter method for currentCategory
     */
    public void setCategoryFilters(String filters)
    {
           currentCategory=filters;
    }

    /**
     * @description Method to check if there are valid filters to render articles.
     */
    public Boolean getFiltersFound()
    {
        if( ( currentCategory != Null && currentCategory.length() > 0 ) ||
            ( currentKeyword != Null && currentKeyword.length() > 0 ) )
        {
            return True;
        }
        return False;
    }

    /**
     * @description Method that returns the URL for this page
     */
    public String getQESSearchUrl() {
        return QES_URL_SEARCH;
    }

    /**
     * @description Method that returns list view URL
     */
    public String getQESListViewUrl() {
        return QES_URL_ListView;
    }

    /**
     * @description An object of Boolean
     */
    public boolean showTopArtciles{get;set;}


    /**
     * @description Method that gets called when user clicks search.
     * This method prepares search criteria to be passed as parameter to
     * Article List tag.
     */
    public PageReference doQESSearch()
    {
        if(currentKeyword == 'Type Questions or Keywords')
        {
           currentKeyword = '';
        }

        if(searchCriteria != '' && searchCriteria != null)
        {
         if(searchCriteria.split(':')[1] != NO_FILTER_VALUE)
          searchMap.put(searchCriteria.split(':')[0], searchCriteria.split(':')[1]);
         else
         {
            if(searchMap.containsKey(searchCriteria.split(':')[0]))
            {
             searchMap.remove(searchCriteria.split(':')[0]);
            }
            if(ApexPages.currentPage().getParameters().containsKey(searchCriteria.split(':')[0]))
            {
             ApexPages.currentPage().getParameters().remove(searchCriteria.split(':')[0]);
            }
         }
        }
        selectedCategoryNames.clear();
        String valueSelected = Null;
        searchPerformed = True;

        if(showTopArtciles == true)
        {
            showTopArtciles = false;
        }

        // First get search category parameters
        for( CategoryGroupSelection cgs : listCategoryGroupSelection ) {
           if(searchMap.containsKey(cgs.categoryGroup.Category_Group_Name__c))
           {
            ApexPages.currentPage().getParameters().put(cgs.categoryGroup.Category_Group_Name__c, cgs.categoryGroup.Category_Group_Name__c + ':' +searchMap.get(cgs.categoryGroup.Category_Group_Name__c));
           }
            valueSelected = paramByParamId( cgs.categoryGroup.Category_Group_Name__c, NO_FILTER_VALUE );

                addToCurrentCategoryFilter( valueSelected );
                cgs.selectedGroupItem = valueSelected;
        }
        QesCurrentPageNumber = 1;
        return null;
    }

    /**
     * @description Method that gets called when there is a need of redirection to
     * searchunity page.
     */
    public PageReference redirectToSearchUnity()
    {
        if(searchkeyword == 'Type Questions or Keywords')
        {
            searchkeyword = '';
        }
        PageReference pg = new PageReference('/apex/supportanswers?k=' + searchkeyword);
        pg.setRedirect(false);
        doQESSearch();
        return pg;
    }

    /**
     * @description Method to add current category filter selection to a set that gets
     * mapped into current category.
     * Note: values passed should be <categoryGroup>:<categoryValue>
     */
    private void addToCurrentCategoryFilter( String filter )
    {
        // Making sure we don't add None when we already have a filter
        if( filter.contains(NO_FILTER_VALUE)) {

            if( selectedCategoryNames.isEmpty() )
                selectedCategoryNames.add( NO_FILTER_VALUE );
        }
        else if( selectedCategoryNames.contains( NO_FILTER_VALUE ) ) {
            selectedCategoryNames.remove( NO_FILTER_VALUE );
            selectedCategoryNames.add( filter );
        }
        else {
            selectedCategoryNames.add( filter );
        }
        currentCategory = stringify( selectedCategoryNames );
    }

    /**
     * @description Method to check if there is a selection for current category group
     * that is being processed. This method takes a category group selection
     * object compares with current list of category selection set, if a match
     * found marks the value as selected value.
     * This method helps to select appropriate values for category filters.
     */
    private void checkCurrentSelection( CategoryGroupSelection grpSelection )
    {
        for( String categoryValue : selectedCategoryNames ) {
            // Check for category group name + ':'
            if( categoryValue != null &&
                categoryValue.startsWith( grpSelection.categoryGroup.Category_Group_Name__c + ':') ) {
                    grpSelection.selectedGroupItem = categoryValue;

                    return;
            }
        }
    }

    /**
     * @description Utility methods to be moved to a utility class
     */
    private String stringify( List<String> listStrings, String delimiter )
    {
        String delimitedString = '';
        delimiter = ( delimiter == Null ) ? ',' : delimiter;

        for( String str : listStrings ) {

            if( delimitedString != '' ) {
                delimitedString = delimitedString + delimiter;
            }
            delimitedString = delimitedString + str;
        }
        return delimitedString;
    }

    /**
     * @description Utility methods to be moved to a utility class
     */
    private String stringify( List<String> listStrings )
    {
        return stringify( listStrings, Null );
    }

    /**
     * @description Utility methods to be moved to a utility class
     */
    private String stringify( Set<String> listStrings )
    {
        List<String> newList = new List<String>();
        newList.addAll( listStrings );

        return stringify( newList );
    }

    /**
     * @description Method to clear all filters
     */
    public void clearAllFilters()
    {
        searchCriteria = '';
        ApexPages.currentPage().getParameters().clear();
        searchMap.clear();
        doQESSearch();
    }
       

    /**
     * @description
     * Child wrapper class to contain category group configuration and selection
     */
    public class CategoryGroupSelection {

        public QES_Unity_Category_Group__c categoryGroup { get; set; }
        public String selectedGroupItem { get; set; }
        public CategoryGroupSelection( QES_Unity_Category_Group__c argCategoryGroup )
        {
            this.categoryGroup = argCategoryGroup;

            // Default to No filtering
            this.selectedGroupItem = NO_FILTER_VALUE;
        }
    }

    public PageReference redirectToPlatformApp() {
        PageReference pg = new PageReference('/apex/' + hiddenInputField);
        pg.setRedirect(false);
        return pg;
    }
    
     public PageReference getArticleRating()
     {
        system.debug('#### Inside the getArticleRating function');
        
        blnShowArticles = true;
        List<ID> lstArticleId = new List<ID>();
        List<KnowledgeArticleVoteStat> lstKAV = new List<KnowledgeArticleVoteStat>();
        
        if (strArticleIdList != null && strArticleIdList != '')
        {
            for(String str : strArticleIdList.split(',')) {
                if(str != null && str != '') {
                    lstArticleId.add(str);
                }
            }
        }
        
        lstKAV = [
                  select 
                      NormalizedScore, 
                      channel,
                      parentid
                  from 
                      KnowledgeArticleVoteStat 
                  where 
                      parentid IN :lstArticleId and
                      isDeleted = false and 
                      channel = 'AllChannels' 
                  limit 
                      :lstArticleId.size()
                ];
        
        for(Id aId : lstArticleId)
        {
            for(KnowledgeArticleVoteStat vote : lstKAV)
            {
                if(vote.ParentId == aId)
                {
                    mapArticleRating.put(aId, vote.NormalizedScore);
                    break;
                }
            }
        }
        

        return null;
     }


    /*-------------------- Private Members ----------------------*/
    private QESUnityWebServicesClientManager wsClientManager;
}