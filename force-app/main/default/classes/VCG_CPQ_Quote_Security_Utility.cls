public with sharing class VCG_CPQ_Quote_Security_Utility {
    /*
    The base CPQ solution will have a configuration module for security settings which provide administrators with the ability to 
    restrict visibility via read/write access to designated features of the tool.

    Base level restrictions are:
    
    - Pricing Result Details - the ability to define who is allowed to view or edit (Pricing Overrides) the Pricing Result Details
    - Output generation - the ability to define who has the ability to generate a specific type of output (i.e. PDF, CSV, etc.)
    - Field-level Visibility/Editability - the ability to define who has the ability to view or edit a specific field 
      (i.e. Uplift or Discretionary Discount fields, calculated discount fields, etc.)
    
    
    Company-specific required restrictions can be detailed in the table below:
        
        Pricing Result Details
        Export to Excel
        Export to PDF
        Value Override
        Renewal Uplift Percent




    Acceptance Criteria
    - Designated features should not be made available to user groups outside of those listed in the table above.
    - The quote output features should require final approval in addition to the required security restrictions listed above before being made available.
    
    
    Assumptions
    - Security model will be based on standard Salesforce Profiles/Roles/Groups. 
    - Security configurations will not be assignable to individual users.
    

    
     */
     
     /**
     * @description  Returns the list of restrictions for a given user. Meant to be cached one time then accessed in memory
     *
     * @author Nathan Shinn
     * @since  6/10/2014
     */
     public static list<VCG_CPQ_Security_Restriction__c> getUserRestrictions(Id userId)
     {
        //get the user's profile Name and Role Name
        User u = [Select Profile.Name, UserRole.Name, Id from User where Id = :userId];
        
        //get the groups that the user belongs to
        set<string> groups = getGroupNamesForUser(userId);
        
        //get the restriction records
        list<VCG_CPQ_Security_Restriction__c> restrictions =  new list<VCG_CPQ_Security_Restriction__c>();
        
        for(VCG_CPQ_Security_Restriction__c r : [Select Assoc_Restriction_Level_Name__c
                                                     , Functional_Restriction__c
                                                     , Has_Access__c
                                                     , Restriction_Level__c
                                                 from VCG_CPQ_Security_Restriction__c
                                                where (Assoc_Restriction_Level_Name__c = :u.Profile.Name and Restriction_Level__c = 'Profile')
                                                      or
                                                      (Assoc_Restriction_Level_Name__c = :u.UserRole.Name and Restriction_Level__c = 'Role')
                                                      or
                                                      (Assoc_Restriction_Level_Name__c in :groups and Restriction_Level__c = 'Group')
                                                    ])
        {
            restrictions.add(r);
        }
        
        return restrictions;
     }
     
     /**
     * @description  Returns true or false iben the functional area. Default it true (has access)
     *
     * @author Nathan Shinn
     * @since  6/10/2014
     */
     public static boolean getUserAccess(list<VCG_CPQ_Security_Restriction__c> restrictions, string functionalArea)
     {
        //retrieve the restriction based on functional area
        for(VCG_CPQ_Security_Restriction__c r : restrictions)
        {
            if(r.Functional_Restriction__c.equalsIgnoreCase(functionalArea))
                return r.Has_Access__c;
        }
        
        return false;
     }
     
     /**
     * @description  Returns a list of the names of the Groups the user belongs to
     *
     * @author Nathan Shinn
     * @since  6/10/2014
     */
     public static set<string> getGroupNamesForUser(Id userId)
     {
        set<string> groupNames = new set<string>();
        for(Group g : getGroupsForUser(userId))
        {
            groupNames.add(g.DeveloperName);
            groupNames.add(g.Name);
        }
        
        return groupNames;
     }
     
     /**
     * @description  return list of all group records the user belongs to via direct or indirect membership
     *
     * @author Nathan Shinn
     * @since  6/10/2014
     */
    public static list<Group> getGroupsForUser(Id userId){
    
        Set<Id> groupIds = getGroupsForIds(new Set<Id>{userId});
         return [
           select Id
                , Name
                , Group.DeveloperName
             from Group
            where Id IN: groupIds];
    
    }
    
     /**
     * @description  return all ids the user belongs to via direct or indirect membership
     *
     * @author Nathan Shinn
     * @since  6/10/2014
     */
    public static Set<Id> getGroupsForIds(Set<Id> userOrGroupIds){
    
        Set<Id> output = new Set<Id>();
    
        Set<Id> nestedGroupIds = new Set<Id>();
    
        // only query actual groups and not roles and queues
        list<GroupMember> records = [
            select id
                 , GroupId
                 , UserOrGroupId
              from GroupMember
             where UserOrGroupId =: userOrGroupIds
            and UserOrGroupId != null
               and Group.Type = 'Regular'];
    
        for (GroupMember record:records)
        {
            // found a group, remember for traversal
            if (!(record.UserOrGroupId + '').startsWith('005'))
            {
                nestedGroupIds.add(record.UserOrGroupId);   
            }
            else
            {
                output.add(record.GroupId);
            }
        }
    
        // call self to get nested groups we found
        if (nestedGroupIds.size() > 0)
        {
            output.addAll(getGroupsForIds(nestedGroupIds));
        }
    
        return output;
    }
}