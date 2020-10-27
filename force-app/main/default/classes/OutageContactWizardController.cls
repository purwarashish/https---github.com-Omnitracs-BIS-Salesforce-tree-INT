/*********************************************************************
Name    : OutageContactWizardController
Author  : Shruti Karn
Date    : 9th August 2010

Usage   : This controller will be used by Outage contact wizard

Dependencies : Dependencies on OutageUtils

*********************************************************************/
public class OutageContactWizardController {

//===================== Variable Declaration ===========================

    public String[] lstSelected_nmc_system_hardware {get;set;} 
    public String[] lstSelected_nmc_system_portal {get;set;}
    public String[] lstSelected_nmc_system_nmc {get;set;}
    String[] lstselected_portal_and_services = new List<String>();
    String[] districtArray;
    String[] lstSelected_contact_types = new List<String>();
    String[] lstSelected_hardware = new List<String>();
    
    public Integer intContactListSize {get;set;}
    public Integer intSelContactSize {get;set;}
    public Integer intEmailTemplatesSize {get;set;}//to be removed
    public integer currentPage {get; set;}
    public Long totalPages {get;set;}
    public Integer totalRecpts {get;set;}
    Integer startIndex;
    Integer stopIndex;
    Decimal decContactListSize {get;set;}

    public String strNotification_topic {get;set;}
    public String strCustomSearch {get;set;}
    public String acctDistricts{get;set;}
    public String acct{get;set;}
    public String listofID {get;set;}
    public String alphabet {get;set;}
    public String search_Value {get;set;}
    public String current_Value {get;set;}
    String ascending;


    public Boolean asce {get;set;}
    public Boolean showProcessing{get;set;}
    public Boolean fromStep3 {get; set;}
    public Boolean saveActivity {get;set;}
    public Boolean sendEmailNow {get;set;}
    Boolean fromStep5;

    List<SelectOption> lstAllHardwareValues;
    List<SelectOption> lstAllNMCSystems;
    List<SelectOption> lstConnectionTypes;
    public List<SelectOption> lstOrgEmail {get;set;}
   
    public list<Contact> lstContact {get;set;}
    public list<Id> lstAcctId{get;set;}
    public list<Outage_Contact_Info__c> lstFinalContact{get;set;}
    public list<list<Outage_Contact_Info__c>> lstExporttoExcel {get;set;}
    private list<Id> lstTempId = new list<Id>();
    list<list<Contact>> tempList = new list<list<Contact>>();
    Map<String, String> districtToIgnoreMap = new Map<String, String>();
    map<ID,Boolean> mapRemovedCont = new map<ID,Boolean>();

    public Campaign newCampaign {get;set;}
    public Outage_Contact_Info__c newOutageID{get; set;}

    public string nameFile{get;set;}
    public Blob contentFile{get;set;}

//=====================Getters and Setters=======================================

    //--------- Retrieve Picklist Values for Contact Types ------------------------
    public List<SelectOption> getContactTypes()
    {
        //Dymanically pull the picklist for Contact Types
        Schema.DescribeFieldResult dFieldResult = Contact.Notification_Type__c.getDescribe();
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> listPickList = dFieldResult.getPicklistValues();

        for(Schema.PicklistEntry picklistEntry : listPickList)
        {
            options.add(new SelectOption(picklistEntry.getValue(),picklistEntry.getLabel()));
        }
        return options;
    }


    public void setLstSelected_contact_types(String[] contactTypeSelections)
    {
        lstSelected_contact_types = contactTypeSelections;

    }

    public List<SelectOption> getConnectionTypes()
    {
        return lstConnectionTypes;
    }

    public void setConnectionTypes(List<SelectOption> newOptions)
    {
        lstConnectionTypes = newOptions;
    }
// no need
    public String[] getLstSelected_contact_types()
    {
        return lstSelected_contact_types;
    }

    public void setHardwareItemTypes(List<SelectOption> newOptions) {
        lstAllHardwareValues = newOptions;
    }

    public List<SelectOption> getHardwareItemTypes() {
        return lstAllHardwareValues;
    }

    public void setlstSelected_hardware(String[] hardwareSelections){
        lstSelected_hardware = hardwareSelections;
    }
    public String[] getlstSelected_hardware(){
        return lstSelected_hardware;
    }

    public List<SelectOption> getNMCSystems() {
        return lstAllNMCSystems;
    }
    public void setNMCSystems(List<SelectOption> newOptions) {
        lstAllNMCSystems = newOptions;
    }

    public void setLstSelected_portal_and_services(String[] portalSrvcSelections)
    {
        lstSelected_portal_and_services = portalSrvcSelections;
    }
    public String[] getLstSelected_portal_and_services()
    {
        return lstSelected_portal_and_services;
    }

/*=======================Contructor==================================================*/

    public OutageContactWizardController()
    {
        
        lstFinalContact= new list<Outage_Contact_Info__c>();
        lstSelected_nmc_system_nmc = new List<String>();
        lstSelected_nmc_system_portal = new List<String>();
        lstSelected_nmc_system_hardware = new List<String>();
        asce = true;
        saveActivity = true;       
        currentPage = 1;
        totalpages =1;
        startIndex = 0;
        stopIndex = 100;
        alphabet = 'All Records';
        current_Value = 'Contact__r.Name';
        showProcessing = false;
        fromStep3 = true; 
        fromStep5 = false;
        ascending = 'asc';
        lstAcctId = new list<Id>();
        newOutageID = new Outage_Contact_Info__c();
        
        retrieveHardwarePicklistValues();
        retrieveNMCSystemValues();
        retrieveConnectionTypePicklistValues();
        
        Outage_Contact_Tool_Config__c configRecord = [SELECT o.Name, o.Districts_to_Exclude__c FROM Outage_Contact_Tool_Config__c o LIMIT 1];
        List<String> districtsToExcludeList = configRecord.Districts_to_Exclude__c.split(';');
        for (String districtToIgnore : districtsToExcludeList)
        {
            districtToIgnoreMap.put(districtToIgnore,districtToIgnore);
        }
    //Gather the list of divisions from the Account object
        Schema.DescribeFieldResult districtFieldResult = Account.District__c.getDescribe();
        List<Schema.PicklistEntry> districtPickList = districtFieldResult.getPicklistValues();
        for(Schema.PicklistEntry picklistEntry : districtPickList)
        {
            if (!districtToIgnoreMap.containsKey(picklistEntry.getValue()))
            {
                if(acctDistricts == null || acctDistricts == '')
                {
                    acctDistricts = picklistEntry.getValue() + '~';
                }
                else
                {
                    acctDistricts += picklistEntry.getValue() + '~';
                }
        }
    }
    //remove the last delimeter
    acctDistricts = acctDistricts.substring(0,acctDistricts.length()-1);
    districtArray = acctDistricts.split('~');

    //Initializing Campaign
    newCampaign = new Campaign();
    DateTime sysTime = system.now();
    String dt = sysTime.format('dd-MM-yy-h:mm');
    newCampaign.Name = 'Unplanned Outage Notification - '+ dt ;
    newCampaign.Status = 'Completed';
    datetime t = System.now();
    date start_Date = Date.newInstance(t.year(),t.month(),t.day());
    newCampaign.StartDate = start_Date;
    newCampaign.IsActive = true;
    newCampaign.Type = 'Email';

}

//======================Class Methods===================================================

/****************************************************************************************/

    public PageReference redirectToStep2()
    {
        //to delete all the prevoius unprocessed records
system.debug('inside redirectToStep2');
        deleteOutageIDs();
        return Page.OutageNotificationTopic;

    }

/********************************************************************************************/

    public PageReference redirectToStep1()
    {
        return Page.OutageNotificationType;
  }
  
/**********************************************************************************************/

    public PageReference redirectToStep3()
    {
        fromStep3 = true;
        fromStep5 = false;
        lstFinalContact= [Select ID , SendEmail__c , IsProcessedRecord__c from Outage_Contact_Info__c where name =: UserInfo.getUserName() and IsProcessedRecord__c = false  order by Contact__r.Name limit 10000];
        if(lstFinalContact.size()>0)
        {
            try
            {
                delete lstFinalContact;
            }
            catch(Exception e)
            {
system.debug('Failed to delete Outage Ids in redirectToStep3()'+e);
            }
        }
        if(strNotification_topic == System.Label.HARDWARE_VALUE )
            return Page.OutageHardwarePage;
        if(strNotification_topic == System.Label.PORTAL_AND_SERVICES_VALUE)
            return Page.OutagePortalsServicesSystems;
        if(strNotification_topic == System.Label.NMC_SYSTEM_VALUE)
            return Page.OutageNMCSytemPage;
        if(strNotification_topic == System.Label.CUSTOM_SEARCH)
            return Page.OutageCustomSearch;
        else
            return null;
    }

/**********************************************************************************************/

    public PageReference redirectToStep4()
    {
        showProcessing = false;
        // If the User is coming from Step3 then delete the previous records , otherwise retain them
        if(fromStep3 == true)
            deleteOutageIDs();
        if(strNotification_topic == System.Label.CUSTOM_SEARCH)
        {
               SelectedCustomSearch();
                return Page.OutageContactSelection;
        }
        else
           return Page.OutageContactSelection;
    }

/***********************************************************************************************/

    public PageReference redirectToStep5()
    {
        fromStep3 = false;
        fromStep5 = true;
        return Page.OutageCreateCampaign;
    }

/**********************************************************************************************/

    public PageReference redirectToStep6()
    {
        if(sendEmailNow == true)
                return Page.OutageSendEmail;
        else
        {
                PageReference pageRef = new PageReference('/'+newCampaign.Id);
                return pageRef;
                
        }
        
    }
    
  
/***********************************************************************************************
     Retrieve Picklist Values for Hardware
***********************************************************************************************/

    public void retrieveHardwarePicklistValues()
    {
    List<SelectOption> hardwareOptions = new List<SelectOption>();
    Schema.DescribeFieldResult dFieldResult = Serialized_Units__c.Item_Type__c.getDescribe();
    List<Schema.PicklistEntry> listPickList = dFieldResult.getPicklistValues();
    List<string> lstItemType = new list<String>();
    for (Schema.PicklistEntry picklistEntry : listPickList)
    {
        lstItemType.add(picklistEntry.getValue());
        
    }
    List<Product2> lstHardware = [Select p.Name, p.Item_Type__c From Product2 p where Item_Type__c in:lstItemType limit 10000];
    for (Product2 product : lstHardware)
    {
        hardwareOptions.add(new SelectOption(product.Item_Type__c ,product.Name));
    }
    setHardwareItemTypes(hardwareOptions);
    }

/***********************************************************************************************
     Retrieve Picklist Values for NMC System 
***********************************************************************************************/
    public void retrieveNMCSystemValues()
    {
        List<SelectOption> nmcSystem= new List<SelectOption>();
        Schema.DescribeFieldResult dFieldResult = NMC_Account__c.NMC_System__c.getDescribe();
        List<Schema.PicklistEntry> listPickList = dFieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : listPickList)
        {
            nmcSystem.add(new SelectOption(picklistEntry.getValue(),picklistEntry.getLabel()));
        }
        setNMCSystems(nmcSystem);
    }

/***********************************************************************************************
     Retrieve Picklist Values for Poratl /Services System 
***********************************************************************************************/

    public void retrieveConnectionTypePicklistValues()
    {
        lstConnectionTypes = new List<SelectOption>();
        Schema.DescribeFieldResult dFieldResult = Connection_Type__c.Connection_Type__c.getDescribe();
        List<Schema.PicklistEntry> listPickList = dFieldResult.getPicklistValues();
        for(Schema.PicklistEntry picklistEntry : listPickList)
        {
            lstConnectionTypes.add(new SelectOption(picklistEntry.getValue(),picklistEntry.getLabel()));
        }
        setConnectionTypes(lstConnectionTypes);
    }

/***********************************************************************************************
     Retrieve Picklist Values for Poratl /Services System 
***********************************************************************************************/

    public void  findSerUnit()
    {
        
        showProcessing = true;
        lstAcctId.clear();
        districtArray = acctDistricts.split('~');
        transient list<Serialized_Unit_Summary__c> lstSerUnits = new list<Serialized_Unit_Summary__c>();
        lstSerUnits = [Select s.Account__c From Serialized_Unit_Summary__c s where s.Item_Type__c in :lstSelected_hardware and
                        (s.Account__r.District__c  in: districtArray OR s.Account__r.District__c  = null)
                        AND s.Account__r.QWBS_Status__c != 'Bankrupt'
                        AND s.Account__r.QWBS_Status__c != 'Out of Business'
                        AND s.Account__r.QWBS_Status__c != 'Inactive'
                        AND s.Account__r.QWBS_Status__c != 'Inactive Prospect'
                        AND s.Account__r.QWBS_Status__c != 'Closed Bundled Customer'
                        AND s.Account__r.QWBS_Status__c != 'Closed Contract Customer'
                        AND s.Account__r.QWBS_Status__c != 'Closed MNS Customer'
                        AND s.Account__r.QWBS_Cust_ID__c != null order by s.Account__c limit 10000 ];

        for(integer i=0;i<lstSerUnits.size();i++)
        {
            lstAcctId.add(lstSerUnits[i].Account__c);
        }
       lstSerUnits.clear();
        
    }

/***********************************************************************************************
     To find list of Accounts for selected Connection Types
***********************************************************************************************/    

    public void findConnectionType()
    {
        transient List<Connection_Type__c> lstConnectionType = new List<Connection_Type__c>();
        transient List<Connection_Type__c> lstTempConnectionType = new List<Connection_Type__c>();
        list<String> tempList = new list<String>();
                
//This is implemented to avoid "retrieve id limit reached" error. Since the id list is very large, this error is shown 
//if we try to query all the portal and services at once
        
        if(lstselected_portal_and_services.size()>5)
        {
            for(integer i=0;i<lstselected_portal_and_services.size();i++)
            {
                tempList.add(lstselected_portal_and_services[i]);
                if(tempList.size() == 3)
                {
                    lstTempConnectionType =  [SELECT NMC_Account__r.Account__c , Connection_Status__c FROM Connection_Type__c
                                        WHERE (NMC_Account__r.Account__r.District__c in :districtArray OR NMC_Account__r.Account__r.District__c = null)
                                        AND NMC_Account__c in: lstAcctId
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Bankrupt'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Out of Business'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Inactive'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Inactive Prospect'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Closed Bundled Customer'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Closed Contract Customer'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Closed MNS Customer'
                                        AND NMC_Account__r.Account__r.QWBS_Cust_ID__c != null
                                        AND (Connection_Status__c != 'Disconnected' OR Connection_Status__c!='Inactive')
                                        AND Connection_Type__c in :tempList limit 10000];
                                        lstConnectionType.addAll(lstTempConnectionType.deepClone());
                    tempList.clear();
                }
            }
            if(tempList.size()>0)
            {
                lstTempConnectionType = [SELECT NMC_Account__c, NMC_Account__r.Account__c , Connection_Status__c FROM Connection_Type__c
                                        WHERE (NMC_Account__r.Account__r.District__c in :districtArray OR NMC_Account__r.Account__r.District__c = null)
                                        AND NMC_Account__c in: lstAcctId
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Bankrupt'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Out of Business'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Inactive'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Inactive Prospect'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Closed Bundled Customer'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Closed Contract Customer'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Closed MNS Customer'
                                        AND NMC_Account__r.Account__r.QWBS_Cust_ID__c != null
                                        AND (Connection_Status__c != 'Disconnected' OR Connection_Status__c!='Inactive')
                                        AND Connection_Type__c in :tempList limit 10000];
                                        lstConnectionType.addAll(lstTempConnectionType.deepClone());
            }
        }
        else
        {
            lstTempConnectionType = [SELECT NMC_Account__r.Account__c FROM Connection_Type__c
                                        WHERE (NMC_Account__r.Account__r.District__c in :districtArray OR NMC_Account__r.Account__r.District__c = null)
                                        AND NMC_Account__c in: lstAcctId
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Bankrupt'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Out of Business'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Inactive'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Inactive Prospect'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Closed Bundled Customer'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Closed Contract Customer'
                                        AND NMC_Account__r.Account__r.QWBS_Status__c != 'Closed MNS Customer'
                                        AND NMC_Account__r.Account__r.QWBS_Cust_ID__c != null
                                        AND (Connection_Status__c != 'Disconnected' OR Connection_Status__c!='Inactive')
                                        AND Connection_Type__c in :lstselected_portal_and_services limit 10000];
                                        lstConnectionType.addAll(lstTempConnectionType.deepClone());
        }

        lstAcctId.clear();
        for(integer i=0;i<lstconnectionType.size();i++)
        {
            lstAcctId.add(lstconnectionType[i].NMC_Account__r.Account__c);
        }
    }

/***********************************************************************************************
    To find the final list of Accounts from NMC.
***********************************************************************************************/ 

    public void findNMCAcct()
    {
        transient list<NMC_Account__c> lstNMC = new list<NMC_Account__c>();
        if(lstSelected_nmc_system_hardware.size() > 0 || lstSelected_nmc_system_portal.size() > 0 || lstSelected_nmc_system_nmc.size() > 0)
        {
            // For Hardware Selection
             if(lstAcctId.size()>0 && strNotification_topic == System.Label.HARDWARE_VALUE)
             {

                lstNMC = [Select Account__c From NMC_Account__c n where  NMC_System__c in:lstSelected_nmc_system_hardware
                            AND n.Account__c in :lstAcctId
                            AND n.Account__r.QWBS_Status__c != 'Bankrupt'
                            AND n.Account__r.QWBS_Status__c != 'Out of Business'
                            AND n.Account__r.QWBS_Status__c != 'Inactive'
                            AND n.Account__r.QWBS_Status__c != 'Closed Bundled Customer'
                            AND n.Account__r.QWBS_Status__c != 'Closed Contract Customer'
                            AND n.Account__r.QWBS_Status__c != 'Inactive Prospect'
                            AND n.Account__r.QWBS_Status__c != 'Closed MNS Customer'
                            AND n.Account__r.QWBS_Cust_ID__c != null
                order by n.Account__c limit 10000];
                lstAcctId.clear();
                for(integer i=0;i<lstNMC.size();i++)
                {
                    lstAcctId.add(lstNMC[i].Account__c);
                }
            }
            //For Portal Service Value
            else if(strNotification_topic == System.Label.PORTAL_AND_SERVICES_VALUE)
            {
                lstAcctId.clear();
                lstNMC = [Select Id From NMC_Account__c n where  NMC_System__c in:lstSelected_nmc_system_portal
                and n.Account__r.QWBS_Status__c != 'Bankrupt'
                            AND n.Account__r.QWBS_Status__c != 'Out of Business'
                            AND n.Account__r.QWBS_Status__c != 'Inactive'
                            AND n.Account__r.QWBS_Status__c != 'Closed Bundled Customer'
                            AND n.Account__r.QWBS_Status__c != 'Closed Contract Customer'
                            AND n.Account__r.QWBS_Status__c != 'Closed MNS Customer'
                            AND n.Account__r.QWBS_Status__c != 'Inactive Prospect'
                            AND n.Account__r.QWBS_Cust_ID__c != null
                order by n.Account__c limit 10000];
               

                for(integer i=0;i<lstNMC.size();i++)
                {
                    lstAcctId.add(lstNMC[i].Id);
                }
                lstNMC.clear();
            }
            //For NMC Systems Only
            else
            {
                lstAcctId.clear();
                lstNMC = [Select Account__c From NMC_Account__c n where  NMC_System__c in:lstSelected_nmc_system_nmc
                and n.Account__r.QWBS_Status__c != 'Bankrupt'
                            AND (n.Account__r.District__c in :districtArray OR n.Account__r.District__c = null)
                            AND n.Account__r.QWBS_Status__c != 'Out of Business'
                            AND n.Account__r.QWBS_Status__c != 'Inactive'
                            AND n.Account__r.QWBS_Status__c != 'Closed Bundled Customer'
                            AND n.Account__r.QWBS_Status__c != 'Closed Contract Customer'
                             AND n.Account__r.QWBS_Status__c != 'Inactive Prospect'
                            AND n.Account__r.QWBS_Status__c != 'Closed MNS Customer'
                            AND n.Account__r.QWBS_Cust_ID__c != null
                order by n.Account__c limit 10000];
                for(integer i=0;i<lstNMC.size();i++)
                {
                   lstAcctId.add(lstNMC[i].Account__c);
                }
            }

        }
    }

/***********************************************************************************************
     Find the list of contacts which is shown on Step 4.
***********************************************************************************************/ 

    public void findContact()
    {
        currentPage = 1;
        if(fromStep5 == true)
        {
            lstFinalContact= [Select ID , SendEmail__c , IsProcessedRecord__c  from Outage_Contact_Info__c where id in: lstTempId  order by Contact__r.Name limit 10000];
            for(integer i=0;i<lstFinalContact.size();i++)
            {
                lstFinalContact[i].IsProcessedRecord__c = false;
                lstFinalContact[i].SendEmail__c = true;
            }
            try
            {
                update lstFinalContact;
            }
            catch(Exception e)
            {
system.debug('Failed to update Outage Ids in findContact()'+e);
            }
        }
        else
        {
        
        lstContact = new list<Contact>();
        list<contact> lstTempCont = new list<contact>();
        list<contact> lstTempAcctId = new list<contact>();
        map<Id,Contact> mapTempcntct = new map<Id,Contact>();
        String DUMMY_VALUE = 'xxx'; // to avoid match in SOQL
        for (Integer i = lstSelected_contact_types.size(); i < 10; i++)
        {
            lstSelected_contact_types.add(DUMMY_VALUE);
        }

        lstContact = [Select id,email, Account.Name  from Contact where AccountId in :lstAcctId and Notification_Type__c includes (:lstSelected_contact_types[0], :lstSelected_contact_types[1], :lstSelected_contact_types[2], :lstSelected_contact_types[3], :lstSelected_contact_types[4], :lstSelected_contact_types[5], :lstSelected_contact_types[6], :lstSelected_contact_types[7], :lstSelected_contact_types[8], :lstSelected_contact_types[9])
                        and  Inactive__c = false order by name limit 10000 ];   
        //                and HasOptedOutOfEmail = false order by name limit 10000 ];

        list<Outage_Contact_Info__c> OutageId = new list<Outage_Contact_Info__c>();
        OutageId = [Select id from Outage_Contact_Info__c where name = : UserInfo.getUserName()  and IsProcessedRecord__c = false and SendEmail__c = true and Contact__c IN : lstContact limit 10000];
        if(OutageId.isEmpty()){
        for(integer i=0;i<lstContact.size();i++)
        {
            Outage_Contact_Info__c newObj = new Outage_Contact_Info__c();
            
            newObj.name  = UserInfo.getUserName();
            newObj.Contact__c = lstContact[i].Id;
            newObj.Account__c = lstContact[i].AccountId;
            newObj.Autonumber__c = i;
            OutageId.add(newObj);
        }
        }
        else{
        OutageId.clear();
        }
         try
         {
             if(!(OutageId.isEmpty()))
             insert OutageId;
         }
         catch(Exception e)
         {
system.debug('Failed to insert Outage IDS');
         }
         intContactListSize = lstContact.size();
         decContactListSize = lstContact.size();
         intSelContactSize = lstContact.size();
         lstContact = null;
         }
         pagination();
                
    }

/***********************************************************************************************
     To display 100 records per page
***********************************************************************************************/ 
 public PageReference pagination()
    {

        lstFinalContact= new list<Outage_Contact_Info__c>();
        if(decContactListSize  > 100)
        {
            Decimal pages = decContactListSize  / 100;
            totalPages = pages.round(System.RoundingMode.UP) ;
        }

        if(alphabet == 'All') // reset the values
        {
            startIndex = 0;
            stopIndex = 100;
            currentPage = 1;
            alphabet = 'All Records';
        }
        String strFinalContact = 'Select Contact__c,Contact__r.FirstName , Contact__r.Email, Account__c , SendEmail__c from Outage_Contact_Info__c where Autonumber__c >= '+ startIndex+' and Autonumber__c < '+ stopIndex+' and name = '+ '\''+ UserInfo.getUserName() + '\'' +' and IsProcessedRecord__c = false and SendEmail__c = true order by '+current_Value +' ' + ascending +' limit 100';
        lstFinalContact = database.query(strFinalContact);
        checkRemovedList();
        return null;
    }
    
    
/***********************************************************************************************
     To change the list to ascending or descending order
***********************************************************************************************/ 
    
    public void changeOrder()
    {
        if(current_Value == 'Name')
        {
            current_Value = 'Contact__r.Name';
        }
        if(asce == true)
        {
            asce = false;
            ascending = 'desc';
        }
        else
        {
            asce = true;
            ascending = 'asc';
        }

        String strFinalContact = 'Select Contact__c,Contact__r.FirstName , Contact__r.Email, Account__c , SendEmail__c from Outage_Contact_Info__c where  name = '+ '\''+ UserInfo.getUserName() + '\'' +' and IsProcessedRecord__c = false and SendEmail__c = true order by '+current_Value +' ' + ascending +' limit 100';
        lstFinalContact = database.query(strFinalContact);
    }
    
/***********************************************************************************************
     To implement Alphabet Ordering based on Contact Name
***********************************************************************************************/ 

    public void alphabetOrdering()
    {
        addRemovedList();
        checkRemovedList();
        if(!(alphabet == 'All'))
        {
            currentPage = 1;
            totalPages=1;
            String sortQuery;
            String username = UserInfo.getUserName();
            lstFinalContact= new list<Outage_Contact_Info__c>();
            sortQuery = ' and Contact__r.Name like ' +'\'' + alphabet + '%\'';

            list<Outage_Contact_Info__c> lstTempContact = new list<Outage_Contact_Info__c>();
            String strFinalContact = 'Select Contact__c,Contact__r.FirstName , Contact__r.Email, Account__c , SendEmail__c from Outage_Contact_Info__c where name = '+'\'' +UserInfo.getUserName()+'\''+' and IsProcessedRecord__c = false and SendEmail__c = true ' + sortQuery+' order by Contact__r.Name limit 100';
            lstFinalContact = database.query(strFinalContact);
            checkRemovedList();
        }
        else
            pagination();
    }

/***********************************************************************************************
    Function to serach contact based on the Contact name.
***********************************************************************************************/ 
 
    public PageReference SearchContact()
    {
        addRemovedList();
        checkRemovedList();
        currentPage = 1;
        totalPages=1;
        String searchName ='';
        if(search_Value.trim() == '' || search_value == null)
            searchName = '';
        else
            searchName =  ' and Contact__r.Name like '+'\'%'+search_value+'%\'';

      String strFinalContact = 'Select Contact__c,Contact__r.FirstName , Contact__r.Email, Account__c , SendEmail__c from Outage_Contact_Info__c where name = '+'\'' +UserInfo.getUserName()+'\''+' and IsProcessedRecord__c = false and SendEmail__c = true ' +  searchName +' order by Contact__r.Name limit 100';
      lstFinalContact = database.query(strFinalContact);
      checkRemovedList();
      findSelContacts();
     
     return null;
    }

/***********************************************************************************************
    Function to  go to next page
***********************************************************************************************/ 
  
    public Pagereference next()
    {

        addRemovedList();
        startIndex = stopIndex;
        stopIndex += 100;
        currentPage++;
        pagination();
        findSelContacts();
        return null;

    }

/***********************************************************************************************
    Function to go to previous page
***********************************************************************************************/ 

   public PageReference previous()
    {
        addRemovedList();
        stopIndex = startIndex ;
        if(startIndex>=100)
            startIndex -= 100;
        currentPage--;
        pagination();
        findSelContacts();
        return null;
    }

/***********************************************************************************************
    Function to add the contacts to a map who were deselected from the list.
***********************************************************************************************/
    public void addRemovedList()
    {
       for(integer i=0;i<lstFinalContact.size();i++)
        {
            if(lstFinalContact[i].SendEmail__c == false)
            {
                if(!(mapRemovedCont.containsKey(lstFinalContact[i].Id)))
                    mapRemovedCont.put(lstFinalContact[i].Id,lstFinalContact[i].SendEmail__c);
            }
            if(lstFinalContact[i].SendEmail__c == true)
            {
                if((mapRemovedCont.containsKey(lstFinalContact[i].Id)))
                {
                    mapRemovedCont.remove(lstFinalContact[i].Id);
                }
            }
        }
    }

/***********************************************************************************************
    Function to check if the map contains contact so that when the Contact is serached , 
     sendemial is displayed accordingly.
***********************************************************************************************/

    public void checkRemovedList()
    {
        for(integer i=0;i<lstFinalContact.size();i++)
        {
            if(mapRemovedCont.containsKey(lstFinalContact[i].Id))
                lstFinalContact[i].SendEmail__c =false;
        }
    }

/***********************************************************************************************
    Function to update "IsProcessedRecord__c = true" so that if the user again runs the wizard , 
    unique value is returened
***********************************************************************************************/
   
    public void updateContactRecords()
    {
        addRemovedList();
        lstFinalContact.clear();
        lstFinalContact= [Select ID , SendEmail__c , IsProcessedRecord__c  from Outage_Contact_Info__c where name =: UserInfo.getUserName() and IsProcessedRecord__c = false  order by Contact__r.Name limit 10000];
        for(integer i=0;i<lstFinalContact.size();i++)
        {
            lstFinalContact[i].IsProcessedRecord__c = true;
            lstTempId.add(lstFinalContact[i].Id);
        }
        try
        {
            update lstFinalContact;
        }
        catch(Exception e)
        {
system.debug('Failed to update Outage IDs');
        }
        
        lstFinalContact.clear();
        Set<Id> lstTobeUpdated = mapRemovedCont.keySet();
        list<Outage_Contact_Info__c> lstUpdateOutageID= new list<Outage_Contact_Info__c>();
        lstUpdateOutageID = [Select id,SendEmail__c from Outage_Contact_Info__c where id in :lstTobeUpdated limit 10000];
        for(integer i =0 ;i<lstUpdateOutageID.size();i++)
        {
            lstUpdateOutageID[i].SendEmail__c = false;
            lstUpdateOutageID[i].IsProcessedRecord__c = true;
        }
        try
        {
            update lstUpdateOutageID;
        }
        catch(exception e)
        {
system.debug('Failed to update list of Outage IDS in updateContactRecords()');
        }
        totalRecpts = intContactListSize - (lstUpdateOutageID.size());
       
    }
    
/***********************************************************************************************
  To show "Processing" message on the 4th Step
***********************************************************************************************/  

    public void showMsg()
    {
        showProcessing = true;
    }

/***********************************************************************************************
   To insert a new Campaign when the "Send" button is clicked
***********************************************************************************************/  

    public void insertCampaign()
    {
        try
        {
            insert newCampaign;
                            
            list<CampaignMember> lstCampMem = new list<CampaignMember>();
            lstFinalContact= [Select SendEmail__c , Contact__c, IsProcessedRecord__c from Outage_Contact_Info__c where name =: UserInfo.getUserName() and IsProcessedRecord__c = true and SendEmail__c =true and sendLater__c = false order by Contact__r.Name limit 10000];
            
            for(integer i=0;i<lstFinalContact.size();i++)
            {
                CampaignMember newObj = new CampaignMember();
                newObj.CampaignId = newCampaign.Id;
                newObj.ContactId = lstFinalContact[i].Contact__c;
                lstCampMem.add(newObj);
            }
            insert lstCampMem;
        }
        catch(Exception e)
        {
system.debug('Exception in insertCampaign():'+e);
         }
       
    }
    
/***********************************************************************************************
   To delete all the Outage IDs created by the wizard at that time
***********************************************************************************************/     
   
    public void deleteOutageIDs()
    {
        //lstFinalContact= [Select SendEmail__c , Contact__c, IsProcessedRecord__c from Outage_Contact_Info__c where name =: UserInfo.getUserName() and IsProcessedRecord__c = true and sendLater__c = false  order by Contact__r.Name limit 10000];
        //Changed the query to delete all the Outage Ids as 'Send Later' will not be used because of Exact Target Integration. 
        lstFinalContact= [Select SendEmail__c , Contact__c, IsProcessedRecord__c from Outage_Contact_Info__c where name =: UserInfo.getUserName() and IsProcessedRecord__c = true order by Contact__r.Name limit 10000];
        try
        {
            delete lstFinalContact;
        }
        catch(Exception e)
        {
system.debug('Error deleting list:'+e);
        }
      
    }
    
/***********************************************************************************************
   For Custom Search option
***********************************************************************************************/
    public void SelectedCustomSearch()
    {

        lstAcctId.clear();
        string[] lstIds = new string[]{};
        list<String> lstId = new list<String>();
    if(listofID.contains(','))
            lstIds = listofID.split(',');
        else if(listofID.contains('/r'))
            lstIds = listofID.split('/r');
        else if(listofID.contains('\n'))
            lstIds = listofID.split('\n');
        else
            lstIds.add(listofID);
        for(integer i=0;i<lstIds.size();i++)
        {
      lstId.add(lstIds[i].trim()); 
        }
        // If Company Id is entered
        if(strCustomSearch == System.Label.COMPANY_ID)
        {
            list<Account> lstAcct = [Select Id from Account where id in : lstId 
                                        and QWBS_Status__c != 'Bankrupt'
                                        AND (District__c in :districtArray OR District__c = null)
                                        AND QWBS_Status__c != 'Out of Business'
                                        AND QWBS_Status__c != 'Inactive'
                                        AND QWBS_Status__c != 'Closed Bundled Customer'
                                        AND QWBS_Status__c != 'Closed Contract Customer'
                                        AND QWBS_Status__c != 'Inactive Prospect'
                                        AND QWBS_Status__c != 'Closed MNS Customer'
                                        AND QWBS_Cust_ID__c != null limit 10000];  

            for(integer i=0;i<lstAcct.size();i++)
            {
                lstAcctId.add(lstAcct[i].Id);
            }

        }
        // If NMc Account is entered
        if(strCustomSearch == System.Label.NMC_ACCOUNT)
        {
            list<NMC_Account__c> lstNMCAcct = [Select Id,Account__c from NMC_Account__c where NMC_Account__c in:lstIds
                                                    AND Account__r.QWBS_Status__c != 'Bankrupt'
                                                    AND (Account__r.District__c in :districtArray OR Account__r.District__c = null)
                                                    AND Account__r.QWBS_Status__c != 'Out of Business'
                                                    AND Account__r.QWBS_Status__c != 'Inactive'
                                                    AND Account__r.QWBS_Status__c != 'Closed Bundled Customer'
                                                    AND Account__r.QWBS_Status__c != 'Closed Contract Customer'
                                                    AND Account__r.QWBS_Status__c != 'Inactive Prospect'
                                                    AND Account__r.QWBS_Status__c != 'Closed MNS Customer'
                                                    AND Account__r.QWBS_Cust_ID__c != null limit 10000];                                       

            for(integer i=0;i<lstNMCAcct.size();i++)
            {
                lstAcctId.add(lstNMCAcct[i].Account__c);
            }
        }
        //If Aux Id is enetered
        if(strCustomSearch == System.Label.AUX_ID)
        {
            list<NMC_Account__c> lstNMCAUXId = [SELECT Account__c FROM NMC_Account__c WHERE NMC_Aux_ID__c  in:lstIds
                                                    AND Account__r.QWBS_Status__c != 'Bankrupt'
                                                    AND (Account__r.District__c in :districtArray OR Account__r.District__c = null)
                                                    AND Account__r.QWBS_Status__c != 'Out of Business'
                                                    AND Account__r.QWBS_Status__c != 'Inactive'
                                                    AND Account__r.QWBS_Status__c != 'Closed Bundled Customer'
                                                    AND Account__r.QWBS_Status__c != 'Closed Contract Customer'
                                                    AND Account__r.QWBS_Status__c != 'Inactive Prospect'
                                                    AND Account__r.QWBS_Status__c != 'Closed MNS Customer'
                                                    AND Account__r.QWBS_Cust_ID__c != null limit 10000];

            for(integer i=0;i<lstNMCAUXId.size();i++)
            {
                lstAcctId.add(lstNMCAUXId[i].Account__c);
            }
        }
        //If CUST ID is enetred
        if(strCustomSearch == System.Label.CUST_ID)
        {

            list<Account> lstAcctCustId = [SELECT ID FROM Account WHERE QWBS_Cust_ID__c  in:lstId
                                                and QWBS_Status__c != 'Bankrupt'
                                                AND (District__c in :districtArray OR District__c =null)
                                                AND QWBS_Status__c != 'Out of Business'
                                                AND QWBS_Status__c != 'Inactive'
                                                AND QWBS_Status__c != 'Closed Bundled Customer'
                                                AND QWBS_Status__c != 'Closed Contract Customer'
                                                AND QWBS_Status__c != 'Inactive Prospect'
                                                AND QWBS_Status__c != 'Closed MNS Customer' limit 10000];

            for(integer i=0;i<lstAcctCustId.size();i++)
            {
                lstAcctId.add(lstAcctCustId[i].Id);
            }
        }
    }

/***********************************************************************************************
   To read uploaded file
***********************************************************************************************/

    public void uploadFile()
    {

        if(contentFile != null)
        {
          listofID=contentFile.toString();
            if(listofID.contains('"'))
                listofID = listofID.replace('"','');
            SelectedCustomSearch();
        }
    }

/***********************************************************************************************
   Function for Export To Excel
***********************************************************************************************/

    public void ExporttoExcel()
    {
        addRemovedList();
        Set<Id> lstTobeUpdated = mapRemovedCont.keySet();
        lstExporttoExcel =new list<list<Outage_Contact_Info__c>>();
        list<Outage_Contact_Info__c> tempLst = new list<Outage_Contact_Info__c>();
        LstFinalContact.clear();
        for(integer i=0;i<10;i++)
        {
            LstFinalContact= [Select Contact__c,Contact__r.Name , Contact__r.Email, Account__c , Account__r.Name , SendEmail__c from Outage_Contact_Info__c where name =: UserInfo.getUserName() and SendEmail__c =true and id not in : lstTobeUpdated and id not in: tempLst order by Contact__r.Name limit 1000];
system.debug('LstFinalContact:'+LstFinalContact.size());
            lstExporttoExcel.add(LstFinalContact.deepclone(true));
            tempLst.addall(LstFinalContact.deepclone(true));
        }
       
    }
/***********************************************************************************************
   Function for showing number of contacts selected
***********************************************************************************************/
   
    public void findSelContacts()
    {
        addRemovedList();
        Set<Id> lstTobeUpdated = mapRemovedCont.keySet();
        intSelContactSize = intContactListSize - (lstTobeUpdated.size());
    }

/***********************************************************************************************
   Function for clearing the path of the input file.
***********************************************************************************************/

    public void clearFile() 
    {
        contentFile = null;
        nameFile = '';
    }
    
   
}