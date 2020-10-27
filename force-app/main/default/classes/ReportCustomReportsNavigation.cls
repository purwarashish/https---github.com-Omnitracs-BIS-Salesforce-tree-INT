public class ReportCustomReportsNavigation {
    
    public ReportCustomReportsNavigation()
    {
    }

    public PageReference gotoOptyReport()
    {
        return new PageReference('/apex/ReportOpty3rdPartyProject');
    }
   
}