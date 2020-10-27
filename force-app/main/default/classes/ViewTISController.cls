public class ViewTISController {

    public String state {get; set;}
    private Static String OPP_PREFIX = '006';
    private Static String LEAD_PREFIX = '00Q';
    private String oppRecId;
    private String leadRecId;
    Public boolean showDetail {get; set;}
    public List<SelectOption> OptionsList{get; set;}
    public list<TIS_Detail_Opp_Lead__c> TISDetail {get; set;}
    
    public ViewTISController(ApexPages.StandardController controller) {
        String recordId = Apexpages.currentPage().getParameters().get('Id');
        system.debug('@@@@recordId'+recordId);
        if(recordId != null && recordId.startsWith(OPP_PREFIX))
            oppRecId = recordId;
        else
            leadRecId = recordId;
             
        system.debug('@@@@oppRec:::'+ oppRecId);
        ShowDetail = true;
        OptionsList = new List<SelectOption>();
        calculateOptionsList();
    }
        
    public List<SelectOption> calculateOptionsList(){
        Set<String> fieldNameList = new Set<String>();
        fieldNameList.add('Owner');
        state = 'Owner';
        OptionsList.add(new SelectOption('Owner','Owner'));
        if(oppRecId != null){
            for (TIS_Detail_Opp_Lead__c TIS :[select name from TIS_Detail_Opp_Lead__c where Opportunity__c =:oppRecId and name !='Owner' limit 1000])
            {
                System.debug('There are Field Names in TIS_Detail_Opp_Lead__c table other than "Owner"');
                if (!FieldNameList.contains(TIS.name))
                {
                    System.debug('@@Add new record:"'+TIS.name+'" in the list');
                    FieldNameList.add(TIS.name);
                    OptionsList.add(new SelectOption(TIS.name,TIS.name));
                }
            
            }
        }
        else{
            for (TIS_Detail_Opp_Lead__c TIS :[select name from TIS_Detail_Opp_Lead__c where lead__c =:leadRecId and name !='Owner' limit 1000])
            {
                System.debug('There are Field Names in TIS_Detail_Opp_Lead__c table other than "Owner"');
                if (!FieldNameList.contains(TIS.name))
                {
                    System.debug('@@Add new record:"'+TIS.name+'" in the list');
                    FieldNameList.add(TIS.name);
                    OptionsList.add(new SelectOption(TIS.name,TIS.name));
                }
            
            }
               
        }
        return OptionsList;
        
    }
    
    public void showTISDetail()
    {
        System.debug('State====>'+ State);
        system.debug('opportunity Number:'+oppRecId);
        if(oppRecId != null)
            TISDetail = [Select 
                                Date_Time_In__c,
                                Date_Time_Out__c,
                                Duration__c,
                                Owner__c,
                                State__c,
                                Who__c
                         from 
                                 TIS_Detail_Opp_Lead__c
                         where 
                                 Name =:State
                         and 
                                 Opportunity__c =:oppRecId
                         order by Date_Time_In__c desc];
        else{             
        TISDetail = [Select 
                            Date_Time_In__c,
                            Date_Time_Out__c,
                            Duration__c,
                            Owner__c,
                            State__c,
                            Who__c
                     from 
                             TIS_Detail_Opp_Lead__c
                     where 
                             Name =:State
                     and 
                             Lead__c =:leadRecId
                     order by Date_Time_In__c desc ];
        }
        system.debug('TISDetail List:'+TISDetail);
       
    }
    
    

}