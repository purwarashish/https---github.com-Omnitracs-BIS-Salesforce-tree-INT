/*
*    Author:          Joseph Barrameda (Cloud Sherpas)
*    Date Created:    4-NOV-2014
*    Description:     Redirects the page to ClickTools form
*/


public without sharing class ClickToolsRedirectController{

    private String toURL =''; 
        
    public ClickToolsRedirectController(){
        
        String q1_value = Apexpages.currentPage().getParameters().get('CField4'); 
        String q3_value = Apexpages.currentPage().getParameters().get('CField5'); 
        String q4_value = Apexpages.currentPage().getParameters().get('CField3'); 
        String iv_value =''; 
        
        System.debug('MM: ' + Apexpages.currentPage().getParameters().get('CField4'));
        
        Case caseRec = [SELECT Id, AccountId, Business_Unit__c FROM Case WHERE Id =: Apexpages.currentPage().getParameters().get('CField4') LIMIT 1];
        System.debug('**** Case Record:' + caseRec.Business_Unit__c );
        
        if (caseRec.Id <> null){            
            
            if (caseRec.Business_Unit__c == 'Roadnet')
                iv_value = 'z3wrca4a7qnv'; 
            else if (caseRec.Business_Unit__c == 'Sylectus')
                iv_value = '1mndllxnnyx59';
            else if (caseRec.Business_Unit__c == 'Omnitracs MX') 
                iv_value = '3byqhk5g3g0sx';
            else
                iv_value = '1dcbyrcmeqlfm';            
        
            //Construct URL
            toURL = 'http://survey.clicktools.com/go?iv=' + iv_value + '&q1=' + q1_value + '&q2=' + caseRec.AccountId + '&q3=' + q3_value + '&q4=' + q4_value;
            
            System.debug('**** URL:' + toURL);
        }       
        
    }
    
    public Pagereference redirect(){
        
        PageReference redirectTo = new PageReference(toURL);
        redirectTo.setRedirect(true);
        return redirectTo;
    } 

}