/***********************************************************************************
Date: 4/29/2008
Author: Kasia Dinen

Overview: 


************************************************************************************/
trigger CaseValidationForNMCRequests on Case (before insert, before update) {

     /*BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }

//TODO: Update this trigger to handle incoming records in bulk rather than
//      assuming that there will be only a single NMC_Request being insert/updated
  Case caseRecord = Trigger.New[0];
// Only enter this trigger if the Case Record type is an NMC Request 
  if (
      ( caseRecord.RecordTypeId != '01250000000DTGN')
      || ( caseRecord.RecordTypeId != '01250000000DT5t')
      ) 
  {
    Map<string,string> idNameMap = CaseValidationUtils.getRecordTypesForCases();    

//===================================================================================
//================ NMC  Request Validations ==========================================
//===================================================================================
System.debug('CASE NMC Request validation - recordType map is ' + idNameMap);
System.debug('CASE NMC Request validation - case record type is ' + caseRecord.RecordTypeId);
System.debug('CASE NMC Request validation - case category is ' + caseRecord.Category__c);
System.debug('CASE NMC Request validation - case Type_Level_2__c is ' + caseRecord.Type_Level_2__c);
System.debug('CASE NMC Request validation - case status is ' + caseRecord.Status);  
System.debug('CASE NMC Request validation - case Substatus__c is ' + caseRecord.Substatus__c);  
System.debug('CASE NMC Request validation - NMC Account Request record type from idNameMap=' + idNameMap.get(caseRecord.RecordTypeId));
System.debug('CASE NMC Request validation - NMC Account Request record type from QESConstants=' + QESConstants.REC_TYPE_CASE_NMC_ACCT_REQ);

  if ( 
       (idNameMap.get(caseRecord.RecordTypeId)==QESConstants.REC_TYPE_CASE_NMC_ACCT_REQ)
    || (idNameMap.get(caseRecord.RecordTypeId)==QESConstants.REC_TYPE_CASE_NMC_ACCT_REQ_SUBMITTED)
    || (idNameMap.get(caseRecord.RecordTypeId)==QESConstants.REC_TYPE_CASE_NMC_ACCT_REQ_CLOSED)
     ){     
//==========================================================================
//==== ALL NMC Request Validations (not specific to type of request)  ======
//==========================================================================
      CaseValidationUtils.validateDefaultUnitType(caseRecord); 
        
//Always validate Additional NMC Account info;  Previously only checked if this request was of a certain record type.
//  If there is NO Add'l NMC Account info specified at all, then there will not be an error. 
//  E.g. many of the layouts don't have Add'l NMC Account info, so there will be no errors from this method.
      CaseValidationUtils.validateAdditionalNMCAccount(caseRecord); 
//Set the Customer ID based on the Customer ID from the Account
//CaseValidationUtils.updateCustomerIdValuesOnRequest(caseRecord);
      
//only populate contracts admin on NMC account requests KD 5/20/09
        ID acctId = caseRecord.AccountId;
//Copy the Contracts Administrator from the Account to this NMC Account Request (Case)
        try{
        if (acctId != null) {
            Account parentAccount = [SELECT  a.Contracts_Administrator__c FROM Account a WHERE Id = :acctId];
            caseRecord.Contracts_Administrator__c = parentAccount.Contracts_Administrator__c; 
        }
        } catch(exception e)
      {}
//===============================================================================
//=============== 'Create' NMC Request Validations  =============================
//===============================================================================
      if (caseRecord.Type_Level_2__c==QESConstants.CASE_TYPE_LEVEL2_NEW_NMC_ACCOUNT) {
        CaseValidationUtils.validateDefaultNMCSetForInactive(caseRecord);
        CaseValidationUtils.validateNMCAndAddlNMCAccountUnit(caseRecord);
//===============================================================================
//=============== 'Update' NMC Request Validations  =============================
//===============================================================================
      } else if (caseRecord.Type_Level_2__c==QESConstants.CASE_TYPE_LEVEL2_UPDATE_NMC_ACCOUNT){     
        CaseValidationUtils.checkIfNMCAccountNumberexists(caseRecord);
        CaseValidationUtils.validateDefaultNMCSetForInactive(caseRecord);    
//===============================================================================
//=============== 'Transfer' NMC Request Validations  ===========================
//===============================================================================
      } else if (caseRecord.Type_Level_2__c==QESConstants.CASE_TYPE_LEVEL2_TRANSFER_NMC_ACCOUNT) {
        CaseValidationUtils.validateDefaultNMCSetForInactive(caseRecord);
        CaseValidationUtils.checkIfNMCAccountNumberexists(caseRecord);

// verify default unit type isn't already being used in the "transfer to" NMC accounts
        CaseValidationUtils.validateNMCAndAddlNMCAccountUnit(caseRecord);  
      }
     
 
//===============================================================================
//=============== 'Completed' NMC Request Validations  ==========================
//===============================================================================
      if ( (caseRecord.Status == QESConstants.CASE_STATUS_CLOSED)
            && (  (caseRecord.Substatus__c == QESConstants.CASE_SUBSTATUS_COMPLETED) 
               || (caseRecord.Substatus__c == QESConstants.CASE_SUBSTATUS_RESOLVED) )) { 

        CaseValidationUtils.validateAddlNMCAccountIsDiffThanNMCAccount(caseRecord);     
        CaseValidationUtils.validateDefaultNMCAcccountSelected(caseRecord);  //KD 7-15-08               

        if (caseRecord.Type_Level_2__c==QESConstants.CASE_TYPE_LEVEL2_NEW_NMC_ACCOUNT){
            CaseValidationUtils.checkIfNMCAccountIsUnique(caseRecord);
            CaseValidationUtils.validateAddlNMCAccountIsUnique(caseRecord);                     
            CaseValidationUtils.validateUnitTypesNotAlreadyExists(caseRecord, caseRecord.AccountId, true);
        } else if (caseRecord.Type_Level_2__c==QESConstants.CASE_TYPE_LEVEL2_UPDATE_NMC_ACCOUNT){  
            CaseValidationUtils.validateUnitTypesNotAlreadyExists(caseRecord, caseRecord.AccountId, true);
        } else if (caseRecord.Type_Level_2__c==QESConstants.CASE_TYPE_LEVEL2_TRANSFER_NMC_ACCOUNT){
            CaseValidationUtils.validateUnitTypesNotAlreadyExists(caseRecord, caseRecord.Transfer_to_Account__c, true);
        }
      }
    }  //end if statement - NMC Request validations

//===============================================================================
//=============== 'Populate Contracts Administrator field =======================
//===============================================================================
  
//only populate contracts admin on NMC account requests KD 5/20/09      
//  ID acctId = caseRecord.AccountId;
  
//Copy the Contracts Administrator from the Account to this NMC Account Request (Case)
//if (acctId != null) {
//  Account parentAccount = [SELECT  a.Contracts_Administrator__c FROM Account a WHERE Id = :acctId];
//  caseRecord.Contracts_Administrator__c = parentAccount.Contracts_Administrator__c; 
//  }
}*/
}