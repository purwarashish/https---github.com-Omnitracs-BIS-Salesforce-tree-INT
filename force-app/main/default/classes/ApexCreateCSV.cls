global class ApexCreateCSV {
    
	public void generate(List<SBQQ__QuoteLine__c> qlineList) {

        String s = line(new String[] {
                format('SBQQ__Quote__c'),
                format('SBQQ__Quantity__c'),
                format('SBQQ__Product__c'),
                format('SBQQ__Number__c'),
                format('From_Asset_Migration__c'),
                format('isWrapper__c'),
                format('Migrated_ARR__c'),
                format('SBQQ__OriginalPrice__c'),
                format('SBQQ__ListPrice__c'),
                format('Test_Quote_Line_Wrapper__c'),
                format('Migrate_Contracted_Asset__c'),
                format('SBQQ__ProductOption__c'),
                format('SBQQ__SubscriptionPricing__c'),
                format('Business_Unit__c'),
                format('Business_Unit_Wrapper__c'),
                format('Default_Billing_Frequency__c'),
                format('Product_Line__c'),
                format('Product_Type__c'),
                format('License_Type__c'),
                format('SBQQ__OptionLevel__c'),
                format('SBQQ__OptionType__c'),
                format('SBQQ__SpecialPriceType__c')    
                });
        for (SBQQ__QuoteLine__c qlg : qlineList) {
            s += line(new String[] {
                    format(qlg.SBQQ__Quote__c),
                    format(qlg.SBQQ__Quantity__c),
                    format(qlg.SBQQ__Product__c),
                    format(qlg.SBQQ__Number__c),
                    format(qlg.From_Asset_Migration__c?'true':'false'),
                    format(qlg.isWrapper__c?'true':'false'),
                    format(qlg.Migrated_ARR__c),
                    format(qlg.SBQQ__OriginalPrice__c),
                    format(qlg.SBQQ__ListPrice__c),
                    format(qlg.Test_Quote_Line_Wrapper__c),
                    format(qlg.Migrate_Contracted_Asset__c),
                    format(qlg.SBQQ__ProductOption__c),
                    format(qlg.SBQQ__SubscriptionPricing__c),
                    format(qlg.Business_Unit__c),
                    format(qlg.Business_Unit_Wrapper__c),
                    format(qlg.Default_Billing_Frequency__c),
                    format(qlg.Product_Line__c),
                    format(qlg.Product_Type__c),
                    format(qlg.License_Type__c),
                    format('1'),
                    format(qlg.SBQQ__OptionType__c),
                    format(qlg.SBQQ__SpecialPriceType__c)
                    });
        }
        ContentVersion file = new ContentVersion();
        file.title = 'MigratedQuoteLines.csv';		  
        file.versionData = Blob.valueOf(s);	  
        file.pathOnClient = '/MigratedQuoteLines.csv';
        insert file;
    }
    private String line(String[] cells) {
        return String.join(cells, ',') + '\n';
    }
    private String format(Date d)    {
        return d != null ? '"' + d.format().escapeCsv() + '"' : '""';
    }
    private String format(String s) {
        return s != null ? '"' + s.escapeCsv() + '"' : '""';
    }
    private String format(Decimal d, Integer scale) {
        return d != null ? String.valueOf(d.setScale(scale)) : '';
    }
    private String format(Decimal d) {
        return format(d, 2);
    }
}