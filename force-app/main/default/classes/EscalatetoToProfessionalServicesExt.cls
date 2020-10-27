/*
 *  @author:        Mark De Chavez | mark.dechavez@cloudsherpas.com
 *  @description:   Updates the field of Case Record if the record type is call center
 *  @date-created:  September 11, 2014
 *  @revision: 
 */
public class EscalatetoToProfessionalServicesExt {
    
    private Case caseRec;
    private Case updateCase;
    
    public EscalatetoToProfessionalServicesExt (ApexPages.StandardController sc){
        caseRec = (Case)sc.getRecord();
        updateCase = [SELECT RecordType.Name, Business_Unit__c, OwnerId, Status, is_case_being_upgraded__c, contract_status__c, tier__c FROM Case WHERE Id = : caseRec.Id];        
    }
    
    public PageReference updateFields(){
        RecordType profSvc = [SELECT Id FROM RecordType WHERE Name = : 'Professional Services'];
       // QueueSobject sylectusProfSvcQ = [SELECT Queue.Id FROM QueueSobject WHERE Queue.Name = : 'Sylectus Professional Services'];
       // QueueSobject cnrProfSvcQ = [SELECT Queue.Id FROM QueueSobject WHERE Queue.Name = : 'CNR Professional Services'];
        
        Map<String, QueueSobject> qObjMap = new Map<String, QueueSobject>();
        for (QueueSobject qObj : [SELECT Queue.Id, Queue.Name 
                                  FROM QueueSobject 
                                  WHERE Queue.Name = : 'CNR Professional Services'
                                  OR Queue.Name = : 'Sylectus Professional Services'
                                  OR Queue.Name = : 'Omnitracs Professional Services'
                                  OR Queue.Name = : 'Roadnet Professional Services'
                                  OR Queue.Name = : 'FRA Professional Services']){
            qObjMap.put(qObj.Queue.Name, qObj);
        }
        
        if (updateCase.RecordType.Name == 'Call Center' || updateCase.RecordType.Name == 'Email Generated Cases')
		{
            updateCase.RecordTypeId = profSvc.Id;
            if (updateCase.Business_Unit__c == 'Sylectus'){
                updateCase.OwnerId = qObjMap.get('Sylectus Professional Services').Queue.Id;
            }
            if (updateCase.Business_Unit__c == 'Omnitracs MX'){
                updateCase.OwnerId = qObjMap.get('CNR Professional Services').Queue.Id;
            }
            if (updateCase.Business_Unit__c == 'Omnitracs US'){
                updateCase.OwnerId = qObjMap.get('Omnitracs Professional Services').Queue.Id;
            }
            if (updateCase.Business_Unit__c == 'Roadnet')
			{
				//  per case no 01796594, if re-assign to pro serve button is hit, prepop the case's project status and tier
				updateCase.contract_status__c = '1 - Evaluating Project/Request';
				updateCase.Tier__c = '2 - Custom';
				updateCase.OwnerId = qObjMap.get('Roadnet Professional Services').Queue.Id;
            }
            if (updateCase.Business_Unit__c == 'FRA'){
                updateCase.OwnerId = qObjMap.get('FRA Professional Services').Queue.Id;
            }
        }
        
        try{
            Database.DMLOptions dlo = new Database.DMLOptions();

            dlo.EmailHeader.triggerUserEmail = true;
            Database.update(updateCase, dlo);
        }
        catch(Exception ex){
            System.debug('***Error on updating: ' + ex.getMessage());
        }
        
        if (updateCase.Status == 'Closed') { 
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Re-assigning a closed case to Professional Services is not allowed' )); 
            return null;
        }
        else {
            return (new ApexPages.StandardController(caseRec)).view();
        }
    }    
}