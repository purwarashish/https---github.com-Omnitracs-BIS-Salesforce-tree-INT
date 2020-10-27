global class ssoLoginController {

    public String startUrl {get; set;}
    public String viewState {get;set;}

    public String QESLoginURL {
       get {
           return Global_Variable__c.getValues('LoginURL').value__c;
       } set; }

    public ssoLoginController() {
        Map<String, String> urlParam = Apexpages.currentPage().getParameters();
        string params = '';
        for(String target : urlParam.keySet()){
            if(!target.equalsIgnoreCase('startUrl')
            && !target.equalsIgnoreCase('refURL')
            && urlParam.get(target) != '' && urlParam.get(target) != null){
                if(params != '?'){
                    params += '&';
                }

                params += target+'='+urlParam.get(target);
            }
        }
        
        viewState=Apexpages.currentPage().getParameters().get('viewState');
        String sstartUrl = Apexpages.currentPage().getParameters().get('starturl');
        String concatStartUrl = sstartUrl+params;

        startUrl=EncodingUtil.urlEncode(concatStartUrl, 'UTF-8');

    }

    public void runTest() {}

}