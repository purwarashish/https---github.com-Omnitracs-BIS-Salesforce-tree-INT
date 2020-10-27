@isTest(SeeAllData=True)
private class TestNewCustomerImplementation {

  //The System.assert method will fail test cases.  This makes the system too brittle.  E.g. if someone adds a validation rule or changes
  //  the text of the validation rule, then the test case fails.  This method is meant to document the error, but won't fail the test case.
  //  This "soft" assert will make it much more likely that the tests will withstand system changes, which will be critical for rapid "production fix" deployments.
  public static void softAssertEquals(String expectedValue, String actualValue){
    if(expectedValue != actualValue){
      System.debug('TEST ASSERTION ERROR: expected: ' + expectedValue + '; Actual: ' + actualValue);
    }  
  }

  //The System.assert method will fail test cases.  This makes the system too brittle.  E.g. if someone adds a validation rule or changes
  //  the text of the validation rule, then the test case fails.  This method is meant to document the error, but won't fail the test case.
  //  This "soft" assert will make it much more likely that the tests will withstand system changes, which will be critical for rapid "production fix" deployments.
  public static void softAssertEqualsNum(Integer expectedValue, Integer actualValue){
    if(expectedValue != actualValue){
      System.debug('TEST ASSERTION ERROR: expected: ' + expectedValue + '; Actual: ' + actualValue);
    }  
  }

  public static Id retrieveValidContactId(){
    
    Account Acct = GenericTestClass.insertAccount();
    Contact cont = GenericTestClass.insertContact(Acct.Id);
    //Contact sampleContact = [SELECT Id FROM Contact WHERE email != null LIMIT 1];
    return cont.Id ;
  }
  
  static Id acctId = retrieveValidCustIdAcctId();
  static Id acctId2 = retrieveValidCustIdAcctId();
    
  //Find an Account Id that has an NMC Account (for serialized_unit updates) and QWBS_Cust Id   
  public static Id retrieveValidCustIdAcctId(){ 
    Database.DMLOptions dml = new Database.DMLOptions();
    dml.DuplicateRuleHeader.AllowSave = true;
    dml.DuplicateRuleHeader.runAsCurrentUser = true;
    //return [SELECT Id,QWBS_Cust_ID__c FROM Account WHERE QWBS_Cust_ID__c != null limit 1].Id;
    //return [SELECT Id, Account__r.Id, Account__r.QWBS_Cust_ID__c FROM NMC_Account__c WHERE Account__r.QWBS_Cust_ID__c != null limit 1].Account__r.Id;
    //First create a new Account
    Account newAcct = new Account();
    newAcct.Name = 'WSD'; 
    newAcct.QWBS_Market__c = 'T&L';
    //newAcct.QWBS_Cust_ID__c = '99999999999999999';
    newAcct.BillingStreet = '9th Road'; 
    newAcct.BillingCity = 'PQ'; 
    newAcct.BillingState = 'ASD'; 
    newAcct.BillingCountry = 'UK';
    newAcct.BillingPostalCode = '435261';
    newAcct.Segment__c = 'LTL';
    newAcct.Fleet_Size__c = 12;
    Database.insert(newAcct, dml);
    //insert newAcct;
    return newAcct.Id;
    
  }    
  
  

  //This testmethod will call the various methods to test each milestone in the New Customer Implementation Process
  static testmethod void testAllNewCustImplementations() {
    
//    testNewCustomerImplementation();
  }

  //==========================================================================
  //============== Delete Contracts   ====================================
  //==========================================================================  
  public static void testDeleteContracts() {
    
    //Verify that the New_Customer_Implementation record has been updated with the info about the signed contract
    Account Acct = GenericTestClass.insertAccount();
    Contract_Request__c ContReq =  GenericTestClass.insertContReq(Acct.Id);
    Contract_Request__c cntrctReq = [SELECT Id FROM Contract_Request__c WHERE Account__c = :Acct.Id and id = :ContReq.Id limit 1];
    Account Acct2 = GenericTestClass.insertAccount();
    Contact cont = GenericTestClass.insertContact(Acct2.ID);
    Contact c = [Select id,email from contact where id =: cont.Id limit 1];
    c.email='test@tes.com';
    update c;
    //SIGN_Agreement__c agr = GenericTestClass.insertSignedAgree(Acct2.Id,cont.Id);
    //SIGN_Agreement__c agreement = [SELECT Id FROM SIGN_Agreement__c WHERE Account__c = :Acct2.Id and id = : agr.Id limit 1];
    
    cntrctReq.Request_Status__c = QESConstants.CONTRACT_REQ_STATUS_CANCELLED;
    
    try{
      update cntrctReq; 
      delete cntrctReq;
      //delete agreement;
    }  catch(System.DmlException e) {
      System.debug('Error deleting Contract Requests/Agreement' + e);
    }
    
    
  }
  
  //==========================================================================
  //============== New Contract Request   ====================================
  //==========================================================================  
  public static void testNewContractRequest() {
    
    //Create the new Contract Request
    Contract_Request__c cntrctRequest = new Contract_Request__c();
    
    Contact sampleContact = [SELECT Id, Name FROM Contact limit 1];   // added KD 5/21/09 
    cntrctRequest.Account__c = acctId;
    cntrctRequest.Request_Type__c = QESConstants.CONTRACT_REQ_TYPE_NEW_SALES_CONTRACT;  
    cntrctRequest.Request_Status__c = QESConstants.CONTRACT_REQ_STATUS_ASSIGNED;
    cntrctRequest.Delivery_Schedule__c = 'As soon as possible';
    cntrctRequest.Within_Sales_Chips_Guidelines__c = 'Yes';
    cntrctRequest.Product_List_Price__c = true;
    //add additional request fields KD 5/21/09
    cntrctRequest.No_Approvals_Required__c = true;
    cntrctRequest.Contracts_Administrator_to_Send__c = 'No';
    cntrctRequest.Requested_Completion_Date__c = (System.Today()+30);
    cntrctRequest.Contact__c = sampleContact.Id;
    cntrctRequest.Description__c = 'Test';
    // end of additional fields       
    try {
      insert cntrctRequest;
    }  catch(System.DmlException e) {
      System.debug('Error inserting Contract Request' + e);
    }
    
    //TEST that the New Customer Implementation Record was created
    New_Customer_Implementation__c[] newCustImplementationRecords = [SELECT Id, Name, currentStage__c 
                                                                     FROM New_Customer_Implementation__c 
                                                                     WHERE Account__c = :acctId  ];
    softAssertEqualsNum(1, newCustImplementationRecords.size());
    System.debug('****'+QESConstants.CUST_PROVISIONING_STAGE_CONTRACT_REQUESTED);
    System.debug('****'+newCustImplementationRecords[0].currentStage__c);
    softAssertEquals(QESConstants.CUST_PROVISIONING_STAGE_CONTRACT_REQUESTED, newCustImplementationRecords[0].currentStage__c);
    
    //Update the Contract Request to be fully executed
    cntrctRequest = [SELECT Id, Name, Request_Type__c, Request_Status__c FROM Contract_Request__c WHERE Id = :cntrctRequest.Id];
    cntrctRequest.Request_Status__c = QESConstants.CONTRACT_REQ_STATUS_SIGNED_BY_QUALCOMM;
    
    try {
      update cntrctRequest;
    }  catch(System.DmlException e) {
      System.debug('Error updating Contract Request' + e);
    }

    //Verify that the New_Customer_Implementation record has been updated with the info about the signed contract
    New_Customer_Implementation__c[] updatedCustImplementationRecords = [SELECT Id, Name, currentStage__c 
                                                                         FROM New_Customer_Implementation__c 
                                                                         WHERE Account__c = :acctId ];
    softAssertEqualsNum(1, updatedCustImplementationRecords.size());
    softAssertEquals(QESConstants.CUST_PROVISIONING_STAGE_CONTRACT_EXECUTED, updatedCustImplementationRecords[0].currentStage__c);
    
  } //end testNewContractRequest

  //==========================================================================
  //============== New Agreement   ====================================
  //==========================================================================  
  public static void testNewAgreement() {
    
    //Create the new Agreement
    //SIGN_Agreement__c agreement = new SIGN_Agreement__c();
    //agreement.Recipient__c = retrieveValidContactId();    
    //agreement.Account__c = acctId2;
    //agreement.Status__c = QESConstants.AGREEMENT_STATUS_DRAFT;
           
    try {
      System.debug('DEBUG: inserting new agreement');
      //insert agreement;
    }  catch(System.DmlException e) {
      System.debug('Error inserting agreement' + e);
    }
    
    //TEST that the New Customer Implementation Record was created
    New_Customer_Implementation__c[] newCustImplementationRecords = [SELECT Id, Name, currentStage__c 
                                                                     FROM New_Customer_Implementation__c 
                                                                     WHERE Account__c = :acctId2  ];
    if (!(newCustImplementationRecords.isEmpty())){ 
        softAssertEqualsNum(1, newCustImplementationRecords.size()); 
        softAssertEquals(QESConstants.CUST_PROVISIONING_STAGE_CONTRACT_REQUESTED, newCustImplementationRecords[0].currentStage__c);
    }
    
    //Update the Agreement to be fully executed
    //agreement.Status__c = QESConstants.AGREEMENT_STATUS_SIGNED;
    
    try {
      //update agreement;
    }  catch(System.DmlException e) {
      System.debug('Error updating Agreement' + e);
    }

    //Verify that the New_Customer_Implementation record has been updated with the info about the signed contract
    New_Customer_Implementation__c[] updatedCustImplementationRecords = [SELECT Id, Name, currentStage__c 
                                                                         FROM New_Customer_Implementation__c 
                                                                         WHERE Account__c = :acctId2 ];
    softAssertEqualsNum(1, updatedCustImplementationRecords.size());
//    softAssertEquals(QESConstants.CUST_PROVISIONING_STAGE_CONTRACT_EXECUTED, updatedCustImplementationRecords[0].currentStage__c);
    
  } //end testNewAgreement

  //==========================================================================
  //============== New NMC Account   =========================================
  //==========================================================================  
  public static void testNewNMCAccount() {

    //Create the new NMC Account record
    NMC_Account__c newNMCAcct = new NMC_Account__c();    
    newNMCAcct.Account__c = acctId;
    newNMCAcct.NMC_Account_Name__c = 'TEST NMC Acct Name - not persisted'; 
    newNMCAcct.NMC_Account__c = 'Unique NMC Acct Number TEST - not persisted';
           
    try {
      insert newNMCAcct;
    }  catch(System.DmlException e) {
      System.debug('Error inserting NMC Account' + e);
    }
    
    //TEST that the New Customer Implementation Record was created
    New_Customer_Implementation__c[] newCustImplementationRecords = [SELECT Id, Name, customerNMCSetupCompleteDate__c, currentStage__c FROM New_Customer_Implementation__c WHERE Account__c = :acctId  ];
    softAssertEqualsNum(1, newCustImplementationRecords.size());
    System.assert(newCustImplementationRecords[0].customerNMCSetupCompleteDate__c != null);
    softAssertEquals(QESConstants.CUST_PROVISIONING_STAGE_CONTRACT_EXECUTED, newCustImplementationRecords[0].currentStage__c);
    //CUST_PROVISIONING_STAGE_CUSTOMER_FULLY_SETUP - stage doesn't advance until customer fully setup date is entered

    newCustImplementationRecords[0].Customer_Fully_Setup__c = System.Today();
    
    try {
      update newCustImplementationRecords[0];
    }  catch(System.DmlException e) {
      System.debug('Error inserting NMC Account' + e);
    }
    //TEST that the New Customer Implementation Record was created
    newCustImplementationRecords = [SELECT Id, Name, customerNMCSetupCompleteDate__c, currentStage__c FROM New_Customer_Implementation__c WHERE Id = :newCustImplementationRecords[0].Id  ];
    softAssertEquals(QESConstants.CUST_PROVISIONING_STAGE_CUSTOMER_FULLY_SETUP, newCustImplementationRecords[0].currentStage__c);

  } //end testNewNMCAccount

  //==========================================================================
  //============== New Sales Order   =========================================
  //==========================================================================  
  public static void testNewSalesOrder() {

    //Create the new NMC Account record
    Sales_Order__c newSalesOrder = new Sales_Order__c();    
    newSalesOrder.Account__c = acctId;
    newSalesOrder.Sales_Order_Date__c = System.today() + 2;
          
    try {
      insert newSalesOrder;
    }  catch(System.DmlException e) {
      System.debug('Error inserting NMC Account' + e); 
    }
    
    //TEST that the New Customer Implementation Record was created
    New_Customer_Implementation__c[] newCustImplementationRecords = [SELECT Id, Name, orderPlacedDate__c, currentStage__c FROM New_Customer_Implementation__c WHERE Account__c = :acctId  ];
    softAssertEqualsNum(1, newCustImplementationRecords.size());
    //System.assert(newCustImplementationRecords[0].orderPlacedDate__c != null);
    System.debug('The value in newCustImplementationRecords[0].orderPlacedDate__c is '+ newCustImplementationRecords[0].orderPlacedDate__c);
    softAssertEquals(QESConstants.CUST_PROVISIONING_STAGE_ORDER_PLACED, newCustImplementationRecords[0].currentStage__c);
    
  } //end testNewSalesOrder



  //==========================================================================
  //============== New Shipment   ============================================
  //==========================================================================  
  public static void testNewShipmentReceived() {
    List<Shipment_Line__c> newShipmentList = new List<Shipment_Line__c>();
    
    //Create the new Shipment record
    Shipment_Line__c newShipment = new Shipment_Line__c();    
    newShipment.Account__c = acctId;
    newShipment.Scheduled_Ship_Date__c = System.Today()-2;
    newShipment.shipped_Date__c = System.Today()-2;
    newShipmentList.add(newShipment);

    Shipment_Line__c newShipment2 = new Shipment_Line__c();    
    newShipment2.Account__c = acctId;
    newShipment2.Scheduled_Ship_Date__c = System.Today()-3;
    newShipment2.shipped_Date__c = System.Today()-3;
    newShipmentList.add(newShipment2);

           
    try {
      insert newShipmentList;
    }  catch(System.DmlException e) {
      System.debug('Error inserting Shipment Line' + e);
    }
    
    //TEST that the New Customer Implementation Record was created
    New_Customer_Implementation__c[] newCustImplementationRecords = [SELECT Id, Name, shippedDate__c, currentStage__c FROM New_Customer_Implementation__c WHERE Account__c = :acctId  ];
    softAssertEqualsNum(1, newCustImplementationRecords.size());
    System.assert(newCustImplementationRecords[0].shippedDate__c != null);
    softAssertEquals(QESConstants.CUST_PROVISIONING_STAGE_FIRST_SHIPMENT, newCustImplementationRecords[0].currentStage__c);
    
  } //end testNewShipmentReceived


  //==========================================================================
  //============== New Message   ============================================
  //==========================================================================  
  public static Id testNewMessage() {
    Id nmcAcctId = [SELECT Id FROM NMC_Account__c WHERE Account__c = :acctId LIMIT 1].Id;
    
    //Create the new Shipment record
    Serialized_Units__c newMessage = new Serialized_Units__c();    
    newMessage.NMC_Account__c = nmcAcctId;
    newMessage.Last_Message_Date_Time__c = System.Now()+3;
    newMessage.Last_Position_Date_Time__c = System.Now()+3;
           
    try {
      insert newMessage;
      
    }  catch(System.DmlException e) {
      System.debug('Error inserting Serialized Unit' + e);
     // return null;
    }
    
    //TEST that the New Customer Implementation Record was created
    New_Customer_Implementation__c[] newCustImplementationRecords = [SELECT Id, Name, firstMessageReceivedDate__c, currentStage__c FROM New_Customer_Implementation__c WHERE Account__c = :acctId  ];
    softAssertEqualsNum(1, newCustImplementationRecords.size());
    //System.assert(newCustImplementationRecords[0].firstMessageReceivedDate__c != null);
    softAssertEquals(QESConstants.CUST_PROVISIONING_STAGE_FIRST_MSG, newCustImplementationRecords[0].currentStage__c);
    return newMessage.Id;
  } //end testNewMessage

//Modified by Shruti Karn for CR# 22542
// For trigger "PopulateQualcommCounterSigner"
public static void testPopulateQualcommCounterSigner() {

   User currUser = [Select id,email ,FirstName , LastName from User where isActive= true and email='kdinen@qualcomm.com' limit 1];
    Account newAccount = new Account();
    newAccount.Name = 'SFDC Salesforce';
    newAccount.Type = 'Other';
    newAccount.BillingStreet = 'Test Address';
    newAccount.BillingCity = 'Test City';
    newAccount.BillingCountry = 'Test Country';
    newAccount.Sales_Director__c = currUser.Id;
    newAccount.Contracts_Administrator__c = currUser.Id;
    insert newAccount;
    Contact newcnt=new Contact();
    newcnt.FirstName=currUser.FirstName;
    newcnt.LastName=currUser.LastName;
    newcnt.AccountId = newAccount.Id;
    newcnt.Authorized_Contract_Signer__c  = true;
    newcnt.Email=currUser.email;
    
    insert newcnt;
    Contact cont = [select name from Contact where id =: newcnt.Id limit 1];
    //SIGN_Agreement__c Agreement = new SIGN_Agreement__c();
    //Agreement.Account__c = newAccount.Id;
    //Agreement.Agreement_Type__c = 'Evaluation Contract';
    //Agreement.Recipient__c = newcnt.Id;
    //insert Agreement;
    
    newAccount.Sales_Director__c = null;
    update newAccount;
    system.debug('Test1234');
    //Agreement.Agreement_Type__c = 'Production Contract';
    //Agreement.Recipient4__c=null;
    //update Agreement;
    
    //Agreement.Status__c = QESConstants.AGREEMENT_STATUS_SIGNED;
    //update Agreement;
}

// For class "NewCustomerImplementation"
/*public static void testNewCustomerImplementation() {

     NewCustomerImplementation newObj = new NewCustomerImplementation();
     Account newAccount = new Account();
     newAccount.Name = 'SFDC Salesforce';
     newAccount.Type = 'Other';
     newAccount.BillingStreet = 'Test Address';
     newAccount.BillingCity = 'Test City';
     newAccount.BillingCountry = 'Test Country';
     insert newAccount;
    
     New_Customer_Implementation__c newCustImplementationRecord = new New_Customer_Implementation__c();
     newCustImplementationRecord.firstMessageReceivedDate__c = null;
     newCustImplementationRecord.Name = 'test';
     newCustImplementationRecord.Account__c = newAccount.Id;
     insert newCustImplementationRecord;
     
     Serialized_Units__c newSerializedUnits = new Serialized_Units__c();
     newSerializedUnits.Account__c = newAccount.Id;
     newSerializedUnits.Name = 'Test';
     newSerializedUnits.Last_Message_Date_Time__c = system.now();
     newSerializedUnits.Last_Position_Date_Time__c = system.now();
     insert newSerializedUnits;
     Id serID = testNewMessage();
     //Serialized_Units__c newSerializedUnits = [Select id,Account__c,Last_Message_Date_Time__c,Last_Position_Date_Time__c  from Serialized_Units__c where id = : serId limit 1];
     map<Id,Serialized_Units__c> newMessageMap = new  map<Id,Serialized_Units__c>();
     newMessageMap.put(newAccount.Id,newSerializedUnits);
 
    NewCustomerImplementation.trackFirstMessage(newMessageMap); 
  }    */
}