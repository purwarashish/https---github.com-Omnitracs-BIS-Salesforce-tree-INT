public with sharing class BatchCustomerHealthNPSScore implements database.batchable<sobject>{
	
	public string query;
	
	public void BatchCustomerHealthNPSScore(){
		//Also take SurveyQuestion where SurveyQuestion == a2y50000000QPHMAA4
		query = 'SELECT ID, Account__c, CreatedDate, Response_1_Value__c, Main_Survey__c, Survey_Type__c FROM Customer_Survey__c WHERE Main_Survey__c = true AND Survey_Type__c = \'NPS\' AND Response_1__c != \'\' AND CreatedDate = LAST_N_MONTHS:3';
	}
	
	public database.querylocator start(database.batchableContext bc){
		//return database.getquerylocator('SELECT ID, TIMBASURVEYS__Recipient__c, TIMBASURVEYS__StringResponse__c, TIMBASURVEYS__SurveyQuestion__c from TIMBASURVEYS__SurveyResponse__c');
		return database.getquerylocator('SELECT ID, Account__c, CreatedDate, Response_1_Value__c, Main_Survey__c, Survey_Type__c FROM Customer_Survey__c WHERE Main_Survey__c = true AND Survey_Type__c = \'NPS\' AND Response_1__c != \'\'');
		
	}
	
	public void execute(Database.BatchableContext BC, list<sObject> scope){
		
		List<Account> listOfAccounts = [SELECT ID, Customer_Health_NPS_Score__c, No_Of_Active_Scoring_Subscription__c from Account where No_of_Active_Scoring_Subscription__c > 0];	
		List<Account> listOfAccountsToUpdate = new List<Account>();
				
		for(Account a : listOfAccounts){
			for(sobject s : scope){
				Customer_Survey__c sr = (Customer_Survey__c)s;
				if(a.ID == sr.Account__c){
					if(sr.response_1_value__c != null){
						a.Customer_Health_NPS_Score__c = sr.Response_1_Value__c;
						listOfAccountsToUpdate.add(a);
					}
				}
			
			}
		}
		
		if(listOfAccountsToUpdate != null){
    		update listOfAccountsToUpdate;
    	}
		
	}	
	
		/*List<ID> usedSurveyResponses = new List<ID>();
		List<ID> usedSurveyRecipients = new List<ID>();
		List<ID> usedAccounts = new List<ID>();
		//List<ID> usedSurveyQuestions = new List<ID>();
		List<Account> listOfAccountsToUpdate = new List<Account>();
		
		Map<ID, Double> recToResponseMap = new Map<ID, Double>();
		Map<ID, TIMBASURVEYS__Recipient__c> recToAccountMap = new Map<ID, TIMBASURVEYS__Recipient__c>();
		Map<ID, ID> recToQuestionMap;
		
		Double testVar;
		
		List<TIMBASURVEYS__SurveyQuestion__c> listOfQuestions = [SELECT ID, TIMBASURVEYS__Question2__c from TIMBASURVEYS__SurveyQuestion__c];
		Set<ID> listOfRatings = new Set<ID>();
		util.debug('Responses should have been queried.  Number passed into this method: ' + scope == null ? 0 : scope.size());
		system.debug('At the survey list of questions loop.');
    	for(TIMBASURVEYS__SurveyQuestion__c sur : listOfQuestions){
    		system.debug('inside survey questions loop.');
    		if(sur.TIMBASURVEYS__Question2__c == 'Rating'){
    			
    			system.debug('current survey question: ' + sur);
    			listOfRatings.add(sur.ID);
    		}
    	}
    	
		for(Sobject s : scope){
    			TIMBASURVEYS__SurveyResponse__c sr = (TIMBASURVEYS__SurveyResponse__c)s;
    			system.debug('Current sobject in scope: ' + s.ID);
    			system.debug('Current survey response: ' + sr.ID);
    			if(listOfRatings.contains(sr.TIMBASURVEYS__SurveyQuestion__c)){ 
	    			usedSurveyResponses.add(sr.ID);
	    			system.debug('Used Survey Response: ' + sr.ID);
	    			
	    			//usedSurveyQuestions.add(sr.TIMBASURVEYS__SurveyQuestion__c);
	    			
	    			//system.debug('Used Survey Question: ' + sr.TIMBASURVEYS__SurveyQuestion__c);
	    			usedSurveyRecipients.add(sr.TIMBASURVEYS__Recipient__c);
	    			
	    			system.debug('Used Survey Recipient: ' + sr.TIMBASURVEYS__Recipient__c);
	    			testVar = extractNumberValueFromResponse(sr.TIMBASURVEYS__StringResponse__c);
	    			system.debug('Test var: ' + testVar);
	    			if(testVar != null){
	    				recToResponseMap.put(sr.TIMBASURVEYS__Recipient__c, testVar);
	    				}
    			}
    		}
    		
    	
    	
    	
    	
    	List<TIMBASURVEYS__Recipient__c> listOfRecipients = [SELECT ID, TIMBASURVEYS__RelatedAccount__c from TIMBASURVEYS__Recipient__c where ID IN: usedSurveyRecipients];
    	
    	
    	system.debug('Post Survey Questions loop, entering Recipient loop.');
    	for(TIMBASURVEYS__Recipient__c rec : listOfRecipients){
    		usedAccounts.add(rec.TIMBASURVEYS__RelatedAccount__c);
    		system.debug('Recipient ID: ' + rec);
    		system.debug('Related Account: ' + rec.TIMBASURVEYS__RelatedAccount__c);
    		recToAccountMap.put(rec.TIMBASURVEYS__RelatedAccount__c, rec);	
    	}
    	system.debug('List of Recipients populated.');
    	List<Account> listOfAccounts = [SELECT ID, Customer_Health_NPS_Score__c, No_Of_Active_Scoring_Subscription__c from Account where ID IN: recToAccountMap.keySet() and No_of_Active_Scoring_Subscription__c > 0];
    	
    	for(Account a : listOfAccounts){
    		system.debug('Entered final loop of accounts to populate.');
    			for(TIMBASURVEYS__Recipient__c rtoa : recToAccountMap.values()){
    				system.debug('Entered nested loop of recipients to accounts map.');
    				if(rtoa.TIMBASURVEYS__RelatedAccount__c == a.id){
    					a.Customer_Health_NPS_Score__c = recToResponseMap.get(rtoa.id);
    					system.debug('Retrieved response: ' + recToResponseMap.get(rtoa.id));
    					system.debug('Response in Account: ' + a.Customer_Health_NPS_Score__c);
    					//if(a.No_Of_Active_Subscriptions__c != null && a.No_Of_active_Subscriptions__c >0)
    					listOfAccountsToUpdate.add(a);
    					
    				}
    			}
    	}
    	if(listOfAccountsToUpdate != null){
    		update listOfAccountsToUpdate;
    	}
	}
	*/
	public void finish(database.batchablecontext bc){
		
	}
	
	public static Double extractNumberValueFromResponse(String stringResponse){
		Double responseToReturn;
		
		//system.debug('In ExtractNumberFromString method, returning: ' + responseToReturn);
		if(stringResponse == '0' || stringResponse == '1' || stringResponse == '2' || stringResponse == '3' || stringResponse == '4' || stringResponse == '5' || stringResponse == '6' || 
			stringResponse == '7' || stringResponse == '8' || stringResponse == '9' || stringResponse == '10'){
				system.debug('String is number, time to convert: ' + Double.valueOf(stringResponse));
				responseToReturn = Double.valueOf(stringResponse);
				return responseToReturn;
			}
		else return null;
	}
    
}