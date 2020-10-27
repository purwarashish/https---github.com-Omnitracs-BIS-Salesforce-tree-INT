public without sharing class ContractTerminateController{
//Declare variables
    public String currentId;
    public List<ObjectStructureMap> asm ;
    public Map<String, ObjectStructureMap> masm;
    public List<Integer> maxLevel;
    public String strUrl {get; set;}
    public Boolean redirectNow { get; set; }
    public Boolean isTreeShow { get; set; }
    public List<TerminateWrapper> term {get; set;}
    private Integer nextIdent=0;
    
   /**
    * Contructor
    */
    public ContractTerminateController() {
        this.asm = new List<ObjectStructureMap>{};
        this.masm = new Map<String, ObjectStructureMap>{};
        this.maxLevel = new List<Integer>{};
        this.isTreeShow = true;
        
    }
  
    /**
    * Allow page to set the current ID
    */
    public void setcurrentId( String cid ){
        currentId = cid;
    }

    /**
    * Return contractlist in page to terminate
    * @return contractlist
    */
    
    public List<TerminateWrapper> getContracts() {
        Set<Id> sConIds = new Set<Id>();
        system.debug('****SELCON '+selectedContracts);
        for(Contract c:selectedContracts){
            sConIds.add(c.Id);
        }
        system.debug('sConIds '+sConIds);
        if(term == null) {
            term = new List<TerminateWrapper>();
            Note n = new Note();
            for(Contract con: [select Account.Name,RecordType.Name,Bypass_Rules__c, ContractNumber,Contract_Title__c,Name,AccountId,Status,StartDate,EndDate,ContractTerm, Parent_Contract__c from Contract where Id In: sConIds]) {
                term.add(new TerminateWrapper(con,n,con.Status));
            }
        }
        System.debug('***term '+term);
        return term;
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
                al = [ SELECT a.Account.Name,a.Agreement_Type__c,a.RecordType.Name,a.Bypass_Rules__c, a.ContractNumber,a.Contract_Title__c,a.Name,a.AccountId,a.Status,a.StartDate,a.EndDate, a.ContractTerm, a.Parent_Contract__c,(SELECT Account.Name,EndDate,RecordType.Name,Agreement_Type__c,ContractNumber,Contract_Title__c,Name,AccountId,Status,StartDate, ContractTerm, Parent_Contract__c FROM Contracts1__r ) FROM Contract a WHERE a.id IN:CurrentParent ORDER BY a.Name ];
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
    /**
    * Next button Function
    * @return null
    */
    public List<Contract> selectedContracts {get; set;}
    public PageReference Next(){
        selectedContracts = new List<Contract>();
        
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
        isTreeShow = false;
        return null;
    }
    
    public PageReference Cancel(){
        if(isTreeShow == false){
            isTreeShow = true;
            return null;
        }
        else{
            PageReference ref = new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
            ref.setRedirect(true);
            return ref;
        }
    }
    
    public PageReference Save(){
        List<Contract> contractsToUpdate = new List<Contract>();
        List<Note> notesToInsert = new List<Note>();
        String noteBody;
        for(TerminateWrapper t: getContracts()) {
            if(t.Status != 'Inactive') {
                Contract c = new Contract();
                c.Id = t.contract.Id;
                c.Status = 'Inactive';
                c.Bypass_Rules__c = true;
                
                Note n = new Note();
                n.ParentId = c.Id;
                n.Title = 'Termination Notes';
                noteBody = t.noteBody;
                n.Body = noteBody;
                
                contractsToUpdate.add(c);
                notesToInsert.add(n);
            }
            System.debug('***contractsToUpdate '+contractsToUpdate);
            System.debug('***notesToInsert '+notesToInsert);
        }
        if(contractsToUpdate!=null && !contractsToUpdate.isEmpty() && notesToInsert!=null && !notesToInsert.isEmpty()){
            try{
                update contractsToUpdate;
                insert notesToInsert;
            }
            catch(DMLException e){
                System.debug('DMLERROR'+e);
            }
        }   
        PageReference ref = new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
        ref.setRedirect(true);
        return ref;
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
            selectd       = false;
        }
    }
    
    public without sharing class TerminateWrapper{
        public Contract contract;
        public Contract getcontract() { return contract; }
        public void setcontract( Contract c ) { this.contract = c; }
        public Note notes {get;set;}
        public String noteBody {get;set;}
        public String status;
        public Integer ident {get; private set;}
        
        public TerminateWrapper(Contract c, Note n, String s){
            this.contract = c;
            this.notes = n;
            this.status = s;
            this.noteBody = n.Body;
            //this.ident=inIdent;
        }
    }
}