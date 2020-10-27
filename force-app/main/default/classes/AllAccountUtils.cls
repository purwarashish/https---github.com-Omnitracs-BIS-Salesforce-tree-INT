/***********************************************************************************
Author: Vignesh Nayak S, Salesforce.com Developer
Tata Consultancy Services Limited
Description : This class is called from AllAccount trigger. This clasd uses 4 custom settings listed below.
              Hence please refer the respective methods before adding or modifying the custom settings.
              Custom Settings : AccountQwbsCloseStatuses, AccountRankingCargoType, AccountRecordTypes, AllAccountUtils, ContactNotificationTypes.
************************************************************************************/
global class AllAccountUtils
{
    /**************Static constants***********************/
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
    static boolean stateUpdate=false;    
    static boolean isExecute = true;
    static boolean isExecuteSetReseller = true; 
    static boolean isExecuteAcctAll = true; 
    static string email = 'kdinen@qualcomm.com';
    public static boolean isExecuted = false; 
    private static Boolean acctUpdateTerritoriesExecutedOnce = false;
    static Map<id,Boolean> mapRollupUpdate = new  Map<id,Boolean>();
    //TODO : Uncomment the password for prod before deployment
    private static String unityCredentials = system.label.UnamePwdLinkWebservice;//'sf-prod@service.qes.qualcomm.com:saleSm3ggs';
    //private static String unityCredentials  = 'sf-non-prod@service.qes.qualcomm.com:saleSm3ggs';
    // added to ensure that when ever owner is changed , Partner agent is same as the owner
    public static boolean hasUpdtedPartnerAgent = false; 
    /********************************************************/
    /* Code added by Pratyush to avoid the trigger from executing if it is
     * an update on the Roll-up summary fields from Serialized-Unit-Summary.
     */
    public static void checkRollUpUpdate(List<Account> lstTriggerNew, Map<id,Account> mapTriggerOld)        
    {   
        for(Account acct : lstTriggerNew) 
        {
            Account oldAcct = mapTriggerOld.get(acct.id);
            if( (acct.Total_TT210_3G_Units__c != oldAcct.Total_TT210_3G_Units__c) ||
                (acct.Total_T2_Units__c != oldAcct.Total_T2_Units__c) ||
                (acct.Total_OX_Units__c != oldAcct.Total_OX_Units__c) ||
             // (acct.Total_OX2_Units__c != oldAcct.Total_OX2_Units__c) ||
                (acct.Total_OT_Units__c != oldAcct.Total_OT_Units__c) ||
                (acct.Total_MRM100_Units__c != oldAcct.Total_MRM100_Units__c) ||
                (acct.Total_MCP50_Units__c != oldAcct.Total_MCP50_Units__c) ||
                (acct.Total_TT210_Units__c != oldAcct.Total_TT210_Units__c) ||
                (acct.Total_MCP110_Units__c != oldAcct.Total_MCP110_Units__c) ||
                (acct.Total_MCP100T_Units__c != oldAcct.Total_MCP100T_Units__c) ||
                (acct.Total_MCP100S_Units__c != oldAcct.Total_MCP100S_Units__c) ||
                (acct.Total_GT_Units__c != oldAcct.Total_GT_Units__c) ||
             // (acct.Sum_of_Open_Opportunities_Direct__c != oldAcct.Sum_of_Open_Opportunities_Direct__c) || // Added new 3 conditions
             // (acct.Sum_of_Open_Opportunities__c != oldAcct.Sum_of_Open_Opportunities__c) || 
                (stateUpdate==true)) 
                {
                    mapRollupUpdate.put(acct.id ,False); //acc.id False
                }
                else
                {
                    mapRollupUpdate.put(acct.id ,True);                      
                }
        }
    }
    //  this method sets the account.ranking_cargo_type__c field, all of the account.ranking**** fields are set by field updates
    //  but this requires tirgger logic to set  by joseph hutchins 7/16/2015
    public static void assignRankingCargoType(List<Account> accounts,Map<id,Account> mapTriggerOld)
    {
      // cargo type is a multi select picklist meaning it can contain no or all values
      // we need to split out the cargo type selections that are selected, compare them and 
      // pick out the cargo type with the highest value
      //Get CargoType and its ranking value from custom setting.
        List<AccountRankingCargoType__c> lstRankingCargoType = AccountRankingCargoType__c.getall().values();
        map<String,Decimal> mapCargoNameAndRanking = new map<String,Decimal>();
        for(AccountRankingCargoType__c ObjAccRankingValue : lstRankingCargoType)
        {
            mapCargoNameAndRanking.put(ObjAccRankingValue.name,ObjAccRankingValue.Ranking__c);
        }
        for (Account a : accounts)
        {
            /*if(Trigger.isUpdate)
            {
                if(!mapRollupUpdate.get(a.id) || (a.Cargo_Type__c == mapTriggerOld.get(a.id).Cargo_Type__c))
                {
                    Continue;
                }
            }*/
            List<string> cargoTypesSplitOut = Util.parseString(a.Cargo_Type__c);
            if (cargoTypesSplitOUt != null && cargoTypesSplitOut.size() > 0)
            {
              //  assume the first cargo type has highest value, and compare to the others int he list
              string highestValueCargoType = cargoTypesSplitOut[0];
              
              //  if other has highest value, assign that as highest value
              for (integer i = 0; i < cargoTypesSplitOut.size(); i++)
              {
                if(mapCargoNameAndRanking.get(cargoTypesSplitOut[i]) > mapCargoNameAndRanking.get(highestValueCargoType))
                {
                  highestValueCargoType = cargoTypesSplitOut[i];
                }
              }
              if (!util.isblank(highestValueCargoType))
              {
                  a.Ranking_Cargo_Type__c = mapCargoNameAndRanking.get(highestValueCargoType);
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
    
    /**@Description:This method calculates the DataQualityScore 
     * Updates the Data_Quality_Description_Apex__c field on account 
    **/
    
    public static void calDataQualScr(List<Account> lstAccount)    
    {   
        System.debug('Inside calDataQualScr of Account utility1'); 
        Integer totalFieldCount = 0;    
        Integer calculatedScore = 0;
        for(Account act :lstAccount )
        {    
            if(Trigger.isUpdate)
            {
                if(!mapRollupUpdate.get(act.id))
                {
                    Continue;
                }
            }
            Map<string,string> labels = new Map<string,string>();
            Integer nonNullFieldCount = 0;
            List<string> scoreFieldDescList = new List<string>();
            totalFieldCount = 0;
            //--CHECK IF RELEVANT FIELDS FOR T & L HAS VALUE-------------/
            
            
            if ( AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c != null)
            {
                if(act.RecordTypeId == AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c )
                {
                    labels.put(AllAccountUtils__c.getInstance('BILLING_ADDRESS').Value__c,act.BillingStreet);
                    labels.put(AllAccountUtils__c.getInstance('PHONE').Value__c,act.Phone);
                    labels.put(AllAccountUtils__c.getInstance('ACCOUNT_TYPE').Value__c,act.Account_Type__c);
                    labels.put(AllAccountUtils__c.getInstance('MARKET').Value__c,act.QWBS_Market__c);
                  //labels.put(AllAccountUtils__c.getInstance('DISTRICT').Value__c,act.District__c);
                    labels.put(AllAccountUtils__c.getInstance('STATUS').Value__c,act.QWBS_Status__c);
                    labels.put(AllAccountUtils__c.getInstance('LEAD_SOURCE').Value__c,act.Lead_Source__c);
                    labels.put(AllAccountUtils__c.getInstance('AVG_LEN_HAUL').Value__c,act.Average_Length_of_Haul__c);
                    labels.put(AllAccountUtils__c.getInstance('REG_VEHICLES').Value__c,String.valueOf(act.Regional_Vehicles__c));
                 // labels.put(AllAccountUtils__c.getInstance('OTR_VEHICLES').Value__c,String.valueOf(act.OTR_Vehicles__c));
                    labels.put(AllAccountUtils__c.getInstance('PRIMARY_BUSINESS').Value__c,act.Primary_Business__c);
                 // labels.put(AllAccountUtils__c.getInstance('PRIMARY_COMMODITY').Value__c,act.Primary_Commodity__c);
                     
                    if((act.QWBS_Status__c == AllAccountUtils__c.getInstance('EVAL_CUSTOMERS').Value__c) 
                    || (act.QWBS_Status__c == AllAccountUtils__c.getInstance('CONTRACT_CUSTOMER').Value__c))
                    {             
                        labels.put(AllAccountUtils__c.getInstance('CONTACT_COMMENT').Value__c,act.Contract_Comments__c);
                        labels.put(AllAccountUtils__c.getInstance('CONTRACT_EXPIRATION').Value__c,String.valueOf(act.Contract_Expiration__c));
                        labels.put(AllAccountUtils__c.getInstance('COMP_PLATFORM').Value__c,act.Computer_Platform__c);
                        labels.put(AllAccountUtils__c.getInstance('RANKING').Value__c,act.Ranking__c);
                    }
                }
			}
            
            	/*Else if (AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c != null && AllAccountUtils__c.getInstance('QWBS_MARKET').Value__c != null)
                {
                    if(act.RecordTypeId == AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c
                                &&  act.QWBS_Market__c ==AllAccountUtils__c.getInstance('QWBS_MARKET').Value__c)
                        {
                      //  =================================================================================
                      //  =====CNR Sales ==================
                      //  =================================================================================
                      //--CHECK IF RELEVANT FIELDS FOR T & L HAS VALUE-------------/
                            labels.put(AllAccountUtils__c.getInstance('LOCATION').Value__c,String.valueOf(act.of_Locations__c));
                            labels.put(AllAccountUtils__c.getInstance('ACCT_MANAGER').Value__c,act.Account_Manager__c);
                            labels.put(AllAccountUtils__c.getInstance('ACCOUNT_TYPE').Value__c,act.Account_Type__c);
                            labels.put(AllAccountUtils__c.getInstance('BILLING_CITY').Value__c,act.BillingCity);
                            labels.put(AllAccountUtils__c.getInstance('BILLING_COUNTRY').Value__c,act.BillingCountry);
                            labels.put(AllAccountUtils__c.getInstance('BILLING_STATE').Value__c,act.BillingState);
                            labels.put(AllAccountUtils__c.getInstance('BILLING_STR').Value__c,act.BillingStreet);
                            labels.put(AllAccountUtils__c.getInstance('BILLING_POSTAL_CODE').Value__c,act.BillingPostalCode);
                            labels.put(AllAccountUtils__c.getInstance('COMP_PLATFORM').Value__c,act.Computer_Platform__c);
                            labels.put(AllAccountUtils__c.getInstance('CUST_ID').Value__c,act.QWBS_Cust_ID__c);
                            labels.put(AllAccountUtils__c.getInstance('CUST_SERVICE_REP').Value__c,act.CSR__c);
                          //labels.put(AllAccountUtils__c.getInstance('DISTRICT').Value__c,act.District__c);
                         // labels.put(AllAccountUtils__c.getInstance('DOLLIES').Value__c,String.valueOf(act.Dollies__c));
                         // labels.put(AllAccountUtils__c.getInstance('DRY_VANS').Value__c,String.valueOf(act.Dry_Vans__c));
                            labels.put(AllAccountUtils__c.getInstance('FAX').Value__c,act.Fax);
                         // labels.put(AllAccountUtils__c.getInstance('FLATBEDS').Value__c,String.valueOf(act.Flatbeds__c));
                            labels.put(AllAccountUtils__c.getInstance('LEAD_SOURCE').Value__c,act.Lead_Source__c);
                            labels.put(AllAccountUtils__c.getInstance('MARKET').Value__c,act.QWBS_Market__c);
                         // labels.put(AllAccountUtils__c.getInstance('OBC').Value__c,String.valueOf(act.OBC__c));
                         // labels.put(AllAccountUtils__c.getInstance('OEM_TRACTOR').Value__c,act.OEM_Tractor__c);
                         // labels.put(AllAccountUtils__c.getInstance('REEFER_TRAILER').Value__c,act.OEM_Reefer_Trailer__c);
                        //  labels.put(AllAccountUtils__c.getInstance('OTR_VEHICLES').Value__c,String.valueOf(act.OTR_Vehicles__c));
                            labels.put(AllAccountUtils__c.getInstance('PRIMARY_BUSINESS').Value__c,act.Primary_Business__c);
                       //   labels.put(AllAccountUtils__c.getInstance('PRIMARY_COMMODITY').Value__c,act.Primary_Commodity__c);
                            labels.put(AllAccountUtils__c.getInstance('RANKING').Value__c,act.Ranking__c);
                        //  labels.put(AllAccountUtils__c.getInstance('REEFERS').Value__c,String.valueOf(act.Reefers__c));
                            labels.put(AllAccountUtils__c.getInstance('REG_VEHICLES').Value__c,String.valueOf(act.Regional_Vehicles__c));
                            labels.put(AllAccountUtils__c.getInstance('RFC_ID').Value__c,act.RFC_ID__c);
                            labels.put(AllAccountUtils__c.getInstance('SHIPPING_CITY').Value__c,act.ShippingCity);
                            labels.put(AllAccountUtils__c.getInstance('SHIPPING_COUNTRY').Value__c,act.ShippingCountry);
                            labels.put(AllAccountUtils__c.getInstance('SHIPPING_PROV').Value__c,act.ShippingState);
                            labels.put(AllAccountUtils__c.getInstance('SHIPPING_STR').Value__c,act.ShippingStreet);
                            labels.put(AllAccountUtils__c.getInstance('SHIPPING_POSTAL_CODE').Value__c,act.ShippingPostalCode);
                            labels.put(AllAccountUtils__c.getInstance('STATUS').Value__c,act.QWBS_Status__c);
                         // labels.put(AllAccountUtils__c.getInstance('TANKERS').Value__c,String.valueOf(act.Tankers__c));
                         // labels.put(AllAccountUtils__c.getInstance('TRAILERTRACS').Value__c,String.valueOf(act.TrailerTRACS__c));
                    }
                }*/ 

            /*Else if (AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c != null)
            {
                if(act.RecordTypeId == AccountRecordTypes__c.getInstance('GSS_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c)
                {
                    if(act.District__c !=null)
                    {
                        labels.clear();
                        nonNullFieldCount = 0;
                        scoreFieldDescList = new List<string>();
                        labels.put(AllAccountUtils__c.getInstance('ACCOUNT_NAME').Value__c,act.Name);
                        labels.put(AllAccountUtils__c.getInstance('ACCOUNT_TYPE').Value__c,act.Account_Type__c);
                        labels.put(AllAccountUtils__c.getInstance('FAX').Value__c,act.Fax);
                        labels.put(AllAccountUtils__c.getInstance('RANKING').Value__c,act.Ranking__c);
                        labels.put(AllAccountUtils__c.getInstance('PDT_INTEREST').Value__c,act.Product_Interest__c);
                     // labels.put(AllAccountUtils__c.getInstance('FEATURE_INTEREST').Value__c,act.Feature_Interest__c);
                        labels.put(AllAccountUtils__c.getInstance('BILLING_STR').Value__c,act.BillingStreet);
                        labels.put(AllAccountUtils__c.getInstance('PHONE').Value__c,act.Phone); 
                        //--CHECK IF RELEVANT FIELDS FOR T & L HAS VALUE-------------/
                     /* if(act.District__c.contains(AllAccountUtils__c.getInstance('ORMM').Value__c))
                        {
                            labels.put(AllAccountUtils__c.getInstance('DEALER').Value__c,String.valueOf(act.Dealer__c));
                        }
                        else
                        {
                         // labels.put(AllAccountUtils__c.getInstance('DEVICE_SUPP').Value__c,act.Device_Supplier__c);
                         // labels.put(AllAccountUtils__c.getInstance('ASSET_VAL_RANGE').Value__c,act.Asset_Value_Range__c);
                         // labels.put(AllAccountUtils__c.getInstance('SERVICE_MODEL').Value__c,act.Service_Model__c);
                         // labels.put(AllAccountUtils__c.getInstance('ENABLED_DEVICE').Value__c,String.valueOf(act.Number_of_Enabled_Devices__c));
                        } //
                    }//
                }//
            }*/
            totalFieldCount = labels.size();
            if(totalFieldCount>0)
            {
                assignScoreDescToAccount(act,labels,totalFieldCount);
            }
        }
    }
    
    /* This method assigns the data score and the description 
        for the account based on Omni Domestic On Air Info */
    public static void assignScoreDescToAccount(Account act,Map<string,string> labels,Integer totalFieldCount)    
    {
        Integer nonNullFieldCount = 0;
        List<string> scoreFieldDescList = new List<string>();
        Integer calculatedScore = 0;
    
        for(string key:labels.keyset())
        {
            if(labels.get(key) == null || labels.get(key) =='')
            {
                scoreFieldDescList.add(key);   
            }
            else
            {
                nonNullFieldCount++;
            }
        }
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
    
    /* Added this method to populate the sic general description/detailed 
    description when an sic code is selected        **/
    
    public static void updateSicFields(List<Account> accounts,Map<id,Account> mapTriggerOld)
    {   
        Account objAcc;
        map<String, Account> mapSicWithAccount = new map<String, Account >();
        for(Account singleAccount : accounts)
        {   
            if(Trigger.isUpdate)
            {
                Account oldAcct = mapTriggerOld.get(singleAccount.id); 
                if((!mapRollupUpdate.get(singleAccount.id)) || (oldAcct.sic_code__c == singleAccount.sic_code__c))
                {
                    Continue;
                }
            }
            if (singleAccount.sic_code__c != null)
            {
                mapSicWithAccount.put(singleAccount.sic_code__c,singleAccount);
            }
        }
        if(mapSicWithAccount.keyset().size()>0)
        {
            List<Sic__c> lstSic = [select id, name, description_general__c, description_detailed__c, reporting__c from SIC__c
                                    where name in: mapSicWithAccount.keyset()];
                        
            for(Sic__c objSic : lstSic)
            {    
                objAcc = new Account();
                if(mapSicWithAccount.containsKey(objSic.name))
                {   
                    objAcc = mapSicWithAccount.get(objSic.name);
                    objAcc.SIC_Description_General__c = objSic.description_general__c;
                    objAcc.SIC_Description_Detailed__c = objSic.description_detailed__c;
                    objAcc.SIC_Reporting_Description__c = objSic.Reporting__c;
                }
            }    
        }
    }
    
    /* This method Finds the account for which the Data Share has to be populated.
    based on the referred account given to the account */
    
    public static void findAccountsToPopulateDataShare(list<Account> lstNewerAccounts, list<Account> lstOlderAccounts)
    {   
        //Changes for CR 01205396
        System.debug('Entered findAccountsToPopulateData');
        List<Account> acctsToPopulateDataShare = new List<Account>(); 
        
        for(Integer i=0;i<lstNewerAccounts.size();i++)
        {
            if(!mapRollupUpdate.get(lstNewerAccounts[i].id))
            {
                Continue;
            }
        if(lstNewerAccounts[i].Referral_Account__c != lstOlderAccounts[i].Referral_Account__c && lstNewerAccounts[i].Referral_Account__c != null)     
         {
            acctsToPopulateDataShare.add(lstNewerAccounts[i]);
         } 
        if(lstNewerAccounts[i].Lead_Source_Most_Recent__c == null &&  lstNewerAccounts[i].Lead_Source__c != null )
        {
            lstNewerAccounts[i].Lead_Source_Most_Recent__c = lstNewerAccounts[i].Lead_Source__c;
        }
        if(lstNewerAccounts[i].Lead_Source_Most_Recent__c != null &&  (lstNewerAccounts[i].Lead_Source__c == null || lstNewerAccounts[i].Lead_Source_Update_Date__c < (System.TODAY()-365)) )
        {
            lstNewerAccounts[i].Lead_Source__c = lstNewerAccounts[i].Lead_Source_Most_Recent__c;
        }   
        }
        if(!acctsToPopulateDataShare.isEmpty())
        {
            populateDataSharePartners(acctsToPopulateDataShare);
        }
    }
    
    /* Method to get the list of Owner id's of the records whose owner updation is requested */
    public static list<string> getAccountOwnerId ( Map<id,Account> mapNewAccounts, Map<id,Account> mapOldAccounts)
    {
        list<string> lstOwnerId = new list<string>();
        for(Id acctId : trigger.newMap.keySet())
        {   
            if(!mapRollupUpdate.get(acctId))
            {
                Continue;
            }
            if(mapNewAccounts.get(acctId).ownerId != mapOldAccounts.get(acctId).ownerId)
            {
                lstOwnerId.add(mapNewAccounts.get(acctId).ownerId);
            }    
        }
        return lstOwnerId;
    }
    
    //Update Partner Support Info Details to Unity
    public static void UpdatePartnerSupport(list<Account> lstTriggerNew, list<Account> lstTriggerOld, boolean isUpdate)
    {
        Set<Id> setRecordOwner = new Set<Id>();
        Map<Id, User> mapUser = null;
            
        for(Account a : lstTriggerNew) 
        {   
            if(Trigger.isUpdate)
            {
                if(!mapRollupUpdate.get(a.id))
                {
                    Continue;
                }
            }
            if(null != a.RecordOwner__c) 
            {
                setRecordOwner.add(a.RecordOwner__c);
            }                        
        }
            
        if(0 != setRecordOwner.size()) 
        {
            mapUser = new Map<Id, User>([ SELECT id, AccountId, FederationIdentifier
                                            FROM User WHERE id in :setRecordOwner LIMIT :setRecordOwner.size() ]);
        }
    
        if(isUpdate==false) 
        {
            List<Id> lstAcctIds = new List<Id>();
            for(Account a : lstTriggerNew) 
            {    
                lstAcctIds.add(a.id);
                if(null != a.RecordOwner__c) 
                {
                    a.Support_Account__c = mapUser.get(a.RecordOwner__c).AccountId;
                }
                else 
                {
                    a.Support_Account__c = System.Label.Omnitracs_Account_Id;
                }
            }               
        }
        else 
        {
            for(Integer i = 0; i < lstTriggerNew.size(); i++) 
            {
                if(!mapRollupUpdate.get(lstTriggerNew[i].id))
                {
                    Continue;
                }
                // Check if it is an owner-update. If yes, we need to update the Support-Account
                if(lstTriggerNew[i].RecordOwner__c != lstTriggerOld[i].RecordOwner__c || lstTriggerNew[i].Support_Account__c == null) 
                {
                    if(null == lstTriggerNew[i].RecordOwner__c) 
                    {
                        // Support Account has to be Omnitracs
                        // Exception: This is not valid for Omnitracs account
                        if(!(lstTriggerNew[i].id+'').contains(System.Label.Omnitracs_Account_Id))
                        lstTriggerNew[i].Support_Account__c = System.Label.Omnitracs_Account_Id;
                    }
                    else 
                    {
                        // Support account has to be the account Id of the record-owner
                        lstTriggerNew[i].Support_Account__c = mapUser.get(lstTriggerNew[i].RecordOwner__c).AccountId;
                    }
                }
            } // End for           
        } // End else          
    }   
    
     /**@Description:This method creates a record of team member object  
      *    for Account inserted or updated
      *
    **/  
    public static void acctUpdateAcctTerritories(list<Account> oldlstAccount,list<Account> newLstAccount,boolean isUpdateVal)
    {
        String UserName = userInfo.getUserName();
        list<Account> lstAccount = new list<Account>();
        list<id> lstAccountId = new list<id>();
        System.debug('Inside acctUpdateAcctTerritories');
            // Not an insert scenario
            if(isUpdateVal)
            {
                for(Integer i=0;i<newLstAccount.size();i++)
                {    
                    if(!mapRollupUpdate.get(newLstAccount[i].id))
                    {
                        Continue;
                    }
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
                   }
               }
            }
            else
            {
                lstAccount = newLstAccount;
            }
        
        for(Account acct:lstAccount)
        {   
            if(trigger.isUpdate)
            {
                if(!mapRollupUpdate.get(acct.id))
                {
                    Continue;
                }
            }
            lstAccountId.add(acct.id);
        }
        
        if(!lstAccountId.isEmpty() && !System.isFuture() && (isUpdateVal))
        {
            AccountTeamUpdate.UpdateAccountTeam(UserName,lstAccountId);
        }
        else 
        {
            acctUpdateTerritoriesExecutedOnce = true;
        }

    }
   
    public static void partnerAgentUpdate(Set<Id> setAccountIds, Boolean isExecutedFrmTrigger)
    {   
        System.debug('isExecutedFrmTrigger ::'+isExecutedFrmTrigger);
        IF(isExecutedFrmTrigger == false)
        {
            set<id> setAccId = new set<id>();
            for(id accId : setAccountIds)
            {    
                if(trigger.isUpdate)
                {
                    if(!mapRollupUpdate.get(accId))
                    {
                        Continue;
                    }
                }
                setAccId.add(accId);
            }
            // Bulk-update
            if((1 < setAccId.size()) || (PartnerMasterOwnerController.updtPartnerAgent == true))
            {
                List<Account> lstAccountToUpdate = new List<Account>();
                list<Account> lstAcct = [select id, Partner_Agent__c, ownerId, recordOwner__c
                                         from Account where id IN: setAccId ];
                if(lstAcct != null && lstAcct.size() > 0)
                {
                    for(Account acct:lstAcct)
                    {
                        if(acct.recordOwner__c != null) 
                        {
                            acct.Partner_Agent__c = acct.recordOwner__c;
                            lstAccountToUpdate.add(acct);                       
                        }
                    }
                    try
                    {                
                        if(lstAccountToUpdate != null && lstAccountToUpdate.size() > 0)
                        {
                            isExecuted = true;
                            hasUpdtedPartnerAgent = true;
                            AccountTeamUpdate.isExecuteAccountTeam = false; 
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
        }
    }
    
    /* Method that will capture updated CSR and support account
       and Update Partner Support Info Details to Unity .
    */
    
    public static void DataPrepPlusupdatePartnerSupportDetails(list<Account> lstTriggerNew,list<Account> lstTriggerOld,boolean isInsertVal)
    {             
        List<Id> lstAccountIds = new List<Id>();
        List<Id> lstSupportAccountIds = new List<Id>();
        List<Id> lstCSRId = new List<Id>();                
        System.debug('************************ IN DataPrepPlusupdatePartnerSupportDetails');            
        if(isInsertVal) 
        {
            for(Account a : lstTriggerNew) 
            {
                lstAccountIds.add(a.id);
                if(null != a.Support_Account__c) 
                {
                    lstSupportAccountIds.add(a.Support_Account__c);
                }                       
                if(null != a.CSR__c) 
                {
                    lstCSRId.add(a.CSR__c);
                }   
            }
        }
        else 
        {
            boolean isOnboardingStatusChanged = false;
            for(Integer i = 0; i < lstTriggerNew.size(); i++) 
            {
                if(!mapRollupUpdate.get(lstTriggerNew[i].id))
                {
                    Continue;
                }
                if((lstTriggerOld[i].UnityOnboardStatus__c!= lstTriggerNew[i].UnityOnboardStatus__c))
                {
                    isOnboardingStatusChanged = true;
                }
                else
                {
                    isOnboardingStatusChanged = false;
                }
            
                if((lstTriggerOld[i].Support_Account__c != lstTriggerNew[i].Support_Account__c)
                   || (lstTriggerOld[i].RecordOwner__c != lstTriggerNew[i].RecordOwner__c)
                   || (lstTriggerOld[i].CSR__c != lstTriggerNew[i].CSR__c)
                   || isOnboardingStatusChanged ) 
                {
                System.debug('************************ ADD ACCOUNT');
                    if(lstTriggerNew[i].AGUID__c != null)
                    { 
                        lstAccountIds.add(lstTriggerNew[i].id);
                    }
                    if(null != lstTriggerNew[i].Support_Account__c) 
                    {
                        lstSupportAccountIds.add(lstTriggerNew[i].Support_Account__c);
                    }                       
                    if(null != lstTriggerNew[i].CSR__c) 
                    {
                        lstCSRId.add(lstTriggerNew[i].CSR__c);
                    }  
                } 
            }                
        } // End else
        if((0 < lstAccountIds.size()) && !System.isFuture()) 
        {
            System.debug('************************ SEND UPDATES');
            AllAccountUtils.updatePartnerSupportDetails(lstAccountIds, lstSupportAccountIds, lstCSRId);
        }
    }

    /* Method Updates the contact status to closed whenever required */

    public static void ChangeContactStatus(map<id,Account> mapTriggerNew,map<id,Account> mapTriggerOld,boolean isInsertVal)
    {
    if(!System.isFuture() && !AllAccountUtils.HasAccountTriggerExecuted())
        {
            List<Id>listClosedStatusAccountId = new List<Id>();
            List<Id>listDormantAccountsWhoseContactsToBeDeactivated = new List<Id>();
            List<Id>listClosedStatusAccountIdTLorPartner = new List<Id>();
            for(Account a : mapTriggerNew.values())
            {    
                if(!mapRollupUpdate.get(a.id))
                {
                    Continue;
                }
                //Check if status has changed
                if(a.QWBS_Status__c != mapTriggerOld.get(a.id).QWBS_Status__c)
                { 
                    //Check if new status is a closed status
                    if(AllAccountUtils.checkIfClosedStatus(a.QWBS_Status__c)) 
                    {
                        listClosedStatusAccountId.add(a.id);
                        //Check if recordType is TL or Partner (for CR 103555)
                        if(AllAccountUtils.checkIfTLOrPartnerAcc(a.recordTypeId))
                        {
                            listClosedStatusAccountIdTLorPartner.add(a.id);
                        }
                    }   
                
                
                    if((a.Closed_Reason__c != mapTriggerOld.get(a.id).Closed_Reason__c)&&
                        ((a.Closed_Reason__c == AllAccountUtils__c.getInstance('CLSD_RSN_OUT_OF_BUS').Value__c
                        || a.Closed_Reason__c ==  AllAccountUtils__c.getInstance('CLSD_RSN_NON_PAY').Value__c )  
                        || ( a.recordTypeId == AccountRecordTypes__c.getInstance('OTHER_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c
                        && a.QWBS_Market__c == 'Service Center' && a.QWBS_Status__c == 'Inactive' )))
                    {
                        listDormantAccountsWhoseContactsToBeDeactivated.add(a.id);
                    } 
                }
            }
            if(!listDormantAccountsWhoseContactsToBeDeactivated.isEmpty())
            {
                AllAccountUtils.inactivateContactsFromDormantAccounts(listDormantAccountsWhoseContactsToBeDeactivated); 
            }
            if(!listClosedStatusAccountId.isEmpty())
            {
                AllAccountUtils.remNotTypesAndChangeOwnerFromDormantAcc(listClosedStatusAccountId);
            }
            if(!listClosedStatusAccountIdTLorPartner.isEmpty())
            {
                AllAccountUtils.changeOpprStageToClosedLost(listClosedStatusAccountIdTLorPartner);
            }    
        }
        if(!Test.isRunningTest())
        {
            AllAccountUtils.AccountTriggerExecuted();
        }
    }

    /**Code added as a part of CR 01205420
        *@Amrita G
        *Calculates sum of open activities on account and update field Sum of Open Activities 
        *it's the number of Activities (Tasks) whose Status is not Completed. 
        **/ 
    public static void CalculateSumOfOpenActivities(List<Account> lstTriggerNew)
    {    
        if(system.label.Activate_Summation_of_Open_Activity == 'true'
           && CalculateSumOfOpenActivities.firstRun)
        {   
            List<id> lstAccountId= new List<id>();
            for(Account acc: lstTriggerNew)
            {
                if(Trigger.isUpdate)
                {
                    if(!mapRollupUpdate.get(acc.Id))
                    {
                        continue;
                    }
                    else
                    {    
                        lstAccountId.add(acc.Id);
                    }
                }
            }
            if(lstAccountId.size() >0 && lstAccountId!=null && !System.isFuture() && !System.isBatch()) // !System.isFuture() -> Added
            {
                CalculateSumOfOpenActivities.firstRun = false;
                CalculateSumOfOpenActivities.calSumOfOpenActv(lstAccountId);
            }
        }
    }
    /*   @Author: JBarrameda
    *    @Date: 09/25/2014
    *    @Description: For Netsuite-Account integration
    */
    public static void NetsuiteSyncUpActivity(List<Account> lstTriggerNew)
    {
        if (!NetsuiteSyncAccountHelper.hasRun && !NetsuiteSyncContactHelper.hasRun)
        {
            Set<Id> accIdList = new Set<Id>();
            for(Account a:lstTriggerNew)
            {
                if(Trigger.isUpdate)
                {
                    if(!mapRollupUpdate.get(a.id))
                    {
                        Continue;    
                    }
                }
                if(a.Send_to_Netsuite__c == true )
                {
                    accIdList.add(a.Id);
                }
            }    
                       
            if(accIdList.size()>0)
            {
                NetsuiteSyncAccountHelper.postDataToNetsuite(accIdList);        
            }
            
            //Set hasRun boolean to true to prevent recursion
            NetsuiteSyncAccountHelper.hasRun = true;
        }
    }
    
    public static void setReseller(list<Account> lstAccount)
    {
        Id resellerPartnerAccountRecordTypeId;
        resellerPartnerAccountRecordTypeId = System.Label.partner_account_reseller;
        Set<Id> accountIds = New Set<Id>();
        //Get the Accounts that are of type Partner Account (Reseller)                       
        for (Account a:lstAccount)
        {    
            if(!mapRollupUpdate.get(a.id))
            {
                Continue;    
            }
            if(a.RecordTypeId==resellerPartnerAccountRecordTypeId && a.Reseller__c == null)
            {
                AccountIds.add(a.Id);
            }     
        }
        if((accountIds.size()>0))
        {
            Map<Id, Account> accountNames = new Map<Id, Account>( [SELECT CreatedBy.Contact.AccountId FROM Account where 
                                                                   CreatedBy.Contact.AccountId!=null and Id in:accountIds limit 50000]);    
            
            //If map has values
            if (accountNames.size() > 0)
            {
                for(Account a:lstAccount)
                {
                    if(accountNames.containsKey(a.Id)) 
                    {
                        a.Reseller__c=accountNames.get(a.Id).CreatedBy.Contact.AccountId;
                    }                    
                }   
            }
        } // End - if
    } // End - method
       
    public static void RecordOwnerChange(list<string> lstOwnerId , list<Account> lstAccount, list<Account>lstOldAccount)
    {
        string LoggedInUsrUserType = userInfo.getUserType();
        List<Id> lstPartnerId = new List<Id>();
        List<User> lstUser = new List<User>();
        Map<string,user> mapOfAcctIdnUsrRec =  new Map<string,user>();
        
        if(null == lstOwnerId || lstOwnerId.isEmpty()) 
        {
            return;
        }
           
        Map<id , user> mapOfIdnUsrRec = new Map<id,user>( [Select id, AccountId, UserType, Profile.Name, ProfileId
                                                           From User where id IN :lstOwnerId limit 50000] );
          
        string PartnerMasterOwnerProfileId = system.label.Partner_Master_Owner_Profile;
          
        for(Integer i=0; i < lstAccount.size(); i++)
        {    
            if(!mapRollupUpdate.get(lstAccount[i].id))
            {
                Continue;    
            }
            if(mapOfIdnUsrRec.containsKey(lstAccount[i].OwnerId))
            {
                mapOfAcctIdnUsrRec.put(lstAccount[i].id ,mapOfIdnUsrRec.get(lstAccount[i].OwnerId));    
            }
        
            User tempUser = mapOfAcctIdnUsrRec.get(lstAccount[i].id);//  added by joseph hutchins 12/2/2014 to fix null exception error
            if( tempUser != null && tempUser.id == lstAccount[i].ownerId && tempUser.ProfileId != PartnerMasterOwnerProfileId )
            {
                if(lstAccount[i].ownerId != lstOldAccount[i].ownerId ||lstAccount[i].RecordOwner__c != lstOldAccount[i].RecordOwner__c)
                {
                    lstAccount[i].RecordOwner__c = null;
                    lstAccount[i].Partner_Agent__c = null;
                }
            }
        } 
    }    
        
    /*  
    *  This will set the "manual assignment" checkbox on accounts depending on it's business unit.  Put simply, Roadnet does not have the
    *  checkbox set, non roadnet business units have it turned on.
    *@author Joseph Hutchins
    *@date 10/30/2014
    *
    */
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
                if(!mapRollupUpdate.get(newerAccounts[i].id))
                {
                    Continue;    
                }
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
    
    public static void ValidateAndUpdateStateCode(List<Account> lstTriggerNew, boolean isBefore, Boolean isAfter, boolean isInsert,Map<id,Account> mapTriggerOld)
    {  
        Map<id,String> mapOfAccntIdToBillState = new Map<id,String>();
        for(Account acc: lstTriggerNew)
        {
            if(trigger.isUpdate)
            {
                Account oldAcct = mapTriggerOld.get(acc.id);
                if((!mapRollupUpdate.get(acc.id)) || ((oldAcct.BillingCountry == acc.BillingCountry) && (oldAcct.BillingState == acc.BillingState )) )
                {
                    Continue;    
                }
            }
            if((!(acc.RecordTypeId + '').contains(AccountRecordTypes__c.getInstance('COMPETITOR_RECORD_TYPE_ID').RecordTypeID__c)) &&
                    (acc.Unity_Prov_Type__c == 'VAR' && acc.UnityOnboardStatus__c == 'CUSTOMER'))
            {
             
              if(acc.BillingCountry == 'US' || acc.BillingCountry == 'USA' || acc.BillingCountry == null || acc.BillingCountry == '')
              {
    
                 if(acc.BillingState != null )
                 {
                     String validCode = AllAccountUtils.getStateCode(acc.BillingState);
                     if(validCode == null || validCode.length() < 2)
                     {
                         if(!Test.isRunningTest())    
                         {
                             acc.addError('A state is required for US addresses and must be capitalized two letter state code(i.e., CA, AZ).');
                         }
                     }
                     else 
                     {
                         if(acc.BillingState != validCode && (isAfter && isInsert)){
                             //mapOfAccntIdToBillState.put(acc.id,validCode);  //commented by arindam Laik as this method will be invoked only in before context
                         }
                         if(acc.BillingState != validCode && (isBefore))
                             acc.BillingState = validCode;
                     } 
                  }
                  else
                  {
                      if(!Test.isRunningTest()) 
                      {
                          acc.addError('A state is required for US addresses and must be capitalized two letter state code(i.e., CA, AZ).');
                      }
                  }
               }
            }  
        }
    } 
 
    @future                            
    public static void UpdateAccountForPRMUser(Set<id> setAcctIds)
    {
        //string loggedUserId = userInfo.getUserId();
        List<Account> lstAccountToUpdate = new List<Account>();
          
        List<Account> lstAccount = [select id,Name, ownerId, RecordOwner__c from Account
                                     where id IN :setAcctIds];
        List<Id> userIdList = new List<Id>();                                  
                                             
        for(Account a : lstAccount)
        {
            userIdList.add(a.ownerId);
        }                                  
                                             
        Map<Id, User> mapOfUsers = new Map<Id, User>([select id, Master_Partner_User__c 
                                                      from User where id IN: userIdList]);                                  
           
        for(Account acct :lstAccount )
        {            
            acct.RecordOwner__c = acct.ownerId;
            acct.Partner_Agent__c = acct.RecordOwner__c; 
            try
            {                               
                if( mapOfUsers.get(acct.OwnerId).Master_Partner_User__c != null)                               
                  acct.OwnerId =  mapOfUsers.get(acct.OwnerId).Master_Partner_User__c;
            }
            catch(Exception e)
            {
                system.debug('Exception ee'+ e.getMessage());
            }                       
            lstAccountToUpdate.add(acct);
        }     
        try
        {
            update lstAccountToUpdate;
        }   
        catch(Exception e)
        {
            System.debug(e);
        }
    }
    
        /**
         * @description Method to update the recordtype based on the   
         * value of the market
         * @author Amrita
         */ 
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
                if(!mapRollupUpdate.get(acct.id))
                {
                    Continue;    
                }
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
                            /*District__c,*/
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
                Account a;                        
                for(String accountId : lstAccountIds) {                             
                    a = new account();
                    a = mapAccount.get(accountId);
                    if(null == a.AGUID__C) {
                        System.debug('@@@@.. Skipping account as AGUID__c is null');
                        continue;
                    }
                    if( !(a.isPartner) && ((null == a.CSR__c) || (null == mapUser.get(a.CSR__c).FederationIdentifier) ) ) {
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
                        if(String.isNotBlank(a.CSR__c)){
							company.SupportModel = 'CSR'; 
							company.QcomCSRUserGuid = mapUser.get(a.CSR__c).FederationIdentifier;
						}
						else if(mapAccount.get(a.Support_Account__c).isPartner) {
							// Partner
							company.SupportModel = 'PARTNER'; 
							company.SupportCompanyGuid = mapAccount.get(a.Support_Account__c).AGUID__c;
						}
						else {
							company.SupportModel = 'TRIAD';
							company.SupportCompanyGuid = a.AGUID__c;
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
        system.debug('Invoked+remNotTypesAndChangeOwnerFromDormantAcc');
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
            // Using the Name of the Custom Setting i.e., keyset of map.
            Map<String,ContactNotificationTypes__c> mapContactNotificationTypes= ContactNotificationTypes__c.getall();
            final Set<String> typestofilterout = mapContactNotificationTypes.keyset();
            for(Contact c : contactstoupdate) 
            {
                // Set the owner of the contact to the marketing admin.
                if(marketingadminid != null) 
                    c.OwnerId = marketingadminid;
                if(c.Notification_Type__c == null) 
                    continue;
                List<String> valuestosave = new List<String>();
                for(String s : c.Notification_Type__c.split(';')) 
                {
                    if(!typestofilterout.contains(s)) 
                        valuestosave.add(s);
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
            for(Contact c : contactstoupdate)  c.Inactive__c = true;
            update contactstoupdate;
        }
        
        @future
        public static void changeOpprStageToClosedLost(List<Id>listClosedStatusAccountIdTLorPartner)
        {   
            if((listClosedStatusAccountIdTLorPartner.size() > 0)&&(listClosedStatusAccountIdTLorPartner!=null))
            {
                List<Opportunity> oppList = [select id,Reason_Lost__c,Reason_Lost_Comments__c, AccountId from Opportunity 
                                                where accountId IN :listClosedStatusAccountIdTLorPartner AND stageName != 'Closed Won' AND stageName != 'Closed Lost' ];
                Map<Id,Account> accMap = new  Map<Id,Account>( [select id,Closed_Reason__c from Account 
                                                                where id IN :listClosedStatusAccountIdTLorPartner]);
               for(Opportunity o : oppList)
               {    
                    o.stageName = 'Closed Lost';
                    if(accMap.containsKey(o.accountId))
                    {
                        if(o.Reason_Lost__c == null || o.Reason_Lost__c == '')
                        {
                            o.Reason_Lost__c =  accMap.get(o.accountId).Closed_Reason__c;
                        }
                        if(o.Reason_Lost_Comments__c == null || o.Reason_Lost_Comments__c == '')
                        {
                            o.Reason_Lost_Comments__c = accMap.get(o.accountId).Closed_Reason__c;
                        }       
                    }     
                }
                Try
                {
                    update oppList;
                }
                Catch(Exception e)
                {
                    System.debug('Exception in changeOpprStageToClosedLost'+e.getmessage());
                }
            }
        }
        public static boolean checkIfClosedStatus(String statusToCheck )
        {
            // Collect any updated Accounts with appropriate status.
            // Using the Name of the Custom Setting i.e., keyset of map.
            Map<String,AccountQwbsCloseStatuses__c> mapAccountQwbsCloseStatuses = AccountQwbsCloseStatuses__c.getall();
            final Set<String> statuses = mapAccountQwbsCloseStatuses.keyset();
            if(statuses.contains(statusToCheck))
            {
                return true;
            }
            else
            return false;
        }
        public static boolean checkIfTLOrPartnerAcc(Id RecordTypeId )
        {
            if((RecordTypeId == AccountRecordTypes__c.getInstance('PRTNR_ACNT_RESELLR_RCRD_TYPE_ID').RecordTypeID__c) || 
            (RecordTypeId == AccountRecordTypes__c.getInstance('TL_SALES_ACCOUNT_RECORD_TYPE_ID').RecordTypeID__c))
            return true;
            else
            return false;
        }
        //Added for  CR 00108807
        public static void preventRecTypeChange(List<Account> listOfAcc, Map<Id,Account> mapOfOldAcc)
        {
            for(Account newAcc: listOfAcc)
            {    
                if(!mapRollupUpdate.get(newAcc.id))
                {
                    Continue;    
                }
                if(Interface_Users__c.getInstance().Is_Interface__c)
                {  
                    Account oldAcc = mapOfOldAcc.get(newAcc.id);
                    if(newAcc.recordTypeId != oldAcc.recordTypeId)
                    {
                        newAcc.recordTypeId = oldAcc.recordTypeId;
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
        for(Data_Sharing_Partner__c dsp: [select id,Related_Account__c from Data_Sharing_Partner__c 
                                          where Related_Account__c IN:SetOfReferralPartnerIds])
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
    public static void checkAndUpdateQuoteLegalName(List<Account> lstTriggerNew, map<id, Account> mapTriggerOld)
    {
        Set<Id> accountSet = new Set<Id>();
        for(Account accnt: lstTriggerNew)
        {
            if(accnt.Legal_Name__c != mapTriggerOld.get(accnt.Id).Legal_Name__c)
            {
                accountSet.add(accnt.Id);
            }
        }
        if(accountSet.size() > 0)
        {
            //Update_Quotes_AccountLegalName(MapAccountIdLegalName);
            //UpdateQuoteLegalName(accountSet);
        }
    }
    
    public static void updateSpringCMAccountName(List<Account> lstTriggerNew, map<id, Account> mapTriggerOld, Boolean isInsert){
        List<Account> accntList = new List<Account>();
        for(Account objAccount: lstTriggerNew)
        {
            if(!isInsert && objAccount.Legal_Name__c != mapTriggerOld.get(objAccount.Id).Legal_Name__c){
                accntList.add(objAccount);
            }
        }
        
        if(accntList.size() > 0){
            SpringCMRestUtils.StartWorkflowAccount(accntList, mapTriggerOld,'Account','Entity Name Change');
        }
    }
        
    /*@future
    public static void Update_Quotes_AccountLegalName(Map<Id, String> MapAccountIdLegalName)
    { 
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
        try
        {
            if(!lstUpdatedQuotes.isEmpty())
                Update lstUpdatedQuotes;
        }
        catch(Exception e)
        {
            system.debug('Error: During Account Legal Name updation due to::'+e.getmessage());
        }
    }
    
    public static void UpdateQuoteLegalName(Set<Id> accountSet)
    { 
        List<SBQQ__Quote__c> quotesList = new List<SBQQ__Quote__c>();
        for(Account accnt : [SELECT Id, Legal_Name__c, (select Id, Ship_to_Account_Name__c, Bill_to_Account_Name__c, Corporate_Account_Name__c 
                                                          from SBQQ__Quotes__r where SBQQ__Status__c != 'Signed') 
                                     from Account where Id in :accountSet]){
            if(accnt.SBQQ__Quotes__r != null && accnt.SBQQ__Quotes__r.size() > 0){
                for(SBQQ__Quote__c uquote : accnt.SBQQ__Quotes__r){
                    uquote.Ship_to_Account_Name__c = accnt.Legal_Name__c;
                    uquote.Bill_to_Account_Name__c = accnt.Legal_Name__c;
                    uquote.Corporate_Account_Name__c = accnt.Legal_Name__c;
                    quotesList.add(uquote);
                }
            }                       
        }     
        
        try
        {
            System.debug('***********-- '+quotesList.size());
            if(quotesList.size() > 0){
                update quotesList;
            }
        }catch(Exception e)
        {
            system.debug('***************** Exception occured updating Account Legal Name ::'+e.getmessage());
        }
    }*/
    
    public static void sendCustomerSuccessEmails(List<Account> lstTriggerNew, map<id, Account> mapTriggerOld){
        Set<ID> accountSet = new Set<ID>();
        Set<ID> custAccountID = new Set<ID>();
        Set<ID> xrsAccountID = new Set<ID>();
        List<Contact> contactList = new List<Contact>();
        for(Account newAccnt: lstTriggerNew)
        {
            Account oldAccnt = mapTriggerOld.get(newAccnt.Id);
           // if(newAccnt.UnityOnboardStatus__c != 'CUSTOMER' ){
                if(newAccnt.QWBS_Cust_ID__c != oldAccnt.QWBS_Cust_ID__c && String.isNotBlank(newAccnt.QWBS_Cust_ID__c)){
                    custAccountID.add(newAccnt.Id);
                    accountSet.add(newAccnt.Id);
                }
                else if(newAccnt.Legacy_Industry_XRS__c != oldAccnt.Legacy_Industry_XRS__c && newAccnt.Legacy_Industry_XRS__c == 'XRS_VAR'){
                    xrsAccountID.add(newAccnt.Id);
                    accountSet.add(newAccnt.Id);
                }
                
            //}
        }
        System.debug('*****************1'+accountSet+' -- '+xrsAccountID);
        if(accountSet.size() > 0){
            Boolean emailSent = false;
            Boolean emailSentXRS = false;
            for(Account accnt : [select Id, Name,
                                    (select Id, Send_Success_Email__c, Send_Success_Email_XRS__c from Contacts where Unity_Prov_Type__c = 'VAR' order by createddate desc) 
                                   from Account where Id in :accountSet]){
                emailSent = false;
                emailSentXRS = false;
                                       
                if(accnt.Contacts != null && accnt.Contacts.size() > 0 && custAccountID.contains(accnt.Id)){
                    for(Contact cntct : accnt.Contacts){
                        if(cntct.Send_Success_Email__c){
                            emailSent = true;
                        }
                    }
                    if(!emailSent){
                        Contact acntct = accnt.Contacts.get(0);
                        acntct.Send_Success_Email__c = true;
                        contactList.add(acntct);
                    }
                }
                else if(accnt.Contacts != null && accnt.Contacts.size() > 0 && xrsAccountID.contains(accnt.Id)){
                    for(Contact cntct : accnt.Contacts){
                        if(cntct.Send_Success_Email_xrs__c){
                            emailSentXRS = true;
                        }
                    }
                    if(!emailSentXRS){
                        Contact acntct = accnt.Contacts.get(0);
                        acntct.Send_Success_Email_XRS__c = true;
                        contactList.add(acntct);
                    }
                }
            }
System.debug('*****************3'+contactList);                 
            if(contactList.size()>0){
                update contactList;
            }
        }
    }
}