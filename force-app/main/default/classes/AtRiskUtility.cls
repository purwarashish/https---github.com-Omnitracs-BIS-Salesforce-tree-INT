public without sharing class AtRiskUtility {

    // when an At Risk record is made Primary, need to uncheck the Primary box on all other At Risk records on the Account
    public static void makePrimary(List<At_Risk__c> newAlerts) {
        List<Id> accIdsToClear = new List<Id>();
        List<Id> newAlertIds = new List<Id>();
        for (At_Risk__c a : newAlerts) {
            if (a.Primary__c) {
                accIdsToClear.add(a.Account__c);
                newAlertIds.add(a.Id);
            }
        }
        
        List<At_Risk__c> alertsToClear = [SELECT Id FROM At_Risk__c WHERE Account__c IN :accIdsToClear AND Primary__c = TRUE AND Id NOT IN :newAlertIds];
        for (At_Risk__c a : alertsToClear) {
            a.Primary__c = false;
        }
        update alertsToClear;
    }
    
    // copies Primary alerts to Account level alert text
    public static void copyAlertToAccount(List<At_Risk__c> newAlerts) {
        Map<Id, String> mapAccountToAlertText = new Map<Id, String>();                
        for (At_Risk__c a : newAlerts) {            
            if (a.Primary__c && a.Account__c != null) {
                if (a.Status__c == 'Open') {
                    mapAccountToAlertText.put(a.Account__c, 'At Risk Alert: ' + a.Problem_Statement__c);
                }
                else {
                    mapAccountToAlertText.put(a.Account__c, '');
                }
            }
        }
        
        List<Account> accsToUpdate = new List<Account>();
        for (Id accId : mapAccountToAlertText.keySet()) {
            accsToUpdate.add(new Account(Id = accId, Alert_Text__c = mapAccountToAlertText.get(accId)));
        }
        update accsToUpdate;
    }
    
    // copies Primary alerts to Account level alert text
    public static void updateCopyAlertToAccount(List<At_Risk__c> newAlerts, Map<Id, At_Risk__c> oldMapAlerts) {
        Map<Id, String> mapAccountToAlertText = new Map<Id, String>();                
        for (At_Risk__c a : newAlerts) {            
            if (a.Primary__c && a.Account__c != null) {
                if (a.Status__c == 'Open') {
                    mapAccountToAlertText.put(a.Account__c, 'At Risk Alert: ' + a.Problem_Statement__c);
                }
                else {
                    mapAccountToAlertText.put(a.Account__c, '');
                }
            }
            if (oldMapAlerts.containsKey(a.Id)){
                if(oldMapAlerts.get(a.Id).Primary__c != a.Primary__c && a.Primary__c == false && a.Account__c != null){
                    mapAccountToAlertText.put(a.Account__c, '');
                }
            }
        }
        
        List<Account> accsToUpdate = new List<Account>();
        for (Id accId : mapAccountToAlertText.keySet()) {
            accsToUpdate.add(new Account(Id = accId, Alert_Text__c = mapAccountToAlertText.get(accId)));
        }
        update accsToUpdate;
    }

}