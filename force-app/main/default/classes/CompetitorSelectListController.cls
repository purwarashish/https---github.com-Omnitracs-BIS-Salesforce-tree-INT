/*******************************************************************************
 * File:  CompetitorSelectListController.cls
 * Date:  July 1st, 2018
 * Author:  Dennis Le & Sai Krishna Kakani
 * Description: Multi select list option for Competitors name in Opportunities 
 * *******************************************************************************/
public class CompetitorSelectListController {
   
    
    public Opportunity theOpportunity{get;set;}
    public String disableValue { get; set; }
    public Boolean disabledType { get; set; }
    public Boolean displayInputputText {get;set;}
    public Boolean saveAfterdisplay {get;set;}
    public String input {get; set{input = value; Find();}}
    public String CompetitorType {get;set;}
    map<String, Competitor__c> LeftOptionMap = new map<String, Competitor__c>();
    map<String, Competitor__c> RightOptionMap = new map<String, Competitor__c>();
    public Static map<Id, String> staticCompetitorsMap {get;set;}
    public list<String> LeftSelectedList {get;set;}
    public list<String> RightSelectedList {get;set;}
    public list<Competitive_Threat__c> competitivelistofopty {get;set;}
        
    public CompetitorSelectListController(ApexPages.StandardController stdController) {
        System.debug('StandardController constructor');
        theOpportunity = queryOpportunity(stdController.getId());
        LeftSelectedList = new list<String>();
        RightSelectedList = new list<String>();
        CompetitorType = theOpportunity.Type_of_Competitor__c;
        getCurrentCompetitors();
       
         if(CompetitorType == 'Competitive Takeaway'){
            displayInputputText = true;
            saveAfterdisplay = true;
            disabledType = true;
            disableValue = 'enabled';
        }
        
        else if(CompetitorType == 'Competitive Threat'){
            displayInputputText = true;
            saveAfterdisplay = true;
            disabledType = true;
            disableValue = 'enabled';
        }
        
        else {
            displayInputputText = false;
            saveAfterdisplay = false;
            disabledType = false;
            disableValue = 'disabled';
            
        }
       
        queryIntelligenceData ();
    }

    public void queryIntelligenceData () {
         competitivelistofopty = [select id, Competitor_Name__r.Name, Name, Competitor_Status__c, Has_Product_Solution_Today__c, CreatedDate from Competitive_Threat__c where Opportunity__c =:theOpportunity.id];
       
    }

    public CompetitorSelectListController () {
        System.debug('CompetitorSelectListController constructor');
    }
    
    public PageReference save() {
     
        staticCompetitorsMap = new map<Id, String>();
        
        List<Competitor__c> l_selectOptions = new List<Competitor__c>();
    //    List<SObject> scope = [Select Id, Name, Competitive_takeaway__c From Competitor__c where Competitive_takeaway__c = :theOpportunity.Id];
        List<SObject> scope = [Select Id, Name From Competitor__c];
                
        if(scope.size() > 0 || scope != null) {  
            try {           
                for (SObject obj : scope) {
                    Competitor__c rec = (Competitor__c) obj;
                    Competitor__c comp = new Competitor__c(Id = rec.Id);
                    l_selectOptions.add(comp);  
                }
                update l_selectOptions;
                
            }catch(DmlException e) {
                System.debug('An unexpected error has occurred updated l_selectOptions: ' + e.getMessage());
            } 
        }
        
        // delete and refresh
        List<Competitive_Threat__c>  competitorThreatlist = new list<Competitive_Threat__c> ();
        List<Competitive_Summary__c> cmpetitorSummaryList =  new list<Competitive_Summary__c> ();
        List<Competitive_Threat__c> competitiorThreatToDelete = new List<Competitive_Threat__c> ();
        List<Competitive_Summary__c> competitiorSummaryToDelete = new List<Competitive_Summary__c> ();
        
        set<id> competitorIDSet = new set<id> ();
        set<id> competitorIDToIgnore = new set<id> ();
        set<id> competitorSumaryIDset = new set<id> ();
        set<id> competitorSummaryIDSetToIgnore = new set<id> ();
        
        Map<id,Competitive_Threat__c> competitorThreatMap = new Map<id,Competitive_Threat__c> ();

        
        competitorThreatlist  = [select id,Account__c,Competitor_Name__c from Competitive_Threat__c where Account__c = :theOpportunity.AccountId];
        cmpetitorSummaryList = [SELECT Id,Competitive_Intelligence__r.Competitor_Name__c,Competitive_Intelligence__c,Opportunity__c FROM Competitive_Summary__c where  Opportunity__c=:theopportunity.id];
        
        for(Competitive_Threat__c ct : competitorThreatlist) {
            competitorIDSet.add(ct.Competitor_Name__c);
            competitorThreatMap.put(ct.Competitor_Name__c,ct);
        }
        
        for (Competitive_Summary__c cmps : cmpetitorSummaryList) {
           competitorSumaryIDset.add(cmps.Competitive_Intelligence__r.Competitor_Name__c);
        }
        
        List<Competitor__c> selected_list = new List<Competitor__c>();    
        List<Competitive_Threat__c> c_Intelligence = new List<Competitive_Threat__c>();   
        for (Competitor__c value : RightOptionMap.values()) {
            staticCompetitorsMap.put(value.Id, value.Name);
           // Competitor__c ct = new Competitor__c (Id = value.Id, Competitive_takeaway__c = theOpportunity.Id);
          //selected_list.add(ct);
           
            if(!competitorIDSet.contains(value.Id)){

                Competitive_Threat__c cthd = new Competitive_Threat__c(Account__c = theOpportunity.AccountId, Competitor_Name__c = value.Id, Opportunity__c = theopportunity.id);
                c_Intelligence.add(cthd);
            } else {
                competitorIDToIgnore.add(value.id);
            }
        }
        for(Competitive_Threat__c ct : competitorThreatlist) {
            if(!competitorIDToIgnore.contains(ct.Competitor_Name__c)) {
                competitiorThreatToDelete.add(ct);
            }
        }
        try {
            for(Competitive_Threat__c ct : competitiorThreatToDelete) {
              competitorThreatMap.remove(ct.Competitor_Name__c);
            }
            //delete competitiorThreatToDelete;
            
        } catch (DmlException e) {
            System.debug('An unexpected error has occurred updated l_selectOptions: ' + e.getMessage());
        }
        
        try {
            if (selected_list.size() > 0 ) {
                update selected_list;
            }   
        } catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }   
        
        try {
            if (c_Intelligence.size() > 0 ) {
                insert c_Intelligence;
                for(Competitive_Threat__c ct : c_Intelligence) {
                    competitorThreatMap.put(ct.Competitor_Name__c,ct);
                }
            }   
        } catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }   
        
        List<Competitive_Summary__c> compSumaryListToInsert = new List<Competitive_Summary__c> ();
        for (Competitor__c value : RightOptionMap.values()) {
            
            if(!competitorSumaryIDset.contains(value.Id)){

                Competitive_Summary__c cts = new Competitive_Summary__c(Competitive_Intelligence__c = competitorThreatMap.get(value.id).id,Account__c = theOpportunity.AccountId, Opportunity__c= theopportunity.Id, Competitor_Type__c = theOpportunity.Type_of_Competitor__c,Competitor__c=value.id);
                compSumaryListToInsert.add(cts);
            } else {
                competitorSummaryIDSetToIgnore.add(value.id);
            }
        }
        for (Competitive_Summary__c cmps : cmpetitorSummaryList) {
            if(!competitorSummaryIDSetToIgnore.contains(cmps.Competitive_Intelligence__r.Competitor_Name__c)) {
                competitiorSummaryToDelete.add(cmps);
            }
        }
        try {
            if(competitiorSummaryToDelete.size() > 0)
            delete competitiorSummaryToDelete;
            
        } catch (DmlException e) {
            System.debug('An unexpected error has occurred updated l_selectOptions: ' + e.getMessage());
        }  
        
        try {
            if (compSumaryListToInsert.size() > 0 ) {
                insert compSumaryListToInsert;
              
            }   
        } catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }   
        

        theOpportunity.Type_of_Competitor__c = competitortype;
        update theOpportunity;
        LeftOptionMap.clear();
        input = '';
        queryIntelligenceData ();
        PageReference reference = new PageReference('/apex/CompetitorSelectListController?id=' + theOpportunity.Id);
        reference.setRedirect(false);
  
        return reference;
    }
    
    public void removeMembers() {
        if (!RightSelectedList.isEmpty()) {
            for (String s : RightSelectedList) {
                if (RightOptionMap.containsKey(s)) {
                    LeftOptionMap.put(s, RightOptionMap.get(s));        
                }
                RightOptionMap.remove(s);
            }
        }
    }
    
    public void addMembers() {     
        for(String s : LeftSelectedList) {
            if (LeftOptionMap.containsKey(s)) {
                RightOptionMap.put(s, LeftOptionMap.get(s));        
            }
            LeftOptionMap.remove(s);
        } 
    }
    
    public list<SelectOption> getSelectedOptionValues() {
        list<SelectOption> TempOptionList = new list<SelectOption>();
        list<Competitor__c> TempValueList;
 
        TempValueList = RightOptionMap.values();
        TempValueList.sort();  // sort by name
        for (Competitor__c T : TempValueList) { 
            TempOptionList.add(new SelectOption(T.Id, T.Name));
        }   
        
        return TempOptionList;
    }

    public void Find() {
        
        String SearchText = null; 
        List<Competitor__c> compList = new List<Competitor__c>();   
        
        if (input.length() > 1) { 
            SearchText = '%'+input+'%';
            compList = [SELECT Id, Name FROM Competitor__c where Name like :SearchText limit 100];
            if (compList.size() > 0 || compList != null)
                LeftOptionMap.clear();        
        }
        
        if (compList != null && compList.size() > 0) {
            for (Competitor__c Co : compList) {
                if (!RightOptionMap.containsKey(Co.Id)) {
                LeftOptionMap.put(Co.Id, Co);
                }
            }
            saveAfterdisplay = true;
            disabledType = true;
        }  
    }  
    
    public list<SelectOption> getUnSelectedValues() {
        
        list<SelectOption> TempOptionList = new list<SelectOption>();
        list<Competitor__c> TempValueList; 
  
        TempValueList = LeftOptionMap.values();
        TempValueList.sort(); 
        for (Competitor__c O : TempValueList) { 
            TempOptionList.add(new SelectOption(O.Id, O.Name));
        }
        return TempOptionList;
    }  
       
         
    public PageReference getCurrentCompetitors() {  
        List<Competitor__c> theOppCompetitors;
        List<Competitive_Summary__c> currentCompetitiveSummaryList = new List<Competitive_Summary__c> ();
        currentCompetitiveSummaryList = [select id,Competitive_Intelligence__r.Competitor_Name__c from Competitive_Summary__c
                                         where Opportunity__c =:theOpportunity.Id];
        set<id> competitorIDSet = new set<id> ();
        for(Competitive_Summary__c cs : currentCompetitiveSummaryList) {
            competitorIDSet.add(cs.Competitive_Intelligence__r.Competitor_Name__c);
        }
        
        theOppCompetitors = [Select Id, Name From Competitor__c where id IN : competitorIDSet];
        
        LeftOptionMap.clear();
        if ( theOppCompetitors.size() > 0) {
            for (Competitor__c cObject : theOppCompetitors) {
                RightOptionMap.put(cObject.Id, cObject);
            }
        }
        
        PageReference oppPage = new PageReference('/apex/CompetitorSelectListController?id=' + theOpportunity.Id);
        oppPage.setRedirect(true);
          
        return oppPage;
    }  
 
    private static Opportunity queryOpportunity(id OppId)
    {
        return [select id, name, AccountId,Type_of_Competitor__c from Opportunity where id =: OppId];
    }
    
    public PageReference Cancel()
    {   
        disabledType = false;
        PageReference m_stc = new PageReference('/apex/CompetitorSelectListController?id=' + ApexPages.currentPage().getParameters().get('Id'));
        m_stc.setRedirect(true);
        
        return m_stc;
    }   
    
    public PageReference competitorLink() {
        
        PageReference competitor_pageRef;
        
        if (!disabledType) {
            for (String s : RightSelectedList) {
                if (RightOptionMap.containsKey(s)) {
                    competitor_pageRef = new PageReference('/' + RightOptionMap.get(s).Id);
                }
            }           
            return competitor_pageRef;
            
        } else {
            PageReference reference = new PageReference('/apex/CompetitorSelectListController?id=' + theOpportunity.Id);
            reference.setRedirect(false);
            return reference;
        }               
        
    }
     
}