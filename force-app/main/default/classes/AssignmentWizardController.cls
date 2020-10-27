public without sharing class AssignmentWizardController {
    Contract cp;
    public Id accId {get;set;}
    public String accName {get;set;}
    public Id cpAccId {get;set;}
    public String selectedYesNo{get;set;}
    public Integer isStep {get; set;}
    public Account newAccID {get; set;}
    public String contrName {get; set;}
    //public Account accToUp;
    
    //Declare variables of Tree View
    public String currentId;
    public List<ObjectStructureMap> asm ;
    public Map<String, ObjectStructureMap> masm;
    public List<Integer> maxLevel;
    public Boolean isTreeShow { get; set; }
    public Boolean isNextCancel { get; set; }
    public List<AssignmentWrapper> term {get; set;}
    
    public AssignmentWizardController(ApexPages.StandardController controller){
        this.cp = (Contract)controller.getRecord();
        this.accId = [Select AccountId From Contract Where Id =: cp.Id].AccountId;
        this.contrName = [Select Contract_Title__c From Contract Where Id =: cp.Id].Contract_Title__c;
        this.selectedYesNo='No';
        this.isStep = 1;
        this.cp.AccountId = null;
        
        //Constructor of Tree View
        this.asm = new List<ObjectStructureMap>{};
        this.masm = new Map<String, ObjectStructureMap>{};
        this.maxLevel = new List<Integer>{};
        this.isTreeShow = false;
        //this.isNextCancel = true;
        this.currentId=cp.Id;
        
    }
    
    /**
    * Return ObjectStructureMap to page
    * @return asm
    */
    public List<ObjectStructureMap> getObjectStructure(){
        //COMMENT TEMPORARILY
        //asm.clear();
        if ( currentId == null ) {
            currentId = System.currentPageReference().getParameters().get('id');
        }
      
        System.assertNotEquals( currentId, null, 'sObject ID must be provided' );
       if(CurrentId !=null)
        asm = formatObjectStructure( CurrentId );
        system.debug('***ASM'+asm);
       return asm;
    }
    
    /**
    * Query Contract from top down to build the ObjectStructureMap
    * @param currentId
    * @return asm
    */
    public ObjectStructureMap[] formatObjectStructure( String currentId ){
  
        List<ObjectStructureMap> asm = new List<ObjectStructureMap>{};
        
        masm.clear();
        List<Contract> al            = new List<Contract>{};
        List<ID> currentParent      = new List<ID>{};
        Map<ID, String> nodeList    = new Map<ID, String>{};
        List<String> nodeSortList   = new List<String>{};
        List<Boolean> levelFlag     = new List<Boolean>{};
        List<Boolean> closeFlag     = new List<Boolean>{};
        String nodeId               = '0';
        String nodeType             = 'child';
        Integer count               = 0;
        Integer level               = 0;
        Boolean endOfStructure      = false;
      
        //Find highest level obejct in the structure
       if(currentId !=null)
        currentParent.add( GetTopElement(currentId) );

        //Loop though all children
        while (!endOfStructure){

            if( level == 0 ){   
                al = [ SELECT a.Account.Name,a.Agreement_Type__c,a.RecordType.Name,a.ContractNumber,a.Bypass_Rules__c, a.Contract_Title__c,a.Name,a.AccountId,a.Status,a.StartDate,a.EndDate, a.ContractTerm, a.Parent_Contract__c,(SELECT Account.Name,EndDate,RecordType.Name,Agreement_Type__c,ContractNumber,Contract_Title__c,Name,AccountId,Status,StartDate, ContractTerm, Parent_Contract__c FROM Contracts1__r ) FROM Contract a WHERE a.id IN:CurrentParent ORDER BY a.Name ];
                //al = [];
            system.debug('***alsize'+ al.size());
            }
            
            else {
                al = [ SELECT a.Account.Name,a.Agreement_Type__c,a.RecordType.Name,a.Bypass_Rules__c, a.ContractNumber,a.Contract_Title__c,a.Name,a.AccountId,a.Status,a.StartDate,a.EndDate, a.ContractTerm, a.Parent_Contract__c,(SELECT Account.Name,EndDate,RecordType.Name,Agreement_Type__c,ContractNumber,Contract_Title__c,Name,AccountId,Status,StartDate, ContractTerm, Parent_Contract__c FROM Contracts1__r ) FROM Contract a WHERE a.Parent_Contract__c IN:CurrentParent ORDER BY a.Name ];
            system.debug('***alsize2'+ al.size());
            }
            

            if( al.size()== 0 ){
                endOfStructure = true;
            }
            else{
                system.debug('***alsize3'+ al.size());
                currentParent.clear();
                for ( Integer i = 0 ; i <al.size(); i++ ){
                    Contract a = al[i];
                    nodeId = ( level > 0 ) ? NodeList.get( a.Parent_Contract__c )+'.'+String.valueOf( i ) : String.valueOf( i );
                    masm.put( NodeID, new ObjectStructureMap( nodeID, levelFlag, closeFlag, nodeType, false, false, a ) );
                    currentParent.add( a.id );
                    nodeList.put( a.id,nodeId );
                    nodeSortList.add( nodeId );
                }
              
                maxLevel.add( level );               
                level++;
            }
        }
        
      
        //Contract structure must now be formatted
        NodeSortList.sort();
        for( Integer i = 0; i < NodeSortList.size(); i++ ){
            List<String> pnl = new List<String> {};
            List<String> cnl = new List<String> {};
            List<String> nnl = new List<String> {};
          
            if ( i > 0 ){
                String pn   = NodeSortList[i-1];
                pnl         = pn.split( '\\.', -1 );
            }

            String cn   = NodeSortList[i];
            cnl         = cn.split( '\\.', -1 );

            if( i < NodeSortList.size()-1 ){
                String nn = NodeSortList[i+1];
                nnl = nn.split( '\\.', -1 );
            }
          
            ObjectStructureMap tasm = masm.get( cn );
            if ( cnl.size() < nnl.size() ){
                //Parent
                tasm.nodeType = ( isLastNode( cnl ) ) ? 'parent_end' : 'parent';
            }
            else if( cnl.size() > nnl.size() ){
                tasm.nodeType   = 'child_end';
                tasm.closeFlag  = setcloseFlag( cnl, nnl, tasm.nodeType );
            }
            else{
                tasm.nodeType = 'child';
            }
          
            tasm.levelFlag = setlevelFlag( cnl, tasm.nodeType );
          
            if (tasm.contract.id == currentId) {
                tasm.currentNode = true;
            }
            asm.add( tasm );
        }
      
        asm[0].nodeType             = 'start';
        asm[asm.size()-1].nodeType  = 'end';
      
        return asm;
    }
    
    /**
    * Determin parent elements relationship to current element
    * @return flagList
    */
    public List<Boolean> setlevelFlag( List<String> nodeElements, String nodeType ){
      
        List<Boolean> flagList = new List<Boolean>{};
        String searchNode   = '';
        String workNode     = '';
        Integer cn          = 0;
      
        for( Integer i = 0; i < nodeElements.size() - 1; i++ ){
            cn = Integer.valueOf( nodeElements[i] );
            cn++;
            searchNode  = workNode + String.valueOf( cn );
            workNode    = workNode + nodeElements[i] + '.';
            if ( masm.containsKey( searchNode ) ){
                flagList.add( true );
            }
            else {
                flagList.add( false );
            }
        }
      
        return flagList;
    }
  
    /**
    * Determin if the element is a closing element
    * @return flagList
    */
    public List<Boolean> setcloseFlag( List<String> cnl, List<String> nnl, String nodeType ){
      
        List<Boolean> flagList = new List<Boolean>{};
        String searchNode   = '';
        String workNode     = '';
        Integer cn          = 0;
      
        for( Integer i = nnl.size(); i < cnl.size(); i++ ){
            flagList.add( true );
        }
        
        return flagList;
    }
    /**
    * Determin if Element is the bottom node 
    * @return Boolean
    */
    public Boolean isLastNode( List<String> nodeElements ){
      
        String searchNode   = '';
        Integer cn          = 0;
      
        for( Integer i = 0; i < nodeElements.size(); i++ ){
            if ( i == nodeElements.size()-1 ){
                cn = Integer.valueOf( nodeElements[i] );
                cn++;
                searchNode = searchNode + String.valueOf( cn );
            }
            else {
                searchNode = searchNode + nodeElements[i] + '.';
            }
        }
        if ( masm.containsKey( searchNode ) ){
            return false;
        }
        else{
            return true;
        }
    }
  
    /**
    * Find the tom most element in Heirarchy 
    * @return objId
    */
    public String GetTopElement( String objId ){
        
        Boolean top = false;
        while ( !top ) {
            //Change below
          
            Contract a = [ Select a.Account.Name,a.Id, a.Bypass_Rules__c, a.Parent_Contract__c From Contract a where a.Id =: objId limit 1 ];
          
            if ( a.Parent_Contract__c != null ) {
                objId = a.Parent_Contract__c;
            }
            else {
                top = true;
            }
        }
        
        return objId ;
    }
    //End Of Tree View
    
    public Account getAcc() {
        Account a = [Select Id, Name From Account where Id =: accId];
        return a;
    }
    
    public List<SelectOption> getYesNo() {
        List<SelectOption> yesNoOptions = new List<SelectOption>();
        yesNoOptions.add(new SelectOption('Yes','Yes'));
        yesNoOptions.add(new SelectOption('No','No'));
        return yesNoOptions;
    }
    
    public PageReference next(){
        newAccID = new Account();
        newAccID=[Select Id,Name FROM Account Where Id =: cp.AccountId];
        //accToUp=newAccID;
        isStep++;
        return null;
    }
    
    public PageReference yes(){
        isTreeShow = true;
        isNextCancel = true;
        selectedYesNo = 'No';
        isStep = 0;
        return null;
    }
    
    public PageReference no(){
        selectedContracts = new List<Contract>();
        selectedContracts.add(cp);
        system.debug('***CON');
        //We will cycle through our list of cContacts and will check to see if the selected property is set to true, if it is we add the Contact to the selectedContacts list
        
            for(ObjectStructureMap cCon: asm) {
                if(cCon.selectd == true) {
                    selectedContracts.add(cCon.contract);
                    system.debug('***CON1');
                }
            }
    
            // Now we have our list of selected contacts and can perform any type of logic we want, sending emails, updating a field on the Contact, etc
            System.debug('These are the selected Contracts...');
            for(Contract con: selectedContracts) {
                system.debug('***CON2'+con);
            }
            asm=null; // we need this line if we performed a write operation  because getContacts gets a fresh list now
        if(selectedContracts.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select Contract to update.'));
            return null;
        }
        else{
            isTreeShow = false;
            isNextCancel = false;
            isStep = 3;
            return null;
        }
        
        // isTreeShow = true;
        // isNextCancel = true;
        // selectedYesNo = 'No';
        // isStep = 0;
        // return null;
        
        
        // Contract c = new Contract();
        // c.Id = cp.Id;
        // c.AccountId = newAccID.Id;
        // system.debug('***ACC'+newAccID);
        // system.debug('***ACC'+newAccID);
        // system.debug('***ACCID'+newAccID.Id);
        // try{
        //     update c;
        // }
        // catch(DMLException e)
        // {
        //     system.debug('***ERROR ' + e);
        // }
        // PageReference ref = new PageReference('/'+cp.Id);
        // ref.setRedirect(true);
        // return ref;
    }
    
    public PageReference cancel(){
        PageReference ref = new PageReference('/'+cp.Id);
        ref.setRedirect(true);
        return ref;
    }
    
    public List<Contract> selectedContracts {get; set;}
    
    public PageReference cont(){
        selectedContracts = new List<Contract>();
        selectedContracts.add(cp);
        system.debug('***CON');
        //We will cycle through our list of cContacts and will check to see if the selected property is set to true, if it is we add the Contact to the selectedContacts list
        
            for(ObjectStructureMap cCon: asm) {
                if(cCon.selectd == true) {
                    selectedContracts.add(cCon.contract);
                    system.debug('***CON1');
                }
            }
    
            // Now we have our list of selected contacts and can perform any type of logic we want, sending emails, updating a field on the Contact, etc
            System.debug('These are the selected Contracts...');
            for(Contract con: selectedContracts) {
                system.debug('***CON2'+con);
            }
            asm=null; // we need this line if we performed a write operation  because getContacts gets a fresh list now
        if(selectedContracts.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select Contract to update.'));
            return null;
        }
        else{
            isTreeShow = false;
            isNextCancel = false;
            isStep = 3;
            return null;
        }
    }
    
    public List<AssignmentWrapper> getContracts() {
        Set<Id> sConIds = new Set<Id>();
        system.debug('****SELCON '+selectedContracts);
        for(Contract c:selectedContracts){
            sConIds.add(c.Id);
        }
        system.debug('sConIds '+sConIds);
        if(term == null) {
            term = new List<AssignmentWrapper>();
            for(Contract con: [select Account.Name,RecordType.Name,ContractNumber,Contract_Title__c,Bypass_Rules__c,Name,AccountId,Status,StartDate,EndDate,ContractTerm, Parent_Contract__c from Contract where Id In: sConIds]) {
                term.add(new AssignmentWrapper(con,accId,con.Status));
            }
        }
        System.debug('***term '+term);
        return term;
    }

    public PageReference finish(){
        List<Contract> contractsToUpdate = new List<Contract>();
        Boolean hasError = false;
        for(AssignmentWrapper t: getContracts()) {
            //if(t.Status != 'Active') {
                Contract c = new Contract();
                c.Id = t.contract.Id;
                c.AccountId = newAccID.Id;
                c.Bypass_Rules__c = true;
                contractsToUpdate.add(c);
            //}
            System.debug('***contractsToUpdate '+contractsToUpdate);
        }
        if(contractsToUpdate!=null && !contractsToUpdate.isEmpty()){
            try{
                update contractsToUpdate;
            }
            catch(DMLException e){
                System.debug('--- DMLERROR'+e);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Exception Occured while updating the contracts -- '+e.getMessage()));
                hasError = true;
            }
            
            if(!hasError){
	        	try{
	        		SpringCMRestUtils.startWorkflow('Contract Assignment', buildWorkflowXML(getAcc(), newAccID, contractsToUpdate), UserInfo.getSessionId());
	        	}catch(Exception e){
	        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Exception Occured while updating Spring CRM -- '+e.getMessage()));
	        	}
	        }
        }   
        PageReference ref = new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
        ref.setRedirect(true);
        return ref;
    }
    
    public PageReference back(){
        isTreeShow = false;
        isNextCancel = false;
        selectedYesNo = 'Yes';
        isStep = 2;
        return null;
    }
    
    public PageReference back2(){
        term = null;
        isTreeShow = true;
        isNextCancel = true;
        selectedYesNo = 'No';
        isStep = 0;
        return null;
    }
    
    
    /**
    * Wrapper class
    */
    public without sharing class ObjectStructureMap{

        public String nodeId;
        public Boolean[] levelFlag = new Boolean[]{};
        public Boolean[] closeFlag = new Boolean[]{};
        public String nodeType;
        public Boolean currentNode;
        public Contract contract;
        public String getnodeId() { return nodeId; }
        public Boolean[] getlevelFlag() { return levelFlag; }
        public Boolean[] getcloseFlag() { return closeFlag; }
        public String getnodeType() { return nodeType; }
        public Boolean getcurrentNode() { return currentNode; }
        public Contract getcontract() { return contract; }
        public void setnodeId( String n ) { this.nodeId = n; }
        public void setlevelFlag( Boolean l ) { this.levelFlag.add(l); }
        public void setlcloseFlag( Boolean l ) { this.closeFlag.add(l); }
        public void setnodeType( String nt ) { this.nodeType = nt; }
        public void setcurrentNode( Boolean cn ) { this.currentNode = cn; }
        public void setcontract( Contract a ) { this.contract = a; }
        public Boolean selectd {get; set;}
   
        public ObjectStructureMap( String nodeId, Boolean[] levelFlag,Boolean[] closeFlag , String nodeType, Boolean lastNode, Boolean currentNode, Contract a){
          
            this.nodeId         = nodeId;
            this.levelFlag      = levelFlag;
            this.closeFlag      = closeFlag;
            this.nodeType       = nodeType;
            this.currentNode    = currentNode;
            this.contract = a;
            if(ApexPages.currentPage().getParameters().get('id')==a.Id)
            {
            selectd       = true;
            }
            else{
            selectd       = false;    
            }
        }
    }
    public without sharing class AssignmentWrapper{
        public Contract contract;
        public Contract getcontract() { return contract; }
        public void setcontract( Contract c ) { this.contract = c; }
        public Id accountId;
        public String status;
        
        public AssignmentWrapper(Contract c, Id acc, String s){
            this.contract = c;
            this.accountId = acc;
            this.status = s;
        }
    }
    
     private static String buildWorkflowXML(Account account, Account acquiredAccount, List <Contract> newContractList) {
		string xml = '<sfData><records>';
		xml += '<id>'+account.Id+'</id>';
		xml += '<sfType>Account</sfType>';
		xml += '<sfName>'+account.Name+'</sfName>';
		xml += '<accountThatAcquiredId>'+acquiredAccount.Id+'</accountThatAcquiredId>';
		xml += '<accountThatAcquiredName>'+acquiredAccount.Name+'</accountThatAcquiredName>';
		
		if(newContractList != null && newContractList.size() > 0){
			for(Contract newContract : newContractList){
				xml += '<selectedContract>';
				xml += '<id>' + newContract.Id + '</id>';
				xml += '<number>' +newContract.ContractNumber + '</number>';
				xml += '<sfPath>/Salesforce/Accounts/'+account.Name+'/contracts</sfPath>';
				xml += '</selectedContract>';
			}
		}
		xml += '</records></sfData>';
		return xml;
	}
}