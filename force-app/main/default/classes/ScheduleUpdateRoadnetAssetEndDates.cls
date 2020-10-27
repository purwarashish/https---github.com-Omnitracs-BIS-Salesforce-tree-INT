/**
	* ScheduleUpdateRoadNetEndDates - This will take the assets, take only SKUs specified by Laura Hughes, and update their end dates if they
	* are expiring soon, by adding a year onto the end date. This is scheduled to run on the last day of the month, at 10:30 PM.
	* Created by BrainEngine Cloud Studio
	* @author: Cody Worth
	* @version: 1.0\
	*
	*
	*
*/

global class ScheduleUpdateRoadnetAssetEndDates implements Schedulable{
	
	public static string SECONDS = '0';
    public static string MINUTES = '30';
    public static string HOURS = '22';
    public static string DAY_OF_MONTH = 'L';
    public static string MONTH = '*';
    public static string DAY_OF_WEEK= '?';
    
    public static string TIME_TO_RUN = SECONDS + ', ' + MINUTES + ', ' + HOURS + ', ' + DAY_OF_MONTH + ', ' + MONTH + ', ' + DAY_OF_WEEK;
    public static string NAME_OF_JOB = 'Update Roadnet Asset End Dates';
	
	
    global void execute(SchedulableContext SC)
    {
        doAssetUpdates();
        
	}
	
	global void doAssetUpdates(){
		List<Asset__c> assetsToUpdate = new List<Asset__c>();
	
		for(Asset__c asset : [Select Id, Asset_Term_End_Date__c FROM ASSET__C WHERE Asset_Term_End_Date__c != null AND Business_Unit__c = 'RoadNet' And (SKU__c = '10029-XX-SR-I-ND'
 			OR SKU__c = '10030-XX-SR-R-ND' OR SKU__c = '34100-XX-LS-I-ET' OR SKU__c = '34100-XX-LS-R-ET' OR SKU__c = '38000-XX-LS-I-ET' OR SKU__c = '38000-XX-LS-R-ET' 
 			OR SKU__c ='51000-VE-LS-I-ET' OR SKU__c = '51000-VE-LS-R-ET' OR SKU__c = '62000-VE-LS-R-ET' OR SKU__c = '70000-VE-LS-I-ET'
 			OR SKU__c = '70000-VE-LS-R-ET' OR SKU__c = '71000-VE-LS-I-ET' OR SKU__c = '71000-VE-LS-R-ET' OR SKU__c = '73015-XX-LS-I-ET' 
 			OR SKU__c = '95000-XX-LS-O-ET')]){
			
			Date dateToCheck = dateChange(asset.Asset_Term_End_Date__c);
	
			if(Date.today() >= dateToCheck){
				asset.Asset_Term_End_Date__c = asset.Asset_Term_End_Date__c.addYears(1);
				assetsToUpdate.add(asset);
			}
		}
		
		update assetsToUpdate;
		
	}
	
	global Date dateChange(Date d){
		date comparisonDate = d.addDays(-45);
		return comparisonDate;
		
	}
        
    

}