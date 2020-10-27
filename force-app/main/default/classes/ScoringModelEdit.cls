/*********************************************************************************
* Name: ScoringModelEdit
* Created by Yogesh (Feuji) {DateCreated 6/9/2016} 
----------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This class is used as controller class for VF ScoringModelEdit
----------------------------------------------------------------------------------
* Unit Test: TestScoringModelEdit
---------------------------------------------------------------------------------- 
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Yogesh (Feuji) 6/9/2016 INITIAL DEVELOPMENT
 
*********************************************************************************/

public with sharing class ScoringModelEdit{
    
    public Scoring_Model__c CurrentScoringModel {get;set;}
    
    public ScoringModelEdit(ApexPages.StandardController stdController){
    	CurrentScoringModel = new Scoring_Model__c();
    	
    	if(System.currentPageReference().getParameters().get('id') != null){
    		
    		for(Scoring_Model__c s : [Select Id,Name,Green_Overall_Score_From__c,Green_Overall_Score_To__c,Red_Overall_Score_From__c,Red_Overall_Score_To__c,Yellow_Overall_Score_From__c,Yellow_Overall_Score_To__c 
    									From Scoring_Model__c Where Id =: System.currentPageReference().getParameters().get('id')]){
    			CurrentScoringModel = s;
    		}
    	}
    }
    
    public PageReference DoSave(){
    	PageReference pr = null;
    	try{
    		
    			if(CurrentScoringModel.Red_Overall_Score_From__c > CurrentScoringModel.Red_Overall_Score_To__c){
    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Red Scoring Range From can not be more than Red Scoring Range To')); return null;
    			}
    			if(CurrentScoringModel.Yellow_Overall_Score_From__c > CurrentScoringModel.Yellow_Overall_Score_To__c){
    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Yellow Scoring Range From can not be more than Yellow Scoring Range To')); return null;
    			}
    			if(CurrentScoringModel.Green_Overall_Score_From__c > CurrentScoringModel.Green_Overall_Score_To__c){
    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Green Scoring Range From can not be more than Green Scoring Range To')); return null;
    			}
    			
    			if(CurrentScoringModel.Red_Overall_Score_To__c < CurrentScoringModel.Green_Overall_Score_From__c){
	    			if(CurrentScoringModel.Yellow_Overall_Score_From__c < CurrentScoringModel.Red_Overall_Score_To__c){
	    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Yellow Scoring Range From can not be less than Red Scoring Range To')); return null;
	    			}
	    			if(CurrentScoringModel.Green_Overall_Score_From__c < CurrentScoringModel.Yellow_Overall_Score_To__c){
	    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Green Scoring Range From can not be less than Yellow Scoring Range To')); return null;
	    			}
    			}
    			else{
    				if(CurrentScoringModel.Yellow_Overall_Score_From__c < CurrentScoringModel.Green_Overall_Score_To__c){
	    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Yellow Scoring Range From can not be less than Green Scoring Range To')); return null;
	    			}
	    			if(CurrentScoringModel.Red_Overall_Score_From__c < CurrentScoringModel.Yellow_Overall_Score_To__c){
	    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Red Scoring Range From can not be less than Yellow Scoring Range To')); return null;
	    			}
    			}
    			
    		
    		// create/update Scoring_Model__c
    		upsert  CurrentScoringModel;
    		
    		pr = new PageReference('/' + CurrentScoringModel.Id);
    		 
    	}
    	catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
    	}
    	return pr;
    }
    
    
}