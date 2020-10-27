public without sharing class ContentDisplayControlller {
    Contract_Project__c cp;
    public Id conProject;
    public Set<Id> conIdsInstance;
    public Integer isStep {get; set;}
    public ContentDisplayControlller(ApexPages.StandardController controller){
        this.cp = (Contract_Project__c)controller.getRecord();
        conProject = cp.Id;
        //conList = [Select Id,Contract__c from Non_Family_Linked_Contracts__c Where ]
        process();
    }
    
    public void process(){
        List<Non_Family_Linked_Contracts__c> conListInstance = [Select Id,Contract__c,Contract_Project__c,Contract__r.contractnumber from Non_Family_Linked_Contracts__c Where Contract_Project__c =: conProject]; 
        conIdsInstance = new Set<Id>();
        for(Non_Family_Linked_Contracts__c n : conListInstance){
            conIdsInstance.add(n.Contract__c);
        }
    }
    public List<ContentVersion> getcontentList(){
        List<ContentVersion> contentListInstance = [Select Id, Title, Contract__c,Parent_Contract_Number__c,Contract_Number__c,Document_Category__c,Account_Name__c, CreatedDate, LastModifiedDate, Family_ID__c FROM ContentVersion WHERE Contract__c =: conIdsInstance ORDER BY Family_ID__c DESC];  
        // List<ContentVersion> contentListInstance = [Select Id, Title, Contract__c, CreatedDate, LastModifiedDate FROM ContentVersion LIMIT 30];  
        return contentListInstance;
    }
    
    
    

}