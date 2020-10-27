@isTest(SeeAllData=true)
public class ContactUtilsTest {
    /*public static testMethod void runAllTests() {
    
        Contact cnt = new Contact();
        List<Contact> lstContact = new List<Contact>();
        lstContact.add(cnt);
        ContactUtils.findDuplicate(lstContact);
        ContactUtils.findDuplicate(lstContact, lstContact);        
        ContactUtils.getGroupEmail();         
                       
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

        List<Id> lstGrpId = new List<Id>();
        lstGrpId.add(lstGrp[0].id);
        ContactUtils.findGrpMembers(lstGrpId);
        
        //  Code added by joseph hutchins 12/12/2014
        List<Contact> testContactList = new List<Contact>();
        Contact testContact = new Contact(inactive__c = true);
        testContactList.Add(testContact);
        ContactUtils.updateContactAlertForInactiveContacts(null, testContactList);
    }*/
}