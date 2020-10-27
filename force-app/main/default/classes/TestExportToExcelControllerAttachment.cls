@IsTest(SeeAllData=false)

public class TestExportToExcelControllerAttachment
{

   //Start testmethod to save test data and call controller methods
    public static testMethod void insertData()
    {           
        //PSAEnhancementTestData object used to create test data
        PSAEnhancementTestData objPSAEnhancementTestData= new PSAEnhancementTestData(); 
        
        //call getUser method to create test user 
        User user= objPSAEnhancementTestData.getUser();
        
     System.runAs(user)
      {  
      
        //call customSettingsAccountRecordTypes method to create test record types
        List<AccountRecordTypes__c> accRecordType= objPSAEnhancementTestData.customSettingsAccountRecordTypes(); 
        //insert recordType
        insert accRecordType;
        
        //call customSettingsAccountUtils method to create test custom settings          
        List<AllAccountUtils__c> testCustomSettings=objPSAEnhancementTestData.customSettingsAccountUtils(); 
        //insert customSettings
        insert testCustomSettings;  
        
        
        //call createAccount method to create test account record                             
        Account objAccount= objPSAEnhancementTestData.createAccount(accRecordType);
        //insert Account record
        insert objAccount; 
        
        
        //call customSettingsColorCode method to create test custom setting
        List<PSE_Color_Code__c> listColor = objPSAEnhancementTestData.customSettingsColorCode();
        //insert customSettings for color code
        insert listColor;
        
        
        //call createContact method to create test contact record
        Contact testResource=objPSAEnhancementTestData.createContact(objAccount.Id); 
        //insert contact object    
        insert testResource;
       
       
        //call createProject method to create test pse__Proj__c record
        List<pse__Proj__c> lstProject=objPSAEnhancementTestData.createProject(objAccount.Id);  
        //insert project object   
        insert lstProject;
        
        //gives Staffing permission to user
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
       
       
       //call createSchedule method to create test pse__Schedule__c record
       List<pse__Schedule__c > lstSchedule = objPSAEnhancementTestData.createSchedule();
       //insert schedule object
       insert lstSchedule ;
       
      
       //call createScheduleException method to create test pse__Schedule_Exception__c record
       pse__Schedule_Exception__c scheduleExceptionObj=new pse__Schedule_Exception__c();
       scheduleExceptionObj =  objPSAEnhancementTestData.createScheduleException(lstSchedule);
       //insert schedule exception object
       insert scheduleExceptionObj ;
              
       
       //call createAssignment method to create test pse__Assignment__c record
       List<pse__Assignment__c> lstAssignments= objPSAEnhancementTestData.createAssignment(lstProject,lstSchedule,testResource.Id);    
       lstAssignments[0].pse__Exclude_from_Planners__c = false;   //give exclude from planner field value
       lstAssignments[1].pse__Exclude_from_Planners__c = false;   //give exclude from planner field value
       //insert assignment objects
       insert lstAssignments;
        
       
    
       //case1: selectedResourceType-allResources
         createControllerObj(Date.newInstance(2015 , 12 ,30),Date.newInstance(2016 , 02 ,05), 'Daily','allResources', testResource);
         
         createControllerObj(Date.newInstance(2016 , 01 ,27),Date.newInstance(2016 , 03 ,23), 'Weekly','allResources', testResource);
         
         createControllerObj(Date.newInstance(2015 , 12 ,10),Date.newInstance(2016 , 02,02), 'Monthly','allResources', testResource);
          
         createControllerObj(Date.newInstance(2016 , 01 ,10),Date.newInstance(2016 , 02 ,07), 'Quarterly','allResources', testResource);
        
       
        
       //case2: selectedResourceType-singleResource
         createControllerObj(Date.newInstance(2015 , 12 ,20),Date.newInstance(2016 , 01 ,28), 'Daily','singleResource', testResource); 
      
         createControllerObj(Date.newInstance(2016 , 01 ,10),Date.newInstance(2016 , 07 ,05), 'Weekly','singleResource', testResource);   
       
         createControllerObj(Date.newInstance(2015 ,08,30),Date.newInstance(2016 , 01 ,02), 'Monthly','singleResource', testResource);   
       
         createControllerObj(Date.newInstance(2015 , 09 ,30),Date.newInstance(2016 ,02,27), 'Quarterly','singleResource', testResource);   
       
       
              
        
        
        
        Date tempDate =Date.newInstance(2016 , 01 ,01);
        //Cover getdayOftheMonth method in controller
        ExportToExcelControllerAttachment.getdayOftheMonth(tempDate);
        
        //Cover getYearOftheDate method in controller
        ExportToExcelControllerAttachment.getYearOftheDate(tempDate);
        
        //Cover getMonthOftheDate method in controller
        ExportToExcelControllerAttachment.getMonthOftheDate(tempDate);
        
         
                
      }
      
        }
   
    
    //Method to create object for ExportToExcelControllerAttachment 
     Public static void createControllerObj(Date fromDate, Date toDate, String selectedDuration,String type, Contact resource)
        {
         
           PageReference pageRef=Page.Resource_Planner;
             Test.setCurrentPage(pageRef);
          
            pageRef.getParameters().put('fromDate', String.valueOf(fromDate));
            pageRef.getParameters().put('toDate', String.valueOf(toDate));
            pageRef.getParameters().put('selectedDuration',selectedDuration);
           
            String strResourceName=resource.FirstName+' '+resource.LastName;
          
            pageRef.getParameters().put('strResourceName', strResourceName);
            pageRef.getParameters().put('selectedResourceType',type );
            
           ExportToExcelControllerAttachment eObject=new ExportToExcelControllerAttachment();
         
         //Reset soqlQuery in controller
           ExportToExcelControllerAttachment.soqlQuery ='Select Id,pse__Schedule__r.pse__Start_Date__c,pse__Schedule__r.pse__End_Date__c,Name,pse__Start_Date__c,pse__End_Date__c,pse__Resource__r.Name,pse__Resource__c,pse__Resource__r.pse__Is_Resource__c,pse__Resource__r.pse__Is_Resource_Active__c,pse__Schedule__r.Id,pse__Schedule__r.pse__Sunday_Hours__c, pse__Schedule__r.pse__Monday_Hours__c,pse__Schedule__r.pse__Tuesday_Hours__c,pse__Schedule__r.pse__Wednesday_Hours__c,pse__Schedule__r.pse__Thursday_Hours__c,pse__Schedule__r.pse__Friday_Hours__c, pse__Schedule__r.pse__Saturday_Hours__c from pse__Assignment__c ';
     
         
         }
     
}