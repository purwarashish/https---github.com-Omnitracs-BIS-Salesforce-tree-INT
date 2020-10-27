public with sharing class GenericSearchComponentCntlr {
    static string COMMA_SEPARATOR = ',';
    static string SEMICOLON_SEPARATOR = ';';
    static integer INITIAL_LIMIT = 10;
    
    // Component parameters
    public string sColumnNames {get;set;}
    public string sSObjectName {get;set;}
    public string sCustomFilter {get;set;}
    
    // Page variables
    public list<sObject> oDisplayRecords {get;set;}
    public list<ColumnDetail> oSearchColumnDetails{get;set;}
    public string searchString {get;set;}
    
    public string sTableMsg {get;set;}
    public set<Id> accIds = new set<Id>();
    public List<Contract> accConId = new List<Contract>();
    public Id ContractID;
    // Internal variables
    Schema.SObjectType sObjType;
    Schema.SObjectField sObjQuickCreateParentField;
    
    // Used to send the link to the right dom element
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }
 
    // Used to send the link to the right dom element for the text box
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }
    
            
    public GenericSearchComponentCntlr(){
        sColumnNames = 'Name,Account_Name__c,Location_Type__c,Address_Line_1__c,Address_Line_2__c,City__c,State_Province__c,Phone_Number__c';
        sSObjectName = 'Address__c';
        searchString = system.currentPageReference().getParameters().get('lksrch');
        ContractID = System.currentPageReference().getParameters().get('id');
        List<Contract_Additional_Parties__c> lCapCon = [SELECT Id, Additional_Company__c FROM Contract_Additional_Parties__c WHERE Contract__c =: ContractID];
        system.debug('***lCapCon -' +lCapCon);
        // accIds = new set<Id>();
        if(lCapCon!=null){
            for(Contract_Additional_Parties__c c : lCapCon){
                accIds.add(c.Additional_Company__c);
            }
        }
        
        accConId = [SELECT Id,AccountId FROM Contract WHERE Id =: ContractID LIMIT 1];
        if(accConId!=null){
            accIds.add(accConId[0].AccountId);
        }
        string frm = System.currentPageReference().getParameters().get('frm');
        string txt = System.currentPageReference().getParameters().get('txt');
        system.debug('***frm- '+ frm);
        system.debug('***txt- '+ txt);
        system.debug('***ContractID- '+ ContractID);
        system.debug('***ContractID- '+ ContractID);
        system.debug('***lCapCon- '+ lCapCon);
        system.debug('***accIds- '+ accIds);
        system.debug('searchString: ' + searchString);
        if(lCapCon!=null&&accConId!=null){
            search();
        }
        system.debug('***frm- '+ frm);
        system.debug('***txt- '+ txt);
        system.debug('***ContractID- '+ ContractID);
        system.debug('***ContractID- '+ ContractID);
        system.debug('***lCapCon- '+ lCapCon);
        system.debug('***accIds- '+ accIds);
        system.debug('searchString: ' + searchString);
        // sTableMsg = 'Searching...';
        sTableMsg = '';
    }
    
    public PageReference search(){
        
        if(oSearchColumnDetails==null){
            createColumnDetails();
        }
        
        system.debug('sColumnNames: ' + sColumnNames);
        system.debug('sSObjectName: ' + sSObjectName);
        
        string soql = 'select Id, ' + sColumnNames + 
                      ' from ' + sSObjectName + 
                      ' where ((name like \'%' + 
                        searchString + '%\') or '+  
                        '(Account__r.name like \'%' + 
                        searchString + '%\')'+ ') AND Account__c In: accIds Limit 1000';
        if(sCustomFilter!=null)
            soql += (' and ' + sCustomFilter);
        system.debug('soql: ' + soql);
        
        try{
            oDisplayRecords = database.query(soql);
            if(oDisplayRecords.size()==0)
                sTableMsg = 'No record found.';
        }catch(Exception e){
            system.debug('ERROR: ' + e.getMessage());
        }
        return null;
    }
    
    public boolean gethasData(){
        boolean retVal = false;
        system.debug('hasData');
        if(oDisplayRecords!=null){
            if(oDisplayRecords.size()>0){
                retVal = true;
            }
        }
        
        system.debug('hasData retVal: ' + retVal);
        return retVal;
    }
        
    private void createColumnDetails(){
        // Describe SObject
        Map<String,Schema.SObjectType> globalDesc = Schema.getGlobalDescribe();
        sObjType = globalDesc.get(sSObjectName);
        
        // Describe SObject fields
        Schema.DescribeSObjectResult desSObjResult = sObjType.getDescribe();
        Map<String,Schema.SObjectField> sObjFields = desSObjResult.fields.getMap();
        
        // Process Search Fields only when quick create is enable.
        oSearchColumnDetails = new list<ColumnDetail>();
        list<string> columnNames = sColumnNames.split(COMMA_SEPARATOR);
        
        for(string fieldName : columnNames){
            string cleanFieldName = fieldName.trim();
                                
            if(sObjFields.containsKey(cleanFieldName)){
                Schema.SObjectField field = sObjFields.get(cleanFieldName);
                Schema.DescribeFieldResult fieldDesc = field.getDescribe();   
                 
                ColumnDetail newColumn = new ColumnDetail(fieldDesc.getName(),fieldDesc.getLabel());
                oSearchColumnDetails.add(newColumn);    
            }
        }
    }
    
    private class ColumnDetail{
        public string apiName {get;set;}
        public string dispName {get;set;}   
        public boolean isRequired {get;set;}
        
        public ColumnDetail(string apiName, string dispName){
            this.apiName = apiName;
            this.dispName = dispName;
            this.isRequired = false;
        }
    }
}