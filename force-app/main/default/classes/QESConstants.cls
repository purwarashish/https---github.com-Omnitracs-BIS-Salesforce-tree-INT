//This class is intended to be the central repository for ALL hardcoded values that 
//are needed within Apex Code.  Examples:
//   * picklist values 
//   * record type names or ids 
public class QESConstants {

  //=============================================================   
  //========= Generic Constants =================================   
  //=============================================================   
  public static String ACTIVE = 'Active';
  public static String INACTIVE = 'Inactive';
  public static boolean inFutureContext = false;
    
  //=============================================================   
  //========= AGREEMENT =========================================   
  //=============================================================   
  public static String AGREEMENT_STATUS_DRAFT = 'Draft';
  public static String AGREEMENT_STATUS_SIGNED = 'Signed';  

  //=============================================================   
  //========= CASE ==============================================   
  //=============================================================   
  //Case Record Types for NMC Requests  //TS 3-20-08 ADD
  public static String REC_TYPE_CASE_NMC_ACCT_REQ = 'NMC Account Request';
  public static String REC_TYPE_CASE_NMC_ACCT_REQ_SUBMITTED = 'Submitted NMC Account Request';
  public static String REC_TYPE_CASE_NMC_ACCT_REQ_CLOSED = 'Closed NMC Account Request';
  
  //Case Record Types for EOX Return Requests  //KD 6-19-09 ADD
  public static String REC_TYPE_CASE_EOX_REQ = 'EOX Return';
  
  //Case Record Type for Call Center Requests //CR# 21051
  public static String REC_TYPE_CASE_CALL_CENTER = 'Call Center'; 
  public static String REC_TYPE_CASE_EMAIL_GENERATED = 'Email Generated Cases';
  
  
  //Case picklists    
  public static String CASE_STATUS_CLOSED = 'Closed';
  public static String CASE_SUBSTATUS_RESOLVED = 'Resolved';
  public static String CASE_SUBSTATUS_COMPLETED = 'Completed';
  public static String CASE_CATEGORY_NMC_REQ = 'NMC Account Request';
  public static String CASE_TYPE_LEVEL2_NEW_NMC_ACCOUNT = 'New NMC Account';
  public static String CASE_TYPE_LEVEL2_UPDATE_NMC_ACCOUNT = 'Update NMC Account';
  public static String CASE_TYPE_LEVEL2_TRANSFER_NMC_ACCOUNT = 'Transfer NMC Account';
  public static String CASE_CASE_ORIGIN = 'Email-iQ OV Requests';//Added for CR# 21051

  //==============================================================   
  //========= LEADERSHIP REPORT ==================================   
  //==============================================================
  public static string SALESROLE1 = 'TL Eastern Sales Account Mgr'; // CONSTANT for Sales Roles
  public static string SALESROLE2 = 'TL Western Sales Account Mgr'; // CONSTANT for Sales Roles
  public static string SALESROLE3 = 'TL Strategic Sales 1'; // CONSTANT for Sales Roles
  public static string SALESROLE4 = 'TL Strategic Sales 2'; // CONSTANT for Sales Roles

  //=============================================================   
  //========= CONTRACT REQUEST ==================================   
  //=============================================================   
  //public static String CONTRACT_REQ_TYPE_NEW_SALES_CONTRACT = 'New Sales Contract';
  public static String CONTRACT_REQ_TYPE_NEW_SALES_CONTRACT = 'Master Contract and Schedule'; //replaced value in picklist 
  public static String CONTRACT_REQ_TYPE_OTHER = 'Other';  //adding request type KD 5/21/09
  public static String CONTRACT_REQ_STATUS_SUBMITTED = 'Submitted';
  public static String CONTRACT_REQ_STATUS_ASSIGNED = 'Assigned';
  public static String CONTRACT_REQ_STATUS_SIGNED_BY_QUALCOMM = 'Signed by Qualcomm';
  //public static String CONTRACT_REQ_STATUS_SIGNED_BY_QUALCOMM = 'Signed (was Signed by Qualcomm)';
  public static String CONTRACT_REQ_STATUS_CANCELLED = 'Cancelled';

  //=============================================================   
  //========= NEW CUSTOMER IMPLEMENTATION =======================   
  //=============================================================   
  //New Customer Implementation Picklist - Current Stage
  public static String CUST_PROVISIONING_STAGE_CONTRACT_REQUESTED = '1-Contract Requested';
  public static String CUST_PROVISIONING_STAGE_CONTRACT_EXECUTED = '2-Contract Fully Executed';
  public static String CUST_PROVISIONING_STAGE_CUSTOMER_FULLY_SETUP = '3-Customer Fully Setup and Ready for Orders';
  public static String CUST_PROVISIONING_STAGE_ORDER_PLACED = '4-Order Placed';
  public static String CUST_PROVISIONING_STAGE_FIRST_SHIPMENT = '5-First Shipment Complete';
  public static String CUST_PROVISIONING_STAGE_FIRST_MSG = '6-First Message Received';
  

  //=============================================================   
  //========= NMC REQUEST =======================================   
  //=============================================================   
  //NMC Request Validation Error Messages
  public static String ERROR_NOT_INTERNAL_ACCT = 'Cannot submit Internal NMC Request for Account not marked as Internal';
  public static String ERROR_NO_CUST_ID = 'Please choose an Account with Cust ID populated.';
  public static String ERROR_NO_CUST_ID_IN_TRANSFER_TO_ACCT = 'Please choose a Transfer To account with a Cust ID populated.';
  public static String ERROR_INVALID_ACCT_NMC_ACCT_COMBO = 'The combination of Account and NMC Account Number does not exist.  Please select an NMC account that belongs to the Account.';
  public static String ERROR_INACTIVE_CANNOT_SPECIFY_DEFAULT_NMC_ACCT_FOR_UNIT_TYPE = 'You cannot specify a "Default NMC Account for Unit Type" if the NMC Account Status or Requested NMC Account Status is set to "Inactive"';
  public static String ERROR_INACTIVE_CANNOT_SPECIFY_DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_ADDL = 'You cannot specify an "Addl Default NMC Account for Unit Type" if the Addl NMC Account Status is set to "Inactive"';
  public static String ERROR_YOU_MUST_ENTER_A_VALUE = 'You must enter a value';
  public static String ERROR_CANNOT_SELECT_UNIT_TYPES_FOR_NON_DEFAULT_NMC_ACCT = 'You cannot select any Unit Types when selecting "Not a Default NMC Account"';
  public static String ERROR_NMC_ACCT_NUM_ALREADY_EXISTS = 'NMC Account Number already exists. Please choose a unique number.';
  public static String ERROR_NMC_ACCT_NUM_AND_ADDL_NMC_NUM_CANNOT_BE_SAME = 'The NMC Account Number and the Additional NMC Account Number cannot be the same.';
  public static String ERROR_UNIT_TYPE_ALREADY_EXISTS = 'Default NMC Account for Unit Type already exists for this customer.  Invalid Unit Type = '; 
  public static String ERROR_UNIT_TYPE_ALREADY_SELECTED_PREFIX = 'The Unit Type has already been selected.  Invalid Unit Type =  ';
  public static String ERROR_ALL_UNIT_TYPES_MUST_BE_SELECTED_ON_FIRST_NMC_ACCOUNT = 'All Unit Types must be selected as defaults since this is the 1st NMC Account';

  //NMC Request Picklist values - Unit Types
  public static String NOT_A_DEFAULT_NMC_ACCOUNT = 'Not a Default NMC Account';
  public static String DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_GLOBALTRACS = 'GlobalTRACS';
  public static String DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_OMNIEXPRESS = 'OmniExpress';
  public static String DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_OMNIEXPRESS2 = 'OmniExpress2';
  public static String DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_OMNITRACS = 'OmniTRACS';
  //public static String DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_OMNIVISION = 'OmniVision';   KD 1/15/08
  //public static String DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_OMNIVISIONTERRESTRIAL = 'OmniVision Terrestrial'; KD 1/15/08
  public static String DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_TRAILERTRACS = 'TrailerTRACS';
  public static String DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP100 = 'MCP100S';   // KD 1/15/08
  public static String DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP200 = 'MCP200';   // KD 1/15/08
  public static String DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP100TERRESTRIAL = 'MCP100T';   //  KD 1/15/08
  public static String DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP110 = 'MCP110';   // KD 3/31/10
  public static String DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP50 = 'MCP50';   // KD 8/15/11
  public static String DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_TT210 = 'TT210';   // KD 9/16/10
    
  //Return true if all of the Unit Types are selected, false if any 1 is missing
  public static boolean allUnitTypesSelected(String unitTypes){
      System.debug('DEBUG: Verify that all unit types are present in this value: ' + unitTypes);
      
      if(unitTypes == null) { return false; }
      if(!unitTypes.contains(QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_GLOBALTRACS)) { return false; }
      if(!unitTypes.contains(QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_OMNIEXPRESS)) { return false; }
      if(!unitTypes.contains(QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_OMNIEXPRESS2)) { return false; }
      if(!unitTypes.contains(QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_OMNITRACS)) { return false; }
      //if(!unitTypes.contains(QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_OMNIVISION)) { return false; }    KD 1/15/08
      //if(!unitTypes.contains(QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_OMNIVISIONTERRESTRIAL)) { return false; }    KD 1/15/08
      if(!unitTypes.contains(QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP100)) { return false; }    //KD 1/15/08
      if(!unitTypes.contains(QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP200)) { return false; }    //KD 1/15/08
      if(!unitTypes.contains(QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP110)) { return false; }    //KD 3/31/10
      if(!unitTypes.contains(QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP50)) { return false; }    //KD 8/15/11
      if(!unitTypes.contains(QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_TT210)) { return false; }    //KD 9/16/10
      if(!unitTypes.contains(QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_MCP100TERRESTRIAL)) { return false; }  //KD 1/15/08
      if(!unitTypes.contains(QESConstants.DEFAULT_NMC_ACCT_FOR_UNIT_TYPE_TRAILERTRACS)) { return false; }
      
      return true;
  
  }
  //These NMC_Request record types and picklist values should be obsolete since we're using Cases.  T.Scott 4/2/08
  //NMC Request Record Types  
  public static String REC_TYPE_CREATE_NMC_FOR_NMC_USE_ONLY = 'Create NMC Account - NMC Use Only';
  public static String REC_TYPE_NEW_CUSTOMER_NMC = 'New Customer NMC Account';
  public static String REC_TYPE_NEW_INTERNAL_NMC = 'New Internal NMC Account';
  public static String REC_TYPE_UPDATE_NMC_FOR_NMC_ONLY = 'Update NMC Account - NMC Use Only';
  public static String REC_TYPE_UPDATE_NMC = 'Update NMC Account';
  public static String REC_TYPE_TRANSFER_NMC_FOR_NMC_ONLY = 'Transfer NMC Account - NMC Use Only';
  public static String REC_TYPE_TRANSFER_NMC = 'Transfer NMC Account';
  public static String REC_TYPE_INTERNAL_NOT_COMPLETED = 'Internal Not Completed';  
  public static String REC_TYPE_NMC_SETUP_NOT_COMPLETED = 'NMC Setup Not Completed';
  public static String REC_TYPE_TRANSFER_NOT_COMPLETED = 'Transfer Not Completed';
  public static String REC_TYPE_UPDATE_NOT_COMPLETED = 'Update Not Completed';
  public static String REC_TYPE_NMC_REQUEST_CLOSED = 'NMC Request Closed';      //KD 3-13-08 ADD

  //NMC Request Picklist values - Sub Status
  public static String SUBSTATUS_CANCELLED = 'Cancelled';
  public static String SUBSTATUS_OPEN = 'Open';                                     //KD 3-13-08 ADD
  public static String SUBSTATUS_PENDING_NMC_SETUP = 'Pending NMC Setup';           //KD 3-13-08 ADD
  public static String SUBSTATUS_COMPLETED = 'Completed';                           //KD 3-13-08 ADD
  
  //Constant usedin 'UpdateAccountinSU' and 'SerializedUnitUpdate' triggers
  public static Boolean CALLED_FROM_NMC = false;
  public static Integer SERIALIZEDUNIT_SIZE = 0;
     
}