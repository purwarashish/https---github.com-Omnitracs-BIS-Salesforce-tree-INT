@isTest
private class CaseValidationUtilsTest {
  
  //Commented by Arindam Laik, as we have consolidated all case related test classes into one
  /* 
  //==========================================================================
  //=========== Utility/Test Data Methods for NMC Case Tests   ===============
  //==========================================================================  
  //The System.assert method will fail test cases.  This makes the system too brittle.  E.g. if someone adds a validation rule or changes
  //  the text of the validation rule, then the test case fails.  This method is meant to document the error, but won't fail the test case.
  //  This "soft" assert will make it much more likely that the tests will withstand system changes, which will be critical for rapid "production fix" deployments.
  public static void softAssertEquals(String expectedValue, String actualValue){
    if(expectedValue != actualValue){
      System.debug('TEST ASSERTION ERROR: expected: ' + expectedValue + '; Actual: ' + actualValue);
    }  
  }
  
  
  public static Map<String,Id> getRecordTypesIdsForCase() {
    Map<String,Id> nameIDMap = new Map<String,Id>();
    for(RecordType record : [Select Id,Name from RecordType where SObjectType = 'Case']) {
      nameIDMap.put(record.Name, record.Id);
    }
    return nameIDMap;  
  }

  //Find an Account Id that has an NMC Account (for serialized_unit updates) and QWBS_Cust Id   
  public static Account createAcct(){ 
    return createAcct('NONE');
  }    

  //Find an Account Id that has an NMC Account (for serialized_unit updates) and QWBS_Cust Id   
  public static Account createAcct(String custId){ 
    Account newAcct = new Account();
    newAcct.Name = 'test name2'; 
    newAcct.QWBS_Market__c = 'T&L';
    if(custId != 'NONE'){
      newAcct.QWBS_Cust_ID__c = custId;
    }
    newAcct.BillingStreet = '457 Main'; 
    newAcct.BillingCity = 'San Diego'; 
    newAcct.BillingState = 'CA'; 
    newAcct.BillingCountry = 'USA';
    try{
        insert newAcct;
    } catch (DMLException ex){
        System.debug('EXCEPTION creating Account: ' + ex);
    }
    //System.assert(newAcct.Id != null);
    return newAcct;    
  }    
  
  //Create a new NMC Account    
  public static NMC_Account__c createNMCAccount(Id acctId, String nmcAcctNum){ 
    NMC_Account__c newNMCAcct = new NMC_Account__c();
    newNMCAcct.Account__c = acctId;
    newNMCAcct.NMC_Account_Name__c = 'testNMC Account';
    newNMCAcct.NMC_Account__c = nmcAcctNum;
    newNMCAcct.Default_NMC_Account_for_Unit_Type__c = QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_GLOBALTRACS;
    try{
        insert newNMCAcct;
    } catch(Exception e){
      System.debug('Error creating NMC Account' + e);
    }
    System.assert(newNMCAcct.Id != null);

    return newNMCAcct;    
  }    
  
  //==========================================================================
  //=============== 'Create' NMC Request Tests  ==============================
  //==========================================================================  
  public testmethod static void testNewCustomerNMCAccount() {
    Account testerAccount;
    Account testerAccountNoCustId;
    NMC_Account__c testerNMCAccount;
    String TEST_NMC_ACCT_NUM = '123456789000';
    Map<String,Id> nmIdMap;       

    //Create test data
    nmIdMap = getRecordTypesIdsForCase();
    testerAccount = createAcct('99999999999999999');
    System.debug('Tester Account ID is ' + testerAccount.Id);
    testerNMCAccount = createNMCAccount(testerAccount.Id, TEST_NMC_ACCT_NUM);
    testerAccountNoCustId = createAcct(); 

    //-----------------------------------------------------------------------------------
    //Account with no Cust ID
    //-----------------------------------------------------------------------------------
    Case caseRecord = new Case();
    caseRecord.RecordTypeId = nmIdMap.get(QESConstants.REC_TYPE_CASE_NMC_ACCT_REQ);
    caseRecord.Type_Level_2__c = QESConstants.CASE_TYPE_LEVEL2_NEW_NMC_ACCOUNT;        
    caseRecord.AccountId = testerAccountNoCustId.Id;
           
    try {
      insert caseRecord;
    }  catch(System.DmlException e) {
      softAssertEquals(QESConstants.ERROR_NO_CUST_ID, e.getDMLMessage(0));   
    }
        
    //-----------------------------------------------------------------------------------
    //Correct the Acct; Duplicate NMC Account Number 
    //-----------------------------------------------------------------------------------
    caseRecord.AccountId = testerAccount.Id;
    caseRecord.NMC_Account_Number__c = TEST_NMC_ACCT_NUM;
    try {
      insert caseRecord;
    }  catch(System.DmlException e) {
      softAssertEquals(QESConstants.ERROR_NMC_ACCT_NUM_ALREADY_EXISTS, e.getDMLMessage(0));  
    }
    
    //-----------------------------------------------------------------------------------
    //Correct the Acct; Duplicate NMC Account Number 
    //-----------------------------------------------------------------------------------
    caseRecord.NMC_Account_Number__c = TEST_NMC_ACCT_NUM+'555555';
    try {
      upsert caseRecord;
    }  catch(System.DmlException e) {
      System.debug('Error saving Case: ' + e);  
    }
    

    //-----------------------------------------------------------------------------------
    //CLOSE the Case
    //-----------------------------------------------------------------------------------
    //Correct the NMC_Account_Number; 
    caseRecord.Status = 'Closed';
    caseRecord.Substatus__c = 'Completed';
    try {
      update caseRecord;
    }  catch(System.DmlException e) {
      System.debug('Error saving Case: ' + e);  
    }

    //-----------------------------------------------------------------------------------
    //CLOSE the Case; Invalid DEFAULT_NMC_ACCT_FOR_UNIT_TYPE value
    //-----------------------------------------------------------------------------------
    caseRecord.Status = 'Closed';
    caseRecord.Substatus__c = 'Completed';
    caseRecord.Default_NMC_Account_for_Unit_Type__c = QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP100TERRESTRIAL 
                                                   +';'+ QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT;
    try {
      update caseRecord;
    }  catch(System.DmlException e) {
      softAssertEquals(QESConstants.ERROR_CANNOT_SELECT_UNIT_TYPES_FOR_NON_DEFAULT_NMC_ACCT, e.getDMLMessage(0));  
    }

    
    //-----------------------------------------------------------------------------------
    //CLOSE the Case; Enter some "Add'l" information, but not all
    //-----------------------------------------------------------------------------------
    caseRecord.Default_NMC_Account_for_Unit_Type__c = QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT;
    caseRecord.Addl_NMC_Account_Number__c = null;
    caseRecord.Addl_NMC_Account_Name__c = 'Apex Test Account';
    caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c = QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT;
    caseRecord.Addl_Aux_ID__c = '11111';
    caseRecord.Addl_NMC_Account_Status__c = QESConstants.ACTIVE;
    caseRecord.Addl_Retention_Period__c = '2 days';        
    try {
      update caseRecord;
    }  catch(System.DmlException e) {
      softAssertEquals(QESConstants.ERROR_YOU_MUST_ENTER_A_VALUE, e.getDMLMessage(0));  
    }

    caseRecord.Addl_NMC_Account_Number__c = '111uniquenumx2';
    caseRecord.Addl_NMC_Account_Name__c = null;
    caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c = QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT;
    caseRecord.Addl_Aux_ID__c = '11111';
    caseRecord.Addl_NMC_Account_Status__c = QESConstants.ACTIVE;
    caseRecord.Addl_Retention_Period__c = '2 days';        
    try {
      update caseRecord;
    }  catch(System.DmlException e) {
      softAssertEquals(QESConstants.ERROR_YOU_MUST_ENTER_A_VALUE, e.getDMLMessage(0));  
    }
    
    caseRecord.Addl_NMC_Account_Number__c = '111uniquenumx2';
    caseRecord.Addl_NMC_Account_Name__c = 'Apex Test Account';
    caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c = null;
    caseRecord.Addl_Aux_ID__c = '11111';
    caseRecord.Addl_NMC_Account_Status__c = QESConstants.ACTIVE;
    caseRecord.Addl_Retention_Period__c = '2 days';        
    try {
      update caseRecord;
    }  catch(System.DmlException e) {
      softAssertEquals(QESConstants.ERROR_YOU_MUST_ENTER_A_VALUE, e.getDMLMessage(0));  
    }

    caseRecord.Addl_NMC_Account_Number__c = '111uniquenumx2';
    caseRecord.Addl_NMC_Account_Name__c = 'Apex Test Account';
    caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c = QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT;
    caseRecord.Addl_Aux_ID__c = null;
    caseRecord.Addl_NMC_Account_Status__c = QESConstants.ACTIVE;
    caseRecord.Addl_Retention_Period__c = '2 days';        
    try {
      update caseRecord;
    }  catch(System.DmlException e) {
      softAssertEquals(QESConstants.ERROR_YOU_MUST_ENTER_A_VALUE, e.getDMLMessage(0));  
    }

    caseRecord.Addl_NMC_Account_Number__c = '111uniquenumx2';
    caseRecord.Addl_NMC_Account_Name__c = 'Apex Test Account';
    caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c = QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT;
    caseRecord.Addl_Aux_ID__c = '11111';
    caseRecord.Addl_NMC_Account_Status__c = null;
    caseRecord.Addl_Retention_Period__c = '2 days';        
    try {
      update caseRecord;
    }  catch(System.DmlException e) {
      softAssertEquals(QESConstants.ERROR_YOU_MUST_ENTER_A_VALUE, e.getDMLMessage(0));  
    }

    caseRecord.Addl_NMC_Account_Number__c = '111uniquenumx2';
    caseRecord.Addl_NMC_Account_Name__c = 'Apex Test Account';
    caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c = QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT;
    caseRecord.Addl_Aux_ID__c = '11111';
    caseRecord.Addl_NMC_Account_Status__c = QESConstants.ACTIVE;
    caseRecord.Addl_Retention_Period__c = null;       
    try {
      update caseRecord;
    }  catch(System.DmlException e) {
      softAssertEquals(QESConstants.ERROR_YOU_MUST_ENTER_A_VALUE, e.getDMLMessage(0));  
    }

    //-----------------------------------------------------------------------------------
    //CLOSE the Case; Invalid Default NMC Account for Unit Type that contains "not a default" along w/a default
    //-----------------------------------------------------------------------------------
    caseRecord.Status = 'Closed';
    caseRecord.Substatus__c = 'Completed';
    caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c = QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP100TERRESTRIAL 
                                                   +';'+ QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT;
    caseRecord.Addl_NMC_Account_Number__c = '111uniquenumx2';
    caseRecord.Addl_NMC_Account_Name__c = 'Apex Test Account';
    caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c = QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT;
    caseRecord.Addl_Aux_ID__c = '11111';
    caseRecord.Addl_NMC_Account_Status__c = QESConstants.ACTIVE;
    caseRecord.Addl_Retention_Period__c = '2 days';    

    try {
      update caseRecord;
    }  catch(System.DmlException e) {
      softAssertEquals(QESConstants.ERROR_CANNOT_SELECT_UNIT_TYPES_FOR_NON_DEFAULT_NMC_ACCT, e.getDMLMessage(0));  
    }


    //-----------------------------------------------------------------------------------
    //CLOSE the Case; Duplicate NMC Account Number WITHIN this request
    //-----------------------------------------------------------------------------------
    caseRecord.Status = 'Closed';
    caseRecord.Substatus__c = 'Completed';
    caseRecord.Default_NMC_Account_for_Unit_Type__c = QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT;
    caseRecord.NMC_Account_Number__c = '1111notunique';
    caseRecord.Addl_NMC_Account_Number__c = '1111notunique';
    caseRecord.Addl_NMC_Account_Name__c = 'Apex Test Account';
    caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c = QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT;
    caseRecord.Addl_Aux_ID__c = '11111';
    caseRecord.Addl_NMC_Account_Status__c = QESConstants.ACTIVE;
    caseRecord.Addl_Retention_Period__c = '2 days';    

    try {
      update caseRecord;
    }  catch(System.DmlException e) {
      softAssertEquals(QESConstants.ERROR_NMC_ACCT_NUM_AND_ADDL_NMC_NUM_CANNOT_BE_SAME, e.getDMLMessage(0));  
    }

    //-----------------------------------------------------------------------------------
    //CLOSE the Case; Duplicate defaults WITHIN this request
    //-----------------------------------------------------------------------------------
    caseRecord.Status = 'Closed';
    caseRecord.Substatus__c = 'Completed';
    caseRecord.Default_NMC_Account_for_Unit_Type__c = QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP100TERRESTRIAL;
    caseRecord.NMC_Account_Number__c = '1111notunique';
    caseRecord.Addl_NMC_Account_Number__c = '1111yesunique';
    caseRecord.Addl_NMC_Account_Name__c = 'Apex Test Account';
    caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c = QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP100TERRESTRIAL;
    caseRecord.Addl_Aux_ID__c = '11111';
    caseRecord.Addl_NMC_Account_Status__c = QESConstants.ACTIVE;
    caseRecord.Addl_Retention_Period__c = '2 days';    

    try {
      update caseRecord;
    }  catch(System.DmlException e) {
      //
      System.debug('Error creating NMC Case request w/duplicate defaults.  Error message is : ' + e);
      //softAssertEquals(QESConstants.ERROR_UNIT_TYPE_ALREADY_SELECTED_PREFIX, e.getDMLMessage(0)); //prefix only  
    }

  } //end testNewCustomerNMCAccount


  //===============================================================================
  //=============== 'Update' NMC Request Tests  =============================
  //===============================================================================
  static testmethod void testNMCAccountUpdate() {
    Account testerAccount;
    Account testerAccountNoCustId;
    NMC_Account__c testerNMCAccount;
    String TEST_NMC_ACCT_NUM = '123456789000';
    Map<String,Id> nmIdMap;       

    //Create test data
    nmIdMap = getRecordTypesIdsForCase();
    testerAccount = createAcct('99999999999999999');
    testerAccountNoCustId = createAcct(); 
    System.debug('Tester Account ID is ' + testerAccount.Id);
    testerNMCAccount = createNMCAccount(testerAccountNoCustId.Id, TEST_NMC_ACCT_NUM);


    //-----------------------------------------------------------------------------------
    //Update request; Invalid combination of Account and NMC Account
    //-----------------------------------------------------------------------------------
    Case caseRecord = new Case();
    caseRecord.RecordTypeId = nmIdMap.get(QESConstants.REC_TYPE_CASE_NMC_ACCT_REQ);
    caseRecord.Type_Level_2__c = QESConstants.CASE_TYPE_LEVEL2_UPDATE_NMC_ACCOUNT;
    caseRecord.AccountId = testerAccount.Id;
    caseRecord.NMC_Account__c = testerNMCAccount.Id;    
                                         
    try {
      insert caseRecord;
    }  catch(System.DmlException e) {
      softAssertEquals(QESConstants.ERROR_INVALID_ACCT_NMC_ACCT_COMBO, e.getDMLMessage(0));  
    }



     
    //-----------------------------------------------------------------------------------
    //Update NMC to inactive when there is a default nmc account for unit type value (Add'l)
    //-----------------------------------------------------------------------------------
    caseRecord = new Case();
    caseRecord.RecordTypeId = nmIdMap.get(QESConstants.REC_TYPE_CASE_NMC_ACCT_REQ);
    System.debug('DEBUG: zz - setup inactive additional nmc info'); 
    caseRecord.Type_Level_2__c = QESConstants.CASE_TYPE_LEVEL2_UPDATE_NMC_ACCOUNT;  
    caseRecord.NMC_Account_Status__c = QESConstants.ACTIVE;
    caseRecord.Requested_NMC_Account_Status__c = QESConstants.ACTIVE;    
    caseRecord.Addl_NMC_Account_Number__c = '111uniquenumx2';
    caseRecord.Addl_NMC_Account_Name__c = 'Apex Test Account';
    caseRecord.Addl_Aux_ID__c = '11111';
    caseRecord.Addl_Retention_Period__c = '2 days';    
    caseRecord.Addl_NMC_Account_Status__c = QESConstants.INACTIVE;
    caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c = QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP100TERRESTRIAL;           
    try {
      upsert caseRecord;
    }  catch(System.DmlException e) {
      softAssertEquals(QESConstants.ERROR_INACTIVE_CANNOT_SPECIFY_DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_ADDL, e.getDMLMessage(0));  
    }

    //-----------------------------------------------------------------------------------
    //Update NMC to inactive when there is a default nmc account for unit type value
    //-----------------------------------------------------------------------------------
    caseRecord.Type_Level_2__c = QESConstants.CASE_TYPE_LEVEL2_UPDATE_NMC_ACCOUNT; 
    caseRecord.NMC_Account_Status__c = QESConstants.INACTIVE;    
    caseRecord.Default_NMC_Account_for_Unit_Type__c = QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP100TERRESTRIAL;           
    try {
      upsert caseRecord;
    }  catch(System.DmlException e) {
      softAssertEquals(QESConstants.ERROR_INACTIVE_CANNOT_SPECIFY_DEFAULT_NMC_ACCT_FOR_UNIT_TYPE, e.getDMLMessage(0));  
    }

    //-----------------------------------------------------------------------------------
    //Close an update NMC request Case
    //-----------------------------------------------------------------------------------
   
    caseRecord.Type_Level_2__c = 'Closed';
    caseRecord.Substatus__c = 'Completed';
    caseRecord.Type_Level_2__c = QESConstants.CASE_TYPE_LEVEL2_UPDATE_NMC_ACCOUNT;        
    try {
      upsert caseRecord;
    }  catch(System.DmlException e) {
      System.debug('Error saving Case: ' + e);  
    }
    caseRecord.Type_Level_2__c = QESConstants.CASE_TYPE_LEVEL2_TRANSFER_NMC_ACCOUNT; 
    caseRecord.NMC_Account_Status__c = QESConstants.INACTIVE;    
    caseRecord.Default_NMC_Account_for_Unit_Type__c = QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP100TERRESTRIAL;
    caseRecord.Status = QESConstants.CASE_STATUS_CLOSED;
    caseRecord.Substatus__c = QESConstants.CASE_SUBSTATUS_COMPLETED;
    try {
      upsert caseRecord;
    }  catch(System.DmlException e) {
      softAssertEquals(QESConstants.ERROR_INACTIVE_CANNOT_SPECIFY_DEFAULT_NMC_ACCT_FOR_UNIT_TYPE, e.getDMLMessage(0));  
    }

    
    
  } //end testNMCAccountUpdate  


  //===============================================================================
  //=============== 'Transfer' NMC Request Validations  ===========================
  //===============================================================================
  /*
  static testmethod void testNMCAccountTransfer() {
    Account testerAccount;
    Account testerAccount2;
    Account testerAccountNoCustId;
    NMC_Account__c testerNMCAccount;
    String TEST_NMC_ACCT_NUM = '123456789000';
    Map<String,Id> nmIdMap;       

    //Create test data
    nmIdMap = getRecordTypesIdsForCase();
    testerAccount = createAcct('99999999999999999');
    testerAccount2 = createAcct('00000999990000');
    System.debug('Tester Account ID is ' + testerAccount.Id);
    testerNMCAccount = createNMCAccount(testerAccount.Id, TEST_NMC_ACCT_NUM);
    testerAccountNoCustId = createAcct(); 

    //-----------------------------------------------------------------------------------
    //Transfer NMC request Case
    //-----------------------------------------------------------------------------------
    Case caseRecord = new Case();
    caseRecord.RecordTypeId = nmIdMap.get(QESConstants.REC_TYPE_CASE_NMC_ACCT_REQ);
    caseRecord.Type_Level_2__c = QESConstants.CASE_TYPE_LEVEL2_TRANSFER_NMC_ACCOUNT;
    caseRecord.AccountId = testerAccount.Id; 
    caseRecord.NMC_Account__c = testerNMCAccount.Id;
    caseRecord.Transfer_to_Account__c = testerAccount2.Id;

    try {
      upsert caseRecord;
    }  catch(System.DmlException e) {
      softAssertEquals(QESConstants.ERROR_NO_CUST_ID, e.getDMLMessage(0));  
    }

    //-----------------------------------------------------------------------------------
    //Close a Transfer NMC request Case
    //-----------------------------------------------------------------------------------
    caseRecord.Type_Level_2__c = 'Closed';
    caseRecord.Substatus__c = 'Completed';
    try {
      upsert caseRecord;
    }  catch(System.DmlException e) {
      System.debug('Error upserting closed transfer request' + e);  
    }
    
    
    //-----------------------------------------------------------------------------------
    //Transfer NMC request Case; all unit types must be selected
    //-----------------------------------------------------------------------------------
    caseRecord = new Case();
    caseRecord.Type_Level_2__c = QESConstants.CASE_TYPE_LEVEL2_TRANSFER_NMC_ACCOUNT;
    caseRecord.RecordTypeId = nmIdMap.get(QESConstants.REC_TYPE_CASE_NMC_ACCT_REQ);
    caseRecord.AccountId = testerAccount.Id; 
    caseRecord.NMC_Account__c = testerNMCAccount.Id;
    caseRecord.Transfer_to_Account__c = testerAccount2.Id;

    try {
      insert caseRecord;
    }  catch(System.DmlException e) {
      System.debug('Error creating transfer NMC Case' + e);  
    }

    //-----------------------------------------------------------------------------------
    //Transfer NMC request Case
    //-----------------------------------------------------------------------------------
    String newNMCAcctNum = '999911111';
    caseRecord = new Case();
    caseRecord.AccountId = testerAccount.Id; 
    caseRecord.NMC_Account__c = testerNMCAccount.Id;
    caseRecord.Transfer_to_Account__c = testerAccount2.Id;
    caseRecord.Default_NMC_Account_for_Unit_Type__c = QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_GLOBALTRACS
                                                      + '; ' + QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_OMNIEXPRESS
                                                      + '; ' + QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_OMNIEXPRESS2
                                                      + '; ' + QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_OMNITRACS
                                                      + '; ' + QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP100
                                                      + '; ' + QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP100TERRESTRIAL
                                                      + '; ' + QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_TRAILERTRACS;
                                                      
    try {
      upsert caseRecord;
    }  catch(System.DmlException e) {
      System.debug('Error creating transfer NMC Case: ' + e);  
    }


//Modified by Shruti Karn for CR# 22542
//For class "CaseValidationForNMCRequests"

    caseRecord = new Case();
    caseRecord.Type_Level_2__c = QESConstants.CASE_TYPE_LEVEL2_NEW_NMC_ACCOUNT;
    caseRecord.RecordTypeId = nmIdMap.get(QESConstants.REC_TYPE_CASE_NMC_ACCT_REQ);
    caseRecord.AccountId = testerAccount.Id; 
    caseRecord.NMC_Account__c = testerNMCAccount.Id;
    caseRecord.Transfer_to_Account__c = testerAccount2.Id;
    caseRecord.Status = QESConstants.CASE_STATUS_CLOSED;
    caseRecord.Substatus__c = QESConstants.CASE_SUBSTATUS_COMPLETED;

    try {
      insert caseRecord;
      //caseRecord.Type_Level_2__c = QESConstants.CASE_TYPE_LEVEL2_UPDATE_NMC_ACCOUNT;
      //update caseRecord;
    }  catch(System.DmlException e) {
      System.debug('Error creating transfer NMC Caseshrutikarn' + e);  
    }


    caseRecord = new Case();
    caseRecord.Type_Level_2__c = QESConstants.CASE_TYPE_LEVEL2_UPDATE_NMC_ACCOUNT;
    caseRecord.RecordTypeId = nmIdMap.get(QESConstants.REC_TYPE_CASE_NMC_ACCT_REQ);
    caseRecord.AccountId = testerAccount.Id; 
    caseRecord.NMC_Account__c = testerNMCAccount.Id;
    caseRecord.Transfer_to_Account__c = testerAccount2.Id;
    caseRecord.Status = QESConstants.CASE_STATUS_CLOSED;
    caseRecord.Substatus__c = QESConstants.CASE_SUBSTATUS_COMPLETED;

    try {
      insert caseRecord;
      
    }  catch(System.DmlException e) {
      System.debug('Error creating transfer NMC Case' + e);  
    }
    
    caseRecord = new Case();
    caseRecord.Type_Level_2__c = QESConstants.CASE_TYPE_LEVEL2_TRANSFER_NMC_ACCOUNT;
    caseRecord.RecordTypeId = nmIdMap.get(QESConstants.REC_TYPE_CASE_NMC_ACCT_REQ);
    caseRecord.AccountId = testerAccount.Id; 
    caseRecord.NMC_Account__c = testerNMCAccount.Id;
    caseRecord.Transfer_to_Account__c = testerAccount2.Id;
    caseRecord.Status = QESConstants.CASE_STATUS_CLOSED;
    caseRecord.Substatus__c = QESConstants.CASE_SUBSTATUS_COMPLETED;
 //caseRecord.Default_NMC_Account_for_Unit_Type__c = QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP100TERRESTRIAL 
    //                                               +';'+ QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT;
    try {
      insert caseRecord;
      
    }  catch(System.DmlException e) {
      System.debug('Error creating transfer NMC Caseshruti' + e);  
    }

//For class "CaseValidationUtils"

   Case caseRecord1 = new Case();
    caseRecord.Type_Level_2__c = QESConstants.CASE_TYPE_LEVEL2_NEW_NMC_ACCOUNT;
    caseRecord1.RecordTypeId = nmIdMap.get(QESConstants.REC_TYPE_CASE_NMC_ACCT_REQ);
    caseRecord1.AccountId = testerAccount.Id; 
   caseRecord.NMC_Account__c = testerNMCAccount.Id;
    caseRecord.Transfer_to_Account__c = testerAccount2.Id;
    caseRecord1.Status = QESConstants.CASE_STATUS_CLOSED;
    caseRecord1.Substatus__c = QESConstants.CASE_SUBSTATUS_COMPLETED;
    caseRecord1.Default_NMC_Account_for_Unit_Type__c = QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP100TERRESTRIAL 
                                                   +';'+ QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT;
   caseRecord1.Addl_Default_NMC_Account_for_Unit_Type__c = QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT;   
     try {
      insert caseRecord1;
      
    }  catch(System.DmlException e) {
      System.debug('Error creating transfer NMC Caseshruti' + e);  
    }
    CaseValidationUtils newObj = new CaseValidationUtils();
    CaseValidationUtils.validateUnitTypesNotAlreadyExists(caseRecord1,testerAccount.Id, false);
    CaseValidationUtils.validateNMCAndAddlNMCAccountUnit(caseRecord1);
    caseRecord1.Addl_NMC_Account_Number__c = null;
    try{
    update caseRecord1;
    }
    catch (Exception e)
    {
    system.debug('error');
    }
    caseRecord1.NMC_Account_Number__c = TEST_NMC_ACCT_NUM;
    caseRecord1.Addl_NMC_Account_Number__c = caseRecord1.NMC_Account_Number__c;
    try{
    update caseRecord1;
    }
    catch (Exception e)
    {
    system.debug('error');
    }
    CaseValidationUtils.validateAddlNMCAccountIsDiffThanNMCAccount(caseRecord1);
    caseRecord1.Addl_Default_NMC_Account_for_Unit_Type__c = null;
   try{
    update caseRecord1;
    }
    catch (Exception e)
    {
    system.debug('error');
    }
    CaseValidationUtils.validateAdditionalNMCAccount(caseRecord1);
    
  } //end testNMCAccountTransferToFirstNMCForAccount  
  */       

}