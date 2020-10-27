public with sharing class UnityDirectSalesRetryController{
	
	public Service_Logs__c serviceLog {get; set;}
	
	public UnityDirectSalesRetryController(ApexPages.StandardController ctrl){
		this.serviceLog = (Service_Logs__c)ctrl.getRecord();
	}
	
	public PageReference callUnityService(){
		
		
		if(this.serviceLog == null){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Retry the action, invalid Service Log id'));
			return null;
		}
		
		this.serviceLog = [select Id, Related_Quote__c, Request_Payload__c, Result__c, Service_Name__c from Service_Logs__c where Id = :this.serviceLog.Id];
		
		if(this.serviceLog == null){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Retry the action, invalid Service Log'));
			return null;
		}
		
		if(String.isNotBlank(serviceLog.Result__c) && serviceLog.Result__c != 'Error'){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Retrying the service call is only for \'Error\' logs.'));
			return null;
		}
		else{
			onboardingUnityDirectSales();
		}
		
		PageReference pg = new PageReference('/'+ serviceLog.id); 
		pg.setRedirect(true);
		return pg;
		
	}
	
	private void onboardingUnityDirectSales() { 
    	
    	List<UnityDirectSalesAPI__mdt> udsList = [SELECT Endpoint__c, Value__c FROM UnityDirectSalesAPI__mdt WHERE DeveloperName = 'DirectSales'];
    	if(udsList.size() > 0){
    		UnityDirectSalesAPI__mdt uds = udsList.get(0);
    		
    		try{
			    HttpRequest req = new HttpRequest();   
			    system.debug ( '**********Direct Sales Service Endpoint -- ' +uds.Endpoint__c );
			    req.setEndpoint(uds.Endpoint__c);
			    req.setMethod('POST');
			    req.setHeader('Authorization', uds.Value__c);
			    req.setHeader('Accept', 'application/vnd.onboardingService-v1+json');
			    req.setHeader('Content-Type', 'application/vnd.onboardingService-v1+json');
			    req.setBody(this.serviceLog.Request_Payload__c);
			    system.debug ( '**********Direct Sales Service Request -- ' +req.getBody());
			    
			    Http http = new Http();
			    HttpResponse response = http.send(req);  
			    system.debug ( '**********Direct Sales Service Response -- ' +response.getBody());
			   
		    } catch(Exception e) {
		    	system.debug ( '**********Direct Sales Service Exception*************' +e.getMessage());
		    }  
		    
		}
	}
	
	public PageReference cancel(){
		PageReference pg = new PageReference('/'+ this.serviceLog.id); 
		return pg;
	}
	
	

}