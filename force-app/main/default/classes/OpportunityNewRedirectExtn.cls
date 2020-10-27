public class OpportunityNewRedirectExtn {
private Opportunity Opp {get;set;}
public String recTypeId {get;set;}
public String retURL {get;set;}
public String accId {get;set;}
public OpportunityNewRedirectExtn(ApexPages.StandardController sc)
{
    Opp = (Opportunity)(sc.getRecord());
    
    recTypeId = Opp.RecordTypeId;
    
    if(recTypeId == null)
    {
    setRecordTypeIncaseNotSetted(); 
    recTypeId = apexpages.currentpage().getparameters().get('RecordType');
    }
    
    retURL = '/006';
    accId = '';
    if(apexpages.currentpage().getparameters().containsKey('retURL'))
    {
        retURL = apexpages.currentpage().getparameters().get('retURL');
    }
    if(apexpages.currentpage().getparameters().containsKey('accid'))
    {
        accId = '&accid=' + apexpages.currentpage().getparameters().get('accid');
        opp.AccountId = apexpages.currentpage().getparameters().get('accid');
    }
     
    
    System.debug('Opportunity record type: ' +  recTypeId);
    
}

public pageReference urlRedirect() 
{
    pageReference pg;   
    try{
    Opportunity_RecType_To_Stage_Mapping__c oppStageMapping = Opportunity_RecType_To_Stage_Mapping__c.getInstance(recTypeId);
    String stageName;
    if(oppStageMapping != null)
    {
        stageName = oppStageMapping.OpportunityStage__c ;
        pg = new PageReference('/006/e?retURL='+retURL+'&RecordType=' + recTypeId +'&ent=Opportunity&opp11='+ stageName +accId+'&nooverride=1');
    }
    else
    {
        pg = new PageReference('/006/e?retURL='+retURL+'&RecordType=' + recTypeId + accId +'&ent=Opportunity&nooverride=1');
    }
        
    }
    catch(exception e)
    {
        System.debug('*************** exception: ' + e.getMessage());
        pg = new PageReference('/006/e?retURL='+retURL+'&RecordType=' + recTypeId + accId +'&ent=Opportunity&nooverride=1');
    }   
    
    return pg; 
}   

/**
 * This method validates wether the record type is not set. This can only happen when the user has only
 * rights to one specific record type. In that scenario the user does not see the record type selection screen.
 * In these cases the record type is not set out of the box. This method finds the appropiate record type for this user and 
 * add this as a parameter to the page.  
 */
public void setRecordTypeIncaseNotSetted() {
    // in case it's null, the user has only one record type available. 
    if (ApexPages.currentPage().getParameters().get('RecordType') == null) {
        Schema.DescribeSObjectResult describeOpp = Schema.SObjectType.Opportunity;
        List<Schema.RecordTypeInfo> rtInfos = describeOpp.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            // walk through the map to determine the correct record type, this is done with the isAvailable() function
            if(rtInfo.getName() != 'Master' && rtInfo.isAvailable() && rtInfo.isDefaultRecordTypeMapping()) {
                // below lines will only run one time only
                System.debug('The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available, adding it as parameter to the page.');
                ApexPages.currentPage().getParameters().put('RecordType', rtInfo.getRecordTypeId());
            }
        }
        if (ApexPages.currentPage().getParameters().get('RecordType') == null) {
            System.debug('Still null after for, this should never happen.');
        }
    }
}

}