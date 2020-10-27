public without sharing class ContractStructureController{
//Declare variables
    public String currentId;
    public List<ObjectStructureMap> asm ;
    public Map<String, ObjectStructureMap> masm;
    public List<Integer> maxLevel;
    public String strUrl {get; set;}
    public Boolean redirectNow { get; set; }
    
    //Public List<ContractShare> listshare=new  List<ContractShare>();
    //Public List<ContractTeamMember> listatm=new List<ContractTeamMember>();
   /**
    * Contructor
    */
    public ContractStructureController() {
        this.asm = new List<ObjectStructureMap>{};
        this.masm = new Map<String, ObjectStructureMap>{};
        this.maxLevel = new List<Integer>{};
        //this.strUrl = ApexPages.currentPage().getParameters().get('id');
    }
  
    /**
    * Allow page to set the current ID
    */
    public void setcurrentId( String cid ){
        currentId = cid;
    }

    /**
    * Return ObjectStructureMap to page
    * @return asm
    */
    public List<ObjectStructureMap> getObjectStructure(){
        asm.clear();
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
                al = [ SELECT a.Account.Name,a.RecordType.Name,a.Agreement_Type__c,a.ContractNumber,a.Contract_Title__c,a.Name,a.AccountId,a.Status,a.StartDate,a.EndDate, a.Term_Type__c,a.ContractTerm, a.Parent_Contract__c,(SELECT Account.Name,RecordType.Name,Term_Type__c,EndDate,ContractNumber,Contract_Title__c,Agreement_Type__c,Name,AccountId,Status,StartDate, ContractTerm, Parent_Contract__c FROM Contracts1__r ) FROM Contract a WHERE a.id IN:CurrentParent ORDER BY a.Name ];
                //al = [];
            system.debug('***alsize'+ al.size());
            }
            
            else {
                al = [ SELECT a.Account.Name,a.RecordType.Name,a.Agreement_Type__c,a.ContractNumber,a.Contract_Title__c,a.Name,a.AccountId,a.Status,a.StartDate,a.EndDate, a.Term_Type__c,a.ContractTerm, a.Parent_Contract__c,(SELECT Account.Name,RecordType.Name,Term_Type__c,EndDate,ContractNumber,Contract_Title__c,Agreement_Type__c,Name,AccountId,Status,StartDate, ContractTerm,Parent_Contract__c FROM Contracts1__r ) FROM Contract a WHERE a.Parent_Contract__c IN:CurrentParent ORDER BY a.Name ];
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
          
            Contract a = [ Select a.Account.Name,a.Id, a.Parent_Contract__c From Contract a where a.Id =: objId limit 1 ];
          
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
        
        //add
        // public List<Contract> children ;
        // public Boolean isHidden;
        // public Boolean hasChildren;
        // public Id parentId;
        
        public ObjectStructureMap( String nodeId, Boolean[] levelFlag,Boolean[] closeFlag , String nodeType, Boolean lastNode, Boolean currentNode, Contract a ){
          
            this.nodeId         = nodeId;
            this.levelFlag      = levelFlag;
            this.closeFlag      = closeFlag;
            this.nodeType       = nodeType;
            this.currentNode    = currentNode;
            this.contract = a;
            // this.parentId = a.Parent_Contract__c;
            
            // if (a.Contracts1__r != null&&!a.Contracts1__r.isEmpty()){
            //     this.children=a.Contracts1__r;
            //     this.hasChildren=true;
            // }
            // else{
            //     this.children=new List<Contract>();
            //     this.hasChildren=false;
            // }
            
        }
    }

}