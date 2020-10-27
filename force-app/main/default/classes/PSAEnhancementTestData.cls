Public class PSAEnhancementTestData
{
    public static Integer intCount=1;
    Public  PSAEnhancementTestData()
    {
    
    }        
    //Used to create the account record
    Public Account createAccount(List<AccountRecordTypes__c> lstRecordType )
    {
        Account objAccount=new Account();                                                             
        objAccount.Name='testAccount';
        objAccount.Primary_Business_Unit__c='Omnitracs Domestic';
        objAccount.Account_Classification__c='Prospect';
        objAccount.Account_Status__c='Active';
        objAccount.phone='(968) 675-0392';
        objAccount.QWBS_Status__c='Active';       
        objAccount.RecordTypeId= lstRecordType[0].RecordTypeID__c;         
        objAccount.BillingStreet='ITPL';
        objAccount.BillingState='CA';
        objAccount.BillingCountry='India';
        //objAccount.Ranking_Num_HOS_Violations_24_Hours__c =1;
        objAccount.Total_Power_Units_Est__c=0;
        objAccount.of_HOS_Violations__c=2;
        objAccount.of_Unsafe_Driving_Violations__c=5;
        objAccount.of_Drivers_Outside_a_100_Mile_Radius__c=3;
        objAccount.Model_Age__c =7; 
        objAccount.Avg_Stops_Route__c=3;     
        objAccount.eLog_Solution_CAP__c ='Paper Logs / None';        
        return objAccount;            
    }      
    
    //Used to create the records for contact/Resource
    Public Contact createContact(Id accountId)
    {
        pse__Practice__c testPractice=new pse__Practice__c();
        testPractice.Name='Professional Services';
        insert testPractice;
        
        pse__Grp__c testGroup=new pse__Grp__c();
        testGroup.Name='XRS';      
        insert testGroup;
        
        pse__Region__c   testRegion=new pse__Region__c();
        testRegion.Name='US';
        insert testRegion;          
          
        pse__Work_Calendar__c testWorkCalendar=new  pse__Work_Calendar__c();
        testWorkCalendar.Name='Test Work Calender';
        insert testWorkCalendar;
             
        Contact testResource=new Contact();               
        Schema.DescribeSObjectResult cfrSchemaContact = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> ContactRecordTypeInfo = cfrSchemaContact.getRecordTypeInfosByName();                
        testResource.RecordTypeId =ContactRecordTypeInfo.get('Resource').getRecordTypeId();
        testResource.FirstName = 'SFDC';
        testResource.LastName = 'Salesforce';
        testResource.Title ='test';
        testResource.AccountId= accountId;
        testResource.email = '123xyz@gmail.com';
        testResource.Phone = '(123) 654-78965';
        testResource.CurrencyIsoCode ='USD';
        testResource.pse__Resource_Role__c='Trainer';         
        testResource.pse__Region__c= testRegion.Id;
        testResource.pse__Practice__c= testPractice.Id;
        testResource.pse__Group__c= testGroup.Id;
        testResource.pse__Work_Calendar__c= testWorkCalendar.Id;                                
        testResource.pse__Is_Resource__c = True;
        testResource.pse__Is_Resource_Active__c = True;
        return  testResource;        
    }
    
    // used to create the records for the project
    Public List<pse__Proj__c> createProject(Id accId)         
    {     
        List<pse__Proj__c> lstProject =new List<pse__Proj__c>();            
        for(Integer i=0;i<=intCount;i++)
        {
            pse__Proj__c testProject =new pse__Proj__c();
            Schema.DescribeSObjectResult cfrSchemaProject = Schema.SObjectType.pse__Proj__c; 
            Map<String,Schema.RecordTypeInfo> ProjectRecordTypeInfo = cfrSchemaProject.getRecordTypeInfosByName();                
            testProject.RecordTypeId =ProjectRecordTypeInfo.get('Customer Project').getRecordTypeId(); 
            testProject.CurrencyIsoCode ='USD'; 
            testProject.pse__Account__c=accId;
            testProject.pse__Billing_Type__c='Fixed Price'; 
            testProject.Time_Approval_Method__c ='Direct Manager'; 
            testProject.pse__Start_Date__c=Date.newInstance(2016 , 01 ,01);
            testProject.pse__End_Date__c=Date.newInstance(2016 , 01 ,28);   
            testProject.name ='testProject'+i ; 
            lstProject.add(testProject);                                       
        }             
        return lstProject;       
    }
    
    //Used to create the records for the Schedule
    Public List< pse__Schedule__c > createSchedule()
    { 
        List<pse__Schedule__c> lstSchedule = new List<pse__Schedule__c> ();
        for(Integer i=0;i<=intCount;i++)
        {
            pse__Schedule__c testSchedule =new pse__Schedule__c(); 
            
            if(i==0)
            {
                testSchedule.pse__Scheduled_Hours__c=80;                                                                      
                testSchedule.pse__Sunday_Hours__c=0.00;
                testSchedule.pse__Monday_Hours__c=8.00;
                testSchedule.pse__Tuesday_Hours__c=8.00;
                testSchedule.pse__Wednesday_Hours__c=8.00;
                testSchedule.pse__Thursday_Hours__c=8.00;
                testSchedule.pse__Friday_Hours__c=8.00;
                testSchedule.pse__Saturday_Hours__c=0.00;
                testSchedule.pse__Start_Date__c = Date.newInstance(2016 , 01 ,01);
                testSchedule.pse__End_Date__c = Date.newInstance(2016 , 01 ,28);           
            }
            if(i==1)
            {
                testSchedule.pse__Scheduled_Hours__c=50;                                                                      
                testSchedule.pse__Sunday_Hours__c=0.00;
                testSchedule.pse__Monday_Hours__c=2.00;
                testSchedule.pse__Tuesday_Hours__c=3.00;
                testSchedule.pse__Wednesday_Hours__c=4.00;
                testSchedule.pse__Thursday_Hours__c=5.00;
                testSchedule.pse__Friday_Hours__c=6.00;
                testSchedule.pse__Saturday_Hours__c=0.00;
                testSchedule.pse__Start_Date__c = Date.newInstance(2016 , 01 ,01);
                testSchedule.pse__End_Date__c = Date.newInstance(2016 , 01 ,31);           
            }
            lstSchedule.add(testSchedule); 
        }
        return lstSchedule ;
    } 
    //Used to create the records for the assignment
    public List<pse__Assignment__c >  createAssignment(List<pse__Proj__c> lstProjects,List<pse__Schedule__c> lstSchedule,Id resourceId)
    {
        List<pse__Assignment__c> lstAssignments=new List<pse__Assignment__c>();
        for(Integer i=0;i<=intCount;i++)
        {
            pse__Assignment__c objAssignment=new pse__Assignment__c();
            objAssignment.CurrencyIsoCode ='USD';
            objAssignment.pse__Bill_Rate__c =0.00;
            objAssignment.pse__Resource__c=resourceId;
            if(i==0)
            {
                objAssignment.Name ='testAssignment'+i;
                objAssignment.pse__Schedule__c = lstSchedule[i].Id;
                objAssignment.pse__Project__c= lstProjects[i].Id;
            }  
            if(i==1)
            {
                objAssignment.Name ='testAssignment'+i;
                objAssignment.pse__Schedule__c = lstSchedule[i].Id;
                objAssignment.pse__Project__c= lstProjects[i].Id;
            }  
        lstAssignments.add(objAssignment);            
        }
        return  lstAssignments ;              
    } 
    
    //Used to create the records for the schedule EXception   
    Public pse__Schedule_Exception__c createScheduleException(List< pse__Schedule__c> lstSchedule)
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
        return testScheduleException;                  
    } 
    
    //uUsed to create the customsetting Accountrecordtypes
    public  List<AccountRecordTypes__c> customSettingsAccountRecordTypes()
    {
        map<string,string> mapRecordTypes=new map<string,string>();
        mapRecordTypes.put('TL_SALES_ACCOUNT_RECORD_TYPE_ID','01250000000DQBAAA4');      
        mapRecordTypes.put('COMPETITOR_RECORD_TYPE_ID','01250000000Qxbn');        
        List<AccountRecordTypes__c> lstAccRecordTypes=new List<AccountRecordTypes__c>();
        for( String recordName : mapRecordTypes.keySet())
        {
            AccountRecordTypes__c objAccRecordType= new AccountRecordTypes__c();
            objAccRecordType.Name=recordName;
            objAccRecordType.RecordTypeID__c=mapRecordTypes.get(recordName);
            lstAccRecordTypes.add(objAccRecordType);          
        }      
        return lstAccRecordTypes;
    }  
    
    //Used to create customsetting AllAccountUtils
    public List<AllAccountUtils__c> customSettingsAccountUtils()
    {  
        map<string,string> mapAllAccountUtils=new map<string,string>();
        mapAllAccountUtils.put('BILLING_ADDRESS','Billing Address');
        mapAllAccountUtils.put('PHONE','1236547893');
        mapAllAccountUtils.put('ACCOUNT_TYPE','Acquired');
        mapAllAccountUtils.put('MARKET','Deere');
        mapAllAccountUtils.put('DISTRICT','Canada');
        mapAllAccountUtils.put('STATUS','Active');
        mapAllAccountUtils.put('LEAD_SOURCE','Association');
        mapAllAccountUtils.put('AVG_LEN_HAUL','Local');
        mapAllAccountUtils.put('REG_VEHICLES','12345');
        mapAllAccountUtils.put('PRIMARY_BUSINESS','Armored');
        mapAllAccountUtils.put('PRIMARY_COMMODITY','Acid');
        mapAllAccountUtils.put('OTR_VEHICLES','1234568');
        mapAllAccountUtils.put('EVAL_CUSTOMERS','Active');
        mapAllAccountUtils.put('CONTACT_COMMENT','test Comment');
        mapAllAccountUtils.put('CONTRACT_EXPIRATION','03/17/2016');
        mapAllAccountUtils.put('COMP_PLATFORM','Mainframe');
        mapAllAccountUtils.put('RANKING','Large');    
        List<AllAccountUtils__c> lstutilSettings= New List<AllAccountUtils__c>();
        for( String UtilsName: mapAllAccountUtils.keySet())
        {
            AllAccountUtils__c objallAccountUtils=new AllAccountUtils__c();        
            objallAccountUtils.Name=UtilsName;
            objallAccountUtils.Value__c=mapAllAccountUtils.get(UtilsName);
            lstutilSettings.add(objallAccountUtils);          
        }  
        return lstutilSettings;     
        }
        
        //Used to create customsetting Color Code for Export to excel
    public List<PSE_Color_Code__c> customSettingsColorCode()
    {
        map<string,string> mapAllColorCode=new map<string,string>();
        mapAllColorCode.put('30-41 Hours','White');
        mapAllColorCode.put('10-19 Hours','Choclate');
        mapAllColorCode.put('42 hours or more','Blue');
        mapAllColorCode.put('Less than 10 hours','Red');
        mapAllColorCode.put('Default','Brown');
        
        List<PSE_Color_Code__c> listColorCode =new List<PSE_Color_Code__c>();
        for(String colorName :mapAllColorCode.keySet())
        {
            PSE_Color_Code__c ObjPseColorCode = new PSE_Color_Code__c();
            ObjPseColorCode.Name =colorName ;
            ObjPseColorCode.Color__c=mapAllColorCode.get(colorName);
            listColorCode.add(ObjPseColorCode);
        
        }
        return listColorCode;
    }
    
    //Used create User(Bralon Stiggers profile and role)
    public User getUser()
    {
        User testUser = new User();
        testUser.Username= 'test.user@omnitracs.com.dev';
        testUser.Email = 'test.user@omnitracs.com';
        testUser.Lastname = 'User';
        testUser.Firstname = 'Test';
        testUser.Alias = 'tuser';
        testUser.UserRole = [ select id from userrole where Name ='Professional Services' ];
        Profile testProfile=[ select id from profile where Name = 'PSE - Management' ];
        testUser.ProfileId=testProfile.Id;
        testUser.TimeZoneSidKey = 'GMT';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.CommunityNickname = 'Test';           
        insert testUser ;
    return testUser ;          
    }                              
}