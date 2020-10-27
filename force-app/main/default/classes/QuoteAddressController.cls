public with sharing class QuoteAddressController {
    String corporateAddress = null;
    String shippingAddress = null;
    String billtoAddress = null;
    List<Address__c> addresses = new List<Address__c>{};
    SBQQ__Quote__c quote = null;
    

	private final sObject mysObject;
    
    public QuoteAddressController() {
     	this.addresses = [SELECT Id, Name, Address_Line_1__c, Address_Line_2__c, City__c, State_Province__c 
                          FROM Address__c
                          WHERE Account__c = :System.currentPageReference().getParameters().get('accountId')];
        this.quote = [SELECT Id, Name, Bill_To_Account_Address2__c, Corporate_Account_Address__c, Ship_To_Account_Address__c
                        FROM SBQQ__Quote__c
                        WHERE Id = :System.currentPageReference().getParameters().get('quoteId')];
    }

    /**
     Set the addresses on the quote and then update the quote.
     */
    public PageReference save() {
        this.quote.Bill_To_Account_Address2__c = billtoAddress;
        this.quote.Corporate_Account_Address__c = corporateAddress;
        this.quote.Ship_To_Account_Address__c = shippingAddress;
        update this.quote;
        PageReference returnPage = new PageReference('/' + this.quote.Id);
        return returnPage;
    }

    public PageReference cancel() {
        PageReference returnPage = new PageReference('/' + this.quote.Id);
        return returnPage;
    }

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public QuoteAddressController(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
    }
    
    public PageReference test() {
       return null; 
    }
    
    public String getSelectedCorporateAddress() {
        return corporateAddress;
    }

    public void setSelectedCorporateAddress(String lselection) {
        corporateAddress = lselection;
    }
    
    public List<SelectOption> getCorporateAddressList() {
        List<SelectOption> addressList = new List<SelectOption>();
        
        for(Address__c address: this.addresses) {
            addressList.add(new SelectOption(address.Id, ''));
        }
        return addressList;
    }
    
    public String getSelectedShippingAddress() {
        return shippingAddress;
    }

    public void setSelectedShippingAddress(String lselection) {
        shippingAddress = lselection;
    }
    
    public List<SelectOption> getShippingAddressList() {
        List<SelectOption> addressList = new List<SelectOption>();
        
        for(Address__c address: this.addresses) {
            addressList.add(new SelectOption(address.Id, ''));
        }
        return addressList;
    }
    
    public String getSelectedBillToAddress() {
        return shippingAddress;
    }

    public void setSelectedBillToAddress(String lselection) {
        billToAddress = lselection;
    }
    
    public List<SelectOption> getBillToAddressList() {
        List<SelectOption> addressList = new List<SelectOption>();
        
        for(Address__c address: this.addresses) {
            addressList.add(new SelectOption(address.Id, address.Name + ' ' + address.Address_Line_1__c + ' ' + address.Address_Line_2__c + ' ' + address.City__c + ', ' + address.State_Province__c));
        }
        return addressList;
    }
}