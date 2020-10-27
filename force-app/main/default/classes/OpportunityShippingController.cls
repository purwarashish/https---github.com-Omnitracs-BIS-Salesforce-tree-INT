/**
 * Controller class for the visual force page: OpportunityShippingMaintenance.
 *
 */
public class OpportunityShippingController {
    /* ARMAN:
    public Shipping_Estimate_Summary__c summary { get; set; }
    //public SBQQ__QuoteLineGroup__c qlGroup;
    //public SBQQ__Quote__c quote { get; set; }
    //public SBQQ__QuoteLine__c quoteLine { get; set; }
    public Opportunity opportunity { get; set; }
    public String closePage { get; set; }
    public String quoteLineGroup { get; set; }
    public Date oppCloseDate { get; set; }
    public Id passedQLGroupId { get; set; }
    public Id passedQuoteId { get; set; }
    public List<SBQQ__QuoteLineGroup__c> quoteLineGroupsList { get; set; }
    public List<Shipping_Estimate__c> shippingEstimateList { get; set; }
    public List<Shipping_Estimate__c> deleteEstimateList { get; set; }
    public String estimatesChanged { get; set; }
    public Decimal targetQuantity { get; set; }
    public String qtyToShow { get; set; }
    public Boolean estErr { get; set; } */

    public OpportunityShippingController(ApexPages.StandardController sc) {
        System.debug('OpportunityShippingController.OpportunityShippingController');
        /* ARMAN: passedQuoteId = ApexPages.currentPage().getParameters().get('quoteId');
        try {
            quoteLineGroupsList = [SELECT Id, Name FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :passedQuoteId];
        } catch (QueryException eek) {
            System.debug(LoggingLevel.INFO, 'OpportunityShippingController.OpportunityShippingController user is trying to access Shipping Maintenace without a group: ' + passedQuoteId);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You do not have a Quote Line Group on the quote. Please return to the quote line editor and add a group. '));
            estErr = true;
        }

        passedQLGroupId = ApexPages.currentPage().getParameters().get('qlGroupId');
        estimatesChanged = ApexPages.currentPage().getParameters().get('estChg');
        closePage = ApexPages.currentPage().getParameters().get('closePage');
        setupBasics(); */
    }

    /**
     * Initialize the basic values for the page.
     */
    /* ARMAN: public void setupBasics() {
        shippingEstimateList = new List<Shipping_Estimate__c>();
        deleteEstimateList = new List<Shipping_Estimate__c>();
        getShippingEstimateSummary(passedQLGroupId);
        if (summary.Name != null) {
            shippingEstimateList = getShippingEstimates(summary);
            oppCloseDate = summary.Quote_Line_Group__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.CloseDate;
        }
        if (passedQLGroupId != null) {
            quoteLineGroup = passedQLGroupId;
        }
        if (summary.Group_Service_Plan_Quantity_Rollup__c != null && summary.Group_Service_Plan_Quantity_Rollup__c != 0) {
            targetQuantity = summary.Group_Service_Plan_Quantity_Rollup__c;
            qtyToShow = 'sp';
        } else if (summary.Group_Hardware_Quantity_Rollup__c != null && summary.Group_Hardware_Quantity_Rollup__c != 0) {
            targetQuantity = summary.Group_Hardware_Quantity_Rollup__c;
            qtyToShow = 'hw';
        } else if (summary.Group_Application_Quantity_Rollup__c != null && summary.Group_Application_Quantity_Rollup__c != 0) {
            targetQuantity = summary.Group_Application_Quantity_Rollup__c;
            qtyToShow = 'ap';
        } else if (summary.Group_Software_Quantity_Rollup__c != null && summary.Group_Software_Quantity_Rollup__c != 0) {
            targetQuantity = summary.Group_Software_Quantity_Rollup__c;
            qtyToShow = 'sw';
        }
        if (targetQuantity != summary.Total_Estimated_Quantities__c) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Your estimated Quantity does not match the target product quantity.'));
            estErr = false;
        }
        try {
            opportunity = [SELECT Id, SBQQ__PrimaryQuote__c FROM Opportunity WHERE SBQQ__PrimaryQuote__c = :passedQuoteId];
        } catch (QueryException eek) {
            System.debug(LoggingLevel.INFO, 'OpportunityShippingController.setupBasics() user is trying to access Shipping Maintenace on a quote that is not primary: ' + passedQuoteId);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'This quote is not marked as Primary. You can only perform shipping maintenance on primary quotes.'));
            estErr = true;
        }
    }

    public void getShippingEstimateSummary(Id qlgId) {
        System.debug('OpportunityShippingController.getShippingEstimateSummary ' + passedQLGroupId);
        try {
            summary = [
                    SELECT Id, Name, Group_Hardware_Quantity_Rollup__c, Group_Service_Plan_Quantity_Rollup__c
                            , Group_Application_Quantity_Rollup__c, Group_Software_Quantity_Rollup__c
                            , Shipping_Summary_Status__c, Total_Estimated_Quantities__c, VEP_Opportunity_Type__c
                            , Quote_Line_Group__c, Quote_Line_Group__r.Name, Quote_Line_Group__r.SBQQ__Quote__r.Name
                            , Quote_Line_Group__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name
                            , Quote_Line_Group__r.Delivery_Schedule__c
                            , Quote_Line_Group__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.CloseDate
                    FROM Shipping_Estimate_Summary__c
                    WHERE Quote_Line_Group__r.Id = :passedQLGroupId LIMIT 1
            ];
            System.debug('OpportunityShippingController.getShippingEstimateSummary Name: ' + summary.Name);

        } catch (QueryException qe) {
            summary = new Shipping_Estimate_Summary__c();
        }

    }

    public List<Shipping_Estimate__c> getShippingEstimates(Shipping_Estimate_Summary__c summary) {
        System.debug('OpportunityShippingController.getShippingEstimates');
        List<Shipping_Estimate__c> shippingEstimates = new List<Shipping_Estimate__c>();
        try {
            shippingEstimates = [
                    select Id, Name, Estimated_Shipping_Date__c, Estimated_Shipping_Quantity__c
                            , Shipping_Notes__c, Shipping_Summary__r.Id, Shipping_Summary__r.Name
                            , Shipping_Summary__r.Quote_Line_Group__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.CloseDate
                    from Shipping_Estimate__c
                    where Shipping_Summary__c = :summary.Id
                    order by Estimated_Shipping_Date__c
            ];
            System.debug('OpportunityShippingController.getShippingEstimates() shippingEstimatesList: ' + shippingEstimates);
        } catch (QueryException qe) {
        }
        return shippingEstimates;
    } */

    /**
     * Action when close button is clicked.
     */
    /* ARMAN: public PageReference closePage() {
        if (estimatesChanged == 'true') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You have unsaved changes, please save changes before closing page.'));
            estErr = false;
            return null;
        } else {
            OpportunityFinancialsHandler.calculateOpportunityFinancials(opportunity.Id);
            PageReference pR = new PageReference('/' + passedQuoteId);
            pR.setRedirect(true);
            return pR;
        }
    } */

    /**
     * Action when the cancel button is clicked.
     */
    /* ARMAN: public void cancel() {
        estimatesChanged = 'false';
        passedQLGroupId = quoteLineGroup;
        setupBasics();
    } */

    /**
     * Action when the Start New Estimate button is clicked.
     */
    /* ARMAN: public PageReference saveShippingSummary() {
        System.debug('****OpportunityShippingController.saveShippingSummary');
        Shipping_Estimate_Summary__c summary = new Shipping_Estimate_Summary__c();
        try {
            summary.Quote_Line_Group__c = passedQLGroupId;
            insert summary;
            SBQQ__QuoteLineGroup__c grp = new SBQQ__QuoteLineGroup__c();
            grp.Id = passedQLGroupId;
            grp.Shipping_Estimate_Summary__c = summary.Id;
            update grp;
        } catch (exception e) {
            System.debug('*********** ' + e.getMessage());
        }
        if (passedQLGroupId != null) {
            System.debug('*********** ');
            PageReference pR = new PageReference('/apex/OpportunityShippingMaintenance');
            pR.getParameters().put('qlGroupId', passedQLGroupId);
            pR.getParameters().put('estChg', estimatesChanged);
            pR.getParameters().put('quoteId', passedQuoteId);
            pR.setRedirect(true);
            return pR;
        } else {
            return null;
        }
    } */

    /**
     * Action when the Add Estimate button is clicked.
     */
    /* ARMAN: public void addRow() {
        System.debug('OpportunityShippingController.addRow');
        estimatesChanged = 'true';
        Shipping_Estimate__c estimate = new Shipping_Estimate__c();
        Shipping_Estimate__c lastEstimate = shippingEstimateList.get(shippingEstimateList.size() - 1);
        estimate.Estimated_Shipping_Date__c = lastEstimate.Estimated_Shipping_Date__c.addMonths(1);
        estimate.Estimated_Shipping_Quantity__c = summary.Group_Service_Plan_Quantity_Rollup__c - summary.Total_Estimated_Quantities__c;
        estimate.Default_Estimate__c = false;
        shippingEstimateList.add(estimate);
    }

    public void dataChanged() {
        System.debug('OpportunityShippingController.dataChanged');
        estimatesChanged = 'true';
    }

    public void deleteShippingEstimate() {
        System.debug('OpportunityShippingController.deleteShippingEstimate');
        estimatesChanged = 'false';
        Integer rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        try {
            Shipping_Estimate__c shippingEstimate = shippingEstimateList.remove(rowIndex);
            delete shippingEstimate;
        } catch (Exception ex) {

        }
        setupBasics();
    } */

    /**
     * Action when the Save Estimates button is clicked.
     */
    /* ARMAN: public void saveShippingEstimates() {
        System.debug('OpportunityShippingController.saveShippingEstimates');
        Boolean errBool = false;
        estimatesChanged = 'false';
        List<Shipping_Estimate__c> insertList = new List<Shipping_Estimate__c>();
        List<Shipping_Estimate__c> updateList = new List<Shipping_Estimate__c>();
        List<Shipping_Estimate__c> deleteList = new List<Shipping_Estimate__c>();
        Map<Date, Integer> dateMap = new Map<Date, Integer>();
        Map<Integer, Shipping_Estimate__c> estimateMap = new Map<Integer, Shipping_Estimate__c>();
        for (Integer i = 0; i < shippingEstimateList.size(); i++) {
            if (shippingEstimateList[i].Estimated_Shipping_Date__c != null) {
                System.debug('OpportunityShippingController.saveShippingEstimates() Estimated Shipping Date: ' + shippingEstimateList[i].Estimated_Shipping_Date__c.format() + ' Matching? ' + dateMap.containsKey(shippingEstimateList[i].Estimated_Shipping_Date__c));
                if (!dateMap.containsKey(shippingEstimateList[i].Estimated_Shipping_Date__c)) {
                    dateMap.put(shippingEstimateList[i].Estimated_Shipping_Date__c, i);
                    System.debug('datemap record: ' + shippingEstimateList[i].Estimated_Shipping_Date__c + ' -- ' + i);
                }
            }
        }
        System.debug('finalDatemap ' + dateMap);
        System.debug('shippingEstimateList size: ' + shippingEstimateList.size());
        Integer listSize = shippingEstimateList.size();
        for (Integer i = 0; i < listSize; i++) {
            System.debug('list record: ' + shippingEstimateList[i].Estimated_Shipping_Date__c + ' -- ' + i);
            if (shippingEstimateList[i].Estimated_Shipping_Date__c == null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Estimate Date is required in Estimate Number: ' + (i + 1)));
//                return null;
                errBool = true;
                estimatesChanged = 'true';
                estErr = true;
            } else if (shippingEstimateList[i].Id == null && shippingEstimateList[i].Estimated_Shipping_Date__c < oppCloseDate) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Estimate Date must be the same or after the close date of the opportunity in Estimate Number: ' + (i + 1)));
//                return null;
                errBool = true;
                estimatesChanged = 'true';
                estErr = true;
            } else if (shippingEstimateList[i].Estimated_Shipping_Date__c != null && shippingEstimateList[i].Estimated_Shipping_Quantity__c == null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Quatity is required in Estimate Number: ' + (i + 1)));
//                return null;
                errBool = true;
                estimatesChanged = 'true';
                estErr = true;
            } else {
                System.debug('OpportunityShippingController.saveShippingSchedule() datemap key found: ' + shippingEstimateList[i].Estimated_Shipping_Date__c + ' matching? ' + i + ' ' + dateMap.get(shippingEstimateList[i].Estimated_Shipping_Date__c));
                if (i == dateMap.get(shippingEstimateList[i].Estimated_Shipping_Date__c)) {
                    System.debug('OpportunityShippingController.saveShippingSchedule() ' + estimateMap);
                    if (!estimateMap.containsKey(i)) {
                        estimateMap.put(i, shippingEstimateList[i]);
                    }
                } else {
                    System.debug('OpportunityShippingController.saveShippingSchedule() creating a new shipping estimate');
                    Shipping_Estimate__c parentEstimate = new Shipping_Estimate__c();
                    parentEstimate = estimateMap.get(dateMap.get(shippingEstimateList[i].Estimated_Shipping_Date__c));
                    parentEstimate.Estimated_Shipping_Quantity__c = parentEstimate.Estimated_Shipping_Quantity__c + shippingEstimateList[i].Estimated_Shipping_Quantity__c;
                    parentEstimate.Default_Estimate__c = false;
                    if (parentEstimate.Shipping_Notes__c != null) {
                        if (shippingEstimateList[i].Shipping_Notes__c != null) {
                            parentEstimate.Shipping_Notes__c = parentEstimate.Shipping_Notes__c + '\n' + shippingEstimateList[i].Shipping_Notes__c;
                        }
                    } else {
                        if (shippingEstimateList[i].Shipping_Notes__c != null) {
                            parentEstimate.Shipping_Notes__c = shippingEstimateList[i].Shipping_Notes__c;
                        }
                    }
                    estimateMap.put(dateMap.get(shippingEstimateList[i].Estimated_Shipping_Date__c), parentEstimate);
                    deleteEstimateList.add(shippingEstimateList[i]);
                }
            }
        }
        System.debug('OpportunityShippingController.saveShippingEstimates() estimateMap after possible updates: ' + estimateMap);
        for (Shipping_Estimate__c estimate : estimateMap.values()) {
            if (estimate.Id == null) {
                estimate.Shipping_Summary__c = summary.Id;
                insertList.add(estimate);
            } else {
                estimate.Default_Estimate__c = false;
                updateList.add(estimate);
            }
        }
        for (Shipping_Estimate__c se : deleteEstimateList) {
            if (se.Id != null) {
                deleteList.add(se);
            }
        }
        try {
            System.debug('OpportunityShippingController.saveShippingEstimate() sizes of update lists insertList: ' + insertList.size() + ' updateList: ' + updateList.size() + ' deleteList: ' + deleteList.size());

            if (insertList.size() > 0) {
                insert insertList;
            }
            if (updateList.size() > 0) {
                System.debug('OpportunityShippingController.saveShippingEstimate() updateList: ' + updateList);
                update updateList;
            }
            if (deleteList.size() > 0) {
                delete deleteList;
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
                    'Failed saving the changes in the record. Please contact your System Administrator.'));
            System.debug('@SaveError: ' + ex.getMessage());
//            return null;
            errBool = true;
            estimatesChanged = 'true';
            estErr = true;
        }
        if (errBool == false) {
            System.debug('OpportunityShippingController.saveShippingEstimates() updating Default Summary & send to setupBasics');
            update summary;
            setupBasics();
        }
    }

    public List<SelectOption> getQuoteLineGroupItems() {
        List<SelectOption> qlgList = new List<SelectOption>();
        qlgList.add(new SelectOption('', '--None--'));
        if (quoteLineGroupsList.size() > 0) {
            for (SBQQ__QuoteLineGroup__c qlg: quoteLineGroupsList) {
                qlgList.add(new SelectOption(qlg.Id, qlg.Name));
            }
        }
        return qlgList;
    } */

    /**
     * Called when the group item is selected.
     */
    /* ARMAN: public void refreshForm() {
        //return new PageReference('/apex/c__OpportunityShippingMaintenance?qlGroupId=' + quoteLineGroup + '&quoteId=' + passedQuoteId);
        System.debug(' *** refreshForm quoteLineGroup ' + quoteLineGroup);
        if (estimatesChanged == 'true') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You have unsaved changes, please save changes before closing page.'));
            estErr = false;
//            return null;
        } else {
            passedQLGroupId = quoteLineGroup;
            setupBasics();
        }
    }

    @future
    public static void updateGroupShipSummFuture(Map<Id, Id> summaryIdMap) {
        System.debug('OpportunityShippingController.updateGroupShipSummFuture');
        List<SBQQ__QuoteLineGroup__c> groupUpdateList = new List<SBQQ__QuoteLineGroup__c>();
        for (Id sumId : summaryIdMap.keySet()) {
            SBQQ__QuoteLineGroup__c updateGroup = new SBQQ__QuoteLineGroup__c();
            updateGroup.Id = summaryIdMap.get(sumId);
            updateGroup.Shipping_Estimate_Summary__c = sumId;
            updateGroup.Shipping_Estimate_Summary_Exists__c = true;
            groupUpdateList.add(updateGroup);
        }
        if (groupUpdateList.size() > 0) {
            update groupUpdateList;
        }

    }

    @Future
    public static void quoteLineGroupSummaryUpdate(List<Id> quoteLineGroupIdList) {
        System.debug('Quote Line Group Summary');
        List<SBQQ__QuoteLineGroup__c> groupUpdateList = new List<SBQQ__QuoteLineGroup__c>();

        List<SBQQ__QuoteLineGroup__c> quoteLineGroupList = [SELECT Id, Name, Shipping_Estimate_Summary__c, Shipping_Estimate_Summary_Exists__c FROM SBQQ__QuoteLineGroup__c WHERE Id In :quoteLineGroupIdList];

        List<Shipping_Estimate_Summary__c> shippingEstimateSummaryList = [SELECT Id, Name, Quote_Line_Group__c FROM Shipping_Estimate_Summary__c WHERE Quote_Line_Group__c IN :quoteLineGroupIdList];


        Map<Id, Id> shippingQuoteGroupMap = new Map<Id, Id>();
        for(Shipping_Estimate_Summary__c summaryItem: shippingEstimateSummaryList) {
            shippingQuoteGroupMap.put(summaryItem.Quote_Line_Group__c, summaryItem.Id);
        }

        for(SBQQ__QuoteLineGroup__c quoteLineGroup: quoteLineGroupList) {
            if(shippingQuoteGroupMap.containsKey(quoteLineGroup.Id)){
                quoteLineGroup.Shipping_Estimate_Summary__c = shippingQuoteGroupMap.get(quoteLineGroup.Id);
                quoteLineGroup.Shipping_Estimate_Summary_Exists__c = true;
                groupUpdateList.add(quoteLineGroup);
            }
        }
        update groupUpdateList;
    } */

}