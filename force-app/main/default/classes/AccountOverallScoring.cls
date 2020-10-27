/*********************************************************************************
* Name: AccountOverallScoring
* Created by Yogesh (Feuji) {DateCreated 6/9/2016} 
----------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This class is used as controller class for VF AccountOverallScoring
----------------------------------------------------------------------------------
* Unit Test: TestAccountOverallScoring
---------------------------------------------------------------------------------- 
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Yogesh (Feuji) 6/9/2016 INITIAL DEVELOPMENT
 
*********************************************************************************/
 
 public with sharing class AccountOverallScoring{
    
    public Account CurrentAccount{get;set;}
    
    public List<Account_Scoring__c> listAccountScoring {get;set;}
    
    public boolean isManualScoring {get;set;}
    public string  SelectedAccountScoringId {get;set;}
    public Account_Scoring__c CurrentAccountScoring {get;set;}
    
    public AccountOverallScoring(ApexPages.StandardController stdController){
    	CurrentAccount = new Account();
    	listAccountScoring = new List<Account_Scoring__c>();
    	CurrentAccountScoring = new Account_Scoring__c();
    	
    	// fetch current account
    	if(System.currentPageReference().getParameters().get('id') != null){
    		for(Account a : [Select Id, Name From Account Where Id = : System.currentPageReference().getParameters().get('id')]){
    			CurrentAccount = a;
    		}   		
    	}
    	
    	DoLoad();
    }
    
    public void DoLoad(){
    	// fetch all account scoring records
    	
    	SET<ID> setSM = new SET<ID>();
    	for(Scoring_Subscription__c ss: [Select Id,Scoring_Model__c From Scoring_Subscription__c Where Account__c=: CurrentAccount.Id AND Subscription_Status__c = 'Active' AND Scoring_Model__c != null]){
    		setSM.add(ss.Scoring_Model__c);
    	}
    	 
    	listAccountScoring = [Select Id,Name, Scoring_Model__c, Manual_Display_Type__c,Date_Manual_Scoring__c,Is_Manual_Scoring__c,Aggregate_Score__c, Manual_Score__c, Manual_Scoring_Reason__c, Manual_Scoring_Comments__c, Date__c, Display_Type__c,Overall_Calculated_Score__c 
    							From Account_Scoring__c Where Scoring_Model_ID__c IN: setSM AND Account__c = : CurrentAccount.Id AND History__c = false Order By Scoring_Model__c limit 1000 ];
    	
    }
    
    public PageReference ManualScoring(){
    	isManualScoring = true;
    	CurrentAccountScoring = new Account_Scoring__c();
    	if(SelectedAccountScoringId != null){
    		for(Account_Scoring__c s:  [Select Id,Name, Scoring_Model__c,Manual_Display_Type__c,Date_Manual_Scoring__c,Aggregate_Score__c, Is_Manual_Scoring__c, Manual_Score__c, Manual_Scoring_Reason__c, Manual_Scoring_Comments__c, Date__c, Display_Type__c,Overall_Calculated_Score__c From Account_Scoring__c Where Id = : SelectedAccountScoringId ]){
    			CurrentAccountScoring = s;
    			if(CurrentAccountScoring.Is_Manual_Scoring__c == false){
    				CurrentAccountScoring.Is_Manual_Scoring__c = true;
    			}
    		}
    	}
    	return null;
    }
    
    public PageReference ManualScoringDisable(){
    	CurrentAccountScoring = new Account_Scoring__c();
    	if(SelectedAccountScoringId != null){
    		for(Account_Scoring__c s:  [Select Id,Name, Scoring_Model__c,Manual_Display_Type__c,Date_Manual_Scoring__c,Aggregate_Score__c, Is_Manual_Scoring__c, Manual_Score__c, Manual_Scoring_Reason__c, Manual_Scoring_Comments__c, Date__c, Display_Type__c,Overall_Calculated_Score__c From Account_Scoring__c Where Id = : SelectedAccountScoringId ]){
    			CurrentAccountScoring = s;
    			CurrentAccountScoring.Is_Manual_Scoring__c = false;
    		}
    		update CurrentAccountScoring;
    	}
    	DoLoad();
    	isManualScoring = false;
    	return null;
    }
    
    
    public PageReference DoCancel(){
    	isManualScoring = false;
    	return null;
    }
    
    public PageReference DoSave(){
    	PageReference pr = null;
    	try{
    		// update account for manual scoring
    		if(CurrentAccountScoring.Is_Manual_Scoring__c == true){
    			CurrentAccountScoring.Date_Manual_Scoring__c = system.today();
    		}
    		update CurrentAccountScoring;
    		DoLoad();
    		isManualScoring = false;
    	}
    	catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
    	}
    	return null;
    }
    
    
}