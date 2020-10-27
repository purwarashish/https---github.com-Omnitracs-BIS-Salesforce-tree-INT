public class accountNameChangeExt {
    public ApexPages.StandardController stdCntrlr {get; set;}
    public accountNameChangeExt(ApexPages.StandardController controller) {
        stdCntrlr = controller;
    }
    
    public Flow.Interview.Account_Name_Change myFlow { get; set; }

    public String getmyID() {
        if (myFlow==null) return '';
        else return myFlow.varID;
        // system.debug('***VARID'+myFlow.varID);
    }
    
    public PageReference getOID(){
        PageReference p = new PageReference('/apex/uploadAccountContent?id=' + getmyID());
        // + '&addTo=' + getmyID() + '&retURL=%2F006%2Fe&sfdc.override=1'
        p.setRedirect(true);
        return p;
    }
}