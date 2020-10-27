public with sharing class ContractRewalExt {
    //Instance of the flow
   public Flow.Interview.Test_Renewal_Wizard RenewalFlow {get; set;}
   public string returnId;
   Public Contract c;
   Public list<task> TaskList;
   
    public ContractRewalExt(ApexPages.StandardController controller) {
         this.c = (Contract)controller.getRecord();
    }
    
    public PageReference getGotoNewContract(){

        if(RenewalFlow != null ) returnId = RenewalFlow.NewContractId;
        if(returnId == null && RenewalFlow != null) returnID = string.valueOf(c.Id);
        if( RenewalFlow != null) TaskList = RenewalFlow.UpdateChangedTasks;
        system.debug('------------------------- NewContractId from Flow '+returnId);
        system.debug('------------------------- MassTask '+TaskList);
        PageReference send = new PageReference('/' + returnId);
        send.setRedirect(true);
        
        return send;

    }

}