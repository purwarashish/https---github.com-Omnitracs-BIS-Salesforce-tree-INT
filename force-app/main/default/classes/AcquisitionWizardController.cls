public class AcquisitionWizardController {
    public integer step {get;set;}
    public Contract conForAccLookup { get;set;}
    public Account AccountId {get;set;}
    public Id accId;
    public List<cContract> contractList {get; set;}
    public Account acc {get;set;}
    public String selectedYesNo{get;set;}
    public boolean isYes {get;set;}
    public date myDate { get; set; }
    public date myDate2 { get; set; }
    public String dateOutput { get; set; } 
    public Note noteToInsert {get;set;}
    
    public AcquisitionWizardController(ApexPages.StandardController controller){
        this.step = 1;
        this.acc = (Account)controller.getRecord();
        conForAccLookup = new Contract();
        conForAccLookup.AccountId = null;
        this.selectedYesNo = '';
    }
    //This method uses a simple SOQL query to return a List of Contracts
    public List<cContract> getContracts() {
        if(contractList == null) {
            contractList = new List<cContract>();
            for(Contract c: [SELECT ContractNumber,Family_ID__c,Account.Name,Agreement_Type__c,Contract_Title__c,StartDate,EndDate,Status,Owner.IsActive,Owner.Name FROM Contract Where AccountId =: acc.Id AND Status !=: 'Inactive' AND Status !=: 'Terminated' AND Status !=: 'Canceled' ORDER BY Family_ID__c]) {
                // As each contact is processed we create a new cContact object and add it to the contactList
                contractList.add(new cContract(c));
            }
        }
        return contractList;
    }
    public List<Contract> selectedContracts {get;set;}
    
    public PageReference processSelected() {
        selectedContracts = new List<Contract>();
                //We create a new list of Contacts that we be populated only with Contacts if they are selected
        

        //We will cycle through our list of cContacts and will check to see if the selected property is set to true, if it is we add the Contact to the selectedContacts list
        for(cContract cCon: getContracts()) {
            if(cCon.selected == true) {
                selectedContracts.add(cCon.con);
                if(cCon.con.Owner.IsActive == false) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You have selected one or more contracts that have an inactive owner.  Please change the ownership of the contract(s) and try again.'));
                    return null;
                }
            }
        }
       
        // Now we have our list of selected contacts and can perform any type of logic we want, sending emails, updating a field on the Contact, etc
        System.debug('These are the selected Contacts...');
        for(Contract con: selectedContracts) {
            system.debug(con);
        }
        
        contractList=null; // we need this line if we performed a write operation  because getContacts gets a fresh list now
        return null;
    }
    
    
    
    public List<SelectOption> getYesNo() {
        List<SelectOption> yesNoOptions = new List<SelectOption>();
        yesNoOptions.add(new SelectOption('',''));
        yesNoOptions.add(new SelectOption('Yes','Yes'));
        yesNoOptions.add(new SelectOption('No','No'));
        return yesNoOptions;
    }
    
    public PageReference nextbtn(){
        // Contact conForAccLookup2 = new Contact(AccountId=conForAccLookup.AccountId);
        
        if(step==1){
            AccountId=[SELECT Id,Name FROM Account WHERE Id =: conForAccLookup.AccountId]; 
            //newAccID=[Select Id,Name FROM Account Where Id =: cp.AccountId];
            step++;            
        }
        // 
    return null;
    }
    
    public PageReference nextbtn2(){
        if(step==2){
            
            // else{
                processSelected();
                if(selectedContracts.isEmpty()){
                    step=2;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select contract/s'));
                }
                else{
                step++;
                }
            // }
        }
    return null;
    }
    
    public PageReference nextbtn3(){
        if(step==3){
            //processSelected();
            step++;
        }
        return null;
    }
    
    public Datetime dt {get;set;} 
    
    public PageReference nextbtn4(){
        //myDate=date.today();
        // dt = datetime.newInstance(myDate.year(), myDate.month(),myDate.day());
        // dateOutput = dt.format('dd/MM/yyyy');
        // myDate2 = Date.newinstance(myDate.year(), myDate.month(), myDate.day());
        // dateOutput = myDate.format('dd/MM/yyyy');
        
        if(step==4){
            noteToInsert = new Note();
            if(selectedYesNo=='Yes'){
                isYes=true;
            }
            else if(selectedYesNo=='No'){
                isYes=false;
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter value'));
                //return null;
                return null;
            }
            //processSelected();
            step++;
        }
        return null;
    }
    public PageReference finish(){
        dt = datetime.newInstance(myDate.year(), myDate.month(),myDate.day());
        dateOutput = dt.format('MM/dd/yyyy');
        Boolean hasError = false;
        //return null;
        try{
            List<Note> nList = new List<Note>();
            List<Contract> conToUpdate = new List<Contract>();
            if(selectedContracts!=null && !selectedContracts.isEmpty()){
                for(Contract c : selectedContracts){
                    Contract cn = new Contract();
                    cn.Id = c.Id;
                    cn.AccountId = AccountId.Id; 
                    cn.Bypass_Rules__c = true;
                    conToUpdate.add(cn);
                }
                System.debug('***conToUpdate1'+conToUpdate);
            }
            if(conToUpdate!=null && !conToUpdate.isEmpty()){
                System.debug('***conToUpdate2'+conToUpdate);
                update conToUpdate;
            }
            
            if(AccountId.Id!=null && acc.Id!=null){
                String Body = noteToInsert.Body;
                Note n = new Note();
                n.Title = 'Acquisition Notes : ' +AccountId.Name+ ' acquired ' + acc.Name;
                n.Body = 'Acquisition Date : ' + dateOutput + ' ' + Body;
                n.ParentId = AccountId.Id;
                
                Note n2 = new Note();
                n2.Title = 'Acquisition Notes : ' +AccountId.Name+ ' acquired ' + acc.Name;
                n2.Body = 'Acquisition Date ' + dateOutput + ' ' + Body;
                n2.ParentId = acc.Id;
                
                nList.add(n);
                nList.add(n2);
                
                Related_Accounts__c raccount = new Related_Accounts__c  (   Parent_Account__c = AccountId.Id,
                                                                            Child_Account__c = acc.Id,
                                                                            Description__c = acc.Name+' was acquired by '+AccountId.Name+ ' on '+dateOutput,
                                                                            Relationship_Type__c = 'Purchaser',
                                                                            Child_Relationship_Type__c = 'Acquired'
                                                                        );
                insert raccount;
                
            }
            
            if(nList!=null && !nList.isEmpty()){
                insert nList;
            }
            
            if(acc.Id!=null){
                if(isYes==false){
                    acc.Account_Status__c='Inactive';
                    acc.QWBS_Status__c='Inactive';
                    acc.Inactive_Reason__c='Merger/Acquisition';
                    update acc;
                }
            }
        }catch(Exception e){
            System.debug('************EXCEPTION OCCURED******************');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Exception Occured while saving the information -- '+e.getMessage()));
            hasError = true;
        }    
        
        if(!hasError){
            try{
                SpringCMRestUtils.startWorkflow('Account Acquisition', buildWorkflowXML(acc, AccountId, isYes, selectedContracts), UserInfo.getSessionId());
            }catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Exception Occured while updating Spring CRM -- '+e.getMessage()));
            }
        }
        
        PageReference ref = new PageReference('/'+acc.Id);
        ref.setRedirect(true);
        return ref;
    }
    
    public PageReference cancel(){
        PageReference ref = new PageReference('/'+acc.Id);
        ref.setRedirect(true);
        return ref;
    }
    
    public PageReference prevbtn(){
        if(step==2){
            step--;
        }
        return null;
    }
    
    public PageReference prevbtn2(){
        if(step==3){
            step--;
        }
        return null;
    }
    
    public PageReference prevbtn3(){
        if(step==4){
            step--;
        }
        return null;
    }
    
    public PageReference prevbtn4(){
        if(step==5){
            step=4;
        }
        return null;
    }
    
    public class cContract {
        public Contract con {get; set;}
        public Boolean selected {get; set;}

    
        public cContract(Contract c) {
            con = c;
            selected = false;
        }
    }
    
    private static String buildWorkflowXML(Account account, Account acquiredAccount, Boolean isYes, List <Contract> newContractList) {
        string xml = '<sfData><records>';
        xml += '<id>'+account.Id+'</id>';
        xml += '<sfType>Account</sfType>';
        xml += '<sfName>'+account.Name+'</sfName>';
        xml += '<toBeActive>'+string.valueOf(isYes)+'</toBeActive>';
        xml += '<accountThatAcquiredId>'+acquiredAccount.Id+'</accountThatAcquiredId>';
        xml += '<accountThatAcquiredName>'+acquiredAccount.Name+'</accountThatAcquiredName>';
        
        if(newContractList != null && newContractList.size() > 0){
            for(Contract newContract : newContractList){
                xml += '<selectedContract>';
                xml += '<id>' + newContract.Id + '</id>';
                xml += '<number>' +newContract.ContractNumber + '</number>';
                xml += '<sfPath>/Salesforce/Accounts/'+account.Name+'/contracts</sfPath>';
                xml += '<startDate>' +newContract.StartDate + '</startDate>';
                if(newContract.EndDate != null ){
                    xml += '<endDate>'+newContract.EndDate+'</endDate>';
                }
                xml += '<status>' +newContract.Status + '</status>';
                xml += '</selectedContract>';
            }
        }
        xml += '</records></sfData>';
        return xml;
    }
}