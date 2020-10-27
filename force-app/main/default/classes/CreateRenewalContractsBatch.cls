/*
Date todayDate = Date.today().addDays(67);
Date startofMonth = Date.today().toStartOfMonth();
String saaQuery = 'Select Id,AccountID,SBQQ__Quote__c,EndDate, (select Id, Contract__c from SAA_Contracts__r) from Contract where RecordTypeId = \'01250000000J5nX\' and '+
                          'endDate <=:todayDate and endDate >=:startofMonth and SBQQ__RenewalOpportunity__c != null and AccountId = \'0015000000LGKsV\'';
Id batchInstanceId = Database.executeBatch(new CreateRenewalContractsBatch (saaQuery), 5);
*/

global class CreateRenewalContractsBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global String cQuery;
    
    global CreateRenewalContractsBatch (String query){
        cQuery = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext batchableContext){
        Integer contractDays = Integer.valueOf(SAA_Settings__c.getall().values().get(0).Contract_Days__c);
        Date todayDate = Date.today().addDays(contractDays);
        Date startofMonth = Date.today().toStartOfMonth();
        return Database.getQueryLocator(cQuery);
    }

    
    global void execute(Database.BatchableContext batchableContext, List<Contract> scope) {
        System.debug('***** EXECUTE ');
        Set<String> accountSet = new Set<String>();
        Set<String> quoteSet = new Set<String>();
        Set<String> oppSet = new Set<String>();
        Map<ID, SBQQ__QuoteLine__c> quoteBUMap = new Map<ID, SBQQ__QuoteLine__c>();
        List<Renewal_Notifications__c> insertRNList = new List<Renewal_Notifications__c>();
        
        String sbrecordTypeId = '01250000000J5nX';
        Map<String, ID> emailTemplateMap = new Map<String, ID>();
        for(SAA_Settings__c saa : SAA_Settings__c.getall().values()){
            emailTemplateMap.put(saa.Business_Unit__c, saa.Template_ID__c);
        }
        //emailTemplateMap.put('Omnitracs US', '00X50000001kKXe');
        //emailTemplateMap.put('Roadnet', '00X50000001kKXe');
        //emailTemplateMap.put('XRS Corporation', '00X50000001tOh0');
        //emailTemplateMap.put('Sylectus', '00X50000001kKXe');
        
        System.debug('*******scopeSize '+scope.size()+' -- '+emailTemplateMap.size());
        for(Contract cntrct: scope) {
            if(cntrct.SAA_Contracts__r == null || cntrct.SAA_Contracts__r.size() == 0){
                accountSet.add(cntrct.AccountID);
            }
        }
        
        Date tDate = Date.today().addMonths(2).addDays(7);
        Integer numberOfDays = Date.daysInMonth(tDate.year(), tDate.month());
        Date saaDate = tDate.addDays((numberOfDays-tDate.Day())-1);
        Date startofMonth = Date.today().toStartOfMonth();
        System.debug('*******saadate '+saaDate);  
        System.debug('*******startofMonth '+startofMonth);  
        List<Account> accntList = [select Id,Fee_Increase_Contact_del__c,  
                                          (select Id, EndDate,RecordTypeId, SBQQ__RenewalOpportunity__c from Contracts 
                                            where EndDate <= :saaDate and endDate >=:startofMonth and RecordTypeId = :sbrecordTypeId and 
                                                  SBQQ__RenewalOpportunity__c != null)
                                     from Account where Id in :accountSet];
        for(Account accnt : accntList){
            System.debug('*******Accnt ');
            if(accnt.Contracts != null && accnt.Contracts.size() > 0){
                System.debug('*******contracts -- '+accnt.Contracts.size());
                for(Contract contr : accnt.Contracts){
                    System.debug('*******contract -- '+contr.Id+' -- '+contr.SBQQ__RenewalOpportunity__c);
                    if(String.isNotBlank(contr.SBQQ__RenewalOpportunity__c)){
                        oppSet.add(contr.SBQQ__RenewalOpportunity__c);
                    }
                }
            }
            
        }
        System.debug('********************oppSet--'+oppSet);
        for(Opportunity rOpp : [select id, (select Id from SBQQ__Quotes2__r where SBQQ__Primary__c = true) 
                                from Opportunity where Id in : oppSet]){
            if(rOpp.SBQQ__Quotes2__r != null && rOpp.SBQQ__Quotes2__r.size() > 0)   {
                quoteSet.add(rOpp.SBQQ__Quotes2__r.get(0).Id);                        
            }                          
        }
        
        System.debug('************* quoteSet -- '+quoteSet);
        for(SBQQ__Quote__c sbq : [select Id, SBQQ__Opportunity2__c, (select Id, SBQQ__Product__c, SBQQ__Product__r.Business_Unit__c, Uplift_Percent__c
                                                                       from SBQQ__LineItems__r where SBQQ__RequiredBy__c != null) 
                                     from SBQQ__Quote__c where Id in :quoteSet]){
            if(sbq.SBQQ__LineItems__r != null && sbq.SBQQ__LineItems__r.size() > 0){
                quoteBUMap.put(sbq.SBQQ__Opportunity2__c,sbq.SBQQ__LineItems__r.get(0));
            }
        }
        
        for(Account accnt : accntList){
            if(accnt.Contracts != null && accnt.Contracts.size() > 0){
                for(Contract contr : accnt.Contracts){
                    String bUnit = 'Omnitracs US';
                    ID emailtemplateId = emailTemplateMap.get(bUnit);
                    Decimal upliftPercent;
                    Date upliftDate;
                    if(String.isNotBlank(contr.SBQQ__RenewalOpportunity__c)){
                        SBQQ__QuoteLine__c ql = quoteBUMap.get(contr.SBQQ__RenewalOpportunity__c);
                        if(ql != null){
                            bUnit = ql.SBQQ__Product__r.Business_Unit__c;
                            if(String.isNotBlank(bUnit) && emailTemplateMap.keySet().contains(bUnit)){
                                emailtemplateId = emailTemplateMap.get(bUnit);
                                upliftPercent = ql.Uplift_Percent__c;
                                upliftDate = contr.EndDate.addDays(1);
                                
                            }
                        }
                        Renewal_Notifications__c rn = new Renewal_Notifications__c(Account__c = accnt.Id, Contract__c = contr.Id, 
                                                                                   Email_Schedule_Send_Date__c = Date.today().addDays(7),
                                                                                   Fee_Increase_Contact__c = accnt.Fee_Increase_Contact_del__c, 
                                                                                   Email_Template_ID__c = emailtemplateId,
                                                                                   Business_Unit__c = bUnit,
                                                                                   Uplift_Percent__c = upliftPercent,
                                                                                   Uplift_Effective_Date__c = upliftDate);
                        insertRNList.add(rn);
                    }
                }
            }
        }
        
        if(insertRNList.size() > 0){
            insert insertRNList;
        }

    }

    global void finish(Database.BatchableContext batchableContext) {
        
    }
}