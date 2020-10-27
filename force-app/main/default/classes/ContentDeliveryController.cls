public  class ContentDeliveryController {
    
    public Integer previous {get; set;}
    public Integer next {get; set;}
    public PageReference thePage {get; set;}
    public String title {get; set;}
    public string FileName {get; set;}
    public boolean previewFile {get; set;}
    public string ContentVersionID {get; set;}
    public string FileType {get; set;}
    public string PublicURL {get; set;}
    public string ContentDistributionID {get; set;}
    
    
    ContentDocument ContentDocument;
    ContentDistribution ContentDistribution;
    ContentDistributionView ContentDistributionView;
    Content_Delivery__c Content_Delivery;
    
    private final Contract contract;
    public String contNum {get; set;}
    private static final String OPTConDoc = 'Contract Documents';
    public List<ContentVersion> conDocL {get;set;}
    public Boolean isResultShow { get; set; }
    public Id contrWID;
    public Id contractId;
    public String selectedOpt {get;set;}
    
  public ContentDeliveryController(ApexPages.StandardController controller){
      this.contract = (Contract)controller.getRecord();
      Contract c = [Select Id, ContractNumber FROM Contract Where Id =: contract.Id];
      contNum = c.ContractNumber;
      this.isResultShow=false;
      contractId = c.Id;
      contrWID = [SELECT Name FROM ContentWorkspace Where Name = 'Contract Documents'].Id;
  }
  
  public List<ContentDocument> getconDocL() {
      List<ContentDocument> getconDoc = [SELECT Title,ArchivedDate FROM ContentDocument WHERE ParentId =: contrWID];
      return getconDoc;
  }
//   public List<ContentDocument> conDocL {get;set;}
  
  public List<SelectOption> getworkspaceOptions() {
        List<SelectOption> workspaceOptions = new List<SelectOption>();
        
        workspaceOptions.add(new selectOption(contrWID, 'Contract Documents')); 
        for(ContentWorkspace cw : [SELECT Name FROM ContentWorkspace]){
            // if(cw.Name==OPTConDoc){
            //     countryOptions.add(new selectOption(cw.id, cw.Name)); 
            // }
            if(cw.Name!=OPTConDoc){
                workspaceOptions.add(new selectOption(cw.id,cw.Name)); 
            }
        }
 
        return workspaceOptions;
    }
    public PageReference Search(){
        conDocL = new List<ContentVersion>();
       
        conDocL = [SELECT  Id, Account_Name__c, Account__c, ContentUrl, ContentDocumentId, Type__c, contract__c, PublishStatus, RecordTypeId, Title, VersionNumber, TCM_Contract_Number__c, PathOnClient, Orderable__c, FirstPublishLocationId, FileType, Description FROM ContentVersion where  PublishStatus = 'P'  and  Contract__r.ContractNumber =:contNum];
        if(conDocL!=null && !conDocL.isEmpty()){
            isResultShow = true;
        }
        previewFile = false;
        return null;
    }
    
    public pageReference refreshData(){
          try {    
                //refresh the new url   
                ContentDistribution cb = [select id, DistributionPublicUrl from ContentDistribution where id =:ContentDistributionID limit 1];
                PublicURL = cb.DistributionPublicUrl;
                system.debug('-------------------------------------------- PublicURL: '+PublicURL);
          }catch (Exception e){
            string msg = 'URL is still being generated.  Please wait about 5 seconds before continuing. Thank you!';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));
        
       } 
        return null;
    }
    
    public PageReference Preview(){
        refreshData();
        previewFile = true;
        FileName =PublicURL;
        return null;
    }
    
    // The next four methods return one of each of the four member
   // variables. If this is the first time the method is called,
   // it creates an empty record for the variable.
   public ContentDocument getContentDocument() {
      if(ContentDocument == null) ContentDocument = new ContentDocument();
      return ContentDocument;
   }

   public ContentDistribution getContentDistribution() {
      if(ContentDistribution == null) ContentDistribution = new ContentDistribution();
      return ContentDistribution;
   }

   public ContentDistributionView getContentDistributionView() {
      if(ContentDistributionView == null) ContentDistributionView = new ContentDistributionView();
      return ContentDistributionView;
   }
    
   // The next three methods are used to control navigation through  
    
   // the wizard. Each returns a reference to one of the three pages  
    
   // in the wizard. 
   
    public PageReference step1() {
      return Page.ContentDelivery;

   }

   public PageReference step2() {
      if(ContentDistribution == null) ContentDistribution = new ContentDistribution(); 
      if(Content_Delivery == null) Content_Delivery = new Content_Delivery__c();
      for(ContentVersion cv: conDocL){
          if(cv.Orderable__c){
              ContentDistribution.ContentVersionId = cv.Id;
              ContentDistribution.Name = cv.Title;
              FileType = cv.Filetype;
              Content_Delivery.Contract__c = cv.Contract__c;
              Content_Delivery.Name = cv.Title.substring(0,5);
          }
      }
      system.debug('-------------------------------------------- ContentDistribution: '+ContentDistribution);
      return Page.ContentDeliveryPage2;
   }

   public PageReference step3() {
       system.debug('-------------------------------------------- ContentDistribution Before Save: '+ContentDistribution);
      if(ContentDistributionID == null) SaveRecord(); 
      return Page.ContentDeliveryPage3;

   }

   public PageReference step4() {
     if(PublicURL == null) refreshData();
     string Body = 'I am sending you documents to view online or download by clicking the following link:';
     string subject = 'Documents to review';
     Body = EncodingUtil.URLENCODE(Body,'UTF-8');
     Subject = EncodingUtil.URLENCODE(Subject,'UTF-8');
     string URL = '/_ui/core/email/author/EmailAuthor?rtype=003&p3_lkid='+contractId+'&p6='+Subject+'&p7='+Body+'%0A'+PublicURL+'&retURL=%2F'+contractId;
     return new PageReference(url);
   }

   public void SaveRecord(){
   
     // setup the save point for rollback
         Savepoint sp = Database.setSavepoint();  
         
     try {      
        // Create the insert Content_Delivery record
        insert Content_Delivery;
        ContentDistribution.RelatedRecordId = Content_Delivery.id;
        // Create the ContentDistribution record
          insert ContentDistribution;
          system.debug('-------------------------------------------- ContentDistribution Saved: '+ContentDistribution);
          system.debug('-------------------------------------------- Content_Delivery Saved: '+Content_Delivery);
          ContentDistributionID = ContentDistribution.ID;
         
     }catch (Exception e){
             // roll everything back in case of error
            Database.rollback(sp);
            ApexPages.addMessages(e);
        
       }  

   }  

}