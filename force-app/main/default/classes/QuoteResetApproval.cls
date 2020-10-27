public class QuoteResetApproval {
    
    private ApexPages.StandardController controller;
    public SBQQ__Quote__c sq {get;set;}
    
    public QuoteResetApproval(ApexPages.StandardController controller) {
        this.controller = controller;
        sq= (SBQQ__Quote__c) controller.getRecord();
    }
    
    public PageReference goBack() {
        PageReference view = controller.view();
        return view ;
    }
    
    public Pagereference ResetApproval(){
        sq = [select id,ApprovalStatus__c from SBQQ__Quote__c where id=:sq.id];
        sq.ApprovalStatus__c='Recalled';
        try{
            update sq;
            List< sbaa__Approval__c> delApp = [select id from sbaa__Approval__c where Quote__c=:sq.id];
            delete delApp;
            PageReference view = controller.view();
            return view ;
        } catch (exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'There was a problem in resetting approval. Reach out to admin with error message:'+ex.getMessage()));
        }
        return null;
    }

}