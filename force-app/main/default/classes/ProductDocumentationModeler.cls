public class ProductDocumentationModeler 
{

    public PlatformAppModeler pam {get; set;}
    public List<ContentVersion > lstCmVer {get;set;} 
    public List<ContentVersion > lstAllProducts {get;set;} 
    {
        lstAllProducts =  new List<ContentVersion >();
    }
    public Set<String> setAllProducts {get;set;} {setAllProducts =  new Set<String>();}
    public String productType{get;set;} {productType = '';}
    public String docType{get;set;} {docType = '';}
    public String headerType{get;set;} {headerType= '';}
    
    
    public Integer intFirst {get;set;}
    public Integer groupHeaderCounter {get;set;} {groupHeaderCounter = 0;}
    public List<ContentVersion > lstCV {get;set;} {lstCV =  new List<ContentVersion >();}
    public Set<String> setPrdct {get;set;} {setPrdct =  new Set<String>();}
    public List<String> lstProduct {get;set;}
    public List<String> lstType {get;set;}
//Following Rows variables are set in constructor
    public Integer intProductRows {get;set;}
    public Integer intInternalRows {get;set;}
    public Integer count = 1;
    public Integer count2 = 1;
    private Set<String> setType = new Set<String>();

//Product Catatlog Link
    public String strProductCatalogLink {get;set;}
    public List<ContentVersion> lstLocal {get;set;}
    
    public Boolean blnMoreProducts {get;set;}
    public Boolean blnPrevious{get;set;}
    public Boolean blnMoreTypes {get;set;}
    
    public String titleBarString {get; set;}
    public String docTypeShort {get; set;}
    
    private String productCriteria = 'Product__c != null';
    private String headerCriteria = 'Type__c != null';
    private String docTypeCriteria = 'Document_Category__c != null';


    Map<String,List<ContentVersion>> mapLocal = new Map<String,List<ContentVersion>>();
    public List<ContentVersion> lstTrainingDocs {get;set;}
    public List<ContentVersion> lstHardwareDocs {get;set;}
    public List<ContentVersion> lstApplicationDocs {get;set;}
    
    public String hiddenInputField {get; set;} {hiddenInputField = '';}
    
    /*************************************************************/
    /*Answer center enhancements*/
    
    /*
    List of alphabets to be used as filters
    */
    
    public List<String> getlistOfFilters()
    {
        List<String> listOfFilters = new List<String>();
        listOfFilters.add('A');
        listOfFilters.add('B');
        listOfFilters.add('C');
        listOfFilters.add('D');
        listOfFilters.add('E');     
        listOfFilters.add('F');
        listOfFilters.add('G');
        listOfFilters.add('H');
        listOfFilters.add('I');
        listOfFilters.add('J');
        listOfFilters.add('K');
        listOfFilters.add('L');
        listOfFilters.add('M');
        listOfFilters.add('N');
        listOfFilters.add('O');
        listOfFilters.add('P');
        listOfFilters.add('Q');
        listOfFilters.add('R');
        listOfFilters.add('S');    
        listOfFilters.add('T');
        listOfFilters.add('U');
        listOfFilters.add('V');
        listOfFilters.add('W');
        listOfFilters.add('X');
        listOfFilters.add('Y');
        listOfFilters.add('Z');
        listOfFilters.add('All'); 
        return listOfFilters;
        
    }
   
    /*
    Filter for Application
    */
    public String appFilter{get;set;}
     /*
    Filter for Hardware
    */
    public String HWFilter{get;set;}
     /*
    Filter for Training
    */
    public String TrainingFilter{get;set;}
    
    public List<ContentVersion> getlstFilteredApplicationDocs()
    {
        List<ContentVersion> tempList = new List<ContentVersion> ();
        if(appFilter == 'All')
        {
            return lstApplicationDocs;
        }
        else
        {
            for(ContentVersion doc :lstApplicationDocs)
            {
                if(doc.title.startsWith(appFilter))
                {
                    tempList.add(doc);
                }
            }
        }
        return tempList;
    } 
    public List<ContentVersion> getlstFilteredHardwareDocs()
    {
        List<ContentVersion> tempList = new List<ContentVersion> ();
        if(HWFilter == 'All')
        {
            return lstHardwareDocs;
        }
        else
        {
            for(ContentVersion doc :lstHardwareDocs)
            {
                if(doc.title.startsWith(HWFilter))
                {
                    tempList.add(doc);
                }
            }
        }
        return tempList;
    } 
    public List<ContentVersion> getlstFilteredTrainingDocs()
    {
        List<ContentVersion> tempList = new List<ContentVersion> ();
        if(TrainingFilter == 'All')
        {
            return lstTrainingDocs;
        }
        else
        {
            for(ContentVersion doc :lstTrainingDocs)
            {
                if(doc.title.startsWith(TrainingFilter))
                {
                    tempList.add(doc);
                }
            }
        }
        return tempList;
    } 
    
    public pageReference filterAppList()
    {
        intFirstRowApplication = 0;
        return null;
    }
    public pageReference filterHWList()
    {
        intFirstRowHardware = 0;
        return null;
    }
    public pageReference filterTrainingList()
    {
        intFirstRowTraining = 0;
        return null;        
    }
    
    /*************************************************************/
    
    
    
    public Pagereference next()
    {
        count++;
        intFirst+=intProductRows;
        if(productLevelMap != null && productLevelMap.size() >0)
        {    
            if((productLevelMap.size() - (count * intProductRows) > 0))
                blnMoreProducts = true;
            else
                blnMoreProducts = false;
            blnPrevious = true;
        }
        return null;
    }
    
    public Pagereference previous()
    {
        count--;
        intFirst-=intProductRows;
        if(intFirst == 0)
            blnPrevious = false;
        blnMoreProducts = true;
        return null;
    }
    public Pagereference NextContent()
    {
        count2++;
        intFirst+=intInternalRows ;
        if(lstLocal != null && lstLocal.size() >0)
        {    
            if((lstLocal.size() - (count2 * intInternalRows ) > 0))
                blnMoreProducts = true;
            else
                blnMoreProducts = false;
            blnPrevious = true;
        }
        return null;
    }
    
    public Pagereference PreviousContent()
    {
        count2--;
        intFirst-=intInternalRows                                                                                                                ;
        if(intFirst == 0)
            blnPrevious = false;
        blnMoreProducts = true;
        return null;
    }
    
    Map<String,Set<ContentVersion>> mapSpltProd = new Map<String,Set<ContentVersion>>();
    public void setMapSpltProd (){this.mapSpltProd =mapSpltProd ;}
    public Map<String,Set<ContentVersion>> getMapSpltProd () {
        return mapSpltProd ;
    }
    public List<String> typeNames {get;set;} 
    public List<String> productNames {get;set;} 
    public Map<String, List<ContentVersion>> innerMap{get;set;} 
    
   public map<String,list<ContentVersion>> tempMap {get;set;}
   
   public Integer skip {get;set;} {skip = 0;}
   
   public  ProductDocumentationModeler ()
   {
       refreshInitializationData();    
   }
 
    public Map<String, Map<String, List<ContentVersion>>> productLevelMap {get;set;}

    public Pagereference  refreshInitializationData()
    {
        tempMap= new map<String,list<ContentVersion>>();
        
        clearAllData();
        try
        {    
            //Product Catalog Link
            strProductCatalogLink = 'http://www.google.com';
            
            docType= string.valueof(ApexPages.currentPage().getParameters().get('doctype'));
            
            productType= string.valueof(ApexPages.currentPage().getParameters().get('prodtype'));
            
            headerType= string.valueof(ApexPages.currentPage().getParameters().get('headertype'));            
            
            if(ApexPages.CurrentPage().getParameters().containskey('skip'))
                skip = integer.valueof(ApexPages.currentPage().getParameters().get('skip'));
            
            //The following values are hardcoded, need to be changed when the no. of items per list has to be increased
                intFirst = 0;
                intProductRows = 5;
                intInternalRows = 5;
                
                if(docType== 'DOC') {
                    docType= 'Documentation';
                    docTypeShort = 'DOC';
                }
                else if(docType== 'CFA') {
                    docType= 'Customer/Field Alerts';
                    docTypeShort = 'CFA';
                }
                if(docType!= null && docType != '')    
                    docTypeCriteria = 'Document_Category__c =\'' +docType+ '\'';
                    pam = new PlatformAppModeler(null);
                if(productType!= null && productType!= '')
                {
                    productCriteria =  'Product__c INCLUDES(\'' +productType + '\')';
                    pam = new PlatformAppModeler(productType);            
                }
                if(headerType!= null && headerType!= '')
                {
                    headerCriteria = 'Type__c INCLUDES(\'' +headerType+ '\')'; 
                    pam = new PlatformAppModeler(null);
                }
                docType = String.isNotBlank(docType) ? docType : 'Documentation';                                 
                //String totalQuery = 'SELECT Id,ContentDocumentId,Product__c,Description,title,orderable__c,Type__c FROM ContentVersion WHERE ' + docTypeCriteria + ' AND ' + productCriteria + ' AND ' + headerCriteria  + ' AND ' + 'isLatest =true ORDER BY title LIMIT 5000';
                                 
                //lstCmVer = Database.query(totalQuery);
				String queryStr = 'SELECT Id,ContentDocumentId,Product__c,Description,title,orderable__c,Type__c FROM ContentVersion WHERE ' + docTypeCriteria + ' AND ' + productCriteria + ' AND ' + headerCriteria  + ' AND ' + 'isLatest =true ORDER BY title LIMIT 5000';
				List<CommunityUserSettings__mdt> comUserSettings = [SELECT Value__c FROM CommunityUserSettings__mdt WHERE DeveloperName = 'SharedFileIds'];
				if(comUserSettings.size() > 0){
					CommunityUserSettings__mdt rec = comUserSettings.get(0);
					queryStr = 'SELECT Id,ContentDocumentId,Product__c,Description,title,orderable__c,Type__c FROM ContentVersion WHERE Document_Category__c = \'' + docType + '\' AND Product__c != null AND Type__c != null AND isLatest = true AND ContentDocumentId IN (' + rec.Value__c + ') ORDER BY title';
				}
                lstCmVer = Database.query(queryStr);
           
                if(lstCmVer.size() > 0 ){
                   productLevelMap = new Map<String, Map<String, List<ContentVersion>>>();
                   for(ContentVersion  cmVer: lstCmVer)
                    {
                        if(112 < cmVer.title.length()) {
                            cmVer.title = cmVer.title.subString(0, 112) + '...';
                        }
                        // Processing a record
                        typeNames = cmVer.Type__c.split(';');
                        productNames = cmVer.Product__c.split(';');
                        
                        
                        // For ever product in this record, let us update the data-structures
                        for(Integer j = 0; j < productNames.size(); j++) 
                        {
                            // Get the product's map                            
                            innerMap = productLevelMap.get(productNames[j]);
                            if(null == innerMap)
                            {
                                // We never encountered such a product till-date
                                innerMap = new Map<String, List<ContentVersion>>();                                                                                                     
                            }

                            // Update all the 'GROUP HEADERS' for this product
                            for(Integer k = 0; k < typeNames.size(); k++)
                            {
                                setType.add(typeNames[k]);
                                List<ContentVersion> lstForCVHeader =
                                            innerMap.get(typeNames[k]);
                                if(null == lstForCVHeader)
                                {
                                    // We never encountered such a header for this 
                                    // product till-date
                                    lstForCVHeader = new List<ContentVersion>();                                                                                                    
                                }   

                                lstForCVHeader.add(cmVer);
                                innerMap.put(typeNames[k], lstForCVHeader);

                            } // End - for(k)
                            productLevelMap.put(productNames[j], innerMap);                                 
                        }// End - for(j)
                    } // End - for(cmVer) 
                    setPrdct =  productLevelMap.keySet();               
                    
                    
                    lstProduct = new List<String>();  
                    for(String str:setPrdct) {
                        lstProduct.add(str);  
                    }                                        
                        
                    lstType = new List<String>();  
                    for(String str:setType) {
                        lstType.add(str);  
                    }
                    
                    lstProduct.sort();
                    lstType.sort();          
                }
                if(productLevelMap.size() > intProductRows)
                    blnMoreProducts = true;
                blnPrevious = false;
            //}

            for(String str : lstType)
            {
                if(str.equalsIgnoreCase('hardware') && productLevelMap != null && productLevelMap.get(productType) != null)
                {
                    lstHardwareDocs = productLevelMap.get(productType).get('Hardware');
                    //sscHardwareDocs = new ApexPages.StandardSetController(lstHardwareDocs );
                }
                    
                else if(str.equalsIgnoreCase('application') && productLevelMap != null && productLevelMap.get(productType) != null)
                {
                    lstApplicationDocs = productLevelMap.get(productType).get('Application');
                    //sscApplicationDocs = new ApexPages.StandardSetController(lstApplicationDocs );
                }
                    
                else if(str.equalsIgnoreCase('training') && productLevelMap != null && productLevelMap.get(productType) != null)
                {
                    lstTrainingDocs  = productLevelMap.get(productType).get('Training');
                    //sscTrainingDocs = new ApexPages.StandardSetController(lstTrainingDocs  );
                }
            }
            
            
            //The following condition will evaluate only for ContentList Page
            if((productType != null || productType != '') && (headerType != null || headerType != '') && productLevelMap.get(productType) != null)
            {
                intFirst = 0;
                intInternalRows = 5;
                mapLocal = productLevelMap.get(productType);
                lstLocal = mapLocal.get(headerType);
                
                if(lstLocal != null && lstLocal.size() > intInternalRows)
                        blnMoreProducts = true;
                    else
                        blnMoreProducts = false;    
                    blnPrevious = false;
                
            }
        }
        catch(Exception E)
        {
            System.debug('Exception thrown::' +e);
        }
        
        if( (null != headerType) && ('' != headerType) ) {
            titleBarString = docType + ' for ' + productType;
        }
        else {
            titleBarString = docType + ' for ' + productType;
        }
        if(60 < titleBarString.length()) {
            titleBarString = titleBarString.subString(0, 57) + '...';
        }
        return null;
    }
    
    public String getResultData() {
        String str = '<ul>';
        if(lstProduct != null)
        {
            for(Integer i = 0; i < lstProduct.size(); i++) 
            {
                str += '<li><a>' + lstProduct[i] + '</a>';
                Map<String, List<ContentVersion>> myInnerMap = productLevelMap.get(lstProduct[i]);
                Set<String> groupHeaderSet = myInnerMap.keySet();
                List<String> groupHeader = new List<String>();
                for(String tmpStr : groupHeaderSet) {
                    groupHeader.add(tmpStr);
                }
                groupHeader.sort();
                str += '<ul>';
                for(Integer j = 0; j < groupHeader.size(); j++) {
                    str += '<li><a class="submenuheader history-open">' + groupHeader[j] + '</a>';
                    List<ContentVersion> cvList = myInnerMap.get(groupHeader[j]);
                    str += '<ul>';
                    for(Integer k = 0; k < cvList.size(); k++) {
                        str += '<li><a>' + cvList[k].title + '</a></li>';
                    }
                    groupHeaderCounter = cvList.size(); 
                    str += '</ul>';
                    str += '</li>';
                }
                str += '</ul>';
                str += '</li>';
            }
        }
        str += '</ul>';
        return str;
    }
    
    public PageReference redirectTo() {
        PageReference pg = new PageReference('/apex/' + hiddenInputField);
        pg.setRedirect(false);
        return pg;
    }
    public void clearAllData(){
        blnMoreProducts = false;
        blnPrevious = false;
        blnMoreTypes = false;
       
        setPrdct.clear();
        setType.clear();
        productCriteria = 'Product__c != null';
        headerCriteria = 'Type__c != null';
        docTypeCriteria = 'Document_Category__c != null';                   
        docType = null;
        productType = null;
        headerType = null;
        
        //CR: Answer Center Enh
        appFilter = 'All';
        HWFilter = 'All';
        TrainingFilter = 'All';
    }
    
    
    public Integer intRows {get;set;} {intRows = 5;}
    public Integer intFirstRowTraining {get;set;} {intFirstRowTraining = 0;}
    public Integer intFirstRowHardware {get;set;} {intFirstRowHardware  = 0;}
    public Integer intFirstRowApplication {get;set;} {intFirstRowApplication  = 0;}
    
    public Pagereference getNextTrainingDocs()
    {
        intFirstRowTraining += 5;
        return null;
    }
    
    public Pagereference getPreviousTrainingDocs()
    {
        intFirstRowTraining -= 5;
        return null;
    }
    
    public Pagereference getNextHardwareDocs()
    {
        intFirstRowHardware += 5;
        return null;
    }
    
    public Pagereference getPreviousHardwareDocs()
    {
        intFirstRowHardware -= 5;
        return null;
    }
    
    public Pagereference getNextApplicationDocs()
    {
        intFirstRowApplication += 5;
        return null;
    }
    
    public Pagereference getPreviousApplicationDocs()
    {
        intFirstRowApplication -= 5;
        return null;
    }
    /*------------------------ PRIVATE MEMBERS -----------------------------*/  

}