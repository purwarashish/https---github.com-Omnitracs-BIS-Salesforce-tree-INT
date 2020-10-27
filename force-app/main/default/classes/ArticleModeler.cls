/**
 * Article types to be passed in the URL parameter - 'doc' for Documentation,
 * 'how' for HOWTO, 'glo' for Glossary, 'pi' for Product Information, 'tb' for
 * Technical Bulletin, 'sol' for Solution.
 */
public class ArticleModeler extends ArticleLinkConverter {
    private final String ARTICLE_TYPE_DOCUMENTATION = 'Documentation';
    private final String ARTICLE_TYPE_GLOSSARY      = 'Glossary';
    private final String ARTICLE_TYPE_HOWTO         = 'How_To';
    private final String ARTICLE_TYPE_PI            = 'Product_Information';
    private final String ARTICLE_TYPE_TB            = 'Technical_Bulletin';
    private final String ARTICLE_TYPE_SOLUTION      = 'Solution';
    private final String ARTICLE_TYPE_KI                = 'Known_Issue';

    public Documentation__kav docArticle {get; set;}
    public Glossary__kav glossaryArticle {get; set;}
    public How_To__kav howtoArticle {get; set;}
    public Product_Information__kav piArticle {get; set;}
    public Solution__kav solutionArticle {get; set;}
    public Technical_Bulletin__kav tbArticle {get; set;}
    public Known_Issue__kav kiArticle {get; set;}
    
    public String description {get; set;}  
    public String workaround {get; set;}
    public String kavArticleId {get; set;} 
    /*Change for CR 00083883*/
    public Boolean IsInternalUseOnly {get; set;} 
	public string standalone {get; set;}
    
    public Boolean getCaseCreationAllowed() {
        return caseCreationAllowed;
    }
    
    public ArticleModeler() 
    {
        standalone = ApexPages.currentPage().getParameters().get('standalone');
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
        
        initUserDetails();
        refreshInitializationData();
    }

    private void resetAllModels() 
    {
        docArticle      = null;
        glossaryArticle = null;
        howtoArticle    = null;
        piArticle       = null;
        solutionArticle = null;
        tbArticle       = null;
        kiArticle       = null;
    }

    public void refreshInitializationData() 
    {
        resetAllModels();

        String type = ApexPages.currentPage().getParameters().get('type');
        String articleId = ApexPages.currentPage().getParameters().get('id');
        kavArticleId = articleId;
        List<KnowledgeArticleVersion>tmpListIds = [Select 
                                                       Id, IsVisibleInCsp 
                                                   From 
                                                       KnowledgeArticleVersion 
                                                   where 
                                                       publishstatus='online' AND 
                                                       KnowledgeArticleId = :articleId 
                                                   limit 
                                                       1];
         
        if( (null == tmpListIds) || (0 == tmpListIds.size()) ) {
            return;
        }
        /*Change for CR 00083883*/
        IsInternalUseOnly = !(tmpListIds[0].IsVisibleInCsp);
        description = '';
        if(type.equals(ARTICLE_TYPE_DOCUMENTATION)) {
             List<Documentation__kav> tmpList =
                           [select
                                id,
                                Title,
                                UrlName,
                                Information__c,
                                Related_Links__c,
                                Attachment_1__Name__s,
                                Attachment_1__ContentType__s,
                                Attachment_2__Name__s,
                                Attachment_2__ContentType__s,
                                Attachment_3__Name__s,
                                Attachment_3__ContentType__s,
                                Attachment_4__Name__s,
                                Attachment_4__ContentType__s
                            from
                                Documentation__kav
                            WHERE
                                Id = :(tmpListIds[0].id)
                            limit
                                1];
            
            if( (null == tmpList) || (0 == tmpList.size()) ) {
                return;
            }
                                
            docArticle = tmpList[0];
            
            if(null != docArticle.Information__c) {
                description = transformArticleHyperLinks(
                                   docArticle.Information__c);
            }                   
            if(null != docArticle.Related_Links__c) {
                description += '<br/><br/><b>Related Links:</b><br/>' + 
                               transformArticleHyperLinks(
                               docArticle.Related_Links__c);
            }
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=Edge');
        }
        else if(type.equals(ARTICLE_TYPE_HOWTO)) {
             List<How_To__kav> tmpList
                         = [select
                                id,
                                Title,
                                UrlName,
                                Information__c,
                                Related_Links__c,
                                Step_By_Step__c,
                                Attachment_1__Name__s,
                                Attachment_1__ContentType__s,
                                Attachment_2__Name__s,
                                Attachment_2__ContentType__s,
                                Attachment_3__Name__s,
                                Attachment_3__ContentType__s,
                                Attachment_4__Name__s,
                                Attachment_4__ContentType__s
                            from
                                How_To__kav
                            where
                                Id = :(tmpListIds[0].id)
                            limit
                                1];

            if( (null == tmpList) || (0 == tmpList.size()) ) {
                return;
            }

            howtoArticle = tmpList[0];
            if(howtoArticle.Information__c != null) {
                description = transformArticleHyperLinks(
                              howtoArticle.Information__c);
            }
            if(null != howtoArticle.Step_By_Step__c) {
                description += '<br/><br/><b>Step by Step:</b><br/>' + 
                               transformArticleHyperLinks( 
                               howtoArticle.Step_By_Step__c);
            }                 
            if(null != howtoArticle.Related_Links__c) {
                description += '<br/><br/><b>Related Links:</b><br/>' + 
                               transformArticleHyperLinks(
                               howtoArticle.Related_Links__c);
            }
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=Edge');            
        }
        else if(type.equals(ARTICLE_TYPE_GLOSSARY)) {
             List<Glossary__kav> tmpList
                              = [select
                                     id,
                                     Title,
                                     Term__c,
                                     UrlName,
                                     Definition__c,
                                     Related_Links__c,
                                     Attachment_1__Name__s,
                                     Attachment_1__ContentType__s,
                                     Attachment_2__Name__s,
                                     Attachment_2__ContentType__s,
                                     Attachment_3__Name__s,
                                     Attachment_3__ContentType__s,
                                     Attachment_4__Name__s,
                                     Attachment_4__ContentType__s
                                 from
                                     Glossary__kav
                                 where
                                     Id = :(tmpListIds[0].id)
                                 limit
                                     1];

            if( (null == tmpList) || (0 == tmpList.size()) ) {
                return;
            }

            glossaryArticle = tmpList[0];
            if(glossaryArticle.Term__c != null) {
                description += '<b>Term:</b><br/>' +
                               transformArticleHyperLinks(
                               glossaryArticle.Term__c);            
            }            
            if(glossaryArticle.Definition__c != null) {
                description += '<br/><br/><b>Definition:</b><br/>' +
                               transformArticleHyperLinks(
                              glossaryArticle.Definition__c);            
            }
            if(null != glossaryArticle.Related_Links__c) {
                description += '<br/><br/><b>Related Links:</b><br/>' +
                               transformArticleHyperLinks( 
                               glossaryArticle.Related_Links__c);
            }
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=Edge');                 
        }
        else if(type.equals(ARTICLE_TYPE_PI)) {
              List<Product_Information__kav> tmpList
                         = [select
                                id,
                                Title,
                                UrlName,
                                Description__c,
                                Related_Links__c,
                                Product_Information__c,
                                Attachment_1__Name__s,
                                Attachment_1__ContentType__s,
                                Attachment_2__Name__s,
                                Attachment_2__ContentType__s,
                                Attachment_3__Name__s,
                                Attachment_3__ContentType__s,
                                Attachment_4__Name__s,
                                Attachment_4__ContentType__s
                            from
                                Product_Information__kav
                            where
                                Id = :(tmpListIds[0].id)
                            limit
                                1];

            if( (null == tmpList) || (0 == tmpList.size()) ) {
                return;
            }

            piArticle = tmpList[0];
            if(piArticle.Description__c != null) {
                description = transformArticleHyperLinks(
                              piArticle.Description__c);            
            }
            if(piArticle.Product_Information__c != null) {
                description += '<br/><br/><b>Product Information:</b><br/>' + 
                               transformArticleHyperLinks(
                               piArticle.Product_Information__c);            
            }            
            if(null != piArticle.Related_Links__c) {
                description += '<br/><br/><b>Related Links:</b><br/>' + 
                               transformArticleHyperLinks(
                               piArticle.Related_Links__c);
            }
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=Edge');                             
        }
        else if(type.equals(ARTICLE_TYPE_TB)) 
        {
             List<Technical_Bulletin__kav> tmpList
                         = [select
                                id,
                                Title,
                                UrlName,
                                Information__c,
                                Release_Date__c,
                                Related_Links__c,
                                Attachment_1__Name__s,
                                Attachment_1__ContentType__s,
                                Attachment_2__Name__s,
                                Attachment_2__ContentType__s,
                                Attachment_3__Name__s,
                                Attachment_3__ContentType__s,
                                Attachment_4__Name__s,
                                Attachment_4__ContentType__s
                            from
                                Technical_Bulletin__kav
                            where
                                Id = :(tmpListIds[0].id)
                            limit
                                1];

            if( (null == tmpList) || (0 == tmpList.size()) ) {
                return;
            }

            tbArticle = tmpList[0];
            if(tbArticle.Information__c != null) {
                description = transformArticleHyperLinks(
                              tbArticle.Information__c);            
            }
            if(null != tbArticle.Release_Date__c) {
                description += '<br/><br/><b>Release Date:</b><br/>' + 
                               tbArticle.Release_Date__c;
            }             
            if(null != tbArticle.Related_Links__c) {
                description += '<br/><br/><b>Related Links:</b><br/>' + 
                               transformArticleHyperLinks(
                               tbArticle.Related_Links__c);
            }
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=Edge');            
        }
        else if(type.equals(ARTICLE_TYPE_SOLUTION)) 
        {
              List<Solution__kav> tmpList
                               = [select
                                      id,
                                      Title,
                                      UrlName,
                                      Details__c,
                                      Related_Links__c,
                                      Attachment_1__Name__s,
                                      Attachment_1__ContentType__s,
                                      Attachment_2__Name__s,
                                      Attachment_2__ContentType__s,
                                      Attachment_3__Name__s,
                                      Attachment_3__ContentType__s,
                                      Attachment_4__Name__s,
                                      Attachment_4__ContentType__s
                                  from
                                      Solution__kav
                                  where
                                      Id = :(tmpListIds[0].id)
                                  limit
                                      1];

            if( (null == tmpList) || (0 == tmpList.size()) ) {
                return;
            }

            solutionArticle = tmpList[0];
            if(solutionArticle.Details__c != null) {
                description = transformArticleHyperLinks(
                              solutionArticle.Details__c);            
            }
            if(null != solutionArticle.Related_Links__c) {
                description += '<br/><br/><b>Related Links:</b><br/>' + 
                               transformArticleHyperLinks(
                               solutionArticle.Related_Links__c);
            }
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=Edge');            
        }        
        else if(type.equals(ARTICLE_TYPE_KI)) 
        {
             List<Known_Issue__kav> tmpList
                         = [select
                                id,
                                Title,
                                UrlName,
                                Issue_Description__c,
                                Workaround_Temporary_Fix__c,
                                Resolution_Status__c,
                                Related_Links__c,
                                Attachment_1__Name__s,
                                Attachment_1__ContentType__s,
                                Attachment_2__Name__s,
                                Attachment_2__ContentType__s,
                                Attachment_3__Name__s,
                                Attachment_3__ContentType__s,
                                Attachment_4__Name__s,
                                Attachment_4__ContentType__s                                
                            from
                                Known_Issue__kav
                            where
                                Id = :(tmpListIds[0].id)
                            limit
                                1];

            if( (null == tmpList) || (0 == tmpList.size()) ) {
                return;
            }

            kiArticle = tmpList[0];
            
            if(null != kiArticle.Issue_Description__c) {
                description = transformArticleHyperLinks(
                                  kiArticle.Issue_Description__c); 
            } 
            if(null != kiArticle.Resolution_Status__c) {
                description += '<br/><br/><b>Resolution Status:</b><br/>' + 
                               transformArticleHyperLinks(
                               kiArticle.Resolution_Status__c);
            }                                                          
            if(kiArticle.Workaround_Temporary_Fix__c != null) {
                description += '<br/><br/><b>Workaround/Temporary Fix:</b><br/>' +
                               transformArticleHyperLinks(
                                  kiArticle.Workaround_Temporary_Fix__c);   
            }
            if(null != kiArticle.Related_Links__c) {
                description += '<br/><br/><b>Related Links:</b><br/>' + 
                               transformArticleHyperLinks(
                               kiArticle.Related_Links__c);
            }
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=Edge');                                 
        }
    }
    public PageReference redirectToCaseSubmission()
    {
        PageReference pg = new PageReference('/apex/supportcasesubmit');
        pg.setRedirect(false);
        return pg;
    }   
    
    /**
     * @description This method is used to menu navigation
     */
     public PageReference returnTo()
     {
         String returl = ApexPages.currentPage().getParameters().get('retUrl');
         system.debug('returl' + returl);
         PageReference pg = new PageReference(returl);
         pg.setRedirect(false);
         return pg;
     }     

    private Boolean caseCreationAllowed;
    private String userType;
        
    private void setBoolCaseCreationPermission(String userType) {
        caseCreationAllowed = false;
    
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
              
    /**
     * @description Method to initialize the user-details of the logged-in user
     */
    private void initUserDetails() {
        String userId = UserInfo.getUserId();
        
        List<User> userDetailsList = [ SELECT
                                           ID,
                                           UserType
                                       FROM
                                           USER
                                       WHERE
                                           ID = :userId
                                       LIMIT
                                           1
                                     ];
        if( (null != userDetailsList) && (0 < userDetailsList.size()) ) {
            userType = userDetailsList[0].UserType;
        }                                 
        setBoolCaseCreationPermission(userType);
    }
}