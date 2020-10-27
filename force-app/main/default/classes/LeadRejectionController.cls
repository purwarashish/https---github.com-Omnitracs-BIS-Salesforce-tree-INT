public class LeadRejectionController {
        /*@Description : varible to store the rejection note for lead 
        */
      public String description {get; set;}
       /*@Description : List to store the queried result 
        */
      List<Lead> lstLead = new List<Lead>(); 
       /*@Description : variable to get the lead Id from URL
        */
      public Id leadId;
       /*@Description : Getter and setter for current invoked lead
        */
      public Lead currentLead {get; set;}
      
      public Boolean isFormIncomplete {get; set;}
      
      public Boolean isPortalUser{get;set;}
      
      
      public LeadRejectionController(){
      
      leadId= Apexpages.currentPage().getParameters().get('Id');
      lstLead = [Select 
                      IF_Rejection_Reason__c, 
                      Body_from_Notes__c , Lifecycle_Status__c
                 from 
                     Lead 
                 where 
                     Id =:leadId 
                 limit 1 ];
      currentLead = lstLead[0];
      
      isPortalUser = [select id, isPortalEnabled from User where id = : UserInfo.getUserId() limit 1].isPortalEnabled;
      
      
      }
    
      public PageReference rejectLead()
      {
        
        if(currentLead != null )
        { 
          if( description!= null && description!= '')   
          {
            Note note = new Note(title = 'Lead Reassignment/Rejection',Body=description ,parentId=currentLead.id );
            insert note;
          }
         /*  @Description :rejection note get copied to Note:Lead Reassignment custom field  */
                  
          currentLead.Body_from_Notes__c = description;   
        }
      
     
      
         try
            {
                if(currentLead != null)
                {
                      update currentLead;                               
                }
            }
            catch(Exception e) 
            {    
                system.debug('update failed');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Exception has occured.The record has not been updated.');
                ApexPages.addMessage(myMsg);
                isFormIncomplete = true;
                
            }
            return null;
            
      }
            
}