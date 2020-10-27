@isTest(SeeAllData = true)
public class TestSystemOutageController{
  @isTest
  public static void testFetch(){
      System_Master__c systemMaster = new System_Master__c();
      insert systemMaster;
        
      //insert new System_Master__c(level__c = 'level - 1',inactive__c = false,Parent__c = systemMaster.Id);
      insert new System_Master__c(level__c = 'level - 2',inactive__c = false,Parent__c = systemMaster.Id);
      insert new System_Master__c(level__c = 'Level - 3',inactive__c = false,Parent__c = systemMaster.Id);    
  
      Case cse = new Case();
      insert cse;
            
      System_Outage__c systemOutage = new System_Outage__c(System_Lookup__c=systemMaster.Id,Subsystem_Lookup__c=systemMaster.Id,type__c='Unplanned Downtime',Case__c=cse.Id,Start_Time__c=System.Now(),End_Time__c=System.Now());
      insert systemOutage;
        
      //PageReference pageRef = Page.SystemOutageDetails;    
      //Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('id', systemOutage.id);
      ApexPages.currentPage().getParameters().put('CF00N50000001caGA_lkid',cse.Id);  
      ApexPages.currentPage().getParameters().put('clone', 'false');
          
      ApexPages.StandardController stdController = new ApexPages.StandardController(systemOutage);
      SystemOutageController testController = new SystemOutageController(stdController );
      
      PageReference page = testController.cancelProcess();    
      System.assertEquals('/'+cse.Id,page.getURL());

      page = testController.getDefaultTypes();
      System.assertEquals(null,page);

      /*testController.fetchSystems();
    
      testController.fetchL1Systems();    
      testController.CancelProcess();*/
        testController.BackToCase();
        testController.RedirectToOutageList();
        testController.CancelUpdate();
        testController.deleteHeader();
        testController.isUpdate = false;
        testController.getDependencies();
        //testController.getDefaultTypes();
        testController.saveRecords();
        try{
            testController.saveHeader();
            }
        catch (Exception e)
                  {
                    System.debug(e.getMessage());
                  }     
        testController.saveSummary();
        testController.editRecords();
       // testController.CloneObj();
        testController.getMoreList();
  }
  
  @isTest
  public static void testSaceRecords(){
  
      Case cse = new Case();
      insert cse;
                  
      System_Outage__c systemOutage = new System_Outage__c(type__c='Unplanned Downtime',Case__c=cse.Id,Start_Time__c=System.Now(),End_Time__c=System.Now());
      insert systemOutage;
        
      //PageReference pageRef = Page.SystemOutageDetails;    
      //Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('id', systemOutage.id);
      ApexPages.currentPage().getParameters().put('CF00N50000001caGA_lkid',cse.Id);  
      ApexPages.currentPage().getParameters().put('clone', 'false');
          
      ApexPages.StandardController stdController = new ApexPages.StandardController(systemOutage);
      SystemOutageController testController = new SystemOutageController(stdController );
    
      testController.saveRecords();
     
    }


    @isTest
    public static void testInitial(){
  
      Case cse = new Case();
      insert cse;
      
      System_Outage__c systemOutage = new System_Outage__c(type__c='Unplanned Downtime',Case__c=cse.Id,Start_Time__c=System.Now(),End_Time__c=System.Now());
      
      insert new System_Master__c(level__c = 'level - 0',inactive__c = false);
      
      //PageReference pageRef = Page.SystemOutageDetails;    
     // Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('id', systemOutage.Id);
      ApexPages.currentPage().getParameters().put('CF00N50000001caGA_lkid',cse.Id);  
      ApexPages.currentPage().getParameters().put('clone', 'false');
          
      ApexPages.StandardController stdController = new ApexPages.StandardController(systemOutage);
      SystemOutageController testController = new SystemOutageController(stdController);
      
      }
    
    @isTest
    public static void testReadOnlyMode(){
  
      Case cse = new Case();
      insert cse;
      
      System_Outage__c systemOutage = new System_Outage__c(type__c='Unplanned Downtime',Case__c=cse.Id);
      insert systemOutage;
      
      //insert new System_Master__c(level__c = 'level - 0',inactive__c = false);
      
      //PageReference pageRef = Page.SystemOutageDetails;    
      //Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('id', systemOutage.Id);
     // ApexPages.currentPage().getParameters().put('CF00N50000001caGA_lkid',null);  
     // ApexPages.currentPage().getParameters().put('clone', 'false');
          
      ApexPages.StandardController stdController = new ApexPages.StandardController(systemOutage);
      SystemOutageController testController = new SystemOutageController(stdController);        
      
      }
    
    @isTest
    public static void testReadOnlyModeWithSystemLookup(){
  
      Case cse = new Case();
      insert cse;
    
      System_Master__c systemMaster = new System_Master__c();
      insert systemMaster;
          
      System_Outage__c systemOutage = new System_Outage__c(type__c='Unplanned Downtime',Case__c=cse.Id,System_Lookup__c=systemMaster.Id,Subsystem_Lookup__c=systemMaster.Id,Start_Time__c=System.Now(),End_Time__c=System.Now());
      insert systemOutage;
      
      insert new System_Master__c(level__c = 'level - 0',inactive__c = false);
      
      //PageReference pageRef = Page.SystemOutageDetails;    
      //Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('id', systemOutage.Id);
     // ApexPages.currentPage().getParameters().put('CF00N50000001caGA_lkid',null);  
     // ApexPages.currentPage().getParameters().put('clone', 'true');
          
      ApexPages.StandardController stdController = new ApexPages.StandardController(systemOutage);
      SystemOutageController testController = new SystemOutageController(stdController);        
    
      //testController.saveHeader();
      testController.CloneObj();
  
      }
        
    
        /*public static void testCancelProcess(){    
      Case cse = new Case();
      insert cse;
      
      System_Outage__c systemOutage = new System_Outage__c(type__c='Unplanned Downtime',Case__c=cse.Id);
      insert systemOutage;
        
      //PageReference pageRef = Page.SystemOutageDetails;    
      Test.setCurrentPage(Page.SystemOutageDetails);
  
      ApexPages.currentPage().getParameters().put('id', systemOutage.Id);
      ApexPages.currentPage().getParameters().put('CF00N50000001caGA_lkid',cse.Id);
      
      ApexPages.StandardController stdController = new ApexPages.StandardController(systemOutage);
      SystemOutageController testController = new SystemOutageController(stdController);
        
      PageReference page = testController.cancelProcess();    
      System.assertEquals('/'+cse.Id,page.getURL());
    }*/

}