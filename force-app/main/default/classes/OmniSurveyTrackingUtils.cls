public with sharing class OmniSurveyTrackingUtils{
	public static void createProjectSurveyTrackingObj(Map<Id, pse__proj__c> oldTrig, List<pse__proj__c> newTrig){
	List<Omni_Survey_Tracking__c> ostToInsert = new List<Omni_Survey_Tracking__c>();

	for(pse__proj__c proj : newTrig){
		pse__proj__c oldproj = oldTrig.get(proj.ID);
		//oldProj.send_survey_now__c == false && 
		if ((proj.send_survey_now__c == true && proj.Survey_Recipient__c != null)){
			Omni_Survey_Tracking__c ost = new Omni_Survey_Tracking__c();
			System.debug('Project Id: ' + proj.Id);
			ost.PS_Project__c = proj.Id;
			ost.Account__c = proj.pse__Account__c;
			ost.Subject_User__c = proj.Survey_Subject_User__c;
			ost.Initiated_By__c = proj.Survey_Initiated_By__c;
			ost.Contact__c = proj.Survey_Recipient__c;
			//ost.Survey_Type__c = proj.Type_of_Survey_to_Send__c;
			if(proj.Type_of_Survey_to_Send__c != null){
				String parseType1 = proj.Type_of_Survey_to_Send__c;
				String parseType2 = parseType1.replaceAll('\\s|-', '');
				ost.Survey_Type__c = parseType2;
			}
			//ost.Survey_Type__c = 'PSE';
			ost.Project_Manager__c = proj.pse__Project_Manager__c;
			ost.Project_Group__c = proj.pse__group__c;
			ost.Survey_Sent_Date__c = Date.Today();
			ostToInsert.add(ost);
			insert ostToInsert;
			
			proj.Omni_Survey_Tracking__c = ost.Id;
			}
		
		
		}
	}
	
	//Added 4/26 by Cody Worth
	//This method creates a survey tracking object
	public static void createContactSurveyTrackingObj(Map<Id, Contact> oldTrig, List<Contact> newTrig){
	//Omni_Survey_Tracking__c ostToInsert = new List<Omni_Survey_Tracking__c>();
	for(Contact con : newTrig){
		Contact oldContact = oldTrig.get(con.ID);
		
		if ((oldContact.survey_email_Sent__c == false && con.survey_email_sent__c == true)){
			Omni_Survey_Tracking__c ost = new Omni_Survey_Tracking__c();
			ost.Contact__c = con.Id;
			ost.Subject_User__c = con.Customer_Experience_Rep__c;
			if(con.Survey_Initiated_By__c == null){
				ost.Initiated_By__c = con.Customer_Experience_Rep__c;
			}
			else if(con.Survey_Initiated_By__c != null){
				ost.Initiated_By__c = con.Survey_Initiated_By__c;
			}
			ost.Survey_Type__c = 'CER';
			ost.Survey_Sent_Date__c = con.Survey_Sent_Date__c;
			
			insert ost;
			con.Survey_To_Tracking_Link__c = ost.Id;
		}
	}
}
}