public class OutageListClass{
public list<System_Outage__c> OutageList {get; set;}
public String Case_num{get; set;}
String OutageID;
public list<System_Outage_Line__c> OutageLineList {get;set;}
public Boolean asce {get; set;}
public String current_Value {get; set;}
public String CaseId{get;set;}
public String alphabet{get;set;}
public Boolean isAlphaBar{get;set;}
public Integer INNERLIST_SIZE{get;set;}
public Integer OUTERLIST_SIZE{get;set;}
public string id1 {get;set;}
public integer counter {get;set;}

//Contructor for the class
public  OutageListClass(ApexPages.StandardController controller)
{
    CaseId = Apexpages.currentPage().getParameters().get('Id');
    //system.debug('OutageID:'+outageID);
    asce = false;
    isAlphaBar = true;
    counter=0;
    current_value = 'name';
    RedirectToOutageList();
}

//Method for displaying the list of System Outage with their dependencies
public pageReference RedirectToOutageList(){
    /*if(outageID != null)
    {
        CaseId = [Select Id, Case__c from System_Outage__c Where Id =:outageID limit 1].Case__c;
    }
    system.debug('CaseId:'+caseID);*/
    if(CaseId!=null)
    {
        try{
        Case_num = [select CaseNumber from case where Id =: CaseId].CaseNumber;
        OutageList = [select id,name,Subsystem_Lookup__c,Start_Time__c,End_Time__c,System_Lookup__c,Type__c,System__c,SubSystems__c,Calculated_Downtime__c,CreatedById,LastModifiedById from System_Outage__c where Case__c =: CaseId limit 1000];
        system.debug('Outage List:'+OutageList);
        List<Id> IdList = new list<Id>();
        for(integer i=0;i<OutageList.size();i++){
            IdList.add(OutageList[i].Id);
        }
        OutageLineList = [Select s.System_Outage_Header__c, s.System_Master__c, s.Outage_Type__c, s.Level__c, s.Id From System_Outage_Line__c s Where s.System_Outage_Header__c IN :IdList limit 1000 ];
        system.debug('Before add:'+OutageLineList );
        system.debug('after add');
        if(OutageList.size()>0)
        {
            OUTERLIST_SIZE = OutageList.size();
        }
        else
        {
            OUTERLIST_SIZE = 0;
        }
        
        if(OutageLineList.size()>0)
        {
            INNERLIST_SIZE = OutageLineList.size();
        }
        else
        {
            INNERLIST_SIZE = 0;
        }
    
        //INNERLIST_SIZE = OutageLineList.size();
        //OUTERLIST_SIZE = OutageList.size();
    }
    catch(Exception e)
    {
        system.debug('Exception inside Redirect to Outage List');
    }
}

    return null;

}


public PageReference ChangeOrder()
{
    try{
    if(current_value == 'Start_Time__c' || current_value == 'End_Time__c')
    {
        isAlphaBar =false;
    }
    else
    {
        isAlphaBar = true;
    }
    String prev_value;
    system.debug('before if');
    //system.debug('prev value:'+prev_value);
    /*if(prev_value != null && prev_value != current_value)
    {
        system.debug('inside chnage asce');
        asce = false;
    }
    else{*/
    if(asce == false)
    {
        system.debug('Ascending');
        asce =true;
        if(current_value == 'system')
        {
            OutageList = [select id,name,Subsystem_Lookup__c,Start_Time__c,End_Time__c,Type__c,System__c,System_Lookup__c,SubSystems__c,Calculated_Downtime__c,CreatedById,LastModifiedById from System_Outage__c where Case__c =: CaseId order by System_Lookup__r.name asc limit 1000];
                    }
        else if(current_value == 'subsystem')
        {
            system.debug('inside subsystem');
            OutageList = [select id,name,Subsystem_Lookup__c,Start_Time__c,End_Time__c,Type__c,System__c,System_Lookup__c,SubSystems__c,Calculated_Downtime__c,CreatedById,LastModifiedById from System_Outage__c where Case__c =: CaseId order by Subsystem_Lookup__r.name asc limit 1000];
            
        }
        else
        {
            system.debug('inside else');
            String strsql = 'select id,name,Subsystem_Lookup__c,Start_Time__c,End_Time__c,Type__c,System__c,System_Lookup__c,SubSystems__c,Calculated_Downtime__c,CreatedById,LastModifiedById from System_Outage__c where Case__c =' + '\'' + CaseId + '\'';
            String subsql = ' order by ' + current_value +' asc limit 1000';
            strsql = strsql + subsql;
            system.debug('strsql:'+strsql);
            OutageList = database.query(strsql);
            
        }
        system.debug('Value:'+OutageList);

    }
    else if(asce == true)
    {
        system.debug('Inside change Records');
        asce = false;
        system.debug('again:'+current_value);
        if(current_value == 'system')
        {
            OutageList = [select id,name,Subsystem_Lookup__c,Start_Time__c,End_Time__c,Type__c,System__c,System_Lookup__c,SubSystems__c,Calculated_Downtime__c,CreatedById,LastModifiedById from System_Outage__c where Case__c =: CaseId order by System_Lookup__r.name desc limit 1000];
        }
        else if(current_value == 'subsystem')
        {
            system.debug('inside subsystem');
            OutageList = [select id,name,Subsystem_Lookup__c,Start_Time__c,End_Time__c,Type__c,System__c,System_Lookup__c,SubSystems__c,Calculated_Downtime__c,CreatedById,LastModifiedById from System_Outage__c where Case__c =: CaseId order by Subsystem_Lookup__r.name desc limit 1000];
        }
        else
        {
            system.debug('inside else');
            String strsql = 'select id,name,Subsystem_Lookup__c,Start_Time__c,End_Time__c,Type__c,System__c,System_Lookup__c,SubSystems__c,Calculated_Downtime__c,CreatedById,LastModifiedById from System_Outage__c where Case__c =' + '\'' + CaseId + '\'';
            String subsql = ' order by ' + current_value +' desc limit 1000';
            strsql = strsql + subsql;
            system.debug('strsql:'+strsql);
            OutageList = database.query(strsql);
        }
        system.debug('OutageLsit'+OutageList);

    }
    prev_value=current_value;
    system.debug('prev_value:'+prev_value+'current_value:'+current_value);
    if(OutageList.size()>0)
    {
        OUTERLIST_SIZE = OutageList.size();
    }
    else
    {
        OUTERLIST_SIZE = 0;
    }
    }
    //}
    catch(Exception e)
    {
        system.debug('Error in Change Order');
    }
    return null;
}

public PageReference alphabet_Ordering()
{
    String selected_value = current_value;
    system.debug('alphabet:'+alphabet);
    try{
    if(alphabet == 'All')
    {
        system.debug('All:');
        OutageList = [select id,name,Subsystem_Lookup__c,Start_Time__c,End_Time__c,System_Lookup__c,Type__c,System__c,SubSystems__c,Calculated_Downtime__c,CreatedById,LastModifiedById from System_Outage__c where Case__c =: CaseId limit 1000];
    }
    else
    {
        if(current_value == 'system')
        {
            selected_value = 'System_Lookup__r.name';
        }
        else if(current_value == 'CreatedById')
        {
            selected_value ='createdBy.Name';
        }
        else if(current_value == 'LastModifiedById')
        {
            selected_value = 'LastModifiedBy.Name';
        }
        else if(current_value == 'subsystem')
        {
            system.debug('inside subsystem');
            selected_value = 'Subsystem_Lookup__r.name';
        }
        

            String strsql = 'select id,name,Subsystem_Lookup__c,Start_Time__c,End_Time__c,Type__c,System__c,System_Lookup__c,SubSystems__c,Calculated_Downtime__c,CreatedById,LastModifiedById from System_Outage__c where Case__c =' + '\'' + CaseId + '\'';
            string subsql1='and '+ selected_value +' like ' +'\'' + alphabet + '%\'';
            String subsql = ' order by ' + selected_value +' asc limit 1000';
            strsql = strsql + subsql1 + subsql;
            system.debug('strsql:'+strsql);
            OutageList = database.query(strsql);
            

    }
    if(OutageList.size()>0)
    {
        OUTERLIST_SIZE = OutageList.size();
    }
    else
    {
        OUTERLIST_SIZE = 0;
    }
    
    }
    catch(Exception e){
    system.debug('Error in alphbet ordering');
    }
    
    return null;
}


}