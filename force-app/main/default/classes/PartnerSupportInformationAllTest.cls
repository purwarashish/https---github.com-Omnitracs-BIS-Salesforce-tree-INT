@isTest(SeeAllData=true)
public class PartnerSupportInformationAllTest {
    public static testMethod void runAllTests() {                
        Partner_Support_Information__c psi = new Partner_Support_Information__c();
        psi.Partner_Account__c = '0015000000LGKdn';
        psi.Support_Email__c = 'xyz@gmail.com';
        psi.Support_Phone__c = '8586039700';
        psi.Support_Name__c = 'Test Partner Display Name';
        psi.Hours_Of_Service__c = '08:00 - 20:00 PST';
        psi.Logo__c = 'xxxxyyyyyzzzz';
        psi.Logo_Orientation__c = 'Portrait';       
        
        test.startTest();
        insert psi;
        
        psi = new Partner_Support_Information__c();
        psi.Partner_Account__c = '0015000000LGKdn';
        psi.Support_Email__c = 'xyz@gmail.com';
        psi.Support_Phone__c = '8586039700';
        psi.Support_Name__c = 'Test Partner Display Name';
        psi.Hours_Of_Service__c = '08:00 - 20:00 PST';
        psi.Logo__c = 'xxxxyyyyyzzzz';
        psi.Logo_Orientation__c = 'Portrait';

        try {
            insert psi;                        
        }
        catch(Exception e) {
        }
        
        test.stopTest();                
    }
}