@isTest(SeeAllData=false)
public Class Test_Schedule_Resource_lookup
{  
 //start of test method
   Public static testMethod void insertTestRecordsandExecuteTestScenarios()
   {    
        PSAEnhancementTestData objPSAEnhancementTestData=new PSAEnhancementTestData();        
        List<AccountRecordTypes__c> lstRecordType= objPSAEnhancementTestData.customSettingsAccountRecordTypes();
        List<AllAccountUtils__c> lstCustomSettingsAccountUtils= objPSAEnhancementTestData.customSettingsAccountUtils();
        insert lstRecordType;     
        insert lstCustomSettingsAccountUtils;         
        Account objAccount=objPSAEnhancementTestData.createAccount(lstRecordType);  //insert account record          
          insert objAccount;
          
      Contact objContact=objPSAEnhancementTestData.createContact(objAccount.Id);  //insert contact/resource record    
           insert objContact;         
       
       Schedule_Resource_lookup objResourcelookup=new Schedule_Resource_lookup();
       objResourcelookup.Search(); 
       objResourcelookup.searchString='test';
       objResourcelookup.Search(); 
       objResourcelookup.getFormTag();
       objResourcelookup.getTextBox();           
   }   //end of test method   
}