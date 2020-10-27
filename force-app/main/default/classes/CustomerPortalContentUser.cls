/**
 * @Description : This class contains the functionality to add CP user to
 * the public group 'Customer Portal Content Users'
 * @author Pratyush Kumar
 * @Dependencies :Customer_Portal_Content_Users (Custom label) 
 */
public class CustomerPortalContentUser
{
    @future
    public static void addToPublicGroup(List<id> userId)
    {
        List<Group> lstGrp = new List<Group>();
        lstGrp = [SELECT 
                          id , 
                          name 
                      FROM 
                          group
                      WHERE 
                          id = :System.label.Customer_Portal_Content_Users
                      LIMIT 
                          1
                  ];
        
        List<GroupMember> lstGrpMem = new List<GroupMember>();
        for(Id ids:userId)
        {
            GroupMember grpMem = new GroupMember();
            if(lstGrp != null && lstGrp.size()>0)
                grpMem.GroupId = lstGrp[0].id;
            grpMem.UserOrGroupId = ids;
            lstGrpMem.add(grpMem); 
             
        }
        try
        {
            if(lstGrpMem != null && lstGrpMem.size() > 0)
            insert lstGrpMem;
        }
        catch(Exception e)
        {
            system.debug('Insert Failed');
        }
    }
}