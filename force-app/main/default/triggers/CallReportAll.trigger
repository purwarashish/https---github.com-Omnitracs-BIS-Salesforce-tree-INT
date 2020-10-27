trigger CallReportAll on Call_Report__c (before insert, before update, after insert, after update) {

List<Call_Report__c> callReportsWithCompetitorInfo = new List<Call_Report__c>();

    /*for(Call_Report__c c: trigger.new)
    {
     
      if(c.Competitor_Name__c != null)
      {       
       callReportsWithCompetitorInfo.add(c);
      }
      else{
       if(c.Competitor_Product_Name__c != null || c.Next_Steps__c!= null || c.Next_Steps_Date__c!= null || c.Satisfaction_Level__c!= null
         || c.Competitor_Mobile_Com_Units__c != null || c.Expected_Competitor_Contract_Expiration__c!= null || c.Comments__c!= null)
         {
        c.Competitor_Name__c.addError('Competitor Name is mandatory if you are entering competitive knowledge.');
       }
      }
     
    }*/
    
    //call method for competitor information validation (Author: Sai Krishna Kakani, Date: 09/11/2018)
        
        if(Trigger.isupdate){
        if(Trigger.isbefore && CheckRecursiveAfter.runOnce() && userinfo.getUserId()!=Label.S2S_User_Id){
             validateCallReportCompetitor validateCallReportCompetitorObj = new  validateCallReportCompetitor();
             validateCallReportCompetitorObj.CRVal (Trigger.newMap, Trigger.oldMap);
      }
     }
    
/*if(trigger.isAfter && Trigger.isInsert)
 {
     List<Competitive_Knowledge__c > listOfCompetitors = new  List<Competitive_Knowledge__c >();
     for(Call_Report__c callRep: callReportsWithCompetitorInfo)
     {
      Competitive_Knowledge__c compKnow = new Competitive_Knowledge__c();
      compKnow.Account__c = callRep.Account__c;
      compKnow.Competitor_Company_Name__c = callRep.Competitor_Company_Name__c ;
      compKnow.Competitor_Name__c = callRep.Competitor_Name__c ;
      compKnow.Competitor_Product_Name__c = callRep.Competitor_Product_Name__c ;
      compKnow.Next_Steps__c= callRep.Next_Steps__c;
      compKnow.Next_Steps_Date__c= callRep.Next_Steps_Date__c;
      compKnow.Satisfaction_Level__c= callRep.Satisfaction_Level__c;
      compKnow.Competitor_Mobile_Com_Units__c = callRep.Competitor_Mobile_Com_Units__c ;
      compKnow.Expected_Competitor_Contract_Expiration__c= callRep.Expected_Competitor_Contract_Expiration__c;
      compKnow.Comments__c= callRep.Comments__c ;
      compKnow.call_report__c = callRep.id;
      listOfCompetitors.add(compKnow);      
     }
     insert listOfCompetitors;
 }
 
 if(trigger.isAfter && Trigger.isUpdate)
 {
     List<Competitive_Knowledge__c > listOfCompetitors = new  List<Competitive_Knowledge__c >();     
     
     Map<Id,Competitive_Knowledge__c> mapOfCallReportIdToCompKnowledge = new Map<Id,Competitive_Knowledge__c>();
     
     for(Competitive_Knowledge__c comp : [Select id, call_report__c from Competitive_Knowledge__c where call_report__c IN: Trigger.newmap.keySet()])
     {
     mapOfCallReportIdToCompKnowledge.put(comp.call_report__c, comp);
     }
     
     for(Call_Report__c callRep: callReportsWithCompetitorInfo)
     {
     Call_Report__c callRepOld = trigger.OldMap.get(callRep.id);
     if(callRep.Competitor_Product_Name__c != callRepOld.Competitor_Product_Name__c 
        || callRep.Next_Steps__c!= callRepOld.Next_Steps__c
        || callRep.Next_Steps_Date__c!= callRepOld.Next_Steps_Date__c
        || callRep.Satisfaction_Level__c!= callRepOld.Satisfaction_Level__c
        || callRep.Competitor_Mobile_Com_Units__c != callRepOld.Competitor_Mobile_Com_Units__c 
        || callRep.Expected_Competitor_Contract_Expiration__c!= callRepOld.Expected_Competitor_Contract_Expiration__c
        || callRep.Comments__c!= callRepOld.Comments__c)
        {
        
         Competitive_Knowledge__c compKnow = new Competitive_Knowledge__c();
          compKnow.Account__c = callRep.Account__c;
          compKnow.Competitor_Company_Name__c = callRep.Competitor_Company_Name__c ;
          compKnow.Competitor_Name__c = callRep.Competitor_Name__c ;
          compKnow.Competitor_Product_Name__c = callRep.Competitor_Product_Name__c ;
          compKnow.Next_Steps__c= callRep.Next_Steps__c;
          compKnow.Next_Steps_Date__c= callRep.Next_Steps_Date__c;
          compKnow.Satisfaction_Level__c= callRep.Satisfaction_Level__c;
          compKnow.Competitor_Mobile_Com_Units__c = callRep.Competitor_Mobile_Com_Units__c ;
          compKnow.Expected_Competitor_Contract_Expiration__c= callRep.Expected_Competitor_Contract_Expiration__c;
          compKnow.Comments__c= callRep.Comments__c ;
          compKnow.call_report__c = callRep.id;
         
         if(mapOfCallReportIdToCompKnowledge.containsKey(callRep.id))
          compKnow.id = mapOfCallReportIdToCompKnowledge.get(callRep.id).id;
          
         listOfCompetitors.add(compKnow);
        }
     
     }
     upsert listOfCompetitors;
 }*/

}