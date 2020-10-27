public without sharing class VCG_CPQ_QuoteAddress {
    
    //==========================================
    public Opportunity opp{get;set;}
    public boolean bypassValidation{get;set;}
    public VCG_CPQ_QuoteAddress(ApexPages.StandardController ctl)
    {
        string oppId = ApexPages.currentPage().getParameters().get('oppid');
        
        opp = new Opportunity();
        opp = [Select Corporate_Account_Address__c, Invoice_Account_Address__c, ShippingAddress__c from Opportunity where Id = :oppId];
       
    }
    
    
    public PageReference next()
    {
        if(!bypassValidation
            && (opp.Corporate_Account_Address__c == null
                || opp.Invoice_Account_Address__c == null))
        {
            if(opp.Corporate_Account_Address__c == null) opp.Corporate_Account_Address__c.addError('Please specify a Corporate Address');
            if(opp.Invoice_Account_Address__c == null) opp.Invoice_Account_Address__c.addError('Please specify an Invoice Address');
             
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please specify a corporate and invoice address'));
            return null;
        }
        try{
           update opp;
        }
        catch(Exception e)
        {
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
           return null;
        }
        return new PageReference('/apex/VCG_CPQ_Quote?oppid='+opp.Id);
    }
    public PageReference verifyUserIsRoadnetPartnerVar()
    {
        if (isUserRoadnetPartner)//  per case no 02038661, prepoulate the oppt addreess fields with the account's if it is not set  
        {
            //  had to put the action method here as we are creating coporate address on page load and it cannot be done in the constructor
            prepopOpptAddressFields();
        }
        return null;
    }
    public void prepopOpptAddressFields()
    {
        Address__c[] addressesOfVar;
        
        //  so we need to query the account of the var and prepopuate the oppt.address fields with that of the vars
        //  we should be able to get the vars address from the user.contactid.account
        if (loggedInUser != null &&
            loggedInUser.contactId != null &&
            loggedINUser.contact.accountid != null)
        {
            //  first thing we need to do here is see if the account addresses already exist for the var (they should if they used this prompt)
             //  at least once.  we will query all account addresses then see if we get a match on the var's account address info
            
            try
            {
                addressesOfVar = [select account__c, address_line_1__c, address_line_2__c, city__c, country__c, location_type__c, phone_number__c, state_province__c, 
                   zip_postal_code__c from Address__c where account__c =: loggedInUser.Contact.AccountId order by lastmodifieddate desc];
            }
            catch(Exception e)
            {
                //  do nthing here
            }
            
            //  so two outcomes here, either we have adddressses or we have none, if we none, its simple, if we have some, its complicated...
            if (addressesOfVar == null || addressesOfVar.size() == 0)//  we'll need to create the address records and assign to the oppt fields
            {
                if (loggedInUser.Contact.Account.billingaddress != null)
                {
                    if (opp.Corporate_Account_Address__c == null)
                    {
                        opp.Corporate_Account_Address__c = createAccountAddress('Corporate HQ', 'Billing', loggedInUser);
                    }
                    if (opp.Invoice_Account_Address__c == null)
                    {
                        opp.Invoice_Account_Address__c = createAccountAddress('Invoice Address', 'Billing', loggedInUser);
                    }
                }
                if (loggedInUser.Contact.Account.ShippingAddress != null && 
                   opp.ShippingAddress__c == null)
                {
                    opp.ShippingAddress__c = createAccountAddress('Shipping Address', 'Shipping', loggedInUser);                
                }
            }
            else  // so that menas that we found 1 or more accountaddresses
            {
                //  the reason why we check is to avoid having to create dupe addresses.
                if (opp.Corporate_Account_Address__c == null)
                {
                    id corpAcctAddress = findAddressId('Corporate HQ', addressesOfVar);
                    if (corpAcctAddress != null)
                    {
                        opp.Corporate_Account_Address__c = corpAcctAddress;
                    }
                    else
                    {
                        opp.Corporate_Account_Address__c = createAccountAddress('Corporate HQ', 'Billing', loggedInUser);
                    }
                }
                
                if (opp.Invoice_Account_Address__c == null)
                {
                    id invoiceAcctAddress = findAddressId('Invoice Address', addressesOfVar);
                    if (invoiceAcctAddress != null)
                    {
                        opp.Invoice_Account_Address__c = invoiceAcctAddress;
                    }
                    else
                    {
                        opp.Invoice_Account_Address__c = createAccountAddress('Invoice Address', 'Billing', loggedInUser);
                    }
                }
                if (opp.ShippingAddress__c == null)
                {
                    id shippingAcctAddress = findAddressId('Shipping Address', addressesOfVar);
                    if (shippingAcctAddress != null)
                    {
                        opp.ShippingAddress__c = shippingAcctAddress;
                    }
                    else
                    {
                        opp.ShippingAddress__c = createAccountAddress('Shipping Address', 'Shipping', loggedInUser);
                    }
                }
            }
        }

    }
    

    public User loggedInUser
    {
        get
        {
            if (loggedInUser == null)
            {
                loggedInUser = [select id, profile.name, contactid, contact.accountid, contact.account.billingaddress, contact.account.shippingAddress, contact.account.phone from user where id =: userInfo.getUserId()];
            }
            return loggedInUser;
        }
        set;
    }
    private boolean isUserRoadnetPartner
    {
        get
        {
            
            return loggedInUser != null &&
              loggedInUser.profile.id != null &&
              loggedInUser.profile.name == 'Roadnet Partner Community User';
              
        }
    }
    private static id findAddressId(string locationType, List<Address__c> addresses)
    {
    	
        for (Address__c add : addresses)
        {
            if (add.Location_Type__c == locationType)
            {
                return add.id;
            }
        }
        return null;
    }
    private static id createAccountAddress(string locationType, string addressType, User u)
    {
        Address__c tempAdd = new Address__c();
        //  the address is a struct, we need to find the property names of the address to be able assing the variour fields on the 
        // custom object
        if (addressType == 'Billing')
        {
            tempAdd.Account__c = u.Contact.Accountid;
            tempAdd.Address_Line_1__c = u.Contact.Account.BillingAddress.getStreet();
            tempAdd.city__c = u.Contact.Account.billingAddress.getCity();
            tempAdd.country__c = u.Contact.Account.billingAddress.getCountry();
            tempAdd.Location_Type__c = locationType;
            tempAdd.phone_number__c = u.Contact.account.phone;
            tempAdd.State_province__c = u.Contact.Account.billingAddress.getState();
            tempAdd.Zip_postal_code__c = u.Contact.Account.billingAddress.getPostalCode();
        }
        else//  other address type is shipping
        {
            tempAdd.Account__c = u.Contact.Accountid;
            tempAdd.Address_Line_1__c = u.Contact.Account.ShippingAddress.getStreet();
            tempAdd.city__c = u.Contact.Account.ShippingAddress.getCity();
            tempAdd.country__c = u.Contact.Account.ShippingAddress.getCountry();
            tempAdd.Location_Type__c = locationType;
            tempAdd.phone_number__c = u.Contact.account.phone;
            tempAdd.State_province__c = u.Contact.Account.ShippingAddress.getState();
            tempAdd.Zip_postal_code__c = u.Contact.Account.ShippingAddress.getPostalCode();
        }
        
        database.insert(tempAdd);
        
        if (tempAdd != null && tempAdd.id != null)
        {
            return tempAdd.id;
        }
        return null;
    }
    
    public static void testMethodTestForPrivateStatics()
    {
    	Address__c[] testAddressList = [select id, location_type__c from Address__c limit 2];
    	id testId = findAddressId('Coporate HQ', testAddressList);
    	User testPartnerUser = [select id, profile.name, contactid, contact.accountid, contact.account.billingaddress, 
    	   contact.account.shippingAddress, contact.account.phone from user where Profile.name = 'Roadnet Partner Community User' and contactid != null limit 1];
    	id testAddress = createAccountAddress('Coporate HQ', 'Billing', testPartnerUser);
    	system.assertNotEquals(null, testAddress);
    	testAddress = createAccountAddress('Coporate HQ', 'Shipping', testPartnerUser);
    	system.assertNotEquals(null, testAddress);
    }
    
    
}