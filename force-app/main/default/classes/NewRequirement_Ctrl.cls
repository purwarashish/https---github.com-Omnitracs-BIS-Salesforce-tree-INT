public class NewRequirement_Ctrl{
    public Requirements__c req {get;set;}
    
    public NewRequirement_Ctrl(){
        req = new Requirements__c();
    }
    
    public PageReference save(){
        try{
            insert req;
            User_Story_Requirement__c reqJunction = new User_Story_Requirement__c(Requirement__c = req.Id, 
                                                                                         User_Story__c = ApexPages.currentPage().getParameters().get('Id'));
            insert reqJunction;
            return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
        }catch(DMLException ex){
            ApexPages.addMessages(ex);
            return null;
        }
    }
    
    public PageReference saveAndNew(){
        try{
            insert req;
            User_Story_Requirement__c reqJunction = new User_Story_Requirement__c(Requirement__c = req.Id, 
                                                                                         User_Story__c = ApexPages.currentPage().getParameters().get('Id'));
            insert reqJunction;
            req = new Requirements__c();
            return new PageReference('/apex/NewRequirement?id=' + ApexPages.currentPage().getParameters().get('Id'));
        }catch(DMLException ex){    
            ApexPages.addMessages(ex);
            return null;
        }
    }
    
    public PageReference cancel(){
        return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
    }
}