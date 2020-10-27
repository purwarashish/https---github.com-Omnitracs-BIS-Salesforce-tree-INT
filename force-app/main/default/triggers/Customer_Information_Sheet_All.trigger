trigger Customer_Information_Sheet_All on Customer_Information_Sheet__c (before insert, before update) {
  
  //Query the partner portal record type
  List<RecordType> partnerRecordType=[select Id
                                           , Name
                                       from  RecordType
                                       where Name='Partner CIS'
                                       Limit 1
                                     ];
  
  for(Customer_Information_Sheet__c cis:Trigger.New){
     if(Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(cis.id).Account__c!=cis.Account__c)){
     //make sure the record type is PRM
       System.debug('====ENTERING FIRST IF BLOCK=======');
     
      if(partnerRecordType!=null && partnerRecordType.size()==1 && cis.RecordTypeId==partnerRecordType.get(0).Id){
        System.debug('====ENTERING second IF BLOCK=======');
       cis.Partner_Portal_Link__c=URL.getSalesforceBaseUrl().toExternalForm() + '/' + cis.Account__c;
       System.debug('====cis.Partner_Portal_Link__c=======' + cis.Partner_Portal_Link__c);
      }
     }
  }
  
}