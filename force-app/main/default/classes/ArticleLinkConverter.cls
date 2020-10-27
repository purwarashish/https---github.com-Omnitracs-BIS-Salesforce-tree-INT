public virtual class ArticleLinkConverter {
     public final Integer ARTICLE_ID_LENGTH = 18;
     public final String CONTENT_DETAILS_BASE_PAGE = '/apex/supportdocDetail?id=';
     
     public String transformArticleHyperLinks (String strArticleHTML) {
         if (strArticleHTML == null || strArticleHTML.length() == 0) {
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
                          
         while ((nArticleLinkStart >= 0) && (nArticleLinkStart < strArticleHTML.length())) {
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

             // Executing this query just to ensure that the Content exists/the user has access to it
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
             if(null != cv && 0 < cv.size()) {
                 strSKRelativeURL = CONTENT_DETAILS_BASE_PAGE + contentDocumentId;
             }
             else {
                 strSKRelativeURL = '#';
             }

             // Replace embedded RN markup with anchor tag using SFDC relative link              
             strArticleHTML = strArticleHTML.substring(0,nArticleUrlnameStart)
                                   + strSKRelativeURL
                                   + strArticleHTML.substring(nArticleUrlnameEnd);
             nArticleLinkStart = nArticleLinkStart + strArticleLinkToken.length() + strSKRelativeURL.length();
         }
        
         return strArticleHTML;
     }    
}