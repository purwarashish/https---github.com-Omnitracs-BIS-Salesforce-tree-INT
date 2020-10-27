/**********

Project Task    05_Develop_Public Form for Request Submission   Sripathi Gullapalli     5/23/2016             Controller to process Request form information and create "Requestion Form" and "Request Form Contact" data
***********/
public with sharing class RequestFormController {
    
    public Request_Form__c requestForm {get;set;}
    public Request_Form_Contact__c requestor {get;set;}
    //public Request_Form_Contact__c additionalEmployee1 {get;set;}
    //public Request_Form_Contact__c additionalEmployee2 {get;set;}
    public Request_Form_Contact__c firstParty {get;set;}
    //public Request_Form_Contact__c secondParty {get;set;}
    //public Request_Form_Contact__c thirdParty {get;set;}
    public List<Request_Form_Contact__c> additionalEmployees {get;set;}
    public List<Request_Form_Contact__c> otherPartyContacts {get;set;}
    public List<SelectOption> primaryReasons {get;set;}
    public List<SelectOption> requestForAmendment {get;set;}
    public List<SelectOption> confidentialParties {get;set;}
    public List<SelectOption> confidentialContractors {get;set;}
    public List<SelectOption> includeAffiliates {get;set;}
    public List<SelectOption> additionalSelections {get;set;}
    public Integer numberOfAdditionalEmployees {get;set;}
    public Integer numberOfOtherContacts {get;set;}
    public Boolean submitSuccessfull {get;set;}
    public RequestFormController(){
        
    }
    
    //Initializing the data
    public void init(){
        requestForm = new Request_Form__c();
        requestor = new Request_Form_Contact__c();
        //additionalEmployee1 = new Request_Form_Contact__c();
        //additionalEmployee2 = new Request_Form_Contact__c();
        firstParty = new Request_Form_Contact__c(Country__c='United States');
        //secondParty = new Request_Form_Contact__c();
        //thirdParty = new Request_Form_Contact__c();
        
        additionalEmployees = new List<Request_Form_Contact__c>();
        otherPartyContacts = new List<Request_Form_Contact__c>();
        numberOfAdditionalEmployees = 1;
        numberOfOtherContacts = 1;
        primaryReasons = getTypes('Primary_reason__c');
        requestForAmendment = getTypes('Request_For_Amendment__c');
        confidentialParties = getTypes('Confidential_Information_Parties__c');
        confidentialContractors = getTypes('Confidential_Information_Contractors__c');
        includeAffiliates = getTypes('Include_affiliates__c');
        submitSuccessfull = false;
        
    }
    
    //method used to get data from picklist fields, used for radio button display
    public List<SelectOption> getTypes(String fieldName){
        Schema.sObjectType sobject_type = Request_Form__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();
        for (Schema.PicklistEntry a : pick_list_values) {
            options.add(new selectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }
    
    public Pagereference addAdditionalEmployees(){
        numberOfAdditionalEmployees = (numberOfAdditionalEmployees != null)?numberOfAdditionalEmployees:1;
        for(Integer i = 0; i<numberOfAdditionalEmployees; i++){
            additionalEmployees.add(new Request_Form_Contact__c());
        }
        return null;
    }
    
    public Pagereference addOtherPartyContacts(){
        Request_Form_Contact__c rfca;
        numberOfOtherContacts = (numberOfOtherContacts != null)?numberOfOtherContacts:1;
        for(Integer i = 0; i<numberOfOtherContacts; i++){
            if(otherPartyContacts.size() == 0){
                rfca = new Request_Form_Contact__c(Party_Number__c = 'Second', Country__c='United States');
            }
            else if(otherPartyContacts.size() == 1){
                rfca = new Request_Form_Contact__c(Party_Number__c = 'Third', Country__c='United States');
            }
            else if(otherPartyContacts.size() == 2){
                rfca = new Request_Form_Contact__c(Party_Number__c = 'Fourth', Country__c='United States');
            }
            else if(otherPartyContacts.size() == 3){
                rfca = new Request_Form_Contact__c(Party_Number__c = 'Fifth', Country__c='United States');
            }
            else if(otherPartyContacts.size() == 4){
                rfca = new Request_Form_Contact__c(Party_Number__c = 'Sixth', Country__c='United States');
            }
            else if(otherPartyContacts.size() == 5){
                rfca = new Request_Form_Contact__c(Party_Number__c = 'Seventh', Country__c='United States');
            }
            else{
                rfca = new Request_Form_Contact__c(Party_Number__c = 'Additional', Country__c='United States');
            }
            otherPartyContacts.add(rfca);
        }
        return null;
    }
    
    public Pagereference clear(){
        return new Pagereference('/apex/RequestForm');
    }
    
    //Submitting the request
     public Pagereference submit(){
        try{
            if(validateForm()){
                insert requestForm;
                
                Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Request_Form_Contact__c.getRecordTypeInfosByName();
                List<Request_Form_Contact__c> rfcList = new List<Request_Form_Contact__c>();
                //Only creating form contacts if the name is entered
                if(String.isNotBlank(requestor.name__c)){
                    requestor.Request_Form__c = requestForm.Id;
                    requestor.Type__c = 'Requestor';
                    requestor.recordTypeId=rtMapByName.get('Requestor').getRecordTypeId();
                    requestor.State_Province__c = requestor.State_Province_PL__c;
                    rfcList.add(requestor);
                }
                for(Request_Form_Contact__c rfc : additionalEmployees){
                    if(String.isNotBlank(rfc.name__c)){
                        rfc.Request_Form__c = requestForm.Id;
                        rfc.Type__c = 'Requestor';
                        rfc.recordTypeId=rtMapByName.get('Requestor').getRecordTypeId();
                        rfc.State_Province__c = rfc.State_Province_PL__c;
                        rfcList.add(rfc);
                    }
                }
                
                if(String.isNotBlank(firstParty.name__c)){
                    firstParty.Multiparty__c = requestForm.Id;
                    firstParty.Type__c = 'First Party';
                    firstParty.recordTypeId=rtMapByName.get('Multi Party').getRecordTypeId();
                    firstParty.State_Province__c = firstParty.State_Province_PL__c;
                    getAccountAndContacts(firstParty);
                    getAuthorizedSigner(firstParty);
                   
                    rfcList.add(firstParty);
                }
                for(Request_Form_Contact__c rfc : otherPartyContacts){
                    if(String.isNotBlank(rfc.name__c)){
                        rfc.Multiparty__c = requestForm.Id;
                        rfc.Type__c = 'Additional Employee';
                        rfc.recordTypeId=rtMapByName.get('Multi Party').getRecordTypeId();
                        rfc.State_Province__c = rfc.State_Province_PL__c;
                        getAccountAndContacts(rfc);
                        rfcList.add(rfc);
                    }
                }
             
                insert rfcList;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Request submitted successfully.'));
                submitSuccessfull = true;
             }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Exception occured while submitting the request -- '+e.getMessage()));
        }
        return null;
     }
     
     private void getAccountAndContacts(Request_Form_Contact__c rfc){
        if(String.isNotBlank(rfc.company__c)){

            List<Account> accntList = [select Id, Name, Legal_name__c , (select Id, State_Province__c from Addresses__r where Location_Type__c = 'Corporate HQ'),
                                                        (select Id, Name, FirstName , LastName, Email from Contacts)  
                                         from Account where Name = :rfc.company__c or Legal_name__c = :rfc.company__c];
            if(accntList != null){
                List<Contact> cntctList;
                if(accntList.size() == 1){
                    rfc.account_associated__c = accntList.get(0).Id;
                    cntctList = accntList.get(0).contacts;
                }
                else if(accntList.size() > 1){
                    for(Account accnt : accntList){
                        if(accnt.Addresses__r != null && accnt.Addresses__r.size() > 0){
                            rfc.account_associated__c = accnt.Id;
                            cntctList = accnt.contacts;
                            break;
                        }
                    }
                }
                
                if(cntctList != null && cntctList.size() > 0){
                    List<Contact> foundContacts = new List<Contact>();
                    for(Contact cntct : cntctList){
                        if(cntct.firstname == rfc.First_Name__c && cntct.lastname == rfc.Name__c){
                            foundContacts.add(cntct);
                        }
                    }
                    
                    if(foundContacts.size() == 1){
                        rfc.contact_associated__c = foundContacts.get(0).Id;
                    }
                    else if(foundContacts.size() > 1){
                        for(Contact cntct : foundContacts){
                            if(cntct.email == rfc.email__c){
                                rfc.contact_associated__c = cntct.Id;
                                return;
                            }
                        }
                    }
                }
            }
        }
        
        
     }
     private void getAuthorizedSigner(Request_Form_Contact__c rfc){
        
        if(String.isNotBlank(rfc.Authorized_First_Party_Signer__c)){
            List<Contact> cntctList = [select Id, email from Contact where Name = :rfc.Authorized_First_Party_Signer__c];
            if(cntctList.size() == 1){
                rfc.Authorized_Signer__c = cntctList.get(0).Id;
            }
            else if(cntctList.size() > 1){
                for(Contact cntct : cntctList){
                    if(cntct.email == rfc.Authorized_First_Party_Email__c){
                        rfc.Authorized_Signer__c = cntct.Id;
                    }
                }
            }
        }
     }
     
     private Boolean validateForm(){
        Boolean result = true;
        if(String.isBlank(requestForm.Primary_reason__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Primary reason for NDA: You must enter a value'));
            result = false;
        }
        if(String.isBlank(requestForm.Request_For_Amendment__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Is this request for an amendment to an existing NDA: You must enter a value'));
            result = false;
        }
        if(String.isBlank(requestForm.Confidential_Information_Parties__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Which parties will be sharing their confidential information: You must enter a value'));
            result = false;
        }
        if(String.isBlank(requestForm.Confidential_Information_Contractors__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Subcontractors or consultants who need to receive confidential information: You must enter a value'));
            result = false;
        }
        if(String.isBlank(requestForm.Include_affiliates__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Will the NDA need to include affiliates or subsidiaries of the outside party: You must enter a value'));
            result = false;
        }
        return result;
     }
}