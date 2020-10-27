public with sharing class ActivationScheduleController {
    public ActivationScheduleController() {

    }
    @AuraEnabled(cacheable=true)
    public static List<Quote_Line_Schedule__c> getQLSchedules(){
        Map<ID, SBQQ__QuoteLine__c> quoteLinesMap = new Map<ID, SBQQ__QuoteLine__c>();
        quoteLinesMap = new Map<ID, SBQQ__QuoteLine__c>([Select Id, Name, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName, SBQQ__Quote__r.Expected_Shipment_Start__c, SBQQ__Quote__r.Name, SBQQ__Quote__r.Delivery_Schedule__c, SBQQ__Quote__r.Schedule_Type__c, SBQQ__EffectiveQuantity__c, SBQQ__Product__r.Name, SBQQ__Product__r.Product_Type__c from 
        SBQQ__QuoteLine__c where SBQQ__Quote__c = :'a0zc0000004jRZY' AND SBQQ__EffectiveQuantity__c > 0 AND SBQQ__Product__r.Shipment_Schedule_Required__c = TRUE]);
        //quoteName = quoteLinesMap.size() > 0 ? quoteLinesMap.values()[0].SBQQ__Quote__r.Name : '';
        System.debug('Json responce test');
        List<Quote_Line_Schedule__c> schedules = [Select Id, Name, Quote_Line__c, Schedule_Date__c, Schedule_Quantity__c, Schedule_Status__c, Quantity_Fulfilled__c, Revision_Schedule__c, Status__c, Revision__c, Reason__c from Quote_Line_Schedule__c where Quote_Line__c in :quoteLinesMap.keySet() Order By Revision__c DESC, Schedule_Date__c];
        return schedules;
    }
    @AuraEnabled
    public static Map<String, String> getworkingSchedulesMap(string inputQuoteId){
         System.debug('Inside getworkingSchedulesMap '+ inputQuoteId);
         Map<String, String> setResult = new Map<String, String>();
         Map<ID, List<Quote_Line_Schedule__c>> workingSchedulesMap = new Map<ID, List<Quote_Line_Schedule__c>>();
         Map<ID, List<Quote_Line_Schedule__c>> activeSchedulesMap = new Map<ID, List<Quote_Line_Schedule__c>>();
         Map<Decimal, Map<ID, List<Quote_Line_Schedule__c>>> revisionSchedulesMap = new Map<Decimal, Map<ID, List<Quote_Line_Schedule__c>>>();
         List<Decimal> revisionList = new List<Decimal>();
         Map<ID, SBQQ__QuoteLine__c> quoteLinesMap = new Map<ID, SBQQ__QuoteLine__c>();
         Map<ID, Double> lineQuantityMap = new Map<ID, Double>();
         Map<Decimal, String> revisionStatusMap = new Map<Decimal, String>();
         Map<ID, String> lineScheduleLabelMap = new Map<ID, String>();
         Map<ID, String> lineIdNameMap = new Map<ID, String>();
         Quote_Line_Schedule__c del;
         List<Revision_Schedule__c> revisionSchedules = new List<Revision_Schedule__c>();
         List<Quote_Line_Schedule__c> delScheduleList = new List<Quote_Line_Schedule__c>();
         Revision_Schedule__c workingRevisionSched = new Revision_Schedule__c();
         String quoteId = inputQuoteId;
         //String quoteId ='a0zc0000004jRZY';
         String quoteName;
         String errorMessage;
         Boolean isOppClosed;
         //String quoteLineId;
         Integer rowIndex;
         Id workingRevScheduleId;
         String quoteApprovalStatus;
         String workingRevStatus;
         Boolean isWorkingRevision;
         Boolean isDraftRevision;
         Boolean isActiveRevision;
         Decimal workingRevision;
         Decimal activeRevision;
         Decimal highestRevision;

        isWorkingRevision = false;
        isDraftRevision = false;
        isActiveRevision = false;
        isOppClosed = false;
        workingRevision = null;
        workingRevScheduleId = null;
        delScheduleList = new List<Quote_Line_Schedule__c>();
        revisionStatusMap = new Map<Decimal, String>();
        quoteLinesMap = new Map<ID, SBQQ__QuoteLine__c>([Select Id, Name, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName, SBQQ__Quote__r.Expected_Shipment_Start__c, SBQQ__Quote__r.Name, SBQQ__Quote__r.Delivery_Schedule__c, SBQQ__Quote__r.Schedule_Type__c, SBQQ__EffectiveQuantity__c, SBQQ__Product__r.Name, SBQQ__Product__r.Product_Type__c,SBQQ__Quote__r.ApprovalStatus__c from 
        SBQQ__QuoteLine__c where SBQQ__Quote__c = :quoteId AND SBQQ__EffectiveQuantity__c > 0 AND SBQQ__Product__r.Shipment_Schedule_Required__c = TRUE]);
        quoteName = quoteLinesMap.size() > 0 ? quoteLinesMap.values()[0].SBQQ__Quote__r.Name : '';
        quoteApprovalStatus = quoteLinesMap.size() > 0 ? quoteLinesMap.values()[0].SBQQ__Quote__r.ApprovalStatus__c : '';
        List<Quote_Line_Schedule__c> schedules = [Select Id, Name, Quote_Line__c, Schedule_Date__c, Schedule_Quantity__c, Schedule_Status__c, Quantity_Fulfilled__c, Revision_Schedule__c, Status__c, Revision__c, Reason__c from Quote_Line_Schedule__c where Quote_Line__c in :quoteLinesMap.keySet() Order By Revision__c DESC, Schedule_Date__c];
        revisionSchedules = [Select Id, Name, Revision__c, Status__c from Revision_Schedule__c where Quote__c = :quoteId Order By Revision__c DESC];
        List<String> pendingStatusList = new list<String> { 'Pending Quote Approval', 'Pending Finance Approval', 'Pending Legal Approval' };
        for(Revision_Schedule__c revSchedule : revisionSchedules){
            if(revSchedule.Status__c == 'Draft' || pendingStatusList.contains(revSchedule.Status__c)){
                workingRevisionSched = revSchedule;
                workingRevision = revSchedule.Revision__c;
                isWorkingRevision = true;
                workingRevStatus = revSchedule.Status__c;
                workingRevScheduleId = revSchedule.Id;
            }else if(revSchedule.Status__c == 'Active'){
                activeRevision = revSchedule.Revision__c;
                isActiveRevision = true;
            }else if(revSchedule.Status__c == 'Frozen' || revSchedule.Status__c == 'Rejected'){
                revisionStatusMap.put(revSchedule.Revision__c, (revSchedule.Status__c == 'Frozen' ? 'Approved' : 'Rejected'));
            }
        }
        //isActiveRevision = schedules.size() > 0 ? schedules[0].Status__c == 'Active' : true;
        List<String> oppClosedStages = new list<String> { 'Closed Won', 'Closed Lost' };
        isOppClosed = quoteLinesMap.size() > 0 ? oppClosedStages.contains(quoteLinesMap.values()[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName) : false;
        highestRevision = revisionSchedules.size() > 0 ? revisionSchedules[0].Revision__c : 0;
        workingRevision = revisionSchedules.size() > 0 ? workingRevision : 1;
        isDraftRevision = revisionSchedules.size() > 0 ? (workingRevStatus == 'Draft' || workingRevStatus == 'Pending Quote Approval') : (!isOppClosed && quoteLinesMap.size() > 0);
        revisionSchedulesMap = new Map<Decimal, Map<ID, List<Quote_Line_Schedule__c>>>();
        revisionList = new List<Decimal>();
        for(Quote_Line_Schedule__c schedule : schedules){
            if(schedule.Status__c == 'Frozen' || schedule.Status__c == 'Rejected'){
                if(!revisionSchedulesMap.containsKey(schedule.Revision__c)){
                    revisionSchedulesMap.put(schedule.Revision__c, new Map<ID, List<Quote_Line_Schedule__c>>());
                    revisionList.add(schedule.Revision__c);
                }
                if(!revisionSchedulesMap.get(schedule.Revision__c).containsKey(schedule.Quote_Line__c)){
                    revisionSchedulesMap.get(schedule.Revision__c).put(schedule.Quote_Line__c, new List<Quote_Line_Schedule__c>());
                }
                revisionSchedulesMap.get(schedule.Revision__c).get(schedule.Quote_Line__c).add(schedule);
            }
        }
        Map<ID, List<Quote_Line_Schedule__c>> quoteWorkingSchedulesMap = new Map<ID, List<Quote_Line_Schedule__c>>();
        List<Quote_Line_Schedule__c> workingSchedules = new List<Quote_Line_Schedule__c>();
        activeSchedulesMap = new Map<ID, List<Quote_Line_Schedule__c>>();
        for(Quote_Line_Schedule__c schedule : schedules){
            if(schedule.Revision__c == workingRevision){
                if(!quoteWorkingSchedulesMap.containsKey(schedule.Quote_Line__c)){
                    quoteWorkingSchedulesMap.put(schedule.Quote_Line__c, new List<Quote_Line_Schedule__c>());
                }
                quoteWorkingSchedulesMap.get(schedule.Quote_Line__c).add(schedule);
                workingSchedules.add(schedule);
            }
            if(schedule.Status__c == 'Active'){
                if(!activeSchedulesMap.containsKey(schedule.Quote_Line__c)){
                    activeSchedulesMap.put(schedule.Quote_Line__c, new List<Quote_Line_Schedule__c>());
                }
                activeSchedulesMap.get(schedule.Quote_Line__c).add(schedule);
            }
        }
        List<Quote_Line_Schedule__c> schedulesToSave = new List<Quote_Line_Schedule__c>();
        if(isDraftRevision){
            for (ID quoteLineId : quoteLinesMap.keySet()) {
                SBQQ__QuoteLine__c quoteLine = quoteLinesMap.get(quoteLineId);
                if(!quoteWorkingSchedulesMap.containsKey(quoteLineId)){
                    String scheduleType = quoteLine.SBQQ__Quote__r.Schedule_Type__c;
                    Date expectedShipmentDate = quoteLine.SBQQ__Quote__r.Expected_Shipment_Start__c != null ? quoteLine.SBQQ__Quote__r.Expected_Shipment_Start__c : Date.today();
                    Integer scheduleDelivery = Integer.valueOf(quoteLine.SBQQ__Quote__r.Delivery_Schedule__c != null ? quoteLine.SBQQ__Quote__r.Delivery_Schedule__c : '3');
                    Decimal totalQty = quoteLine.SBQQ__EffectiveQuantity__c;
                    Decimal firstLoadPercent = (scheduleType == 'Front load' ? 0.5 : (scheduleType == 'Level load' ? 0.33 : 0.2));
                    Decimal secondLoadPercent = (scheduleType == 'Front load' ? 0.3 : (scheduleType == 'Level load' ? 0.33 : 0.3));
                    List<Decimal> quoteLineQtyDist = new List<Decimal>();
                    Integer eachLoadMonths = scheduleDelivery / 3;
                    if(eachLoadMonths != 0){
                        Decimal firstLoadQty = Math.floor((totalQty * firstLoadPercent));
                        Decimal secondLoadQty = Math.floor((totalQty * secondLoadPercent));
                        Decimal thirdLoadQty = totalQty - (firstLoadQty + secondLoadQty);
                        List<Decimal> qtyLoads = new List<Decimal> {firstLoadQty, secondLoadQty, thirdLoadQty};
                        for(Decimal qty : qtyLoads){
                            Decimal equalQty = Math.floor(qty/eachLoadMonths);
                            Decimal remainderQty = Math.mod(Integer.valueOf(qty), eachLoadMonths);
                            for(Integer k = 1; k <= eachLoadMonths; k++){
                                Decimal quantity = (equalQty == 0 && k == 1 ? remainderQty : (equalQty == 0 && k != 1 ? 0 : (k == eachLoadMonths ? equalQty + remainderQty : equalQty)));
                                if(quantity > 0)
                                    quoteLineQtyDist.add(quantity);
                            }
                        }
                    }else{
                        quoteLineQtyDist.add(quoteLine.SBQQ__EffectiveQuantity__c);
                    }
                    if(workingRevScheduleId == null){
                        highestRevision += 1;
                        Revision_Schedule__c revSched = new Revision_Schedule__c(Name = quoteName + '_REV_' + highestRevision, Quote__c = quoteId, Revision__c = highestRevision, Status__c = 'Draft');
                        insert revSched;
                        workingRevisionSched = revSched;
                        workingRevScheduleId = revSched.Id;
                    }
                    for(Integer i=0; i<quoteLineQtyDist.size(); i++){
                        Date shipmentDate = expectedShipmentDate.addMonths(i);
                        Quote_Line_Schedule__c lineSchedule = new Quote_Line_Schedule__c(Quote__c = quoteId, Quote_Line__c = quoteLine.Id, Schedule_Date__c = shipmentDate, Schedule_Quantity__c = quoteLineQtyDist[i], Schedule_Status__c = 'Pipeline', Reason__c = 'Initial Schedule', Revision_Schedule__c = workingRevScheduleId);
                        schedulesToSave.add(lineSchedule);
                    }
                }
            }
        }
        if(schedulesToSave.size() > 0){
            insert schedulesToSave;
            isWorkingRevision = true;
            workingSchedules.addAll(schedulesToSave);
        }
        workingSchedulesMap = new Map<ID, List<Quote_Line_Schedule__c>>();
        for(Quote_Line_Schedule__c schedule : workingSchedules){
            if(!workingSchedulesMap.containsKey(schedule.Quote_Line__c))
                workingSchedulesMap.put(schedule.Quote_Line__c, new List<Quote_Line_Schedule__c>());
            workingSchedulesMap.get(schedule.Quote_Line__c).add(schedule);
        }
         
        if(workingSchedulesMap.size() > 0 && (!isDraftRevision || workingRevStatus == 'Pending Quote Approval'))
        errorMessage = revisionSchedules.size() > 1 ? 'Revision submitted for Approval.' : 'Quote submitted for Approval and pending Documents generation.';
        //    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, revisionSchedules.size() > 1 ? 'Revision submitted for Approval.' : 'Quote submitted for Approval and pending Documents generation.'));
        if(revisionSchedules.size() == 0 && isOppClosed)
        errorMessage = 'Opportunity has already been closed.';
        //    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Opportunity has already been closed.'));
        //recalculateScheduleLabelMap();
        //return workingSchedulesMap;

        //recalculateScheduleLabelMap
        lineScheduleLabelMap = new Map<ID, String>();
        lineIdNameMap = new Map<ID, String>();
        List<Quote_Line_Schedule__c> combinedList = new List<Quote_Line_Schedule__c>();

        for(ID key : workingSchedulesMap.keySet()){
            List<Quote_Line_Schedule__c> scheduleList = workingSchedulesMap.get(key);
            combinedList.addall(scheduleList);
            Double totalQty = 0;
            for(Quote_Line_Schedule__c schedule : scheduleList){
                totalQty += schedule.Schedule_Quantity__c;
            }
            boolean isError = totalQty != quoteLinesMap.get(key).SBQQ__EffectiveQuantity__c;
            //String label = quoteLinesMap.get(key).SBQQ__Product__r.Name + ' (Sum of Scheduled Quantity: ' + totalQty.intValue() + ')' + (totalQty > quoteLinesMap.get(key).SBQQ__EffectiveQuantity__c ? 'is greater than' : (totalQty < quoteLinesMap.get(key).SBQQ__EffectiveQuantity__c ? 'is less than' : 'equals')) + '(Effective Quantity: ' + quoteLinesMap.get(key).SBQQ__EffectiveQuantity__c.intValue() + ')' + (isError ? ' [ Please make sure Sum of Scheduled Quantity equals Effective Quantity ]' : '');
            String label = quoteLinesMap.get(key).SBQQ__Product__r.Name + ' (Effective Quantity: ' + quoteLinesMap.get(key).SBQQ__EffectiveQuantity__c.intValue() + ')';
            lineScheduleLabelMap.put(key, label);
        }
        for(ID key : quoteLinesMap.keySet()){
            lineIdNameMap.put(key, quoteLinesMap.get(key).SBQQ__Product__r.Name);
        }

        setResult.put('workingSchedulesMap', JSON.serialize(workingSchedulesMap));
        setResult.put('lineScheduleLabelMap', JSON.serialize(lineScheduleLabelMap));
        setResult.put('lineIdNameMap', JSON.serialize(lineIdNameMap));
        setResult.put('revisionSchedulesMap', JSON.serialize(revisionSchedulesMap));
        setResult.put('activeSchedulesMap', JSON.serialize(activeSchedulesMap));
        setResult.put('workingRevScheduleId',workingRevScheduleId);
        setResult.put('csvData',JSON.serialize(combinedList));
        setResult.put('quoteId', quoteId);
        setResult.put('errorMessage',errorMessage);
        setResult.put('workingRevision', String.valueOf(workingRevision));
        setResult.put('activeRevision', String.valueOf(activeRevision));
        setResult.put('isWorkingRevision',String.valueOf(isWorkingRevision));
        setResult.put('workingRevStatus', workingRevStatus);
        setResult.put('isDraftRevision', String.valueOf(isDraftRevision));
        setResult.put('isActiveRevision', String.valueOf(isActiveRevision));
        setResult.put('quoteApprovalStatus',String.valueOf(quoteApprovalStatus));
        setResult.put('highestRevision',String.valueOf(highestRevision));
        setResult.put('revisionStatusMap',JSON.serialize(revisionStatusMap));

        return setResult;
    }
    @AuraEnabled
    public static void addRow(string quoteId,string quoteLineId,string workingRevScheduleId) {
        //quoteLineId = ApexPages.currentPage().getParameters().get('quoteLineId');
        Quote_Line_Schedule__c lineSchedule = new Quote_Line_Schedule__c(Quote__c = quoteId, Quote_Line__c = quoteLineId, Schedule_Date__c = Date.today(), Schedule_Quantity__c = 0, Schedule_Status__c = 'Pipeline', Reason__c = 'New Schedule', Revision_Schedule__c = workingRevScheduleId);
        insert lineSchedule;
        //workingSchedulesMap.get(quoteLineId).add(lineSchedule);
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Schedule added successfully.'));
        //recalculateScheduleLabelMap();
    }
    @AuraEnabled
    public static string submitForApproval(string quoteId, string workingRevisionSchedID){
        Revision_Schedule__c Rs = new Revision_Schedule__c();
        List<Revision_Schedule__c> revisionList = new List<Revision_Schedule__c>();
        revisionList = [Select Id, Name, Revision__c, Status__c from Revision_Schedule__c where Quote__c = :quoteId Order By Revision__c DESC];

        if(revisionList.size() > 1){
            Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
                approvalReq.setComments('Submitting approval request for approval for Revision of Activation Schedule');
                approvalReq.setObjectId(workingRevisionSchedID);
                // approvalReq.setNextApproverIds(new Id[] {opp.Next_Approver__c});
                // Submit the approval request for the Revision of Activation Schedule
                Approval.ProcessResult result = Approval.process(approvalReq);
                //initialize();
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Revision submitted successfully for Approval.'));
                return 'Revision submitted successfully for Approval.';
         }
         else {
                Rs.Id=workingRevisionSchedID;
                Rs.Status__c = 'Pending Quote Approval';
                update Rs;
                SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
                return 'Submitted for Approval';
         }
        
    }
    @AuraEnabled
    public static string updateQLS(string quoteScheduleID, string reason,Double quantity, Date scheduledDate){
        System.debug('Json responce test updateQLS');
        Quote_Line_Schedule__c updateQLS = new Quote_Line_Schedule__c();
        Quote_Line_Schedule__c newupdateQLS = new Quote_Line_Schedule__c();
        Decimal totalEffectiveQuantity;
        Decimal getQuantity = 0;
        updateQLS = [SELECT ID,Schedule_Date__c,Schedule_Quantity__c,Reason__c,Quote__c,Revision_Schedule__c,Quote_Line__c,Quote_Line__r.SBQQ__EffectiveQuantity__c FROM Quote_Line_Schedule__c WHERE ID =: quoteScheduleID];
        totalEffectiveQuantity = updateQLS.Quote_Line__r.SBQQ__EffectiveQuantity__c;

        List<Quote_Line_Schedule__c> relatedQLS = new List<Quote_Line_Schedule__c>();
        relatedQLS = [SELECT ID,Schedule_Date__c,Schedule_Quantity__c,Reason__c,Quote__c,Revision_Schedule__c FROM Quote_Line_Schedule__c WHERE Quote__c =: updateQLS.Quote__c AND Revision_Schedule__c =: updateQLS.Revision_Schedule__c AND Quote_Line__c =: updateQLS.Quote_Line__c];

        if(quantity>0)
        {
          for(Quote_Line_Schedule__c qls : relatedQLS)
            {
                if(qls.Id != quoteScheduleID)
                {
                getQuantity = getQuantity + qls.Schedule_Quantity__c;
                }
                else {
                    getQuantity = getQuantity + quantity;
                }
            }
        if(totalEffectiveQuantity < getQuantity)
            {
                throw new AuraHandledException('You are exceding the total effective quantity');
            }
            else {
                newupdateQLS.Schedule_Quantity__c = quantity;
            }
        } 
        else{
            newupdateQLS.Schedule_Quantity__c = quantity;
        }
         
        if(scheduledDate != null)
        {
            newupdateQLS.Schedule_Date__c = scheduledDate;
        }
        if(reason != null)
        {
            newupdateQLS.Reason__c = reason;
        }
        
        newupdateQLS.Id = quoteScheduleID;
        System.debug('Json responce test updateQLS'+newupdateQLS);
        System.debug(Limits.getDMLStatements() +', '+ Limits.getLimitDMLStatements());
        update newupdateQLS;
        return 'Ok';
    }
    @AuraEnabled
    public static string addRevision(string quoteId,string workingRevScheduleId){

        SBQQ__Quote__c quoteDetails = new SBQQ__Quote__c();
        List<Quote_Line_Schedule__c> revSchedules = new List<Quote_Line_Schedule__c>();
        Revision_Schedule__c revisionDetails = new Revision_Schedule__c();
        Decimal highestRevision  = 0; 
        System.debug('addRevision'+quoteId);
        System.debug('addRevision'+workingRevScheduleId);

        List<Revision_Schedule__c> revisionSchedules = new List<Revision_Schedule__c>();
        revisionSchedules = [Select Id, Name, Revision__c, Status__c from Revision_Schedule__c where Quote__c = :quoteId Order By Revision__c DESC];
        highestRevision = revisionSchedules.size() > 0 ? revisionSchedules[0].Revision__c : 0;

        quoteDetails = [SELECT Name FROM SBQQ__Quote__c WHERE Id =: quoteId];
        //revisionDetails = [SELECT Id, Name, Revision__c FROM Revision_Schedule__c WHERE Id =:workingRevScheduleId];

        //Revision_Schedule__c newRevSched = new Revision_Schedule__c(Name = quoteDetails.Name + '_REV_' + (revisionDetails.Revision__c + 1), Quote__c = quoteId, Revision__c = revisionDetails.Revision__c + 1, Status__c = 'Draft');
        Revision_Schedule__c newRevSched = new Revision_Schedule__c(Name = quoteDetails.Name + '_REV_' + (highestRevision + 1), Quote__c = quoteId, Revision__c = highestRevision + 1, Status__c = 'Draft');
        insert newRevSched;
        
        
        for(Quote_Line_Schedule__c qls : [SELECT Id,Quote__c,Quote_Line__c,Revision_Schedule__c,Schedule_Date__c,Schedule_Quantity__c,Schedule_Status__c FROM Quote_Line_Schedule__c WHERE Revision_Schedule__c =:revisionSchedules[0].Id]){
           
            Quote_Line_Schedule__c copySchedule = new Quote_Line_Schedule__c();
            copySchedule.Quote__c = qls.Quote__c;
            copySchedule.Quote_Line__c = qls.Quote_Line__c;
            copySchedule.Revision_Schedule__c = newRevSched.Id;
            copySchedule.Schedule_Date__c = qls.Schedule_Date__c;
            copySchedule.Schedule_Quantity__c = qls.Schedule_Quantity__c;
            copySchedule.Schedule_Status__c = 'Pipeline';
            revSchedules.add(copySchedule);
        }
        
        /*for(ID key : activeSchedulesMap.keySet()){
            List<Quote_Line_Schedule__c> scheduleList = activeSchedulesMap.get(key);
            for(Quote_Line_Schedule__c schedule : scheduleList){
                revSchedules.add(new Quote_Line_Schedule__c(Quote__c = quoteId, Quote_Line__c = schedule.Quote_Line__c, Revision_Schedule__c = newRevSched.Id, Schedule_Date__c = schedule.Schedule_Date__c, Schedule_Quantity__c = schedule.Schedule_Quantity__c, Schedule_Status__c = 'Pipeline'));
            }
        }*/
        insert revSchedules;
        System.debug('addRevision revSchedules'+revSchedules);
        //System.debug('addRevision'+workingRevScheduleId);
        //initialize();
        return 'Ok';
    }
}