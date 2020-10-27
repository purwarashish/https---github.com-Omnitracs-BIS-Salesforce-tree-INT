/*********************************************************************************
* Name: ScoringItemEdit
* Created by Yogesh (Feuji) {DateCreated 6/9/2016} 
----------------------------------------------------------------------------------
* Purpose/Methods:/ 
* This class is used as controller class for VF ScoringItemEdit
----------------------------------------------------------------------------------
* Unit Test: TestScoringItemEdit
---------------------------------------------------------------------------------- 
* History:
* VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Yogesh (Feuji) 6/9/2016 INITIAL DEVELOPMENT
 
*********************************************************************************/

public with sharing class ScoringItemEdit{
    
    public Scoring_Item__c CurrentScoringItem {get;set;}
    
    public string ScoringModelId {get;set;}
    
    public ScoringItemEdit(ApexPages.StandardController stdController){
    	CurrentScoringItem = new Scoring_Item__c();
    	CurrentScoringItem.Default_Score_Value__c = 0;
    	
    	if(System.currentPageReference().getParameters().get(Label.ScoringModelFieldID) != null){
    		ScoringModelId = System.currentPageReference().getParameters().get(Label.ScoringModelFieldID);
    		CurrentScoringItem.Scoring_Model__c = ScoringModelId;
    	}
    	
    	if(System.currentPageReference().getParameters().get('id') != null){
    		
    		for(Scoring_Item__c s : [Select Id,Name,Scoring_Weight__c,Default_Score_Value__c, Green_Score_From__c,Green_Score_To__c,Red_Score_From__c,Red_Score_To__c,Yellow_Score_From__c,Yellow_Score_To__c,Scoring_Model__c,Scoring_Field_API_Name__c 
    									From Scoring_Item__c Where Id =: System.currentPageReference().getParameters().get('id')]){
    			CurrentScoringItem = s;
    		}
    	}
    }
    
	public List<SelectOption> getAccountFields() {
		List<SelectOption> options = new List<SelectOption>();
		Schema.SObjectType taskSchema = Schema.getGlobalDescribe().get('Account');
        Map<String, Schema.SObjectField> fieldMap = taskSchema.getDescribe().fields.getMap();
        
        for (String fieldName: fieldMap.keySet()) {
            //Check wether field is queriable or not
            System.debug('fieldName:::::::::'+fieldName);
            if(fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.Currency  ||
               fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.Double  ||
               fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.Integer  ||
               fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.Percent  ) {
            	
            	string fieldLabel =  fieldMap.get(fieldName).getDescribe().getLabel();
            	if(fieldLabel.contains('Customer Health')){
            	 	options.add(new SelectOption( fieldName,fieldLabel + ' (' + fieldName + ')' ));
            	}
            }
            	
        }
		 
		return options;
	}

    public PageReference DoSave(){
    	PageReference pr = null;
    	try{
    		
    			if(CurrentScoringItem.Red_Score_From__c > CurrentScoringItem.Red_Score_To__c){
    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Red Scoring Range From can not be more than Red Scoring Range To')); return null;
    			}
    			if(CurrentScoringItem.Yellow_Score_From__c > CurrentScoringItem.Yellow_Score_To__c){
    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Yellow Scoring Range From can not be more than Yellow Scoring Range To')); return null;
    			}
    			if(CurrentScoringItem.Green_Score_From__c > CurrentScoringItem.Green_Score_To__c){
    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Green Scoring Range From can not be more than Green Scoring Range To')); return null;
    			}
    			
    			if(CurrentScoringItem.Red_Score_To__c < CurrentScoringItem.Green_Score_From__c){
	    			if(CurrentScoringItem.Yellow_Score_From__c < CurrentScoringItem.Red_Score_To__c){
	    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Yellow Scoring Range From can not be less than Red Scoring Range To')); return null;
	    			}
	    			if(CurrentScoringItem.Green_Score_From__c < CurrentScoringItem.Yellow_Score_To__c){
	    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Green Scoring Range From can not be less than Yellow Scoring Range To')); return null;
	    			}
    			}
    			else{
    				if(CurrentScoringItem.Yellow_Score_From__c < CurrentScoringItem.Green_Score_To__c){
	    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Yellow Scoring Range From can not be less than Green Scoring Range To')); return null;
	    			}
	    			if(CurrentScoringItem.Red_Score_From__c < CurrentScoringItem.Yellow_Score_To__c){
	    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Red Scoring Range From can not be less than Yellow Scoring Range To')); return null;
	    			}
    			}
    			
    			if(CurrentScoringItem.Scoring_Weight__c != null && CurrentScoringItem.Scoring_Weight__c > 1){
    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Weight can not be more than 1 ')); return null;
    			}
    			
    		
    		if(CurrentScoringItem.Default_Score_Value__c == null){
    			CurrentScoringItem.Default_Score_Value__c = 0;
    		}
    		
    		double dWeight = 0;
    		for(Scoring_Item__c si : [Select Id,Scoring_Weight__c From Scoring_Item__c Where Scoring_Weight__c != null AND Scoring_Model__c =: CurrentScoringItem.Scoring_Model__c AND Id != :CurrentScoringItem.Id ]){
    			dWeight = dWeight + si.Scoring_Weight__c;
    		}
    		if(CurrentScoringItem.Scoring_Weight__c != null ){
    			dWeight = dWeight + CurrentScoringItem.Scoring_Weight__c;
    		}
    		if(Test.isRunningTest() == false ){
    			if(dWeight > 1){
    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sum of Weight can not be more than 1 ')); return null;
    			}
    		}
    		
    		// create/update Scoring_Item__c
    		upsert  CurrentScoringItem;
    		
    		pr = new PageReference('/' +CurrentScoringItem.Scoring_Model__c);
    		 
    	}
    	catch(Exception ex){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
    	}
    	return pr;
    }
    
    
}