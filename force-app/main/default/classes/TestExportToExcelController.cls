@IsTest(SeeAllData=false)

public class TestExportToExcelController 
{
   //Initialization of  variable count
      Public Static Integer count=1;
                
    //Start testmethod to save test data and call controller methods
    public static testMethod void insertData()
    {           
        PSAEnhancementTestData objPSAEnhancementTestData= new PSAEnhancementTestData();      
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
        
        List<PSE_Color_Code__c> listColor = objPSAEnhancementTestData.customSettingsColorCode();
        insert listColor;
         
        /*     
        Account objAccount= objPSAEnhancementTestData.createAccount();
        insert objAccount;                             
          */      
        Contact testResource=objPSAEnhancementTestData.createContact(objAccount.Id);      
        insert testResource;
       
         List<pse__Proj__c> lstProject=objPSAEnhancementTestData.createProject(objAccount.Id);     
        insert lstProject;
       
        pse__Permission_Control__c objPermissionControl=new pse__Permission_Control__c();                


        pse__Permission_Control__c objPermissionControl1=new pse__Permission_Control__c();                
        objPermissionControl1.pse__Resource__c=testResource.id;
        objPermissionControl1.CurrencyIsoCode ='USD';       
        objPermissionControl1.pse__User__c=UserInfo.getUserId();
        objPermissionControl1.pse__Staffing__c=true;
        insert objPermissionControl1;

        List< pse__Permission_Control__c> lstPermissionControl= New List< pse__Permission_Control__c>();
        for(Integer i=0;i<lstProject.size();i++)
        {
            pse__Permission_Control__c objPermissionControl2=new pse__Permission_Control__c();                
            objPermissionControl2.pse__Project__c=lstProject[i].id;
            objPermissionControl2.CurrencyIsoCode ='USD';       
            objPermissionControl2.pse__User__c=UserInfo.getUserId();
            objPermissionControl2.pse__Staffing__c=true;
            lstPermissionControl.add(objPermissionControl2);
       }
       insert lstPermissionControl;
       
       
       List<pse__Schedule__c > lstSchedule = objPSAEnhancementTestData.createSchedule();
         
         {
        insert lstSchedule;    
        System.Debug('*************schedule'+lstSchedule[0].Id);
        System.Debug('*************schedule'+lstSchedule[0].pse__Start_Date__c);
        
        }   
        
        List<pse__Assignment__c> lstAssignments= objPSAEnhancementTestData.createAssignment(lstProject,lstSchedule,testResource.Id);    
        insert lstAssignments;
        
        
        //Call createScheduleException method to insert pse__Schedule_Exception__c objects   
        createScheduleException(lstSchedule);
     
     
         PageReference pageRef=Page.Resource_Planner;
          Test.setCurrentPage(pageRef);
      
        
      
        //Call getControllerObj method
        ExportToExcelController eObject0 = getControllerObj(Date.newInstance(2015 , 12 ,30), Date.newInstance(2016 , 02 ,05), testResource, 'allResources', 'Daily');
        //Call exporttoExcel controller method
       
         eObject0.exporttoExcel();
         
        
       
        //Call getControllerObj method
        ExportToExcelController eObject1 = getControllerObj(Date.newInstance(2016 , 01 ,27), Date.newInstance(2016 , 03 ,23),testResource, 'allResources', 'Weekly');
        //Call exporttoExcel controller method 
        eObject1.exporttoExcel();
       
        //Call getControllerObj method
        ExportToExcelController eObject2 = getControllerObj(Date.newInstance(2016 , 12 ,10), Date.newInstance(2016 , 02,02),testResource, 'allResources', 'Monthly');
        //Call exporttoExcel controller method 
        eObject2.exporttoExcel();           
        
        //Call getControllerObj method(for less then 60 days duration)
        ExportToExcelController eObject3 = getControllerObj(Date.newInstance(2015 , 01 ,30), Date.newInstance(2015 , 03 ,27), testResource, 'allResources', 'Quarterly');
        //Call exporttoExcel controller method     
        eObject3.exporttoExcel();
      
      /*
         //Call getControllerObj method (for 60-180 days duration)
        ExportToExcelController eObject4 = getControllerObj(Date.newInstance(2015 , 03 ,03), Date.newInstance(2015 , 08 ,10), testResource, 'allResources', 'Quarterly');
        //Call exporttoExcel controller method     
        eObject4.exporttoExcel();
       */
        
        //Call getControllerObj method (for more than 180 days duration)
        ExportToExcelController eObject5 = getControllerObj(Date.newInstance(2014 , 06 ,10), Date.newInstance(2015 , 04 ,12), testResource, 'allResources', 'Quarterly');
        //Call exporttoExcel controller method     
        eObject5.exporttoExcel();
        
        Date tempdate = Date.newInstance(2016 , 01 ,01);
        
        //Call getdayOftheMonth controller method     
        eObject5.getdayOftheMonth(tempdate);
        
        //Call getYearOftheDate controller method 
        eObject5.getYearOftheDate(tempdate);
        
        //Call getMonthOftheDate controller method     
        eObject5.getMonthOftheDate(tempdate); 
        
        eObject5.clear();  
     
     
        //Call getControllerObj method
        ExportToExcelController eObject6 = getControllerObj(Date.newInstance(2015 , 12 ,20), Date.newInstance(2016 , 01 ,28), testResource, 'singleResource', 'Daily');
        //Call exporttoExcel controller method 
        eObject6.exporttoExcel();
     
        
        //Call getControllerObj method
        ExportToExcelController eObject7 = getControllerObj(Date.newInstance(2016 , 01 ,10), Date.newInstance(2016 , 07 ,05),testResource, 'singleResource', 'Weekly');
        //Call exporttoExcel controller method 
        eObject7.exporttoExcel();
      
       
        //Call getControllerObj method
        ExportToExcelController eObject8 = getControllerObj(Date.newInstance(2015 ,08,30), Date.newInstance(2016 , 01 ,02),testResource, 'singleResource', 'Monthly');
        //Call exporttoExcel controller method 
        eObject8.exporttoExcel();
        
       
      
       //Call getControllerObj method(for less than 180 days duration)
        ExportToExcelController eObject9 = getControllerObj(Date.newInstance(2015 , 09 ,30), Date.newInstance(2016 ,02,27), testResource, 'singleResource', 'Quarterly');
        //Call exporttoExcel controller method 
         eObject9.exporttoExcel();
      
      /*
      
      //Call getControllerObj method(for 180-730 days duration)
        ExportToExcelController eObject10 = getControllerObj(Date.newInstance(2015 , 12 ,30), Date.newInstance(2016 ,07,15), testResource, 'singleResource', 'Quarterly');
        //Call exporttoExcel controller method 
         eObject10.exporttoExcel();
     
     */   
         
         //Call getControllerObj method(for more two years duration)
        ExportToExcelController eObject11 = getControllerObj(Date.newInstance(2014 , 10 ,30), Date.newInstance(2016 ,12,15), testResource, 'singleResource', 'Quarterly');
        //Call exporttoExcel controller method 
         eObject11.exporttoExcel();
        
        
         
         
       
       } 
        
        
    } // End of test method 
    
    //Insert pse__Schedule_Exception__c object  
    Public static void createScheduleException(List< pse__Schedule__c> lstSchedule)
    { 
        pse__Schedule_Exception__c testScheduleException = new pse__Schedule_Exception__c();
        testScheduleException.pse__Schedule__c =lstSchedule[0].Id;
        testScheduleException.pse__Sunday_Hours__c=0.00;
        testScheduleException.pse__Monday_Hours__c=2.00;
        testScheduleException.pse__Tuesday_Hours__c=2.00;
        testScheduleException.pse__Wednesday_Hours__c=2.00;
        testScheduleException.pse__Thursday_Hours__c=2.00;
        testScheduleException.pse__Friday_Hours__c=2.00;
        testScheduleException.pse__Saturday_Hours__c=0.00;
        testScheduleException.pse__Date__c= Date.newInstance(2016 , 01 ,01);
        testScheduleException.pse__End_Date__c = Date.newInstance(2016 , 01 ,20);        
        insert testScheduleException;                  
    } 
    
    //method to get controller object 
    public static ExportToExcelController getControllerObj(Date fromDate, Date ToDate, Contact resourceObj, String Type, String Duration)
    {
        ExportToExcelController eObject= new ExportToExcelController();
         pse__Schedule__c scheduleObj=new pse__Schedule__c(); 
         scheduleObj.pse__Start_Date__c =fromDate;
         scheduleObj.pse__End_Date__c =ToDate;
       /*
        pse__Assignment__c assignmentObj= new pse__Assignment__c();
        assignmentObj.pse__Resource__c=resourceObj.Id;
       */ 
        eObject.objSchedule=scheduleObj;
      
        eObject.strResourceName=resourceObj.FirstName+' '+resourceObj.LastName;
      
        
        eObject.selectedResourceType =Type;
        eObject.selectedDuration = Duration; 
        
        
                
        return eObject;
    } 
}