trigger trigMapFields on Lead (after update){
/*
     BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }

String profileId= userInfo.getProfileId();
String UserId= userInfo.getUserId();
System.debug('In trigger profileid = ' + profileId + '\n UserId = ' + UserId);
Profile profile=[Select UserLicenseId,Id From Profile where Id=:profileId];
UserLicense userLicense = [Select Name,Id From UserLicense where Name='Gold Partner'];
 for(Lead lead:Trigger.new)
  {
  if (lead.IsConverted)
    {
            if(userLicense.Id == profile.UserLicenseId)
            {
            Account acc= [SELECT Id,Name FROM Account WHERE Id = :lead.ConvertedAccountId];
                          acc.Partner_Agent__c =  UserId;
            update acc;
            }
     }

   }*/
}