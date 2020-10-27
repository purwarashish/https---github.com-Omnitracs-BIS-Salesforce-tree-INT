@isTest(SeeAllData=true)
private class SAAUtilityTest {

 static testMethod void testSAAFlow()
    {
        list<contact> lstContact = new list<contact>();
        lstContact = [select id,accountid from contact where Notification_Type__c includes ('Price Increase') limit 50000];
        
        for(contact updateContact : lstContact )
        {
        account testAccount = [select id from account
                              where id =: updateContact.accountid 
                              limit 1 ];
         
        list<Contract> lstContract = [select id from contract where accountid = : updateContact.accountid limit 1];                      
        
        if(!lstContract.isEmpty())
            {
                Service_Agreement_Adjustment__c newSAA = new Service_Agreement_Adjustment__c();
                newSAA.Contract__c = lstContract[0].id;
                newSAA.SAA_Status__c = 'New';
                insert newSAA;
                break;
            }
        else
        {
            continue;
        }
       } 
     }

}