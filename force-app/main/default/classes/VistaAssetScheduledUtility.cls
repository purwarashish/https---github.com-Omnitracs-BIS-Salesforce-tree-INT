global class VistaAssetScheduledUtility implements Schedulable {

    global void execute(SchedulableContext sc){
        System.debug('VistaAssetScheduledUtility.execute');
        try{
            decommissionAssets();
        }catch (Exception ex){
            System.debug(LoggingLevel.ERROR, 'Error running decommission assets scheduled method' + ex.getMessage());
        }
    }
    
    public static void decommissionAssets(){
        System.debug('VistaAssetScheduledUtility.decommissionAssets');
        List<Customer_Asset__c> assetList = new List<Customer_Asset__c>();
        List<Customer_Asset__c> updateList = new List<Customer_Asset__c>();

        assetList = [Select Id, Name, Asset_Status__c, Decommission_Effective_Date__c
                   From Customer_Asset__c Where Decommission_Effective_Date__c = YESTERDAY and Asset_Status__c = 'Active'];
        System.debug('Current asset list: ' + assetList);
        
        for(Customer_Asset__c a : assetList){
            System.debug('Current asset: ' + a);
            a.Asset_Status__c = 'Decommissioned';
            updateList.add(a);
        }
        System.debug('Asset List to update: ' + updateList);
        Update updateList;
    }
}