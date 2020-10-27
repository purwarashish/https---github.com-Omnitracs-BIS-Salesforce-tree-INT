/**@Description:This class contains the logic for displaying the Content 
  *details along with the preview using flash player
  *@Author:Jaspreet Singh
  *@Modified:Ketan Prakash Singh
  *@Date:21st June,2012
**/
public class SrContentVersionModeler {
    public ContentVersion contentDetails {get; set;}{contentDetails = new ContentVersion();}
    public String contentSize {get; set;}
    public String downloadLink {get;set;}
    public SrContentVersionModeler() {
        contentVersionData();
        getContentSize();
    }
/* Used for retrieving the fields of the ContentVersion
 * based on the Id of the Document passed in the Url.
 * Also sets the Url for the DownloadLink.
 */    
    public void contentVersionData() 
    {
        String contentDocumentId = Apexpages.currentPage().getParameters().get('id');
        if((contentDocumentId == null)||(contentDocumentId == ''))
        {
            return;
        }
		downloadLink = '#';
		List<ContentVersion> cv = [ SELECT 
                   Id, Title, ContentUrl, Description, ContentSize, ContentModifiedDate,
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
        if( (null != cv) && (0 < cv.size()) ) 
        {
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
    }
/* Checks for the size of ContentVersion and accordingly
 * assigns to the String variable 'contentSize' appending
 * the appropriate unit.
 */
    public void getContentSize() 
    {
        if(contentDetails != null || Test.isRunningTest()){
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
        }    
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