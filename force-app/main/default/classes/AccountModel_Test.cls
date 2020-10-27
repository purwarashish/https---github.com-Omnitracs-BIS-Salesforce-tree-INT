@isTest(SeeAllData=true)
class AccountModel_Test
{

    static testMethod void testConstructorsForCaseCreation()
    {
       //test the constructor with account and isPortal flag as arguments
        Account a = TestUtils.getAccount('ut Acc1');
        insert a;
        AccountModel am = new AccountModel(a, false);
        System.assertEquals(a.id, am.record.id);
        System.assertEquals(am.isPortal, false);
        
        am = new AccountModel(a, true);
        System.assertEquals(a.id, am.record.id);
        System.assertEquals(am.isPortal, true);
        
        //test the overloaded constructor with just Account argument
        am = new AccountModel(a);
        System.assertEquals(a.id, am.record.id);
        //verify that with this overload, Isportal is always defaulted to false
        System.assertEquals(am.isPortal, false);
        
        am = new AccountModel(a,false,true);
        System.assertEquals(a.id, am.record.id);
        System.assertEquals(am.isPortal, false);
        System.assertEquals(am.isRoadnetOnly, true);
    }
    
    
    static testMethod void testGetAccountsModel()
    {
        Account parent = TestUtils.getAccount('Parent acc');
        insert parent;
        Account acc= TestUtils.getAccount('ut acc1');
        acc.parentId = parent.id;
        insert acc;
        Contact c1 = TestUtils.getContact(acc, 'c1');
        insert c1;
        Contact c2 = TestUtils.getContact(acc, 'c2');
        insert c2;
        Product2 p1 = TestUtils.getProduct('up1', 'family1');
        p1.Support_Applicable__c = true;
        p1.Family = 'test';
        p1.Product_Line__c = 'Product';
        insert p1;
        Contract con = TestUtils.getContract(acc);
        insert con;
        Asset__c va1 = TestUtils.getAsset(acc, p1, con); 
        va1.Name = 'v1';
        va1.Maintenance_Status__c = 'On Maintenance';
        va1.Product__c = p1.id ;
        insert va1;
        Case cObj = new case();
        cObj.Status = 'Teststatus';
        cObj.AccountId = acc.id;
        cObj.ContactId = c2.id;
        cObj.Product_Family_Name__c = 'test';
        cObj.Product_Line_Name__c = 'Product';
        insert cObj;
        CaseComment ccomment = new CaseComment();
        ccomment.CommentBody = 'body';
        ccomment.ParentId = cObj.id;
        insert ccomment;
        
        Test.startTest();
        AccountModel am = new AccountModel(acc);
        am.isRoadnetOnly = true;
        am.getAccounts();
        am.getContactOptionsByAccount(acc.Id, c1.Id);
        am.getSupportContactOptionsByAccount(acc.Id,c1.Id );
        am.getSupportContacts(acc.Id);
        am.getProductFamilyOptionsByAccount(acc.Id,null);
        am.getAssetOptionsByProductFamily('test');
        am.getProductLineOptionsByProductFamily('test');
        am.getAssetOptionsByProductFamilyAndProductLine('test','Product' , true);
        //am.saveCase(cObj ,null,'parent' , true , false , true);
        //System.assertEquals(am.accountOptions.size() , 0);
        Test.stopTest();
    }
      
  
    static testMethod void testGetAccountsModelElse()
    {
        Account parent = TestUtils.getAccount('Parent acc');
        insert parent;
        Account acc= TestUtils.getAccount('ut acc1');
        acc.parentId = parent.id;
        insert acc;
        Contact c1 = TestUtils.getContact(acc, 'c1');
        insert c1;
        Contact c2 = TestUtils.getContact(acc, 'c2');
        insert c2;
        Product2 p1 = TestUtils.getProduct('up1', 'family1');
        p1.Support_Applicable__c = true;
        p1.Family = 'test';
        p1.Product_Line__c = 'Product';
        insert p1;
        Contract con = TestUtils.getContract(acc);
        insert con;
        Asset__c va1 = TestUtils.getAsset(acc, p1, con); 
        va1.Name = 'v1';
        va1.Maintenance_Status__c = 'On Maintenance';
        va1.Product__c = p1.id ;
        insert va1;
        Case cObj = new case();
        cObj.Status = 'Teststatus';
        cObj.Product_Family_Name__c = 'Customer Community';
        cObj.AccountId = acc.id;
        cObj.ContactId = c2.id;
        insert cObj;
        CaseComment ccomment = new CaseComment();
        ccomment.CommentBody = 'body';
        ccomment.ParentId = cObj.id;
        insert ccomment;
        
        Test.startTest();
        AccountModel am = new AccountModel(acc);
        am.isRoadnetOnly = false;
        am.getAccounts();
        am.getContactOptionsByAccount(acc.Id, c1.Id);
        am.getSupportContactOptionsByAccount(acc.Id,c1.Id );
        am.getSupportContacts(acc.Id);
        am.getProductFamilyOptionsByAccount(acc.Id,acc.Id);
        am.getAssetOptionsByProductFamily('Customer Community');
        am.getProductLineOptionsByProductFamily('Customer Community');
        am.getAssetOptionsByProductFamilyAndProductLine(null,'Product' , true);
        //am.saveCase(cObj ,null,'edit' , false, false , true);
        //System.assertEquals(am.accountOptions.size() , 0);
        Test.stopTest();
    }
}