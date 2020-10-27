/*********************************************************************************
Program:                Used to Upload Content documents to a contract
Programmer:             Joe Henry - CloudSherpas
Date:                   September 30, 2014
**********************************************************************************/     
public with sharing class ContentController {   
    Contract c;
    public ContentVersion file { get; set; }
    
    public ContentController(ApexPages.StandardController controller) {
        
        this.c = (Contract)controller.getRecord();
        file = new ContentVersion();
        file.Contract__c = c.id;
        
    }
     
    public PageReference go() {
        Contract ctr = new Contract();
         ctr = [Select id, ContractNumber, Parent_Contract__r.ContractNumber, account.Name  from Contract where id = :c.Id limit 1];
         ContentWorkspace CW = [SELECT Description, Id, Name, DefaultRecordTypeId, IsRestrictContentTypes, IsRestrictLinkedContentTypes, 
                                 TagModel FROM ContentWorkspace where name ='Contract Documents' limit 1];
          //Set recordtype and Workspace
        file.RecordTypeId = CW.DefaultRecordTypeId;
        file.FirstPublishLocationId = CW.Id;
        file.Contract_Number__c = ctr.ContractNumber;
        file.Parent_Contract_Number__c = ctr.Parent_Contract__r.ContractNumber;
        file.Account_name__c = ctr.Account.Name;
        insert file;
        //return new PageReference('/' + file.id);
        return new PageReference('/' + c.id);
    }
}