public class CSATSurveyUtils{
    
	public static void updateAvgCSATScore(List<Survey__c> svyList){
		boolean isCSATSurvey = false;
		Set<ID> acctIds = new Set<ID>();
        for(Survey__c svy : svyList){
			if(svy.Survey_Type__c == 'CSAT' && svy.Account__c != null)
				acctIds.add(svy.Account__c);
		}
		updateAvgCSATScore(acctIds);
	}
	
	public static void updateAvgCSATScore(List<Case> caseList, Map<Id, Case> oldCaseMap){
		Set<ID> acctIds = new Set<ID>();
        for(Case caseRec : caseList){
			if(caseRec.Not_CSAT_Eligible__c != oldCaseMap.get(caseRec.Id).Not_CSAT_Eligible__c)
				acctIds.add(caseRec.AccountId);
		}
		updateAvgCSATScore(acctIds);
	}
	
	public static void updateCSATSurveyAccount(List<Survey__c> svyList){
		for(Survey__c svy : svyList){
			if(svy.Survey_Type__c == 'CSAT')
				svy.CSAT_Account__c = svy.Account__c;
		}
	}
	
	public static void updateAvgCSATScore(Set<ID> acctIds){
        if(acctIds.size() > 0){
			List<Survey__c> custSrvyList = [select Account__c, Case__c, CreatedDate, Total_Score__c from Survey__c where Survey_Type__c = 'CSAT' AND Case__r.Not_CSAT_Eligible__c = FALSE AND CreatedDate >= Last_N_Months:12 AND Account__c in :acctIds Order By Account__c DESC, CreatedDate DESC];
			Map<Id, List<Survey__c>> objMap = new Map<Id, List<Survey__c>>();
			for(Survey__c survey : custSrvyList){
				Id acctId = survey.Account__c;
				if(!objMap.containsKey(acctId))
					objMap.put(acctId, new List<Survey__c>());
				objMap.get(acctId).add(survey);
			}
			List<Account> acctList = [select Id, Average_CSAT_Score__c from Account where Id in :acctIds];
			for(Account acct : acctList){
				List<Survey__c> csatSrvyList = objMap.get(acct.Id);
				Decimal total = 0.0;
				Integer count = 0;
				if(csatSrvyList != null && csatSrvyList.size() > 0){
					Datetime latestDate = csatSrvyList[0].CreatedDate;
					Integer month = latestDate.month();
					Integer year = latestDate.year();
					
					for(Survey__c survey : csatSrvyList){
						Datetime surveyDate = survey.CreatedDate;
						if(surveyDate.month() == month && surveyDate.year() == year && survey.Total_Score__c != null){
							total += survey.Total_Score__c;
							++count;
						}
					}
				}
				Decimal avg = total;
				if(total > 0)
					avg = (total/count).setScale(1);
				acct.Average_CSAT_Score__c = avg;
			}
			update acctList;
		}
    }
}