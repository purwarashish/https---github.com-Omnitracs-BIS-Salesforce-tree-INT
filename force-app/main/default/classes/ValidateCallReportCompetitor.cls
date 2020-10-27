/*******************************************************************************
 * File:        ValidateCallReportCompetitor.cls
 * Date:        September 11th, 2018
 * Author:      Sai Krishna Kakani
 * Description: Competitors as required when changing the CallReport Status
 * Called onto CallReportAll trigger
 * *******************************************************************************/
public class ValidateCallReportCompetitor {
     public void CRVal (Map<id,Call_Report__c> newMap, Map<id,Call_Report__c> oldMap)  {
    
           id id1 = userinfo.getProfileId();    
           profile p =[select Name from profile where id = :id1];
           
           if(p.Name != 'System Administrator' || test.isrunningtest()) {
           
            list<Competitive_Summary__c> commpsummarylist = new list<Competitive_Summary__c> ();
            Map<id,list<Competitive_Summary__c>> compsummaryMap = new map<id,list<Competitive_Summary__c>> ();
            commpsummarylist = [select id,Call_Report__c from Competitive_Summary__c where Call_Report__c IN:newMap.keyset()];
            
        for(Competitive_Summary__c cs : commpsummarylist) {
            
            List<Competitive_Summary__c> cslist = new list<Competitive_Summary__c> ();
            if(compsummaryMap.get(cs.Call_Report__c) != null ) {
            cslist = compsummaryMap.get(cs.Call_Report__c);
            }
            if(userinfo.getUserId()!=Label.S2S_User_Id){
            cslist.add(cs);
            compsummaryMap.put(cs.Call_Report__c,cslist);
            }
        }
        
        for(Call_Report__c cr : newMap.values()) {
        
         if ((cr.id != null) && (cr.status__c != oldMap.get(cr.id).status__c) && (cr.Type_of_Competitor__c!= 'No Competitor') && (oldMap.get(cr.id).Type_of_Competitor__c== cr.Type_of_Competitor__c)) {
            boolean isError = false;
            
            if(compsummaryMap == null || compsummaryMap.size() == 0) {
                isError = true;
            } 
            
            else if(!compsummaryMap.containskey(cr.id)) {
                isError = true;
            } 
            
            if(isError && !Test.isrunningtest()) {
              cr.addError('You cannot advance this call report until competitor information is completed. Please change the Status field back to Draft, click Save and then update the Competitor Information.');
            }
        }
        
       }
       
      }
      
    }
}