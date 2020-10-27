public class  ContentVersionModeler {
    
    public ContentVersion contentDetails {get; set;}
    public String contentSize {get; set;}
    public String downloadLink {get;set;}
    public String returnURL {get; set;}
    public ContentVersionModeler() {
        refreshInitializationData();
    }
    
    public void refreshInitializationData() {
        String contentDocumentId = Apexpages.currentPage().getParameters().get('id');
        returnURL = Apexpages.currentPage().getParameters().get('retURL'); 
        downloadLink = '#';
        List<ContentVersion> cv = 
             [ SELECT 
                   Id, Title, ContentUrl, Description, ContentSize, ContentModifiedDate,Internal_Use_Only__c, positiveRatingCount, negativeRatingCount,
                   Product__c, Type__c
               FROM 
                   ContentVersion 
               WHERE 
                   ContentDocumentId = :contentDocumentId  
               AND 
                   iSLatest = true 
               Limit 
                   1 
             ];
           
        if((null != cv) && (0 < cv.size())) {
            contentDetails = cv[0];
			if(contentDetails.ContentUrl == null){
				List<ContentDistribution> contentDistribs = [select DistributionPublicUrl from ContentDistribution Where ContentDocumentId = :contentDocumentId Order By CreatedDate DESC];
				if((null != contentDistribs) && (contentDistribs.size() > 0)){
					downloadLink = contentDistribs[0].DistributionPublicUrl;
				}
			}else{
				downloadLink = contentDetails.ContentUrl;
			}
            //downloadLink = '/sfc/servlet.shepherd/version/download/' + cv[0].id + '?asPdf=false&operationContext=CHATTER';
        }
        else {
            return;
        }         
        
        if(1000 > contentDetails.contentSize) {
            contentSize = contentDetails.contentSize + ' bytes';
        }
        else if( (1000 <= contentDetails.contentSize) && ((1024 * 1024) > contentDetails.contentSize) ) {
            Decimal size = contentDetails.contentSize;
            contentSize = size.divide(1024, 2, System.RoundingMode.DOWN) + ' KB';
        }
        else if( ((1024 * 1024) <= contentDetails.contentSize) && ((1024 * 1024 * 1024) > contentDetails.contentSize) ) {
            Decimal size = contentDetails.contentSize;
            contentSize = size.divide((1024 * 1024), 2, System.RoundingMode.DOWN) + ' MB';
        }
        else if( ((1024 * 1024 * 1024) <= contentDetails.contentSize) && ((1024 * 1024 * 1024 * 1024) > contentDetails.contentSize) ) {
            Decimal size = contentDetails.contentSize;
            contentSize = size.divide((1024 * 1024 * 1024), 2, System.RoundingMode.DOWN) + ' GB';
        }
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=Edge');        
        
    }
    
    public PageReference redirectTo()
     {
        System.Cookie rURL = ApexPages.currentPage().getCookies().get('external_cookie');
        String redirectionLink = rURL.getValue();
        PageReference pg = new PageReference(redirectionLink);
        pg.setRedirect(false);
        return pg;
     }
    public PageReference redirectToDownload() {
        PageReference pr = new PageReference(downloadLink);
        return pr;
    }
}