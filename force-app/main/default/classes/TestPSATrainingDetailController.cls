@IsTest(SeeAllData=false)
public class TestPSATrainingDetailController 
{

   public static testMethod void insertData()
    {     
      PSAEnhancementTestData objPSAEnhancementTestData = new PSAEnhancementTestData();
        User user= objPSAEnhancementTestData.getUser();
     System.runAs(user)
      { 
        List<AccountRecordTypes__c> accRecordType= objPSAEnhancementTestData.customSettingsAccountRecordTypes(); 
        //insert recordType
        insert accRecordType;            
        List<AllAccountUtils__c> testCustomSettings=objPSAEnhancementTestData.customSettingsAccountUtils(); 
        //insert customSettings
        insert testCustomSettings;                                 
        Account objAccount= objPSAEnhancementTestData.createAccount(accRecordType);
        insert objAccount; 
        
             
        Contact objContact1=objPSAEnhancementTestData.createContact(objAccount.Id);      
        insert objContact1; 
        
        Contact objContact2=objPSAEnhancementTestData.createContact(objAccount.Id);
           objContact2.Email ='abc@xyz.com';   
        insert objContact2;  
        
        
          Training_Information__c objTrainingInformation1 =new Training_Information__c(); 
          objTrainingInformation1.Contact__c=objContact1.id; 
          objTrainingInformation1.Start_Date__c=Date.newInstance(2016 , 01 ,01);
          objTrainingInformation1.End_Date__c=Date.newInstance(2016 , 02 ,01);
          objTrainingInformation1.Status__c='Active';
          
          String strRecordTypeId1 = [Select Id From RecordType Where SobjectType = 'Training_Information__c' and Name = 'Learning Lab'].Id;
          objTrainingInformation1.RecordTypeId=strRecordTypeId1;
          
          insert objTrainingInformation1;
          
          Training_Information__c objTrainingInformation2 =new Training_Information__c(); 
          objTrainingInformation2.Contact__c=objContact1.id; 
          objTrainingInformation2.Start_Date__c=Date.newInstance(2016 , 01 ,01);
          objTrainingInformation2.End_Date__c=Date.newInstance(2016 , 02 ,01);
          objTrainingInformation2.Status__c='Active';
          
          String strRecordTypeId2 = [Select Id From RecordType Where SobjectType = 'Training_Information__c' and Name = 'Webinar'].Id;
          objTrainingInformation2.RecordTypeId=strRecordTypeId2;
          
          insert objTrainingInformation2;
                        
                   
          Course_Catalog__c objCourseCatalog=new Course_Catalog__c();
          objCourseCatalog.Course_Name__c='TestCoursecatalog';
          objCourseCatalog.Course_Type__c='Webinar';
          objCourseCatalog.Description__c='test';
          objCourseCatalog.Status__c='Active';
          objCourseCatalog.Course_Code__c='testcourse1';
          insert objCourseCatalog;
          
          Class__c objClass=new Class__c();
          objClass.Class_Name__c='TestClass';
          objClass.Class_Schedule__c=Date.newInstance(2016 , 01 ,01);
          objClass.Instructor__c=objContact1.id;
          objClass.Course__c=objCourseCatalog.id;
          objClass.Class_Code__c='testcode1';
           insert objClass;                      
          
           Training_History__c objTrainingHistory=new Training_History__c();
           objTrainingHistory.Class_Name__c=objClass.id;
           objTrainingHistory.Completion_Date__c=Date.newInstance(2016 , 01 ,02);
           objTrainingHistory.Completion_Status__c='Completed';
           objTrainingHistory.Contact__c=objContact1.id;
           objTrainingHistory.Registration_Date__c=Date.newInstance(2016 , 01 ,01);
           objTrainingHistory.Registration_Status__c='Registered';
           objTrainingHistory.Training_History_Code__c='testhistorycode';
           insert objTrainingHistory;          
       
        
           PageReference pageRef=Page.PsaRelatedTrainingHistory;
           Test.setCurrentPage(pageRef);
           ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(objContact1); 
           PSATrainingDetailController testObj1 =new PSATrainingDetailController(sc1);
           
           ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(objContact2); 
           PSATrainingDetailController testObj2 =new PSATrainingDetailController(sc2);
      }
    } 
    
                  

}