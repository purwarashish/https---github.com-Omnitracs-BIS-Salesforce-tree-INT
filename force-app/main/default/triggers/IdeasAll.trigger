/*********************************************************************
Name : IdeasAll
Author : David Ragsdale
Date : 2 February 2011

Usage : This trigger is used for the Ideas Object.
 - before Delete - Gathers the Customer Ideas (customer_ideas__c) records and deletes them
    based upon the idea being deleted
 - before Update - update fields on the Idea when a NEW idea Comment is posted
    
Dependencies : none.

*********************************************************************/
trigger IdeasAll on Idea (before update, before delete) {

    Idea oldIdea;
    List<Idea> lstIdeaUpdate = new List<Idea>(); 
    List<IdeaComment> lstCommentData = new List<IdeaComment>(); 

    if (trigger.isdelete)
    {        
        /*************************************************************
        * DELETE ASSOCIATED Customer Ideas
        *    Gather all the Customer Ideas and see if any are linked to the Idea being deleted */
        
        Customer_Idea__c[] CustomerIdeas = [SELECT Name, Idea__c, Account__c 
            FROM Customer_Idea__c
            WHERE Idea__c in :trigger.old];
        
        delete CustomerIdeas;
        /**************************************************************/
    }

//DAR - Added 4 March 2011
    if (Trigger.isUpdate)
    {
        for (Idea newIdea : Trigger.new)
        {
            oldIdea = System.Trigger.oldMap.get(newIdea.Id); 
            
            if(newIdea.LastCommentId != null)
            { 

                if(oldIdea.LastCommentId != newIdea.LastCommentId)
                {
                    lstCommentData = [SELECT Id, CommentBody, CreatedById
                        FROM IdeaComment 
                        WHERE Id = :newIdea.LastCommentId LIMIT 1];
                        
                    if (lstCommentData.size() > 0)
                    {
                        newIdea.Last_Comment__c = lstCommentData[0].CommentBody;
                        newIdea.Last_Comment_Created_By__c = lstCommentData[0].CreatedById;                   
                    }   
                }
            }
        }
    }
    
}