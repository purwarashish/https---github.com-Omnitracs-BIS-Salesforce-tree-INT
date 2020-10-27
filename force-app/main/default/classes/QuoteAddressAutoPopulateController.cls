/**
 * Controller to handle the autopopulation of the address fields when creating a new Steelbrick Quote.
 */

public with sharing class QuoteAddressAutoPopulateController {

    private ApexPages.StandardController standardController;
    private Opportunity opportunity;
    private List<Address__c> addresses = new List<Address__c>{};
    private String corporateAddress = null;
    private String shippingAddress = null;
    private String billtoAddress = null;

    public QuoteAddressAutoPopulateController(ApexPages.StandardController standardController) {
        this.standardController = standardController;
        this.opportunity = [SELECT Id, Name, Account.Id, Account.Roadnet_Market__c,CurrencyIsoCode, Primary_Contact__c 
            FROM Opportunity
            WHERE Id = :System.currentPageReference().getParameters().get('oppId')];

        this.addresses = [SELECT Id, Name, Account_Name__c, Attention__c, Location_Type__c, Address_Line_1__c, Address_Line_2__c, City__c, State_Province__c, Zip_Postal_Code__c, Country__c
            FROM Address__c
            WHERE Account__c = :this.opportunity.Account.Id
            ORDER BY Location_Type__c, LastModifiedDate DESC];
        System.debug('Size of addresses: ' + addresses.size());
    }

    public PageReference test() {
        return null;
    }

    /**
        Searches for the addresses from the account and then creates a new quote. It then sets the values for the address and opportunity and then inserts it. It then displays the edit page for the quote.

        Shipping Address
        Billing Address
        Corporate HQ
     */
    public PageReference populateAddresses() {
        SBQQ__Quote__c sbQuote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=this.opportunity.Id, SBQQ__Account__c=this.opportunity.Account.Id);
        /*for(Address__c address: this.addresses) {
            if((address.Location_Type__c == 'Shipping Address' && shippingAddress == null) || this.addresses.size() == 1) {
                shippingAddress = address.Id;
                sbQuote.Ship_To_Account_Address__c = shippingAddress;

                sbQuote.Ship_To_Location_Type__c = address.Location_Type__c;
                sbQuote.Ship_to_Account_Name__c = address.Account_Name__c;
                sbQuote.Ship_To_Attention__c = opportunity.Primary_Contact__c;
                sbQuote.SBQQ__PrimaryContact__c = opportunity.Primary_Contact__c;
                sbQuote.SBQQ__ShippingStreet__c = address.Address_Line_1__c + ' ' + (address.Address_Line_2__c == null ? '' : address.Address_Line_2__c);
                sbQuote.SBQQ__ShippingCity__c = address.City__c;
                sbQuote.SBQQ__ShippingState__c = address.State_Province__c;
                sbQuote.SBQQ__ShippingPostalCode__c = address.Zip_Postal_Code__c;
                sbQuote.SBQQ__ShippingCountry__c = address.Country__c;

            }
            if(((address.Location_Type__c == 'Billing Address' || address.Location_Type__c == 'Invoice Address') && billtoAddress == null) || this.addresses.size() == 1) {
                billtoAddress = address.Id;
                sbQuote.Bill_To_Account_Address2__c = billtoAddress;

                sbQuote.Bill_to_Location_Type__c = address.Location_Type__c;
                sbQuote.Bill_to_Account_Name__c = address.Account_Name__c;
                sbQuote.Bill_To_Attention__c = opportunity.Primary_Contact__c;
                sbQuote.SBQQ__PrimaryContact__c = opportunity.Primary_Contact__c;
                sbQuote.SBQQ__BillingStreet__c = address.Address_Line_1__c + ' ' + (address.Address_Line_2__c == null ? '' : address.Address_Line_2__c);
                sbQuote.SBQQ__BillingCity__c = address.City__c;
                sbQuote.SBQQ__BillingState__c = address.State_Province__c;
                sbQuote.SBQQ__BillingPostalCode__c = address.Zip_Postal_Code__c;
                sbQuote.SBQQ__BillingCountry__c = address.Country__c;

            }
            if((address.Location_Type__c == 'Corporate HQ' && corporateAddress == null) || this.addresses.size() == 1) {
                corporateAddress = address.Id;
                sbQuote.Corporate_Account_Address__c = corporateAddress;

                sbQuote.Corporate_Location_Type__c = address.Location_Type__c;
                sbQuote.Corporate_Account_Name__c = address.Account_Name__c;
                sbQuote.Corporate_Attention__c = opportunity.Primary_Contact__c;
                sbQuote.SBQQ__PrimaryContact__c = opportunity.Primary_Contact__c;
                sbQuote.Corporate_Street__c = address.Address_Line_1__c + ' ' + (address.Address_Line_2__c == null ? '' : address.Address_Line_2__c);
                sbQuote.Corporate_City__c = address.City__c;
                sbQuote.Corporate_State__c = address.State_Province__c;
                sbQuote.Corporate_Postal_Code__c = address.Zip_Postal_Code__c;
                sbQuote.Corporate_Country__c = address.Country__c;
            }
        }*/
        sbQuote.CurrencyIsoCode = opportunity.CurrencyIsoCode;
        insert sbQuote;
        
        /*if(String.isNotBlank(opportunity.Account.Roadnet_Market__c)){
            String pbookName = 'Standard Price Book'; 
            if(opportunity.Account.Roadnet_Market__c == 'Developed'){
                pbookName = 'Developed Price Book';
            }
            else if(opportunity.Account.Roadnet_Market__c == 'Emerging'){
                pbookName = 'Emerging Price Book';
            }
            if(String.isNotBlank(pbookName)){
                List<Pricebook2> pbList = [select Id from Pricebook2 where IsActive = true and name = :pbookName];
                if(pbList.size() > 0){
                    sbQuote.SBQQ__PriceBook__c = pbList.get(0).Id;
                    sbQuote.SBQQ__PricebookId__c = pbList.get(0).Id;
                    update sbQuote;
                }
                
            }
        }*/

        /* 1
        PageReference returnPage = new PageReference('/' + sbQuote.Id + '/e?saveURL=/apex/sbqq__editquotelines&retURL=/' + this.opportunity.Id); */
         String retURL = EncodingUtil.urlEncode('/apex/QuoteAddressCleanup?oppId=' + this.opportunity.Id + '&quoteId=' + sbQuote.Id, 'UTF-8');
        PageReference returnPage = new PageReference('/' + sbQuote.Id + '/e?saveURL=/apex/sbqq__sb&retURL=' + retURL);
        /*PageReference returnPage = new PageReference('/apex/SBQQ__NewQuote/e?SBQQ__Account__c=' + this.opportunity.Account.Id + '&SBQQ__Opportunity2__c=' + this.opportunity.Id + '&Ship_To_Account_Address__c=' + shippingAddress + '&Bill_To_Account_Address2__c=' + billtoAddress + '&Corporate_Account_Address__c=' + corporateAddress + '&scontrolCaching=1&sfdc.override=1&retURL=/' + this.opportunity.Id + '&saveURL=/apex/sbqq__editquotelines');*/

        return returnPage;
    }

    /**
        Cleans up the quote after having created a new one, if they cancel this
     */
    public PageReference cleanupQuote() {
        SBQQ__Quote__c sbQuote = null;
        String quoteId = System.currentPageReference().getParameters().get('quoteId');
        try {
            sbQuote = [
                    SELECT Id, Name
                    FROM SBQQ__Quote__c
                    WHERE Id = :quoteId
            ];
        } catch (Exception eek) {
            System.debug(LoggingLevel.ERROR, ' ** failed to find the quote ' + quoteId);
        }
        System.debug(LoggingLevel.INFO, ' *** cleaning up the quote ');
        if(sbQuote != null) {
            delete sbQuote;
        }

        PageReference returnPage = new PageReference('/' + this.opportunity.Id);
        return returnPage;
    }


}