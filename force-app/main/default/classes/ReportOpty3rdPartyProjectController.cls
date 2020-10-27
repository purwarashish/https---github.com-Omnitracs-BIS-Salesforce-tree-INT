/*********************************************************************
Name    : ReportOpty3rdPartyProjectController
Author  : Shruti Karn
Date    : 1 June 2010

Usage   : Report to be used by Sales
    
Dependencies : none

Modified Date : 20 June 2010 - 8 July 2010 - David Ragsdale (DAR)
Comment : Updated code, reviewed queries
*********************************************************************/
public with sharing class ReportOpty3rdPartyProjectController{

    public Opportunity NewOpportunity  {get;set;} 
    
    public List<SelectOption> Product= new List<SelectOption>();
    public List<SelectOption> Project {get;set;}
    public List<SelectOption> forecastDemand {get;set;}
    public List<SelectOption> ShowOpp {get;set;}
    public list<Projects__c> projList {get;set;}
    public list<Opportunity> masterList {get;set;}
    public list<OpportunityLineItem> OppLineList{get;set;}
    public list<X3rd_Party_Contract_Service__c> PartyList {get;set;}
    public List<SelectOption> No_of_Records {get;set;}
    public list<Opportunity> oppList {get;set;}
    public list<Opportunity3RDPartyProdUtil> excelList = new list<Opportunity3RDPartyProdUtil>();
    public list<list<Opportunity3RDPartyProdUtil>> excelList1 = new list<list<Opportunity3RDPartyProdUtil>>();
    public List<Opportunity3RDPartyProdUtil> MasterList1 {get;set;}
    
    public String selProduct{get;set;}
    public String selStage {get;set;}
    public String sel_No_of_Records {get;set;}
    public String[] projValue {get;set;}
    public String[] demand {get;set;}
    public String alphabet{get;set;}
    public String search_Value{get;set;}
    private String projListString;
    
    public Boolean noRecords {get;set;}
    public Boolean isDisplay{get;set;}
    
    public integer currentPage {get; set;} 
    public Integer GrandTotal {get;set;}
    public Integer start_index;
    public Integer last_index;
    public Integer OppListSize {get;set;}
    
    public Long totalPages {get;set;}  
   
    private Map<Id,OpportunityLineItem> tempMapProd {get;set;}
    private Map<Id,Projects__c> tempMapProj {get;set;}
    private Map<Id,X3rd_Party_Contract_Service__c> tempMapParty {get;set;}
    private Integer sizeoflist;
    private list<id> IdList;
    private Integer diffValue;
 
    public void setExcelList(list<Opportunity3RDPartyProdUtil> excelList)
    {
        this.excelList = excelList;
    }
    
    public void setExcelList1(list<list<Opportunity3RDPartyProdUtil>> excelList)
    {
        this.excelList1 = excelList;
    }
    
    public list<Opportunity3RDPartyProdUtil> getExcelList()
    {
        return excelList;
    }
    
    public list<list<Opportunity3RDPartyProdUtil>> getExcelList1()
    {
        return excelList1;
    }

    public void setStart_Index(Integer start)
    {
        this.start_index = start;
    }

    public void setLast_Index(Integer last)
    {
        this.last_index = last;
    }

    public Integer getStart_Index()
    {
        return start_index ;
    }

    public Integer getLast_Index()
    {
        return last_index;
    }

    public void setProduct (List<SelectOption> Product )
    {
        this.Product = Product;
    }

    public List<SelectOption> getProduct  ()
    {
        return Product;
    }

    public String getTargetDate(DateTime t) 
    {  
        String DateStr;  
        if(t!=null)
        {
            DateStr = t.format('yyyy-MM-dd'); //formatting complies with SOQL    
            system.debug('Date:'+DateStr);    
        }
        return DateStr; 
    } 

    public ReportOpty3rdPartyProjectController()
    {
        NewOpportunity  = new Opportunity();
        Project = new List<SelectOption>();
        sel_No_of_Records = '20';
        sizeoflist = integer.valueof(sel_No_of_Records);
        start_index=0;
        last_index=sizeoflist;
        isDisplay = false;
        currentPage = 1;
        totalpages =1;  
        alphabet = 'All';
        search_Value = '';
        projValue = new String[]{};
        demand = new String[]{};
        OppListSize = 0;
        retrieveData();
    }

    public void retrieveData()
    {
        forecastDemand= new List<SelectOption>();
        
        Product.add(new SelectOption('Workflow','Workflow'));
        Product.add(new SelectOption('MCP200','MCP200'));
        Product.add(new SelectOption('MCP110','MCP110'));
        Product.add(new SelectOption('MCP100','MCP100'));
        Product.add(new SelectOption('MCP50','MCP50'));
        Product.add(new SelectOption('TT210','TT210'));
        Product.add(new SelectOption('Omnitracs','Omnitracs'));
        Product.add(new SelectOption('All','All'));
    
        ShowOpp = new List<SelectOption>(); 
        ShowOpp.add(new SelectOption('All','All'));
        ShowOpp.add(new SelectOption('Closed','Closed'));
        ShowOpp.add(new SelectOption('Open','Open'));
        

        No_of_Records = new List<SelectOption>();
        No_of_Records.add(new SelectOption('10','View 10 records'));
        No_of_Records.add(new SelectOption('20','View 20 records'));
        //No_of_Records.add(new SelectOption('30','View 30 records'));
    
        Schema.DescribeFieldResult fieldResult = Projects__c.Project_Stage__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistEntries)
            Project.add(new SelectOption(entry.getLabel(), entry.getValue()));
        
        Schema.DescribeFieldResult fieldResult1 = Opportunity.Forecast_Demand__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries1 = fieldResult1.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistEntries1)
            forecastDemand.add(new SelectOption(entry.getLabel(), entry.getValue()));    
    } //end retrieveData

    // to call report from "Run Report" button so that alphabet is set to "All"
    //everytime "Run Report" is called
    public void runReport()
    {
        alphabet='All';
        report();
    }

    public PageReference report()
    {
        start_index=0;
        last_index=sizeoflist;
        isDisplay = true;
        GrandTotal = 0;
        masterList = new list<Opportunity>();
        oppList = new list<Opportunity>();
        OppLineList = new list<OpportunityLineItem>();
        PartyList = new list<X3rd_Party_Contract_Service__c>();
        projList = new list<Projects__c>();

        String forecastDemand = '';
        String oppStage ='';
        String prodName ='';
        String oppStartDate ='';
        String projStage = '';
        String prodQuery ='';
        String projQuery ='';
        String sortQuery = '';
        String searchName = '';

system.debug('alphabet:'+alphabet);
        if(NewOpportunity.Start_Date__c > NewOpportunity.CloseDate)
        {
            ApexPages.Message msg0 = new ApexPages.Message(ApexPages.Severity.WARNING,'Error: Start Date cannot be greater than End Date.');
            ApexPages.addmessage(msg0);
            return null;
        }
        if(alphabet == 'All')
            sortQuery = '';
        else
            sortQuery = ' and Account.Name like ' +'\'' + alphabet + '%\'';
 
        if(search_Value.trim() == '' || search_value == null)
            searchName = '';
        else
            searchName =  ' and Account.Name  like'+'\''+ search_value + '%\'';
    
        if(demand.isEmpty())
            forecastDemand ='';
        else    
            forecastDemand =' and Forecast_Demand__c in : demand';
        
        if(selStage == 'Open')
            oppStage = ' and (StageName!=\'Closed Lost\' AND StageName!=\'Shipped\' AND StageName!=\'Contract Signed\' AND StageName!=\'Units Installed \' AND StageName!=\'Closed \' AND StageName!=\'Shipped/Contract\')'; 
        else if(selStage == 'Closed')
            oppStage = ' and (StageName=\'Closed Lost\' OR StageName=\'Shipped\' OR StageName=\'Contract Signed\' OR StageName=\'Units Installed \' OR StageName=\'Closed \' OR StageName=\'Shipped/Contract\')'; 
        else
            oppStage = '';
        
        if(selProduct == 'All')
            prodName = ' where OpportunityId !=null';
        else
            prodName = ' where PricebookEntry.Name like '+'\'%'+ selProduct + '%\' and OpportunityId !=null';
    
        prodQuery = ' and Id IN (Select OpportunityId from OpportunityLineItem '+ prodName+ ')';

        if(NewOpportunity.Start_Date__c == null)
            oppStartDate ='';
        else
            oppStartDate = ' and (Start_Date__c >= '+  getTargetDate(NewOpportunity.Start_Date__c) +')';
    
        String OppListString = 'Select Id,AccountId From Opportunity  where (CloseDate<='+  getTargetDate(NewOpportunity.CloseDate) + ')' +prodQuery +forecastDemand +oppStage +oppStartDate + sortQuery+searchName+' order by Account.Name asc limit 8000 ';    
        system.debug('OppListString:'+OppListString);

        try
        {
            OppList = database.query(OppListString);   
        } 
        catch(Exception e)
        {
            system.debug('Error in quering reocrds:'+e);
        }
    
        idList = new list<Id>();
        list<Id> acctIdList = new list<Id>();
        if(OppList.isEmpty())
        {
            //noRecords = true;
            
        }
        if(!(OppList.isEmpty()))
        {
            OppListSize = OppList.size();
        
            for(integer i=0;i<OppList.size();i++)
            {
                idList.add(OppList[i].Id);
                acctIdList.add(OppList[i].AccountId);
            }    
        }

        try
        {
            //OppLineList = [select PricebookEntry.Name,Description,OpportunityId from OpportunityLineItem where OpportunityId IN: idList limit 1000];
            
            PartyList = [Select Id,x.X3rd_Party__c, x.Partner_Type__c, x.Name, x.LastModifiedDate, x.LastModifiedById, x.CreatedDate, x.CreatedById,x.Account__c, x.Comments__c From X3rd_Party_Contract_Service__c x where x.Account__c in : acctIdList limit 1000]; 
            
            //projList = [Select p.Id,p.Opportunity__c,p.Opportunity__r.Name, p.Total_Estimated_Billable_Amount__c, p.Project_Status__c, p.Project_Stage__c, p.Project_Manager__c, p.Name, p.Actual_Start_Date__c, p.Actual_Completion_Date__c  From Projects__c p where  Opportunity__c in :IdList and  Project_Stage__c in :projValue limit 1000];
            if(projValue.isEmpty())
                projStage = '';
            else
                projStage = ' and Project_Stage__c in :  projValue ';
        
            projListString='Select p.Id,p.Opportunity__c,p.Opportunity__r.Name, p.Total_Estimated_Billable_Amount__c, p.Project_Status__c, p.Project_Stage__c, p.Project_Manager__c, p.Name, p.Actual_Start_Date__c, p.Actual_Completion_Date__c  From Projects__c p where  Opportunity__c in :idList'+projStage+' limit 1000';

            system.debug('Project string:'+projListString);

            projList = database.query(projListString);
        
            GrandTotal = OppList.size();
            MasterList1 = new list<Opportunity3RDPartyProdUtil>();
            //acctIdList = null;
            //projListString = null;
            //projStage = null;
            pagination2();
        }
        catch(Exception e) 
        {
            system.debug('Error in querying other lists:'+e);
            ApexPages.Message msg0 = new ApexPages.Message(ApexPages.Severity.WARNING,'Error: Your Query Returned more than 10,000 records. Please refine your search criteria.');
            ApexPages.addmessage(msg0);
            return null;
        }
   return null;
    } //end report

    // To change the value of start_index and last_index based on the value selected in the picklist for number of records for pagination
    public void ChangePagination()
    {
        system.debug('currPage:'+currentPage+'totalPages:'+totalPages);
                
        start_index = start_index;
        Integer diff = last_index-start_index;
        sizeoflist = integer.valueof(sel_No_of_Records);
        if(sizeoflist == 20)
        {
            currentPage = currentPage-1;
        }
        else
            currentPage = currentPage +1;
        if(sizeoflist < diff)
        {
            last_index = last_index - (diff - sizeoflist);
        }
    
        if(diff < sizeoflist)
        {
            last_index = last_index + (sizeoflist - diff);
        }
        
        pagination2();
    } //end pagination

    //To display 10 or 20 records as per value selected for pagination
    public PageReference pagination2()
    {
        if(OppList.size()>0)
        {
            Decimal size = OppList.size();
            Decimal pages = (size/sizeoflist);
            totalPages = pages.round(System.RoundingMode.UP);
            MasterList1.clear();
            diffValue = last_index - OppList.size();
            system.debug('diffValue:'+diffValue);
            if(last_index>OppList.size())
                last_index = OppList.size();
        
            if(start_index < = OppList.size())
            {
                list<Id> OppId = new  list<Id>();
                //OppId is used to query Products based on the OppList. Since all all the Product cannot be queried once in report()
                for(integer i=start_index;i<last_index;i++)
                {
                    OppId.add(OppList[i].Id);
                }

                for(integer i=start_index;i<last_index;i++)
                {
                    system.debug('inside for:');
                    Opportunity3RDPartyProdUtil newObj = new  Opportunity3RDPartyProdUtil();
                    newObj = newObj.tempMethod(OppList[i],PartyList,projList,OppId);
                    MasterList1.add(newObj);
                }
                
                pages = null;
                size = null;
            }
        }
   
        return null;
    } //end pagination2
 
    // Function to go next page
    public Pagereference next()
    {
        setStart_Index(last_index);
        setLast_Index(last_index+(sizeoflist));
        system.debug('start_index:'+start_index);
        system.debug('last_index:'+last_index);
        currentPage++;
        pagination2();
        return null;
    
    }

    // Function to go to previous page
    public PageReference previous()
    {
        system.debug('start_index:'+start_index);
        setStart_Index(start_index-(sizeoflist));
        if(diffValue > 0)
            last_index = last_index + diffValue;
        system.debug('last_index:'+last_index);
        setLast_Index(last_index-(sizeoflist));
        system.debug('start_index:'+start_index);
        system.debug('last_index:'+last_index);
        currentPage--;
        pagination2();
        return null;
    }

    //Method to implement Export to Excel
    public void ExporttoExcel()
    {
        tempMapProd = new Map<Id,OpportunityLineItem>();
        tempMapProj = new  Map<Id,Projects__c>();
        tempMapParty = new Map<Id,X3rd_Party_Contract_Service__c>();
        masterList = [Select Id,Start_Date__c, StageName, Ranking__c, Oppty_Quantity__c, Name, Forecast_Demand__c, Cust_ID__c, AccountId, Account.name From Opportunity where id in: idList order by Account.Name asc limit 1000];
        idList.clear();
        list<Id> acctIdList = new list<Id>();
        if(!(masterList.isEmpty()))
        {
            for(integer i=0;i<masterList.size();i++)
            {
                idList.add(masterList[i].Id);
                acctIdList.add(masterList[i].AccountId);
            }    
        }
        OppLineList = [select PricebookEntry.Name,Description,OpportunityId from OpportunityLineItem where OpportunityId IN: idList limit 1000];
        PartyList = [Select Id,x.X3rd_Party__c, x.Partner_Type__c, x.Name, x.LastModifiedDate, x.LastModifiedById, x.CreatedDate, x.CreatedById,x.Account__c, x.Comments__c From X3rd_Party_Contract_Service__c x where x.Account__c in : acctIdList limit 1000]; 
        //String projListString='Select p.Id,p.Opportunity__c,p.Opportunity__r.Name, p.Total_Estimated_Billable_Amount__c, p.Project_Status__c, p.Project_Stage__c, p.Project_Manager__c, p.Name, p.Actual_Start_Date__c, p.Actual_Completion_Date__c  From Projects__c p where  Opportunity__c in :idList'+projStage+' limit 1000';
        //system.debug('Project string:'+projListString);

       projList = database.query(projListString);
        
        if(!(OppLineList.isEmpty())) 
            for(integer i=0;i<OppLineList.size();i++)
                tempMapProd.put(OppLineList[i].OpportunityId,OppLineList[i]);
        
        if(!(PartyList.isEmpty()))
            for(integer i=0;i<PartyList.size();i++)
                tempMapParty.put(PartyList[i].Account__c,PartyList[i]);
     
        if(!(projList.isEmpty()))
            for(integer i=0;i<projList.size();i++)
                tempMapProj.put(projList[i].Opportunity__c,projList[i]);

        Opportunity3RDPartyProdUtil newObj = new  Opportunity3RDPartyProdUtil();
        masterList = [Select Id,Start_Date__c, StageName, Ranking__c, Oppty_Quantity__c, Name, Forecast_Demand__c, Cust_ID__c, AccountId, Account.name From Opportunity where id in: idList limit 1000];
        if(OppList.size()>1000)
        {
            for(integer i =0;i<1000;i++)
            {
                newObj  = newObj.tempExcelMethod(masterList[i],tempMapProd,tempMapParty,tempMapProj);            
                excelList.add(newObj);
            }
        }else{
            for(integer i =0;i<masterList.size();i++)
            {
                newObj  = newObj.tempExcelMethod(masterList[i],tempMapProd,tempMapParty,tempMapProj);            
                excelList.add(newObj);
            }
        } 
    } //end ExporttoExcel


    //This class is used to hold aal the four list in one object and the list of these objects is used in Visualforce Page
    public Class Opportunity3RDPartyProdUtil
    {
    
        public Opportunity tempOppList {get;set;}
        public list<OpportunityLineItem> tempProdList {get;set;}
        public list<X3rd_Party_Contract_Service__c> tempthirdParty {get;set;}
        public list<Projects__c> tempProjList {get; set;}
    
        //default constructor       
        public Opportunity3RDPartyProdUtil()
        {
        
        }

        public Opportunity3RDPartyProdUtil(Opportunity OppList,list<OpportunityLineItem> ProdList,list<X3rd_Party_Contract_Service__c> thirdParty,list<Projects__c> ProjList)
        {
            this.tempOppList = OppList;
            this.tempProdList = ProdList;
            this.tempProjList = ProjList;
            this.tempthirdParty = thirdParty;
        }
    
        public Opportunity3RDPartyProdUtil tempMethod(Opportunity OppList,list<X3rd_Party_Contract_Service__c> thirdParty,list<Projects__c> ProjList,list<Id> Idlist1)
        {
            tempOppList = [Select Id,Start_Date__c, CloseDate,Account.Name , StageName, Ranking__c, Oppty_Quantity__c, Name, Forecast_Demand__c, Cust_ID__c, AccountId From Opportunity where id = :OppList.Id limit 1];
            
            this.tempProdList = new list<OpportunityLineItem>();
            list<OpportunityLineItem> tempProdList1 = new list<OpportunityLineItem>();

            tempProdList1 = [select PricebookEntry.Name,Description,OpportunityId from OpportunityLineItem where OpportunityId IN: idList1 limit 1000];
            this.tempProjList = new list<Projects__c>();
            this.tempthirdParty = new list<X3rd_Party_Contract_Service__c>();
            
            if(tempProdList1.size()>0)
            {
                for(integer i=0;i<tempProdList1.size();i++)
                {
                
                    if(OppList.Id == tempProdList1[i].OpportunityId)
                    {
                        this.tempProdList.add(tempProdList1[i]);
                    }
                }
            }
        
            if(thirdParty.size()>0)
            {
                for(integer i=0;i<thirdParty.size();i++)
                {
                    if(OppList.AccountId == thirdParty[i].Account__c)
                    {
                        this.tempthirdParty.add(thirdParty[i]);
                    }
                }
            }
        
            if(ProjList.size()>0)
            {
                for(integer i=0;i<ProjList.size();i++)
                {
                    if(OppList.Id == ProjList[i].Opportunity__c)
                    {
                        this.tempProjList.add(ProjList[i]);
                    }
                }
            }
        
            Opportunity3RDPartyProdUtil newObj = new Opportunity3RDPartyProdUtil(tempOppList,tempProdList,tempthirdParty,tempProjList);
            system.debug(tempProdList);
            return newObj;
        }

        // this method is used for Export to Excel as the List of Opportunities will be queried in the outer class and will not queried here
        public Opportunity3RDPartyProdUtil tempExcelMethod(Opportunity OppList,Map<Id,OpportunityLineItem> tempMapProd,Map<Id,X3rd_Party_Contract_Service__c> tempMapParty ,Map<Id,Projects__c> tempMapProj )
        {
            tempOppList = OppList;        
            this.tempProdList = new list<OpportunityLineItem>();
            this.tempProjList = new list<Projects__c>();
            this.tempthirdParty = new list<X3rd_Party_Contract_Service__c>();
            
            if(!(tempMapProd.isEmpty()))
                if(tempMapProd.containsKey(OppList.Id))
                    this.tempProdList.add(tempMapProd.get(OppList.Id));
            
            if(!(tempMapParty.isEmpty()))      
                if(tempMapParty.containsKey(OppList.AccountId))
                    this.tempthirdParty.add(tempMapParty.get(OppList.AccountId));
        
            if(!(tempMapProj.isEmpty()))      
                if(tempMapProj.containsKey(OppList.Id))
                    this.tempProjList.add(tempMapProj.get(OppList.Id));
        
            Opportunity3RDPartyProdUtil newObj = new Opportunity3RDPartyProdUtil(tempOppList,tempProdList,tempthirdParty,tempProjList);
            return newObj;
        }

    } // end class
} // end class