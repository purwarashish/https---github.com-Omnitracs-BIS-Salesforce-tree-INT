public with sharing class AccountContentController {
    Account a;
    public ContentVersion file { get; set; }
    
    public AccountContentController(ApexPages.StandardController controller) {
        this.a = (Account)controller.getRecord();
        file = new ContentVersion();
        file.Account__c = a.id;
        
    }
     public PageReference go() {
     Account acc = new Account();
         acc = [Select id, Name from Account where id = :a.Id limit 1];
         ContentWorkspace CW = [SELECT Description, Id, Name, DefaultRecordTypeId, IsRestrictContentTypes, IsRestrictLinkedContentTypes, 
                                TagModel FROM ContentWorkspace where name ='Account Documents' limit 1];
                                
          //Set recordtype and Workspace
        file.RecordTypeId = CW.DefaultRecordTypeId;
        file.Account_Name__c = acc.Name;
        file.FirstPublishLocationId = CW.Id;
          //Set recordtype and Workspace
        //file.Contract_Number__c = ctr.ContractNumber;
        //file.Parent_Contract_Number__c = ctr.Parent_Contract__r.ContractNumber;
        insert file;
        //return new PageReference('/' + file.id);
        return new PageReference('/' + a.id);
    }
}