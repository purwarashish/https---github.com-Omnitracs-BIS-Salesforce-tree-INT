public with sharing class ScoringDataUtils {

	
	public static Double extractNumberValueFromResponse(String stringResponse){
		Double responseToReturn;
		
		responseToReturn = Double.valueOf(stringResponse);
		if(responseToReturn == 0 || responseToReturn == 1 || responseToReturn == 2 || responseToReturn == 3 || responseToReturn == 4 || responseToReturn == 5 || responseToReturn == 6 || 
			responseToReturn == 7 || responseToReturn == 8 || responseToReturn == 9 || responseToReturn == 10){
				return responseToReturn;
			}
		else return null;
	}
	
	public static string convert18to15(ID id18){
			string string1;
			string string2;
			Id id15;
			
			string1 = string.valueOf(id18);
			system.debug('18 string: ' + string1);
			string2 = string1.left(15);
			system.debug('15 string: ' + string2);

			return string2;
		}
	
	public static void clicktoolsSurveyTrigger(List<Survey__c> surveyTrigger){
		List<ID> listOfSurveyIDs = new List<ID>();
		List<Account> listOfAccountsToUpdate = new List<Account>();
		Set<ID> setOfAccounts = new Set<ID>();
		List<Survey__c> listOfSurveysTest = new List<Survey__c>();
		Map<Survey__c, Account> surveyAccountMap;
		Double averageNumerator;
		Double averageDenominator;
		Double average;
		
		System.debug('Entering for loop');
		
		for(Survey__c sur : SurveyTrigger){
			System.debug('Current Survey: '  + sur.ID);
			listOfSurveyIDs.add(sur.ID);
			System.debug('Current Account: ' + sur.Account__c);
			if(sur.Account__c != null){
			System.debug('adding account ' + sur.Account__c);
			setOfAccounts.add(sur.Account__c);
			System.debug('Set of Accounts Is Empty: ' + setOfAccounts.isEmpty());
			}
		}
		
		List<Survey__c> listofSurveys = [SELECT ID, Case__c, Account__c, Total_Score__c from Survey__c WHERE Case__r.Status = 'Closed'
			AND Account__c IN: setOfAccounts AND CreatedDate = LAST_N_DAYS:180];
		
		List<Account> listOfAccountsToProcess = [SELECT ID, Customer_Health_Trans_Survey_Score__c from Account where ID IN: setOfAccounts];
		
		if(listOfAccountsToProcess != null){
			System.debug('Account to process TRUE');
		for(Account a : listOfAccountsToProcess){
			System.debug('Entering the innerest loop');
			averageNumerator = 0.0;
			averageDenominator = 0.0;
			average = 0.0;
			for(Survey__c ctsur : listOfSurveys){
				System.debug('ctsur account: ' + ctsur.account__c);
				System.debug('a.ID ' + a.ID);
				if(ctsur.Account__c == a.ID){
					averageNumerator = averageNumerator + ctsur.total_score__c;
					averageDenominator = averageDenominator + 1;
				}
			}
			if(averageDenominator > 0){
				average = averageNumerator/averageDenominator;
			}
			a.Customer_Health_Trans_Survey_Score__c = average;
			listOfAccountsToUpdate.add(a);
		}
		
		if(listOfAccountsToUpdate.isEmpty() == false){
			update listOfAccountsToUpdate;
		}
		}
	}
	
	public static void populateCustomerHealthFields(List<Account> newTrig, Map<ID, Account> oldTrig){
		//if No_Of_Scoring_Subscriptions > 0 AND No_of_scoring_subscriptions was 0/null
	
		Set<ID> setofAccountIDs = new Set<ID>();
		Double tempDate;
		Double comparisonDate;
		Boolean corePlan;
		Map<ID, Account> listOfAccountsToUpdate = new Map<ID, Account>();
		Set<String> id15s = new Set<String>();
		Double averageNumerator;
		Double averageDenominator;
		Double average;
		Double totalARR;
		Double daysBetween;
		Double numOfDaysBetween;
		Double comparisonValue;
		Date todaysDate;
		 
		for(Account a : newTrig){
			setOfAccountIDs.add(a.Id);
			id15s.add(convert18to15(a.ID));	
			system.debug('ID added to set: ' + a.ID);	
		}
		
		List<Account> listofAccounts = [Select id, No_Of_Active_Scoring_Subscription__c, Customer_Health_of_Case_Escalations__c, Customer_Health_Legacy_EOL_Platform__c,
			Total_On_Air_Units__c, Customer_Health_Total_On_Air_Units__c, Customer_Health_Total_On_Air_Units_Last__c from Account where id in: setOfAccountIDs];
		system.debug('Size of Account list: ' + listOfAccounts.size());
		List<Contract> listOfContracts = [SELECT id, accountID, EndDate from Contract where accountID IN: setOfAccountIDs and Term_Type__c = 'Fixed' AND Record_type__c = 'Customer Agreement' AND Status = 'Active' AND Agreement_Type__c = 'Master' AND EndDate = NEXT_N_YEARS:10];
		system.debug('Size of Contracts list: ' + listOfContracts.size());
		List<Case> listOfCases = [Select ID, accountID, IsEscalated, status from Case where AccountID IN: SetofAccountIDs and status != 'Closed'];
		system.debug('Size of Case list: ' + listOfCases.size());
		List<Asset__c> listOfAssets = [Select ID, account_ID__c, Maintenance_Status__c, Name, ARR__c from Asset__c where account_ID__c IN: setOfAccountIDs or account_ID__c IN: id15s];
		system.debug('Size of Asset list: ' + listOfAssets.size());
		List<Survey__c> listOfSurveys = [Select ID, Account__c, Total_Score__c from Survey__c where Account__c IN: setOfAccountIDs or Account__c IN: id15s];
		system.debug('Size of Transactional Survey list: ' + listOfSurveys.size());
		
		//FIELDS TO POPULATE
		//QUERIES: Contracts, Cases, Assets, Clicktools Surveys, TIMBASurveys
		for(Account a : listOfAccounts){
		Account oldAccount = oldTrig.get(a.ID);
		if(a.No_Of_Active_Scoring_Subscription__c > 0 && (oldAccount.No_Of_Active_Scoring_Subscription__c == 0 || oldAccount.No_Of_Active_Scoring_Subscription__c == null))
		{
		/////ON AIR DELTA INIT
		if(a.Customer_Health_Total_On_Air_Units__c != null){
			a.customer_health_total_on_air_units_last__c = a.customer_health_total_on_air_units__c;
			a.customer_health_total_on_air_units__c = a.total_on_air_units__c;
		}
		else{
			a.Customer_Health_Total_On_Air_Units__c = a.Total_On_Air_Units__c;
			a.customer_health_total_on_air_units_last__c = 0;
		}

		
		system.debug('Old Account: ' + oldAccount.ID);
		system.debug('New Account No of Subs: ' + a.No_Of_Active_Scoring_Subscription__c + ' -- Old Account No of Subs: ' + oldAccount.No_Of_Active_Scoring_Subscription__c);
			
			system.debug('Before Contract Loop');
			todaysDate = Date.today();
			system.debug('Todays date: ' + todaysDate);
			
			if(listOfContracts.isEmpty() == false){
			for(Contract c : listOfContracts){
				system.debug('Entered Contract loop');
				if(c.EndDate != null && c.AccountID == a.ID){
                    if(c.EndDate < Date.Today()){
                        
                    }
                    else{
                    numofDaysBetween = todaysDate.daysBetween(c.EndDate);
                    system.debug('Contract end date: ' + c.endDate);
                    system.debug('Num of Days Between: ' + numofDaysBetween);
                    //numOfDaysBetween = numOfDaysBetween;
                    System.debug('Number of Days Between: ' + (Date)todaysDate + ' - ' + numOfDaysBetween);
                    System.debug('Current account: ' + a.ID);
                if(a.Customer_Health_ofDaystoContractTerm__c == 0.0 || a.Customer_Health_ofDaysToContractTerm__c == null){
                    System.debug('In #ofdays = 0 or null');
                    //usedAccountIDs.add(c.accountID);
                    a.Customer_Health_ofDaystoContractTerm__c = numOfDaysBetween;
                    a.Customer_Health_ofDaysToContractTerm__c = math.abs(a.Customer_Health_ofDaysToContractTerm__c);
                    System.debug('Account value : ' + numOfDaysBetween + ' ' + a.Customer_Health_ofDaystoContractTerm__c);
                    //a.TEST_CH_Nearest_Renewal_Contract_ID__c = c.ID;
                }
                else{
                    System.debug('Days detected: Checking and updating.');
                    //a.TEST_CH_Nearest_Renewal_Contract_ID__c = c.ID;
                    comparisonValue = a.Customer_Health_ofDaystoContractTerm__c;
                    if(comparisonValue < numofDaysBetween){
                    	//usedAccountIDs.add(c.accountID);
                        //a.TEST_CH_Nearest_Renewal_Contract_ID__c = c.ID;
                        a.Customer_Health_ofDaystoContractTerm__c = numOfDaysBetween;
                        a.Customer_Health_ofDaysToContractTerm__c = math.abs(a.Customer_Health_ofDaysToContractTerm__c);
                        System.debug('Account value: ' + numOfDaysBetween + ' ' + a.Customer_Health_ofDaystoContractTerm__c);
                        }
                    
                    }
                }
			}
			}
			}
			a.Customer_Health_of_case_Escalations__c = 0;
			system.debug('Before Case loop.');
			if(listOfCases.isEmpty() == false){
			for(Case cas : listOfCases){
				system.debug('Entered case loop');
				if(a.Id == cas.AccountID){
					system.debug('matched Case Account to Account in list');
					if(cas.IsEscalated == True){
						system.debug('Case escalated is true.');
						//if(a.Customer_Health_of_case_escalations__c == null){
							//system.debug('Case Escalations is null, one was detected. Increment to 1');
							//a.Customer_Health_of_case_escalations__c = 1;
							//}
						//else{
							system.debug('Case Escalations: ' + a.Customer_Health_of_Case_Escalations__c);
							a.Customer_Health_of_Case_Escalations__c = a.Customer_health_of_Case_escalations__c + 1;
							system.debug('Case Escalations post-increment: ' + a.Customer_Health_of_Case_Escalations__c);
						//}
					//
					//
					//
				}
			 }
			}
			}
			system.debug('Exited Case loop, Pre Asset loop');
			totalARR = 0.0;
			a.Customer_Health_Total_ARR__c = 0.0;
			if(listOfAssets != null){
			for(Asset__c currasset : listOfAssets){
				system.debug('Entering asset loop.');
				String string1;
				String comparisonString;
				if(a.ID == currasset.Account_ID__c){
					system.debug('matched account ID to assets Account ID');
					string1 = currasset.Name;
					comparisonString = string1.toLowerCase(currasset.Name);
					system.debug('Comparison String: ' + comparisonString);
					if(currasset.Maintenance_Status__c != 'Decommissioned'){
						if(currAsset.ARR__c != null){
						a.Customer_Health_Total_ARR__c = a.Customer_Health_Total_ARR__c + currasset.ARR__c;
						}
						system.debug('Assets maintenance status is not decomissioned.');
						if(comparisonString.contains('xatanet') || comparisonString.contains('Java')){
							system.debug('string contains Xatanet or Java somewhere');
							a.Customer_Health_Legacy_EOL_Platform__c = true;
							system.debug('Set Legacy/EOL Platform to true: Value is ' + a.Customer_Health_Legacy_EOL_Platform__c);
							}
					}
				}
			}
			}
			averageNumerator = 0.0;
			averageDenominator = 0.0;
			average = 0.0;
			
			if(listOfSurveys.isEmpty() == false){
			for(Survey__c ctsur : listOfSurveys){
				System.debug('ctsur account: ' + ctsur.account__c);
				System.debug('a.ID ' + a.ID);
				if(ctsur.Account__c == a.ID){
					if(ctsur.total_score__c != null){
					system.debug('Average Numerator: ' + averageNumerator);
					system.debug('Total Score: ' + ctsur.total_score__c);
					
					averageNumerator = averageNumerator + ctsur.total_score__c;
					averageDenominator = averageDenominator + 1;
					}
				}
			
			if(averageDenominator > 0){
				average = averageNumerator/averageDenominator;
			}
			a.Customer_Health_Trans_Survey_Score__c = average;
			}
			}
			system.debug('Place Account ' + a.ID + ' in map values to update.');
			listOfAccountsToUpdate.put(a.id, a);
		
		}
		//Num Of Case Escalations
		//Legacy/EOL Platform - SELECT 
		//# of days to contract termination
		//Trans Survey
		//NPS
		//Core Plan Only
		
		
		}
		system.debug('Update everything in the values, this is post Account loop.');
		if(listOfAccountsToUpdate.isEmpty() == false) update listOfAccountsToUpdate.values();
	}
				
		
	}