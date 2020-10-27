@isTest(SeeAllData=false)
Private Class TestSumTotalIntegrationCallout
{

   public static void testSumTotal()
   {  
      PSAEnhancementTestData objPSAEnhancementTestData= new PSAEnhancementTestData();      
     
        List<AccountRecordTypes__c> accRecordType= objPSAEnhancementTestData.customSettingsAccountRecordTypes(); 
        //insert recordType
        insert accRecordType;            
        
        List<AllAccountUtils__c> testCustomSettings=objPSAEnhancementTestData.customSettingsAccountUtils(); 
        //insert customSettings
        insert testCustomSettings;                                 
       
        Account objAccount= objPSAEnhancementTestData.createAccount(accRecordType);
        //insert account object
        insert objAccount; 
        List<Contact> listofContacts=new List<Contact>();
        //test.startTest();
        Contact testContact1=objPSAEnhancementTestData.createContact(objAccount.Id);  
        
        System.debug('contact from other class-----'+testContact1);      
          
          testContact1.Email='jmetcalf@omnitracs.com';
          listofContacts.add(testContact1);
          //insert testContact1;
          
        System.debug('contact id-----'+testContact1.id);
        // List<Contact> LstVarContact=[Select Id,email From Contact where email=:'jmetcalf@omnitracs.com'];
         //System.debug('Contact------------'+LstVarContact);
         
           Contact testContact2=objPSAEnhancementTestData.createContact(objAccount.Id);             
             testContact2.FirstName ='SFDC1';
             testContact2.Email='jmetcalf@omnitracs2.com';
             listofContacts.add(testContact2);
             
           Contact testContact3=objPSAEnhancementTestData.createContact(objAccount.Id); 
             testContact3.Email='jmetcalf@omnitracs2.com'; 
             testContact3.FirstName ='SFDC2'; 
             listofContacts.add(testContact3);           
           
             
           insert listofContacts; 
           

         //test.stopTest();    
        /* Contact testContact4=objPSAEnhancementTestData.createContact(objAccount.Id); 
             testContact4.Email='jmetcalf@omnitracs4.com'; 
             testContact4.FirstName ='SFDC4';            
           insert testContact4; */
   
  //Insert custom settings sum total integration
      SumTotalIntegration__c SumTotalIntegration1 = customSettingsSumTotalIntegration('days to retract');
           Insert SumTotalIntegration1 ;
           
      SumTotalIntegration__c SumTotalIntegration2 = customSettingsSumTotalIntegration('fromdate');
           Insert SumTotalIntegration2 ;
           
      SumTotalIntegration__c SumTotalIntegration4 = customSettingsSumTotalIntegration('Credential');
           Insert SumTotalIntegration4 ;
           
      SumTotalIntegration__c SumTotalIntegration3 = customSettingsSumTotalIntegration('Course Catalog');
           Insert SumTotalIntegration3 ;
     
      SumTotalIntegration__c SumTotalIntegration5 = customSettingsSumTotalIntegration('Class');
           Insert SumTotalIntegration5 ;
     
      SumTotalIntegration__c SumTotalIntegration6 = customSettingsSumTotalIntegration('Training History');
           Insert SumTotalIntegration6 ;
           
      SumTotalIntegration__c SumTotalIntegration7 = customSettingsSumTotalIntegration('Contact');
           Insert SumTotalIntegration7 ;
     
}
      
  // String Type ='Course Catalog';
  public static testMethod void testSumTotal1()
  {     
       
          TestSumTotalIntegrationCallout.testSumTotal();
          test.startTest();      
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorPsa());    //Calling httpmock class for test callout
            ImportPSACourseCatalogRecords ObjSChedulePSACourseCatalog=new  ImportPSACourseCatalogRecords();      
            String sch = '0  00 1 3 * ?';
            system.schedule('Test', sch, ObjSChedulePSACourseCatalog);
         test.stopTest();
         
 }           
               
            /*SumTotalIntegrationCalloutCopy testObj =new SumTotalIntegrationCalloutCopy(Type);
         
         
         Type ='Class';
                 Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorPsa());
                  SumTotalIntegrationCalloutCopy testObj2 =new SumTotalIntegrationCalloutCopy(Type);
        
         Type ='Training History';
                 Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorPsa());
                 SumTotalIntegrationCalloutCopy testObj3 =new SumTotalIntegrationCalloutCopy(Type);
         
         Type ='Contact';
                  Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorPsa());
                  SumTotalIntegrationCalloutCopy testObj4 =new SumTotalIntegrationCalloutCopy(Type);*/
     
           //test.stopTest();
   
   public static testMethod void testSumTotal2()
   {
         test.startTest() ;  
         TestSumTotalIntegrationCallout.testSumTotal();          
             Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorPsa());
             ImportPSAClassRecords   ObjSChedulePSAClassRecords=new   ImportPSAClassRecords();
             String sch1 = '0  00 2 3 * ?';
             system.schedule('Test', sch1, ObjSChedulePSAClassRecords);
       test.stopTest();
   }
    
    public static testMethod void testSumTotal3()
   {
         test.startTest() ;  
         TestSumTotalIntegrationCallout.testSumTotal();          
             Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorPsa());
              ImportPSATrainingHistoryRecords   ObjSChedulePSATrainingHistory=new    ImportPSATrainingHistoryRecords();
             String sch2 = '0  00 3 3 * ?';
             system.schedule('Test', sch2, ObjSChedulePSATrainingHistory);
       test.stopTest();
   }
  public static testMethod void testSumTotal4()
   {
         test.startTest() ;  
         TestSumTotalIntegrationCallout.testSumTotal();          
             Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorPsa());
                UpdatePSAContactRecords   ObjUpdatePSAContactRecords=new UpdatePSAContactRecords();
             String sch3 = '0  00 4 3 * ?';
             system.schedule('Test', sch3,  ObjUpdatePSAContactRecords);
       test.stopTest();
   }


 
  //Used to create the customsetting SumTotalIntegration__c
    public static SumTotalIntegration__c customSettingsSumTotalIntegration(String name)
    {
    
       SumTotalIntegration__c objSumTotal= new SumTotalIntegration__c();
            objSumTotal.name=name;
            objSumTotal.End_Point_URL__c='testURL';
            objSumTotal.number_of_days__c=10;
            objSumTotal.Password__c='password';
            objSumTotal.UserName__c='username';
            return objSumTotal;
  
    }  
    
  
    

}