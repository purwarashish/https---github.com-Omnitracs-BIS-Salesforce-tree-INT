trigger AttachmentTrigger on Attachment (after insert) 
{
	/* COMMENTED OUT AS THE LOGIC HAS BEEN CONSOLIDATED AttachmentAll Trigger
	
     if ( MigrationUser.isMigrationUser() )
    {
        // do nothing you are the migration user
    }
    else
    {
        //  try to query a custom report object using the parentid of attachment, if it exists, update the custom report's record's name with the name of 
        //  the Attachment
        for (Attachment a : Trigger.new)
        {
            try 
            {
                Custom_Report__c cr = [select id, name from Custom_Report__c where id =: a.parentid];
                if (cr != null)
                {
                    cr.name = a.name;
                    update cr;
                }
            }
            catch(Exception e)
            {
                //  we alwyas want attachments to be created so do not alow the exception to bubble up at all
            }
        }
    }
    */
}