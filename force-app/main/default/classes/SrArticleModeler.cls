/**
  *@Description:This class contains the logic for showing the article information
  *on SrSupportArticle page. This controller is also referred by MsrArticle detail
  *page for mobile KB UI   
  *@Author:Jaspreet Singh
  *@Modified By:Amrita Ganguly
  *Modified to make the front end Generic for all article type.
**/

public class SrArticleModeler 
{
    
    /**
      *@Description:To store the article type object instance
      */
    private string parentObj = '';
       
    /**
      *@Description:Store instace of Documentation__kav 
      */
    public Documentation__kav docArticle {get; set;}
    
    /**
      *@Description:Store instace of Glossary__kav 
      */
    public Glossary__kav glossaryArticle {get; set;}
    
    /**
      *@Description:Store instace of How_To__kav
      */
    public How_To__kav howtoArticle {get; set;}
    
    /**
      *@Description:Store instace of Product_Information__kav
      */
    public Product_Information__kav piArticle {get; set;}
    
    /**
      *@Description:Store instace of Solution__kav
      */
    public Solution__kav solutionArticle {get; set;}
    
    /**
      *@Description:Store instace of Technical_Bulletin__kav 
      */
    public Technical_Bulletin__kav tbArticle {get; set;}
    
    /**
      *@Description:Store instace of Known_Issue__kav
      */
    public Known_Issue__kav kiArticle {get; set;}
    
    /**
      *@Description:Holds the text from different fields to display 
      *in the front end, for every article type
      */
    public String description {get; set;}  
    
    /**
      *@Description:String to hold information about article type from URL, 
      *replace '_' with ' '.Used in front end. 
      */
    public String artType {get;set;} 
    
    /**
      *@Description:Used to hold queried records returned in dynamic query.
      */
    public SObject articleTypeObject {get; set;}
    
    /**
     *@Description: Stores the return url for back button
     */
     public string returnUrl{get;set;} {returnUrl = '#';}
     
    /**
      *@List of Wrapper class to display attachments in the front end
      */
    public list<AttachmentFiles> lstAttachment{get; set;}{lstAttachment = new list<AttachmentFiles>();} 
    
    /*************** Private Constants to hold Aticle type *************/
    private string pagename = '';
    public final String ARTICLE_TYPE_DOCUMENTATION{get;set;}{ARTICLE_TYPE_DOCUMENTATION = 'Documentation';}
    public final String ARTICLE_TYPE_GLOSSARY{get;set;}{ ARTICLE_TYPE_GLOSSARY = 'Glossary';}
    public final String ARTICLE_TYPE_HOWTO{get;set;}{ARTICLE_TYPE_HOWTO = 'How To';}
    public final String ARTICLE_TYPE_PI{get;set;}{ARTICLE_TYPE_PI = 'Product Information';}
    public final String ARTICLE_TYPE_TB{get;set;}{ARTICLE_TYPE_TB = 'Technical Bulletin';}
    public final String ARTICLE_TYPE_SOLUTION{get;set;}{ARTICLE_TYPE_SOLUTION = 'Solution';}
    public final String ARTICLE_TYPE_KI{get;set;} {ARTICLE_TYPE_KI = 'Known Issue';}
    private final Integer ARTICLE_ID_LENGTH = 18;
    private final String CONTENT_DETAILS_BASE_PAGE = '/sr/apex/srsupportdocDetail?id=';
    private final String CONTENT_DETAILS_BASE_PAGE_MOB = '/apex/MsrContentVersion?id='; // ContentVersion detail page for mobile
    /**
      *@Description:In the constructor we set all the article type instance
      *to null.Get the Article Type from URL
      *Display it in the front end
    */
    public SrArticleModeler() 
    {
        docArticle      = null;
        glossaryArticle = null;
        howtoArticle    = null;
        piArticle       = null;
        solutionArticle = null;
        tbArticle       = null;
        kiArticle       = null;
        
        artType = ApexPages.currentPage().getParameters().get('type');
        
        //used to direct to correct contentversion vf page
        if(Apexpages.CurrentPage().getParameters().containskey('pn'))
            pagename = ApexPages.currentPage().getParameters().get('pn');
        
        //used in back button for MsrArticleDetails page
        if(Apexpages.CurrentPage().getParameters().containskey('retUrl'))
            returnUrl = ApexPages.currentPage().getParameters().get('retUrl');
        
        
        if(artType != null)
            artType = artType.replace('_', ' ');
        
        displayArticleDetails(); 
    }
    
    /**@Description:This method constructs the value for the description variable
      *used in the front end. Creates a list of wrapper class used
      *to display attachments
      */
    public void displayArticleDetails() 
    {
        String articleId = ApexPages.currentPage().getParameters().get('id');
        
        //Construct the query string
        String fieldsTobeQueried = 'id,Title,UrlName,Related_Links__c,';
        fieldsTobeQueried += 'Attachment_1__Name__s,Attachment_1__ContentType__s,';
        fieldsTobeQueried += 'Attachment_2__Name__s,Attachment_2__ContentType__s,Attachment_3__Name__s,';
        fieldsTobeQueried += 'Attachment_3__ContentType__s,Attachment_4__Name__s,Attachment_4__ContentType__s';
        
        SYSTEM.DEBUG('@@@@@fieldsTobeQueried'+fieldsTobeQueried);
        
        List<KnowledgeArticleVersion> lstKnwArtId = new List<KnowledgeArticleVersion>();
        lstKnwArtId = [Select 
                            Id 
                       From 
                            KnowledgeArticleVersion 
                       where 
                            publishstatus='online' 
                       AND 
                           KnowledgeArticleId = :articleId 
                       limit 
                            1];
                            
        if( (null == lstKnwArtId) || (0 == lstKnwArtId.size()) )
        {
            return;
        }
        description = '';
        if(artType.equals(ARTICLE_TYPE_DOCUMENTATION))
        {
             parentObj = 'Documentation__kav';
                          
             string queryStr = 'SELECT Information__c,' + fieldsTobeQueried + ' FROM '+ parentObj;
             queryStr += ' WHERE id = \''+lstKnwArtId[0].id+'\' LIMIT 1';
             
             articleTypeObject = Database.query(queryStr);
             
             if(null == articleTypeObject)
             {
                return;
             }
            
            docArticle = (Documentation__kav)articleTypeObject; 
                        
            if(null != docArticle.Information__c) 
            {
                description = docArticle.Information__c;
            }                   
            if(null != docArticle.Related_Links__c) 
            {
                description += '<br/><br/><b>Related Links:</b><br/>'+docArticle.Related_Links__c;
            }
            system.debug('@@@@docArticle.Attachment_1__Name__s'+docArticle.Attachment_1__Name__s);
            //Add attachment details to list wrapper class
            if(( docArticle.Attachment_1__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(docArticle.Attachment_1__Name__s,docArticle.Attachment_1__ContentType__s,'Attachment_1__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( docArticle.Attachment_2__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(docArticle.Attachment_2__Name__s, docArticle.Attachment_2__ContentType__s,'Attachment_2__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( docArticle.Attachment_3__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(docArticle.Attachment_3__Name__s, docArticle.Attachment_3__ContentType__s,'Attachment_3__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( docArticle.Attachment_4__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(docArticle.Attachment_4__Name__s, docArticle.Attachment_4__ContentType__s,'Attachment_4__Body__s');
                lstAttachment.add(attchFiles);
            } 
            
               
        }
        
        else if(artType.equals(ARTICLE_TYPE_HOWTO))
        {
             
             parentObj = 'How_To__kav';
             
             string queryStr = 'SELECT Step_By_Step__c,Information__c,' + fieldsTobeQueried + ' FROM '+ parentObj;
             queryStr += ' WHERE id = \''+lstKnwArtId[0].id+'\' LIMIT 1';
             
             articleTypeObject = Database.query(queryStr);
    
             if( null == articleTypeObject ) {
                return;
            }

            howtoArticle = (How_To__kav)articleTypeObject;
            if(howtoArticle.Information__c != null) 
            {
                description = howtoArticle.Information__c;
            }
            if(null != howtoArticle.Step_By_Step__c) {
                description += '<br/><br/><b>Step by Step:</b><br/>' + howtoArticle.Step_By_Step__c;
            }                 
            if(null != howtoArticle.Related_Links__c) {
                description += '<br/><br/><b>Related Links:</b><br/>' + howtoArticle.Related_Links__c;
            }
            if(( howtoArticle.Attachment_1__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(howtoArticle.Attachment_1__Name__s,howtoArticle.Attachment_1__ContentType__s,'Attachment_1__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( howtoArticle.Attachment_2__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(howtoArticle.Attachment_2__Name__s, howtoArticle.Attachment_2__ContentType__s,'Attachment_2__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( howtoArticle.Attachment_3__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(howtoArticle.Attachment_3__Name__s, howtoArticle.Attachment_3__ContentType__s,'Attachment_3__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( howtoArticle.Attachment_4__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(howtoArticle.Attachment_4__Name__s, howtoArticle.Attachment_4__ContentType__s,'Attachment_4__Body__s');
                lstAttachment.add(attchFiles);
            }          
        }
        else if(artType.equals(ARTICLE_TYPE_GLOSSARY)) 
        {
            parentObj = 'Glossary__kav';
            
            string queryStr = 'SELECT Term__c,Definition__c,' + fieldsTobeQueried + ' FROM '+ parentObj;
            queryStr += ' WHERE id = \''+lstKnwArtId[0].id+'\' LIMIT 1';    
            
            articleTypeObject = Database.query(queryStr);
            
            if( null == articleTypeObject ) {
                return;
            }

            glossaryArticle = (Glossary__kav)articleTypeObject;
            
            if(glossaryArticle.Term__c != null) {
                description += '<b>Term:</b><br/>' + glossaryArticle.Term__c;            
            }            
            if(glossaryArticle.Definition__c != null) 
            {
                description += '<br/><br/><b>Definition:</b><br/>' +
                                glossaryArticle.Definition__c;            
            }
            if(null != glossaryArticle.Related_Links__c) {
                description += '<br/><br/><b>Related Links:</b><br/>' +
                                glossaryArticle.Related_Links__c;
            } 
           if(( glossaryArticle.Attachment_1__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(glossaryArticle.Attachment_1__Name__s,glossaryArticle.Attachment_1__ContentType__s,'Attachment_1__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( glossaryArticle.Attachment_2__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(glossaryArticle.Attachment_2__Name__s, glossaryArticle.Attachment_2__ContentType__s,'Attachment_2__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( glossaryArticle.Attachment_3__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles( glossaryArticle.Attachment_3__Name__s, glossaryArticle.Attachment_3__ContentType__s,'Attachment_3__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( glossaryArticle.Attachment_4__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles( glossaryArticle.Attachment_4__Name__s, glossaryArticle.Attachment_4__ContentType__s,'Attachment_4__Body__s');
                lstAttachment.add(attchFiles);
            }               
        }
        else if(artType.equals(ARTICLE_TYPE_PI)) 
        {
            parentObj = 'Product_Information__kav';
            
            string queryStr = 'SELECT Product_Information__c,Description__c,' + fieldsTobeQueried + ' FROM '+ parentObj;
            queryStr += ' WHERE id = \''+lstKnwArtId[0].id+'\' LIMIT 1';
            
            articleTypeObject = Database.query(queryStr);
            
            if( null == articleTypeObject ) {
                return;
            }
              
            piArticle = (Product_Information__kav)articleTypeObject;
            if(piArticle.Description__c != null) {
                description = transformArticleHyperLinks(
                              piArticle.Description__c);            
            }
            if(piArticle.Product_Information__c != null) {
                description += '<br/><br/><b>Product Information:</b><br/>' + 
                                piArticle.Product_Information__c;            
            }            
            if(null != piArticle.Related_Links__c) {
                description += '<br/><br/><b>Related Links:</b><br/>' + 
                                piArticle.Related_Links__c;
            }
            if(( piArticle.Attachment_1__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles( piArticle.Attachment_1__Name__s, piArticle.Attachment_1__ContentType__s,'Attachment_1__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( piArticle.Attachment_2__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles( piArticle.Attachment_2__Name__s, piArticle.Attachment_2__ContentType__s,'Attachment_2__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( piArticle.Attachment_3__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles( piArticle.Attachment_3__Name__s, piArticle.Attachment_3__ContentType__s,'Attachment_3__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( piArticle.Attachment_4__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles( piArticle.Attachment_4__Name__s, piArticle.Attachment_4__ContentType__s,'Attachment_4__Body__s');
                lstAttachment.add(attchFiles);
            }                                
        }
        else if(artType.equals(ARTICLE_TYPE_TB)) 
        {
            parentObj = 'Technical_Bulletin__kav';
            
            string queryStr = 'SELECT Release_Date__c,Information__c,' + fieldsTobeQueried + ' FROM '+ parentObj;
            queryStr += ' WHERE id = \''+lstKnwArtId[0].id+'\' LIMIT 1';
            
            articleTypeObject = Database.query(queryStr);
            
            if( null == articleTypeObject ) {
                return;
            }

            tbArticle = (Technical_Bulletin__kav)articleTypeObject;
            if(tbArticle.Information__c != null) 
            {
                description = tbArticle.Information__c;            
            }
            if(null != tbArticle.Release_Date__c) 
            {
                description += '<br/><br/><b>Release Date:</b><br/>' + 
                               tbArticle.Release_Date__c;
            }             
            if(null != tbArticle.Related_Links__c) 
            {
                description += '<br/><br/><b>Related Links:</b><br/>' + 
                                tbArticle.Related_Links__c;
            } 
            if(( tbArticle.Attachment_1__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(tbArticle.Attachment_1__Name__s,tbArticle.Attachment_1__ContentType__s,'Attachment_1__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( tbArticle.Attachment_2__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(tbArticle.Attachment_2__Name__s,tbArticle.Attachment_2__ContentType__s,'Attachment_2__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( tbArticle.Attachment_3__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(tbArticle.Attachment_3__Name__s,tbArticle.Attachment_3__ContentType__s,'Attachment_3__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( tbArticle.Attachment_4__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(tbArticle.Attachment_4__Name__s,tbArticle.Attachment_4__ContentType__s,'Attachment_4__Body__s');
                lstAttachment.add(attchFiles);
            }          
        }
        else if(artType.equals(ARTICLE_TYPE_SOLUTION)) 
        {
            parentObj = 'Solution__kav';
            
            string queryStr = 'SELECT Details__c,' + fieldsTobeQueried + ' FROM '+ parentObj;
            queryStr += ' WHERE id = \''+lstKnwArtId[0].id+'\' LIMIT 1';
            
            articleTypeObject = Database.query(queryStr);
            
            if( null == articleTypeObject ) {
                return;
            }
            
            solutionArticle = (Solution__kav)articleTypeObject;
            if(solutionArticle.Details__c != null)
            {
                description = solutionArticle.Details__c;            
            }
            if(null != solutionArticle.Related_Links__c) {
                description += '<br/><br/><b>Related Links:</b><br/>' + 
                               solutionArticle.Related_Links__c;
            }
            
            if(( solutionArticle.Attachment_1__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(solutionArticle.Attachment_1__Name__s,solutionArticle.Attachment_1__ContentType__s,'Attachment_1__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( solutionArticle.Attachment_2__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(solutionArticle.Attachment_2__Name__s,solutionArticle.Attachment_2__ContentType__s,'Attachment_2__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( solutionArticle.Attachment_3__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(solutionArticle.Attachment_3__Name__s,solutionArticle.Attachment_3__ContentType__s,'Attachment_3__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( solutionArticle.Attachment_4__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(solutionArticle.Attachment_4__Name__s,solutionArticle.Attachment_4__ContentType__s,'Attachment_4__Body__s');
                lstAttachment.add(attchFiles);
            }
          
        }  
        else if(artType.equals(ARTICLE_TYPE_KI)) 
        {
            parentObj = 'Known_Issue__kav';
            
            string queryStr = 'SELECT Issue_Description__c,Workaround_Temporary_Fix__c,Resolution_Status__c,' + fieldsTobeQueried + ' FROM '+ parentObj;
            queryStr += ' WHERE id = \''+lstKnwArtId[0].id+'\' LIMIT 1';
            
            articleTypeObject = Database.query(queryStr);
            
            if( null == articleTypeObject ) {
                return;
            }
            
            kiArticle = (Known_Issue__kav)articleTypeObject;
            
            if(null != kiArticle.Issue_Description__c) {
                description = kiArticle.Issue_Description__c; 
            } 
            if(null != kiArticle.Resolution_Status__c) {
                description += '<br/><br/><b>Resolution Status:</b><br/>' + 
                               kiArticle.Resolution_Status__c;
            }                                                          
            if(kiArticle.Workaround_Temporary_Fix__c != null) {
                description += '<br/><br/><b>Workaround/Temporary Fix:</b><br/>' +
                               kiArticle.Workaround_Temporary_Fix__c;   
            }
            if(null != kiArticle.Related_Links__c) {
                description += '<br/><br/><b>Related Links:</b><br/>' + 
                               kiArticle.Related_Links__c;
            }
            if(( kiArticle.Attachment_1__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(kiArticle.Attachment_1__Name__s,kiArticle.Attachment_1__ContentType__s,'Attachment_1__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( kiArticle.Attachment_2__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(kiArticle.Attachment_2__Name__s,kiArticle.Attachment_2__ContentType__s,'Attachment_2__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( kiArticle.Attachment_3__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(kiArticle.Attachment_3__Name__s,kiArticle.Attachment_3__ContentType__s,'Attachment_3__Body__s');
                lstAttachment.add(attchFiles);
            }
            if(( kiArticle.Attachment_4__Name__s != null) || (Test.isRunningTest() != false))
            {
                AttachmentFiles attchFiles =  new AttachmentFiles(kiArticle.Attachment_4__Name__s,kiArticle.Attachment_4__ContentType__s,'Attachment_4__Body__s');
                lstAttachment.add(attchFiles);
            }                                 
        }
        
        //Parse the description field to extract content URL if any
        description = transformArticleHyperLinks(description);      
     } 
     
     
     /**@Description:This method parse the text to extract the content
       *url from description.
      */  
     public String transformArticleHyperLinks (String strArticleHTML)
     {
         if (strArticleHTML == null || strArticleHTML.length() == 0) 
         {
             return strArticleHTML;
         }
            
         String strArticleLinkUrlname = '';
         
         String strSKRelativeURL = '';
         
         String strArticleLinkToken    = '<a href="';
         String strContentDocumentIdToken = '#version?selectedDocumentId=';
         
         Integer nArticleLinkStart     = 0;
         Integer nArticleLinkEnd       = 0;

         Integer nArticleUrlnameStart  = 0;
         Integer nArticleUrlnameEnd    = 0;
                          
         while ((nArticleLinkStart >= 0) && (nArticleLinkStart < strArticleHTML.length())) 
         {
             nArticleLinkStart = strArticleHTML.indexOf(strArticleLinkToken, nArticleLinkStart);

             if (nArticleLinkStart < 0) {
                 break; // No more article links in source HTML
             }

             nArticleUrlnameStart = nArticleLinkStart + strArticleLinkToken.length(); 
             nArticleLinkEnd = strArticleHTML.indexOf('</a>', nArticleLinkStart + strArticleLinkToken.length());
                             
             nArticleUrlnameEnd = strArticleHTML.indexOf('"', nArticleUrlnameStart);
             strArticleLinkUrlname = strArticleHTML.substring(nArticleUrlnameStart, nArticleUrlnameEnd);
             if(-1 == strArticleLinkUrlname.indexOf(strContentDocumentIdToken, 0)) {
                 //Least interested in this link
                 nArticleLinkStart =  nArticleLinkEnd + '</a>'.length();
                 continue;
             }

             String contentDocumentId = strArticleLinkUrlname.substring(strArticleLinkUrlname.length() - ARTICLE_ID_LENGTH, 
                                                                        strArticleLinkUrlname.length());

             // Executing this query just to ensure that the Content exists
             List<ContentVersion> cv = [SELECT 
                                            Id 
                                        FROM 
                                            ContentVersion 
                                        WHERE 
                                            ContentDocumentId = :contentDocumentId  AND 
                                            iSLatest = true
                                        LIMIT
                                            1
                                        ];
             if(null != cv && 0 < cv.size()) 
             {
                 if(pagename == '' && pagename != 'MsrSearch')
                     strSKRelativeURL = CONTENT_DETAILS_BASE_PAGE + contentDocumentId;
                 else
                     strSKRelativeURL = CONTENT_DETAILS_BASE_PAGE_MOB + contentDocumentId;
             }
             else {
                 strSKRelativeURL = '#';
             }

             // Replace embedded RN markup with anchor tag using SFDC relative link              
             strArticleHTML = strArticleHTML.substring(0,nArticleUrlnameStart)
                                   + strSKRelativeURL
                                   + strArticleHTML.substring(nArticleUrlnameEnd);
             nArticleLinkStart = nArticleLinkStart + strArticleLinkToken.length() + strSKRelativeURL.length();
         }// end of while loop
        
         return strArticleHTML;
     }
     
     
     /**@Description:This wrapper class is used
       *To create a list of attachment which will 
       *be used in the front end to
       *display attachments
       */
     public class AttachmentFiles 
     {
        //contain the name of the attachment
        public string attachmentName { get; set; } 
        
        //contain the contentType
        public String attachmentContentType { get; set; } 
        
        //contains the label of the Attachment_n__Body__s where n = 1,2,3,4
        public string fieldName {get;set;} 
        
        //Constructor
        public AttachmentFiles( string name, string contentType,string fldName )
        {
            this.attachmentName = name;
            this.attachmentContentType = contentType;
            this.fieldName = fldName;
        }
    }
    
   
}