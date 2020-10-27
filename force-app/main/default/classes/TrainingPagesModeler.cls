/**
 *@description A modeler class for MoreTrainingPages
 *@author Amrita Ganguly
 */
public class TrainingPagesModeler{   
     
    public String returnURL {get; set;}
    public Integer intProductRows {get; set;}
    public Integer intInternalRows {get; set;}{intInternalRows = 25;}
    public Integer intFirst {get; set;}{intFirst = 0;}
    public Boolean blnMoreTraining {get;set;}
    public Boolean blnPrevious{get;set;}
    public Integer trainingListSize{get;set;}{trainingListSize=0;}
    public QESUnityWebServicesClientManager wscm {get; set;}
    public TrainingPagesModeler(){
        refreshInitializationData();
    }
    
    public void refreshInitializationData() {
        if(null == ApexPages.currentPage().getParameters().get('ret')) {
            returnURL = '#';
        }
        else {
            returnURL = ApexPages.currentPage().getParameters().get('ret') ;
            if(ApexPages.currentPage().getParameters().containskey('name'))
            {
                if(!returnURL.contains('?'))
                    returnURL = returnURL +'?';
                returnURL = returnURL + 'name='+ ApexPages.currentPage().getParameters().get('name')+'&';
            }
            if(ApexPages.currentPage().getParameters().containskey('docType'))
            {
                if(!returnURL.contains('?'))
                        returnURL = returnURL +'?';
                returnURL = returnURL + 'docType=' +ApexPages.currentPage().getParameters().get('docType')+'&';
            }
            
            if(ApexPages.currentPage().getParameters().containskey('prodType'))
            {
                if(!returnURL.contains('?'))
                        returnURL = returnURL +'?';
                returnURL = returnURL + 'prodType='+ApexPages.currentPage().getParameters().get('prodType')+'&';
            }
        }
        
        wscm = new QESUnityWebServicesClientManager(-1);
        wscm.refreshTrainingData(ApexPages.currentPage().getParameters().get('id'));
    }
    
    public Pagereference next()
    {
        count++;
        intFirst+=intInternalRows ;
        if(trainingListSize>0)
        {    
            if((trainingListSize - (count * intInternalRows ) > 0))
            
                blnMoreTraining = true;
            else
                blnMoreTraining = false;
            blnPrevious = true;
            system.debug(blnMoreTraining );
        }
        return null;
    }
    
    public Pagereference previous()
    {
        count--;
        intFirst-=intInternalRows ;
        if(intFirst == 0)
            blnPrevious = false;
        blnMoreTraining = true;
        return null;
    } 
    /*-------------Private Members------------------------*/
    
    private Integer count=0;
}