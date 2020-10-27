public class NewChildController {
    public Contract c;
    public List<Contract> cList{get;set;}
    public List<Contract_Address__c> caddList{get;set;}
    public List<Contract_Additional_Parties__c> caddParty{get;set;}
    public List<Non_Family_Linked_Contracts__c> nflconList{get;set;}
    public Id cid;
    public String query{get;set;}
    public String query2{get;set;}
    public String query3{get;set;}
    public Id eCopyId{get;set;} 
    public NewChildController(ApexPages.StandardController controller){
       cid = ApexPages.currentPage().getParameters().get('Id');
    }
    
    
    public pageReference cloneContract(){
        String SobjectApiName = 'Contract';
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
 
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
 
        query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName + ' Where ID =\''+cid+'\'';
        cList = Database.query(query);
        

        Contract eCopy = cList[0].clone(false, true, false, false);
        eCopy.status='Draft';
        // eCopy.CompanySigned=null;
        eCopy.Contract_Title__c=null;
        eCopy.Parent_Contract__c=cid;
        eCopy.External_Contract_Number__c=null;
        eCopy.Contract_Value__c=null;
        eCopy.TCM_Contract_Number__c=null;
        eCopy.IsActive__c=false;
        eCopy.Agreement_Type__c=null;
        eCopy.StartDate=null;
        eCopy.EndDate=null;
        eCopy.ContractTerm=null;
        eCopy.Term_Type__c=null;
        eCopy.Renewal_Term_Length_in_months__c=null;
        eCopy.Notice_Period_in_days__c=null;
        eCopy.OwnerExpirationNotice=null;
        eCopy.Original_Expiration_Date__c=null;
        eCopy.Original_Company__c=null;
        eCopy.Original_Contract_Manager__c=null;
        eCopy.Original_Attorney__c=null;
        eCopy.Legacy_Source_ID__c =null;
        
        insert eCopy;
        eCopyId=eCopy.Id;
        system.debug('***eC'+eCopy.Id);
        system.debug('***eCopyId'+eCopyId);
        cloneContractAddress(eCopy.Id);
        cloneContractAdditionalParties(eCopy.Id);
        cloneNFLinkedCon(eCopy.Id);
        PageReference newPage = new PageReference('/'+eCopy.id+'/e?retURL=%2F'+eCopy.id+'&00NW0000000Z1Mb=');
        return newPage.setRedirect(true);
    }
    
    public void cloneContractAddress(Id pContract){
        caddList = [SELECT Id,Account_Address__c,Address_ID__c,Address_Line_1__c,Address_Line_2__c,Attention__c,City__c,Country__c,QWBS_Cust_ID__c,Email_Address__c,Fax_Number__c,Legacy_Source_ID__c,Location_Type__c,Phone_Number__c,State_Province__c,Zip_Postal_Code__c FROM Contract_Address__c WHERE Contract__c =:cid];
        List<Contract_Address__c> cAddToInsert = new List<Contract_Address__c>();
        if((caddList!=null) && !(caddList.isEmpty())){
            for(Contract_Address__c c : caddList){
                c.Id=null;
                Contract_Address__c eCopy2 = new Contract_Address__c();
                eCopy2.Account_Address__c = c.Account_Address__c;
                eCopy2.Address_ID__c = c.Address_ID__c;
                eCopy2.Address_Line_1__c = c.Address_Line_1__c;
                eCopy2.Address_Line_2__c = c.Address_Line_2__c;
                eCopy2.Attention__c = c.Attention__c;
                eCopy2.City__c = c.City__c;
                eCopy2.Country__c = c.Country__c;
                eCopy2.QWBS_Cust_ID__c = c.QWBS_Cust_ID__c;
                eCopy2.Email_Address__c = c.Email_Address__c;
                eCopy2.Fax_Number__c = c.Fax_Number__c;
                eCopy2.Legacy_Source_ID__c = c.Legacy_Source_ID__c;
                eCopy2.Location_Type__c = c.Location_Type__c;
                eCopy2.Phone_Number__c = c.Phone_Number__c;
                eCopy2.State_Province__c = c.State_Province__c;
                eCopy2.Zip_Postal_Code__c = c.Zip_Postal_Code__c;
                eCopy2.Contract__c=pContract;
                cAddToInsert.add(eCopy2);
            }
            insert cAddToInsert;
        }
    }
    public void cloneContractAdditionalParties(Id pContract){
        caddParty = [SELECT Id,Additional_Company__c,Contract__c,Import_ID__c,Party_Effective_Date__c,Party_Expiration_Date__c,Party_Relation_Description__c,Party_Relation_Type__c,Relationship_Status__c,Search_Term_2__c FROM Contract_Additional_Parties__c WHERE Contract__c =:cid];
        List<Contract_Additional_Parties__c> cAddPInsert = new List<Contract_Additional_Parties__c>();
        if((caddParty!=null) && !(caddParty.isEmpty())){
            for(Contract_Additional_Parties__c c : caddParty){
                c.Id=null;
                Contract_Additional_Parties__c eCopy3 = new Contract_Additional_Parties__c();
                eCopy3.Additional_Company__c = c.Additional_Company__c;
                eCopy3.Import_ID__c = c.Import_ID__c;
                eCopy3.Party_Effective_Date__c = c.Party_Effective_Date__c;
                eCopy3.Party_Expiration_Date__c = c.Party_Expiration_Date__c;
                eCopy3.Party_Relation_Description__c = c.Party_Relation_Description__c;
                eCopy3.Party_Relation_Type__c = c.Party_Relation_Type__c;
                eCopy3.Relationship_Status__c = c.Relationship_Status__c;
                eCopy3.Search_Term_2__c = c.Search_Term_2__c;
                
                eCopy3.Contract__c=pContract;
                cAddPInsert.add(eCopy3);
            }
            insert cAddPInsert;
        }
    }
    public void cloneNFLinkedCon(Id pContract){
        nflconList = [SELECT Id,Contract_Project__c,Contract__c FROM Non_Family_Linked_Contracts__c WHERE Contract__c =: cid];
        List<Non_Family_Linked_Contracts__c> nfcInsert = new List<Non_Family_Linked_Contracts__c>();
        if((nflconList!=null) && !(nflconList.isEmpty())){
            for(Non_Family_Linked_Contracts__c c : nflconList){
                c.Id=null;
                Non_Family_Linked_Contracts__c nCopy = new Non_Family_Linked_Contracts__c();
                nCopy.Contract_Project__c = c.Contract_Project__c;
                nCopy.Contract__c = pContract;
                nfcInsert.add(nCopy);
            }
            insert nfcInsert;
        }
    }
    
}