/***********************************************************************************
Author: Amrita Ganguly, Salesforce.com Developer
Tata Consultancy Services Limited
Description : This class is called from AccountAll trigger.
***********************************************************************************/
global class AccountUtils
{
   /* 
    
    Static String ALL_DATA_CAPTURED_VALUE = 'All Account Details Captured';
    
    private static boolean isAccountTriggerExecuted = false;
    
    public static void AccountTriggerExecuted()
    {
        isAccountTriggerExecuted = true;
    } 
    public static boolean HasAccountTriggerExecuted()
    {
        return isAccountTriggerExecuted;
    } 
    

    public static string TL_SALES_ACCOUNT_RECORD_TYPE_ID = '01250000000DQBAAA4';
    public static String CNR_SALES_ACCOUNT_RECORD_TYPE_ID = '01250000000DVm9AAG';
    public static String GSS_ACCOUNT_RECORD_TYPE_ID = '01250000000DVwYAAW';
    public static String PARTNER_ACCOUNT_RESELLER_RECORD_TYPE_ID = '01250000000QjAKAA0';
    public static String OTHER_ACCOUNT_RECORD_TYPE_ID = '01250000000DTCpAAO';
    
 
    public static String CLSD_RSN_OUT_OF_BUS = 'Out of Business';    
    public static String CLSD_RSN_NON_PAY = 'Non-Payment';
    
    static string EVAL_CUSTOMERS = 'New Eval Customer';
    
    static string CONTRACT_CUSTOMER = 'Contract Customer'; 
    
    static string BILLING_ADDRESS = 'Billing Address';
    
    static string PHONE = 'Phone';
    
    static string ACCOUNT_TYPE = 'Account Type';

    static string MARKET = 'Market';
    
    static string DISTRICT = 'District';

    static string STATUS = 'Status';
    


    static string LEAD_SOURCE = 'Lead Source';

    static string AVG_LEN_HAUL = 'Average Length of Haul';

    static string REG_VEHICLES = 'Regional Vehicles';
    
    static string OTR_VEHICLES = 'OTR Vehicles';

    static string PRIMARY_BUSINESS = 'Primary Business';

    static string PRIMARY_COMMODITY = 'Primary Commodity';

    static string CONTACT_COMMENT = 'Contract Comments';

    static string CONTRACT_EXPIRATION = 'Contract Expiration';

    static string COMP_PLATFORM = 'Computer Platform';

    static string RANKING = 'Ranking';

    static string LOCATION = '# of Locations';

    static string ACCT_MANAGER = 'Account Manager';

    static string BILLING_CITY = 'Billing City';
    
    static string BILLING_COUNTRY = 'Billing Country';

    static string BILLING_STATE = 'Billing State/Province';

    static string BILLING_STR = 'Billing Street';

    static string  BILLING_POSTAL_CODE = 'Billing Zip/Postal Code';

    static string CUST_ID = 'Cust ID';

    static string CUST_SERVICE_REP = 'Customer Service Rep';
    
    static string DOLLIES = 'Dollies';

    static string DRY_VANS = 'Dry Vans';
    
    static string FAX = 'Fax';

    static string FISCAL_YR_END = 'Fiscal Year End';

    static string FLATBEDS = 'Flatbeds';

    static string OBC = 'OBC';

    static string REEFER_TRAILER = 'OEM Reefer Trailer';

    static string OEM_TRACTOR = 'OEM Tractor';

    static string DEALER = 'Dealer';

    static string ENABLED_DEVICE = 'Number of Enabled Devices';

    static string REEFERS = 'Reefers';

    static string RFC_ID = 'RFC ID';

    static string SENSOR = 'Sensors';

    static string FEATURE_INTEREST = 'Feature Interest';

    static string PDT_INTEREST = 'Product Interest';
    
    static string SERVICE_MODEL = 'Service Model';
    
    static string ASSET_VAL_RANGE = 'Asset Value Range';
    
    static string DEVICE_SUPP = 'Device Supplier';
    
    static string ACCOUNT_NAME = 'Account Name';
    
    static string TANKERS = 'Tankers';
    
    static string TRAILERTRACS = 'TrailerTRACS';
    
    static string SHIPPING_CITY = 'Shipping City';
    
    static string SHIPPING_COUNTRY = 'Shipping Country';
    
    static string SHIPPING_PROV = 'Shipping State/Province';
    
    static string SHIPPING_STR = 'Shipping Street';
    
    static string SHIPPING_POSTAL_CODE = 'Shipping Zip/Postal Code';
    
    static list<Profile> lstProfile = new list<profile>();
    
    static list<UserLicense> lstUsrLicense = new list<UserLicense>();
    
    static boolean isExecute = true;
    
    static boolean isExecuteSetReseller = true; 
    
    static boolean isExecuteAcctAll = true; 
    
    static string email = 'kdinen@qualcomm.com';
        
    public static boolean isExecuted = false; 
    
    private static Boolean acctUpdateTerritoriesExecutedOnce = false;
    
    //TODO : Uncomment the password for prod before deployment
    private static String unityCredentials = system.label.UnamePwdLinkWebservice;//'sf-prod@service.qes.qualcomm.com:saleSm3ggs';
    //private static String unityCredentials  = 'sf-non-prod@service.qes.qualcomm.com:saleSm3ggs';
    
    // added to ensure that when ever owner is changed , Partner agent is same as the owner
    public static boolean hasUpdtedPartnerAgent = false;
    
    //  this method sets the account.ranking_cargo_type__c field, all of the account.ranking**** fields are set by field updates
    //  but this requires tirgger logic to set  by joseph hutchins 7/16/2015
    public static void assignRankingCargoType(List<Account> accounts)
    {
        //  cargo type is a multi select picklist meaning it can contain no or all values
        //  we need to split out the cargo type selections that are selected, compare them to either hardcoded
        //  or custom setting listing and pick out the cargo type with the highest value
        for (Account a : accounts)
        {
            List<string> cargoTypesSplitOut = Util.parseString(a.Cargo_Type__c);
            if (cargoTypesSplitOUt != null && cargoTypesSplitOut.size() > 0)
            {
                //  assume the first cargo type has highest value, and compare to the others int he list
                string highestValueCargoType = cargoTypesSplitOut[0];
                
                //  if other has highest value, assign that as highest value
                for (integer i = 0; i < cargoTypesSplitOut.size(); i++)
                {
                    if (getRankingValue(cargoTypesSplitOut[i]) > getRankingValue(highestValueCargoType))
                    {
                        highestValueCargoType = cargoTypesSplitOut[i];
                    }
                }
                if (!util.isblank(highestValueCargoType))
                {
                    a.Ranking_Cargo_Type__c = getRankingVAlue(highestValueCargoType);
                }
                else
                {
                    a.Ranking_Cargo_Type__c = 0;//  by default it is 0
                }
            }
            else
            {
                a.Ranking_Cargo_Type__c = 0;//  by default it is 0
            }
        }
    }
    
    private static decimal getRankingVAlue(string cargoTypePicklistVAlue)
    {

        
        //  shannons spreadsheeet has all cargot ypes in captial so lets just make this change to the string to get exact matching
        cargoTypePIcklistValue = cargoTypePicklistValue.toUpperCase();
    
        //  hate to hardcode this but i have to make this into the july release and it takes less time doing this 
        //  like this then via custom settting
        if (cargoTypePicklistValue == 'BEVERAGES' || cargoTypePicklistValue == 'PAPERPROD' || cargoTypePicklistValue == 'COLDFOOD' || cargoTypePicklistValue == 'GENFREIGHT')
        {
            return 1.0;
        }
        if (cargoTypePicklistValue == 'PRODUCE'  || cargoTypePicklistValue == 'MEAT' || cargoTypePicklistValue == 'CHEM' || cargoTypePicklistValue == 'DRYBULK'
         || cargoTypePicklistValue == 'LIQGAS'  || cargoTypePicklistValue == 'BLDGMAT'  || cargoTypePicklistValue == 'GARBAGE' )
        {
            return 0.5;
        }
        if (cargoTypePicklistValue == 'HOUSEHOLD' || cargoTypePicklistValue == 'METALSHEET' || cargoTypePicklistValue == 'MACHLRG' || cargoTypePicklistValue == 'PASSENGERS'
           || cargoTypePicklistValue == 'GRAINFEED' || cargoTypePicklistValue == 'INTERMODAL' || cargoTypePicklistValue == 'LIVESTOCK' || cargoTypePicklistValue == 'MOTORVEH')
        {
            return 0.1;
        }
        
        //  rest of the values return 0
        return 0.0;
    } 
    /*******************************************************
    /**@Description:This method calculates the DataQualityScore 
     * Updates the Data_Quality_Description_Apex__c field on account 
    *
    
    public static void calDataQualScr(List<Account> lstAccount)    
    {    
        Integer totalFieldCount = 0;    
        Integer calculatedScore = 0;
        
        for(Account act :lstAccount )
        {
             Map<string,string> labels = new Map<string,string>();
             Integer nonNullFieldCount = 0;
             List<string> scoreFieldDescList = new List<string>();
             totalFieldCount = 0;
             //--CHECK IF RELEVANT FIELDS FOR T & L HAS VALUE-------------/
             if(act.RecordTypeId == TL_SALES_ACCOUNT_RECORD_TYPE_ID && 
                             (act.QWBS_Status__c == EVAL_CUSTOMERS 
                             || act.QWBS_Status__c == CONTRACT_CUSTOMER ))
             {             
                 labels.put(BILLING_ADDRESS,act.BillingStreet);
                 labels.put(PHONE,act.Phone);
                 labels.put(ACCOUNT_TYPE,act.Account_Type__c);
                 labels.put(MARKET,act.QWBS_Market__c);
                 labels.put(DISTRICT,act.District__c);
                 labels.put(STATUS,act.QWBS_Status__c);
                 labels.put(LEAD_SOURCE,act.Lead_Source__c);
                 labels.put(AVG_LEN_HAUL,act.Average_Length_of_Haul__c);
                 labels.put('Regional Vehicles',String.valueOf(act.Regional_Vehicles__c));
                 labels.put(OTR_VEHICLES,String.valueOf(act.OTR_Vehicles__c));
                 labels.put(PRIMARY_BUSINESS,act.Primary_Business__c);
                 labels.put(PRIMARY_COMMODITY,act.Primary_Commodity__c);
                 labels.put(CONTACT_COMMENT,act.Contract_Comments__c);
                 labels.put(CONTRACT_EXPIRATION,String.valueOf(act.Contract_Expiration__c));
                 labels.put(COMP_PLATFORM,act.Computer_Platform__c);
                 labels.put(RANKING,act.Ranking__c);
                 totalFieldCount = labels.size();
                 System.debug('%%%%%%%%%%%%%...' + totalFieldCount);             
            }
            else if(act.RecordTypeId == TL_SALES_ACCOUNT_RECORD_TYPE_ID
                        && act.QWBS_Status__c != EVAL_CUSTOMERS 
                        && act.QWBS_Status__c != CONTRACT_CUSTOMER )
             {
              //  =================================================================================
              //  ===== T&L District Sales - NOT Eval and NOT Contract Customer ===================
              //  =================================================================================
              //--CHECK IF RELEVANT FIELDS FOR T & L HAS VALUE-------------/
                 
                 labels.put(BILLING_ADDRESS,act.BillingStreet);
                 labels.put(PHONE,act.Phone);
                 labels.put(ACCOUNT_TYPE,act.Account_Type__c);
                 labels.put(MARKET,act.QWBS_Market__c);
                 labels.put(DISTRICT,act.District__c);
                 labels.put(STATUS,act.QWBS_Status__c);
                 labels.put(LEAD_SOURCE,act.Lead_Source__c);
                 labels.put(AVG_LEN_HAUL,act.Average_Length_of_Haul__c);
                 labels.put('Regional Vehicles',String.valueOf(act.Regional_Vehicles__c));
                 labels.put(OTR_VEHICLES,String.valueOf(act.OTR_Vehicles__c));
                 labels.put(PRIMARY_BUSINESS,act.Primary_Business__c);
                 labels.put(PRIMARY_COMMODITY,act.Primary_Commodity__c);
                 totalFieldCount = labels.size();
            }
            else if(act.RecordTypeId == CNR_SALES_ACCOUNT_RECORD_TYPE_ID
                        &&  act.QWBS_Market__c =='Mexico Sales')
                {
               System.debug('@@@@.. Found my match!!!!');  
              //  =================================================================================
              //  =====CNR Sales ==================
              //  =================================================================================
              //--CHECK IF RELEVANT FIELDS FOR T & L HAS VALUE-------------/
              
              labels.put(LOCATION,String.valueOf(act.of_Locations__c));
              labels.put(ACCT_MANAGER,act.Account_Manager__c);
              labels.put(ACCOUNT_TYPE,act.Account_Type__c);
              labels.put(BILLING_CITY,act.BillingCity);
              labels.put(BILLING_COUNTRY,act.BillingCountry);
              labels.put(BILLING_STATE,act.BillingState);
              labels.put(BILLING_STR,act.BillingStreet);
              labels.put(BILLING_POSTAL_CODE,act.BillingPostalCode);
              labels.put(COMP_PLATFORM,act.Computer_Platform__c);
              labels.put(CUST_ID,act.QWBS_Cust_ID__c);
              labels.put(CUST_SERVICE_REP,act.CSR__c);
              labels.put(DISTRICT,act.District__c);
              labels.put(DOLLIES,String.valueOf(act.Dollies__c));
              labels.put(DRY_VANS,String.valueOf(act.Dry_Vans__c));
              labels.put(FAX,act.Fax);
              labels.put(FLATBEDS,String.valueOf(act.Flatbeds__c));
              labels.put(LEAD_SOURCE,act.Lead_Source__c);
              labels.put(MARKET ,act.QWBS_Market__c);
              labels.put(OBC,String.valueOf(act.OBC__c));
              labels.put(OEM_TRACTOR,act.OEM_Tractor__c);
              labels.put(REEFER_TRAILER,act.OEM_Reefer_Trailer__c);
              labels.put(OTR_VEHICLES,String.valueOf(act.OTR_Vehicles__c));
              labels.put(FLATBEDS,String.valueOf(act.Flatbeds__c));
              labels.put(LEAD_SOURCE,act.Lead_Source__c);
              labels.put(PHONE ,act.Phone);
              labels.put(PRIMARY_BUSINESS,act.Primary_Business__c);
              labels.put(PRIMARY_COMMODITY,act.Primary_Commodity__c);
              labels.put(RANKING,act.Ranking__c);
              labels.put(REEFERS,String.valueOf(act.Reefers__c));
              labels.put(REG_VEHICLES,String.valueOf(act.Regional_Vehicles__c));
              labels.put(RFC_ID,act.RFC_ID__c);
              labels.put(SHIPPING_CITY,act.ShippingCity);
              labels.put(SHIPPING_COUNTRY,act.ShippingCountry);
              labels.put(SHIPPING_PROV,act.ShippingState);
              labels.put(SHIPPING_STR,act.ShippingStreet);
              labels.put(SHIPPING_POSTAL_CODE,act.ShippingPostalCode);
              labels.put(STATUS,act.QWBS_Status__c);
              labels.put(TANKERS,String.valueOf(act.Tankers__c));
              labels.put(TRAILERTRACS,String.valueOf(act.TrailerTRACS__c));
              totalFieldCount = labels.size();
            //  system.debug('labels'+labels.size());
            }
            if(labels.size()>0){
                nonNullFieldCount = 0;
                scoreFieldDescList = new List<string>();
                for(string key:labels.keyset())
                {
                    if(labels.get(key) == null || labels.get(key) =='')
                    {
                        
                        scoreFieldDescList.add(key);   
                    }
                    else
                        nonNullFieldCount++;
                }
                system.debug('nonNullFieldCount'+nonNullFieldCount); 
                system.debug('scoreFieldDescList'+scoreFieldDescList);           
                //--- Assign Score/Description Values in Account object -------------
               
                if(totalFieldCount>0)    
                    calculatedScore = CalculateDataQualityScore.determineDataQualityScore(totalFieldCount,nonNullFieldCount);
                act.Data_Quality_Score_Apex__c = calculatedScore;
                //--- Populate the Data Quality Description showing missing field values if the score is NOT 100 -----------
                if(calculatedScore != 100)
                {
                    act.Data_Quality_Description_Apex__c = CalculateDataQualityScore.generateScoreDescription(scoreFieldDescList);
                }
                else
                {
                    act.Data_Quality_Description_Apex__c = ALL_DATA_CAPTURED_VALUE;
                }
            }        
            if(act.District__c !=null)
            {             
              if(act.RecordTypeId == GSS_ACCOUNT_RECORD_TYPE_ID 
                  &&  (act.District__c.contains('ORMM')))
              {
              //  =================================================================================
              //  ================= Construction Equipment ========================================
              //  =================================================================================
              //--CHECK IF RELEVANT FIELDS FOR T & L HAS VALUE-------------/
              system.debug('inside else if 3.1');
              labels.clear();
              system.debug('@After clear labels:'+labels.size());
              nonNullFieldCount = 0;
              scoreFieldDescList = new List<string>();
              
              labels.put(ACCOUNT_NAME,act.Name);
              labels.put(ACCOUNT_TYPE,act.Account_Type__c);
              labels.put(FAX,act.Fax);
              labels.put(RANKING,act.Ranking__c);
              labels.put(DEALER,String.valueOf(act.Dealer__c));
              labels.put(PDT_INTEREST,act.Product_Interest__c);
              labels.put(FEATURE_INTEREST,act.Feature_Interest__c);
              labels.put(PHONE,act.Phone);
              labels.put(ACCOUNT_TYPE,act.Account_Type__c);
              labels.put(BILLING_STR,act.BillingStreet);
              totalFieldCount = labels.size();
              
            }
            else if(act.RecordTypeId == GSS_ACCOUNT_RECORD_TYPE_ID 
                    && (!(act.District__c.contains('ORMM')))){
              //  =================================================================================
              //  ================= Construction Equipment ========================================
              //  =================================================================================
              //--CHECK IF RELEVANT FIELDS FOR T & L HAS VALUE-------------/
              system.debug('inside else if 4');
              labels.clear();
              system.debug('@After clear labels:'+labels.size());
              nonNullFieldCount = 0;
              scoreFieldDescList = new List<string>();
    
              labels.put(ACCOUNT_NAME,act.Name);
              labels.put(ACCOUNT_TYPE,act.Account_Type__c);
              labels.put(FAX,act.Fax);
              labels.put(RANKING,act.Ranking__c);
              labels.put(DEVICE_SUPP,act.Device_Supplier__c);
              labels.put(ASSET_VAL_RANGE,act.Asset_Value_Range__c);
              labels.put(SERVICE_MODEL,act.Service_Model__c);
              labels.put(ENABLED_DEVICE,String.valueOf(act.Number_of_Enabled_Devices__c));
              labels.put(PDT_INTEREST,act.Product_Interest__c);
              labels.put(FEATURE_INTEREST,act.Feature_Interest__c);
              labels.put(ACCOUNT_TYPE,act.Account_Type__c);
              labels.put(BILLING_STR,act.BillingStreet);
              labels.put(PHONE,act.Phone);        
              totalFieldCount = labels.size();
              system.debug('totalFieldCount'+totalFieldCount);
            } 
            if(labels.size()>0){
                nonNullFieldCount = 0;
                scoreFieldDescList = new List<string>();
                for(string key:labels.keyset())
                {
                    if(labels.get(key) == null || labels.get(key) =='')
                    {
                        
                        scoreFieldDescList.add(key);   
                    }
                    else
                        nonNullFieldCount++;
                }
                system.debug('nonNullFieldCount'+nonNullFieldCount); 
                system.debug('scoreFieldDescList'+scoreFieldDescList);           
                //--- Assign Score/Description Values in Account object -------------
               
                if(totalFieldCount>0)    
                    calculatedScore = CalculateDataQualityScore.determineDataQualityScore(totalFieldCount,nonNullFieldCount);
                act.Data_Quality_Score_Apex__c = calculatedScore;
                //--- Populate the Data Quality Description showing missing field values if the score is NOT 100 -----------
                if(calculatedScore != 100)
                {
                    act.Data_Quality_Description_Apex__c = CalculateDataQualityScore.generateScoreDescription(scoreFieldDescList);
                }
                else
                {
                    act.Data_Quality_Description_Apex__c = ALL_DATA_CAPTURED_VALUE;
                }
            }
         } 
    
      }
    }
    
    
    /**@Description:This method creates a record of team member object  
      *    for Account inserted or updated
      *
    *    
    public static void acctUpdateAcctTerritories(list<Account> oldlstAccount,list<Account> newLstAccount,boolean isUpdateVal)
    {
        String UserName = userInfo.getUserName();
        list<Account> lstAccount = new list<Account>();
        if(null == oldlstAccount || oldlstAccount.isEmpty()) {
            // Insert scenario
            for(Integer i=0; i<newlstAccount.size(); i++) {
                lstAccount.add(newLstAccount[i]);
            }
        }
        else {
            // Not an insert scenario
            if(isUpdateVal)
            {
                for(Integer i=0;i<oldlstAccount.size();i++)
                {
                    if((oldlstAccount[i].OwnerId != newLstAccount[i].OwnerId) 
                       || (oldlstAccount[i].Account_Manager__c != newLstAccount[i].Account_Manager__c) 
                       || (oldlstAccount[i].CSR__c != newLstAccount[i].CSR__c) 
                       || (oldlstAccount[i].Professional_Services_Rep__c != newLstAccount[i].Professional_Services_Rep__c) 
                       || (oldlstAccount[i].Software_Application_Eng__c != newLstAccount[i].Software_Application_Eng__c) 
                       || (oldlstAccount[i].Contracts_Administrator__c != newLstAccount[i].Contracts_Administrator__c) 
                       || (oldlstAccount[i].Inside_Sales_Rep__c != newLstAccount[i].Inside_Sales_Rep__c) 
                       || (oldlstAccount[i].AR_Representative__c != newLstAccount[i].AR_Representative__c) 
                       || (oldlstAccount[i].Partner_Agent__c != newLstAccount[i].Partner_Agent__c)
                       || (oldlstAccount[i].Inside_CSR__c != newLstAccount[i].Inside_CSR__c)
                       || (oldlstAccount[i].FRA_Account_Manager__c != newLstAccount[i].FRA_Account_Manager__c)
                       || (oldlstAccount[i].FRA_Customer_Service_Rep__c != newLstAccount[i].FRA_Customer_Service_Rep__c)
                       || (oldlstAccount[i].FRA_Contracts_Administrator__c != newLstAccount[i].FRA_Contracts_Administrator__c)
                       || (oldlstAccount[i].FRA_Software_Application_Eng__c != newLstAccount[i].FRA_Software_Application_Eng__c))
                   {
                        lstAccount.add(newLstAccount[i]);
                        System.debug('@@@@@@@..' +  oldlstAccount[i].OwnerId + ' ' + newLstAccount[i].OwnerId);
                        System.debug('@@@@@@@..' + oldlstAccount[i].Account_Manager__c + ' ' +  newLstAccount[i].Account_Manager__c);
                        System.debug('@@@@@@@..' + oldlstAccount[i].CSR__c + ' ' +  newLstAccount[i].CSR__c);
                        System.debug('@@@@@@@..' + oldlstAccount[i].Professional_Services_Rep__c + ' ' +  newLstAccount[i].Professional_Services_Rep__c);
                        System.debug('@@@@@@@..' + oldlstAccount[i].Software_Application_Eng__c + ' ' +  newLstAccount[i].Software_Application_Eng__c);
                        System.debug('@@@@@@@..' + oldlstAccount[i].Contracts_Administrator__c + ' ' +  newLstAccount[i].Contracts_Administrator__c);
                        System.debug('@@@@@@@..' + oldlstAccount[i].Inside_Sales_Rep__c + ' ' +  newLstAccount[i].Inside_Sales_Rep__c);
                        System.debug('@@@@@@@..' + oldlstAccount[i].AR_Representative__c + ' ' +  newLstAccount[i].AR_Representative__c);
                        System.debug('@@@@@@@..' + oldlstAccount[i].Partner_Agent__c + ' ' +  newLstAccount[i].Partner_Agent__c);
                        System.debug('@@@@@@@..' + oldlstAccount[i].Inside_CSR__c + ' ' +  newLstAccount[i].Inside_CSR__c);
                        System.debug('@@@@@@@..' + oldlstAccount[i].FRA_Account_Manager__c + ' ' +  newLstAccount[i].FRA_Account_Manager__c);
                        System.debug('@@@@@@@..' + oldlstAccount[i].FRA_Customer_Service_Rep__c + ' ' +  newLstAccount[i].FRA_Customer_Service_Rep__c);
                        System.debug('@@@@@@@..' + oldlstAccount[i].FRA_Contracts_Administrator__c + ' ' + newLstAccount[i].FRA_Contracts_Administrator__c);
                        System.debug('@@@@@@@..' + oldlstAccount[i].FRA_Software_Application_Eng__c + ' ' + newLstAccount[i].FRA_Software_Application_Eng__c);
                   }
               }
            }
            else
            {
                lstAccount = newLstAccount;
            }
        }
        list<id> lstAccountId = new list<id>();
        for(Account acct:lstAccount)
        {
            lstAccountId.add(acct.id);
        }
        if(!lstAccountId.isEmpty()  && (isUpdateVal) && !System.isFuture()) {
            UpdateAccountTeam.UpdateAccountTeam(UserName,lstAccountId);
        }
        else {
            acctUpdateTerritoriesExecutedOnce = true;
        }
    }
    /*
    public static void updatePartnerAgt(List<Account> lstAccount)
    {
        String profileId= userInfo.getProfileId();
        String UserId= userInfo.getUserId();
        system.debug('before update trigger to set the value');
        if(isExecute)
        {
            lstProfile=[Select UserLicenseId,Id From Profile where Id=:profileId limit 1 ];
            lstUsrLicense = [Select Name,Id From UserLicense where Name='Gold Partner' limit 1];
            isExecute =false;
        }
        for(Account acc :lstAccount)
        {
            
            
            if(lstUsrLicense[0].Id == lstProfile[0].UserLicenseId)
            {
                acc.Partner_Agent__c  = UserId;
            }
         }
    }
    
    public static void partnerAgentUpdate(list<Id> lstAccountIds)
    {       
        List<Account> lstAccountToUpdate = new List<Account>();
        list<Account> lstAcct = [select id,
                                        Partner_Agent__c,
                                        ownerId,
                                        recordOwner__c
                                 from
                                     Account
                                 where
                                     id IN:lstAccountIds
                                
                                ];
        if(lstAcct != null && lstAcct.size() > 0)
        {
            for(Account acct:lstAcct)
            {
                if(acct.recordOwner__c != null) 
                {
                    system.debug('Setting acct.Partner_Agent__c');
                    acct.Partner_Agent__c = acct.recordOwner__c;
                    system.debug('@@Setting acct.Partner_Agent__c'+acct.Partner_Agent__c);
                    lstAccountToUpdate.add(acct);                       
                }
            }
            try{                
                if(lstAccountToUpdate != null && lstAccountToUpdate.size() > 0)
                {
                    isExecuted = true;
                    hasUpdtedPartnerAgent = true;
                    UpdateAccountTeam.isExecuteAccountTeam = false; 
                    update lstAccountToUpdate;                     
                    PartnerMasterOwnerController.updtPartnerAgent=false;
                 }
            }
            catch(Exception e)
            {
                    system.debug('update failed');
            }
        }
    
    }
        @future
        public static void Update_Quotes_AccountLegalName(Map<Id, String> MapAccountIdLegalName){ 
        
        system.debug('MapAccountIdLegalName Id::'+MapAccountIdLegalName.keyset());
        List<VCG_CPQ_Quote__c> lstUpdatedQuotes = new List<VCG_CPQ_Quote__c>();
        List<VCG_CPQ_Quote__c> lstQuotes = [SELECT Id,Account__c,Account_Legal_Name__c,Status__c FROM VCG_CPQ_Quote__c 
                                            WHERE Account__c in :MapAccountIdLegalName.keyset()];
                 
        for(VCG_CPQ_Quote__c objQuotes: lstQuotes)
        {
            if(MapAccountIdLegalName.containsKey(objQuotes.Account__c))
            {
                if(objQuotes.Status__c != 'Approved')
                {
                    objQuotes.Account_Legal_Name__c = MapAccountIdLegalName.get(objQuotes.Account__c);
                    lstUpdatedQuotes.add(objQuotes);
                }
            }
        }
        try{
            if(!lstUpdatedQuotes.isEmpty())
                Update lstUpdatedQuotes;
        }
        catch(Exception e)
        {
        system.debug('Error: During Account Legal Name updation due to::'+e.getmessage());
        }
        }
    
    
    /*
     *When the Collector Name is published from Oracle, look up their user id by the Oracle Name
     *field on the User record and put the user id in the AR Rep field on the Account
    
    public static void populateAR_Rep(List<Account> lstAccount)
    {
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {email};
        String Output='';
        list<string> lstCollectName  = new list<string>();
        for(Account acct:lstAccount)
        {
            if(acct.Collector_Name__c != NULL) 
            {
               lstCollectName.add(acct.Collector_Name__c);
            }
        }
           
        List<user> lstUsr = [select Oracle_Name__c from User 
                             where Oracle_Name__c in :lstCollectName
                             limit 50000];
        map<string,user> mapOfOracleNameNUsrId =  new map<string,user>();
        if(lstUsr.size()>0)
        {
            for(User usr:lstUsr)
            {
                mapOfOracleNameNUsrId.put(usr.Oracle_Name__c,usr);    
            }
        }

        if (mapOfOracleNameNUsrId.size()>0) 
        {
            for(Account acct:lstAccount)
            {
            if(mapOfOracleNameNUsrId.keyset().contains(acct.Collector_Name__c))
                       acct.AR_Representative__c = mapOfOracleNameNUsrId.get(acct.Collector_Name__c).id;     
            
            }
          
        }
     }         
    /* public static void setReseller(list<Account> lstAccount)
     {
            
            Id resellerPartnerAccountRecordTypeId;
            Map<Id, Account> accountNames = new Map<Id, Account>();
            //if(idNameMap.containsKey(System.Label.partner_account_reseller)) {
                resellerPartnerAccountRecordTypeId = System.Label.partner_account_reseller;
            //}            
             
            Set<Id> accountIds = New Set<Id>();
 
            //Get the Accounts that are of type Partner Account (Reseller)                       
            for (Account a:lstAccount)
            {
                system.debug('a.RecordTypeId'+a.RecordTypeId);
                system.debug('a.Reseller__c'+a.Reseller__c);
                system.debug('resellerPartnerAccountRecordTypeId'+resellerPartnerAccountRecordTypeId);
                if(a.RecordTypeId==resellerPartnerAccountRecordTypeId && a.Reseller__c == null){
                    system.debug('inside 2nd if');
                    AccountIds.add(a.Id);
                }     
            }
            
           system.debug('AccountIds.size()'+ AccountIds.size());
            
            if(AccountIds.size() > 0)   // Putting a size Check by Abhishek 
             {       
            accountNames = new Map<Id, Account>(
                                        [SELECT CreatedBy.Contact.AccountId 
                                            FROM Account where 
                                            CreatedBy.Contact.AccountId!=null and 
                                            Id in:accountIds limit 50000]);    
             }
    //If map has values
           if (accountNames.size() > 0)
            {
                for(Account a:lstAccount)
                {
                    if(accountNames.containsKey(a.Id)) {
                        a.Reseller__c=accountNames.get(a.Id).CreatedBy.Contact.AccountId;
                        system.debug('a.Reseller__c'+a.Reseller__c);
                    }                    
                }   
           } // End - if
       } // End - method
       
       public static void RecordOwnerChange(list<string> lstOwnerId , list<Account> lstAccount, list<Account>lstOldAccount)
       {
           string LoggedInUsrUserType = userInfo.getUserType();
           List<Id> lstPartnerId = new List<Id>();
           List<User> lstUser = new List<User>();
           Map<string , user> mapOfIdnUsrRec = new Map<string , user>();
           Map<string,user> mapOfAcctIdnUsrRec =  new Map<string,user>();
           
           if(null == lstOwnerId || lstOwnerId.isEmpty()) {
               return;
           }
           
           lstUser = [Select 
                            u.id,
                            u.AccountId,
                            u.UserType,
                            u.Profile.Name,
                            u.ProfileId
                       From 
                            User u 
                       where
                            id IN :lstOwnerId
                       limit 50000];
           
          string PartnerMasterOwnerProfileId = system.label.Partner_Master_Owner_Profile;
          for(User usr : lstUser)
          {
              mapOfIdnUsrRec.put(usr.Id,usr); 
          }
                    
          //for(Account acct : lstAccount)
          for(Integer i=0; i < lstAccount.size(); i++)
          {
              if(mapOfIdnUsrRec.containsKey(lstAccount[i].OwnerId))
              {
                  mapOfAcctIdnUsrRec.put(lstAccount[i].id ,mapOfIdnUsrRec.get(lstAccount[i].OwnerId));    
              }
        
              User tempUser = mapOfAcctIdnUsrRec.get(lstAccount[i].id);//  added by joseph hutchins 12/2/2014 to fix null exception error
              if( tempUser != null &&
        tempUser.id == lstAccount[i].ownerId
                 && tempUser.ProfileId != PartnerMasterOwnerProfileId )
                 {
                     system.debug('Inside for ');
                     if(lstAccount[i].ownerId != lstOldAccount[i].ownerId
                     ||lstAccount[i].RecordOwner__c != lstOldAccount[i].RecordOwner__c)
                     {
                         lstAccount[i].RecordOwner__c = null;
                         lstAccount[i].Partner_Agent__c = null;
                     }
                 }
               if(mapOfAcctIdnUsrRec.get(lstAccount[i].id).id == lstAccount[i].ownerId
                  && mapOfAcctIdnUsrRec.get(lstAccount[i].id).userType == 'PowerPartner'
                  &&(lstAccount[i].recordTypeId == system.label.T_L_Sales_Accounts_RecType_Id
                   ||lstAccount[i].recordTypeId ==System.Label.partner_account_reseller
                  ))
                  {
                      system.debug('Inside for loop1');
                      if(LoggedInUsrUserType != 'PowerPartner' && mapOfAcctIdnUsrRec.get(lstAccount[i].id).profileId != '00e500000018UEw' && lstAccount[i].Primary_Business_Unit__c != 'Roadnet')
                      {                         
                          //lstAccount[i].addError('Accounts need to be assigned to partners using the "Assign to Partner" link.');
                      }
                   }
                                        
                  } 
             
              }    

       /**
        Added this method to populate the sic general description/detailed description when an sic code is selected
        @auhtor joseph hutchins 
        @date 10/22/2014
      
       public static void updateSicFields(List<Account> oldAccountTriggerRecords, List<Account> newAccountTriggerRecords)
       {
            //  per mibos conf call on 3/26/2015, there is an issue with this causing too many soql queries so going to modify
            //  this so that it only queries the Sic records if the field has actually changed OR if the 
            //  accounts are being inserted
            List<Account> accountsToUpdate = new List<Account>();
            
            if (oldAccountTriggerRecords != null)//  called by the update trigger
            {
                for (integer i = 0; i < newAccountTriggerRecords.size(); i++)
                {
                    if (oldAccountTriggerRecords[i].SIC_Code__c != newAccountTriggerRecords[i].Sic_Code__c)
                    {
                        accountsToUpdate.add(newAccountTriggerRecords[i]);
                    }
                }   
            }
            else//  called by insert
            {
                for (Account a : newAccountTriggerRecords)
                {
                    if (a.Sic_Code__c != null)
                    {
                        accountsToUpdate.add(a);
                    }
                }
            }
            
            if (accountsToUpdate != null && accountsToUpdate.size() > 0)
            {
                //  mass query the sic table for mulitple account procesing
                system.assertNotEquals(null, allSics);
                
                for (Account singleAccount : accountsToUpdate)
                {
                    if (singleAccount.sic_code__c != null)
                    {
                        Sic__c tempSicRecord = findSicRecord(allSics, singleAccount.sic_code__c);
                        if (tempSicRecord != null)
                        {
                            singleAccount.SIC_Description_General__c = tempSicRecord.description_general__c;
                            singleAccount.SIC_Description_Detailed__c = tempSicrecord.description_detailed__c;
                            singleAccount.SIC_Reporting_Description__c = tempSicRecord.Reporting__c;
                        }
                    }
                    else//  sic code is blank or been removed, empty out the other sic fields
                    {
                        singleAccount.SIC_Description_General__c = '';
                        singleAccount.SIC_Description_Detailed__c = '';
                        singleAccount.SIC_Reporting_Description__c = '';
                    }
                }
                
            }
            
            //  since this is called by the before trigger, we will let it update the accounts, no need to implicilty update the accounts here
       }
       private static List<SIC__c> allSics
        {
            get
            {
                if (allSics == null)
                {
                    system.debug('ctrlf testing how many times this is called....');
                    //  should never be more thatn 100000 records but just in case...
                    allSics = [select id, name, description_general__c, description_detailed__c, reporting__c from SIC__c limit 10000];
                }
                return allSics;
            }
        } 
       
    
    /*  
    *  This will set the "manual assignment" checkbox on accounts depending on it's business unit.  Put simply, Roadnet does not have the
    *  checkbox set, non roadnet business units have it turned on.
    *@author Joseph Hutchins
    *@date 10/30/2014
    *
    
    public static void manageManualAssignmentForAccountTeamCreation(List<Account> olderAccounts, List<Account> newerAccounts)
    {
        if (olderAccounts == null || olderaccounts.size() == 0)//  isInsert
        {
            for (Account a : newerAccounts)
            {
                if (a.Primary_Business_Unit__c == 'Omnitracs Mexico' ||
                  a.Primary_Business_Unit__c == 'Sylectus' ||
                  a.Primary_Business_unit__c == 'Roadnet')
                {
                    a.Manual_Assignment__c = true;
                }
                //  for omnitracs domestic, the manual assignment field should be set to false but we'll leave it up the user to manage that
                
            
            }
        
        }
        else//  isUpdate
        {
            for (integer i = 0; i < newerAccounts.size(); i++)
            {
                //  account business unit is being changed to roadnet or Omnitracs Domestic, let's turn the manual assignment checkbox off
                if (olderAccounts[i].Primary_Business_Unit__c != newerAccounts[i].Primary_Business_Unit__c)
                {
                    if (newerAccounts[i].Primary_Business_Unit__c == 'Omnitracs Mexico' ||
                        newerAccounts[i].Primary_Business_Unit__c == 'Sylectus' ||
                        newerAccounts[i].Primary_Business_unit__c == 'Roadnet')
                    {
                        newerAccounts[i].Manual_Assignment__c = true;
                    }
                    else if (newerAccounts[i].Primary_Business_Unit__c == 'Omnitracs Domestic')
                    {
                        //  Omnitracs domestic manual assignment should be turned off
                        newerAccounts[i].Manual_Assignment__c = false;
                    }
                }
                
            }
        }
        
    }       
 
 
    /*  
    *  This is designed to create account teams for Roadnet accounts.  The account owner, account owner's manager, John Wajer
    *  and Scott hilderbrand are made to apart of the team.  The account team is used for accounts at risk.
    *@author Joseph Hutchins
    *@date 10/30/2014
    *
    
    public static void createAccountTeams(List<Account> olderAccounts, List<Account> newerAccounts)
    {
        //  so the logic is as followed, we need to see if the trigger isInsert or isUpdate
        //  if isInser, the logic remains the same, if isUpdate, we just need to pull out the accounts whose
        //  account primary business unit is changing and/or is already a roadnet account but is going from prospect to customer
        List<Account> accountsToWorkOn = new List<Account>();
        //  will be used to skip the check on "doesTeamMemberExistAlready", since newly created accoutns would have no account team members already
        
        boolean isInsert = olderAccounts == null || olderAccounts.size() == 0;
        
        if (isInsert)//  after insert was called
        {            
            for (integer i = 0; i < newerAccounts.size(); i++)
            {
              if (newerAccounts[i].Account_Classification__c == 'Customer' &&
                newerAccounts[i].Primary_Business_Unit__c == 'Roadnet')
                {
                  accountsToWorkOn.Add(newerAccounts[i]);
                }
            }
        }
        else 
        {
          //  scroll thru, pulling out only those whose business unit has changed to roadnet AND/OR
          //  if the account is being changed to a active customer via the account Status and is already roadnet
            for (integer i = 0; i < newerAccounts.size(); i++)
            {
              boolean didPrimaryBusinessUnitChangeToRoadnet = olderAccounts[i].Primary_Business_unit__c != newerAccounts[i].Primary_Business_Unit__c &&
                    newerAccounts[i].Primary_Business_Unit__c == 'Roadnet';
                    
                boolean isAccountRoadnetAndSetToActive = newerAccounts[i].Primary_Business_Unit__c == 'Roadnet' &&
                  olderAccounts[i].Account_Classification__c != newerAccounts[i].Account_Classification__c &&
                  newerAccounts[i].Account_Classification__c == 'Customer';

                if (newerAccounts[i].Account_Status__c == 'Active' &&  //  only shuld create account teams for active acounts
                  (didPrimaryBusinessUnitChangeToRoadnet || isAccountRoadnetAndSetToActive))
                {
                    accountsToWorkOn.add(newerAccounts[i]);
                }
            }
        }
        //  so we should have a list of accounts who are potentially going to get an account team creatd for them
        //  the next thing we need to do is to confirm if the account doesn't already have the account team
        //  that is about to be created for them, i would take the easy route and just see if any account team
        //  already exists but i will check to see if the specific users ie john/scott/account owner/account owner manager
        //  is already apart of the team, so lets mass query all the account team members that point to the accounts
        List<AccountTeamMember> teamMembersOfAccounts;
        if (!isInsert)
        {
          //  query existing team members already so we dont double create them
           teamMembersOfAccounts = [select accountid, userid, teammemberrole from AccountTeamMember where accountid =: accountsToWorkOn];  
        }
        else
        {
          teamMembersOfAccounts = new List<AccountTeamMember>();
        }
        
        id johnWajerId;
        id scottHilderbrandId;
        try
        {
            //  prequery scott's and john's user id, its done like this so that its not two queries instead of one
            User[] twoUsers = [select id, name from user where (name = 'John Wajer' or name = 'Scott Hildebrand') and isactive = true];
            for (User singleUser : twoUsers)
            {
               if (singleUser.Name == 'John Wajer')
               {
                   johnWajerId = singleUser.id;
               }
               if (singleUser.Name == 'Scott Hildebrand')
               {
                scottHilderbrandId = singleUser.id;
               }
            }
        
        }        
        catch(Exception e)
        {
            //  possbile that this will fail if the user's are not active
        }
        
        //  first thing we need to do is requery the accounts, we are doing this so we can get the account owner's id field
        //  the account owner's manager will be the second member on the account team
        List<Account> accountsRequeried = [select id, primary_business_unit__c, ownerId, owner.isactive, owner.managerId, owner.manager.isactive 
          from account where id in: accountsToWorkOn];
        
        //  we can save query rows if we only requery accounts whose business unit is roadnet...
        List<AccountTeamMember> teamMembersToCreate = new List<AccountTeamMember>();
        
        for (Account singleAccount : accountsRequeried)
        {
          //  only if account owner is active AND the account owner isn't already a team member do we create him as account team mbmer
            if (singleAccount.Owner.isactive && 
              !doesTeamMemberExistAlready(isInsert, singleAccount.Owner.id, singleAccount.id, teamMembersOfAccounts))
            {
                AccountTeamMember accountOwner = new AccountTeamMember();
                accountOwner.accountid = singleAccount.id;
                accountOwner.UserId = singleAccount.OwnerId;
                accountOwner.TeamMemberRole = 'Account Manager';
                //accountOwner.AccountAccessLevel = 'Read/Write';
                teamMembersToCreate.add(accountOwner);
            }
            
            //  make sure the account owner id is set
            if (singleAccount.Owner.ManagerId != null &&
                  singleAccount.Owner.manager.isActive &&
                  !doesTeamMemberExistAlready(isInsert, singleAccount.Owner.ManagerId, singleAccount.id, teamMembersOfAccounts))//  got error that steve simon was inactive when i was testing this
            {
                AccountTeamMember accountOwnerManager = new AccountTeamMember();
                accountOwnerManager.accountid = singleAccount.id;
                accountOwnerManager.userId = singleAccount.Owner.ManagerId;
                accountOwnerManager.TeamMemberRole = 'Account Manager';
                //accountOwner.AccountAccessLevel = 'Read/Write';
                teamMembersToCreate.Add(accountOwnerManager);
            }
            // now we add john and scott if they are not the owner of the account already
            //  if they were they would've been added in the previous step
            if (johnWajerId != null && 
             singleAccount.OwnerId != johnwajerId && 
             singleAccount.Owner.ManagerId != johnWajerId &&
             !doesTeamMemberExistAlready(isInsert, johnWajerId, singleAccount.id, teamMembersOfAccounts))
            {
                AccountTeamMember johnMember = new AccountTeamMember();
                johnMember.accountid = singleAccount.id;
                johnMember.userId = johnWajerId;
                johnMember.TeamMemberRole = 'Account Manager';
                //johnMember.AccountAccessLevel = 'Read/Write';
                teamMembersToCreate.add(johnMember);
            }
            if (scottHilderbrandId != null && 
             singleAccount.OwnerId != scottHilderbrandId && 
             singleAccount.Owner.Managerid != scottHIlderbrandId &&
             !doesTeamMemberExistAlready(isInsert, scottHilderbrandId, singleAccount.id, teamMembersOfAccounts))
            {
                AccountTeamMember scottMember = new AccountTeamMember();
                scottMember.AccountId = singleAccount.id;
                scottMember.userId = scottHilderbrandId;
                scottMember.TeamMemberRole = 'Account Manager';
                //scottMember.AccountAccessLevel = 'Read/Write';
                teamMembersToCreate.add(scottMember);
            }
            
        }
        
        if (teamMembersToCreate.size() > 0)
        {
           insert teamMembersToCreate;
        }
    }           
    
    private static boolean doesTeamMemberExistAlready(boolean isInsert, id userId, id accountid, List<AccountTeamMember> teamMembersOfAccounts)
    {
      if (isInsert)
      {
        return false;
      }
    //  scroll thru each account team member fields to check if the user id passed in aready is a team member of that account
    for (AccountTeamMember atm : teamMembersOfAccounts)
    {
      if (atm.AccountId == accountId && atm.UserId == userId)
      {
        return true;
      }
    }      
    return false;
    }
           
       private static Sic__c findSicRecord(List<Sic__c> sics, string sicCode)
       {
            for (Sic__c singleSic : sics)
            {
                if (singleSic.name == siccode)
                {
                    return singleSic;
                }
            }
            return null;
       }
       @future                            
       public static void UpdateAccountForPRMUser(list<string> lstAcctIds, boolean isInsert)
       {
           system.debug('####'+isInsert);
           //string loggedUserId = userInfo.getUserId();
           List<Account> lstAccountToUpdate = new List<Account>();
           
           
           List<Account> lstAccount = [select 
                                               id,
                                               ownerId,
                                               RecordOwner__c
                                          
                                         from
                                              Account
                                         where
                                             id IN :lstAcctIds];
           List<Id> userIdList = new List<Id>();                                  
                                             
           for(Account a : lstAccount)
           {
            userIdList.add(a.ownerId);
           }                                  
                                             
           Map<Id, User> mapOfUsers = new Map<Id, User>([select 
                                         id,
                                         Master_Partner_User__c 
                                  from 
                                         User 
                                  where 
                                         id IN: userIdList]);                                  
           
           for(Account acct :lstAccount )
           {            
               
                acct.RecordOwner__c = acct.ownerId;
                acct.Partner_Agent__c = acct.RecordOwner__c; 
                
                try{                               
                  if( mapOfUsers.get(acct.OwnerId).Master_Partner_User__c != null)                               
                   acct.OwnerId =  mapOfUsers.get(acct.OwnerId).Master_Partner_User__c; 
                 }
                 catch(Exception e){
                   system.debug('Exception ee'+ e.getMessage());
                 }                       
              
                lstAccountToUpdate.add(acct);
               
           }     
                try{
                      system.debug('lstAccountToUpdate'+lstAccountToUpdate[0].RecordOwner__c +' ' +lstAccountToUpdate[0].ownerId);
                      update lstAccountToUpdate;
                      
                }   
                catch(Exception e)
                {
                    System.debug(e);
                }
            
        }
        /**
         * @description Method to update the Customer Action Plan field when field on accounts   
         * are changed
         * @author Amrita
         * Anand - Commented for Jan 23 Dep will have to be uncommmented for CAP changes
         
         /* 
        public static void updateCAPFields(Map<string,Account> mapAcctIdnAcctRec){
            system.debug('@@@@@ method called');
            List<Customer_Action_Plan__c> lstCAPUpdate = new List<Customer_Action_Plan__c>();
            Map<string,Customer_Action_Plan__c> mapCAPIdCAPRec = new Map<string,Customer_Action_Plan__c>
                ([SELECT 
                      Account_Manager__c,
                      CSR__c, 
                      Inside_CSR__c,
                      Sales_Director__c,
                      QES_Owner__c,
                      Account__c,
                      Customer_ID__c
                  FROM
                      Customer_Action_Plan__c
                  WHERE
                      Account__c IN :mapAcctIdnAcctRec.keySet()
                 LIMIT 50000]);
            if(!mapCAPIdCAPRec.isEmpty()) {            
                for(String key:mapCAPIdCAPRec.keySet()){
                    String mstAcctId = mapCAPIdCAPRec.get(key).Account__c;
                    
                    //Update the child CAP records with the new field value
                    if(mapAcctIdnAcctRec.containsKey(mstAcctId))
                    {
                        mapCAPIdCAPRec.get(key).Account_Manager__c = mapAcctIdnAcctRec.get(mstAcctId).Account_Manager__c;             
                        mapCAPIdCAPRec.get(key).CSR__c = mapAcctIdnAcctRec.get(mstAcctId).CSR__c;
                        mapCAPIdCAPRec.get(key).Inside_CSR__c = mapAcctIdnAcctRec.get(mstAcctId).Inside_CSR__c;
                        mapCAPIdCAPRec.get(key).Sales_Director__c = mapAcctIdnAcctRec.get(mstAcctId).Sales_Director__c;
                        mapCAPIdCAPRec.get(key).QES_Owner__c = mapAcctIdnAcctRec.get(mstAcctId).ownerId;
                        mapCAPIdCAPRec.get(key).Customer_ID__c = mapAcctIdnAcctRec.get(mstAcctId).QWBS_Cust_ID__c;
                        lstCAPUpdate.add(mapCAPIdCAPRec.get(key));
                    }   
                }
                try{
                        system.debug('CAP to be updated: '+lstCAPUpdate);
                        update lstCAPUpdate;
                   }
                catch(Exception e){
                    System.debug('@@@Exception: '+e.getMessage());
                }
           }    
        
        }
        
        
        /**
         * @description Method to update the recordtype based on the   
         * value of the market
         * @author Amrita
          
        public static void changeRecordType(list<Account> lstAccount)
        {
            List<PMOMarketRecordTypePair__c> lstPMOMarketRecordTypePair = PMOMarketRecordTypePair__c.getAll().values(); 
            set<string> setMktNames = new set<string>(); 
            map<string,string> mktRecTypePair = new map<string,string>();
            if(lstPMOMarketRecordTypePair != null && lstPMOMarketRecordTypePair.size()>0)
            {
                for(PMOMarketRecordTypePair__c mrtp:lstPMOMarketRecordTypePair)
                {
                    mktRecTypePair.put(mrtp.Market_Name__c,mrtp.Record_Type_Id__c);        
                }
            }
            for(Account acct:lstAccount)
            {
                if(mktRecTypePair != null && mktRecTypePair.size() > 0 && mktRecTypePair.containsKey(acct.QWBS_Market__c))
                {
                    acct.RecordTypeId = mktRecTypePair.get(acct.QWBS_Market__c);
                }
            }
        
        }  
        
        @future (callout=true)
        public static void updatePartnerSupportDetails(List<String> lstAccountIds,
                                                       List<String> lstSupportAccountIds,
                                                       List<String> lstCSRId) {
            Map<Id, User> mapUser = null;
            Map<Id, Account> mapAccount = null;
               
            Set<String> setUserId = new Set<String>();
            Set<String> setAccountIds = new Set<String>();
            
            setUserId.add(UserInfo.getUserId());
            setUserId.addAll(lstCSRId);
            setAccountIds.addAll(lstAccountIds);
            setAccountIds.addAll(lstSupportAccountIds);

            mapUser = new Map<Id, User>([
                        SELECT
                            id,
                            AccountId,
                            FederationIdentifier
                        FROM
                            User
                        WHERE
                            id = :setUserId
                        LIMIT
                            :setUserId.size()
                      ]); 
                       
            mapAccount = new Map<Id, Account>([
                        SELECT
                            id,
                            AGUID__c,
                            OwnerId,
                            District__c,
                            CSR__c,
                            Support_Account__c,
                            RecordOwner__c,
                            isPartner
                        FROM
                            Account
                        WHERE
                            id in :setAccountIds
                        LIMIT
                            :setAccountIds.size()
                      ]);          
                      

            QESUnityAdminLinkWebServices.AdminServiceSoapImplPort port = null;    
            QESUnityAdminLinkWebServices.standardResponse response = null;
                      
            try {
                port = new QESUnityAdminLinkWebServices.AdminServiceSoapImplPort();
                String authorization = EncodingUtil.base64Encode(
                                       Blob.valueOf(unityCredentials ));
                port.inputHttpHeaders_x = new Map<String, String>();
                port.inputHttpHeaders_x.put('Authorization', 'Basic ' + authorization);
                                          
                for(String accountId : lstAccountIds) {                             
                    Account a = mapAccount.get(accountId);
                    if(null == a.AGUID__C) {
                        System.debug('@@@@.. Skipping account as AGUID__c is null');
                        continue;
                    }
                    if( !(a.isPartner) && (a.District__c == 'Strategic') && ((null == a.CSR__c) || (null == mapUser.get(a.CSR__c).FederationIdentifier) ) ) {
                        System.debug('@@@@.. Skipping account as it is a non-partner strategic account with no CSR.');
                        continue;
                    }
                    else if( (null == a.Support_Account__c) || (null == mapAccount.get(a.Support_Account__c).AGUID__c) ) {
                        System.debug('@@@@.. Skipping account as Support_Account is null or the Support_Account does not have a compnay-GUID.');
                        continue;
                    }
                    
                    QESUnityAdminLinkWebServices.ExtendedCompany company = new QESUnityAdminLinkWebServices.ExtendedCompany();                    
                    company.CompanyGuid = a.AGUID__c; 
                    
                    if(a.isPartner) {
                        company.SupportModel = 'TRIAD';
                        company.SupportCompanyGuid = a.AGUID__c;
                
                        company.companyAttributeList = new QESUnityAdminLinkWebServices.CompanyAttributeList_element();
                        company.companyAttributeList.companyAttribute = new List<QESUnityAdminLinkWebServices.CompanyAttribute>();
                        
                        QESUnityAdminLinkWebServices.CompanyAttribute companyAttribute = new QESUnityAdminLinkWebServices.CompanyAttribute();
                        companyAttribute.AttrName = 'SUPPORT_TRIAD_EMAIL';
                        companyAttribute.AttrValueString = System.Label.PRM_Support_Email_Group;
                        company.companyAttributeList.companyAttribute.add(companyAttribute);   
                        System.debug('@@@@@@..Setting TRIAD email Id to .. ' + System.Label.PRM_Support_Email_Group);                                                                                             
                    }
                    else {
                        if(a.District__c == 'Strategic') {
                            // Strategic Account
                            company.SupportModel = 'CSR'; 
                            company.QcomCSRUserGuid = mapUser.get(a.CSR__c).FederationIdentifier;
                        }
                        else {
                            // Not Strategic
                            if(mapAccount.get(a.Support_Account__c).isPartner) {
                                // Partner
                                company.SupportModel = 'PARTNER'; 
                                company.SupportCompanyGuid = mapAccount.get(a.Support_Account__c).AGUID__c;
                            }
                            else {
                                company.SupportModel = 'TRIAD'; 
                                TriadEmails__c triadEmailCS = TriadEmails__c.getValues(a.District__c);
                                if(null == triadEmailCS) {
                                    System.debug('@@@@@@@..Triad Email Id does not exist for district->' + a.District__c);
                                }
                                else {
                                    // TODO Add the code to populate the email-id in the WS request
                                    company.companyAttributeList = new QESUnityAdminLinkWebServices.CompanyAttributeList_element();
                                    company.companyAttributeList.companyAttribute = new List<QESUnityAdminLinkWebServices.CompanyAttribute>();
                                    
                                    QESUnityAdminLinkWebServices.CompanyAttribute companyAttribute = new QESUnityAdminLinkWebServices.CompanyAttribute();
                                    companyAttribute.AttrName = 'SUPPORT_TRIAD_EMAIL';
                                    companyAttribute.AttrValueString = triadEmailCS.TriadEmailId__c;
                                    company.companyAttributeList.companyAttribute.add(companyAttribute);   
                                    System.debug('@@@@@@..Setting TRIAD email Id to .. ' + triadEmailCS.TriadEmailId__c);                                                                     
                                }
                                company.SupportCompanyGuid = a.AGUID__c;
                            }                                                                                  
                        }
                    }                                

                    String str = '@@@@@@@@@@@@@@@@@@@@@..Request';
                    str = str + '\nCompanyGUID = ' + company.CompanyGuid;
                    str = str + '\nSupportModel = ' + company.SupportModel;
                    str = str + '\nSupportCompanyGuid = ' + company.SupportCompanyGuid;
                    str = str + '\nQcomCSRUserGuid = ' + company.QcomCSRUserGuid + '\n';     
                    if(null == mapUser.get(UserInfo.getUserId()).FederationIdentifier) {
                        response = port.updateCompanyModelDetails(company, mapUser.get(UserInfo.getUserId()).Id);
                    }
                    else {               
                        response = port.updateCompanyModelDetails(company, mapUser.get(UserInfo.getUserId()).FederationIdentifier);                
                    }
                    System.debug(str);
                    System.debug('@@@@@@@@..' + response.status);        
                    System.debug('@@@@@@@@..' + response.message);                
                }                                
            }                        
            catch(Exception e) {
                System.debug('@@@@@@@@..' + e);        
            } // End - catch                               
        }
        
        @future
        public static void remNotTypesAndChangeOwnerFromDormantAcc(List<Id> listClosedStatusAccountId) {  
            if(listClosedStatusAccountId == null || listClosedStatusAccountId.size() < 1) return;
            
            // The marketing admin record id is stored in a hierarchical custom setting.
            String marketingadminid = MarketingAdmin__c.getInstance().Marketing_Admin_User__c;
            
           
            
            // Query for all the contacts associated with found accounts.
            List<Contact> contactstoupdate = new List<Contact>([
                select Notification_Type__c
                from   Contact
                where  Account.Id in :listClosedStatusAccountId
            ]);
            if(contactstoupdate.size() < 1) return;
            
            // Filter out notification types.
            final Set<String> typestofilterout = new Set<String>{
                'Battery Alert'
                ,'Downtime/Degraded'
                ,'FRA'
                ,'Portal Services Platform'
                ,'RMA Initiator'
                ,'SSO Portal Administrator'
                ,'Time Change'
            };
            for(Contact c : contactstoupdate) {
                // Set the owner of the contact to the marketing admin.
                if(marketingadminid != null) c.OwnerId = marketingadminid;
                
                if(c.Notification_Type__c == null) continue;
                List<String> valuestosave = new List<String>();
                for(String s : c.Notification_Type__c.split(';')) {
                    if(!typestofilterout.contains(s)) valuestosave.add(s);
                }
                c.Notification_Type__c = StringUtils.joinStrings(valuestosave,';');
            }
            update contactstoupdate;
        }
        
        @future
        public static void inactivateContactsFromDormantAccounts(List<Id> listDormantAccountsWhoseContactsToBeDeactivated) {
            if(listDormantAccountsWhoseContactsToBeDeactivated == null || listDormantAccountsWhoseContactsToBeDeactivated.size() < 1) return;
            
           
            List<Contact> contactstoupdate = new List<Contact>([
                select  id
                from    Contact
                where   AccountID in :listDormantAccountsWhoseContactsToBeDeactivated and  Inactive__c = false                
            ]);
            if(contactstoupdate.size() < 1) return;
            
            for(Contact c : contactstoupdate) c.Inactive__c = true;
            update contactstoupdate;
        }
        
        @future
        public static void changeOpprStageToClosedLost(List<Id>listClosedStatusAccountIdTLorPartner)
        {
            List<Opportunity> oppList = [select id from Opportunity where accountId IN :listClosedStatusAccountIdTLorPartner AND stageName != 'Shipped' AND stageName != 'Closed Lost' ];
            Map<Id,Account> accMap = new  Map<Id,Account>( [select id,Closed_Reason__c from Account where id IN :listClosedStatusAccountIdTLorPartner]);
            for(Opportunity o : oppList)
            {
                o.stageName = 'Closed Lost';
                if(accMap.containsKey(o.accountId))
                {
                  if(o.Reason_Lost__c == null || o.Reason_Lost__c == '')
                  o.Reason_Lost__c =  accMap.get(o.accountId).Closed_Reason__c;
                  if(o.Reason_Lost_Comments__c == null || o.Reason_Lost_Comments__c == '')
                   o.Reason_Lost_Comments__c = accMap.get(o.accountId).Closed_Reason__c;
                }                
            }
            update oppList;
        }
        
        
        public static boolean checkIfClosedStatus(String statusToCheck )
        {
        // Collect any updated Accounts with appropriate status.
            final Set<String> statuses = new Set<String>{
                'Inactive'
                ,'Inactive Prospect'
                ,'Closed Contract Customer'
                ,'Closed - End of Eval'
            };
            
            if(statuses.contains(statusToCheck))
            {
                return true;
            }
            else
            return false;
        }
        public static boolean checkIfTLOrPartnerAcc(Id RecordTypeId )
        {
            if(RecordTypeId == PARTNER_ACCOUNT_RESELLER_RECORD_TYPE_ID || RecordTypeId == TL_SALES_ACCOUNT_RECORD_TYPE_ID)
            return true;
            else
            return false;
        }
        
        //Added for  CR 00108807
        public static void preventRecTypeChange(List<Account> listOfAcc, Map<Id,Account> mapOfOldAcc)
        {
          for(Account newAcc: listOfAcc)
      {
       if(Interface_Users__c.getInstance().Is_Interface__c)
       {  
        Account oldAcc = mapOfOldAcc.get(newAcc.id);
        if(newAcc.recordTypeId != oldAcc.recordTypeId)
          {
            //Modifying so that Interface users cannot make any record type change. for Rick's case: 01240364 
            //if((oldAcc.recordTypeId+'').contains(System.Label.Account_Other_RecType)
            //||(oldAcc.recordTypeId+'').contains(System.Label.Account_Int_Partner_RecType))
            //{
              newAcc.recordTypeId = oldAcc.recordTypeId;
            //}
          }
        }  
      }
        }
        
   
    
    // CR 105284 implemented with Custom settings method
    
    public static String getStateCode(String stateToValidate)
    {
                  State__c sCode;
                  String stateCodeValue;
                  Map<String,State__c> mapCodes = State__c.getAll();
                 
                  List<State__c> listOfCodes = State__c.getAll().values();
                  Set<String> setofStateCode = new Set<String>();
                  
                  for(State__c cd : listOfCodes)
                  {
                      setOfStateCode.add(cd.StateCode__c);
                  }
                  
                    
             if(mapCodes.containsKey(stateToValidate))
             {             
                 
                  sCode = State__c.getInstance(stateToValidate);
                  stateCodeValue = sCode.StateCode__c;                  
                  
                  if(stateCodeValue != null && stateCodeValue != '')
                  {                     
                     return stateCodeValue;
                  }
                  else
                  {   
                     return stateToValidate;          
                  }
   
             } 
             else if(setOfStateCode.contains(stateToValidate) && stateToValidate != null && stateToValidate != '')
             {   
                  return stateToValidate;       
             }
             else
             {   
                  return null;        
             }
                              
                                     
            return null; 
          
    }
    
     public static void updateStateCode(Map<id,String> mapOfAccntIdToBillState)
     {
      
      Set<Id> setOfIds = new Set<Id>();
      
      if(!mapOfAccntIdToBillState.isEmpty())
        setOfIds.addAll(mapOfAccntIdToBillState.keySet());
      
      List<Account> accList = [select id, BillingState from Account where id IN: setOfIds];
      
      List<Account> accTobeUpdated  = new List<Account>();
        
      for(Account acnt : accList)
      {
         if(mapOfAccntIdToBillState.containsKey(acnt.id))
         {
           acnt.BillingState= mapOfAccntIdToBillState.get(acnt.id);
         }
          
       accTobeUpdated.add(acnt);
       } 
       try{
           update accTobeUpdated;
       }
       catch(exception e)
       {
           System.debug('Error on Billing state: ' + e.getMessage());
       }    
    }
    //Changes for CR 01205396
    //To populate Data share partner field based on the referral partner entered
    public static void populateDataSharePartners (List<Account> acctsToPopulateDataShare)
    {
      Set<Id> SetOfReferralPartnerIds = new Set<Id>();
      
      for(Account a : acctsToPopulateDataShare)
      {
        SetOfReferralPartnerIds.add(a.Referral_Account__c);
      }
      
      Map< Id, Data_Sharing_Partner__c>  dspMap = new Map< Id, Data_Sharing_Partner__c> ();
            
      for(Data_Sharing_Partner__c dsp: [select id,Related_Account__c from Data_Sharing_Partner__c where Related_Account__c IN:SetOfReferralPartnerIds  ])
      {
        dspMap.put(dsp.Related_Account__c, dsp);
      }
      
      for(Account a : acctsToPopulateDataShare)
      {
        if(dspMap.containsKey(a.Referral_Account__c))
        {
        a.Data_Share_Partner__c = dspMap.get(a.Referral_Account__c).id;
        }
        
      }      
      
    }
    
    // Code end as per CR 105284
	*/
    }