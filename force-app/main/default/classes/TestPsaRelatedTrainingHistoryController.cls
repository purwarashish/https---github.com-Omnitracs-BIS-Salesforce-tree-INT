@isTest(seeAllData=false)
public class TestPsaRelatedTrainingHistoryController
{
  public static Contact objContact{get;set;}
  public static Training_History__c objTrainingHistory{get;set;} 
  
    public TestPsaRelatedTrainingHistoryController()
    {
      
    }     
    public static testMethod  void insertDataAndExcecuteScenario()  //start of test method
    { 
           insertTestData();
           PageReference pageRef=Page.PsaRelatedTrainingHistory;
           Test.setCurrentPage(pageRef);
           ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(objContact); 
           PsaRelatedTrainingHistoryController objPsaRelatedTrainingHistoryController=new PsaRelatedTrainingHistoryController(sc); 
           ApexPages.currentPage().getParameters().put('TrainingHistoryId',objTrainingHistory.id);  
           objPsaRelatedTrainingHistoryController.deleteRecord();
           objPsaRelatedTrainingHistoryController.trainingHistoryHelp();
           PsaRelatedTrainingHistoryController objPsaRelatedTrainingHistoryController1=new PsaRelatedTrainingHistoryController(sc); 
                             
      } //end of test method

      public static void insertTestData()
      {
        PSAEnhancementTestData objPSAEnhancementTestData= new PSAEnhancementTestData();                                       
        List<AccountRecordTypes__c> lstRecordType= objPSAEnhancementTestData.customSettingsAccountRecordTypes();
        List<AllAccountUtils__c> lstCustomSettingsAccountUtils= objPSAEnhancementTestData.customSettingsAccountUtils();        
        insert lstRecordType;         
        insert lstCustomSettingsAccountUtils;
                 
        Account objAccount=objPSAEnhancementTestData.createAccount(lstRecordType); //insertion of the account record
        insert objAccount;                    
                                    
         objContact=objPSAEnhancementTestData.createContact(objAccount.Id);   //insertion of the Contact record  
         insert objContact;                   
                   
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
          objClass.Instructor__c=objContact.id;
          objClass.Course__c=objCourseCatalog.id;
          objClass.Class_Code__c='testcode1';
           insert objClass;                      
          
           objTrainingHistory=new Training_History__c();
           objTrainingHistory.Class_Name__c=objClass.id;
           objTrainingHistory.Completion_Date__c=Date.newInstance(2016 , 01 ,02);
           objTrainingHistory.Completion_Status__c='Completed';
           objTrainingHistory.Contact__c=objContact.id;
           objTrainingHistory.Registration_Date__c=Date.newInstance(2016 , 01 ,01);
           objTrainingHistory.Registration_Status__c='Registered';
           objTrainingHistory.Training_History_Code__c='testhistorycode';
           insert objTrainingHistory;                      
      }            
}