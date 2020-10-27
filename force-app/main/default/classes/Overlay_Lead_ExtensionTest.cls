/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class Overlay_Lead_ExtensionTest {

    Static Country_And_Country_Code__c createCountryAndCountryCode(){  
        Country_And_Country_Code__c tstCountryAndCountryCode = new Country_And_Country_Code__c();
        tstCountryAndCountryCode.Name = 'India';
        tstCountryAndCountryCode.CurrencyIsoCode = 'USD';
        insert tstCountryAndCountryCode;
      
        return tstCountryAndCountryCode;
    }
    static List<Lead> insertLeads(){
        Country_And_Country_Code__c tstCountryCode = createCountryAndCountryCode();
        List<Lead> listLeads=new List<Lead>();

        Lead leadInstance=new Lead();
        leadInstance.Company='Test Company 123';
        leadInstance.FirstName='Test lead FirstName 123 ';
        leadInstance.LastName='Test lead LastName 123';
        leadInstance.Email='leadInstance@lead.com';
        leadInstance.Phone='343242343';
        leadInstance.Status='Not Started';
        leadInstance.Self_Reported_Fleet_Size__c=45;
        leadInstance.City='Test City';
        leadInstance.State='AL';
        leadInstance.Country=tstCountryCode.Name;
        listLeads.add(leadInstance);
        
        leadInstance=new Lead();
        leadInstance.Company='Test Company 345';
        leadInstance.FirstName='Test lead FirstName 345 ';
        leadInstance.LastName='Test lead LastName 345';
        leadInstance.Email='leadInstance@lead.com';
        leadInstance.Phone='2324324333';
        leadInstance.Status='Not Started';
        leadInstance.Self_Reported_Fleet_Size__c=21;
        leadInstance.City='Test City';
        leadInstance.State='AL';
        leadInstance.Country=tstCountryCode.Name;
        listLeads.add(leadInstance);
        
        leadInstance=new Lead();
        leadInstance.Company='Test Company 789';
        leadInstance.FirstName='Test lead FirstName 789 ';
        leadInstance.LastName='Test lead LastName 789';
        leadInstance.Email='leadInstance@lead.com';
        leadInstance.Phone='123432432311';
        leadInstance.Status='Not Started';
        leadInstance.Self_Reported_Fleet_Size__c=11;
        leadInstance.City='Test City';
        leadInstance.State='AL';
        leadInstance.Country=tstCountryCode.Name;
        listLeads.add(leadInstance);
    
        insert listLeads;
        
        return listLeads;
        
    }
    
    static testMethod void validTestCase() {
        // TO DO: implement unit test
        List<Lead> insertedLeads=insertLeads();
        
        ApexPages.StandardSetController standardLeadController=new ApexPages.StandardSetController(insertedLeads);
        
        standardLeadController.setSelected(insertedLeads);
        
        Overlay_Lead_Extension leadExtensionInstance=new Overlay_Lead_Extension(standardLeadController);
        
        //change lead values
        for(LeadWrapper leadWrapperInstance:leadExtensionInstance.selectedLeads){
            //we update only the first instance
            leadWrapperInstance.leadInstance.FirstName='Test lead FirstName 123 Updated';
            leadWrapperInstance.taskInstance.Description='Test Lead 123 task creation';
            break;
        }
        
        leadExtensionInstance.saveLeads();
        
        //compare the saved values now
        List<Lead> savedLeads=[select Id, FirstName from Lead where Id in :insertedLeads and Phone='343242343'];
        
        for(Lead leadInstance: savedLeads){
            System.assertEquals('Test lead FirstName 123 Updated',leadInstance.FirstName);
        }
       
       //check for created tasks
        List<Task> savedTasks=[select Id, Description, WhoId, Subject from Task where WhoId in :insertedLeads];
        
        //validate that only one task was created
        System.assertEquals(1,savedTasks.size());
        
        for(Task taskInstance:savedTasks){
            System.assertEquals('Test Lead 123 task creation',taskInstance.Description);
            //make sure the task is associtated with the first lead
            System.assertEquals(insertedLeads.get(0).Id,taskInstance.WhoId);
        }
   }
   
    static testMethod void inValidTestCase() {
        // TO DO: implement unit test
        List<Lead> insertedLeads=insertLeads();
        
        ApexPages.StandardSetController standardLeadController=new ApexPages.StandardSetController(insertedLeads);
        
        standardLeadController.setSelected(insertedLeads);
        
        Overlay_Lead_Extension leadExtensionInstance=new Overlay_Lead_Extension(standardLeadController);
        
        //change lead values
        for(LeadWrapper leadWrapperInstance:leadExtensionInstance.selectedLeads){
            //update the first name and last name to be blank
            leadWrapperInstance.leadInstance.FirstName='Test lead FirstName 123 Updated';
            leadWrapperInstance.leadInstance.lastName=null;
            leadWrapperInstance.taskInstance.Description='Test Lead 123 task creation';
            break;
        }
        
        PageReference ref= leadExtensionInstance.saveLeads();
        
        //validate that the page reference returned was null
        System.assertEquals(null,ref);
        
        //compare the saved values now
        List<Lead> savedLeads=[select Id, FirstName from Lead where Id in :insertedLeads and Phone='343242343'];
        
        for(Lead leadInstance: savedLeads){
            System.assertNotEquals('Test lead FirstName 123 Updated',leadInstance.FirstName);
            System.assertEquals('Test lead FirstName 123',leadInstance.FirstName);
        }
       
       //check for created tasks
        List<Task> savedTasks=[select Id, Description, Subject from Task where WhoId in :insertedLeads];
        
        //validate that only no task was created
        System.assertEquals(0,savedTasks.size());
          
   }
   
   
}