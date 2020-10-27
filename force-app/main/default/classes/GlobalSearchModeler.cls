/**
 * @description A modeler class for SearchUnitySupport, DocumentList, 
 * MoreArticlePage pages.
 * @author Avinash
 * @modified by Amrita
*/
public class GlobalSearchModeler
{
    /**
     *@description List of ContentVersion. Will contain ids returned through sosl 
     *query
     */ 
    public List<ContentVersion> lstContentVersion; 
    
    /**
     *@description String variable to hold searchText value from URL 
     */
    public String searchValue {get;set;} 
    
    /**
     *@description String variable to hold retURL value from URL
     */
    public String returnURL  {get;set;}
    
    /**
     *@description List of contentversion Id
     */
    public List<Id> lstId = new List<Id>();
    
    /**
     *@description contains list of content version.
     */
    public List<ContentVersion> lstContent;
    
    /**
     *@description list variable to store list of SObject   
     */
    public List<List<SObject>> lst;
    /**
     *@description boolean variable to render more link in front end
     */
    public boolean blnRedirect{get;set;}{blnRedirect= false;} 
    
    /**
     *@description integer variable to hold current page number
     */
    public Integer CurrentPageNumber{get;set;}{CurrentPageNumber = 1;}
        
    /**
     *@description integer variable to store number of rows to be rendered 
     *in frontend 
     */
    public Integer intInternalRows {get;set;}
    
    /**
     *@description integer variable to store first row to be rendered 
     *in frontend 
     */
    public Integer intFirst {get;set;}
    
    /**
     *@description boolean variable to render next button
     *in frontend 
     */
    public Boolean blnMoreProducts {get;set;}
    
    /**
     *@description boolean variable to render prevoius button
     *in frontend 
     */
    public Boolean blnPrevious{get;set;}
    
    /**
     *@description variable to render output panel in front end
     */
    public Boolean blnshowErr {get; set;}{blnshowErr = false;}
    
    /**
     *@description boolean value to check if searchText param is present in URL
     */
    public Boolean blnCheckUrlParameter {get; set;} {blnCheckUrlParameter = true;}
    
    public String hiddenInputField {get; set;} {hiddenInputField = '';}
    
    /**
     * @description Default Constructor
     */
    public GlobalSearchModeler() {        
        refreshInitializationData();        
    }
    
    /**
     * @description Method to refresh the initialization-data for the 
     * variables of this class
     */
    public void refreshInitializationData() {       
        resetAllData();
        returnURL = ApexPages.currentPage().getParameters().get('retURL');        
       // if(true == blnCheckUrlParameter) {
          //  searchValue = null;            
            searchValue = Apexpages.currentPage().getParameters().get('searchText');
       // }
       
       System.debug('*************** searchValue : ' +searchValue);
        
       system.debug('@@@@@@@@@searchValue'+searchValue);
        lstContent = new List<ContentVersion>();
        if(searchValue != null && searchValue != '')
            populateLstContent();
    }
    
    /**
     *@description getter method for lstContent
     *returns list of ContentVersion to front end
     */
    public List<ContentVersion> getLstContent() {
        return lstContent;
    }
    
    
               
    /**
     *@description method to query contentversion from salesforce
     */    
    public void populateLstContent()
    {
        intFirst = 0;
        intInternalRows = 10;
        lst = null;
        /*Change for  CR 00083883*/
        if(UserInfo.getUserType() != 'Standard')
        {
            lst = [ FIND 
                    :searchValue 
                IN 
                    NAME FIELDS RETURNING ContentVersion(id 
                    where 
                         Internal_Use_Only__c = false and
                         isLatest = true and 
                         Document_Category__c = 'Documentation' and 
                         Product__c <> null and 
                         Type__c <> null
                     ) 
                LIMIT 200
              ];
        }
        else
        {
            lst = [ FIND 
                    :searchValue 
                IN 
                    NAME FIELDS RETURNING ContentVersion(id 
                    where 
                         isLatest = true and 
                         Document_Category__c = 'Documentation' and 
                         Product__c <> null and 
                         Type__c <> null
                     ) 
                LIMIT 200
              ];
        }
        /*lst = [ FIND 
                    :searchValue 
                IN 
                    ALL FIELDS RETURNING ContentVersion(id 
                    where                         
                         isLatest = true and 
                         Document_Category__c = 'Documentation' and 
                         Product__c <> null and 
                         Type__c <> null
                     ) 
                LIMIT 200
              ];*/
        
        if(lst != null)
            lstContentVersion = lst[0];
        
        if(lstContentVersion != null && lstContentVersion.size() > 0)
            for(ContentVersion cv : lstContentVersion)
            {
                  System.debug('***************** content version id:' + cv.id);    
                  lstId.add(cv.id);
            }
         System.debug('***************** lstId' + lstId);
         if(lstId.size() == 0)
         {
            errCnt++;
            if(errCnt > 0)
                blnshowErr = true;
         }
        
        if(lstId != null && lstId.size() > 0)
        {  
            /*lstContent = [ Select 
                               c.Title, 
                               c.CreatedDate , 
                               c.Description, 
                               c.Orderable__c, 
                               c.Id, 
                               c.ContentDocumentid, 
                               c.ContentUrl,
                               c.Type__c  
                           From 
                               ContentVersion c 
                           where 
                               c.id in :lstId 
                           limit 1000
                         ];
            if(lstContent.size()!=0)
            {
                
                if(lstContent.size()>10)
                    blnRedirect= true;
                else
                    blnRedirect= false; 
            }*/
            /*Change for  CR 00083883*/
            Map<Id,ContentVersion> mapOfContent = new Map<Id,ContentVersion>([ Select 
                               c.Title, 
                               c.CreatedDate , 
                               c.Description, 
                               c.Orderable__c, 
                               c.Id,
                               C.Internal_Use_Only__c, 
                               c.ContentDocumentid, 
                               c.ContentUrl,
                               c.Type__c  
                           From 
                               ContentVersion c 
                           where 
                               c.id in :lstId 
                           limit 1000
                         ]);
            
            for(Id i : lstId)
            {
                if(mapOfContent.containsKey(i))
                lstContent.add(mapOfContent.get(i));
            }
            
            if(lstContent.size()!=0)
            {
                
                if(lstContent.size()>10)
                    blnRedirect= true;
                else
                    blnRedirect= false; 
            }
        }
        
        
        
        if(lstContent.size() >= intInternalRows )
            blnMoreProducts = true;
        else
            blnMoreProducts = false;    
        blnPrevious = false;
    }
    
    /**
     *@description method to show next list of articles in MoreArticlePage 
     */
    public void incrementPageNumber() {
        CurrentPageNumber++;
        currentPageNumber = CurrentPageNumber;
    }
    
    /**
     *@description method to show previous list of articles in MoreArticlePage 
     */
    public void decrementPageNumber() {
        CurrentPageNumber--;
        currentPageNumber = CurrentPageNumber;
    }

    /**
     *@description method to show next list of documents in documnetList page
     */
    public Pagereference NextContent()
    {
        count++;
        intFirst+=intInternalRows ;
        if(lstContent.size() >0)
        {    
            if((lstContent.size() - (count * intInternalRows ) > 0))
                blnMoreProducts = true;
            else
                blnMoreProducts = false;
            blnPrevious = true;
        }
        return null;
    }
    
    /**
     *@description method to show previous list of documents in documentList page
     */
    public Pagereference PreviousContent()
    {
        count--;
        intFirst-=intInternalRows ;
        if(intFirst == 0)
            blnPrevious = false;
        blnMoreProducts = true;
        return null;
    }
   
    /**
     *@description method to fetch URL from cookie
     */
    public PageReference redirectToArticles()
    {
        PageReference pg = new PageReference('/apex/' + hiddenInputField);
        pg.setRedirect(false);
        return pg;
    }

    /*-------------------------------- PRIVATE MEMBERS -------------------------*/

    private Integer errCnt= 0;
    private Integer count = 1;

    /**
     * @description Method to reset all the variables 
     */
    private void resetAllData() {
        lstContentVersion = null; 
        returnURL = null;
        lstId = new List<Id>();
        lstContent = null;
        lst = null;
        blnRedirect= false;
        blnshowErr = false;
        intInternalRows = 0;
        count = 1;
        intFirst = 0;
        blnMoreProducts = false;
        blnPrevious = false;        
    }
}