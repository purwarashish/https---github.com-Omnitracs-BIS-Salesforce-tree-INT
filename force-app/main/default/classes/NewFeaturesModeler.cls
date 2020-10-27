/**
 *@description A modeler class for Support - New Features
 *@author Pratyush Kumar
 */
public class NewFeaturesModeler {   
     
    public String returnURL {get; set;}
    public QESUnityWebServicesClientManager wscm {get; set;}    
        
    public NewFeaturesModeler() {
        refreshInitializationData();
    }
    
    public void refreshInitializationData() {
        if(null == ApexPages.currentPage().getParameters().get('retURL')) {
            returnURL = '#';
        }
        else {
            returnURL = ApexPages.currentPage().getParameters().get('retURL');
        }
        
        try{
        wscm = new QESUnityWebServicesClientManager(-1);
        wscm.refreshNewFeaturesData();
        }
        catch(exception e)
        {
            
        }
    }
}