/**
 * This class contains unit tests for validating the behavior of all Contract Apex classes
 * and triggers.
 *
 
 */
@isTest(SeeAllData=True)
private class TestContractAll
{
    
    /***************Common Data Initialization**************/
    
    static Account Acct = GenericTestClass.insertAccount();
    static Contact Cont = GenericTestClass.insertContact(Acct.Id);
    static Account sampleAccount = [SELECT Id, Name FROM Account where id = : Acct.ID limit 1];
    static Contact sampleContact = [SELECT Id, Name FROM Contact where id = : Cont.Id limit 1];
   
    /*******************************************************/
    
    
    /******************TestContractRequestTIS******************************/
    public static testmethod void TestContractRequestTISControllerExtension()
    {
        Contract_Request__c CRNew = new Contract_Request__c();
        CRNew.Account__c = sampleAccount.id;
        CRNew.Description__c = 'Test Contract';
        CRNew.Contact__c = sampleContact.Id;
        CRNew.Contracts_Administrator_to_Send__c = 'No';
        CRNew.No_Approvals_Required__c = true;
        CRNew.Product_Reduced_Price__c = '5.00';
        CRNew.Requested_Completion_Date__c = (System.Today()+30);
        CRNew.Request_Status__c = 'Submitted';
        
        insert CRNew;
        
    // Add parameters to the page URL
        System.currentPageReference().getParameters().put('id', CRNew.Id);
    
    //Create a new instance fo the controller class
        ApexPages.StandardController standardcontroller = new ApexPages.StandardController(CRNew);
        ContractRequestTISControllerExtension Controller = new ContractRequestTISControllerExtension(standardcontroller);
    
        Controller.setState('Request Status');
    
        String RequestState = Controller.getState();
            
        System.assertEquals(RequestState ,'Request Status');
        
        list<TIS_Summary__c> TISSum = new list<TIS_Summary__c>();
        TISSum = Controller.getTISSummary();
        
        
        list<TIS_Detail__c> TISDetail = new list<TIS_Detail__c>();
        TISDetail = Controller.getTISDetail();
    
        String result = CreateTIS.CreateTISRecord('Contract_Request__c',CRNew.Id, 'Request Status', 'Assigned', UserInfo.getUserId(),false);
        
        List<SelectOption> options = new List<SelectOption>();
        options = Controller.getItems();
                
        String VFContractRequestPage = controller.ReturntoContractRequest().getUrl();
        String ContractRequestPage = '/' + CRNew.Id + '';
        System.assertEquals(ContractRequestPage, VFContractRequestPage);
        
        //Modified by Shruti Karn for CR# 22542
        Controller.TrueToggleShowDetail();
        Controller.FalseToggleShowDetail();
      }
      /************ End TestContractRequestTIS*************************/

    /*************************TestContractRequestTISDetail ***************************************/
    static testmethod void TestByCreateUpdateOfContractRequest() 
 {
 
    Contract_Request__c ContractRequestObj = new Contract_Request__c(
                                      Account__c = sampleAccount.Id,
                                      Description__c = 'Test', 
                                      Contact__c = sampleContact.Id,                                      
                                      Contracts_Administrator_to_Send__c = 'No',
                                      No_Approvals_Required__c = true,
                                      Product_Reduced_Price__c = '5.00',
                                      Requested_Completion_Date__c = (System.Today()+30),
                                      Request_Status__c = 'Submitted',
                                      //12 August 2010 - Added to prevent @future limits being exceeded
                                      System_Is_Future__c = true
                                     );
    insert ContractRequestObj;  
    System.debug('Contract Request created with SID :' + ContractRequestObj.Id);
    
    ContractRequestObj.Request_Status__c = 'Contract Request Pending';
    update ContractRequestObj;
    
    ContractRequestObj.Request_Status__c = 'Assigned';
    update ContractRequestObj;
    
    ContractRequestObj.Request_Status__c = 'Contract sent to Customer';
    update ContractRequestObj;
    
    ContractRequestObj.Request_Status__c = 'Contract received - QC signature pending';
    update ContractRequestObj;
    
    ContractRequestObj.Request_Status__c = 'Finance Hold';
    update ContractRequestObj;
    
    ContractRequestObj.Request_Status__c = 'Pending Approval';
    update ContractRequestObj;
    
    ContractRequestObj.Request_Status__c = 'Cancelled';
    update ContractRequestObj;
    
    ContractRequestObj.Request_Status__c = 'Pending NMC Setup';
    update ContractRequestObj;
    
    ContractRequestObj.Request_Status__c = 'Rejected';
    update ContractRequestObj;
    
    ContractRequestObj.Request_Status__c = 'Set-up Complete';
    update ContractRequestObj;
  
    //Modified by Shruti Karn for CR# 22542
      
    TIS_Detail__c newTISDetail = new TIS_Detail__c();
    newTISDetail.Contract_Request__c = ContractRequestObj.Id;
    newTISDetail.State__c = 'Set-up Complete';
    newTISDetail.Name = 'Request Status';
    newTISDetail.Date_Time_In__c = system.now()-1; 
    newTISDetail.Date_Time_Out__c = system.now();
    insert newTISDetail;
    list<TIS_Summary__c> lstTISSum = new list<TIS_Summary__c>();
    TIS_Summary__c newTISSum = new TIS_Summary__c();
    newTISSum.Contract_Request__c = newTISDetail.Contract_Request__c;
    newTISSum.Name = newTISDetail.Name;
    newTISSum.State__c = newTISDetail.State__c;
    newTISSum.Mins__c = 60;
    newTISSum.Hrs__c = 120;
    newTISSum.Days__c = 1;
    insert newTISSum;
    
    TIS_Summary__c newTISSum1 = new TIS_Summary__c();
    newTISSum1.Contract_Request__c = newTISDetail.Contract_Request__c;
    newTISSum1.Name = newTISDetail.Name;
    newTISSum1.State__c = newTISDetail.State__c;
    newTISSum1.Mins__c = 120;
    newTISSum1.Hrs__c = 48;
    newTISSum1.Days__c = 1;
    insert newTISSum1;
    newTISDetail.Date_Time_Out__c = system.now();
    update newTISDetail;
    newTISSum1.Hrs__c = 48;
    update newTISSum;
    update newTISDetail;
    newTISSum.Hrs__c = 16;
    update newTISSum;
    update newTISDetail;
    newTISSum.Hrs__c = 24;
    update newTISSum;
    update newTISDetail;    
 }
    
    
    
    /*************************End TestContractRequestTISDetail ***************************************/
    /************************* TestContractSoftwareOnAccount ***************************************/
      static testmethod void ContractSoftwareOnAccount()
      {
           account acct1 = [Select id ,QWBS_Status__c,QWBS_Market__c,Contract_Expiration__c from Account where Id = : acct.ID limit 1];
           try {update acct1;} catch (system.dmlexception e)
           {
               system.assert(e.getmessage().contains('Contract Expiration must be'),e.getmessage());
           }    
            acct1.QWBS_Status__c = 'MSA Customer';
            acct1.QWBS_Market__c = 'T&L';
            acct1.Contract_Expiration__c = NULL;
            try {update acct1;} catch (system.dmlexception e){
              system.assert(e.getmessage().contains('Contract Expiration must be'),e.getmessage());
            }
        try {update acct1;} catch (system.dmlexception e){
              system.assert(e.getmessage().contains('Contract Expiration must be'),e.getmessage());
            }    
      }
 /*************************End TestContractSoftwareOnAccount ***************************************/



}