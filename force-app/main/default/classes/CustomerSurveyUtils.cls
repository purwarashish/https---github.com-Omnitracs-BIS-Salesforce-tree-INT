public with sharing class CustomerSurveyUtils{
    public static void surveyToTracking(List<Customer_Survey__c> newTrig){
    for(Customer_Survey__c cs : newTrig){
        try{
        	if(cs.Survey_Type__c != 'NPS'){
        	Omni_Survey_Tracking__c relatedOst = [Select Id, Omni_Survey__c, Survey_Responded_To__c from Omni_Survey_Tracking__c where Id =: cs.Omni_Survey_Tracking__c LIMIT 1];
       		if(relatedost != null){
	        relatedOst.Survey_Responded_To__c = true;
	        relatedOst.Omni_Survey__c = cs.Id;
	        relatedOst.Completion_Date__c = Date.today();
	        relatedOst.Initiated_By__c = cs.Initiated_By__c;
	        
       		update relatedOst;
       		}
        }
        }
        catch(Exception e){
        	
        }
    }
        
       /* Set<Customer_Survey__c> surveysToUse = new Set<Customer_Survey__c>();
        List<Omni_Survey_Tracking__c> ostsToUpdate = new List<Omni_Survey_Tracking__c>();
        
    	for(Customer_Survey__c cs : newTrig){
    		surveysToUse.add(cs);
   	 }
   	 
   	 	List<Omni_Survey_Tracking__c> relatedOst = [Select Id, Omni_Survey__c, Survey_Responded_To__c from Omni_Survey_Tracking__c where Omni_Survey__c IN: surveysToUse];
   	 
   	 if(relatedOst.size() > 0){
	   	 for(Customer_Survey__c cs : surveysToUse){
	   	 	for(Omni_Survey_Tracking__c ost : relatedOst){
	   	 		if(cs.Omni_Survey_Tracking__c == ost.ID){
		   	 		ost.Survey_Responded_To__c = true;
			        ost.Omni_Survey__c = cs.Id;
			        ost.Completion_Date__c = Date.today();
			        ost.Initiated_By__c = cs.Initiated_By__c;
			        ostsToUpdate.add(ost);
   	 			}
   	 		}
   	 	}
   	 }
   	 	if(ostsToUpdate.size() > 0) {
   	 		update ostsToUpdate;
   	 		}
   	 		*/
    }
    
    public static void calculateAverageOfAverages(List<Customer_Survey__c> newTrig){
        Double totalSurveys;
        Double totalWeightedAverage = 0.0;
        
        for(Customer_Survey__c cs : newTrig){
            if(cs.Project__c != null){
            //if(cs.Weighted_Average__c != null){
               //totalWeightedAverage = cs.Weighted_Average__c;
            //}
            if(cs.Survey_Type__c == 'ODOnsiteTraining'){
                //For the survey that is updated, select all surveys related to that project of the same type - we are only updating the weighted average for a particular type.
                pse__proj__c currentProject = [SELECT Id, Average_for_OD_Onsite_Training__c FROM pse__proj__c WHERE ID =: cs.Project__c];
                List<Customer_Survey__c> surveysOnProject = [Select Id, Survey_Type__c, Project__c, Weighted_Average__c from Customer_Survey__c where Project__c =: currentProject.ID and Survey_Type__c = 'ODOnsiteTraining' and Weighted_Average__c != null];
                //Take the size of the surveys on the project. This will be used to divide and extract the average
                totalSurveys = surveysOnProject.size();
                System.debug('Number of surveys: ' + totalSurveys);
                for(Customer_Survey__c sop : surveysOnProject){
                //Loop and add all weighted averages together in the loop. We will divide post-loop.
                System.debug('Current weighted average: ' + totalWeightedAverage);
                totalWeightedAverage = totalWeightedAverage + sop.Weighted_Average__c;
                }
                //calculate the average of the weighted averages. total score / # of surveys.
                if(totalSurveys != null && totalSurveys > 0) {
                System.debug('Current weighted average: ' + totalWeightedAverage);
                    totalWeightedAverage = totalWeightedAverage/totalSurveys;
                }
                currentProject.Average_for_OD_Onsite_Training__c = totalWeightedAverage;
                update currentProject;
            }
            if(cs.Survey_Type__c == 'ODTrainingWebinar'){
                //For the survey that is updated, select all surveys related to that project of the same type - we are only updating the weighted average for a particular type.
                pse__proj__c currentProject = [SELECT Id, Average_for_OD_Training_Webinar__c FROM pse__proj__c WHERE ID =: cs.Project__c];
                List<Customer_Survey__c> surveysOnProject = [Select Id, Survey_Type__c, Project__c, Weighted_Average__c from Customer_Survey__c where Project__c =: currentProject.ID and Survey_Type__c = 'ODTrainingWebinar' and Weighted_Average__c != null];
                //Take the size of the surveys on the project. This will be used to divide and extract the average
                totalSurveys = surveysOnProject.size();
                System.debug('Number of surveys: ' + totalSurveys);
                for(Customer_Survey__c sop : surveysOnProject){
                //Loop and add all weighted averages together in the loop. We will divide post-loop.
                System.debug('Current weighted average: ' + totalWeightedAverage);
                totalWeightedAverage = totalWeightedAverage + sop.Weighted_Average__c;
                }
                //calculate the average of the weighted averages. total score / # of surveys.
                if(totalSurveys != null && totalSurveys > 0) {
                    System.debug('Current weighted average: ' + totalWeightedAverage);
                    totalWeightedAverage = totalWeightedAverage/totalSurveys;
                }
                currentProject.Average_for_OD_Training_Webinar__c = totalWeightedAverage;
                update currentProject;
            }
            if(cs.Survey_Type__c == 'ODPSProjectClosure'){
                //For the survey that is updated, select all surveys related to that project of the same type - we are only updating the weighted average for a particular type.
                pse__proj__c currentProject = [SELECT Id, Average_for_OD_PS_Project_Closure__c FROM pse__proj__c WHERE ID =: cs.Project__c];
                List<Customer_Survey__c> surveysOnProject = [Select Id, Survey_Type__c, Project__c, Weighted_Average__c from Customer_Survey__c where Project__c =: currentProject.ID and Survey_Type__c = 'ODPSProjectClosure' and Weighted_Average__c != null];
                //Take the size of the surveys on the project. This will be used to divide and extract the average
                totalSurveys = surveysOnProject.size();
                System.debug('Number of surveys: ' + totalSurveys);
                for(Customer_Survey__c sop : surveysOnProject){
                //Loop and add all weighted averages together in the loop. We will divide post-loop.
                totalWeightedAverage = totalWeightedAverage + sop.Weighted_Average__c;
                }
                //calculate the average of the weighted averages. total score / # of surveys.
                if(totalSurveys != null && totalSurveys > 0) {
                    totalWeightedAverage = totalWeightedAverage/totalSurveys;
                }
                currentProject.Average_for_OD_PS_Project_Closure__c = totalWeightedAverage;
                update currentProject;
         		   }
           		}
        	}
        }
    
    public static void createSurveyLog(List<Customer_Survey__c> newTrig){
    	List<Customer_Survey_Log__c> logsToInsert = new List<Customer_survey_Log__c>();
    	
    	for(Customer_Survey__c cs : newTrig){
    		if(cs.Survey_Type__c == 'NPS'){
				Customer_Survey_Log__c csl = new Customer_Survey_Log__c();
    			csl.Survey_Type__c = cs.Survey_Type__c;
    			csl.Survey_Initiated__c = cs.Survey_Initiated__c;
    			csl.Email_Opened__c = cs.Email_Opened__c;
    			csl.Account__c = cs.Account__c;
    			csl.Recipient_Contact__c = cs.Recipient_Contact__c;
    			csl.NPS_Wave__c = cs.NPS_Wave__c;
    			csl.Customer_Survey__c = cs.ID;
    			logsToInsert.add(csl);
    		}
    	}
    	
    	if(logsToInsert.size() > 0){
    		insert logsToInsert;
    	}
    }
    
    public static void NPSSurveyCompleted(List<Customer_Survey__c> newTrig){
    	List<Contact> contactsToUpdate = new List<Contact>();
    	List<ID> contactsToReference = new List<ID>();
    	
    	for(Customer_Survey__c cs : newTrig){
    		if(cs.Survey_Type__c == 'NPS' && cs.Survey_Initiated__c == 'Initiated'){
    			system.debug('Added contact ID: ' + cs.Recipient_Contact__c);
    			contactsToReference.add(cs.Recipient_Contact__c);		
    		}
    	}
    	
    	List<Contact> contactsToUse = [SELECT ID, Name, NPS_Survey_Completed__c FROM Contact where ID IN: contactsToReference];
    	for(Contact c : contactsToUse){
			System.debug('Contact being updated: ' + c.name + ' ID: ' + c.ID);
			if(!c.NPS_Survey_Completed__c){
				c.NPS_Survey_Completed__c = true;
				contactsToUpdate.add(c);
			}
		}
    	update contactsToUpdate;
    }
    
    public static void detectDuplicateSurveys(List<Customer_Survey__c> newTrig){
    	//
    	Set<ID> csIDsToUse = new Set<ID>();
    	Customer_Survey__c currentSurvey = new Customer_Survey__c();
    	List<Customer_survey__c> listOfSurveysToUpdate = new List<Customer_Survey__c>();
    	
    	
    	for(Customer_Survey__c cs : newTrig){
    		if(cs.Response_1__c != null){
    			csIDsToUse.add(cs.Recipient_Contact__c);
    		}	
    	}
    	
    
    	List<Customer_Survey__c> surveysLast30Days = [SELECT ID, Account__c, Main_Survey__c, Response_1__c, Response_9__c, Recipient_Contact__c, CreatedDate FROM Customer_Survey__c WHERE Recipient_Contact__C IN: csIDstoUse AND CreatedDate = LAST_N_DAYS:30 AND Main_Survey__c = true];
		
		if(surveysLast30Days.size() > 0){
			for(Customer_Survey__c surv : surveysLast30Days){
					surv.Main_Survey__c = false;
					listOfSurveysToUpdate.add(surv);
			}
		}
		
		if(listofSurveysToUpdate.size() > 0){
			update listOfSurveysToUpdate;
		}
		
		for(Customer_Survey__c sur : newTrig){
			if(sur.Response_1__c != null) {
				sur.Main_Survey__c = true;
			}
			//listOfSurveysToUpdate.add(sur);
		}
    	/*for(ID con : csIDsToUse){
    		for(Customer_Survey__c surv : surveysLast30Days){
    			if(surv.CreatedDate > currentSurvey.createdDate || currentSurvey == null){
	    			if(surv.Recipient_Contact__c == con){
	    				if(surv.Response_1__c != ''){
	    					currentSurvey = surv;
	    					//if(surv.Response_9__c != ''){
	    						//currentSurvey = surv;
	    					//}
	    				}
	    			}
    			}
    			if(currentSurvey != null){
	    			currentSurvey.main_survey__c = true;
	    			listOfSurveysToUpdate.add(currentSurvey);
    			}
    		}
    	}*/
    	
    	
    	
    	//if(listofSurveysToUpdate.size() > 0) update listOfSurveysToUpdate;
    	
    }
    

}