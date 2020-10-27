public class CreateCompKnowledgeObjectExtension
{
 private Competitive_Knowledge__c  compKnowledge;

 public CreateCompKnowledgeObjectExtension(ApexPages.standardController scontroller)
 {
  compKnowledge = (Competitive_Knowledge__c )(scontroller.getRecord()); 
 }
 
 public pageReference saveCompKnowledge()
 {
  try{
      insert compKnowledge;  
  }
  catch(exception e)
  {       
       compKnowledge.addError(e.getMessage());
       return null;
  }
  System.debug('********* compKnowledge.Lead__c' + compKnowledge.Lead__c);
   System.debug('********* compKnowledge.Account__c ' + compKnowledge.Account__c );
  PageReference pg ;
  if(compKnowledge.Lead__c != null && (compKnowledge.Lead__c+ '') != '')
  pg = new PageReference ('/'+compKnowledge.Lead__c);
  else if (compKnowledge.Account__c != null && (compKnowledge.Account__c  + '') != '')
  pg = new PageReference ('/'+compKnowledge.Account__c );
  
  System.debug('********* pg  ' + pg  );
  
  return pg;
  
 }
 
 
 
}