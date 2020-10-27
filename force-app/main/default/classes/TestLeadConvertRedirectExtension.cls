@isTest(SeeAllData= true)
public class TestLeadConvertRedirectExtension {

 static testmethod void testForTandL()
    {
        Lead l = new Lead();
        l.firstName = 'test';
        l.lastName = 'test';
        l.RecordTypeId = '01250000000DSzH';
        l.Street = 'street';
        l.City = 'San Diego';
        l.State = 'CA';
        l.PostalCode  = '92121';
        l.Country = 'USA';
        l.Company = 'Company';
        insert l;
        ApexPages.StandardController sc = new ApexPages.standardController(l);
        LeadConvertRedirectExtension ext = new LeadConvertRedirectExtension(sc);

        ext.urlRedirect();
    }
   
   static testmethod void  testForPartner()
    {
        Lead l = new Lead();
        l.firstName = 'test';
        l.lastName = 'test';
        l.RecordTypeId = '01250000000QjAy';
        l.Street = 'street';
        l.City = 'San Diego';
        l.State = 'CA';
        l.PostalCode  = '92121';
        l.Country = 'USA';
        l.Company = 'Company';
        insert l;
        ApexPages.StandardController sc = new ApexPages.standardController(l);
        LeadConvertRedirectExtension ext = new LeadConvertRedirectExtension(sc);

        ext.urlRedirect();
    }
    
    static testmethod void  testForOther()
    {
        Lead l = new Lead();
        l.firstName = 'test';
        l.lastName = 'test';
        l.RecordTypeId = '01250000000DdY8';
        l.Street = 'street';
        l.City = 'San Diego';
        l.State = 'CA';
        l.PostalCode  = '92121';
        l.Country = 'USA';
        l.Company = 'Company';
        insert l;
        ApexPages.StandardController sc = new ApexPages.standardController(l);
        LeadConvertRedirectExtension ext = new LeadConvertRedirectExtension(sc);

        ext.urlRedirect();
    }
}