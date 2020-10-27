public class CaseValidationUtils {
  //===============================================================================
  //=============== Utility Methods ===============================================
  //===============================================================================

//*******************
//  FIELD Validations
//*******************

  // ******* NMC Account Number Exists *******
  //ERROR if no NMC Account exists with the Account and NMC Account Number in the request (must exist for 'update transactions')
  // commented by Arindam Laik, Code is replaced by 'Combination_of_Account_and_NMC_Account' validation rule
  /*public static void checkIfNMCAccountNumberexists(Case caseRecord) {
    Integer count = [SELECT count() 
                      FROM NMC_Account__c 
                      WHERE Account__c = :caseRecord.AccountId
                        AND Id = :caseRecord.NMC_Account__c];                       

    if(count == 0) {
      caseRecord.addError(QESConstants.ERROR_INVALID_ACCT_NMC_ACCT_COMBO);
    }

  }*/

  // commented by Arindam Laik, Code is replaced by validation rule
  //Default NMC Set for Inactive
  //ERROR if setting NMC_Request to "Inactive" and Default_NMC_Account_for_Unit_Type__c  is not 'Not a Default NMC Account' 
  // error should not occur if field is null (this is the case when the field in not on the page layout) KD 3-28-08    
  /*public static boolean validateDefaultNMCSetForInactive (Case caseRecord) {
    System.debug('DEBUG: into validateDefaultNMCSetForInactive; NMC Acct Status='+caseRecord.NMC_Account_Status__c);
     // replaced by 'Validate_Default_NMC_For_Inactive_NMCAcc' validation rule
     if( (caseRecord.NMC_Account_Status__c == QESConstants.INACTIVE
          || caseRecord.Requested_NMC_Account_Status__c == QESConstants.INACTIVE)
         && (caseRecord.Default_NMC_Account_for_Unit_Type__c != QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT
          && caseRecord.Default_NMC_Account_for_Unit_Type__c != null)){                                 //KD 3-28-08
        caseRecord.addError(QESConstants.ERROR_INACTIVE_CANNOT_SPECIFY_DEFAULT_NMC_ACCT_FOR_UNIT_TYPE);

        return false;
     }
     // replaced by 'Validate_DefaultNMC_Inactive_Addl_NMCAcc' validation rule
     //---Check the Add'l fields, too
     if( caseRecord.Addl_NMC_Account_Status__c == QESConstants.INACTIVE
         && caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c != QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT){

        caseRecord.addError(QESConstants.ERROR_INACTIVE_CANNOT_SPECIFY_DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_ADDL);
        return false;
     }
     
     return true;
  }*/


  // ******* NMC and Addl NMC Account Unit *******
  //Verifies that the Addl Default NMC Account for Unit Type has already been selected in the 
  //                       Default NMC Account for Unit Type picklist WITHIN THIS REQUEST.
  //  This method does NOT check all NMC Accounts for this customer...that's another method.
  public static void validateNMCAndAddlNMCAccountUnit(Case caseRecord) {
    if ( (caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c == null) 
      || (caseRecord.Default_NMC_Account_for_Unit_Type__c == null) ){
      return;
    }
    
   String[] unitTypesList = caseRecord.Default_NMC_Account_for_Unit_Type__c.split(';');
   Map<String, String> unitTypeMap = new Map<String, String>();

   for(String nextUnitType : unitTypesList){
    unitTypeMap.put(nextUnitType, nextUnitType);
   }
   
   string[] unitTypesAddl = caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c.split(';');

   System.debug('DEBUG: checking default unit type for nmc account map: ' + unitTypeMap);
   System.debug('DEBUG: checking ADDITIONAL default unit type for nmc account: ' + unitTypesAddl);
   
   for(Integer index = 0; index < unitTypesAddl.size(); index++) {
     if(unitTypesAddl[index] != QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT){
         if(unitTypeMap.containsKey(unitTypesAddl[index])) {
           caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c.addError(QESConstants.ERROR_UNIT_TYPE_ALREADY_SELECTED_PREFIX + unitTypesAddl[index]);
         }
     }
   }  
  }


  // ******* Additional NMC Account Field Edits *******
  // All-or-nothing validation logic for the "additional" fields.  I.e. if any are populated, they ALL must be populated.
  public static boolean validateAdditionalNMCAccount(Case caseRecord) {
    if(   caseRecord.Addl_NMC_Account_Number__c != null 
       || caseRecord.Addl_NMC_Account_Name__c != null  
       || caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c != null  
       || caseRecord.Addl_Aux_ID__c!=null  
       || caseRecord.Addl_NMC_Account_Status__c!=null
       || caseRecord.Addl_Retention_Period__c!=null) {
    
      if(caseRecord.Addl_NMC_Account_Number__c==null){caseRecord.Addl_NMC_Account_Number__c.addError(QESConstants.ERROR_YOU_MUST_ENTER_A_VALUE);}
      if(caseRecord.Addl_NMC_Account_Name__c==null){caseRecord.Addl_NMC_Account_Name__c.addError(QESConstants.ERROR_YOU_MUST_ENTER_A_VALUE);}
      if(caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c==null){ caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c.addError(QESConstants.ERROR_YOU_MUST_ENTER_A_VALUE);}
      if(caseRecord.Addl_Aux_ID__c==null){ caseRecord.Addl_Aux_ID__c.addError(QESConstants.ERROR_YOU_MUST_ENTER_A_VALUE);}
      if(caseRecord.Addl_NMC_Account_Status__c==null){ caseRecord.Addl_NMC_Account_Status__c.addError(QESConstants.ERROR_YOU_MUST_ENTER_A_VALUE);}
      if(caseRecord.Addl_Retention_Period__c==null){ caseRecord.Addl_Retention_Period__c.addError(QESConstants.ERROR_YOU_MUST_ENTER_A_VALUE);}
      return false;
    } 
    return true;
  }


  // ******* Default Unit Type *******
  //ERROR if selecting unit type while the default NMC Account for unit type is 'Not a Default NMC Account'
  public static void validateDefaultUnitType(Case caseRecord) {
    if(caseRecord.Default_NMC_Account_for_Unit_Type__c != null){ 
      if(caseRecord.Default_NMC_Account_for_Unit_Type__c != QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT){
        if(caseRecord.Default_NMC_Account_for_Unit_Type__c.contains (QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT)) {
          caseRecord.Default_NMC_Account_for_Unit_Type__c.addError(QESConstants.ERROR_CANNOT_SELECT_UNIT_TYPES_FOR_NON_DEFAULT_NMC_ACCT);
        }
      }
    } 
    
    if(caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c != null){ 
      if(caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c != QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT){
        if(caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c.contains (QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT)) {
          caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c.addError(QESConstants.ERROR_CANNOT_SELECT_UNIT_TYPES_FOR_NON_DEFAULT_NMC_ACCT);
        }
      }
    } 
    
  }

  //*** NMC Account Uniqueness w/in this request
  //  Verify that the NMC Account # and Add'l NMC Account # are not the same...ON THIS CASE! 
  //  This method does NOT check all NMC Accounts for this customer...that's another method.
  // commented by Arindam Laik, Code is replaced by 'Validate_NMC_Account_Number_Closed_Case' validation rule
  /*public static void validateAddlNMCAccountIsDiffThanNMCAccount(Case caseRecord) {
    if ((caseRecord.NMC_Account_Number__c == null) || (caseRecord.Addl_NMC_Account_Number__c == null) ){
      return;
    } else if (caseRecord.NMC_Account_Number__c  == caseRecord.Addl_NMC_Account_Number__c) {
      caseRecord.addError(QESConstants.ERROR_NMC_ACCT_NUM_AND_ADDL_NMC_NUM_CANNOT_BE_SAME);
    }
  }*/


  // ******* NMC Account Uniqueness *******
  //ERROR if NMC Request contains an NMC Account Number that already exists as an NMC Account (used during creation of new NMC Account)   
  public static void checkIfNMCAccountIsUnique(List<Case> lstnewCases) 
  { 
    Set<String> setNMCAccountNumber = new Set<String>();
    for(Case caseRecord :lstnewCases)
    {
        if(caseRecord.NMC_Account_Number__c != null)
        {
            setNMCAccountNumber.add(caseRecord.NMC_Account_Number__c);
        }
    }
    if(setNMCAccountNumber.size() > 0)
    {
        List<NMC_Account__c> lstNMCAccount = [SELECT id, Hub_ID__c, NMC_Account__c from NMC_Account__c where NMC_Account__c in :setNMCAccountNumber];        

        if(lstNMCAccount != null && lstNMCAccount.size()>0)
        {
            Map<String, id> mapNMCAccount = new Map<String, id>();
            for(NMC_Account__c NMCAccountRecord :lstNMCAccount)
            {
                if(NMCAccountRecord.NMC_Account__c != null)
                {
                    mapNMCAccount.put(NMCAccountRecord.NMC_Account__c + '_' + NMCAccountRecord.Hub_ID__c, NMCAccountRecord.id);//NMC_Account__c is no more an external id
                }                
            }
            if(mapNMCAccount.size() > 0)
            {
                for(Case caseRecord :lstnewCases)
                {
                    if(caseRecord.NMC_Account_Number__c != null && mapNMCAccount.containsKey(caseRecord.NMC_Account_Number__c + '_' + caseRecord.Hub_ID__c))
                    {
                        if(mapNMCAccount.get(caseRecord.NMC_Account_Number__c + '_' + caseRecord.Hub_ID__c) != caseRecord.NMC_Account__c)
                            caseRecord.NMC_Account_Number__c.addError(QESConstants.ERROR_NMC_ACCT_NUM_ALREADY_EXISTS);                          
                    }
                }
            }
        }
    }
    //logic was not written for bulk scenario
    /*Integer count =  [SELECT count() 
                      FROM NMC_Account__c 
                      WHERE NMC_Account__c = :caseRecord.NMC_Account_Number__c
                      AND Id != :caseRecord.NMC_Account__c]; //testing
    System.debug('CASE NMC Request validation - checking NMC Account Is Unique - found this many existing records:' + count + ' for NMC Account # ' + caseRecord.NMC_Account_Number__c);
    if(count != 0) {
      caseRecord.NMC_Account_Number__c.addError(QESConstants.ERROR_NMC_ACCT_NUM_ALREADY_EXISTS);
    }*/
  }


  // ******* Addl NMC Accout Uniqueness *******
  //ERROR if Add'l NMC Account Number already exists as an NMC Account
  public static void validateAddlNMCAccountIsUnique(List<Case> lstnewCases) {
    
    Set<String> setAddlNMCAccountNumber = new Set<String>();
    for(Case caseRecord :lstnewCases)
    {
        if(caseRecord.Addl_NMC_Account_Number__c != null)
        {
            setAddlNMCAccountNumber.add(caseRecord.Addl_NMC_Account_Number__c);
        }
    }
    if(setAddlNMCAccountNumber.size() > 0)
    {
        List<NMC_Account__c> lstNMCAccount = [SELECT id, Hub_ID__c, NMC_Account__c from NMC_Account__c where NMC_Account__c in :setAddlNMCAccountNumber];        

        if(lstNMCAccount != null && lstNMCAccount.size()>0)
        {
            Map<String, id> mapNMCAccount = new Map<String, id>();
            for(NMC_Account__c NMCAccountRecord :lstNMCAccount)
            {
                if(NMCAccountRecord.NMC_Account__c != null)
                {
                    mapNMCAccount.put(NMCAccountRecord.NMC_Account__c + '_' + NMCAccountRecord.Hub_ID__c, NMCAccountRecord.id);//NMC_Account__c is no more an external id
                }                
            }
            if(mapNMCAccount.size() > 0)
            {
                for(Case caseRecord :lstnewCases)
                {
                    if(caseRecord.Addl_NMC_Account_Number__c!= null && mapNMCAccount.containsKey(caseRecord.Addl_NMC_Account_Number__c + '_' + caseRecord.Hub_ID__c))
                    {
                        caseRecord.Addl_NMC_Account_Number__c.addError(QESConstants.ERROR_NMC_ACCT_NUM_ALREADY_EXISTS);                          
                    }
                }
            }
        }
    }
    //logic was not written for bulk scenario
    /*if(caseRecord.Addl_NMC_Account_Number__c == null){
      return;
    }
    
    Integer count = [SELECT count() 
                     FROM   NMC_Account__c 
                     WHERE  NMC_Account__c = :caseRecord.Addl_NMC_Account_Number__c]; 
    
    System.debug('CASE NMC Request validation - checking Addl NMC Account Is Unique - found this many existing records:' + count);
    if(count != 0) {
      caseRecord.Addl_NMC_Account_Number__c.addError(QESConstants.ERROR_NMC_ACCT_NUM_ALREADY_EXISTS);
    }*/
  }


  // ******* Validate Unit Types do not already Exist on New *******
  //ERROR if "Default NMC Account for Unit Type" or "Additional Default NMC Account for Unit Type"
  //      already exists on an NMC Account for this customer Account 
  public static void validateUnitTypesNotAlreadyExists(List<Case> lstnewCases, boolean isTransferAccount) 
  {
    Set<Id> setAccountIds = new Set<Id>();
    for(Case caseRecord :lstnewCases)
    {
        if(!isTransferAccount)
            setAccountIds.add(caseRecord.AccountId);
        else
            setAccountIds.add(caseRecord.Transfer_to_Account__c);  
    }
    
    if(setAccountIds.size() > 0)
    {
        List<NMC_Account__c> lstnmcAccount = [SELECT Account__c, Default_NMC_Account_for_Unit_Type__c FROM NMC_Account__c WHERE Account__c in :setAccountIds  AND 
                                              Default_NMC_Account_for_Unit_Type__c != null AND
                                              Default_NMC_Account_for_Unit_Type__c != :QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT];
                                              
        if(lstnmcAccount != null && lstnmcAccount.size() >0)
        {
            for(Case caseRecord :lstnewCases)
            {
                Map<String, String> unitTypesMap = new Map<String, String>();
                Map<String, String> addlUnitTypesMap = new Map<String, String>();
                
                //Gather Default_NMC_Account_for_Unit_Type__c values for this Case
                if(caseRecord.Default_NMC_Account_for_Unit_Type__c != null)
                {
                    String[] unitTypes = caseRecord.Default_NMC_Account_for_Unit_Type__c.split(';');
                    for(String nextUnitType: unitTypes)
                    {
                      unitTypesMap.put(nextUnitType, nextUnitType);
                    } 
                }
                
                //Gather Add'l Default_NMC_Account_for_Unit_Type__c values for this Case
                if(caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c != null) 
                {
                    String[] addlUnitTypes = caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c.split(';'); 
                    for(String nextUnitType: addlUnitTypes)
                    {
                        addlUnitTypesMap.put(nextUnitType, nextUnitType);
                    } 
                }
                
                for(NMC_Account__c nmcAccount :lstnmcAccount)
                {
                    boolean isAccountExist = false;
                    
                    if(!isTransferAccount)
                    {
                        if(nmcAccount.Account__c == caseRecord.AccountId && nmcAccount.id != caseRecord.NMC_Account__c)
                            isAccountExist = true;
                    }    
                    else
                    {
                        if(nmcAccount.Account__c == caseRecord.Transfer_to_Account__c && nmcAccount.id != caseRecord.NMC_Account__c)
                            isAccountExist = true;
                    }
                    
                    if(isAccountExist)
                    {       
                        String[] nmcUnits = nmcAccount.Default_NMC_Account_for_Unit_Type__c.split(';');
                        system.debug('nmcUnits'+nmcUnits);
                        for(Integer i = 0; i < nmcUnits.size(); i++)
                        {
                            if(unitTypesMap.containsKey(nmcUnits[i])) 
                                caseRecord.Default_NMC_Account_for_Unit_Type__c.addError(QESConstants.ERROR_UNIT_TYPE_ALREADY_EXISTS + nmcUnits[i]); 
        
                            if(addlUnitTypesMap.containsKey(nmcUnits[i]))
                                caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c.addError(QESConstants.ERROR_UNIT_TYPE_ALREADY_EXISTS + nmcUnits[i]);
                        }
                    }
                } 
            }
        }                                         
    }
    
    //logic was not written for bulk scenario
    /*Map<String, String> unitTypesMap = new Map<String, String>();
    Map<String, String> addlUnitTypesMap = new Map<String, String>();

    //Gather Default_NMC_Account_for_Unit_Type__c values for this Case
    if(caseRecord.Default_NMC_Account_for_Unit_Type__c != null){
        String[] unitTypes = caseRecord.Default_NMC_Account_for_Unit_Type__c.split(';');
        for (String nextUnitType: unitTypes){
          unitTypesMap.put(nextUnitType, nextUnitType);
        } 
    }

    //Gather Add'l Default_NMC_Account_for_Unit_Type__c values for this Case
    if(caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c != null) {   //check Add'l default nmc account for unit type as well if it exists
        String[] addlUnitTypes = caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c.split(';'); 
        for (String nextUnitType: addlUnitTypes){
          addlUnitTypesMap.put(nextUnitType, nextUnitType);
        } 
    }
     
    List<NMC_Account__c> lstnmcAccount = new List<NMC_Account__c>();

    lstnmcAccount = [SELECT Default_NMC_Account_for_Unit_Type__c FROM NMC_Account__c WHERE Account__c = :acctIdToCheck  AND 
                     Id != :caseRecord.NMC_Account__c AND Default_NMC_Account_for_Unit_Type__c != null AND
                     Default_NMC_Account_for_Unit_Type__c != :QESConstants.NOT_A_DEFAULT_NMC_ACCOUNT];
                  
    if(lstnmcAccount.IsEmpty()){ return; }

    //Loop through existing NMC Accounts and check for duplicates
    for(NMC_Account__c nmcAccount :lstnmcAccount) 
    { 
        String[] nmcUnits = nmcAccount.Default_NMC_Account_for_Unit_Type__c.split(';');
        for(Integer i = 0; i < nmcUnits.size(); i++) 
        {
           if(unitTypesMap.containsKey(nmcUnits[i])) 
               caseRecord.Default_NMC_Account_for_Unit_Type__c.addError(QESConstants.ERROR_UNIT_TYPE_ALREADY_EXISTS + nmcUnits[i]); 

           if(addlUnitTypesMap.containsKey(nmcUnits[i]))
               caseRecord.Addl_Default_NMC_Account_for_Unit_Type__c.addError(QESConstants.ERROR_UNIT_TYPE_ALREADY_EXISTS + nmcUnits[i]); 
        }    
    }*/
  }//end validateUnitTypesNotAlreadyExists() method
 
 //Validate that the Default NMC Account field is not null.  This must be selected when case status is Closed/Completed.  KD 7-14-08 
   // commented by Arindam Laik, Code is replaced by 'Default_NMC_Account_should_Not_Blank' validation rule
   /*public static boolean validateDefaultNMCAcccountSelected(Case caseRecord) {
    if(caseRecord.Default_NMC_Account_for_Unit_Type__c==null){ 
        caseRecord.Default_NMC_Account_for_Unit_Type__c.addError(QESConstants.ERROR_YOU_MUST_ENTER_A_VALUE);
      return false;
    } 
    return true;
  }*/
 
}