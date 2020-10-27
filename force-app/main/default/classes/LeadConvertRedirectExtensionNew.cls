public with sharing class LeadConvertRedirectExtensionNew {

    public Id newId = null;
    public id AccId = null;
    public LeadConvertRedirectExtensionNew(){
        newId = ApexPages.CurrentPage().getParameters().get('newid');
        AccId = ApexPages.CurrentPage().getParameters().get('accid');
        
    } 
 
    public PageReference redirect(){
        
        Lead convertedLead = [select ConvertedContactId,ConvertedAccountId from Lead where id=:newId];
        string ContactId = string.valueOf(Lead.ConvertedContactId);
        list<Contact> convertedC = new list<Contact>([Select AccountID, id from contact where id =:ContactId limit 1]);
         system.debug('********************************************** AccId  '+AccId +'*********** Value  '+ApexPages.CurrentPage().getParameters().get('value'));
         system.debug('********************************************** onvertedC  '+convertedC);
        
        PageReference pRef;
        if(convertedLead.ConvertedAccountId != Null){
            pRef = new PageReference('/' + convertedLead.ConvertedAccountId +'/e?retURL=%2F'+convertedLead.ConvertedAccountId); //  
        //else
        //    pRef = new PageReference('/' + convertedC[0].AccountId +'/e?retURL=%2F'+convertedC[0].AccountId);         
        system.debug('********************************************** pRef '+pRef);
        pRef.setRedirect(true);
        return pRef;
        }
        return null;
    }
    
}