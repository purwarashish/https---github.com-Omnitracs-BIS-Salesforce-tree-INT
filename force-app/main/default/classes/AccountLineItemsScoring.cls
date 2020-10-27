/*********************************************************************************
* Name: AccountLineItemsScoring
* Created by Yogesh (Feuji) {DateCreated 6/9/2016} 
----------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This class is used as controller class for VF AccountLineItemsScoring
----------------------------------------------------------------------------------
* Unit Test: TestAccountLineItemsScoring
---------------------------------------------------------------------------------- 
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Yogesh (Feuji) 6/9/2016 INITIAL DEVELOPMENT
 
*********************************************************************************/

public with sharing class AccountLineItemsScoring{
    
    public Account CurrentAccount{get;set;}
     
    public Account_Scoring__c CurrentScoring{get;set;}
    
    public List<Account_Scoring_Item__c> listScoringLines {get;set;}
    
    public string AccountScoringId {get;set;}
    
    public boolean isUpdateScoring {get;set;}
    
    public AccountLineItemsScoring( ){
    	
    	CurrentAccount = new Account();
    	CurrentScoring = new Account_Scoring__c();
    	listScoringLines = new List<Account_Scoring_Item__c>();
    	
    	// fetch current account scoring
    	if(System.currentPageReference().getParameters().get('id') != null){
    		for(Account_Scoring__c s : [Select Id, Name,Date_Manual_Scoring__c, Manual_Display_Type__c, Aggregate_Score__c,Manual_Scoring_Reason__c, Overall_Calculated_Score__c, Manual_Scoring_Comments__c,Is_Manual_Scoring__c,Manual_Score__c,Scoring_Model__c,Average_Score__c, Account__c,Date__c,Display_Type__c From Account_Scoring__c Where Id = : System.currentPageReference().getParameters().get('id')]){
    			CurrentScoring = s;
    			AccountScoringId = string.valueof(s.Account__c).substring(0,15);
    		}   		
    	}
    	
    	// associated account
    	for(Account a : [Select Id, Name From Account Where Id = : CurrentScoring.Account__c]){
			CurrentAccount = a;
		} 
		
		// fetch all scoring items
    	listScoringLines = [Select Id,Name, Scoring_Item__c, Scoring_Item_ID__r.Scoring_Weight__c, Score__c, Normalized_Score__c, Value__c, Display_Type__c From Account_Scoring_Item__c Where Account_Scoring__c = : CurrentScoring.Id  Order By Scoring_Item__c limit 1000 ];
    	
    }
    
    public PageReference BackToAccount(){
    	return new PageReference('/' + CurrentAccount.Id );
    }
    
    
}