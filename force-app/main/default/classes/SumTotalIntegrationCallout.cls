/*
Author : TCS Banglore offshore Team
Summary: APEX code to import data from SumTotal system.
*/

public class SumTotalIntegrationCallout{

public SumTotalIntegrationCallout(string type)
{
    fetchCourseData(type);
}

//-----------------------------------------------------------------------------------------------------------------------------
private void fetchCourseData(String objName) 
{    
    List<PSA_Training_Error_Log__c> lstTrainingErrorLog = new List<PSA_Training_Error_Log__c>();
    String DataAsString = calloutSumTotal(objName);
    System.debug('file length'+DataAsString.length());
    String[] csvRecordRow = DataAsString.split('\n');           
    if(objName == 'Course Catalog')
    {
        List<Course_Catalog__c> listCourseCatalog=new List<Course_Catalog__c>();
        Set<String> setCourseId=new Set<String>();
        string strTempvalue='';
        for(Integer i = 1; i < csvRecordRow.size(); i++) 
        {                              
            Course_Catalog__c objtemp=new Course_Catalog__c();
            objtemp.Sumtotal_Import_Date__c=system.now();
            
            //The first column and last column contains ".Remove that and use
            string[] csvRecordColumn = csvRecordRow[i].split('","'); 
            
            objtemp.Course_Name__c = csvRecordColumn[0].substring(1,csvRecordColumn[0].length());
            if(csvRecordColumn.size()>=16)
            {
                objtemp.Course_Code__c= csvRecordColumn[16];
            }
            if(csvRecordColumn.size()>=2)
            {
                strTempvalue=csvRecordColumn[2];
                if(strTempvalue=='UDT')
                    objtemp.Course_Type__c ='Webinar';
                else if(strTempvalue=='ILT')
                    objtemp.Course_Type__c ='Learning Lab';
                else if(strTempvalue=='OLT')
                    objtemp.Course_Type__c ='Onsite Training';
            }
            if(csvRecordColumn.size()>=3)
            {
                objtemp.Status__c = csvRecordColumn[3];
            }
            if(csvRecordColumn.size()>=4)
            {
                objtemp.Description__c = csvRecordColumn[4];
            }
            if(!setCourseId.contains(objtemp.Course_Code__c))
            {
                listCourseCatalog.add(objtemp);
                setCourseId.add(objtemp.Course_Code__c);
            }
        }    
        if(listCourseCatalog.size()>0) 
        {        
            //if any error needs to insert in Error Log table ..so Database.upsert();
            List<Database.UpsertResult> upsertResults = Database.upsert(listCourseCatalog, Course_Catalog__c.Fields.Course_Code__c, false);              
    
        }
    }
    
    //*******************************************************************************************
    //*******************************************************************************************
    
    if(objName == 'Class')
    {
        List<Class__c> listClasses = new List<Class__c>();
        Set<String> setCourseId = new Set<String>();
        Set<String> setClassId=new Set<String>(); 
        Set<String> setInstructorEmailId = new Set<String>();
        Map<String, Course_Catalog__c> mapCourseId = new Map<String, Course_Catalog__c>();
        Map<String, List<Contact>> mapInstructorId = new Map<String, List<Contact>>();//should be a list of contact to find duplicate records
        List<Contact> listTempContacts;
        boolean classRecord=false;

        //Get all EmailId of contacts and courseID to fetch corresponding records from salesforce
        for(Integer i = 1; i < csvRecordRow.size(); i++) 
        {
            string[] csvRecordColumn = csvRecordRow[i].split('","');
            
            if(csvRecordColumn.size()>=25 && csvRecordColumn[25]<>null && (csvRecordColumn[25].trim())<>'')
            {
                setInstructorEmailId.add(csvRecordColumn[25]);
            }
            if(csvRecordColumn.size()>=29 && csvRecordColumn[29]<>null && (csvRecordColumn[29].trim())<>'')
            {
                setCourseId.add(csvRecordColumn[29]);
            }
        }
        

        for(Course_Catalog__c singleCourseCatalog :[Select id, Course_Code__c,Course_Name__c from Course_Catalog__c where Course_Code__c in :setCourseId])
        {
            mapCourseId.put(singleCourseCatalog.Course_Code__c, singleCourseCatalog);
        }
        for(Contact singleContact :[select id, email from Contact where email in :setInstructorEmailId])
        {
            if(mapInstructorId.containsKey(singleContact.email)){
                listTempContacts=mapInstructorId.get(singleContact.email);
            }
            else{
                listTempContacts=new List<Contact>();
            }
            listTempContacts.add(singleContact);
            mapInstructorId.put(singleContact.email,listTempContacts);
        }
        
        
        for(Integer i = 1; i < csvRecordRow.size(); i++) 
        {                              
            Class__c objtemp=new Class__c();
            objtemp.Sumtotal_Import_Date__c=system.now();
            classRecord=true;
            
            string[] csvRecordColumn = csvRecordRow[i].split('","');
            
            objtemp.Class_Name__c = csvRecordColumn[0].substring(1,csvRecordColumn[0].length());
             
            if(csvRecordColumn.size()>=25)
            {
                if(mapInstructorId.containsKey(csvRecordColumn[25].toLowerCase())){
                    listTempContacts = mapInstructorId.get(csvRecordColumn[25].toLowerCase());
                    if(listTempContacts<>null && listTempContacts.size()==1){
                        objtemp.Instructor__c=listTempContacts[0].Id;
                    }
                    else{
                        //insert a record in error log
                        PSA_Training_Error_Log__c objTrainingErrorLog=new PSA_Training_Error_Log__c();
                        objTrainingErrorLog.User_Name__c=csvRecordColumn[25];
                        objTrainingErrorLog.Error_Log__c='Duplicate contacts with same Email address '+'"' +csvRecordColumn[25] +'"'+' ('+'Class Name: '+objtemp.Class_Name__c+'»'+'Course Name: '+csvRecordColumn[5]+'»'+'Class Code: '+csvRecordColumn[1]+'»'+'Insructor: '+csvRecordColumn[25]+')';
                        objTrainingErrorLog.Object_Name__c=objName;
                        lstTrainingErrorLog.add(objTrainingErrorLog);
                        classRecord=false;
                    }
                    
                }     
                else
                {
                    //insert a record in error log
                    PSA_Training_Error_Log__c objTrainingErrorLog=new PSA_Training_Error_Log__c();
                    objTrainingErrorLog.User_Name__c=csvRecordColumn[25];
                    objTrainingErrorLog.Object_Name__c=objName;                    
                    objTrainingErrorLog.Error_Log__c='No contacts exists with Email address '+'"'+csvRecordColumn[25]+'"'+' (' +'Class Name: '+objtemp.Class_Name__c+'»'+'Course Name: '+csvRecordColumn[5]+'»'+'Class Code: '+csvRecordColumn[1]+'»'+'Insructor: '+csvRecordColumn[25]+')';
                    lstTrainingErrorLog.add(objTrainingErrorLog);
                }
                
            }
            if(csvRecordColumn.size()>=28){
                objtemp.Class_Code__c= csvRecordColumn[28];
            }
            if(csvRecordColumn.size()>=21)
            {
              objtemp.Class_Schedule__c=convertDate(csvRecordColumn[21]); 
            }
            if(csvRecordColumn.size()>=29){
                if(mapCourseId.containsKey(csvRecordColumn[29])){
                    objtemp.Course__c = mapCourseId.get(csvRecordColumn[29]).id;
                }    
                else
                {
                    //insert a record in error log
                    PSA_Training_Error_Log__c objTrainingErrorLog=new PSA_Training_Error_Log__c();
                    objTrainingErrorLog.User_Name__c=csvRecordColumn[29];
                    objTrainingErrorLog.Object_Name__c=objName;
                    objTrainingErrorLog.Error_Log__c='No course exists with Name ' +csvRecordColumn[29] +' ('+'Class Name: '+objtemp.Class_Name__c+' » '+'Course Name: '+csvRecordColumn[5]+' » '+'Class Code: '+csvRecordColumn[1]+' » '+'Insructor: '+csvRecordColumn[25]+')';
                    lstTrainingErrorLog.add(objTrainingErrorLog);
                    classRecord=false;
                }    
            }              

            if(classRecord){

                if(!setClassId.contains(objtemp.Class_Code__c))
                {
                    listClasses.add(objtemp);
                    setClassId.add(objtemp.Class_Code__c);
                }    
            }
            
        }    
        
        if(listClasses.size()>0) 
        {      
            List<Database.UpsertResult> upsertResults = Database.upsert(listClasses, Class__c.Fields.Class_Code__c, false);//if any error needs to insert in Error Log table ..so Database.upsert();
            for(Integer i=0; i<upsertResults.size(); i++) 
            {
                if(!upsertResults.get(i).isSuccess()) 
                {
                    // DML operation failed
                    PSA_Training_Error_Log__c trainingErrorLogObj = new PSA_Training_Error_Log__c();
                    Database.Error error = upsertResults.get(i).getErrors().get(0);
                    trainingErrorLogObj.Error_Log__c = error.getMessage();
                    trainingErrorLogObj.Object_Name__c=objName;
                    trainingErrorLogObj.User_Name__c = listClasses.get(i).Instructor__c;//failed record from the list
                    lstTrainingErrorLog.add(trainingErrorLogObj);
                }
            }                       
        }
        if(lstTrainingErrorLog<>null && lstTrainingErrorLog.size()>0){
            insert lstTrainingErrorLog;
        }
    }
    //*******************************************************************************************
    //*******************************************************************************************
    if(objName == 'Training History')
    {
        List<Training_History__c> listTrainingHistory = new List<Training_History__c>();
        Set<String> setClassId = new Set<String>();
        Set<String> setContactEmailId = new Set<String>();
        Set<String> setTrainingHistoryId=new Set<String>();       
        Map<String, Class__c> mapClassId = new Map<String, Class__c>();
        Map<String, List<Contact>> mapContactId = new Map<String, List<Contact>>();//should be a list of contact to find duplicate records
        List<Contact> listTempContacts;
        boolean THRecord=false;
       

        //Get all EmailId of contacts and courseID to fetch corresponding records from salesforce
        for(Integer i = 1; i < csvRecordRow.size(); i++) 
        {
            string[] csvRecordColumn = csvRecordRow[i].split('","');
            if(csvRecordColumn.size()>=1 && csvRecordColumn[1]<>null && (csvRecordColumn[1].trim())<>'')
            {
                setContactEmailId.add(csvRecordColumn[1]);
            }
            if(csvRecordColumn.size()>=24 && csvRecordColumn[24]<>null && (csvRecordColumn[24].trim())<>'')
            {
                setClassId.add(csvRecordColumn[24]);
            }  
        }
        
        
        for(Class__c singleClass :[Select id, Class_Code__c from Class__c where Class_Code__c in :setClassId])
        {
            mapClassId.put(singleClass.Class_Code__c, singleClass);
        }
        for(Contact singleContact :[select id, email from Contact where email in :setContactEmailId])
        {
            if(mapContactId.containsKey(singleContact.email)){
                listTempContacts=mapContactId.get(singleContact.email);
            }
            else{
                listTempContacts=new List<Contact>();
            }
            listTempContacts.add(singleContact);
            mapContactId.put(singleContact.email,listTempContacts);
        }

        for(Integer i = 1; i < csvRecordRow.size(); i++) 

        {                              
            Training_History__c objtemp=new Training_History__c();
            objtemp.Sumtotal_Import_Date__c=system.now();
            
            THRecord=true;
            
            string[] csvRecordColumn = csvRecordRow[i].split('","');
            objtemp.Training_History_Code__c=csvRecordColumn[1];

            If(csvRecordColumn.size()>=23)
            {
                objtemp.Training_History_Code__c=objtemp.Training_History_Code__c+ '»' +csvRecordColumn[23];
                
            }
            if(csvRecordColumn.size()>=24)
            {
                objtemp.Training_History_Code__c=objtemp.Training_History_Code__c+ '»' +csvRecordColumn[24];

                if(mapClassId.containsKey(csvRecordColumn[24])){
                    objtemp.Class_Name__c=mapClassId.get(csvRecordColumn[24]).id;

                }    
                else
                {
                    PSA_Training_Error_Log__c objTrainingErrorLog=new PSA_Training_Error_Log__c();
                    objTrainingErrorLog.Error_Log__c='No Class exists with Name ' +csvRecordColumn[15] +' ('+'User Name: '+csvRecordColumn[1]+' » '+'Class Name: '+csvRecordColumn[15]+' » '+'Completion Date: '+csvRecordColumn[18]+')';
                    objTrainingErrorLog.Object_Name__c=objName;
                    lstTrainingErrorLog.add(objTrainingErrorLog);
                    THRecord=false;
                }    
            }
            
            if(csvRecordColumn.size()>=1)
            {
                

                if(mapContactId.containsKey(csvRecordColumn[1].toLowerCase())){
                    listTempContacts = mapContactId.get(csvRecordColumn[1].toLowerCase());
                    if(listTempContacts<>null && listTempContacts.size()==1){
                        objtemp.Contact__c=listTempContacts[0].Id;
                        
                    }
                    else{
                        //insert a record in error log
                        PSA_Training_Error_Log__c objTrainingErrorLog=new PSA_Training_Error_Log__c();
                        objTrainingErrorLog.User_Name__c=csvRecordColumn[1];
                        objTrainingErrorLog.Object_Name__c=objName;
                        objTrainingErrorLog.Error_Log__c='Duplicate contacts with same Email address ' +csvRecordColumn[1] +' ('+'User Name: '+csvRecordColumn[1]+' » '+'Class Name: '+csvRecordColumn[15]+' » '+'Completion Date: '+csvRecordColumn[18]+')';
                        lstTrainingErrorLog.add(objTrainingErrorLog);
                        THRecord=false;
                    }
                }     
                else
                {
                    //insert a record in error log
                    PSA_Training_Error_Log__c objTrainingErrorLog=new PSA_Training_Error_Log__c();
                    objTrainingErrorLog.User_Name__c=csvRecordColumn[1];
                    objTrainingErrorLog.Object_Name__c=objName;
                    objTrainingErrorLog.Error_Log__c='No contacts exists with Email address ' +csvRecordColumn[1] +' ('+'User Name: '+csvRecordColumn[1]+' » '+'Class Name: '+csvRecordColumn[15]+ ' » '+'Completion Date: '+csvRecordColumn[18]+')';
                    lstTrainingErrorLog.add(objTrainingErrorLog);
                    THRecord=false;
                }
            }
            if(csvRecordColumn.size()>=17){
                objtemp.Grade__c=csvRecordColumn[17];         
            }
            if(csvRecordColumn.size()>=18){
                objtemp.Completion_Date__c=convertDate(csvRecordColumn[18]);                
            }
            if(csvRecordColumn.size()>=19){
                objtemp.Completion_Status__c=csvRecordColumn[19];                
            }
            if(csvRecordColumn.size()>=16){
                objtemp.Registration_Date__c=convertDate(csvRecordColumn[16]);                   
            }
            if(csvRecordColumn.size()>=21){
                objtemp.Registration_Status__c=csvRecordColumn[21];                
            }   
            //grade filds needs to update
            
            if(THRecord){
               if(!setTrainingHistoryId.contains(objtemp.Training_History_Code__c))
                {
                    listTrainingHistory.add(objtemp);
                    setTrainingHistoryId.add(objtemp.Training_History_Code__c);
                }
            }
        }
 
        if(listTrainingHistory!=null && listTrainingHistory.size()>0) 
        {  
    
            List<Database.UpsertResult> upsertResults = Database.upsert(listTrainingHistory, Training_History__c.Fields.Training_History_Code__c, false);//if any error needs to insert in Error Log table ..so Database.upsert();
            for(Integer i=0; i<upsertResults.size(); i++) 
            {
                if(!upsertResults.get(i).isSuccess()) 
                {
                    // DML operation failed
                    PSA_Training_Error_Log__c trainingErrorLogObj = new PSA_Training_Error_Log__c();
                    Database.Error error = upsertResults.get(i).getErrors().get(0);
                    trainingErrorLogObj.Error_Log__c = error.getMessage();
                    String[] strEmail=(listTrainingHistory.get(i).Training_History_Code__c).split('»');
                    trainingErrorLogObj.Object_Name__c=objName;
                    trainingErrorLogObj.User_Name__c = strEmail[0];//failed record from the list
                    lstTrainingErrorLog.add(trainingErrorLogObj);
                }
            }                       
        }
        if(lstTrainingErrorLog<>null && lstTrainingErrorLog.size()>0){
            insert lstTrainingErrorLog;
        }
        
        
    }
    //*******************************************************************************************
    //*******************************************************************************************
    
    if(objName == 'Contact')
    {

        List<Contact> listContactstoUpdate = new List<Contact>();
        Set<String> setContactEmailId = new Set<String>();
        Map<String, List<Contact>> mapContactId = new Map<String, List<Contact>>();//should be a list of contact to find duplicate records
        List<Contact> listTempContacts;
        boolean ContactRecord=false;
        
        for(Integer i = 1; i < csvRecordRow.size(); i++) 
        {
            string[] csvRecordColumn = csvRecordRow[i].split('","');
            if(csvRecordColumn.size()>=1 && csvRecordColumn[1]<>null && (csvRecordColumn[1].trim())<>'')
            {
                setContactEmailId.add(csvRecordColumn[1]);
            }
        }
        
        for(Contact singleContact :[select id, email, User_Status__c from Contact where email in :setContactEmailId])
        {
            if(mapContactId.containsKey(singleContact.email)){
                listTempContacts=mapContactId.get(singleContact.email);
            }
            else{
                listTempContacts=new List<Contact>();
            }
            listTempContacts.add(singleContact);
            mapContactId.put(singleContact.email,listTempContacts);
        }
        
        for(Integer i = 1; i < csvRecordRow.size(); i++) 
        {
            Contact objTempContact;
            
            string[] csvRecordColumn = csvRecordRow[i].split('","');
            if(csvRecordColumn.size()>=2)
            {
                 if(mapContactId.containsKey(csvRecordColumn[1].toLowerCase()))
                 {
                    listTempContacts = mapContactId.get(csvRecordColumn[1].toLowerCase());
                    if(listTempContacts<>null && listTempContacts.size()==1)
                    {
                        objTempContact=listTempContacts[0];
                        objTempContact.User_Status__c=csvRecordColumn[2];
                        objTempContact.Sumtotal_Import_Date__c=system.now();
                        listContactstoUpdate.add(objTempContact);
                    }
                    else
                    {
                        //insert a record in error log
                        PSA_Training_Error_Log__c objTrainingErrorLog=new PSA_Training_Error_Log__c();
                        objTrainingErrorLog.User_Name__c=csvRecordColumn[1];
                        objTrainingErrorLog.Object_Name__c=objName;
                        objTrainingErrorLog.Error_Log__c='Duplicate contacts with same Email address ' +csvRecordColumn[1] +'';
                        lstTrainingErrorLog.add(objTrainingErrorLog);
                    }
                }     
                else
                {
                    //insert a record in error log
                    PSA_Training_Error_Log__c objTrainingErrorLog=new PSA_Training_Error_Log__c();
                    objTrainingErrorLog.User_Name__c=csvRecordColumn[1];
                    objTrainingErrorLog.Object_Name__c=objName;
                    objTrainingErrorLog.Error_Log__c='No contacts exists with Email address ' +csvRecordColumn[1] +'';
                    lstTrainingErrorLog.add(objTrainingErrorLog);
                }
            }  
        }

        if(listContactstoUpdate!=null & listContactstoUpdate.size()>0){
  
            List<Database.SaveResult> updateResults = Database.update(listContactstoUpdate, false);//if any error needs to insert in Error Log table ..so Database.upsert();
            for(Integer i=0; i<updateResults.size(); i++) 
            {
                if(!updateResults.get(i).isSuccess()) 
                {
                    // DML operation failed
                    PSA_Training_Error_Log__c trainingErrorLogObj = new PSA_Training_Error_Log__c();
                    Database.Error error = updateResults.get(i).getErrors().get(0);
                    trainingErrorLogObj.Object_Name__c=objName;
                    trainingErrorLogObj.Error_Log__c = error.getMessage();
                    trainingErrorLogObj.User_Name__c = listContactstoUpdate.get(i).email;//failed record from the list
                    lstTrainingErrorLog.add(trainingErrorLogObj);
                }
            }   
            
            
           if(lstTrainingErrorLog<>null && lstTrainingErrorLog.size()>0)
           {
            insert lstTrainingErrorLog;
           } 
            
        }
    }
}
//-----------------------------------------------------------------------------------------------------------------------------
private String calloutSumTotal(String objName)
{

    Http httpProtocol = new Http();
    HttpRequest httpRequest= new HttpRequest();
    HttpRequest httpRequestFile= new HttpRequest();
    HttpResponse httpResponse=new HttpResponse();
    AggregateResult objAggregateResult;
    DateTime lastModifiedDate;
    string headerkeyValue='header_required=true';
    SumTotalIntegration__c objDays=SumTotalIntegration__c.getValues('days to retract');
    SumTotalIntegration__c objfromDate=SumTotalIntegration__c.getValues('fromdate');
    Integer numberofDaysfromdate=(Integer)objfromDate.number_of_days__c;
    Integer noofdays=0;
    if(objDays!=null){
        noofdays=Integer.valueOf(objDays.number_of_days__c);
        noofdays=0-noofdays;
    }

        if(objName=='Course Catalog'){
            objAggregateResult=[select max(Sumtotal_Import_Date__c) lastDate from Course_Catalog__c];
        }
        if(objName=='Class'){
            objAggregateResult=[select max(Sumtotal_Import_Date__c) lastDate from Class__c];
        }
        if(objName=='Training History'){
            objAggregateResult=[select max(Sumtotal_Import_Date__c) lastDate from Training_History__c];
        }
        if(objName=='Contact'){         
            objAggregateResult=[select max(Sumtotal_Import_Date__c) lastDate from Contact where Sumtotal_Import_Date__c<>null];
        }
         system.debug('objName...'+objName);
         system.debug('objAggregateResult....'+objAggregateResult.get('lastDate'));
        
        lastModifiedDate=(DateTime)objAggregateResult.get('lastDate');
        system.debug('lastmodified------->'+lastModifiedDate);
        If(lastModifiedDate<>null){

            
            lastModifiedDate=lastModifiedDate.addDays(noofdays);
            headerkeyValue=headerkeyValue +'&since=' + lastModifiedDate.year() +'-'+ lastModifiedDate.month() +'-'+ lastModifiedDate.day() +'T00:00:00Z';
        }
        else if(numberofDaysfromdate!=0 && (objName=='Class' || objName=='Training History')){
            Date dtnow=system.today();
            Date dtsub=dtnow.addDays(0-numberofDaysfromdate);
            headerkeyValue=headerkeyValue +'&fromdate=' + dtsub.month() +'/'+ dtsub.day() +'/'+ dtsub.year() ;

            
        }
  
        system.debug('headerkeyValue------->'+headerkeyValue);
    
    SumTotalIntegration__c objSumTotal=SumTotalIntegration__c.getValues(objName);
    SumTotalIntegration__c objCredential=SumTotalIntegration__c.getValues('Credential');   
    httpRequest.setEndpoint(objSumTotal.End_Point_URL__c);
    httpRequest.setMethod('POST');
    httpRequest.setHeader('Authorization', getBasicAuthHeader(objCredential.UserName__c,objCredential.Password__c));
    httpRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    httpRequest.setHeader('Content-Length', '0');
    httpRequest.setHeader('Accept', 'text/csv');
    httpRequest.setTimeout(120000);
    httpRequest.setBody(headerkeyValue);
    
    if(Test.isRunningTest() ==false)
    {
    httpResponse = httpProtocol.send(httpRequest);
    
    system.debug('response1------>'+httpResponse);
    System.debug('RE BODY-------------->'+httpResponse.getHeader('Location'));
    
    httpRequestFile.setEndpoint(httpResponse.getHeader('Location'));
    httpRequestFile.setMethod('GET');
    httpRequestFile.setHeader('Accept', 'text/csv');
    httpRequestFile.setTimeout(120000);
    httpRequestFile.setHeader('Authorization', getBasicAuthHeader(objCredential.UserName__c,objCredential.Password__c));
    httpRequestFile.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    httpResponse = httpProtocol.send(httpRequestFile);    
    system.debug('response2--------->'+httpResponse);
    
    return httpResponse.getBody();
    }
    else
    {      
      MockHttpResponseGeneratorPsa testObj = new MockHttpResponseGeneratorPsa();
      
       string result;
      If(objName == 'Course Catalog')
      {
       result=testObj.courseCatalogObj();
      } 
      
      If(objName == 'Class')
      {
       result= testObj.classObj();
      }
      
      If(objName == 'Training History')
      {
       result= testObj.trainingHistoryObj();
      }
      
      If(objName == 'Contact')
      {
       result= testObj.contactObj();
      }            
      return result;
    }
}
//-----------------------------------------------------------------------------------------------------------------------------
private String getBasicAuthHeader(String username, String password)
{
      String authHeader = '';        
      authHeader = (username != null && password != null) ? 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password)) : '';      
      System.debug('Using Basic Authentication Header: ' + authHeader);        
      return authHeader;   
}
//-----------------------------------------------------------------------------------------------------------------------------

private Date convertDate(String strDate){
    Date dt=null;
    if(strDate!=null && strDate<>''){
        String[] dateParts=strDate.split('/');
        if(dateParts.size()>=2){
            dt=Date.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
        }
        else{
          dateParts=strDate.split('-');
          if(dateParts.size()>=2){
            dt=Date.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
            }  
        }
    }
    return dt;
    
}   
//----------------------------------------------------------------------------------------------------------------------------- 
 
}