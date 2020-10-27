public class OppDealDeskController {

    public Opportunity op {get;set;}
    public date mostRecentRev {get;set;}
    Public String typeofcompetitor {get;set;}
    public List<OpportunityLineItem> lineItems {get; set;}
    public List<financeWrapperInfo> finWra {get;set;}
	public List<CompetitorWrapperInfo>comwra {get;set;}
    
    public OppDealDeskController(ApexPages.StandardController controller) {
        finWra = new List<financeWrapperInfo>(); 
		comwra = new List<CompetitorWrapperInfo>();    
    }
    
    public Pagereference PrePopulateData(){
        
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get('Deal_Desk__c') ;
        Schema.DescribeSObjectResult r = s.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        String queryString='/'+keyPrefix+'/e?';
        try{
        // NNARR__c
            /*op = [select id,name,accountid,Product_Type__c, Service_Plan_Quantity__c,
                    SBQQ__PrimaryQuote__r.SBQQ__SubscriptionTerm__c,System_Fleet_Size__c,
                    ownerid,Owner.name,TCV__c,ARR__c,NewCPQ_Primary_Quote_Contract_Term__c,VEP_Opportunity_Type__c,ACV__c,Net_ARR__c,Account.Fleet_Size_for_Territory_Assignment__c,Type, Type_of_Competitor__c from opportunity where id=:ApexPages.currentPage().getParameters().get('oppId')
                ];*/
            op = [select id,name,accountid, Service_Plan_Quantity__c,
                    SBQQ__PrimaryQuote__r.SBQQ__SubscriptionTerm__c,System_Fleet_Size__c,
                    ownerid,Owner.name,TCV__c,ARR__c,Accretive_Recurring_ACV__c,Accretive_Non_Recurring_ACV__c,Total_Accretive_ACV__c,NewCPQ_Primary_Quote_Contract_Term__c,VEP_Opportunity_Type__c,ACV__c,Net_ARR__c,Account.Fleet_Size_for_Territory_Assignment__c,Type, Type_of_Competitor__c from opportunity where id=:ApexPages.currentPage().getParameters().get('oppId')
                ];
        
        string dura='';
        for(EntityParticle ee : [SELECT EntityDefinitionId FROM EntityParticle WHERE EntityDefinition.QualifiedApiName = 'Deal_Desk__c' limit 1]){
            dura = ee.EntityDefinitionId;
            
        }
        
        String objid = dura;
        Map<String,String> FieldNamewithId = new Map<String,String>();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        String query = 'Select id,DeveloperName from CustomField where TableEnumOrId = \'' + objid + '\'';
        
        
        String endpoint = Url.getSalesforceBaseUrl().toExternalForm();
        endpoint += '/services/data/v41.0/tooling/query/?q=';
        endpoint += EncodingUtil.urlEncode(query, 'UTF-8');
        
        req.setEndpoint(endpoint);
        
        req.setMethod('GET');
        string resP = '';
        Http h = new Http();
        try{
            List<Custom_Field_And_ID__c> aa = [select id,name,Field_ID__c,Object__c,Developer_Name__c from Custom_Field_And_ID__c where Object__c='Deal_Desk' ];
            if(aa.size()>0){
                for(Custom_Field_And_ID__c ca : aa){
                    FieldNamewithId.put(ca.Developer_Name__c,ca.Field_ID__c); 
                }
            } else {
                HttpResponse res = h.send(req);
                resP = res.getBody(); 
            }
        }catch(exception ex){
            system.debug('++++Exception'+ex.getMessage());
        }
        if(test.isRunningTest()){
            resP = '{"size":28,"totalSize":28,"done":true,"queryLocator":null,"entityTypeName":"CustomField","records":[{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByCMAW"},"Id":"00NZ0000003JByCMAW","DeveloperName":"ARPU"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByDMAW"},"Id":"00NZ0000003JByDMAW","DeveloperName":"ARR"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByEMAW"},"Id":"00NZ0000003JByEMAW","DeveloperName":"Current_Contracts_del"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByFMAW"},"Id":"00NZ0000003JByFMAW","DeveloperName":"Current_Financials_del"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByGMAW"},"Id":"00NZ0000003JByGMAW","DeveloperName":"Current_Price_Uplift_Language"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByHMAW"},"Id":"00NZ0000003JByHMAW","DeveloperName":"Deal_Type"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByIMAW"},"Id":"00NZ0000003JByIMAW","DeveloperName":"Existing_New_Customer"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByJMAW"},"Id":"00NZ0000003JByJMAW","DeveloperName":"Fleet_Size"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByKMAW"},"Id":"00NZ0000003JByKMAW","DeveloperName":"Has_This_Been_on_Deal_Desk_Before"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByMMAW"},"Id":"00NZ0000003JByMMAW","DeveloperName":"NRF_Current"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByNMAW"},"Id":"00NZ0000003JByNMAW","DeveloperName":"Proposed_NRF_Language"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByOMAW"},"Id":"00NZ0000003JByOMAW","DeveloperName":"Opportunity_Link"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByPMAW"},"Id":"00NZ0000003JByPMAW","DeveloperName":"Opportunity_Name"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByQMAW"},"Id":"00NZ0000003JByQMAW","DeveloperName":"Opportunity_Owner"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByRMAW"},"Id":"00NZ0000003JByRMAW","DeveloperName":"Opportunity_Size"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JBySMAW"},"Id":"00NZ0000003JBySMAW","DeveloperName":"Product_Type"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByTMAW"},"Id":"00NZ0000003JByTMAW","DeveloperName":"Proposal_Details"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByUMAW"},"Id":"00NZ0000003JByUMAW","DeveloperName":"Proposed_Uplift_Language"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByVMAW"},"Id":"00NZ0000003JByVMAW","DeveloperName":"Subscription_Term"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByWMAW"},"Id":"00NZ0000003JByWMAW","DeveloperName":"TCV"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByXMAW"},"Id":"00NZ0000003JByXMAW","DeveloperName":"What_are_they_offering"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByYMAW"},"Id":"00NZ0000003JByYMAW","DeveloperName":"What_are_we_doing_for_the_customer_now"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByZMAW"},"Id":"00NZ0000003JByZMAW","DeveloperName":"What_is_the_expected_rollout_schedule"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JByaMAG"},"Id":"00NZ0000003JByaMAG","DeveloperName":"When_do_we_expect_a_decision"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JBybMAG"},"Id":"00NZ0000003JBybMAG","DeveloperName":"Who_are_we_competing_against"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JBycMAG"},"Id":"00NZ0000003JBycMAG","DeveloperName":"Why_are_you_bringing_this_to_Deal_Desk"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JXOmMAO"},"Id":"00NZ0000003JXOmMAO","DeveloperName":"NET_ARR"},{"attributes":{"type":"CustomField","url":"/services/data/v28.0/tooling/sobjects/CustomField/00NZ0000003JXOrMAO"},"Id":"00NZ0000003JXOrMAO","DeveloperName":"ACV"}]}';
        }
        Matcher m1 = Pattern.compile('"Id":"(\\w+)","DeveloperName":"(\\w+)"').matcher(resP);
        List<Custom_Field_And_ID__c> caa = new List<Custom_Field_And_ID__c>();
        while(m1.find()) {
            
            Custom_Field_And_ID__c cs = new Custom_Field_And_ID__c();
            cs.Developer_Name__c=m1.group(2);
            cs.Object__c='Deal_Desk';
            cs.Field_ID__c=m1.group(1).substring(0,m1.group(1).length()-3);
            cs.Name=m1.group(1).substring(0,m1.group(1).length()-3);
            caa.add(cs);
            FieldNamewithId.put(m1.group(2),m1.group(1).substring(0,m1.group(1).length()-3));  
        }
        if(caa.size()>0){
            upsert caa name;
        }
        
        queryString += 'CF'+FieldNamewithId.get('Opportunity_Name')+'='+EncodingUtil.URLENCODE(op.name,'UTF-8')+'&';
        //queryString += 'Name='+EncodingUtil.URLENCODE(op.name,'UTF-8')+'&'+FieldNamewithId.get('Product_Type')+'='+EncodingUtil.URLENCODE(op.Product_Type__c,'UTF-8')+'&';
        queryString += 'Name='+EncodingUtil.URLENCODE(op.name,'UTF-8')+'&';
        //queryString += '00NZ0000003JByI='+EncodingUtil.URLENCODE('New Customer','UTF-8')+'&';
        queryString += FieldNamewithId.get('Deal_Type')+'='+EncodingUtil.URLENCODE(op.VEP_Opportunity_Type__c,'UTF-8')+'&'+FieldNamewithId.get('Opportunity_Owner')+'='+EncodingUtil.URLENCODE(op.Owner.name,'UTF-8')+'&';
        queryString += FieldNamewithId.get('Existing_New_Customer')+'='+EncodingUtil.URLENCODE(op.Type,'UTF-8')+'&';
        queryString += FieldNamewithId.get('Fleet_Size')+'='+op.Account.Fleet_Size_for_Territory_Assignment__c+'&'+FieldNamewithId.get('Opportunity_Size')+'='+op.Service_Plan_Quantity__c+'&';
        queryString += FieldNamewithId.get('TCV')+'='+op.TCV__c+'&'+FieldNamewithId.get('ARR')+'='+op.ARR__c+'&';
        queryString += FieldNamewithId.get('Total_Accretive_ACV')+'='+op.Total_Accretive_ACV__c+'&';
        queryString += FieldNamewithId.get('Accretive_Non_Recurring_ACV')+'='+op.Accretive_Non_Recurring_ACV__c+'&';
        queryString += FieldNamewithId.get('Accretive_Recurring_ACV')+'='+op.Accretive_Recurring_ACV__c+'&';
        //FieldNamewithId.get('NNARR')+'='+op.NNARR__c+'&'+
        queryString += FieldNamewithId.get('NET_ARR')+'='+op.Net_ARR__c+'&'+FieldNamewithId.get('Subscription_Term')+'='+op.NewCPQ_Primary_Quote_Contract_Term__c+'&';
        queryString += FieldNamewithId.get('Opportunity_Link')+'='+EncodingUtil.URLENCODE(System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+op.id,'UTF-8')+'&retURL=%2F'+op.id;
        
        Pagereference Pr = new Pagereference(queryString.replaceall('null',''));
        pr.setRedirect(true);
        return pr;
        } catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'Opportunity is missing or the record is deleted or there is an error'+ ex.getmessage()));
            
        }
        return null;
            
    }
    
    public pagereference loadFinanceData()
    {
        List<String> ProductLines = new List<String>{'MCP50','MCP110','TT200','Omnitracs IVG','XRS','MCP100S','TT210','MCP200','MCP100T','TT150','RTS','Roadnet Telematics','RNA','RDC','IVG'};
        
        Map<String,Date> ConEndDate = new Map<String,Date>();
        Map<String,Revenue__c> LatestInvoice = new Map<String,Revenue__c>();
        
        Deal_desk__c dd = [select id, Opportunity_Name__r.accountid from Deal_desk__c where id=:ApexPages.currentPage().getParameters().get('id')];
        
        date latestendDate = system.today();
        for(contract cc : [select id, EndDate ,Agreement_Type__c, Contract_Title__c, Status, Contract_Category_1__c from contract where accountid=:dd.Opportunity_Name__r.accountid and Status='Active' and Agreement_Type__c='Schedule' and EndDate!=null order by EndDate asc ])
        {
            
            if(cc.Contract_Title__c.containsIgnoreCase('INTELLIGENT VEHICLE GATEWAY SERVICE SCHEDULE')  && cc.Contract_Category_1__c.contains('IVG'))
            {
             ConEndDate.put('Omnitracs IVG',cc.EndDate);   
            }
            else if(cc.Contract_Title__c.containsIgnoreCase('INTELLIGENT VEHICLE GATEWAY SERVICE SCHEDULE')  && cc.Contract_Category_1__c.contains('IVG'))
            {
             ConEndDate.put('IVG',cc.EndDate);   
            }
            else if(cc.Contract_Title__c.containsIgnoreCase('MOBILE COMPUTING PLATFORM 50 SERIES') && cc.Contract_Category_1__c.contains('MCP50'))
            {
             ConEndDate.put('MCP50',cc.EndDate);     
            }
            else if(cc.Contract_Title__c.containsIgnoreCase('Mobile Computing Platform 110 Series')  && cc.Contract_Category_1__c.contains('MCP110'))
            {
             ConEndDate.put('MCP110',cc.EndDate);    
            }
            else if(cc.Contract_Title__c.containsIgnoreCase('Untethered Asset Management Service Schedule')  && cc.Contract_Category_1__c.contains('T2'))
            {
             ConEndDate.put('TT200',cc.EndDate);    
            }
            else if(cc.Contract_Title__c.containsIgnoreCase('Relay Unit Schedule')  && cc.Contract_Category_1__c.contains('XRS'))
            {
             ConEndDate.put('XRS',cc.EndDate);  
            }
            else if(cc.Contract_Title__c.containsIgnoreCase('Mobile Computing Platform 100 Series Satellite')  && cc.Contract_Category_1__c.contains('MCP100S'))
            {
             ConEndDate.put('MCP100S',cc.EndDate);    
            }
            else if(cc.Contract_Title__c.containsIgnoreCase('TRAILER TRACKS 210 SERVICE SCHEDULE')  && cc.Contract_Category_1__c.contains('TT210'))
            {
             ConEndDate.put('TT210',cc.EndDate);    
            }
            else if(cc.Contract_Title__c.containsIgnoreCase('MOBILE COMPUTING PLATFORM 200 SERIES')  && cc.Contract_Category_1__c.contains('MCP200'))
            {
             ConEndDate.put('MCP200',cc.EndDate);    
            }
            else if((cc.Contract_Title__c.ContainsIgnoreCase('Mobile Computing Platform 100 Series Terrestrial') || cc.Contract_Title__c.ContainsIgnoreCase('OmniVision Terrestrial'))  && cc.Contract_Category_1__c.contains('MCP100T'))
            {
             ConEndDate.put('MCP100T',cc.EndDate);    
            }
            else if(cc.Contract_Title__c.containsIgnoreCase('TRAILER TRACKS 150 SERVICE SCHEDULE')  && cc.Contract_Category_1__c.contains('TT150'))
            {
             ConEndDate.put('TT150',cc.EndDate);    
            }
            else if(cc.Contract_Title__c.containsIgnoreCase('Software License Schedule')  && (cc.Contract_Category_1__c.contains('Dom. SAAS') || cc.Contract_Category_1__c.contains('Dom. Perpetual')))
            {
             ConEndDate.put('RTS',cc.EndDate);    
            }
            else if((cc.Contract_Title__c.containsIgnoreCase('Roadnet Telematics Device') && cc.Contract_Title__c.containsIgnoreCase('Wireless Services')) && cc.Contract_Category_1__c.contains('RN Telematics/SaaS (Lease)'))
            {
             ConEndDate.put('Roadnet Telematics',cc.EndDate);    
            }
            else if(cc.Contract_Title__c.containsIgnoreCase('SOFTWARE AS A SERVICE SCHEDULE')  && cc.Contract_Category_1__c.contains('RN SaaS'))
            {
             ConEndDate.put('RNA',cc.EndDate); 
            }
            
        }
        if(ConEndDate.get('XRS')>=ConEndDate.get('RNA')){
            ConEndDate.put('RDC',ConEndDate.get('XRS'));   
        }else{
            ConEndDate.put('RDC',ConEndDate.get('RNA'));  
        }
        for(Revenue__c rr : [select id,Product_Line__c,ARPU__c,Invoice_Date__c,Billed_Units__c,Net_Revenue__c from revenue__c where Account__c=:dd.Opportunity_Name__r.accountid and Product_Line__c=:ProductLines order by Invoice_Date__c desc limit 1]){
            mostRecentRev=rr.Invoice_Date__c;
        }
        
        for(Revenue__c rr : [select id,Product_Line__c,ARPU__c,Invoice_Date__c,Billed_Units__c,Net_Revenue__c from revenue__c where Account__c=:dd.Opportunity_Name__r.accountid and Product_Line__c=:ProductLines and Invoice_Date__c=:mostRecentRev order by Product_Line__c desc, Invoice_Date__c asc]){
            LatestInvoice.put(rr.Product_Line__c,rr);
        }
        decimal rev=0;
        decimal ARPU=0;
        decimal unit=0;
        
        for(AggregateResult rr : [select MAX(Invoice_Date__c)invd, Product_Line__c, sum(ARPU__c) sumARPU, SUM(Billed_Units__c) sumUnit, SUM(Net_Revenue__c) sumRev from Revenue__c where Account__c=:dd.Opportunity_Name__r.accountid and id=:LatestInvoice.values() group by Product_Line__c order by Product_Line__c])
        {
            
            financeWrapperInfo ssa = new financeWrapperInfo();
            
            ssa.productName=((String)rr.get('Product_Line__c'));
            ssa.Revenue=LatestInvoice.get(ssa.productName).Net_Revenue__c;//((decimal)rr.get('sumRev'));
            ssa.ARPU=LatestInvoice.get(ssa.productName).ARPU__c;//((decimal)rr.get('sumARPU'));
            ssa.ContractEndDate =ConEndDate.get(ssa.productName);
            ssa.UnitCount=LatestInvoice.get(ssa.productName).Billed_Units__c;//((decimal)rr.get('sumUnit')).setscale(0);
           // System.debug('++++++rev'+rev);
            if((decimal)rr.get('sumUnit')!=null)
                unit+=((decimal)rr.get('sumUnit')).setscale(0);
            if((decimal)rr.get('sumARPU')!=null)
                ARPU+=((decimal)rr.get('sumARPU'));
            if((decimal)rr.get('sumRev')!=null)
                rev+=((decimal)rr.get('sumRev'));
            
            finWra.add(ssa);
        }
        financeWrapperInfo ssa = new financeWrapperInfo();
            ssa.productName='Total:';
            ssa.Revenue=rev;
            ssa.ARPU=ARPU;
            ssa.UnitCount=unit;

        finWra.add(ssa);
        return null;
    }
    public pagereference loadCompetitorData(){
        system.debug ('###');
	    Deal_desk__c dd = [select id,Opportunity_Name__c , Opportunity_Name__r.accountid from Deal_desk__c where id=:ApexPages.currentPage().getParameters().get('id')];
       
		op = [select id,name,accountid,Type_of_Competitor__c from opportunity where id=:dd.Opportunity_Name__c];
				
		typeofcompetitor = op.Type_of_Competitor__c;
		list<Competitive_Summary__C> compSummarylist = new list<Competitive_Summary__C> ();
        set<id> compSummaryIDset = new set<id> ();

		compSummarylist = [select name, competitor__c, Account__c, competitive_intelligence__c, opportunity__c from Competitive_Summary__c where opportunity__c =: op.id ];
		for(Competitive_Summary__C comps :compSummarylist) {
            compSummaryIdSet.add(comps.Competitive_intelligence__c);
        }
        
        list<Competitive_Threat__C> compilist = new list<Competitive_Threat__C> ();
		compilist = [select id, name,Competitor_Name__r.Name, Competitor_Status__c, Product_Solution_Name__C, Entire_Fleet__c, of_units_at_risk__c, competitor_units_installed__c, Satisfaction_level__c, Expected_Competitor_Contract_expiration__c from Competitive_threat__c where id in: compSummaryIdSet];
		
        for(Competitive_Threat__C CTI: compilist){
            CompetitorWrapperInfo CWI = new CompetitorWrapperInfo();
            
            CWI.CompetitorName = cti.Competitor_Name__r.Name;
            CWI.CompetitorStatus = cti.Competitor_Status__c;
            CWI.CompetitorProductSolution = cti.Product_Solution_Name__C;
            CWI.EntireFleet = cti.Entire_Fleet__c;
            CWI.NumberofUnitsatRisk = cti.of_units_at_risk__c;
            CWI.NumberofCompetitiveUnitsInstalled = cti.competitor_units_installed__c;
            CWI.SatisfactionLevel = cti.Satisfaction_level__c;
            CWI.ExpectedExpireDate = cti.Expected_Competitor_Contract_expiration__c;
            
            Comwra.add(CWI);

         }
        
        System.debug (op);
		System.debug(compsummarylist);
        system.debug(compsummaryidset);
		System.debug(compilist);
        return null;
	}
    
    public pagereference LoadProductsData(){
        
	    Deal_desk__c dd = [select id,Opportunity_Name__c  from Deal_desk__c where id=:ApexPages.currentPage().getParameters().get('id')];
        
		op = [select id,name,accountid from opportunity where id=:dd.Opportunity_Name__c];
		
		lineItems = [ Select Id, Opportunityid, PriceBookEntry.Name, Product2.Name, Quantity, Unit_Price__C, Final_Unit_Price__c from OpportunityLineItem where Opportunityid =: op.id];
		
        return null;
    }
    
    public class financeWrapperInfo{
        public string productName{get;set;}
        public decimal ARPU {get;set;}
        public decimal UnitCount {get;set;}
        public Date ContractEndDate {get;set;}
        public decimal Revenue {get;set;}
    }
	
	Public class CompetitorWrapperInfo{
		public String CompetitorName{get;set;}
		public String CompetitorStatus{get;set;}
		public String CompetitorProductSolution{get;set;}
		public String EntireFleet{get;set;}
		public Decimal NumberofUnitsatRisk{get;set;}
		public Decimal NumberofCompetitiveUnitsInstalled{get;set;}
		public String SatisfactionLevel{get;set;}
		public Date ExpectedExpireDate{get;set;}
	}

}