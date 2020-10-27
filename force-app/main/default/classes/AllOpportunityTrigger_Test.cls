/*********************************************************************************************************************
Name     : AllOpportunityTrigger_Test
Objective: Test methods for all functionalities in AllOpportunityTrigger on Opportunity

Modified By  : Rittu Roy
Modified Date: 01/09/2016
Reason       : Case #02149361 - Added a line of code(line #74) to test if opportunity gets unlocked while in approval process
*********************************************************************************************************************/
@istest(seeAllData=true)
private class AllOpportunityTrigger_Test
{
    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
    /*@istest(seeAllData=true)
    private Static void createAssets_Test()
    {    
        OpportunityTestData opportunityTestData  = new OpportunityTestData();
        //insert test user
        Profile testProfile=[ select id from profile where Name = 'System Administrator' ];
        User TestUser = opportunityTestData.CreateUser('createUpdateAssets', testProfile.id, 'TstOpUsr', null);
        Insert TestUser;
        //insert Account
        List<Account> accountList = opportunityTestData.CreateAcccount('createUpdateAssets', 1);
        insert accountList;
        //Insert Contact
        List<Contact> contactList =  opportunityTestData.ContactCreation('createUpdateAssets', 1, accountList.get(0).id);
        insert contactList;
        
        Test.startTest();   
        System.runAs(TestUser)
        {
            PriceBook2 stdPriceBook = opportunityTestData.createPriceBook();
            //Insert Opportunity
            List<Opportunity> createOpportunityList = opportunityTestData.CreateOpportunity('createUpdateAssets', accountList.get(0).id,
                                                                                            'Products, Services and Maintenance', 1, contactList.get(0).id, stdPriceBook, null, null, null);
            Insert createOpportunityList;
            system.assert(createOpportunityList.get(0).id != null,'Exception in Opportunity Creation');
            
            //Insert Product
            List<Product2> productlist = opportunityTestData.createProduct('createUpdateAssets', 2);
            Insert productlist;
            system.assert(productlist.get(0).id != null,'Exception in Product1 Creation');
            system.assert(productlist.get(1).id != null,'Exception in Product2 Creation');
            
            //Insert PriceBookEntry
            List<PriceBookEntry> PriceBookEntrylist = opportunityTestData.createPriceBookEntry('createUpdateAssets', productlist.size(), 
                                                                                               stdPriceBook, productlist);
            Insert PriceBookEntrylist;
            system.assert(PriceBookEntrylist.get(0).id != null,'Exception in PriceBookEntry1 Creation');
            system.assert(PriceBookEntrylist.get(1).id != null,'Exception in PriceBookEntry2 Creation');
            
            //Insert OpportunityProduct
            List<OpportunityLineItem> opportunityLineItemList = opportunityTestData.createopportunityLineItem('createUpdateAssets',
                                                                                                              PriceBookEntrylist.size(), createOpportunityList, PriceBookEntrylist);
            Insert opportunityLineItemList;
            system.assert(opportunityLineItemList.get(0).id != null,'Exception in opportunityLineItem1 Creation');
            system.assert(opportunityLineItemList.get(1).id != null,'Exception in opportunityLineItem2 Creation');
            system.debug('opportunityproduct Inserted@@@');
            
            //Update Opportunity
            List<Id> createdOpportunityIdList = new List<Id>();
            for(Opportunity objOpportunity :createOpportunityList)
            {
                CreatedOpportunityIdList.add(objOpportunity.Id);
            }
            List<Opportunity> createdOpportunityList = [Select Id, Legal_Review__c, Finance_Status__c, Stagename  From Opportunity where id in :CreatedOpportunityIdList];
            for(Opportunity objOpportunity :createdOpportunityList)
            {
                system.assertequals('Waiting for Finance Review', objOpportunity.Legal_Review__c);
                system.assertequals('Approved', objOpportunity.Finance_Status__c);
                objOpportunity.Legal_Review__c = 'Approved';
                objOpportunity.Finance_Status__c = 'Approved';
                objOpportunity.Stagename = 'Closed Won';
                
                //Added by Rittu Roy(1/9/16)-Case #02149361
                objOpportunity.Unlock_Opportunity__c = true;
            }
            update createdOpportunityList;
            system.debug('opportunity updated@@@');
            
            //Verify the updated opportunity
            List<Id> UpdatedOpportunityIdList = new List<Id>();
            for(Opportunity objOpportunity :createOpportunityList)
            {
                UpdatedOpportunityIdList.add(objOpportunity.Id);
            }
            List<Opportunity> UpdatedOpportunityList = [Select Id, Legal_Review__c, Finance_Status__c, SP_Products__c From Opportunity where id in :UpdatedOpportunityIdList];
            List<OpportunityLineItem> oppLineItmList = [SELECT pricebookentry.Product2.ProductCode FROM OpportunityLineItem WHERE OpportunityId in :UpdatedOpportunityIdList];
            for(Opportunity objOpportunity :UpdatedOpportunityList)
            {
                system.assertequals('Approved', objOpportunity.Legal_Review__c);
                system.assertequals('Approved', objOpportunity.Finance_Status__c);
                system.assertequals(oppLineItmList.get(0).pricebookentry.Product2.ProductCode+';'+oppLineItmList.get(1).pricebookentry.Product2.ProductCode, objOpportunity.SP_Products__c);
            }
            
        }
        Test.stopTest();
    }*?
    
    /*@istest(seeAllData=true)
    private Static void updateAssets_Test()
    {
        OpportunityTestData opportunityTestData  = new OpportunityTestData();
        //insert User
        Profile testProfile=[ select id from profile where Name = 'System Administrator' ];
        User TestUser = opportunityTestData.CreateUser('createUpdateAssets', testProfile.id, 'TstOpUsr', null);
        Insert TestUser;
        
        //insert Account
        List<Account> accountList = opportunityTestData.CreateAcccount('createUpdateAssets', 1);
        insert accountList;
        
        //Insert Contact
        List<Contact> contactList =  opportunityTestData.ContactCreation('createUpdateAssets', 1, accountList.get(0).id);
        insert contactList;
        
        System.runAs(TestUser)
        {
            Id quote_Product_Id;
            Id asset_c_Id;
            Integer noOfDays = 10;
            Set<opportunityLineItem> lstopportunityLineItem = new Set<opportunityLineItem>();
            while(true)
            {
                List<opportunityLineItem> objopportunityLineItem = [select id, opportunityId, Line_Type__c, asset__c, Add_On_To_Asset__c, 
                                                                    Add_On_Source_Quote_Product__c, Quote_Product__c from opportunityLineItem where 
                                                                    asset__c != null AND PricebookEntry.Product2.Is_Maintenance__c =: false AND 
                                                                    PriceBookEntry.Product2.Is_Bundle__c =: false AND Quote_Product__c !=: null AND
                                                                    CreatedDate <= :System.today()- noOfDays Limit 4];
                if(objopportunityLineItem != null && objopportunityLineItem.size()>0)
                {
                    for(opportunityLineItem singleopportunityLineItem :objopportunityLineItem)
                    {
                        lstopportunityLineItem.add(singleopportunityLineItem);
                        Quote_Product_Id = singleopportunityLineItem.Quote_Product__c;
                        asset_c_Id = singleopportunityLineItem.asset__c;
                        if(lstopportunityLineItem.size() == 4)
                            break;
                    }
                }
                if(noOfDays >2000)
                {
                    break;
                }            
                noOfDays = noOfDays + 200;                                                                                                                  
            }
            
            noOfDays = 200;
            while(true)
            {
                List<opportunityLineItem> objopportunityLineItem = [select id, opportunityId, Line_Type__c, asset__c, Add_On_To_Asset__c, 
                                                                    Add_On_Source_Quote_Product__c from opportunityLineItem where 
                                                                    asset__c != null AND PricebookEntry.Product2.Is_Maintenance__c =: true AND 
                                                                    PriceBookEntry.Product2.Is_Bundle__c =: false AND 
                                                                    CreatedDate <= :System.today()- noOfDays Limit 4];
                if(objopportunityLineItem != null && objopportunityLineItem.size()>0)
                {
                    for(opportunityLineItem singleopportunityLineItem :objopportunityLineItem)
                    {
                        lstopportunityLineItem.add(singleopportunityLineItem);
                        if(lstopportunityLineItem.size() == 8)
                            break;
                    }
                }    
                if(noOfDays >2000)
                {
                    break;
                }            
                noOfDays = noOfDays + 200;                                                                                                                  
            }
            system.debug('lstopportunityLineItem@@@'+lstopportunityLineItem);
            
            if(lstopportunityLineItem != null && lstopportunityLineItem.size() > 0)
            {
                Set<Id> setRoadnetOpportunityId = new set<Id>();
                integer i = 1;
                
                list<opportunityLineItem> lstopportunityLineItemData = new list<opportunityLineItem>();
                for(opportunityLineItem objopportunityLineItem :lstopportunityLineItem)
                {
                    lstopportunityLineItemData.add(objopportunityLineItem);
                }
                
                for(opportunityLineItem objopportunityLineItem :lstopportunityLineItemData)
                {
                    if(i == 1){
                        objopportunityLineItem.Line_Type__c = 'Decommission';
                        objopportunityLineItem.Decommission_Quantity__c = 1;
                    }                       
                    if(i == 2)
                        objopportunityLineItem.Line_Type__c = 'Renewal';
                    if(i == 3){
                        objopportunityLineItem.Line_Type__c = 'Extension';    
                    }
                    if(i == 4)
                        objopportunityLineItem.Line_Type__c = 'Migration';
                    if(i == 5){
                        objopportunityLineItem.Add_On_To_Asset__c = asset_c_Id;
                        objopportunityLineItem.Line_Type__c = 'New';
                    }
                    if(i == 6){
                        objopportunityLineItem.Add_On_To_Asset__c = asset_c_Id;
                        objopportunityLineItem.Line_Type__c = 'Decommission';
                        objopportunityLineItem.Decommission_Quantity__c = 1;
                    }
                    if(i == 7){
                        objopportunityLineItem.Add_On_To_Asset__c = asset_c_Id;
                        objopportunityLineItem.Line_Type__c = 'Renewal';
                    }     
                    if(i == 8){
                        objopportunityLineItem.Add_On_To_Asset__c = null;
                        objopportunityLineItem.Add_On_Source_Quote_Product__c = Quote_Product_Id;
                        objopportunityLineItem.Line_Type__c = 'Extension';
                    }           
                    i++;
                    setRoadnetOpportunityId.add(objopportunityLineItem.opportunityid);
                }
                
                List<Opportunity> lstRoadnetOpportunity = [select id, Primary_Contact__c, Role__c, geo_region__c from opportunity where 
                                                           id in:setRoadnetOpportunityId];
                for(Opportunity singleopp :lstRoadnetOpportunity)
                {
                    singleOpp.Primary_Contact__c = contactList.get(0).Id;
                    singleOpp.Role__c = 'Approver';
                    singleOpp.geo_region__c = 'APAC';
                }
                
                update lstRoadnetOpportunity;
                update lstopportunityLineItemData;          
            }
            
            Test.startTest();
            Set<Id> setOpportunityId = new Set<Id>();
            if(lstopportunityLineItem != null && lstopportunityLineItem.size() > 0)
            {
                for(opportunityLineItem objopportunityLineItem :lstopportunityLineItem)
                {
                    setOpportunityId.add(objopportunityLineItem.opportunityId);
                }
            }
            if(setOpportunityId != null && setOpportunityId.size() > 0)
            {
                List<Opportunity> lstOpportunity = [select id, Legal_Review__c, Finance_Status__c From Opportunity where id =: setOpportunityId ];           
                for(Opportunity objOpportunity :lstOpportunity)
                {
                    objOpportunity.Legal_Review__c = 'Waiting for Finance Review';
                    objOpportunity.Finance_Status__c = 'Approved';
                }
                update lstOpportunity;
                
                List<Opportunity> lstOpportunity1 = [select id, Legal_Review__c, Finance_Status__c From Opportunity where id =: lstOpportunity ];
                for(Opportunity objOpportunity1 :lstOpportunity1)
                {
                    system.assertequals('Waiting for Finance Review',objOpportunity1.Legal_Review__c);
                    system.assertequals('Approved',objOpportunity1.Finance_Status__c);
                    system.debug('objOpportunity1@@@ '+objOpportunity1.Legal_Review__c+','+objOpportunity1.Finance_Status__c);
                    objOpportunity1.Legal_Review__c = 'Approved';
                    objOpportunity1.Legal_Review__c = 'Approved';
                }
                update lstOpportunity1;
                
                List<Opportunity> lstOpportunity2 = [select id, Legal_Review__c, Finance_Status__c From Opportunity where id =: lstOpportunity1 ];
                for(Opportunity objOpportunity2 :lstOpportunity2)
                {
                    system.assertequals('Approved',objOpportunity2.Legal_Review__c);
                    system.assertequals('Approved',objOpportunity2.Finance_Status__c);
                    system.debug('objOpportunity2@@@ '+objOpportunity2.Legal_Review__c+','+objOpportunity2.Finance_Status__c);
                }
                
            }
        }
        Test.stopTest();
    }*/
    
    @istest(seeAllData=true)
    private Static void validateOpptyEditability_Test()
    {
        OpportunityTestData opportunityTestData  = new OpportunityTestData();
        //Insert test user
        Profile testProfile=[ select id from profile where Name = 'System Administrator' ];
        User TestUser = opportunityTestData.CreateUser('validateOpptyEditability', testProfile.id, 'TstOpUsr', null);
        Insert TestUser;
        system.assert(TestUser.id != null);
        
        //Insert test Account
        List<Account> accountList = opportunityTestData.CreateAcccount('validateOpptyEditability', 1);
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        //Account lstAccount = new Account(Name='dupe');
        list<Database.SaveResult> sr = Database.insert(accountList, dml);
        //insert accountList;
        system.assert(accountList.get(0).id != null);
        
        //Insert test Contact
        List<Contact> contactList =  opportunityTestData.ContactCreation('validateOpptyEditability', 1, accountList.get(0).id);
        insert contactList;
        system.assert(contactList.get(0).id != null);
        
        PriceBook2 stdPriceBook = opportunityTestData.createPriceBook();
        //Insert test Opportunity
        List<Opportunity> createOpportunityList = opportunityTestData.CreateOpportunity('validateOpptyEditability', accountList.get(0).id,
                                                                                        'Products, Services and Maintenance', 1, contactList.get(0).id, stdPriceBook, null, null, null);
        insert createOpportunityList;
        system.assert(createOpportunityList.get(0).id != null);
        
        //Update test Opportunity
        List<Id> createdOpportunityIdList = new List<Id>();
        for(Opportunity objOpportunity :createOpportunityList)
        {
            CreatedOpportunityIdList.add(objOpportunity.Id);
        }
        SBQQ__Quote__c sbQuote = util.createSBQuote(createOpportunityList.get(0), accountList.get(0), Date.today(), true);
        List<Opportunity> createdOpportunityList = [Select Id, Stagename  From Opportunity where id in :CreatedOpportunityIdList];
        for(Opportunity objOpportunity :createdOpportunityList)
        {
            system.assertequals('Prove', objOpportunity.Stagename);
            objOpportunity.SBQQ__PrimaryQuote__c = sbQuote.Id;
            objOpportunity.Stagename = 'Closed Won';
        }
        update createdOpportunityList;
        
        //insert test user into OpptyLock_Blockeduser
        Global_Variable__c OpptyLockBlockedUser = opportunityTestData.blockedUserInsertion(TestUser.id);
        update OpptyLockBlockedUser;
        
        //verify updated opportunity
        List<Id> updatedOpportunityIdList = new List<Id>();
        for(Opportunity objOpportunity :createOpportunityList)
        {
            updatedOpportunityIdList.add(objOpportunity.Id);
        }
        List<Opportunity> updatedOpportunityList = [Select Id, Stagename  From Opportunity where id in :updatedOpportunityIdList];
        
        Test.startTest();
        system.runAs(TestUser)
        {
            for(Opportunity objOpportunity :updatedOpportunityList)
            {
                system.assertequals('Closed Won', objOpportunity.Stagename);
                objOpportunity.Stagename = 'Sales Acceptance';
            }
            try{
                //should not be updated as oportunity is closed
                update updatedOpportunityList;
            }
            catch(Exception e)
            {
                system.assert(e.getmessage().contains('Closed Opportunity cannot be edited'));
            }
            
            //inserting Current SE into allowed field list
            Global_Variable__c OpptyLockAllowedFields  = opportunityTestData.allowedFieldInsertion('Current_SE__c');
            update OpptyLockAllowedFields ;
            List<Opportunity> updatedOpportunityList2 = [Select Id, Stagename, Current_SE__c  From Opportunity where id in :updatedOpportunityIdList];
            for(Opportunity objOpportunity :updatedOpportunityList2)
            {
                //system.assertequals('Closed Won', objOpportunity.Stagename);
                objOpportunity.Current_SE__c = TestUser.id;
            }
            //should be updated as we have added Current SE into allowed field list
            update updatedOpportunityList2;
            
            //insert test user into OpptyLock_AllowedProfiles
            Global_Variable__c OpptyLockallowedUser = opportunityTestData.allowedUserInsertion(TestUser.id);
            update OpptyLockallowedUser;
            List<Opportunity> updatedOpportunityList3 = [Select Id, Stagename  From Opportunity where id in :updatedOpportunityIdList];
            for(Opportunity objOpportunity :updatedOpportunityList3)
            {
                //system.assertequals('Closed Won', objOpportunity.Stagename);
                objOpportunity.Stagename = 'Sales Acceptance';
            }
            //should be updated as we have put user into allowed profile list
            update updatedOpportunityList3;
        }
        
        //deactivating the test user as we are having shortage of licenses
        User deploymentuser = [select id from user where id =: userinfo.getuserid()];
        system.runas(deploymentuser)
        {
            TestUser.isActive = false;
            update TestUser;
        }
        
        //Adding user's profile into OpptyLockBlockedProfile   
        String[] OpptyLockBlockedProfile = Label.OpptyLock_BlockedProfiles.split(',',0);
        Profile blockedProfile=[ select id from profile where Name =: OpptyLockBlockedProfile[4] ];
        User blockedUser = opportunityTestData.CreateUser('validateOpptyEditability', blockedProfile.id, 'blckdusr', null);
        Insert blockedUser;
        system.assert(blockedUser.id != null); 
        
        List<Opportunity> updatedOpportunityList4 = [Select Id, Stagename  From Opportunity where id in :updatedOpportunityIdList];
        system.runAs(blockedUser)
        {
            for(Opportunity objOpportunity :updatedOpportunityList4)
            {
                system.assertequals('Sales Acceptance', objOpportunity.Stagename);
                objOpportunity.Stagename = 'Closed - Won';
            }
            try{
                //should not be updated as user profile is part of OpptyLockBlockedProfile 
                update updatedOpportunityList4;
            }
            catch(Exception e)
            {
                //system.assert(e.getmessage().contains('Closed Opportunity cannot be edited'));
            }
            
        }
        Test.stopTest();                                             
    }
    
    @istest(seeAllData=true)
    private Static void opportunityNetsuitesync_Test()
    {
        OpportunityTestData opportunityTestData  = new OpportunityTestData();
        //Insert test user
        Profile testProfile=[ select id from profile where Name = 'System Administrator' ];
        User TestUser = opportunityTestData.CreateUser('opportunityNetsuitesync', testProfile.id, 'TstOpUsr', null);
        Insert TestUser;
        system.assert(TestUser.id != null);
        
        Test.startTest();
        system.runas(TestUser)
        {
            Test.setMock(HttpCalloutMock.class, new NetsuiteSyncMockHttpResponseGen());
            
            //Insert test Account
            List<Account> accountList = opportunityTestData.CreateAcccount('opportunityNetsuitesync', 1);
            Database.DMLOptions dml = new Database.DMLOptions(); 
        	dml.DuplicateRuleHeader.allowSave = true;
        	dml.DuplicateRuleHeader.runAsCurrentUser = true;
        	//Account lstAccount = new Account(Name='dupe');
        	list<Database.SaveResult> sr = Database.insert(accountList, dml);
            //insert accountList;
            system.assert(accountList.get(0).id != null);
            
            //Insert test Contact
            List<Contact> contactList =  opportunityTestData.ContactCreation('opportunityNetsuitesync', 1, accountList.get(0).id);
            insert contactList;
            system.assert(contactList.get(0).id != null);
            
            PriceBook2 stdPriceBook = opportunityTestData.createPriceBook();
            //Insert test Opportunity
            List<Opportunity> createOpportunityList = opportunityTestData.CreateOpportunity('opportunityNetsuitesync', accountList.get(0).id,
                                                                                            'Products, Services and Maintenance', 1, contactList.get(0).id, stdPriceBook, null, null, null);
            insert createOpportunityList;
            system.assert(createOpportunityList.get(0).id != null);
            
            //Update test Opportunity
            List<Id> createdOpportunityIdList = new List<Id>();
            for(Opportunity objOpportunity :createOpportunityList)
            {
                CreatedOpportunityIdList.add(objOpportunity.Id);
            }
            List<Opportunity> createdOpportunityList = [Select Id, Primary_Quote_Approval_Status__c  From Opportunity where id in :CreatedOpportunityIdList];
            for(Opportunity objOpportunity :createdOpportunityList)
            {
                system.assertequals('Approved', objOpportunity.Primary_Quote_Approval_Status__c);
                objOpportunity.Primary_Quote_Approval_Status__c = 'Recalled';
            }
            update createdOpportunityList;
        }
        Test.stopTest();
    }
    
    
    @istest(seeAllData=true)
    private Static void assignGeoRegionAndOpptCountry_Test()
    {
        OpportunityTestData opportunityTestData  = new OpportunityTestData();
        //Insert test user
        Profile testProfile=[ select id from profile where Name = 'System Administrator' ];
        User TestUser = opportunityTestData.CreateUser('assignGeoRegionAndOpptCountry', testProfile.id, 'TstOpUsr', null);
        Insert TestUser;
        system.assert(TestUser.id != null);
        
        //Insert test Account
        List<Account> accountList = opportunityTestData.CreateAcccount('assignGeoRegionAndOpptCountry', 1);
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        //Account lstAccount = new Account(Name='dupe');
        list<Database.SaveResult> sr = Database.insert(accountList, dml);
        //insert accountList;
        system.assert(accountList.get(0).id != null);
        
        //Insert test Contact
        List<Contact> contactList =  opportunityTestData.ContactCreation('assignGeoRegionAndOpptCountry', 1, accountList.get(0).id);
        insert contactList;
        system.assert(contactList.get(0).id != null);
        
        List<Country_And_Country_Code__c> CountryAndCountryCodeList = opportunityTestData.createCountryAndCountryCode('assignGeoRegionAndOpptCountry', 2);
        insert CountryAndCountryCodeList;
        system.assertequals('APAC',CountryAndCountryCodeList.get(0).region__c);
        system.assertequals('LATAM',CountryAndCountryCodeList.get(1).region__c);
        
        Test.startTest();
        system.runas(TestUser)
        {               
            PriceBook2 stdPriceBook = opportunityTestData.createPriceBook();
            //Insert test Opportunity
            List<Opportunity> createOpportunityList = opportunityTestData.CreateOpportunity('assignGeoRegionAndOpptCountry', accountList.get(0).id,
                                                                                            'Products, Services and Maintenance', 2, contactList.get(0).id, stdPriceBook, null, 
                                                                                            null, CountryAndCountryCodeList);
            insert createOpportunityList;
         // system.assertequals(null,createOpportunityList.get(0).Hidden_Opportunity_Region__c);
         // system.assertequals('APAC',createOpportunityList.get(1).Hidden_Opportunity_Region__c);
            
            //Update test Opportunity
            List<Id> createdOpportunityIdList = new List<Id>();
            for(Opportunity objOpportunity :createOpportunityList)
            {
                CreatedOpportunityIdList.add(objOpportunity.Id);
            }
         /*   List<Opportunity> createdOpportunityList = [Select Id, Opporunity_Country__c From Opportunity where 
                                                        id in :CreatedOpportunityIdList];
            for(Opportunity objOpportunity :createdOpportunityList)
            {
                if(objOpportunity.id == createOpportunityList.get(0).id){
                 // system.assertequals('APAC', objOpportunity.Hidden_Opportunity_Region__c);
                    objOpportunity.Opporunity_Country__c = null;
                }
                if(objOpportunity.id == createOpportunityList.get(1).id){
                    //system.assertequals('LATAM', objOpportunity.Hidden_Opportunity_Region__c);    
                    objOpportunity.Opporunity_Country__c = CountryAndCountryCodeList.get(0).Name;
                }    
            }
            update createdOpportunityList;
            
            //verify the updated opportunity
            List<Id> updatedOpportunityIdList = new List<Id>();
            for(Opportunity objOpportunity :createdOpportunityList)
            {
                updatedOpportunityIdList.add(objOpportunity.Id);
            }
            List<Opportunity> updatedOpportunityList = [Select Id, Opporunity_Country__c From Opportunity where 
                                                        id in :updatedOpportunityIdList];
            for(Opportunity objOpportunity :updatedOpportunityList)
            {
                if(objOpportunity.id == createOpportunityList.get(0).id){
                    system.assertequals(null, objOpportunity.Hidden_Opportunity_Region__c);
                }
                if(objOpportunity.id == createOpportunityList.get(1).id){
                    system.assertequals('APAC', objOpportunity.Hidden_Opportunity_Region__c);    
                }    
            }*/
        }
        Test.stopTest();
    }
    
    /*public Static testMethod void SalesComplete()
    {        
        OpportunityTestData opportunityTestData  = new OpportunityTestData();
        //Insert test user
        Profile testProfile=[ select id from profile where Name = 'System Administrator' ];
        User TestUser = opportunityTestData.CreateUser('assignGeoRegionAndOpptCountry', testProfile.id, 'TstOpUsr', null);
        Insert TestUser;
        system.assert(TestUser.id != null);
        
        List<Account> lstAccount = opportunityTestData.CreateAcccount(null,1);
        insert lstAccount;
        System.assert(lstAccount[0].id!=null,'Account Creation Successful');
        
        List<Contact> lstContact =  opportunityTestData.ContactCreation(null,1,lstAccount[0].id);
        insert lstContact;
        System.assert(lstContact[0].id!=null,'Contact Creation Successful');
        
        PriceBook2 stdPriceBook = opportunityTestData.createPriceBook(); 
        
        List<Opportunity> lstOpportunity =  opportunityTestData.CreateOpportunity('salesCompleteCriteria', lstAccount[0].id,
                                                                                  'Products, Services and Maintenance', 1,
                                                                                  lstContact[0].id,stdPriceBook,null,null,null);
        insert lstOpportunity;
        System.assert(lstOpportunity[0].id!=null,'Opportunity Creation Successful');
        
        List<Address__c> lstAccountAddress =  opportunityTestData.CreateAccountAddress(null, 1,lstAccount[0].id);
        insert lstAccountAddress;
        System.assert(lstAccountAddress[0].id!=null,'Account Address Creation Successful');  
        
        List<VCG_CPQ_Quote__c> lstQuote =  opportunityTestData.CreateQuote('salesCompleteCriteria', 1, lstOpportunity[0].id,
                                                                            lstAccountAddress[0].id);
        insert lstQuote;
        System.assert(lstQuote[0].id!=null,'Quote Creation Successful'); 
        
        List<Product2> productList =  opportunityTestData.createProduct('salesCompleteCriteria', 1);
        insert productList;
        System.assert(productList[0].id!=null,'Product Creation Successful'); 
        
        List<VCG_CPQ_Quote_Product__c> lstQuoteProduct =  opportunityTestData.CreateQuoteProduct('salesCompleteCriteria', 1,
                                                                                                  productList[0].id, lstQuote);
        insert lstQuoteProduct;
        System.assert(lstQuoteProduct[0].id!=null,'Quote Product Creation Successful'); 
        
        List<PriceBookEntry> lstPriceBookEntry =  opportunityTestData.createPriceBookEntry('salesCompleteCriteria',1,stdPriceBook,
                                                                                            productList);
        insert lstPriceBookEntry;
        System.assert(lstPriceBookEntry[0].id!=null,'PriceBookEntry Creation Successful'); 
        
        List<OpportunityLineItem> lstOpportunityLineItem =  opportunityTestData.createopportunityLineItem('salesCompleteCriteria', 1,
                                                                                                           lstOpportunity, lstPriceBookEntry);
        insert lstOpportunityLineItem;
        System.assert(lstOpportunityLineItem[0].id!=null,'Opportunity Line Item Creation Successful'); 
        
        List<Opportunity> lstOpportunity2 =[SELECT Id, StageName, Legal_Review__c FROM Opportunity where id= :lstOpportunity];
        
        Test.StartTest(); 
        system.runas(TestUser)
        {
            for(Opportunity objTempOpportunity : lstOpportunity2)  
            {
                objTempOpportunity.StageName='Sales Complete';
                objTempOpportunity.Legal_Review__c ='Waiting for Finance Review';
            }
            try
            {    
                Update lstOpportunity2;
            }
            Catch(Exception e)
            {
                //System.assert(e.getmessage().contains('Cannot change Opportunity Stage. There are missing Shipment Schedules for Products that require them'));  
            }
            
            List<Opportunity> OpportunityListRej =  opportunityTestData.CreateOpportunity(null, lstAccount[0].id,
                                                                                         'Products, Services and Maintenance', 1,
                                                                                         lstContact[0].id,stdPriceBook,null,null,null);
            Insert OpportunityListRej;
            for(Opportunity opp :OpportunityListRej)
            {
                opp.StageName='Sales Complete';
            }                                                                           
            try
            {    
                Update OpportunityListRej;
            }
            Catch(Exception e)
            {
                //System.assert(e.getmessage().contains('An Opportunity must have at least one primary Quote before setting the stage to "Sales Complete"'));  
            }
            
            List<Opportunity> OpportunityListAcc =  opportunityTestData.CreateOpportunity('salesacceptance', lstAccount[0].id,
                                                                                         'Products, Services and Maintenance', 1,
                                                                                          lstContact[0].id,stdPriceBook,null,null,null);
            Insert OpportunityListAcc;
            for(Opportunity opp :OpportunityListAcc)
            {
                opp.StageName='Sales Complete';
            }
            try{                                                                           
                Update OpportunityListAcc;
            }
            Catch(Exception e)
            {
                system.debug(e.getmessage());  
            }
        }
        Test.stopTest();                                                                                                   
    }*/

    public Static testMethod void FinanceApprovalStatus()
    {        
        OpportunityTestData opportunityTestData  = new OpportunityTestData();
        
        //insert test user
        Profile testProfile=[ select id from profile where Name = 'System Administrator' ];
        User TestUser = opportunityTestData.CreateUser('createUpdateAssets', testProfile.id, 'TstOpUsr', null);
        Insert TestUser;
        
        List<Account> lstAccount = opportunityTestData.CreateAcccount(null, 1);
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        //Account lstAccount = new Account(Name='dupe');
        list<Database.SaveResult> sr = Database.insert(lstAccount, dml);
        //insert lstAccount;
        System.assert(lstAccount[0].id!=null,'Account Creation Successful');
        
        List<Contact> lstContact =  opportunityTestData.ContactCreation(null, 1, lstAccount[0].id);        
        insert lstContact;
        System.assert(lstContact[0].id!=null,'Contact Creation Successful');
        
        Test.StartTest();
        System.runAs(TestUser)
        {
            PriceBook2 stdPriceBook = opportunityTestData.createPriceBook(); 
            
            List<Opportunity> lstOpportunity =  opportunityTestData.CreateOpportunity('salesCompleteCriteria', lstAccount[0].id, 
                                                                                      'Products, Services and Maintenance', 2, lstContact[0].id,
                                                                                      stdPriceBook, null, null, null);
            insert lstOpportunity;
            System.assert(lstOpportunity[0].id!=null,'Opportunity Creation Successful');
            System.assert(lstOpportunity[1].id!=null,'Opportunity Creation Successful');         
            
            List<Opportunity> lstOpportunity2 =[SELECT Id, Legal_Review__c, Finance_Status__c FROM Opportunity where id in :lstOpportunity];
            
            for(Opportunity objTempOpportunity : lstOpportunity2)  
            {
                System.assertequals('Initial Review', objTempOpportunity.Legal_Review__c);
                if(objTempOpportunity.id == lstOpportunity.get(0).id)
                    objTempOpportunity.Legal_Review__c ='Contract Data Entry Process';
                if(objTempOpportunity.id == lstOpportunity.get(1).id)
                    objTempOpportunity.Legal_Review__c ='Approved';    
            }
            Update lstOpportunity2;
            
            List<Opportunity> lstOpportunity3 =[SELECT Id, Legal_Review__c, Finance_Status__c FROM Opportunity where id in :lstOpportunity2];                                                
            
            for(Opportunity objTempOpportunity : lstOpportunity3)  
            {
                if(objTempOpportunity.id == lstOpportunity.get(0).id)
                {
                    System.assertequals('Contract Data Entry Process', objTempOpportunity.Legal_Review__c);
                    System.assertequals('Needs Review', objTempOpportunity.Finance_Status__c);
                }
                if(objTempOpportunity.id == lstOpportunity.get(1).id)
                {
                    System.assertequals('Approved', objTempOpportunity.Legal_Review__c);
                    System.assertequals('Needs Review', objTempOpportunity.Finance_Status__c);
                }
            }
        }
        Test.StopTest();  
    }
    
    public Static testMethod void DeleteQuote()
    {
        List<Opportunity> lstOpportunity1;
        List<Opportunity> lstOpportunity;
        List<Account> lstAccount;
        List<Account> lstAccount1;
        List<Contact> lstContact;
        List<Contact> lstContact1;
        List<VCG_CPQ_Quote__c> lstQuote;
        List<VCG_CPQ_Quote__c> lstQuote1;
        List<Address__c> lstAccountAddress;
        List<Address__c> lstAccountAddress1;
        
        OpportunityTestData opportunityTestData  = new OpportunityTestData();
        
        lstAccount = opportunityTestData.CreateAcccount(null,3);
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        //Account lstAccount = new Account(Name='dupe');
        list<Database.SaveResult> sr = Database.insert(lstAccount, dml);
        
        //insert lstAccount;
        lstAccount1 = [Select id, name from Account where id = :lstAccount];
        System.assert(lstAccount1[0].id!=null,'Account Creation Successful');
        
        lstContact =  opportunityTestData.ContactCreation(null,3,lstAccount[0].id);
        insert lstContact;
        lstContact1 = [Select id, name from Contact where id = :lstContact];
        System.assert(lstContact1[0].id!=null,'Contact Creation Successful');
        
        PriceBook2 stdPriceBook = opportunityTestData.createPriceBook(); 
        
        lstOpportunity =  opportunityTestData.CreateOpportunity('', lstAccount[0].id,'Products, Services and Maintenance',3,lstContact[0].id,stdPriceBook,null,null,null);
        insert lstOpportunity;
        lstOpportunity1 = [Select id, name , StageName, OwnerId from Opportunity where id = : lstOpportunity];
        System.assert(lstOpportunity1[0].id!=null,'Opportunity Creation Successful');
        
        lstAccountAddress =  opportunityTestData.CreateAccountAddress(null,3,lstAccount[0].id);
        insert lstAccountAddress;
        lstAccountAddress1 = [Select id from Address__c where id = : lstAccountAddress ];
        System.assert(lstAccountAddress1[0].id!=null,'Account Address Creation Successful'); 
        
        lstQuote =  opportunityTestData.CreateQuote('salesCompleteCriteria',3,lstOpportunity[0].id,lstAccountAddress[0].id);
        insert lstQuote;
        lstQuote1 = [Select Id, Is_Primary__c, Opportunity__c from VCG_CPQ_Quote__c where id = : lstQuote];
        System.assert(lstQuote1[0].id!=null,'Quote Creation Successful'); 
        System.debug('@@@@@@@@@@@lstQuote1'+lstQuote1);
        
        delete lstOpportunity;
    }
        
    /*public Static testMethod void cloningValidation()
    {        
        OpportunityTestData opportunityTestData  = new OpportunityTestData();
        //insert test user
        Profile testProfile=[ select id from profile where Name = 'System Administrator' ];
        User TestUser = opportunityTestData.CreateUser('cloningValidation', testProfile.id, 'TstOpUsr', null);
        Insert TestUser;
        //insert Account
        List<Account> accountList = opportunityTestData.CreateAcccount('cloningValidation', 1);
        insert accountList;
        //Insert Contact
        List<Contact> contactList =  opportunityTestData.ContactCreation('cloningValidation', 1, accountList.get(0).id);
        insert contactList;
        
        Test.startTest();   
        System.runAs(TestUser)
        {
            PriceBook2 stdPriceBook = opportunityTestData.createPriceBook();
            //Insert Opportunity
            List<Opportunity> createOpportunityList = opportunityTestData.CreateOpportunity('cloningValidation', accountList.get(0).id,
                                                                                            'Products, Services and Maintenance', 1, contactList.get(0).id, stdPriceBook, null, null, null);
         // createOpportunityList.get(0).Terms_Requested_Status__c = 'Approved';
         // createOpportunityList.get(0).Terms_Requested__c = true;
            
            try{
                Insert createOpportunityList;
            }
            catch(Exception e)
            {
                //Error message should be displayed as Terms_Requested_Status and Terms_Requested should not be set
                //during asset creation
                system.assert(e.getmessage().contains('This field needs to be blank if cloning an opportunity'));
            }
            //reset those two fields
         // createOpportunityList.get(0).Terms_Requested_Status__c = null;
         // createOpportunityList.get(0).Terms_Requested__c = false;
            //set Se Approval and current Se field
        //  createOpportunityList.get(0).Se_Approval__c = true;
            createOpportunityList.get(0).current_se__c = TestUser.id;
            
            Insert createOpportunityList;
            
            List<Opportunity> createdOpportunityList = [select id,current_se__c from Opportunity where id in :createOpportunityList];
            //Se Approval field should be reset after insertion
         // system.assertequals(false, createdOpportunityList.get(0).Se_Approval__c);
            //current Se field should be reset after insertion
            system.assertequals(null, createdOpportunityList.get(0).current_se__c);
        }
        Test.stopTest();    
    }*/
    
    /*public Static testMethod void depositPending()
    {            
        OpportunityTestData opportunityTestData  = new OpportunityTestData();
        
        //Insert test user
        Profile testProfile=[ select id from profile where Name = 'System Administrator' ];
        User TestUser = opportunityTestData.CreateUser('depositPending', testProfile.id, 'TstOpUsr', null);
        Insert TestUser;
        system.assert(TestUser.id != null);
        
        List<Account> lstAccount = opportunityTestData.CreateAcccount('depositPending',1);
        insert lstAccount;
        System.assert(lstAccount[0].id!=null,'Account Creation Successful');
        
        List<Contact> lstContact =  opportunityTestData.ContactCreation('depositPending',1,lstAccount[0].id);
        insert lstContact;
        System.assert(lstContact[0].id!=null,'Contact Creation Successful');
        
        Test.StartTest();
        system.runAs(TestUser)
        {
            PriceBook2 stdPriceBook = opportunityTestData.createPriceBook(); 
            
            List<Opportunity> lstOpportunity =  opportunityTestData.CreateOpportunity('depositPending', lstAccount[0].id,
                                                                                      'Products, Services and Maintenance', 1, lstContact[0].id,stdPriceBook, null, null, null);
            insert lstOpportunity;       
            System.assert(lstOpportunity[0].id!=null,'Opportunity Creation Successful');
            
            List<Opportunity> lstOpportunity2 =[SELECT Id, Name, StageName FROM Opportunity where 
                                                id in :lstOpportunity];                                                         
            for(Opportunity objTempOpportunity : lstOpportunity2)  
            {
                System.assertequals('Prove', objTempOpportunity.StageName);
             // System.assertequals(null, objTempOpportunity.Deposit_Pending_To_Pending_Date__c);
                objTempOpportunity.StageName='Closed - Won';
            }    
            Update lstOpportunity2;
            
            List<Opportunity> lstOpportunity3 =[SELECT Id, Name, StageName FROM Opportunity 
                                                where id in :lstOpportunity2];
            for(Opportunity objTempOpportunity : lstOpportunity3)
            {
                System.assertequals('Closed - Won', objTempOpportunity.StageName);
             // System.assertequals(date.today(), objTempOpportunity.Deposit_Pending_To_Pending_Date__c);
            }              
            
        }
        Test.StopTest();                                                
    }*/
    
    static TestMethod void testCreateandUpdateOpptyContactRole()
    {                  
        
        OpportunityTestData  opportunityTestData  = new OpportunityTestData();
        List<Account> accountList = opportunityTestData.CreateAcccount('test',2);
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        //Account lstAccount = new Account(Name='dupe');
        list<Database.SaveResult> sr = Database.insert(accountList, dml);
        //insert accountList;
        
        List<Contact> contactList =  opportunityTestData.ContactCreation('test',2, accountList.get(0).id);
        insert contactList;
        
        PriceBook2 stdPriceBook = [Select Id, Name from PriceBook2 where isStandard = true];
        
        List<Opportunity> opportunityList =  opportunityTestData.CreateOpportunity('test',accountList.get(0).id,'Products, Services and Maintenance',2,contactList.get(0).id,stdPriceBook,null,null,null);
        insert opportunityList; 
        system.assertNotEquals(null, opportunityList.size());
        
        List<OpportunityContactRole> opportunityContactRoleList =  opportunityTestData.CreateOpportunityContactRole('test',opportunityList.get(0).id, 1,opportunityList.get(0).Primary_Contact__c);
        insert opportunityContactRoleList;
        system.assertNotEquals(null, opportunityContactRoleList.size());
        
        List<Product2> productList =  opportunityTestData.createProduct('test',1);
        insert productList;
        
        List<PriceBookEntry> pbEntry = opportunityTestData.createPriceBookEntry('test', 1, stdPriceBook, productList);
        insert pbEntry;
        
        /*List<OpportunityLineItem> oli = opportunityTestData.createopportunityLineItem('test', 1, opportunityList,pbEntry);
        insert oli;
        
        Test.startTest();
        
        opportunityList.get(0).StageName ='Closed lost';
        opportunityList.get(0).Reason_Lost_Comments__c ='test lost';
        opportunityList.get(0).AccountId = accountList.get(0).id; 
        update opportunityList;
        system.assertEquals(accountList.get(0).id,opportunityList.get(0).AccountId);
        
        opportunityContactRoleList.get(0).IsPrimary = TRUE;
        update opportunityContactRoleList;
        
        OpportunityLineItem oliObj = [SELECT Id, OpportunityId from OpportunityLineItem WHERE OpportunityId =: opportunityList.get(0).id];
        oliObj.Software_to_Omni__c = opportunityList.get(0).ups_of_total_sw__c; 
        update oliObj;        
        Test.stopTest();*/ 
        
    }
    /*static TestMethod void testOpptyProductandCampaign()
    {
        
        OpportunityTestData  opportunityTestData  = new OpportunityTestData();
        
        List<Account> accountList = opportunityTestData.CreateAcccount('test',2);
        insert accountList;
        
        List<Contact> contactList =  opportunityTestData.ContactCreation('test',2, accountList.get(0).id);
        insert contactList;
        
        PriceBook2 stdPriceBook = [Select Id, Name from PriceBook2 where isStandard = true];
        
        List<Campaign> campaignList = opportunityTestData.CreateCampaign('test',1);
        insert  campaignList;
        
        List<Opportunity> opportunityList =  opportunityTestData.CreateOpportunity('test',accountList.get(0).id,'Products, Services and Maintenance',2,contactList.get(0).id,stdPriceBook,null,null,null);
        insert opportunityList;
        system.assertNotEquals(null, opportunityList.size());
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunityList.get(0), accountList.get(0), Date.today(), true);
        
        opportunityList.get(0).SBQQ__PrimaryQuote__c = sbQuote.Id;
        opportunityList.get(0).stagename = 'Closed Won';   
        opportunityList.get(0).Primary_Contact__c = contactList.get(0).id;
        opportunityList.get(0).Role__c = 'Sponsor';
        opportunityList.get(0).campaignId = campaignList.get(0).id;
        
        Test.startTest();
        
        update opportunityList;
        system.assertEquals(campaignList.get(0).id, opportunityList.get(0).campaignId);
        system.assertNotEquals(null, campaignList.size());
        
        update campaignList;
        Delete opportunityList;
        Test.stopTest();
    }*/
    static TestMethod void testHandleOpptyClosure()
    {
        
        OpportunityTestData  opportunityTestData  = new OpportunityTestData(); 
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        PriceBook2 stdPriceBook = [Select Id, Name from PriceBook2 where isStandard = true];
        
        List<Account> accountList = opportunityTestData.CreateAcccount('test',2);
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        //Account lstAccount = new Account(Name='dupe');
        list<Database.SaveResult> sr = Database.insert(accountList, dml);
        //insert accountList;
        
        List<Contact> contactList =  opportunityTestData.ContactCreation('test',2, accountList.get(0).id);
        insert contactList;
        
        List<Opportunity> opportunityList =  opportunityTestData.CreateOpportunity('Closedlost',accountList.get(0).id,'Products, Services and Maintenance',2,contactList.get(0).id,stdPriceBook,null,null,null);
        insert opportunityList;
        
        User u = opportunityTestData.CreateUser('test', p.id, 'usrOmni', null);
        insert u;
        
        Test.startTest();
        opportunityList.get(0).stagename = 'Closed lost';
        opportunityList.get(0).Reason_Lost_Comments__c ='test lost';
        update opportunityList;
        
        opportunityList.get(0).ownerId = u.id;
        update opportunityList;
        
        system.assertEquals('Closed lost', opportunityList.get(0).stagename);
        Test.stopTest();
    }
    /* till here */
    // For SPValidation Method
    Public Static testMethod void SalesPlanNonExcemtedUser()
    {
        OpportunityTestData  opportunityTestData  = new OpportunityTestData();
        PriceBook2 stdPriceBook = opportunityTestData.createPriceBook();
        String SPErrorMessage = 'You cannot advance this Opportunity until all required Sales Plan actions have been completed';
        String ExceptionMessage;
        List<Opportunity> lstOpportunity1;
        List<Opportunity> lstOpportunity;
        List<User> lstUser = new List<User>();
        List<User> lstUser1;
        List<Account> lstAccount;
        List<Account> lstAccount1;
        List<Contact> lstContact;
        List<Contact> lstContact1;
        List<Task> lstTask= new List<Task>();
        User Usr;
        
        
        List<Profile> lstprofile= ([select name,id from profile where name = 'CS Contract']);                
        if(!lstprofile.isEmpty())
        {   
            Usr = new User();
            Usr = opportunityTestData.CreateUser(null,lstprofile[0].Id,'ExmpUsr',null);
            lstUser.add(Usr);
            //System.debug('@@@@@User Details');
        }
        
        if(!lstUser.isEmpty())
        {
            try
            {
                Insert lstUser;
            }
            Catch(Exception e)
            {
                //System.debug('Exception e'+e.getMessage());
            }
        }
        if(!lstUser.isEmpty()) 
        {       
            lstUser1 = [Select id, name from User where id =: lstUser];  
            System.assert(lstUser1.size()!=0,'USER CREATION');
            
            System.runAs(lstUser1[0])
            {
                lstAccount = opportunityTestData.CreateAcccount(null,1);
                Database.DMLOptions dml = new Database.DMLOptions(); 
        		dml.DuplicateRuleHeader.allowSave = true;
        		dml.DuplicateRuleHeader.runAsCurrentUser = true;
       			//Account lstAccount = new Account(Name='dupe');
       			list<Database.SaveResult> sr = Database.insert(lstAccount, dml);
                //insert lstAccount;
                lstAccount1 = [Select id, name from Account where id = :lstAccount];
                System.assert(lstAccount1[0].id!=null,'Account Creation');
                
                lstContact =  opportunityTestData.ContactCreation(null,1, lstAccount[0].id);
                insert lstContact;
                lstContact1 = [Select id, name from Contact where id = :lstContact];
                System.assert(lstContact1[0].id!=null,'Contact Creation');
                
                lstOpportunity =  opportunityTestData.CreateOpportunity(null, lstAccount[0].id,'Products, Services and Maintenance',1,lstContact[0].id,stdPriceBook,null,null,null);
                insert lstOpportunity;
                System.assert(lstOpportunity[0].id!=null,'Opportunity Creation');
                
                lstOpportunity1 = [Select id, name , StageName, OwnerId from Opportunity where id = : lstOpportunity];
                System.assert(!lstOpportunity1.isEmpty(),'Opportunity Creation');
                System.assertEquals(lstOpportunity1[0].stagename,'Prove','Stage Name');
                System.assertEquals(lstOpportunity1[0].OwnerId,lstUser1[0].Id,'Non Excemped Owner');
                
                
                Test.startTest(); 
                for(Opportunity objOpp : lstOpportunity1)
                {
                    objOpp.StageName='Qualify';
                }
                try
                {
                    Update lstOpportunity1;
                }
                Catch(Exception e)
                {
                    ExceptionMessage='';
                    //System.debug('Exception e'+e.getMessage());
                    ExceptionMessage = e.getMessage();
                    System.assert(ExceptionMessage.contains(SPErrorMessage),'Sales Plan Validation Message' +ExceptionMessage);
                }
                
            }
            lstOpportunity1 = [Select id, name , StageName, OwnerId, Type, Order_Type__c, Order_Sub_Type__c from Opportunity where id =: lstOpportunity];
            //System.debug('lstOpportunity1 !!!!!!'+lstOpportunity1);
            System.assert(lstOpportunity1[0].id == lstOpportunity[0].id, 'Opportunity Id');
            
            String oppType = 'Existing Customer';
            String oppOrderType ='New;Migration';
            String oppOrderSubType = 'Dummy;Value';
            /* 
System.debug('oppType !!!!!!'+oppType);
System.debug('oppOrderType !!!!!'+oppOrderType);
System.debug('oppOrderSubType !!!!!'+oppOrderSubType);
System.debug('Stage !!!!!'+lstOpportunity1[0].StageName); 
*/ 
            /*List<Objective_Action__c> lstObjectiveAction = [SELECT Id, Name, Opportunity_Type__c, Opportunity_Order_Type__c, Opportunity_Order_SubType__c, Effective_Date__c, Exempt_Profiles__c, Exempt_Users__c, 
Exempt_Products__c, Stage_Objective__c FROM Objective_Action__c WHERE Stage_Name__c = :lstOpportunity1[0].StageName
AND Action_Type__c = 'Required' AND (Stage_Objective__r.Opportunity_Type__c = : oppType
OR Stage_Objective__r.Opportunity_Order_Type__c = : oppOrderType
OR Stage_Objective__r.Opportunity_Order_SubType__c = :oppOrderSubType) LIMIT 50000];
*/
            List<Objective_Action__c> lstObjectiveAction = [SELECT Id, Name, Opportunity_Type__c, Opportunity_Order_Type__c, Opportunity_Order_SubType__c, Effective_Date__c, Exempt_Profiles__c, Exempt_Users__c, 
                                                            Exempt_Products__c, Stage_Objective__c FROM Objective_Action__c WHERE Stage_Name__c = :lstOpportunity1[0].StageName and Action_Type__c = 'Required'];
            
            if(!lstObjectiveAction.isEmpty())
            {                                                
                System.runAs(lstUser1[0])
                {
                    /* 
System.assert(lstOpportunity1[0].StageName == 'Sales Acceptance',lstOpportunity1[0].StageName );
System.debug('lstObjectiveAction !!!!!'+lstObjectiveAction);
System.debug('lstOpportunity1[0].Id !!!!!'+lstOpportunity1[0].Id);
System.debug('lstObjectiveAction[0].Id !!!!!'+lstObjectiveAction[0].Id);
System.debug('lstOpportunity1[0].StageName !!!!!'+lstOpportunity1[0].StageName);
System.debug('lstObjectiveAction[0].Stage_Objective__c !!!!!'+lstObjectiveAction[0].Stage_Objective__c);
*/   
                    task reqTask;
                    for(Integer i=0;i<lstObjectiveAction.size();i++)
                    {
                        reqTask= new task();
                        reqTask.WhatId = lstOpportunity1[0].Id;
                        reqTask.ObjectiveActionID__c=lstObjectiveAction[i].Id;
                        reqTask.Related_Stage__c =lstOpportunity1[0].StageName; 
                        reqTask.StageObjectiveID__c =lstObjectiveAction[i].Stage_Objective__c;
                        reqTask.whoId=lstContact[0].Id;
                        reqTask.Status= 'Completed';
                        lstTask.add(reqTask);
                    }
                    
                    Insert lstTask;
                    
                    //reqTask.ISclosed= TRUE;
                    //task reqTask1=[Select id, isClosed,ObjectiveActionID__c,Related_Stage__c,StageObjectiveID__c from task where id = :reqTask.Id ];
                    List<Task> lstCompletedAction = [SELECT Id, ObjectiveActionID__c,whatId FROM Task WHERE WhatId = :lstOpportunity1[0].Id
                                                     AND StageObjectiveID__c != null AND ObjectiveActionID__c != null AND IsClosed = true];
                    System.debug('lstCompletedAction !!!!!'+lstCompletedAction);
                    //System.debug('reqTask1 !!!!!'+reqTask1);  
                    
                    String taskOppID = lstCompletedAction[0].whatId;
                    System.assertEquals(taskOppID, lstOpportunity1[0].Id,'Opportunity Task');
                    System.assert(lstCompletedAction.size()>0,'Completed Task');
                    //System.assert(reqTask1.Id!=null,'Task Created');
                    //System.assert(reqTask1.isClosed==TRUE,'Task Not Closed');
                    System.assert(lstOpportunity1.size()==1,'Size not 1');
                    //System.debug('lstOpportunity1'+lstOpportunity1);
                    
                    for(Opportunity objOpp : lstOpportunity1)
                    {
                        objOpp.StageName='Qualify';
                    }
                    try
                    {
                        Update lstOpportunity1;
                    }
                    Catch(Exception e)
                    {
                        ExceptionMessage='';
                        System.assert(False,'Exception for update '+e.getMessage());
                        //System.debug('Exception e'+e.getMessage());
                        ExceptionMessage = e.getMessage();
                    }
                    if(lstOpportunity1.isEmpty())
                    {
                        lstOpportunity = [Select id, name , StageName, OwnerId from Opportunity where id = : lstOpportunity1];
                        System.assert(lstOpportunity1[0].StageName=='Qualify','Stage not changed');
                    }
                    
                }     
            }
            Test.stopTest();
        }
    }
    
    
    /*// For checkForPrimaryContactRolesIfStageNegotiateLost,  Method
    Public Static testMethod void checkForPrimaryContactRolesIfStageNegotiateLostTest()
    {
        OpportunityTestData  opportunityTestData  = new OpportunityTestData();
        PriceBook2 stdPriceBook = opportunityTestData.createPriceBook();
        String ErrorNoPrimaryContact='You must specify a primary contact role for this opportunity';
        String ErrorNoPrimaryContactRole = 'You must specify a role';
        List<Opportunity> lstOpportunity1;
        List<Opportunity> lstOpportunity;
        List<User> lstUser = new List<User>();
        List<User> lstUser1;
        List<Account> lstAccount;
        List<Account> lstAccount1;
        List<Contact> lstContact;
        List<Contact> lstContact1;
        List<Case> lstCase;
        List<OpportunityContactRole> lstOpportunityContactRole;
        User Usr;
        String ExceptionMessage='';
        
        List<Profile> lstprofile= ([select name,id from profile where name = 'CNR Finance']);                
        if(!lstprofile.isEmpty())
        {   
            Usr = new User();
            Usr = opportunityTestData.CreateUser('BURoadnet',lstprofile[0].Id,'RoadNtBU',null);
            lstUser.add(Usr);
        }
        
        if(!lstUser.isEmpty())
        {   
            try
            {
                Insert lstUser;
            }
            Catch(Exception e)
            {
                System.debug('Exception e'+e.getMessage());
                System.assert(False,e.getMessage());
            }
            lstUser1 = [Select id, name, Business_Unit__c from User where id =: lstUser];  
            System.assert(lstUser1[0].Business_Unit__c=='Roadnet','User not of Roadnet');
        }
        if(!lstUser1.isEmpty())
        {    
            //System.assert(false,lstUser1[0].Id);
            System.runAs(lstUser1[0])
            {
                lstCase = opportunityTestData.CreateCase(null,1);
                Insert lstCase;
                System.assert(lstCase[0].Id!=null,'Case Creation');
                
                lstAccount = opportunityTestData.CreateAcccount('Roadnet',1);
                insert lstAccount;
                lstAccount1 = [Select id, name,BillingCountry,ShippingCountry from Account where id = :lstAccount];
                System.assert(lstAccount1[0].id!=null,'Account Creation');
                
                lstContact =  opportunityTestData.ContactCreation(null,1, lstAccount[0].id);
                insert lstContact;
                lstContact1 = [Select id, name from Contact where id = :lstContact];
                System.assert(lstContact1[0].id!=null,'Contact Creation');
                
                // No Primary Role and Contact
                lstOpportunity =  opportunityTestData.CreateOpportunity('NoPrimary', lstAccount[0].id,'Products, Services and Maintenance',1,lstContact[0].id,stdPriceBook,lstCase[0].Id, null,null);
                try
                {
                    Insert lstOpportunity;
                }
                Catch(Exception e)
                {
                    ExceptionMessage=e.getMessage();
                }
                //System.assert(ExceptionMessage.contains(ErrorNoPrimaryContact),'primary contact role present');
                
                // No Primary Contact Role
                lstOpportunity = opportunityTestData.CreateOpportunity('NoPrimaryContactRole', lstAccount[0].id,'Products, Services and Maintenance',1,lstContact[0].id,stdPriceBook,lstCase[0].Id, null,null);
                try
                {
                    Insert lstOpportunity;
                }
                Catch(Exception e)
                {
                    ExceptionMessage=e.getMessage();
                }
               // System.assert(ExceptionMessage.contains(ErrorNoPrimaryContactRole),'primary contact role present');
                
                //No Primary Contact
                lstOpportunity = opportunityTestData.CreateOpportunity('NoPrimaryContact', lstAccount[0].id,'Products, Services and Maintenance',1,lstContact[0].id,stdPriceBook,lstCase[0].Id,null,null);
                try
                {
                    Insert lstOpportunity;
                }
                Catch(Exception e)
                {
                    ExceptionMessage=e.getMessage();
                }
                //System.assert(ExceptionMessage.contains(ErrorNoPrimaryContact),'primary contact role present');
                
                
                for(Account objAccount : lstAccount1 )
                {
                    objAccount.BillingCountry='united states';
                    objAccount.ShippingCountry=null;
                }            
                Update lstAccount1;
                
                try
                {
                    Insert lstOpportunity;
                }
                Catch(Exception e)
                {
                    ExceptionMessage=e.getMessage();
                }
                
                
                // With Case is_case_being_upgraded__c = True
                for(Case objCase: lstCase)
                {
                    ObjCase.is_case_being_upgraded__c=True;
                }
                Update lstCase;
                
                try
                {
                    Insert lstOpportunity;
                }
                Catch(Exception e)
                {
                    ExceptionMessage=e.getMessage();
                }
                
                
                lstOpportunity = opportunityTestData.CreateOpportunity(null, lstAccount[0].id,'Products, Services and Maintenance',1,lstContact[0].id,stdPriceBook,lstCase[0].Id,null,null);
                Insert lstOpportunity;
                
                lstOpportunity1=[Select id, name , Role__c ,Primary_Contact__c  , Case__c from Opportunity where id in :lstOpportunity];
                lstOpportunity.clear();
                lstOpportunity.addAll(lstOpportunity1);
               // System.assert(!lstOpportunity1.isEmpty(), 'Opportunity Insertion Failed');
                
                // Insert Contact Role but not Primary.
                lstOpportunityContactRole = opportunityTestData.CreateOpportunityContactRole(null, lstOpportunity1[0].Id, 1, lstContact[0].Id);
                Insert lstOpportunityContactRole;
                
                // Nullify Case and try updating
                for(Opportunity objOpportunity : lstOpportunity1)
                {
                    objOpportunity.Case__c=null;
                }
                
                try
                {
                    Update lstOpportunity1;
                }
                Catch(Exception e)
                {
                    ExceptionMessage=e.getMessage();
                }
                //System.assert(ExceptionMessage.contains(ErrorNoPrimaryContact),'primary contact role present');
                
                lstOpportunity1.clear();
                lstOpportunity1.addAll(lstOpportunity);
                
                for(OpportunityContactRole objOpportunityContactRole : lstOpportunityContactRole)
                {
                    objOpportunityContactRole.isPrimary= TRUE;
                }
                Update lstOpportunityContactRole;
                
                for(Opportunity objOpportunity : lstOpportunity1)
                {
                    objOpportunity.Primary_Contact__c=null;
                    objOpportunity.Role__c = null;
                }
                Update lstOpportunity1;
                
            }
        }
    }*/
    
    // For updateOpptAmountMc,assignSalesTeamManagerAndDarManager, TIS
    Public Static testmethod void assignSalesTeamManagerAndDarManagerTest()
    {
        OpportunityTestData  opportunityTestData  = new OpportunityTestData();
        PriceBook2 stdPriceBook = opportunityTestData.createPriceBook();
        id loggedInUserId = UserInfo.getUserId();
        String loggedInUserName = UserInfo.getName();
        List<Opportunity> lstOpportunity1;
        List<Opportunity> lstOpportunity;
        List<User> lstUser = new List<User>();
        List<User> lstUser1;
        List<Account> lstAccount;
        List<Account> lstAccount1;
        List<Contact> lstContact;
        List<Contact> lstContact1;
        List<Case> lstCase;
        List<OpportunityContactRole> lstOpportunityContactRole;
        User Usr;
        
        List<Profile> lstprofile= ([select name,id from profile where name LIKE '%Sales%' Limit 1]);  
        
        if(!lstprofile.isEmpty())
        {   
            Usr = new User();
            Usr = opportunityTestData.CreateUser('BURoadnet',lstprofile[0].Id,'RoadNtBU',null);
            Usr.ManagerId =loggedInUserId;
            lstUser.add(Usr);
        }
        
        if(!lstUser.isEmpty())
        {   
            try
            {
                Insert lstUser;
            }
            Catch(Exception e)
            {
                System.debug('Exception e'+e.getMessage());
                System.assert(False,e.getMessage());
            }
            lstUser1 = [Select id, name, Business_Unit__c from User where id =: lstUser];  
            System.assert(lstUser1[0].Business_Unit__c=='Roadnet','User not of Roadnet');
        }
        
        System.runAs(lstUser[0])
        {
            lstAccount = opportunityTestData.CreateAcccount(null,1);
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
        	dml.DuplicateRuleHeader.runAsCurrentUser = true;
        	//Account lstAccount = new Account(Name='dupe');
        	list<Database.SaveResult> sr = Database.insert(lstAccount, dml);
            //insert lstAccount;
            lstAccount1 = [Select id, name from Account where id = :lstAccount];
            System.assert(lstAccount1[0].id!=null,'Account Creation');
            
            lstContact =  opportunityTestData.ContactCreation(null,1, lstAccount[0].id);
            insert lstContact;
            lstContact1 = [Select id, name from Contact where id = :lstContact];
            System.assert(lstContact1[0].id!=null,'Contact Creation');
            
            lstOpportunity =  opportunityTestData.CreateOpportunity(null, lstAccount[0].id,'Partner Opportunity (Reseller)',1,lstContact[0].id,stdPriceBook,null,null,null);
            // For Method : updateOpptAmountMc
            for(Opportunity objOpp : lstOpportunity)
            {
                objOpp.Editable_Opportunity_Qty__c=2;
            //    objOpp.Subscription_arpu__c=5;
           //   objOpp.Hardware_Unit_Price__c = 10;
            }
            insert lstOpportunity;
            System.assert(lstOpportunity[0].id!=null,'Opportunity Creation');
          //  lstOpportunity1= [Select id, name,Opportunity_Amount_MC__c,sales_team_manager__c from opportunity where id =: lstOpportunity];
          //  System.assert((lstOpportunity1[0].Sales_Team_Manager__c == loggedInUserName),'Opportunity Owners Manager is not same as Opportunity Sales_Team_Manager__c');    
         // System.assert((lstOpportunity1[0].Opportunity_Amount_MC__c==140),'Editable_Opportunity_Qty__c*(Subscription_arpu__c*12)+Hardware_Unit_Price__c [2*(5*12+10) = 140] '+lstOpportunity1[0].Opportunity_Amount_MC__c);    
            
        }
        
        /*lstUser1 =[Select id, name from User where id= : RoadnetSalesManager__c.getInstance('Brian Callahan').UserId__c];
        
        System.runAs(lstUser1[0])
        {
            lstAccount = opportunityTestData.CreateAcccount(null,1);
            insert lstAccount;
            lstAccount1 = [Select id, name from Account where id = :lstAccount];
            System.assert(lstAccount1[0].id!=null,'Account Creation');
            test.startTest();
            lstContact =  opportunityTestData.ContactCreation(null,1, lstAccount[0].id);
            insert lstContact;
            test.stopTest();
            lstContact1 = [Select id, name from Contact where id = :lstContact];
            System.assert(lstContact1[0].id!=null,'Contact Creation');
            
            lstOpportunity =  opportunityTestData.CreateOpportunity(null, lstAccount[0].id,'Products, Services and Maintenance',1,lstContact[0].id,stdPriceBook,null,null,null);
            insert lstOpportunity;
            System.assert(lstOpportunity[0].id!=null,'Opportunity Creation');
            lstOpportunity1= [Select id, name, Sales_Team_Manager__c from opportunity where id =: lstOpportunity];
            
            System.assert(lstOpportunity1[0].Sales_Team_Manager__c == lstUser1[0].Name,'Opportunity Owners Manager is not same as '+RoadnetSalesManager__c.getInstance('Brian Callahan').UserId__c);    
            
        }*/
        
        //lstOpportunity1[0].OwnerId=loggedInUserId; // Update TIS Scenario
        //lstOpportunity1[0].Stage_Reversal_Approval_Status__c ='Rejected';
        //Update lstOpportunity1;
        
    }
    
}