@isTest(SeeAllData=True)
class CaseContExt_Test
{

    static testMethod void testConstructor()
    {
        //Test without Account and contact
        Case cs1 = new Case();
        ApexPages.StandardController std1 = new ApexPages.StandardController(cs1);
        CaseContExt cce1 = new CaseContExt(std1);
        cce1.saveAndAttach();
        cce1.saveOnly();
        System.assertNotEquals(null, cce1);

        
        
        //Test with dummy contact
        Account a2 =  TestUtils.getAccount('ut acc1');
        insert a2;           
        Case cs2 = new Case();
        cs2.Business_Unit__c = 'Roadnet';
        ApexPages.StandardController std2 = new ApexPages.StandardController(cs2);
        ApexPages.currentPage().getParameters().put('def_account_id', a2.id);
        ApexPages.currentPage().getParameters().put('def_contact_id', '003000000000000000');
        CaseContExt cce2 = new CaseContExt(std2);        
        cce2.saveAndAttach();
        cce2.saveOnly();
        System.assertNotEquals(null, cce2);                           
        
        //Test with invalid accountid             
        Case cs3 = new Case();
        ApexPages.StandardController std3 = new ApexPages.StandardController(cs2);
        ApexPages.currentPage().getParameters().put('def_account_id', '003000000000000000');
        ApexPages.currentPage().getParameters().put('def_contact_id', '003000000000000000');
        CaseContExt cce3 = new CaseContExt(std3);        
        System.assertNotEquals(null, cce3);

        
        //Test with dummy contact
        Account a4 =  TestUtils.getAccount('ut acc1');
        insert a4;           
        Contact con = TestUtils.getContact(a2, 'ContOpt');
        insert con;
        Contact con2 = TestUtils.getContact(a2, 'ContOpt2');
        insert con2;
        Case cs4 = new Case();
        cs4.Business_Unit__c = 'Roadnet';
        ApexPages.StandardController std4 = new ApexPages.StandardController(cs4);
        ApexPages.currentPage().getParameters().put('def_account_id', a4.id);
        ApexPages.currentPage().getParameters().put('def_contact_id', '003000000000000000');
        CaseContExt cce4 = new CaseContExt(std4);        
        cce2.saveAndAttach();
        cce2.saveOnly();
        System.assertNotEquals(null, cce4); 
        
        
        //initialize Page without any query string - internal user
        Account a = TestUtils.getAccount('ut acc1');
        insert a;
        Case cs = TestUtils.getCase();
        
        ApexPages.StandardController std = new ApexPages.StandardController(cs);
        Test.startTest();
        CaseContExt cce = new CaseContExt(std);
        //System.assertEquals(System.label.No_Account_provided, ApexPages.getMessages().get(0).getDetail());
        
        //provide an account and contact in query string - internal user
        cs = TestUtils.getCase();
        Contact c = TestUtils.getContact(a);
        insert c;        
        ApexPages.currentPage().getParameters().put('def_account_id', a.id);
        ApexPages.currentPage().getParameters().put('def_contact_id', c.id);
        std = new ApexPages.StandardController(cs);
        cce = new CaseContExt(std);
        System.assertEquals(a.id, cce.am.record.id);
        System.assertEquals(a.id, cs.AccountID);
        System.assertEquals(c.id, cs.ContactID);
        //System.assertEquals(Constants.DEFAULT_ORIGIN, cs.Origin);
        //System.assertEquals(Constants.SEVERITY_ROUTINE, cs.Severity__c);
        System.assertEquals(false, cce.isPortal);
        System.assertEquals(false, cce.isChangeAsset);
        //System.assertEquals(false, cce.useDefaultAssignmentRules);
        
        //call the page from portal - portal user
        /*User u = TestUtils.getCustomerPortalUser2('UTP1', c);
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        u.UserRoleId = portalRole.Id;        
        insert u;
        
        System.runAs(u)
        {
            std = new ApexPages.StandardController(new Case());
            cce = new CaseContExt(std);
            System.assertEquals(a.id, cs.AccountID);
            System.assertEquals(c.id, cs.ContactID);
            System.assertEquals(true, cce.isPortal);
            System.assertEquals(false, cce.isChangeAsset);
        }*/
        
        //call the page to change asset - Internal user only
        //create all Case related objects first
    /*
        Account practice = TestUtils.getPractice(a, 'prc1');
        insert practice;
        Version_Family__c vf = TestUtils.getVersionFamily('vf1');
        insert vf;
        Version__c v1 = TestUtils.getVersion(vf, 'v1.0');
        insert v1;
        Product2 p1 = TestUtils.getProduct('ut prod1', 'family1', 'line1', vf);
        insert p1;
        Asset__c ast1 = TestUtils.getAsset(a, p1);
        insert ast1;
        AccountAsset__c aa1 = TestUtils.getAccountAsset(practice, ast1);
        insert aa1;
        Component__c comp = TestUtils.getComponent( 'comp1');
        insert comp;
        Component_Product_Junction__c cpj = TestUtils.getComponentProductJunction(comp, p1);
        insert cpj;
        Sub_Component__c sc = TestUtils.getSubComponent(comp, 'subComponent1');
        insert sc;
        cs = TestUtils.getCase(a, c, 'family1', 'line1', ast1, practice, v1, comp, sc);
        insert cs;
        ApexPages.currentPage().getParameters().put(CONSTANTS.QRY_STRING_CASE_ID, cs.id);
        std = new ApexPages.StandardController(cs);
        cce = new CaseContExt(std);
        System.assertEquals(true, cce.isChangeAsset);
        */
        Test.stopTest();
    }
    
    static testMethod void testConstructorWithAsset(){
        Account a = TestUtils.getAccount('ut acc1');
        insert a;
        
        Product2 p2 = TestUtils.getProduct('ut prod2', 'MCP');
        p2.Shipment_Schedule_Required__c = TRUE;
        p2.ProductCode = 'OMNI';
        insert p2;
        
        Asset__c assets = TestUtils.getAsset(a, p2);
        insert assets;
        
        Case cs = TestUtils.getCase();        
                
        ApexPages.StandardController std = new ApexPages.StandardController(cs);        
        CaseContExt cce = new CaseContExt(std);                        
        cs = TestUtils.getCase();
        cs.Product_Family_Name__c = 'MCP';
        cs.Asset__c = assets.Id;
        Contact c = TestUtils.getContact(a);
        insert c;
        ApexPages.currentPage().getParameters().put('def_account_id', a.id);
        //ApexPages.currentPage().getParameters().put('def_contact_id', c.id);
        std = new ApexPages.StandardController(cs);
        cce = new CaseContExt(std);        
        
        System.assertEquals(a.id, cce.am.record.id);
        System.assertEquals(a.id, cs.AccountID);
        //System.assertEquals(c.id, cs.ContactID);
        System.assertEquals(false, cce.isPortal);
        System.assertEquals(false, cce.isChangeAsset);
        
    }
    
    
   /* static testMethod void testConstructorPortalUser(){      
        
        //UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        //system.debug('portalRole is ' + portalRole);
        test.startTest();
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
        UserRoleId = portalRole.Id,
        ProfileId = profile1.Id,
        Username = System.now().millisecond() + 'test2@omnitracs.com',
        Alias = 'batman',
        Email='bruce.wayne@omnitracs.com',
        EmailEncodingKey='UTF-8',
        Firstname='Bruce',
        Lastname='Wayne',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);
        
        //User u1 = [Select ID From User Where Id =: portalAccountOwner1.Id];
        Account portalAccount1 = new Account();
        Contact contact1 = new Contact();
        User user1 = new User();
        
        System.runAs ( portalAccountOwner1 ) {
            //Create account
            portalAccount1 = new Account(
            Name = 'TestAccount',
            OwnerId = portalAccountOwner1.Id
            );
            Database.insert(portalAccount1);
            
            //Create contact
            contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            AccountId = portalAccount1.Id,
            Email = System.now().millisecond() + 'test@omnitracs.com'
            );
            Database.insert(contact1);
            
            //Create user
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name like: '%'+'Customer Community User'+'%' limit 1];
            user1 = new User(
            Username = System.now().millisecond() + 'test12345@omnitracs.com',
            ContactId = contact1.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@omnitracs.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
            );
            Database.insert(user1);
        }
        
        Case cs = TestUtils.getCase();
        
        System.runAs(user1)
        {
            ApexPages.StandardController std = new ApexPages.StandardController(new Case());
            CaseContExt cce = new CaseContExt(std);
            System.assertEquals(true, cce.isPortal);
            System.assertEquals(false, cce.isChangeAsset);
            cce.saveAndAttach();
            cce.saveOnly();
            cce.showArticles();
            cce.refreshPage();
            cce.doCancel();
        }test.stoptest();
    }*/
    
/*AA>    
    static testMethod void testRefreshAccount()
    {
        Account a = TestUtils.getAccount('ut acc1');
        insert a;
        Account a2 = TestUtils.getAccount('ut acc2');
        insert a2;
        Contact c = TestUtils.getContact(a);
        insert c;
        Case cs = TestUtils.getCase();
        ApexPages.currentPage().getParameters().put(Constants.QRY_STRING_ACCOUNT_ID, a.id);
        ApexPages.currentPage().getParameters().put(Constants.QRY_STRING_CONTACT_ID, c.id);
        ApexPages.StandardController std = new ApexPages.StandardController(cs);
        CaseContExt cce = new CaseContExt(std);
        System.assertEquals(a.id, cs.AccountID);
        System.assertEquals(c.id, cs.ContactID);
        
        //first call the method without providing the AccountID. Verify it throws appropriate error
        cce.c.AccountID = null;
        cce.refreshAccount();
        System.assertEquals(System.label.No_Account_provided_Please_choose_an_Account_before_clicking_Go, ApexPages.getMessages().get(0).getDetail());
        
        cce.c.AccountID = a2.id;
        cce.refreshAccount();
    }*/
    
    static testMethod void testSaveMethods()
    {
        User depUser = [select Id from User where alias = 'Depuser'];
        System.runas(depUser){
            Account a = TestUtils.getAccount('ut acc1');
            insert a;
            Contact c = TestUtils.getContact(a);
            insert c;
            Case cs = TestUtils.getCase(a, c);        
            ApexPages.currentPage().getParameters().put('def_account_id', a.id);
            ApexPages.currentPage().getParameters().put('def_contact_id', c.id);
            ApexPages.StandardController std = new ApexPages.StandardController(cs);
            CaseContExt cce = new CaseContExt(std);
            
            
            Test.startTest();
            PageReference pr = cce.saveOnly();
            pr = cce.saveAndAttach();
            //pr = cce.saveAsset();
        }
    }
    
/**/
}