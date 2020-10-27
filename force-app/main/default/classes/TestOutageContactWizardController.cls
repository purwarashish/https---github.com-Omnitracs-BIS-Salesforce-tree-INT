/*********************************************************************
Name    : TestOutageContactWizardController
Author  : Shruti Karn
Date    : 12 April 2011

Usage   : Test class for OutageContactWizardController


*********************************************************************/
@isTest(SeeAllData=true)
private class TestOutageContactWizardController{   
static OutageContactWizardController newObj = new OutageContactWizardController();
static Account Acct = GenericTestClass.insertAccount();
static NMC_Account__c NMC = GenericTestClass.insertNMCAccount(Acct.ID);
private static testmethod void runTest(){
   
      
        newObj.redirectToStep2();
        newObj.redirectToStep3();
        list<selectOption> lstContactTypes = newObj.getContactTypes();
        newObj.retrieveNMCSystemValues();
        newObj.lstSelected_nmc_system_hardware  = new String[] {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16'};
        selectHardware();
        selectNMCSystems();
        selectPoratlSystem();
        redirecttostep4();
       
} 
    private static void selectHardware(){
        newObj.retrieveHardwarePicklistValues();
        String[] hardwareSelections = new String[] {'GT','GTL','OT','OV','OV2','OVM','OVT','OX','OX2','T2','MCP110','TT210'};
        newObj.setlstSelected_hardware(hardwareSelections);
        newObj.strNotification_topic = System.Label.HARDWARE_VALUE;
        Serialized_Units__c serUnit = GenericTestClass.insertSerUnit(Acct.ID);
        newObj.findSerUnit();
        newObj.findNMCAcct();
        newObj.findContact();
       
    }
    
     private static void selectNMCSystems(){
        newObj.strNotification_topic = System.Label.NMC_SYSTEM_VALUE;
        newObj.findNMCAcct();
        newObj.findContact();
     }
        
    private static void selectPoratlSystem()
    {
        newObj.strNotification_topic = System.Label.PORTAL_AND_SERVICES_VALUE;
        Connection_Type__c connType = GenericTestClass.insertConnType(NMC.Id);
    }
    
    private static void redirecttostep4()
    {
        String[] contactTypeSelections = new String[]{'Battery Alert', 'Downtime/Degraded', 'Newsletter', 'Portal Services Platform', 'Press', 'Product Information', 'RMA Initiator', 'Seminars/Conferences', 'SFM, Sr. Management', 'SSO Portal Administrator', 'Time Change'};
        newObj.setLstSelected_contact_types(contactTypeSelections);
        contactTypeSelections = newObj.getLstSelected_contact_types();
         newObj.alphabet = 'All';
         newObj.findContact();
         newObj.alphabetOrdering();
         newObj.redirectToStep5();
         newObj.findContact();
         newObj.next();
         newObj.previous();
         Contact cnt = GenericTestClass.insertContact(Acct.ID);
         String cntName = [Select id,name from Contact where id= : cnt.ID limit 1].name;
         newObj.search_value = cntName;
         newObj.SearchContact();
         newObj.asce = true; 
         newObj.changeOrder();
         newObj.asce = false;
         newObj.changeOrder();
         newObj.redirectToStep1();
         newObj.redirectToStep4();
         newObj.redirectToStep6();
         newObj.findConnectionType();
         newObj.findNMCAcct();
         newObj.findContact();
         newObj.updateContactRecords();
         newObj.showMsg();
         newObj.insertCampaign();
         newObj.uploadFile();
         newObj.ExporttoExcel();
         newObj.findSelContacts();
         newObj.clearFile();
         
    }
}