public class Createx3rdPartyServiceExtension
{
 private X3rd_Party_Contract_Service__c x3rdPartyService;

 public Createx3rdPartyServiceExtension(ApexPages.standardController scontroller)
 {
  x3rdPartyService = (X3rd_Party_Contract_Service__c )(scontroller.getRecord()); 
 }
 
 public pageReference save3rdPartyService()
 {
  try{
      insert x3rdPartyService;  
  }
  catch(exception e)
  {       
       x3rdPartyService.addError(e.getMessage());
       return null;
  }
  System.debug('********* x3rdPartyService.Lead__c' + x3rdPartyService.Lead__c);
   System.debug('********* x3rdPartyService.Account__c ' + x3rdPartyService.Account__c );
  PageReference pg ;
  if(x3rdPartyService.Lead__c != null && (x3rdPartyService.Lead__c+ '') != '')
  pg = new PageReference ('/'+x3rdPartyService.Lead__c);
  else if (x3rdPartyService.Account__c != null && (x3rdPartyService.Account__c  + '') != '')
  pg = new PageReference ('/'+x3rdPartyService.Account__c );
  
  System.debug('********* pg  ' + pg  );
  
  return pg;
  
 }
 
 
 
}