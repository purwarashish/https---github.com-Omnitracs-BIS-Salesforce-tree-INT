/**
    * ManageQuoteLineScheduleController - <Manages Activation Schedules and Revisions for the Quote>
    * Created by Yasir Arafat
    * @author: Yasir Arafat
    * @version: 1.0
*/

public class ManageQuoteLineScheduleController {
    public Map<ID, List<Quote_Line_Schedule__c>> workingSchedulesMap {get;set;}
    public Map<ID, List<Quote_Line_Schedule__c>> activeSchedulesMap {get;set;}
    public Map<Decimal, Map<ID, List<Quote_Line_Schedule__c>>> revisionSchedulesMap {get;set;}
    public List<Decimal> revisionList {get;set;}
    public Map<ID, SBQQ__QuoteLine__c> quoteLinesMap {get;set;}
    public Map<ID, Double> lineQuantityMap {get;set;}
    public Map<Decimal, String> revisionStatusMap {get;set;}
    public Map<ID, String> lineScheduleLabelMap {get;set;}
    public Map<ID, String> lineIdNameMap {get;set;}
    public Quote_Line_Schedule__c del;
    public List<Revision_Schedule__c> revisionSchedules {get;set;}
    public List<Quote_Line_Schedule__c> delScheduleList {get;set;}
    public Revision_Schedule__c workingRevisionSched {get;set;}
    public String quoteId {get;set;}
    public String quoteName {get;set;}
    public Boolean isOppClosed {get;set;}
    public String quoteLineId {get;set;}
    public Integer rowIndex {get;set;}
    public Id workingRevScheduleId {get;set;}
    public String quoteApprovalStatus {get;set;}
    public String workingRevStatus {get;set;}
    public Boolean isWorkingRevision {get;set;}
    public Boolean isDraftRevision {get;set;}
    public Boolean isActiveRevision {get;set;}
    public Decimal workingRevision {get;set;}
    public Decimal activeRevision {get;set;}
    public Decimal highestRevision {get;set;}
    
    public ManageQuoteLineScheduleController() {
        quoteId = ApexPages.currentPage().getParameters().get('id');
    }
    
    public void initialize() {
        isWorkingRevision = false;
        isDraftRevision = false;
        isActiveRevision = false;
        isOppClosed = false;
        workingRevision = null;
        workingRevScheduleId = null;
        delScheduleList = new List<Quote_Line_Schedule__c>();
        revisionStatusMap = new Map<Decimal, String>();
        quoteLinesMap = new Map<ID, SBQQ__QuoteLine__c>([Select Id, Name, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName, SBQQ__Quote__r.Expected_Shipment_Start__c, SBQQ__Quote__r.Name, SBQQ__Quote__r.Delivery_Schedule__c, SBQQ__Quote__r.Schedule_Type__c, SBQQ__Quote__r.ApprovalStatus__c, SBQQ__EffectiveQuantity__c, SBQQ__Product__r.Name, SBQQ__Product__r.Product_Type__c from 
        SBQQ__QuoteLine__c where SBQQ__Quote__c = :quoteId AND SBQQ__EffectiveQuantity__c > 0 AND SBQQ__Product__r.Shipment_Schedule_Required__c = TRUE]);
        quoteName = quoteLinesMap.size() > 0 ? quoteLinesMap.values()[0].SBQQ__Quote__r.Name : '';
        quoteApprovalStatus = quoteLinesMap.size() > 0 ? quoteLinesMap.values()[0].SBQQ__Quote__r.ApprovalStatus__c : '';
        List<Quote_Line_Schedule__c> schedules = [Select Id, Name, Quote_Line__c, Schedule_Date__c, Schedule_Quantity__c, Schedule_Status__c, Quantity_Fulfilled__c, Revision_Schedule__c, Status__c, Revision__c, Reason__c from Quote_Line_Schedule__c where Quote_Line__c in :quoteLinesMap.keySet() Order By Revision__c DESC, Schedule_Date__c];
        revisionSchedules = [Select Id, Name, Revision__c, Status__c from Revision_Schedule__c where Quote__c = :quoteId Order By Revision__c DESC];
        List<String> pendingStatusList = new list<String> { 'Pending Finance Approval', 'Pending Legal Approval' };
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
        isDraftRevision = revisionSchedules.size() > 0 ? workingRevStatus == 'Draft' : (!isOppClosed && quoteLinesMap.size() > 0);
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
        if(workingSchedulesMap.size() > 0 && ((highestRevision > 1 && !isDraftRevision) || (highestRevision == 1 && (quoteApprovalStatus == 'Pending' || quoteApprovalStatus == 'Approved'))))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, highestRevision > 1 ? 'Revision submitted for Approval.' : (quoteApprovalStatus == 'Approved' ? 'Quote Approved' : 'Quote submitted for Approval') + ' and pending Documents generation.'));
        if(revisionSchedules.size() == 0 && isOppClosed)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Opportunity has already been closed.'));
        recalculateScheduleLabelMap();
    }
    
    public void recalculateScheduleLabelMap(){
        lineScheduleLabelMap = new Map<ID, String>();
        lineIdNameMap = new Map<ID, String>();
        for(ID key : workingSchedulesMap.keySet()){
            List<Quote_Line_Schedule__c> scheduleList = workingSchedulesMap.get(key);
            Double totalQty = 0;
            for(Quote_Line_Schedule__c schedule : scheduleList){
                totalQty += schedule.Schedule_Quantity__c;
            }
            boolean isError = totalQty != quoteLinesMap.get(key).SBQQ__EffectiveQuantity__c;
            String label = quoteLinesMap.get(key).SBQQ__Product__r.Name + ' (Sum of Scheduled Quantity: ' + totalQty.intValue() + ') <span style="color: #7FFF48">' + (totalQty > quoteLinesMap.get(key).SBQQ__EffectiveQuantity__c ? 'is greater than' : (totalQty < quoteLinesMap.get(key).SBQQ__EffectiveQuantity__c ? 'is less than' : 'equals')) + '</span> (Effective Quantity: ' + quoteLinesMap.get(key).SBQQ__EffectiveQuantity__c.intValue() + ')' + (isError ? ' <span style="color: #7cf8ff">[ Please make sure Sum of Scheduled Quantity equals Effective Quantity ]</span>' : '');
            lineScheduleLabelMap.put(key, label);
        }
        for(ID key : quoteLinesMap.keySet()){
            lineIdNameMap.put(key, quoteLinesMap.get(key).SBQQ__Product__r.Name);
        }
    }
    
    public void addRow() {
        quoteLineId = ApexPages.currentPage().getParameters().get('quoteLineId');
        Quote_Line_Schedule__c lineSchedule = new Quote_Line_Schedule__c(Quote__c = quoteId, Quote_Line__c = quoteLineId, Schedule_Date__c = Date.today(), Schedule_Quantity__c = 0, Schedule_Status__c = 'Pipeline', Reason__c = 'New Schedule', Revision_Schedule__c = workingRevScheduleId);
        insert lineSchedule;
        workingSchedulesMap.get(quoteLineId).add(lineSchedule);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Schedule added successfully.'));
        recalculateScheduleLabelMap();
    }
    
    public boolean processSave(boolean checkReason) {
        recalculateScheduleLabelMap();
        boolean reasonError = false;
        lineQuantityMap = new Map<ID, Double>();
        boolean isError = false;
        for(ID key : workingSchedulesMap.keySet()){
            List<Quote_Line_Schedule__c> scheduleList = workingSchedulesMap.get(key);
            if(!lineQuantityMap.containsKey(key))
                lineQuantityMap.put(key, 0);
            Double totalQty = 0;
            for(Quote_Line_Schedule__c schedule : scheduleList){
                totalQty += schedule.Schedule_Quantity__c;
                if(checkReason && String.isBlank(schedule.Reason__c))
                    reasonError = true;
            }
            lineQuantityMap.put(key, totalQty);
            if(totalQty != quoteLinesMap.get(key).SBQQ__EffectiveQuantity__c){
                isError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Sum of Scheduled Quantity for Product <b>' + quoteLinesMap.get(key).SBQQ__Product__r.Name + '</b> is not in sync with Effective Quantity. <b style="color:red">Sum of Scheduled Quantity is ' + totalQty.intValue() + '</b> but it has to <b style="color:blue">match Effective quantity of ' + quoteLinesMap.get(key).SBQQ__EffectiveQuantity__c.intValue() + '</b>'));
            }
        }
        if(reasonError){
            isError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Reason is required for all the schedules before Submitting Revision for Approval.'));
        }
        if(!isError){
            List<Quote_Line_Schedule__c> scheduleListToUpsert = new List<Quote_Line_Schedule__c>();
            for(ID key : workingSchedulesMap.keySet()){
                List<Quote_Line_Schedule__c> scheduleList = workingSchedulesMap.get(key);
                for(Quote_Line_Schedule__c schedule : scheduleList){
                    scheduleListToUpsert.add(schedule);
                    /*if(schedule.Schedule_Quantity__c != 0)
                        scheduleListToUpsert.add(schedule);
                    else if (schedule.Schedule_Quantity__c == 0 && schedule.Id != null)
                        delScheduleList.add(schedule);*/
                }
            }
            if(scheduleListToUpsert.size() > 0)
                upsert scheduleListToUpsert;
            /*if(delScheduleList.size() > 0)
                delete delScheduleList;*/
        }
        return isError;
    }
    
    public PageReference submit(){
        PageReference pageRef = null;
        boolean isError = processSave(true);
        if(!isError){
            if(revisionSchedules.size() > 1){
                Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
                approvalReq.setComments('Submitting approval request for approval for Revision of Activation Schedule');
                approvalReq.setObjectId(workingRevScheduleId);
                // approvalReq.setNextApproverIds(new Id[] {opp.Next_Approver__c});
                // Submit the approval request for the Revision of Activation Schedule
                Approval.ProcessResult result = Approval.process(approvalReq);
                initialize();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Revision submitted successfully for Approval.'));
            }else{
                SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
                pageRef = new PageReference('/' + quoteId);
            }
        }
        return pageRef;
    }

    public PageReference save() {
        boolean isError = processSave(false);
        if(!isError){
            initialize();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Quote Line Schedules saved successfully.'));
        }
        return null;
    }
    
    public PageReference reset() {
        List<Quote_Line_Schedule__c> delScheduleList = [Select Id from Quote_Line_Schedule__c where Quote__c = :quoteId AND Revision_Schedule__c = :workingRevScheduleId];
        delete delScheduleList;
        initialize();
        return null;
    }
    
    public void addRevision() {
        Revision_Schedule__c newRevSched = new Revision_Schedule__c(Name = quoteName + '_REV_' + (highestRevision + 1), Quote__c = quoteId, Revision__c = highestRevision + 1, Status__c = 'Draft');
        insert newRevSched;
        List<Quote_Line_Schedule__c> revSchedules = new List<Quote_Line_Schedule__c>();
        for(ID key : activeSchedulesMap.keySet()){
            List<Quote_Line_Schedule__c> scheduleList = activeSchedulesMap.get(key);
            for(Quote_Line_Schedule__c schedule : scheduleList){
                revSchedules.add(new Quote_Line_Schedule__c(Quote__c = quoteId, Quote_Line__c = schedule.Quote_Line__c, Revision_Schedule__c = newRevSched.Id, Schedule_Date__c = schedule.Schedule_Date__c, Schedule_Quantity__c = schedule.Schedule_Quantity__c, Schedule_Status__c = 'Pipeline'));
            }
        }
        insert revSchedules;
        initialize();
    }
    
    /*public void deleteRow() {
        quoteLineId = ApexPages.currentPage().getParameters().get('quoteLineId');
        rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        del = workingSchedulesMap.get(quoteLineId).remove(rowIndex);
        if(del.Id != null)
            delScheduleList.add(del);
        recalculateScheduleLabelMap();
    }
    
    public void validateRevision() {
        for(ID key : activeSchedulesMap.keySet()){
            List<Quote_Line_Schedule__c> activeScheduleList = activeSchedulesMap.get(key);
            List<Quote_Line_Schedule__c> workingScheduleList = workingSchedulesMap.get(key);
            for(Quote_Line_Schedule__c schedule : activeScheduleList){              
            }
        }
    }*/
    
    public PageReference cancel() {
        return new PageReference('/' + quoteId);
    }
}