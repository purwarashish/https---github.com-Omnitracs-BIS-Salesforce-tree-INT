/**
 * Created by CrutchfieldJody on 11/29/2016.
 */

public with sharing class CustomerAssetShippingController {
    /* ARMAN: public Customer_Asset_Shipping_Summary__c summary { get; set; }
    public String closePage { get; set; }
    public Date customerAssetStartDate { get; set; }
    public Id passedCustAssetId { get; set; }

    public List<Customer_Asset_Shipping_Estimate__c> shippingEstimateList { get; set; }
    public List<Customer_Asset_Shipping_Estimate__c> deleteEstimateList { get; set; }
    public List<Customer_Asset_Shipping_Actual__c> shippingActualList { get; set; }
    public List<Customer_Asset_Shipping_Actual__c> deleteActualList { get; set; }

    public String estimatesChanged { get; set; }
    public String actualsChanged { get; set; }
    public Boolean estErr { get; set; }
    public Boolean actErr { get; set; } */

    public CustomerAssetShippingController(ApexPages.StandardController sc) {
        System.debug('CustomerAssetShippingController.CustomerAssetShippingController');
        /* ARMAN: passedCustAssetId = ApexPages.currentPage().getParameters().get('custAssetId');
        estimatesChanged = ApexPages.currentPage().getParameters().get('estChg');
        actualsChanged = ApexPages.currentPage().getParameters().get('actChg');
        closePage = ApexPages.currentPage().getParameters().get('closePage');
        setupBasics(); */
    }

    /* ARMAN: public void setupBasics() {
        shippingEstimateList = new List<Customer_Asset_Shipping_Estimate__c>();
        deleteEstimateList = new List<Customer_Asset_Shipping_Estimate__c>();
        shippingActualList = new List<Customer_Asset_Shipping_Actual__c>();
        deleteActualList = new List<Customer_Asset_Shipping_Actual__c>();

        getShippingEstimateSummary(passedCustAssetId);
        if (summary.Name != null) {
            getShippingEstimates(summary);
            getShippingActuals(summary);
            customerAssetStartDate = summary.Customer_Asset__r.Term_Start_Date__c;
        }

        estErr = false;
        actErr = false;
    }*/

    /* ARMAN: public void getShippingEstimateSummary(Id caId) {
        System.debug('CustomerAssetShippingController.getShippingEstimateSummary');
        try {
            summary = [
                    select Id, Name, Estimated_Shipping_Quantity__c, Actual_Shipped_Quantity__c, Customer_Asset__c
                            , Customer_Asset__r.Term_Start_Date__c, Customer_Asset__r.Term_End_Date__c, Customer_Asset__r.Quantity__c
                    from Customer_Asset_Shipping_Summary__c
                    where Customer_Asset__c = :passedCustAssetId
            ];
        } catch (QueryException qe) {
            summary = new Customer_Asset_Shipping_Summary__c();
        }
    }*/

    /* ARMAN: public void getShippingEstimates(Customer_Asset_Shipping_Summary__c summary) {
        System.debug('CustomerAssetShippingController.getShippingEstimates');
        try {
            shippingEstimateList = [
                    select Id, Name, Estimated_Shipping_Date__c, Estimated_Shipping_Quantity__c
                            , Shipping_Notes__c, Customer_Asset_Shipping_Summary__r.Id, Customer_Asset_Shipping_Summary__r.Name
                            , Customer_Asset_Shipping_Summary__r.Customer_Asset__r.Term_Start_Date__c
                    from Customer_Asset_Shipping_Estimate__c
                    where Customer_Asset_Shipping_Summary__c = :summary.Id
                    order by Estimated_Shipping_Date__c
            ];
        } catch (QueryException qe) {
        }
    }*/

    /* ARMAN: public void getShippingActuals(Customer_Asset_Shipping_Summary__c summary) {
        System.debug('CustomerAssetShippingController.getShippingActuals');
        try {
            shippingActualList = [
                    select Id, Name, Actual_Shipped_Date__c, Actual_Shipped_Quantity__c
                            , Shipping_Notes__c, Customer_Asset_Shipping_Summary__r.Id, Customer_Asset_Shipping_Summary__r.Name
                            , Customer_Asset_Shipping_Summary__r.Customer_Asset__r.Term_Start_Date__c
                    from Customer_Asset_Shipping_Actual__c
                    where Customer_Asset_Shipping_Summary__c = :summary.Id
                    order by Actual_Shipped_Date__c
            ];
        } catch (QueryException qe) {
        }
    }*/

    /* ARMAN: public void estimateDataChanged() {
        System.debug('CustomerAssetShippingController.estimateDataChanged');
        estimatesChanged = 'true';
    }*/

    /* ARMAN: public void actualDataChanged() {
        System.debug('CustomerAssetShippingController.actualDataChanged');
        actualsChanged = 'true';
    }*/

    /* ARMAN: public PageReference closePage() {
        System.debug('CustomerAssetShippingController.closePage');
        if (estimatesChanged == 'true') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You have unsaved estimates, please save changes before closing page.'));
            estErr = true;
            return null;
        }else if (actualsChanged == 'true') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You have unsaved actuals, please save changes before closing page.'));
            actErr = true;
            return null;
        }else{
            // ARMAN: RevenueForecastHandler.calculateCustomerAssetFinancials(passedCustAssetId);
        }

        PageReference pR;
        if (passedCustAssetId == null) {
            pR = new PageReference('/apex/CustomerAssetShippingMaintenance');
        }
        else {
            pR = new PageReference('/' + passedCustAssetId);
        }
        pR.setRedirect(true);
        return pR;
    }*/

    /* ARMAN: public void cancelChanges() {
        estimatesChanged = 'false';
        actualsChanged = 'false';
        // ARMAN: setupBasics();
    }*/

    /* ARMAN: public PageReference saveShippingSummary() {
        System.debug('CustomerAssetShippingController.saveShippingSummary');
        Customer_Asset_Shipping_Summary__c summary = new Customer_Asset_Shipping_Summary__c();
        try {
            summary.Customer_Asset__c = passedCustAssetId;
            insert summary;
        } catch (exception e) {
            System.debug('*********** ' + e.getMessage());
        }
        if (passedCustAssetId != null) {
            PageReference pR = new PageReference('/apex/CustomerAssetShippingMaintenance');
            pR.getParameters().put('custAssetId', passedCustAssetId);
            pR.getParameters().put('estChg', estimatesChanged);
            pR.getParameters().put('actChg', actualsChanged);
            pR.setRedirect(true);
            return pR;
        } else {
            return null;
        }
    }*/

    /* ARMAN: public void addRow() {
        System.debug('CustomerAssetShippingController.addRow');
        // ARMAN: shippingEstimateList.add(new Customer_Asset_Shipping_Estimate__c());
    }*/

    /* ARMAN: public void addActRow() {
        System.debug('CustomerAssetShippingController.addActRow');
        // ARMAN: shippingActualList.add(new Customer_Asset_Shipping_Actual__c());
    }*/

    /* ARMAN: public void deleteShippingEstimate() {
        System.debug('CustomerAssetShippingController.deleteShippingEstimate');
        Integer rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        try {
            Customer_Asset_Shipping_Estimate__c shippingEstimate = shippingEstimateList.remove(rowIndex);
            delete shippingEstimate;
        } catch (Exception ex) {

        }

//        if (passedCustAssetId != null) {
//            PageReference pR = new PageReference('/apex/CustomerAssetShippingMaintenance');
//            pR.getParameters().put('custAssetId', passedCustAssetId);
//            pR.getParameters().put('estChg', estimatesChanged);
//            pR.getParameters().put('actChg', actualsChanged);
//            pR.getParameters().put('closePage', 'false');
//            pR.setRedirect(true);
//            return pR;
//        } else {
//            return null;
//        }
    }*/

    /* ARMAN: public void deleteShippingActual() {
        System.debug('CustomerAssetShippingController.deleteShippingActual');
        Integer actRowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('actRowIndex'));
        try {
            Customer_Asset_Shipping_Actual__c shippingActual = shippingActualList.remove(actRowIndex);
            delete shippingActual;
        } catch (Exception ex) {

        }

//        if (passedCustAssetId != null) {
//            PageReference pR = new PageReference('/apex/CustomerAssetShippingMaintenance');
//            pR.getParameters().put('custAssetId', passedCustAssetId);
//            pR.getParameters().put('estChg', estimatesChanged);
//            pR.getParameters().put('actChg', actualsChanged);
//            pR.getParameters().put('closePage', 'false');
//            pR.setRedirect(true);
//            return pR;
//        } else {
//            return null;
//        }
    }*/

    /* ARMAN: public void saveShippingEstimates() {
        System.debug('CustomerAssetShippingController.saveShippingEstimates');
        estimatesChanged = 'false';
        List<Customer_Asset_Shipping_Estimate__c> insertList = new List<Customer_Asset_Shipping_Estimate__c>();
        List<Customer_Asset_Shipping_Estimate__c> updateList = new List<Customer_Asset_Shipping_Estimate__c>();
        List<Customer_Asset_Shipping_Estimate__c> deleteList = new List<Customer_Asset_Shipping_Estimate__c>();
        Map<Date, Integer> dateMap = new Map<Date, Integer>();
        Map<Integer, Customer_Asset_Shipping_Estimate__c> estimateMap = new Map<Integer, Customer_Asset_Shipping_Estimate__c>();
        for (Integer i = 0; i < shippingEstimateList.size(); i++) {
            if (shippingEstimateList[i].Estimated_Shipping_Date__c != null) {
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
                estErr = true;
//                return null;
            } else if (shippingEstimateList[i].Id == null && shippingEstimateList[i].Estimated_Shipping_Date__c < customerAssetStartDate) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Estimate Date must be the same or after the start date of the customer asset in Estimate Number: ' + (i + 1)));
                estErr = true;
//                return null;
            } else if (shippingEstimateList[i].Estimated_Shipping_Date__c != null && shippingEstimateList[i].Estimated_Shipping_Quantity__c == null || shippingEstimateList[i].Estimated_Shipping_Quantity__c < 1) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Quatity is required in Estimate Number: ' + (i + 1)));
                estErr = true;
//                return null;
            } else {
                System.debug('datemap key found: ' + shippingEstimateList[i].Estimated_Shipping_Date__c);
                if (i == dateMap.get(shippingEstimateList[i].Estimated_Shipping_Date__c)) {
                    if (!estimateMap.containsKey(i)) {
                        estimateMap.put(i, shippingEstimateList[i]);
                    }
                } else {
                    Customer_Asset_Shipping_Estimate__c parentEstimate = new Customer_Asset_Shipping_Estimate__c();
                    parentEstimate = estimateMap.get(dateMap.get(shippingEstimateList[i].Estimated_Shipping_Date__c));
                    parentEstimate.Estimated_Shipping_Quantity__c = parentEstimate.Estimated_Shipping_Quantity__c + shippingEstimateList[i].Estimated_Shipping_Quantity__c;
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
        for (Customer_Asset_Shipping_Estimate__c estimate : estimateMap.values()) {
            if (estimate.Id == null) {
                estimate.Customer_Asset_Shipping_Summary__c = summary.Id;
                insertList.add(estimate);
            } else {
                updateList.add(estimate);
            }
        }
        for (Customer_Asset_Shipping_Estimate__c se : deleteEstimateList) {
            if (se.Id != null) {
                deleteList.add(se);
            }
        }
        try {
            if (insertList.size() > 0) {
                insert insertList;
            }
            if (updateList.size() > 0) {
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
        }

        System.debug('est chg: ' + estimatesChanged);
//        if (passedCustAssetId != null) {
//            PageReference pR = new PageReference('/apex/CustomerAssetShippingMaintenance');
//            pR.getParameters().put('custAssetId', passedCustAssetId);
//            pR.getParameters().put('estChg', estimatesChanged);
//            pR.getParameters().put('actChg', actualsChanged);
//            pR.setRedirect(true);
//            return pR;
//        } else {
//            return null;
//        }
    }*/

    /* ARMAN: public void saveShippingActuals() {
        System.debug('CustomerAssetShippingController.saveShippingActuals');
        actualsChanged = 'false';
        List<Customer_Asset_Shipping_Actual__c> insertList = new List<Customer_Asset_Shipping_Actual__c>();
        List<Customer_Asset_Shipping_Actual__c> updateList = new List<Customer_Asset_Shipping_Actual__c>();
        List<Customer_Asset_Shipping_Actual__c> deleteList = new List<Customer_Asset_Shipping_Actual__c>();
        Map<Date, Integer> dateMap = new Map<Date, Integer>();
        Map<Integer, Customer_Asset_Shipping_Actual__c> actualMap = new Map<Integer, Customer_Asset_Shipping_Actual__c>();
        for (Integer i = 0; i < shippingActualList.size(); i++) {
            if (shippingActualList[i].Actual_Shipped_Date__c != null) {
                if (!dateMap.containsKey(shippingActualList[i].Actual_Shipped_Date__c)) {
                    dateMap.put(shippingActualList[i].Actual_Shipped_Date__c, i);
                    System.debug('datemap record: ' + shippingActualList[i].Actual_Shipped_Date__c + ' -- ' + i);
                }
            }
        }
        System.debug('finalDatemap ' + dateMap);
        System.debug('shippingActualList size: ' + shippingActualList.size());
        Integer listSize = shippingActualList.size();
        for (Integer i = 0; i < listSize; i++) {
            System.debug('list record: ' + shippingActualList[i].Actual_Shipped_Date__c + ' -- ' + i);
            if (shippingActualList[i].Actual_Shipped_Date__c == null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Actual Date is required in Row Number: ' + (i + 1)));
                actErr = true;
//                return null;
            } else if (shippingActualList[i].Id == null && shippingActualList[i].Actual_Shipped_Date__c < customerAssetStartDate) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Shipped Date must be the same or after the start date of the customer asset in Row Number: ' + (i + 1)));
                actErr = true;
//                return null;
            } else if (shippingActualList[i].Actual_Shipped_Date__c != null && shippingActualList[i].Actual_Shipped_Quantity__c == null || shippingActualList[i].Actual_Shipped_Quantity__c < 1) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Quatity is required in Actual Row Number: ' + (i + 1)));
                actErr = true;
//                return null;
            } else {
                System.debug('datemap key found: ' + shippingActualList[i].Actual_Shipped_Date__c);
                if (i == dateMap.get(shippingActualList[i].Actual_Shipped_Date__c)) {
                    if (!actualMap.containsKey(i)) {
                        actualMap.put(i, shippingActualList[i]);
                    }
                } else {
                    Customer_Asset_Shipping_Actual__c parentEstimate = new Customer_Asset_Shipping_Actual__c();
                    parentEstimate = actualMap.get(dateMap.get(shippingActualList[i].Actual_Shipped_Date__c));
                    parentEstimate.Actual_Shipped_Quantity__c = parentEstimate.Actual_Shipped_Quantity__c + shippingActualList[i].Actual_Shipped_Quantity__c;
                    if (parentEstimate.Shipping_Notes__c != null) {
                        if (shippingActualList[i].Shipping_Notes__c != null) {
                            parentEstimate.Shipping_Notes__c = parentEstimate.Shipping_Notes__c + '\n' + shippingActualList[i].Shipping_Notes__c;
                        }
                    } else {
                        if (shippingActualList[i].Shipping_Notes__c != null) {
                            parentEstimate.Shipping_Notes__c = shippingActualList[i].Shipping_Notes__c;
                        }
                    }
                    actualMap.put(dateMap.get(shippingActualList[i].Actual_Shipped_Date__c), parentEstimate);
                    deleteActualList.add(shippingActualList[i]);
                }
            }
        }
        for (Customer_Asset_Shipping_Actual__c actual : actualMap.values()) {
            if (actual.Id == null) {
                actual.Customer_Asset_Shipping_Summary__c = summary.Id;
                insertList.add(actual);
            } else {
                updateList.add(actual);
            }
        }
        for (Customer_Asset_Shipping_Actual__c sa : deleteActualList) {
            if (sa.Id != null) {
                deleteList.add(sa);
            }
        }
        try {
            if (insertList.size() > 0) {
                insert insertList;
            }
            if (updateList.size() > 0) {
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
        }

//        if (passedCustAssetId != null) {
//            PageReference pR = new PageReference('/apex/CustomerAssetShippingMaintenance');
//            pR.getParameters().put('custAssetId', passedCustAssetId);
//            pR.getParameters().put('estChg', estimatesChanged);
//            pR.getParameters().put('actChg', actualsChanged);
//            pR.setRedirect(true);
//            return pR;
//        } else {
//            return null;
//        }
    }*/


}