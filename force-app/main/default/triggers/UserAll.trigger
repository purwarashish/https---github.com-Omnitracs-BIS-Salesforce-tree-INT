/**
 * @Decription: This trigger is fired when A CP user is created .
 * This CP user is then added to the public group 'Customer Portal Content Users' 
 * @author Pratyush Kumar
 */
trigger UserAll on User (before insert, before update, after insert) 
{    
    if(trigger.isAfter)    
    {
        if(trigger.isInsert) {
            List<id> lstUsrId = new List<id>(); //stores CP user's id
            for(User usr:trigger.new)
            {
                if( (usr.UserType == 'PowerCustomerSuccess') ||(usr.UserType == 'CustomerSuccess') )
                {
                    lstUsrId.add(usr.id); 
                }
            }
            if(lstUsrId != null && lstUsrId.size()>0)
                CustomerPortalContentUser.addToPublicGroup(lstUsrId);
        }
    }
}