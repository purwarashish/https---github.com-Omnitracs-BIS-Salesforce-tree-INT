/**@Description: This class contains the logic for display articles based
  *on the currentKeyword and filterCriteria selected in SRaySupportAnswers
  *@author:Amrita Ganguly
  *@date:21st June,2012
*/

public class SrSearchArticalModeller extends KnowledgeController
{

    /**
     * @description: This string contain the category Name and the value selected
     * in the following formate category name:value.
     * This value is received from frontend. 
     */
    public String searchCriteria{get;set;}

    /**
     * @description :Used to keep track of the page number based on
     * which the next and the previous button is rendered in the vf page.
     */
    public Integer QESCurrentPageNumber{get; set;}{QESCurrentPageNumber = 1;} 
    
    /**
     * @description An Object of List<QES_Unity_Category_Group__c>.
     * This list contains records of object QES_Unity_Category_Group__c 
     */
    public List<QES_Unity_Category_Group__c> listPKBCategoryGroups {get; set;}
    
    /**
     * @description A Static String constant
     */
    private final String NO_FILTER_LABEL = '-- No filter --';
    
    /**
     * @description:Used in narrow search section of the vf page 
     */
    public String noFilterLabel{get;set;}{noFilterLabel= NO_FILTER_LABEL;}
    
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
                    listCategoryGroupSelection.add( grpSelection );
                }
            }
            return listCategoryGroupSelection;
        }
        set;
    }
  
   /**
     * @description An object of Map<String, String>
     */
    public Map<String, String> searchMap = new Map<String, String>();

    private static final String NO_FILTER_VALUE = 'NONE';
    
    /**
     * @description : Stores value equal to None
     */
    public String noFilterValue {get; set;}{noFilterValue = NO_FILTER_VALUE;}

    /**
     * @description Constructor sets the currentKeyword to null 
     */
    public SrSearchArticalModeller()
    {
        currentKeyWord = null;
    }
  
   /**
     * @description Method to initialize the listPKBCategoryGroups list.
     */
    public void initListPKBCategoryGroups()
    {
        if( listPKBCategoryGroups == null ) {
            
                listPKBCategoryGroups = [Select
                                             Root_Category__c, Ordinal__c, 
                                             Name, Level_or_Depth__c, 
                                             Category_Group_Name__c,
                                             Category_Group_Label__c, 
                                             Ancestors_Of__c, 
                                             Show_On_Navbar__c
                                         From
                                             QES_Unity_Category_Group__c
                                         Where
                                             Inactive__c != True
                                         Order By Ordinal__c ];
        }
    }
     
    /**@Description:This method increments the page number
      */
    public void incrementPageNumber() {
        QESCurrentPageNumber++;
        
    }

    /**@Description:This method decrements the page number
      */
    public void decrementPageNumber() {
        QESCurrentPageNumber--;
        
    }

    /**
     * @description Method that takes selected category values and converts into a coma
     * seperated string to be used as a filter with article list tag.
     * Note: This method passes a blank when no category filters are selected.
     */
    public String getCategoryFilters()
    {
        if( currentCategory != NO_FILTER_VALUE )
            return currentCategory;

        return '';
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
     * @description The setter method for currentCategory
     */
    public void setCategoryFilters(String filters)
    {
           currentCategory=filters;
    }
   
   /**
     * @description Method that gets called when user clicks search.
     * This method prepares search criteria to be passed as parameter to
     * Article List tag.
     */
    public pageReference doQESSearch()
    {
        system.debug('@@@@currentKeyword'+currentKeyword);
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
        List<String> lstSelectedCategoryNames = new List<String>();
        lstSelectedCategoryNames.addAll( selectedCategoryNames );
        currentCategory = stringify( lstSelectedCategoryNames , null );
    }

   /**
     * @description : This method returns the category selection separeted
     * by comma
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
}