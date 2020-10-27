trigger UpdateContentLink on ContentVersion (before Insert,before update) {
    List<ContentVersion> lstContent = trigger.new;

    for(ContentVersion contentVer:lstContent){
        Id  id =  contentVer.ContentDocumentId;
        contentVer.Superlinks_URL__c = System.label.ContentUrl + id;        
        contentVer.Article_URL__c = '/sfc/#version?selectedDocumentId=' + id;
    }
}