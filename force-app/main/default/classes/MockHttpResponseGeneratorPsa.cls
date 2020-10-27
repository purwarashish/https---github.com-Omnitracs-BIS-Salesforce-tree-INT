@isTest
global class MockHttpResponseGeneratorPsa implements HttpCalloutMock {
 
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type',  'text/csv');

        res.setHeader('Location', 'url');
        
        string body;
       
     body = 'testbody';
         res.setBody(body);

        res.setStatusCode(200);
        return res;
    }
    
    
    public String courseCatalogObj()
    {
     system.debug('****** Inside mock courseCatalogObj');
    
      String body; 
       
         body = '\n'+
                '"Analytics Manager Sales Training","Analytics Manager Sales Training","OLT","Active","course_description","","","","","","","","","","","","22506846641","",""\n'+
                '"QTRACS Portal for Administrators","QTRACS Portal for Administrators","ILT","Active","course_description","","","","","","","","","","","","22506983353","",""\n'+
                '"QTRACS Portal for Administrators1","QTRACS Portal for Administrators1","UDT","Active","course_description1","","","","","","","","","","","","22506983354","",""\n'+             
                '"VAR: MCP50 Quiz","VAR: MCP50 Quiz","UDT","Inactive","course_description","","","","","","","","","","","","22507155041","",""\n';
              
      return body;
    }
    public String classObj()
    {
      
        Course_Catalog__c courseObj = new Course_Catalog__c();
       
        courseObj.Course_Code__c ='test course code';
        courseObj.Course_Name__c ='test name';
        insert courseObj;
        
        Class__c classObj = new Class__c();
        classObj.Class_Name__c='testClass2';
        classObj.Class_Code__c ='test class code';
        classObj.Course__c = courseObj.Id;
        insert classObj;
      
      String body;  
           body = '\n'+
                 '"","2090170036","","","","","Analytics Manager Sales Training","","","","","","","","","","","","","","","01/01/0001","","","","jmetcalf@omnitracs.com","","","22509365236","test course code","","","","","", "","",""\n'+
                 '"","2090170036","","","","","Analytics Manager Sales Training","","","","","","","","","","","","","","","01/01/0001","","","","jmetcalf@omnitracs2.com","","","22509365236","test course code","","","","","", "","",""\n'+
                 '"","2090170037","","","","","QTRACS Portal for Administrators","","","","","","","","","","","","","","","01/01/0002","","","","jmetcalf@omnitracs.com","","","22509365237","test course code","","","","","", "","",""\n'+               
                 '"","2090170038","","","","","QTRACS Portal for Administrators1","","","","","","","","","","","","","","","01/01/0002","","","","jmetcalf@omnitracs4.com","","","22509365238","22506983354","","","","","", "","",""\n'+
                 '"","2090178037","","","","","VAR: MCP50 Quiz","","","","","","","","","","","","","","","01/01/0003","","","","jmetcalf@omnotracs2.com","","","22509365737","test course code2","","","","","", "","",""';
      return body;
    }
      
       public String trainingHistoryObj()
    {
    
     Course_Catalog__c courseObj = new Course_Catalog__c();
        courseObj.Course_Code__c ='test course code';
        courseObj.Course_Name__c ='test name';
        insert courseObj;
        
        Class__c classObj = new Class__c();
        classObj.Class_Name__c='testClass1';
        classObj.Class_Code__c ='test class code';
        classObj.Course__c = courseObj.Id;
        insert classObj;
        
      String body;  
          body = '\n'+ 
                 '"","jmetcalf@omnitracs.com","","","","","","","","","","","","","","","01/05/2016"," ","01/08/2016","Completed","","Expired","","22507083797","test class code","","","",""\n'+
                 '"","jmetcalf@omnitracs.com","","","","","","","","","","","","","","","01/05/2016"," ","01/12/2016","Completed","","Enrolled","","22507201647","test class code2","","","",""\n'+
                 '"","jmetcalf@omnitracs2.com","","","","","","","","","","","","","","","01/05/2016"," ","01/13/2016","Completed","","Enrolled","","22507083797","test class code1","","","",""\n'+                
                 '"","jmetcalf@omnitracs4.com","","","","","","","","","","","","","","","01/05/2016"," ","01/13/2016","Completed","","Enrolled","","22507083797","22509365238","","","",""\n'+ 
                 '"","jmetcalf@omnitracs3.com","","","","","","","","","","","","","","","01/05/2016"," ","01/13/2016","Completed","","Enrolled","","22507083797","test class code2","","","",""';  
                 
      
                   return body;
    }
    
       public String contactObj()
    {
      String body;  
           body = body = '\n'+ 
                 '"819c846c-0e70-4dda-8404-34961a7ca4bc","jmetcalf@omnitracs.com","Active","","","","","","","","","","","","","","","","","","","","","",""\n'+
                 '"ae1d778c-a933-4e4d-ac75-874719b3327d","jmetcalf@omnitracs2.com","Inactive","","","","","","","","","","","","","","","","","","","","","",""\n'+
                 '"2770842e-ad2b-4f1a-9ffc-d0b1051fdbd8","jmetcalf@omnitracs3.com","Active","","","","","","","","","","","","","",""," ","","","","","","",""';
           
            return body;
    }
    
    
}