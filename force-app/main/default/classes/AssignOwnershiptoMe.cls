global class AssignOwnershiptoMe {
/****************************************************************************
Date: 5/1/2008
Author: Anand Singh, Salesforce.com Consultant
        Tata Consultancy Services Limited

Problem: Due to sharing rules, the case ownership cannot be assigned to a user with roles associated in sharing rules.
         When a user clicks on button "Assign to me" , the Case ownership need to be assigned to that user.

Solution: The OnClick Javascript behind the button "Assign to me" invokes the assignment method "AssignCaseOwnertoCurrentUser" from this class.



*******************************************************************************/
WebService static String AssignCaseOwnertoCurrentUser(String CaseId,String CurrentUserId,String CurrentUserQId)
{
     
     String Output='';
       Try {
        
           Case VarCase = [Select Id, OwnerId, Queue__c from Case  where Id= :CaseId ];
            
            if (VarCase != null)
                {
                 VarCase.OwnerId = CurrentUserId;
                 VarCase.Queue__c = CurrentUserQId; 
                 update VarCase;
                 Output = 'True';
                }
           }catch (exception e)
          {
            system.debug('@@Error@@ ' + e.getMessage()); 
            Output =  e.getMessage(); 
            return Output;
          }
       System.debug('The Ownership of Case with CaseId: '+ CaseId +' is assigned to Current User with SID: '+ CurrentUserId +' and Queue Id: '+ CurrentUserQId);
       return Output;
}
    

    
    
}