/**********************************************************
* @Author       Heidi Tang (heidi.a.tang@accenture.com)
* @Date         2016-05-25
* @Description  Test data creations for all classes
**********************************************************/
public class TestDataFactory {
   
    /* -----------------------------Set Record Types and Business Hours--------------------------*/
    
    public static Id getRecordTypeId(String recordTypeDevName, String objectName){
        
        RecordType recType = [SELECT Id FROM RecordType WHERE sObjectType =:objectName AND DeveloperName = :recordtypeDevName];
        
        return recType.Id;
    } 
    
    /* -----------------------------Test Data for Multiple Records--------------------------*/
    
    public static List<Account> createAcctList(Integer noOfAccts, String acctName){
        
        List<Account> acctList = new List<Account>();
        
        for(Integer i=1;i<=noOfAccts;i++){
            acctList.add(new Account(Name = acctName + i, QWBS_Market__c = 'Enterprise', Primary_Business_Unit__c = 'Omnitracs Domestic', QWBS_Cust_ID__c = '12345' + i, Segment__c = 'TL', Fleet_Size__c = 10, BillingStreet = 'Harwood St ' + i, BillingCity = 'Dallas ' + i, BillingState = 'TX ' + i, BillingPostalCode = '75201' + i, BillingCountry = 'USA'));
        }
        
        return acctList;
        
    }
    
    public static List<Contact> createConList(Integer noOfCons, String lastName){
         List<Contact> conList = new List<Contact>();
        
        for(Integer i=1;i<=noOfCons;i++){
            conList.add(new Contact(FirstName = 'FirstName', LastName = lastName +'i', Title = 'Title', Email = 'testemail@email.com'));
        }
        
        return conList;
    }
    
     public static List<Key_Players_Influencers__c> createKeyInfluencer(Integer noOfKeys,String formalRole, Id opportunityId){
        List<Key_Players_Influencers__c> keyList = new List<Key_Players_Influencers__c>();
        
        for(Integer i=1;i<=noOfKeys;i++){
            keyList.add(new Key_Players_Influencers__c(Formal_Role__c=formalRole,Opportunity__c=opportunityId));
        }
        
        return keyList;
    }
   
}