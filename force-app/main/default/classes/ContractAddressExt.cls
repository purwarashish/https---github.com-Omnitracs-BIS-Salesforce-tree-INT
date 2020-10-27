public with sharing class ContractAddressExt {
    Public Contract_address__c ca;
    Contract_address__c CAddr;
    public ContractAddressExt(ApexPages.StandardController controller) {
        CAddr = new Contract_address__c();
        this.ca = (Contract_address__c)controller.getRecord();
        CAddr = this.ca;
        // GenericSearchComponentCntlr.lCAP(this.CAddr.Contract__c);
    }

    public pageReference ResetAddress(){
        //Address__c a = new  Address__c();
        for ( Address__c a : [SELECT Account__c, Address_ID__c, Name, Address_Line_1__c, Address_Line_2__c, Attention__c, City__c, Company_ID__c, 
                        Country__c, CreatedById, CreatedDate, CurrencyIsoCode, QWBS_Cust_ID__c, IsDeleted, Email_Address__c, Fax_Number__c, 
                        LastModifiedById, LastModifiedDate, Location_Type__c, OwnerId, Phone_Number__c, ConnectionReceivedId, Id, 
                        ConnectionSentId, State_Province__c, SystemModstamp, Zip_Postal_Code__c FROM Address__c where id = :ca.Account_Address__c limit 1]){
              ca.address_line_1__c = a.Address_Line_1__c;
              ca.Address_Line_2__c = a.Address_Line_2__c;
              ca.Attention__c =  a.Attention__c;
              ca.City__c = a.City__c;
              ca.Country__c = a.Country__c;
              ca.Location_Type__c = a.Location_Type__c;
              ca.Zip_Postal_Code__c = a.Zip_Postal_Code__c;
              ca.Email_Address__c = a.Email_Address__c; 
              ca.Fax_Number__c = a.Fax_Number__c;
              ca.phone_Number__c = a.phone_Number__c;
              ca.State_Province__c = a.State_Province__c;
          }
        return null;
    }
    public string getKeyPrfx(){
        Schema.DescribeSObjectResult r = Address__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        System.debug('Printing --'+keyPrefix );
        return keyPrefix;
    }
    public pageReference SaveAndNew(){
        //Save the record and open the page to create a new one
        try {
          insert ca;
          //redirect to new record
          string Num = ApexPages.currentPage().getParameters().get('ContractNum');
          PageReference ContractAddrPage = new PageReference('/apex/ContractAddress?CF00NW0000000Z9LH='+Num+'&CF00NW0000000Z9LH_lkid='+ca.Contract__c);
          
          ContractAddrPage.getParameters().put('CntractNum', Num);
          //ContractAddrPage.getParameters().put('CF00NW0000000Z9LH_lkid', ca.Contract__c);

            ContractAddrPage.setRedirect(true);
            return ContractAddrPage;

        }catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;
        }  
    
    }

}