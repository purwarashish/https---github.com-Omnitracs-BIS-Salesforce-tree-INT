/******************************************************************************************
 * File:        CallReportEmail.cls
 * Date:        October 5th, 2018
 * Author:      Sai Krishna Kakani
 * Description: Class to facilitatie the product details in New Call Report Template
 * ****************************************************************************************/
public class CallReportEmail {
    public ID callReportID;
    public id getcallreportID () {return callreportid;}
    public Call_Report__C CR {get;set;}
    public date mostRecentRev {get;set;}
    public decimal LatestRevenue {get;set;}
    public List<financeWrapperInfo> finWra {get;set;}
    
    public void setcallreportID (ID s) {
        callReportID = s;
        init();
    }
    
    public void init(){
        if(callReportID != null || callReportID != '') {
            CR = [select id, Call_Report__c.Name,Account__c from Call_Report__c where id=: callReportID];
        Map<String,Date> ContEndDate = new Map<String,Date>();
        for(contract cc : [select id, EndDate ,Agreement_Type__c, Contract_Title__c, Status, Contract_Category_1__c from contract where accountid =:CR.Account__c and Status='Active' and Agreement_Type__c='Schedule' order by EndDate asc ]){
            
            If(cc.Contract_Title__c.ContainsIgnoreCase('MOBILE COMPUTING PLATFORM 50 SERIES') && cc.Contract_Category_1__c.Contains('MCP50')){
                 ContEndDate.put('MCP50',cc.EndDate);     
            }
            
            else If((cc.Contract_Title__c.ContainsIgnoreCase('Mobile Computing Platform 100 Series Terrestrial') || cc.Contract_Title__c.ContainsIgnoreCase('OmniVision Terrestrial')) && cc.Contract_Category_1__c.contains('MCP100T')){
                 ContEndDate.put('MCP100T',cc.EndDate);     
            }
            
            else If(cc.Contract_Title__c.ContainsIgnoreCase('INTELLIGENT VEHICLE GATEWAY SERVICE SCHEDULE') && cc.Contract_Category_1__c.Contains('IVG')){
                 ContEndDate.put('Omnitracs IVG',cc.EndDate);     
            }
            
            else If(cc.Contract_Title__c.ContainsIgnoreCase('INTELLIGENT VEHICLE GATEWAY SERVICE SCHEDULE') && cc.Contract_Category_1__c.contains('IVG')){
                 ContEndDate.put('IVG',cc.EndDate);     
            }
            
            else If(cc.Contract_Title__c.ContainsIgnoreCase('Mobile Computing Platform 110 Series') && cc.Contract_Category_1__c.Contains('MCP110')){
                 ContEndDate.put('MCP110',cc.EndDate);     
            }
            
            else If(cc.Contract_Title__c.ContainsIgnoreCase('Untethered Asset Management Service Schedule') && cc.Contract_Category_1__c.Contains('T2')){
                 ContEndDate.put('TT200',cc.EndDate);     
            }
            
            else If(cc.Contract_Title__c.ContainsIgnoreCase('Relay Unit Schedule') && cc.Contract_Category_1__c.Contains('XRS')){
                 ContEndDate.put('XRS',cc.EndDate);     
            }
            
            else If(cc.Contract_Title__c.ContainsIgnoreCase('Mobile Computing Platform 100 Series Satellite') && cc.Contract_Category_1__c.Contains('MCP100S')){
                 ContEndDate.put('MCP100S',cc.EndDate);     
            }
            
            else If(cc.Contract_Title__c.ContainsIgnoreCase('TRAILER TRACKS 210 SERVICE SCHEDULE') && cc.Contract_Category_1__c.Contains('TT210')){
                 ContEndDate.put('TT210',cc.EndDate);     
            }
            
            else If(cc.Contract_Title__c.ContainsIgnoreCase('MOBILE COMPUTING PLATFORM 200 SERIES') && cc.Contract_Category_1__c.Contains('MCP200')){
                 ContEndDate.put('MCP200',cc.EndDate);     
            }
            
            else If(cc.Contract_Title__c.ContainsIgnoreCase('TRAILER TRACKS 150 SERVICE SCHEDULE') && cc.Contract_Category_1__c.Contains('TT150')){
                 ContEndDate.put('TT150',cc.EndDate);     
            }
            
            else If(cc.Contract_Title__c.ContainsIgnoreCase('Software License Schedule') && cc.Contract_Category_1__c != null && (cc.Contract_Category_1__c.Contains('Dom. SAAS') || cc.Contract_Category_1__c.Contains('Dom. Perpetual'))){
                 ContEndDate.put('RTS',cc.EndDate);     
            }
            
            else If((cc.Contract_Title__c.ContainsIgnoreCase('Roadnet Telematics Device')) && (cc.Contract_Title__c.ContainsIgnoreCase('Wireless Services')) && cc.Contract_Category_1__c.Contains('RN Telematics/SaaS (Lease)')){
                 ContEndDate.put('Roadnet Telematics',cc.EndDate);     
            }
            
            else If((cc.Contract_Title__c.ContainsIgnoreCase('Roadnet Telematics Device')) && (cc.Contract_Title__c.ContainsIgnoreCase('Wireless Services')) && cc.Contract_Category_1__c.Contains('RN Telematics/SaaS (Lease)')){
                 ContEndDate.put('RNT - Telematics',cc.EndDate);     
            }
            
            else If(cc.Contract_Title__c.ContainsIgnoreCase('SOFTWARE AS A SERVICE SCHEDULE') && cc.Contract_Category_1__c == 'RN SaaS'){
                 ContEndDate.put('RNA',cc.EndDate);     
            }              
        }
            
        if(ContEndDate.get('XRS')>=ContEndDate.get('RNA')){
                ContEndDate.put('RDC',ContEndDate.get('XRS'));   
            }
        else{
                ContEndDate.put('RDC',ContEndDate.get('RNA'));  
            }     
           
            
        List<Id> revIds = new List<Id>();
        Map<String,Revenue__c> LatestInvoice = new Map<String,Revenue__c>();
        List<String> ProductLines = new List<String>{'MCP50','MCP110','TT200','Omnitracs IVG','XRS','MCP100S','TT210','MCP200','MCP100T','TT150','RTS','Roadnet Telematics','RNT - Telematics','RNA','RDC','RNA - Roadnet Anywhere','RTS - Transportation Services'}; 
       
        list<Revenue__c> rrlist = new list<Revenue__c> ();
        rrlist = [select id,Product_Line__c,ARPU__c,Invoice_Date__c,Billed_Units__c,Net_Revenue__c from revenue__c where Account__c=:CR.Account__c and Product_Line__c=:ProductLines order by Invoice_Date__c DESC limit 1];
        
        if(rrlist != null && rrlist.size() > 0) {
        mostRecentRev=rrlist[0].Invoice_Date__c;
        
        for(Revenue__c rerv : [select id,Product_Line__c,ARPU__c,Invoice_Date__c,Billed_Units__c,Net_Revenue__c from revenue__c where Account__c=:CR.Account__c and Product_Line__c=:ProductLines and Invoice_Date__c =:mostRecentRev order by Product_Line__c desc, Invoice_Date__c asc]){
            LatestInvoice.put(rerv.Product_Line__c,rerv);
        
        }
        }
              
        decimal rev=0;
        decimal ARPU=0;
        decimal unit=0;
        
        finWra = new List<financeWrapperInfo>();
        
        for(AggregateResult rerv : [select MAX(Invoice_Date__c)invd, Product_Line__c, sum(ARPU__c) sumARPU, SUM(Billed_Units__c) sumUnit, SUM(Net_Revenue__c) sumRev from Revenue__c where Account__c=:CR.Account__c and id=:LatestInvoice.values() group by Product_Line__c order by Product_Line__c]){
            financeWrapperInfo ssa = new financeWrapperInfo();
            
            ssa.productName=((String)rerv.get('Product_Line__c'));
            
            ssa.Revenue=LatestInvoice.get(ssa.productName).Net_Revenue__c;//((decimal)rr.get('sumRev'));
            
            ssa.ARPU=LatestInvoice.get(ssa.productName).ARPU__c;//((decimal)rr.get('sumARPU'));
            
            ssa.UnitCount=LatestInvoice.get(ssa.productName).Billed_Units__c;//((decimal)rr.get('sumUnit')).setscale(0);
            
            ssa.ContractEndDate =ContEndDate.get(ssa.productName);
            
            if((decimal)rerv.get('sumRev')!=null)
                rev+=((decimal)rerv.get('sumRev'));
            if((decimal)rerv.get('sumARPU')!=null)
                ARPU+=((decimal)rerv.get('sumARPU'));
            if((decimal)rerv.get('sumUnit')!=null)
                unit+=((decimal)rerv.get('sumUnit')).setscale(0);
            
            finWra.add(ssa);
        }
        financeWrapperInfo ssa = new financeWrapperInfo();
            ssa.productName='Total:';
            ssa.Revenue=rev;
            if(unit !=0)
            {
                ssa.ARPU= (rev/unit).setscale(2);
            }
            if(unit ==0)
            {
                ssa.ARPU= 0;
            }
            ssa.UnitCount=unit;

        finWra.add(ssa);
        
        LatestRevenue = rev;
        
        System.debug('#####'+finWra);
        }
     
    }
    
    
    public class financeWrapperInfo{
        public string productName{get;set;}
        public decimal ARPU {get;set;}
        public decimal UnitCount {get;set;}
        public Date ContractEndDate {get;set;}
        public decimal Revenue {get;set;}
    }

}