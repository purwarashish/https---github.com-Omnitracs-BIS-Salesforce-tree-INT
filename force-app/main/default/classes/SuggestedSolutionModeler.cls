public class SuggestedSolutionModeler {
    public SuggestedSolutionModeler() {}
    
    public List<QESUnityTopArticle> getSuggestedSolutions(String subject) {
        List<QESUnityTopArticle> suggestedSolutionsList = new List<QESUnityTopArticle>();
        if( (null == subject) || ('' == subject) || (1 == subject.length()) ) {
            return suggestedSolutionsList;
        }
        List<List<Sobject>> articlesList = [ 
                            FIND 
                               :subject
                            IN 
                            ALL FIELDS RETURNING 
                                Documentation__kav( // index 0
                                        Summary,
                                        KnowledgeArticleId,
                                        Title
                                    where 
                                        PublishStatus = 'Online' and
                                        Language = 'en_US'
                                ),
                                Solution__kav( // index 1
                                        Summary,
                                        KnowledgeArticleId,
                                        Title
                                    where 
                                        PublishStatus = 'Online' and
                                        Language = 'en_US'
                                ),
                                Glossary__kav( // index 2
                                        Summary,
                                        KnowledgeArticleId,
                                        Title
                                    where 
                                        PublishStatus = 'Online' and
                                        Language = 'en_US'
                                ),                                
                                How_To__kav( // index 3
                                        Summary,
                                        KnowledgeArticleId,
                                        Title
                                    where 
                                        PublishStatus = 'Online' and
                                        Language = 'en_US'
                                ),
                                Technical_Bulletin__kav( // index 4
                                        Summary,
                                        KnowledgeArticleId,
                                        Title
                                    where 
                                        PublishStatus = 'Online' and
                                        Language = 'en_US'
                                ),
                                Product_Information__kav( // index 5
                                        Summary,
                                        KnowledgeArticleId,
                                        Title
                                    where 
                                        PublishStatus = 'Online' and
                                        Language = 'en_US'
                                ),
                                Known_Issue__kav( // index 6
                                        Summary,
                                        KnowledgeArticleId,
                                        Title
                                    where 
                                        PublishStatus = 'Online' and
                                        Language = 'en_US'
                                )                                                                                                                                
                            LIMIT 
                                5
              ];

        for(Integer i = 0; i < articlesList.size(); i++) {
            if(0 == i) {
                List<Documentation__kav> innerList = ((List<Documentation__kav>)articlesList[i]);
                for(Documentation__kav article : innerList) {
                    QESUnityTopArticle suggestedArticle = new QESUnityTopArticle();
                    suggestedArticle.title = article.title;
                    suggestedArticle.Body = article.Summary;
                    suggestedArticle.linkUrl = '/apex/supportarticleDocumentation?type=Documentation&&id=' 
                                               + article.knowledgeArticleId;
                    suggestedSolutionsList.add(suggestedArticle);
                }
            }
            else if(1 == i) {
                List<Solution__kav> innerList = ((List<Solution__kav>)articlesList[i]);
                for(Solution__kav article : innerList) {
                    QESUnityTopArticle suggestedArticle = new QESUnityTopArticle();
                    suggestedArticle.title = article.title;
                    suggestedArticle.Body = article.Summary;
                    suggestedArticle.linkUrl = '/apex/supportarticleSolution?type=Solution&&id=' 
                                               + article.knowledgeArticleId;
                    suggestedSolutionsList.add(suggestedArticle);
                }
            }
            else if(2 == i) {
                List<Glossary__kav> innerList = ((List<Glossary__kav>)articlesList[i]);
                for(Glossary__kav article : innerList) {
                    QESUnityTopArticle suggestedArticle = new QESUnityTopArticle();
                    suggestedArticle.title = article.title;
                    suggestedArticle.Body = article.Summary;
                    suggestedArticle.linkUrl = '/apex/supportarticleGlossary?type=Glossary&&id=' 
                                               + article.knowledgeArticleId;
                    suggestedSolutionsList.add(suggestedArticle);
                }
            } 
            else if(3 == i) {
                List<How_To__kav> innerList = ((List<How_To__kav>)articlesList[i]);
                for(How_To__kav article : innerList) {
                    QESUnityTopArticle suggestedArticle = new QESUnityTopArticle();
                    suggestedArticle.title = article.title;
                    suggestedArticle.Body = article.Summary;
                    suggestedArticle.linkUrl = '/apex/supportarticleHow_To?type=How_To&&id=' 
                                               + article.knowledgeArticleId;
                    suggestedSolutionsList.add(suggestedArticle);
                }
            }
            else if(4 == i) {
                List<Technical_Bulletin__kav> innerList = ((List<Technical_Bulletin__kav>)articlesList[i]);
                for(Technical_Bulletin__kav article : innerList) {
                    QESUnityTopArticle suggestedArticle = new QESUnityTopArticle();
                    suggestedArticle.title = article.title;
                    suggestedArticle.Body = article.Summary;
                    suggestedArticle.linkUrl = '/apex/supportarticleTechnical_Bulletin?type=Technical_Bulletin&&id=' 
                                               + article.knowledgeArticleId;
                    suggestedSolutionsList.add(suggestedArticle);
                }
            }
            else if(5 == i) {
                List<Product_Information__kav> innerList = ((List<Product_Information__kav>)articlesList[i]);
                for(Product_Information__kav article : innerList) {
                    QESUnityTopArticle suggestedArticle = new QESUnityTopArticle();
                    suggestedArticle.title = article.title;
                    suggestedArticle.Body = article.Summary;
                    suggestedArticle.linkUrl = '/apex/supportarticleProduct_Information?type=Product_Information&&id=' 
                                               + article.knowledgeArticleId;
                    suggestedSolutionsList.add(suggestedArticle);
                }
            }
            else if(6 == i) {
                List<Known_Issue__kav> innerList = ((List<Known_Issue__kav>)articlesList[i]);
                for(Known_Issue__kav article : innerList) {
                    QESUnityTopArticle suggestedArticle = new QESUnityTopArticle();
                    suggestedArticle.title = article.title;
                    suggestedArticle.Body = article.Summary;
                    suggestedArticle.linkUrl = '/apex/supportarticleKnown_Issue?type=Known_Issue&&id=' 
                                               + article.knowledgeArticleId;
                    suggestedSolutionsList.add(suggestedArticle);
                }
            }           
        } // End - for 
        
        return suggestedSolutionsList;                                  
    }
}