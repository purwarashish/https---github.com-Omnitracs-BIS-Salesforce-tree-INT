@isTest(seeAllData=false)
Public class TestMassScheduleExceptionController
{ 
   Public TestMassScheduleExceptionController()
   {
   
   }
   
   //start of  test method
    public Static testMethod void insertTestRecordsandExcecuteTestScenarios()
    { 
        List<MassScheduleExceptionController.assignmentwrapper> lstassignmentWrapper;   
        PSAEnhancementTestData objPSAEnhancementTestData= new PSAEnhancementTestData();                                       
        List<AccountRecordTypes__c> lstRecordType= objPSAEnhancementTestData.customSettingsAccountRecordTypes();
        List<AllAccountUtils__c> lstCustomSettingsAccountUtils= objPSAEnhancementTestData.customSettingsAccountUtils();
        insert lstRecordType;     
        insert lstCustomSettingsAccountUtils; 
        
        Account objAccount=objPSAEnhancementTestData.createAccount(lstRecordType); //insertion of the account record                      
          insert objAccount;                
                                    
        Contact objContact=objPSAEnhancementTestData.createContact(objAccount.Id);   //insertion of the Contact record  
         insert objContact;         
                      
        List<pse__Proj__c> lstProject=objPSAEnhancementTestData.createProject(objAccount.Id);     //insertion of the project records
        insert lstProject;       
        
        List<pse__Schedule__c > lstSchedule = objPSAEnhancementTestData.createSchedule();  //insertion of the schedule records
        insert lstSchedule;     
        
        //insertion of the Permission control  records
        pse__Permission_Control__c objPermissionControl=new pse__Permission_Control__c();                                
        pse__Permission_Control__c objPermissionControl1=new pse__Permission_Control__c();                
        objPermissionControl1.pse__Resource__c=objContact.id;
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
        
        //insertion of the assignment records
        List<pse__Assignment__c> lstAssignments= objPSAEnhancementTestData.createAssignment(lstProject,lstSchedule,objContact.Id);//insertion of Assignment    
         insert lstAssignments;             
        
        PageReference pageRef=Page.MassScheduleExceptionPage;
        Test.setCurrentPage(pageRef);
        MassScheduleExceptionController objMassSchExpCntrl=new MassScheduleExceptionController ();
        
        //Scenario to get all active assignment of the Selected resource  and selected resource is null         
        objMassSchExpCntrl.assignment.pse__Resource__c=lstAssignments[0].pse__Resource__c;
        pse__Schedule__c objSchedule=new pse__Schedule__c();
        objSchedule.pse__Start_Date__c= Date.newInstance(2016 , 01 ,01);
        objSchedule.pse__End_Date__c=Date.newInstance(2016 , 01 ,15);
        objMassSchExpCntrl.datefilterScheduler=objSchedule;
        objMassSchExpCntrl.activeAssignments();                    
        objMassSchExpCntrl.verifySchedule(); 
                
        //Scenario to  select assignments and ScheduleException start state is greater than Schedule Exception end date   
        lstassignmentWrapper =new  List<MassScheduleExceptionController.assignmentwrapper>();      
        for(pse__Assignment__c objassignments:lstAssignments)
        {
            MassScheduleExceptionController.assignmentwrapper objassignmentwrapper=new  MassScheduleExceptionController.assignmentwrapper(objassignments);
            objassignmentwrapper.selectedWR=true;
            lstassignmentWrapper.add(objassignmentwrapper);
             
        } 
        objMassSchExpCntrl.listActiveAssignmentWrapper=lstassignmentWrapper;
        objMassSchExpCntrl.scheduleException.pse__Date__c=Date.newInstance(2016 , 02 ,31);
        objMassSchExpCntrl.scheduleException.pse__End_Date__c=Date.newInstance(2016 , 01 ,28);             
        objMassSchExpCntrl.verifySchedule();
        
        //Scenario to Select Assignments and Start date of Schedule Exception not fall between selected Assignment start date and end date
        objMassSchExpCntrl.scheduleException.pse__Date__c=Date.newInstance(2015 ,12,30);  
        objMassSchExpCntrl.verifySchedule();          
              
        //Scenario to cover selected Assignments  and Schedule Exception end date not fall between the selected assignment start date and end date
        objMassSchExpCntrl.scheduleException.pse__End_Date__c=Date.newInstance(2015 ,12,30);         
        objMassSchExpCntrl.verifySchedule();
        
        //Scenario to create holiday Exception
        objMassSchExpCntrl.listActiveAssignmentWrapper=lstassignmentWrapper;
        pse__HolidayObj__c objHoliday=new pse__HolidayObj__c();
        objHoliday.pse__Date__c=Date.newInstance(2016 , 01 ,18);
        objHoliday.pse__Work_Calendar__c=lstAssignments[0].pse__Resource__r.pse__Work_Calendar__c;
        objHoliday.pse__Work_Hours__c=0.0;        
        insert objHoliday;
        objMassSchExpCntrl.verifySchedule();
        
        // Scenario to create the Schedule Exception for selected assignment
        objMassSchExpCntrl.listActiveAssignmentWrapper=lstassignmentWrapper; 
        objMassSchExpCntrl.autoAdjustOverlappingException=false;
        objMassSchExpCntrl.MoveEndDate=false; 
        pse__Schedule_Exception__c  objScheduleException=new  pse__Schedule_Exception__c();        
        objScheduleException.pse__Sunday_Hours__c=0.00;
        objScheduleException.pse__Monday_Hours__c=3.00;
        objScheduleException.pse__Tuesday_Hours__c=3.00;
        objScheduleException.pse__Wednesday_Hours__c=3.00;
        objScheduleException.pse__Thursday_Hours__c=2.00;
        objScheduleException.pse__Friday_Hours__c=2.00;
        objScheduleException.pse__Saturday_Hours__c=0.00;                                                  
        objScheduleException.pse__Date__c=Date.newInstance(2016 ,01,03);      
        objScheduleException.pse__End_Date__c=Date.newInstance(2016 ,01,09);
        objMassSchExpCntrl.scheduleException=objScheduleException;
        objMassSchExpCntrl.verifySchedule();
        
        //Scenario to cover the the error message code of the with out autoAdjustOverlappingException when Exception is present in that range
        objMassSchExpCntrl.scheduleException.pse__Date__c=Date.newInstance(2016 ,01,03);       
        objMassSchExpCntrl.scheduleException.pse__End_Date__c=Date.newInstance(2016 ,01,09);
        objMassSchExpCntrl.listActiveAssignmentWrapper=lstassignmentWrapper;          
        objMassSchExpCntrl.verifySchedule();
        
        objMassSchExpCntrl.scheduleException.pse__Date__c=Date.newInstance(2016 ,01,09);     
        objMassSchExpCntrl.scheduleException.pse__End_Date__c=Date.newInstance(2016 ,01,09);
        objMassSchExpCntrl.verifySchedule();
        
        objMassSchExpCntrl.scheduleException.pse__Date__c=Date.newInstance(2016 ,01,02);     
        objMassSchExpCntrl.scheduleException.pse__End_Date__c=Date.newInstance(2016 ,01,08);
        objMassSchExpCntrl.verifySchedule();
        
        objMassSchExpCntrl.scheduleException.pse__Date__c=Date.newInstance(2016 ,01,08);     
        objMassSchExpCntrl.scheduleException.pse__End_Date__c=Date.newInstance(2016 ,01,08);
        objMassSchExpCntrl.verifySchedule();
        
        objMassSchExpCntrl.scheduleException.pse__Date__c=Date.newInstance(2016 ,01,05);     
        objMassSchExpCntrl.scheduleException.pse__End_Date__c=Date.newInstance(2016 ,01,10);
        objMassSchExpCntrl.verifySchedule(); 
        
        //Scenario to Override the Existing Exception without move end date
        objMassSchExpCntrl.listActiveAssignmentWrapper=lstassignmentWrapper; 
        objMassSchExpCntrl.autoAdjustOverlappingException=true;
        objMassSchExpCntrl.MoveEndDate=false; 
        pse__Schedule_Exception__c  objScheduleException1=new  pse__Schedule_Exception__c();        
        objScheduleException1.pse__Sunday_Hours__c=0.00;
        objScheduleException1.pse__Monday_Hours__c=4.00;
        objScheduleException1.pse__Tuesday_Hours__c=5.00;
        objScheduleException1.pse__Wednesday_Hours__c=6.00;
        objScheduleException1.pse__Thursday_Hours__c=2.00;
        objScheduleException1.pse__Friday_Hours__c=2.00;
        objScheduleException1.pse__Saturday_Hours__c=0.00;                                                  
        objScheduleException1.pse__Date__c=Date.newInstance(2016 ,01,03);      
        objScheduleException1.pse__End_Date__c=Date.newInstance(2016 ,01,09);
        objMassSchExpCntrl.scheduleException=objScheduleException1;
        objMassSchExpCntrl.verifySchedule();
        
        //Scenario to split the Existing Exception with out move end date and at start date of the Exception
        objMassSchExpCntrl.listActiveAssignmentWrapper=lstassignmentWrapper; 
        objMassSchExpCntrl.autoAdjustOverlappingException=true;
        objMassSchExpCntrl.MoveEndDate=false; 
        pse__Schedule_Exception__c  objScheduleException2=new  pse__Schedule_Exception__c();        
        objScheduleException2.pse__Sunday_Hours__c=3.00;                                                       
        objScheduleException2.pse__Date__c=Date.newInstance(2016 ,01,03);      
        objScheduleException2.pse__End_Date__c=Date.newInstance(2016 ,01,03);
        objMassSchExpCntrl.scheduleException=objScheduleException2;
        objMassSchExpCntrl.verifySchedule();
        
        //Scenario to split the Existing Exception with out move end date and at end date of the Exception
        objMassSchExpCntrl.listActiveAssignmentWrapper=lstassignmentWrapper; 
        objMassSchExpCntrl.autoAdjustOverlappingException=true;
        objMassSchExpCntrl.MoveEndDate=false; 
        pse__Schedule_Exception__c  objScheduleException3=new  pse__Schedule_Exception__c();        
        objScheduleException3.pse__Saturday_Hours__c=6.00;                                                       
        objScheduleException3.pse__Date__c=Date.newInstance(2016 ,01,09);      
        objScheduleException3.pse__End_Date__c=Date.newInstance(2016 ,01,09);
        objMassSchExpCntrl.scheduleException=objScheduleException3;
        objMassSchExpCntrl.verifySchedule();
        
        //Scenario to split the Existing Exception with out move end date and at middle of the Exception
        objMassSchExpCntrl.listActiveAssignmentWrapper=lstassignmentWrapper; 
        objMassSchExpCntrl.autoAdjustOverlappingException=true;
        objMassSchExpCntrl.MoveEndDate=false; 
        pse__Schedule_Exception__c  objScheduleException4=new  pse__Schedule_Exception__c();        
        objScheduleException4.pse__Tuesday_Hours__c=3.00;
        objScheduleException4.pse__Wednesday_Hours__c=2.00;                                                           
        objScheduleException4.pse__Date__c=Date.newInstance(2016 ,01,05);      
        objScheduleException4.pse__End_Date__c=Date.newInstance(2016 ,01,06);
        objMassSchExpCntrl.scheduleException=objScheduleException4;
        objMassSchExpCntrl.verifySchedule();
        
        //rejoin the splitted Schedule Exception
        objMassSchExpCntrl.listActiveAssignmentWrapper=lstassignmentWrapper; 
        objMassSchExpCntrl.autoAdjustOverlappingException=true;
        objMassSchExpCntrl.MoveEndDate=false; 
        pse__Schedule_Exception__c  objScheduleException5=new  pse__Schedule_Exception__c();        
        objScheduleException5.pse__Sunday_Hours__c=0.00;
        objScheduleException5.pse__Monday_Hours__c=4.00;
        objScheduleException5.pse__Tuesday_Hours__c=5.00;
        objScheduleException5.pse__Wednesday_Hours__c=6.00;
        objScheduleException5.pse__Thursday_Hours__c=2.00;
        objScheduleException5.pse__Friday_Hours__c=2.00;
        objScheduleException5.pse__Saturday_Hours__c=0.00;                                                  
        objScheduleException5.pse__Date__c=Date.newInstance(2016 ,01,03);      
        objScheduleException5.pse__End_Date__c=Date.newInstance(2016 ,01,09);
        objMassSchExpCntrl.scheduleException=objScheduleException5;
        objMassSchExpCntrl.verifySchedule();
        
        //Scenario to create the Schedule Exception in Between the Existing EXception start date
        objMassSchExpCntrl.listActiveAssignmentWrapper=lstassignmentWrapper; 
        objMassSchExpCntrl.autoAdjustOverlappingException=true;
        objMassSchExpCntrl.MoveEndDate=false; 
        pse__Schedule_Exception__c  objScheduleException6=new  pse__Schedule_Exception__c();        
        objScheduleException6.pse__Sunday_Hours__c=0.00;
        objScheduleException6.pse__Monday_Hours__c=4.00;
        objScheduleException6.pse__Tuesday_Hours__c=2.00;   
        objScheduleException6.pse__Saturday_Hours__c=0.00;                                                  
        objScheduleException6.pse__Date__c=Date.newInstance(2016 ,01,02);      
        objScheduleException6.pse__End_Date__c=Date.newInstance(2016 ,01,05);
        objMassSchExpCntrl.scheduleException=objScheduleException6;
        objMassSchExpCntrl.verifySchedule();
        
        //Scenario to create Schedule Exception in Between the Existing EXception end date
        objMassSchExpCntrl.listActiveAssignmentWrapper=lstassignmentWrapper; 
        objMassSchExpCntrl.autoAdjustOverlappingException=true;
        objMassSchExpCntrl.MoveEndDate=false; 
        pse__Schedule_Exception__c  objScheduleException7=new  pse__Schedule_Exception__c();        
        objScheduleException7.pse__Sunday_Hours__c=0.00;
        objScheduleException7.pse__Monday_Hours__c=4.00;
        objScheduleException7.pse__Friday_Hours__c=5.00;       
        objScheduleException7.pse__Saturday_Hours__c=0.00;                                                  
        objScheduleException7.pse__Date__c=Date.newInstance(2016 ,01,08);      
        objScheduleException7.pse__End_Date__c=Date.newInstance(2016 ,01,11);
        objMassSchExpCntrl.scheduleException=objScheduleException7;
        objMassSchExpCntrl.verifySchedule(); 
        
        //Scenario to create Schedule Exception with move end date Checked 
        objMassSchExpCntrl.listActiveAssignmentWrapper=lstassignmentWrapper; 
        objMassSchExpCntrl.autoAdjustOverlappingException=false;       
        objMassSchExpCntrl.MoveEndDate=true; 
        pse__Schedule_Exception__c  objScheduleException8=new  pse__Schedule_Exception__c();        
        objScheduleException8.pse__Sunday_Hours__c=0.00;
        objScheduleException8.pse__Monday_Hours__c=2.00;
        objScheduleException8.pse__Tuesday_Hours__c=3.00;
        objScheduleException8.pse__Wednesday_Hours__c=4.00;
        objScheduleException8.pse__Thursday_Hours__c=5.00;
        objScheduleException8.pse__Friday_Hours__c=6.00;
        objScheduleException8.pse__Saturday_Hours__c=0.00;                                                  
        objScheduleException8.pse__Date__c=Date.newInstance(2016 ,01,12);      
        objScheduleException8.pse__End_Date__c=Date.newInstance(2016 ,01,18);
        objMassSchExpCntrl.scheduleException=objScheduleException8;
        objMassSchExpCntrl.verifySchedule();
        
        //Scenario overide Schedule Exception with move end date Checked 
        objMassSchExpCntrl.listActiveAssignmentWrapper=lstassignmentWrapper; 
        objMassSchExpCntrl.autoAdjustOverlappingException=true;
        objMassSchExpCntrl.MoveEndDate=true; 
        pse__Schedule_Exception__c  objScheduleException9=new  pse__Schedule_Exception__c();        
        objScheduleException9.pse__Sunday_Hours__c=0.00;
        objScheduleException9.pse__Monday_Hours__c=0.00;
        objScheduleException9.pse__Tuesday_Hours__c=0.00;
        objScheduleException9.pse__Wednesday_Hours__c=0.00;
        objScheduleException9.pse__Thursday_Hours__c=0.00;
        objScheduleException9.pse__Friday_Hours__c=0.00;
        objScheduleException9.pse__Saturday_Hours__c=0.00;                                                  
        objScheduleException9.pse__Date__c=Date.newInstance(2016 ,01,12);      
        objScheduleException9.pse__End_Date__c=Date.newInstance(2016 ,01,18);
        objMassSchExpCntrl.scheduleException=objScheduleException9;
        objMassSchExpCntrl.verifySchedule();
        
        //Scenario overide Schedule Exception with move end date Checked and days move back
        objMassSchExpCntrl.listActiveAssignmentWrapper=lstassignmentWrapper; 
        objMassSchExpCntrl.autoAdjustOverlappingException=true;
        objMassSchExpCntrl.MoveEndDate=true; 
        pse__Schedule_Exception__c  objScheduleException10=new  pse__Schedule_Exception__c();        
        objScheduleException10.pse__Sunday_Hours__c=12.00;
        objScheduleException10.pse__Monday_Hours__c=12.00;
        objScheduleException10.pse__Tuesday_Hours__c=12.00;
        objScheduleException10.pse__Wednesday_Hours__c=12.00;
        objScheduleException10.pse__Thursday_Hours__c=12.00;
        objScheduleException10.pse__Friday_Hours__c=12.00;
        objScheduleException10.pse__Saturday_Hours__c=12.00;                                                  
        objScheduleException10.pse__Date__c=Date.newInstance(2016 ,01,12);      
        objScheduleException10.pse__End_Date__c=Date.newInstance(2016 ,01,18);
        objMassSchExpCntrl.scheduleException=objScheduleException10;
        objMassSchExpCntrl.verifySchedule();
                              
    }                                   
   //end of test method         
}