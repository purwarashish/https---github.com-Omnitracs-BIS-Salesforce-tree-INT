@isTest(SeeAllData=true)
private class TestReportOpty3rdPartyProject{
    public static testmethod void Testmethod1(){
        ReportOpty3rdPartyProjectController newObj = new ReportOpty3rdPartyProjectController();
        String[] demandValues = new String[]{'Pipeline - 30% to 50%','Best Case - 70%'};
        newObj.NewOpportunity = new Opportunity();
        DateTime dt = System.now();
        Date currentDate = date.newinstance(dt.year(), dt.month(), dt.day());
        Integer int1 = newObj.getStart_Index();
        int1 = newObj.getLast_Index();
        List<SelectOption> testList = new List<SelectOption> ();
        testList.add(new SelectOption('Test1','Test1'));
        testList.add(new SelectOption('Test2','Test2'));
        newObj.setProduct(testList);
        testList = newObj.getProduct();
        newObj.alphabet = 'All';
        newObj.search_value = ''; 
        newObj.demand = demandValues;
        newObj.selStage = 'Open';
        newObj.selProduct = 'All';
        newObj.NewOpportunity.start_date__c = null;
        newObj.NewOpportunity.closeDate = currentDate;
        test.startTest();
        newObj.Runreport();
        newObj.sel_No_of_Records = '10';
        newObj.ChangePagination();
        newObj.ExporttoExcel();
        test.stopTest();
        newObj.next();
        newObj.previous();
        list<ReportOpty3rdPartyProjectController.Opportunity3RDPartyProdUtil> newObj1 = new list<ReportOpty3rdPartyProjectController.Opportunity3RDPartyProdUtil>();
        newObj.setExcelList(newObj1);
        newObj1 = newObj.getExcelList();
        list<list<ReportOpty3rdPartyProjectController.Opportunity3RDPartyProdUtil>> newObj2 = new list<list<ReportOpty3rdPartyProjectController.Opportunity3RDPartyProdUtil>>();
        
        newObj.setExcelList1(newObj2);
        newObj2 = newObj.getExcelList1();

    }
}