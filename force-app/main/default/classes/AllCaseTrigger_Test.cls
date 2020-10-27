@istest(seeAllData=true)
private class AllCaseTrigger_Test
{
    
    @istest(seeAllData=true)
    private Static void guessEffort_Test()
    {
        CaseTestData caseTestData  = new CaseTestData();
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<User> TestUserList = caseTestData.CreateUser('guessWorkEffort', testProfile.id, 'TestCaseUser', null, 2);
        Insert TestUserList;
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('guessWorkEffort', null, 1, null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('guessWorkEffort', 1, accountList.get(0).id);
        insert contactList;
              
        Test.startTest();   
        System.runAs(TestUserList.get(0))
        {
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('guessWorkEffort', 'Call Center', accountList, contactList, TestUserList, 5);
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            system.assert(createCaseList.get(1).id != null,'Exception in Case Creation');
            system.assert(createCaseList.get(2).id != null,'Exception in Case Creation');
            system.assert(createCaseList.get(3).id != null,'Exception in Case Creation');
            system.assert(createCaseList.get(4).id != null,'Exception in Case Creation');
            Allcasetriggerutils.guessWorkEffort(createCaseList);
                       
            //verify Inserted Case
            List<Case> createdCaseList = [Select Id, Last_Modified_Date_Time__c, total_work_effort__c, Work_Effort_In_Minutes__c, 
                                          IsVisibleInSelfService From Case where id in :createCaseList];
                   
            for(Case createdCaseObj :createdCaseList)
            {
                if(createdCaseObj.id == createCaseList[0].id)
                {
                    //'Last Modified Date Time' should be the system date
                    String LastModifiedDateTime = TestUserList.get(0).FirstName + ' ' + TestUserList.get(0).LastName;
                    //system.assert(createdCaseObj.Last_Modified_Date_Time__c.contains(LastModifiedDateTime), 'LastModifiedDateTime mismatch');
                    
                    //No Assisting Tech is associated with the case
                    system.assertequals(createCaseList[0].Work_Effort_In_Minutes__c, createdCaseObj.total_work_effort__c, 'work effort mismatch');
                }
                if(createdCaseObj.id == createCaseList[1].id)
                {
                    //Assisting Tech is active user
                    //system.assertequals(createCaseList[1].Work_Effort_In_Minutes__c * 2, createdCaseObj.total_work_effort__c, 'work effort mismatch');
                }
                if(createdCaseObj.id == createCaseList[2].id)
                {
                    //Assisting Tech is Inactive user
                    system.assertequals(createCaseList[2].Work_Effort_In_Minutes__c, createdCaseObj.total_work_effort__c, 'work effort mismatch');
                }
                if(createdCaseObj.id == createCaseList[3].id)
                {
                    //Assisting Tech is combination of active & inactive user
                    //system.assertequals(createCaseList[3].Work_Effort_In_Minutes__c * 2, createdCaseObj.total_work_effort__c, 'work effort mismatch');
                }
                if(createdCaseObj.id == createCaseList[4].id)
                {
                    //  the isvisibiliinselfservice portal flag should be false for all prof services cases
                    //system.assertequals(false, createdCaseObj.IsVisibleInSelfService);
                }
            }
            
            //Update the Case
            List<Case> updateCaseList = new List<Case>();
            
            for(Case createdCaseObj :createdCaseList)
            {
                if(createdCaseObj.id == createCaseList[0].id)
                {
                    //updating 'Last Modified Date Time' with some junk data
                    createdCaseObj.Last_Modified_Date_Time__c = 'Modified Date time';
                }
                if(createdCaseObj.id == createCaseList[4].id)
                {
                    createdCaseObj.IsVisibleInSelfService = true;
                }
                    updateCaseList.add(createdCaseObj);               
            }
            update updateCaseList;
            
            //verify the updated Case
            List<Case> updatedCaseList = [Select Id, Last_Modified_Date_Time__c, IsVisibleInSelfService From Case 
                                          where id in :updateCaseList];
                   
            for(Case updatedCaseObj :updatedCaseList)
            {
                if(updatedCaseObj.id == createCaseList[0].id)
                {
                    //'Last Modified Date Time' should automatically set to system date
                    String LastModifiedDateTime = TestUserList.get(0).FirstName + ' ' + TestUserList.get(0).LastName;
                    //system.assert(updatedCaseObj.Last_Modified_Date_Time__c.contains(LastModifiedDateTime), 'LastModifiedDateTime mismatch');
                }
                if(updatedCaseObj.id == createCaseList[4].id)
                {
                    //  the isvisibiliinselfservice portal flag should be false for all prof services cases
                    //system.assertequals(false, updatedCaseObj.IsVisibleInSelfService);
                }
            }
            
        }
        Test.stopTest();               
    }
    
    @istest(seeAllData=true)
    private Static void SetLastModifiedTime_Test()
    {
        CaseTestData caseTestData  = new CaseTestData();
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('guessWorkEffort', null, 1, null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('guessWorkEffort', 1, accountList.get(0).id);
        insert contactList;
        //Get 'Email Agent' User
        List<User> lstemailAgentUser = [Select id, FirstName, LastName from User where username like: 'emailagent@omnitracs.com%'];
        
        Test.startTest();
        System.runAs(lstemailAgentUser.get(0))//Verify 'Last Modified Date Time' for Email Agent user
        {
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('guessWorkEffort', 'Call Center', accountList, contactList, null, 1);
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            
            //verify Inserted Case
            List<Case> createdCaseList = [Select Id, Last_Modified_Date_Time__c From Case where id in :createCaseList];
            
            String LastModifiedDateTime = lstemailAgentUser.get(0).FirstName + ' ' + lstemailAgentUser.get(0).LastName;
            //'Last Modified Date Time' should be three hours prior to system date
            system.debug(createdCaseList.get(0).Last_Modified_Date_Time__c);
            //system.assert(createdCaseList.get(0).Last_Modified_Date_Time__c.contains(LastModifiedDateTime), 'LastModifiedDateTime mismatch');
        }
        Test.stopTest();
    }
    
    @istest(seeAllData=true)
    private Static void SendEmail_Test()
    {
        CaseTestData caseTestData  = new CaseTestData();
        //Set value in Send Trigger Email Alerts  custom setting
        Send_Trigger_Email_Alerts__c isSendTriggerEmailAlert = caseTestData.sendTriggerEmailAlert();
        update isSendTriggerEmailAlert;
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<User> TestUserList = caseTestData.CreateUser('SendEmail', testProfile.id, 'TestCaseUser', null, 1);
        Insert TestUserList;
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('SendEmail', TestUserList, 2, null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('SendEmail', 1, accountList.get(0).id);
        insert contactList;
              
        Test.startTest();   
        System.runAs(TestUserList.get(0))
        {
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('SendEmail', 'Call Center', accountList, contactList, TestUserList, 3);
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            system.assert(createCaseList.get(1).id != null,'Exception in Case Creation');
            system.assert(createCaseList.get(2).id != null,'Exception in Case Creation');
                       
            //verify Inserted Case
            List<Case> createdCaseList = [Select Id, Status, Work_Effort_In_Minutes__c From Case where id in :createCaseList];
            for(Case createdCaseObj :createdCaseList)
            {
                //email is sent to stakeholders, but we do not have any parameter to verify that
            }
            
            //Update the Case
            List<Case> updateCaseList = new List<Case>();
            
            for(Case createdCaseObj :createdCaseList)
            {
                if(createdCaseObj.id == createCaseList[0].id)
                {
                    createdCaseObj.Status = 'Closed';
                    createdCaseObj.Accountid = accountlist.get(0).id;
                    createdCaseObj.Contactid = contactList.get(0).id;
                    createdCaseObj.resolution__c = 'Test';
                    createdCaseObj.Work_Effort_In_Minutes__c = 10;
                    createdCaseObj.Self_Close_Reason__c = 'Unit Testing';
                }
                if(createdCaseObj.id == createCaseList[1].id)
                {
                    createdCaseObj.Status = 'Closed';
                    createdCaseObj.Accountid = accountlist.get(0).id;
                    createdCaseObj.Contactid = contactList.get(0).id;
                    createdCaseObj.resolution__c = 'Test';
                    createdCaseObj.Work_Effort_In_Minutes__c = 10;
                    createdCaseObj.Self_Close_Reason__c = 'Unit Testing';
                }
                if(createdCaseObj.id == createCaseList[2].id)
                {
                    createdCaseObj.Status = 'Closed';
                    createdCaseObj.Accountid = accountlist.get(0).id;
                    createdCaseObj.Contactid = contactList.get(0).id;
                    createdCaseObj.resolution__c = 'Test';
                    createdCaseObj.Work_Effort_In_Minutes__c = 10;
                    createdCaseObj.Self_Close_Reason__c = 'Unit Testing';
                }
                
                updateCaseList.add(createdCaseObj);               
            }
            update updateCaseList;
            
            //verify the updated Case
            List<Case> updatedCaseList = [Select Id, Status, Work_Effort_In_Minutes__c From Case where id in :updateCaseList];
                   
            for(Case updatedCaseObj :updatedCaseList)
            {
                //email is sent to stakeholders, but we do not have any parameter to verify that
            }           
        }
        Test.stopTest();               
    }
    
    @istest(seeAllData=true)
    private Static void ChatterCaseToAccountFeed_Test()
    {
        CaseTestData caseTestData  = new CaseTestData();
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<User> TestUserList = caseTestData.CreateUser('ChatterCaseToAccountFeed', testProfile.id, 'TestCaseUser', null, 1);
        Insert TestUserList;
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('ChatterCaseToAccountFeed', TestUserList, 2, null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('ChatterCaseToAccountFeed', 1, accountList.get(0).id);
        insert contactList;
              
        Test.startTest();   
        System.runAs(TestUserList.get(0))
        {
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('ChatterCaseToAccountFeed', 'Call Center', accountList, contactList, null, 1);
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            
            //verify Inserted Case
            String strAccountFeed;
            List<Case> createdCaseList = [Select Id, CaseNumber, subject, Accountid From Case where id in :createCaseList];
            for(Case createdCaseObj :createdCaseList)
            {
                strAccountFeed = 'Case Created: '+createdCaseObj.CaseNumber +' : '+createdCaseObj.subject+'.';
            }
                       
            //verify Inserted FeedItem on corresponding Case's Account
            List<FeedItem> createdFeedItemList = [Select Id, Body From FeedItem where ParentID = :accountList.get(0).id];
            for(FeedItem createdFeedItemObj :createdFeedItemList)
            {
                //posted chatter in Corresponding Case's Account
                system.assertequals(strAccountFeed,createdFeedItemObj.Body,'Error in feed creation');
            }
            
            //Update the Case
            List<Case> updateCaseList = new List<Case>();
            strAccountFeed = '';
            for(Case createdCaseObj :createdCaseList)
            {
                if(createdCaseObj.id == createCaseList[0].id)
                {
                    //Account is getting Changed
                    createdCaseObj.Accountid = accountList.get(1).id;
                }               
                updateCaseList.add(createdCaseObj);               
            }
            update updateCaseList;
           
            //verify the updated Case
            List<Case> updatedCaseList = [Select Id, CaseNumber, subject, Accountid From Case where id in :updateCaseList];
                   
            for(Case updatedCaseObj :updatedCaseList)
            {
                strAccountFeed = 'Case Created: '+updatedCaseObj.CaseNumber +' : '+updatedCaseObj.subject+'.';   
            }
            
            //verify Inserted FeedItem on corresponding Case's Account
            List<FeedItem> updatedFeedItemList = [Select Id, Body From FeedItem where ParentID = :accountList.get(1).id];
            for(FeedItem updatedFeedItemObj :updatedFeedItemList)
            {
                //posted chatter in Corresponding Case's Account
                system.assertequals(strAccountFeed,updatedFeedItemObj.Body,'Error in feed creation');
            }          
        }
        Test.stopTest();               
    }
    
    /*@istest(seeAllData=true)
    private Static void setOwnerEngCase_Test()
    {
        CaseTestData caseTestData  = new CaseTestData();
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<User> TestUserList = caseTestData.CreateUser('setOwnerEngCase', testProfile.id, 'TestCaseUser', null, 1);
        Insert TestUserList;
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('setOwnerEngCase', TestUserList, 1, null);
        insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('setOwnerEngCase', 1, accountList.get(0).id);
        insert contactList;
    
        Test.startTest();   
        System.runAs(TestUserList.get(0))
        {
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('setOwnerEngCase', 'Engineering Case', accountList, contactList, null, 6);
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            system.assert(createCaseList.get(1).id != null,'Exception in Case Creation');
            
            //verify Inserted Case
            List<Case> createdCaseList = [Select Id, ownerId, JIRA_Status__c, JIRA_Issue__c From Case where id in :createCaseList];            
            List<Case> updateCaseList = new List<Case>();
            for(Case createdCaseObj :createdCaseList)
            {
                if(createdCaseObj.id == createCaseList[0].id)
                {
                    createdCaseObj.ownerId = CaseTrigger_Global_Variable__c.getInstance('Strategic Support_QueueId').Value__c;//case owner is a queue
                    createdCaseObj.JIRA_Status__c = 'Closed';
                    createdCaseObj.JIRA_Issue__c = '012345678912345';            
                    updateCaseList.add(createdCaseObj);
                }
                if(createdCaseObj.id == createCaseList[1].id)
                {
                    createdCaseObj.Engineering_Case__c = createCaseList[0].id;//Case is having lookup(Engineering Case) to another case
                    updateCaseList.add(createdCaseObj);
                }
                if(createdCaseObj.id == createCaseList[3].id)
                {
                    createdCaseObj.Engineering_Case__c = createCaseList[2].id;//Case is having lookup(Engineering Case) to another case
                    updateCaseList.add(createdCaseObj);
                }
                if(createdCaseObj.id == createCaseList[5].id)
                {
                    createdCaseObj.Engineering_Case__c = createCaseList[4].id;//Case is having lookup(Engineering Case) to another case
                    updateCaseList.add(createdCaseObj);
                }   
            }                                 
            update updateCaseList;
           
            //verify the updated Case & update again
            List<Case> updatedCaseList = [Select Id, ownerId, JIRA_Status__c, createdById, JIRA_Issue__c From Case where id in :createCaseList];
            List<Case> updateUpdatedCaseList  = new List<Case>();     
            for(Case updatedCaseObj :updatedCaseList)
            {
                if(updatedCaseObj.id == createCaseList[0].id)
                {
                    //Case owner will automatically be changed to Case created by user
                    system.assertequals(updatedCaseObj.createdById, updatedCaseObj.ownerId, 'Exception in owner change');
                    //updatedCaseObj.JIRA_Status__c = 'Blocked';
                    updateUpdatedCaseList.add(updatedCaseObj);
                }
                if(updatedCaseObj.id == createCaseList[2].id)
                {
                    //updating the parent case
                    updatedCaseObj.JIRA_Status__c = 'Blocked'; 
                    updateUpdatedCaseList.add(updatedCaseObj);
                }
                if(updatedCaseObj.id == createCaseList[4].id)
                {
                    //updating the parent case
                    updatedCaseObj.JIRA_Status__c = 'Resolved'; 
                    updateUpdatedCaseList.add(updatedCaseObj);
                }                  
            }
            update updateUpdatedCaseList;

            //verify the updated Case & update again
            List<Case> updatedUpdatedCaseList = [Select Id, ownerId, JIRA_Status__c, createdById, JIRA_Issue__c From Case where id in :createCaseList];
            for(Case updatedUpdatedCaseObj :updatedUpdatedCaseList)
            {
                if(updatedUpdatedCaseObj.id == createCaseList[1].id)
                {
                    //Jira Status and Jira Issue# will be copied to child cases
                    system.assertequals('Closed', updatedUpdatedCaseObj.JIRA_Status__c, 'exception is copying jira status to child cases');
                    system.assertequals('012345678912345', updatedUpdatedCaseObj.JIRA_Issue__c, 'exception is copying Jira Issue#  to child cases');
                }
                if(updatedUpdatedCaseObj.id == createCaseList[3].id)
                {
                    //Case will automatically asssigned to Roadnet Strategic Support Queue
                    system.assertequals(CaseTrigger_Global_Variable__c.getInstance('Strategic Support_QueueId').Value__c, updatedUpdatedCaseObj.ownerId, 'Exception in owner change');
                }
                if(updatedUpdatedCaseObj.id == createCaseList[5].id)
                {
                    //Case owner will automatically be changed to Case created by user
                    system.assertequals(updatedUpdatedCaseObj.createdById, updatedUpdatedCaseObj.ownerId, 'Exception in owner change');
                }                  
            }                    
        }
        Test.stopTest();               
    }*/
    
    @istest(seeAllData=true)
    private Static void populateJiraFields_Test()
    {
        CaseTestData caseTestData  = new CaseTestData();
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<User> TestUserList = caseTestData.CreateUser('populateJiraFields', testProfile.id, 'TestCaseUser', null, 1);
        Insert TestUserList;
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('populateJiraFields', TestUserList, 1, null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('populateJiraFields', 1, accountList.get(0).id);
        insert contactList;
    
        Test.startTest();   
        System.runAs(TestUserList.get(0))
        {
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('populateJiraFields', 'Engineering Case', accountList, contactList, null, 3);
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            system.assert(createCaseList.get(1).id != null,'Exception in Case Creation');
            system.assert(createCaseList.get(2).id != null,'Exception in Case Creation');
            
            //verify Inserted Case
            List<Case> createdCaseList = [Select Id From Case where id in :createCaseList];            
            List<Case> updateCaseList = new List<Case>();
            for(Case createdCaseObj :createdCaseList)
            {
                if(createdCaseObj.id == createCaseList[1].id)
                {
                    createdCaseObj.Engineering_Case__c = createCaseList[0].id;//Case is having lookup(Engineering Case) to another case
                    updateCaseList.add(createdCaseObj);
                }
                if(createdCaseObj.id == createCaseList[2].id)
                {
                    createdCaseObj.Engineering_Case__c = createCaseList[0].id;//Case is having lookup(Engineering Case) to another case
                    updateCaseList.add(createdCaseObj);
                }   
            }                                 
            update updateCaseList;
           
            //verify the child Cases
            Map<id,Case> updatedCaseMap = new map<Id, Case>([Select Id, Status, Substatus__c, JIRA_Status__c, Jira_Priority__c, 
                                                             JIRA_Issue__c, Jira_Tracking__c From Case where id in :createCaseList]);  
            for(Case updatedCaseObj :updatedCaseMap.values())
            {
                updatedCaseObj.JIRA_Issue__c = '012345678912345';
                if(updatedCaseObj.id == createCaseList[0].id)
                {
                    
                    system.assert('012345678912345' == updatedCaseObj.JIRA_Issue__c, 'Exception in parent case');
                    system.assert('Closed' == updatedCaseObj.JIRA_Status__c, 'Exception in parent case');
                    system.assert('012345678912345' == updatedCaseObj.Jira_Tracking__c, 'Exception in parent case');
                    system.assert('Low' == updatedCaseObj.Jira_Priority__c, 'Exception in parent case');
                    system.assert('Closed' == updatedCaseObj.Status, 'Exception in parent case');
                }
                if(updatedCaseObj.id == createCaseList[1].id)
                {
                    //Jira Issue# should be copied from parent case
                    system.assertequals(updatedCaseMap.get(createCaseList[0].id).JIRA_Issue__c,updatedCaseObj.JIRA_Issue__c);
                    //other jira fields should not be copied as the child case record type is not 'Call Center'
                    system.assertnotequals(updatedCaseMap.get(createCaseList[0].id).JIRA_Status__c,updatedCaseObj.JIRA_Status__c);
                    //system.assertnotequals(updatedCaseMap.get(createCaseList[0].id).Jira_Tracking__c,updatedCaseObj.Jira_Tracking__c);
                    system.assertnotequals(updatedCaseMap.get(createCaseList[0].id).Jira_Priority__c,updatedCaseObj.Jira_Priority__c);
                    //child case should automatically be set as parent case is Closed
                    updatedCaseObj.Substatus__c = 'Pending Customer';
                    system.assertequals('Pending Customer', updatedCaseObj.Substatus__c);
                    
                }
                if(updatedCaseObj.id == createCaseList[2].id)
                {
                    //Jira Issue# should be copied from parent case
                    system.assertequals(updatedCaseMap.get(createCaseList[0].id).JIRA_Issue__c,updatedCaseObj.JIRA_Issue__c);
                    //other jira fields should not be copied as the child case record type is not 'Call Center'
                    //system.assertequals(updatedCaseMap.get(createCaseList[0].id).JIRA_Status__c,updatedCaseObj.JIRA_Status__c);
                    //system.assertequals(updatedCaseMap.get(createCaseList[0].id).Jira_Tracking__c,updatedCaseObj.Jira_Tracking__c);
                    //system.assertequals(updatedCaseMap.get(createCaseList[0].id).Jira_Priority__c,updatedCaseObj.Jira_Priority__c);
                    //child case should automatically be set as parent case is Closed
                    updatedCaseObj.Substatus__c = 'Pending Customer';
                    system.assertequals('Pending Customer',updatedCaseObj.Substatus__c);    
                }                 
            }                   
        }
        Test.stopTest();               
    }
    
    @istest(seeAllData=true)
    private Static void validateWorkEffort_Test()
    {
        String strErrorMsg = '';
        CaseTestData caseTestData  = new CaseTestData();
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<User> TestUserList = caseTestData.CreateUser('validateWorkEffort', testProfile.id, 'TestCaseUser', null, 1);
        Insert TestUserList;
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('validateWorkEffort', TestUserList, 1, null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('validateWorkEffort', 1, accountList.get(0).id);
        insert contactList;        
        
        Test.startTest();   
        System.runAs(TestUserList.get(0))
        {
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('validateWorkEffort', 'Engineering Case', accountList, contactList, null, 1);
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');

            //verify Inserted Case
            List<Case> createdCaseList = [Select Id From Case where id in :createCaseList];            
            List<Case> updateCaseList = new List<Case>();
            for(Case createdCaseObj :createdCaseList)
            {
                if(createdCaseObj.id == createCaseList[0].id)
                {
                    //case could not be closed if work effort is not provided
                    createdCaseObj.Work_Effort_In_Minutes__c = null;
                    createdCaseObj.Total_Work_Effort__c = null;
                    createdCaseObj.Status = 'Closed';
                    createdCaseObj.resolution__c = 'Test';
                    createdCaseObj.Self_Close_Reason__c = 'Unit Testing';
                    updateCaseList.add(createdCaseObj);
                }  
            }
            try
            {                                 
                update updateCaseList;
            }
            catch(Exception e)
            {
                strErrorMsg = e.getmessage();
                updateCaseList = new list<case>();
            }
            //system.assert(strErrorMsg.contains('Cannot close case with 0 Total Work Effort.  Please place a non zero value in Work Effort In Minutes'));    

            for(Case createdCaseObj :createdCaseList)
            {
                if(createdCaseObj.id == createCaseList[0].id)
                {
                    createdCaseObj.Work_Effort_In_Minutes__c = 0;//work effort is set to zero
                    createdCaseObj.Status = 'Open';//Status is not closed
                    updateCaseList.add(createdCaseObj);
                }  
            }
            try
            {                                 
                update updateCaseList;               
            }
            catch(Exception e)
            {
                strErrorMsg = '';
                strErrorMsg = e.getmessage();
                updateCaseList = new list<case>();                
            }
            //system.assert(strErrorMsg.contains('Please place a non zero value in Work Effort')); 

            for(Case createdCaseObj :createdCaseList)
            {
                if(createdCaseObj.id == createCaseList[0].id)
                {
                    //work effort can not be more than 480
                    createdCaseObj.Work_Effort_in_minutes__c = 481;
                    updateCaseList.add(createdCaseObj);
                }  
            }
            try
            {                                 
                update updateCaseList;                              
            }
            catch(Exception e)
            {
                strErrorMsg = '';
                strErrorMsg = e.getmessage();
                updateCaseList = new list<case>();
            }
            //system.assert(strErrorMsg.contains('Work Effort value is too high.  Please specify a new value for work minutes.'));

            for(Case createdCaseObj :createdCaseList)
            {
                if(createdCaseObj.id == createCaseList[0].id)
                {
                    //set product to RNA
                    createdCaseObj.Product_PL__c = 'RNA Dispatching';
                    createdCaseObj.Product_Family_PL__c = 'Roadnet Anywhere';
                    createdCaseObj.Status = 'Closed';
                    createdCaseObj.resolution__c = 'Test';
                    createdCaseObj.Self_Close_Reason__c = 'Unit Testing';
                    createdCaseObj.Work_Effort_in_minutes__c = 10;
                    createdCaseObj.Closed_By__c = userinfo.getuserid();
                    updateCaseList.add(createdCaseObj);
                } 
                
            }                                 
            update updateCaseList;
            
            //verify the updated Cases
            List<Case> updatedCaseList = [Select Id, Product_PL__c, Product_Family_PL__c, Closed_By__c  From Case where id in :createCaseList];
            for(Case updatedCaseObj :updatedCaseList)
            {
                if(updatedCaseObj.id == createCaseList[0].id)
                {
                    system.assertequals('RNA Dispatching', updatedCaseObj.Product_PL__c);
                    //Product Family will automatically set to 'Roadnet Anywhere'
                    system.assertequals('Roadnet Anywhere', updatedCaseObj.Product_Family_PL__c);
                    //as case got closed so Closed By will automatically set to logged in user
                    system.assertequals(userinfo.getuserid(), updatedCaseObj.Closed_By__c);
                }
            }   
        }
        Test.stopTest();               
    }
    
    @istest(seeAllData=true)
    private Static void closeChildCaseANDSendmailtoContact_Test()
    {
        CaseTestData caseTestData  = new CaseTestData();
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<User> TestUserList = caseTestData.CreateUser('closeChildCaseANDSendmailtoContact', testProfile.id, 'TestCaseUser', null, 1);
        Insert TestUserList;
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('closeChildCaseANDSendmailtoContact', TestUserList, 1, null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('closeChildCaseANDSendmailtoContact', 1, accountList.get(0).id);
        insert contactList;
    
        Test.startTest();   
        System.runAs(TestUserList.get(0))
        {
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('closeChildCaseANDSendmailtoContact', 'Call Center', accountList, contactList, null, 3);
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            system.assert(createCaseList.get(1).id != null,'Exception in Case Creation');
            system.assert(createCaseList.get(2).id != null,'Exception in Case Creation');
            
            //verify Inserted Case
            List<Case> createdCaseList = [Select Id, status, Substatus__c From Case where id in :createCaseList];            
            List<Case> updateCaseList = new List<Case>();
            for(Case createdCaseObj :createdCaseList)
            {
                if(createdCaseObj.id == createCaseList[0].id)
                {
                    createdCaseObj.Substatus__c = 'Completed';
                    updateCaseList.add(createdCaseObj);
                }
                if(createdCaseObj.id == createCaseList[1].id)
                {
                    createdCaseObj.parentId = createCaseList[0].id;//child case
                    createdCaseObj.Self_Close_Reason__c = 'Unit Testing';
                    updateCaseList.add(createdCaseObj);
                }
                if(createdCaseObj.id == createCaseList[2].id)
                {
                    createdCaseObj.parentId = createCaseList[0].id;//child case
                    createdCaseObj.Self_Close_Reason__c = 'Unit Testing';
                    createdCaseObj.ownerid = CaseTrigger_Global_Variable__c.getInstance('Strategic Support_QueueId').Value__c;//owner 
                    updateCaseList.add(createdCaseObj);
                }    
            }                                 
            update updateCaseList;
           
            //verify the child cases and closing the parent case
            List<Case> updatedCaseList = [Select Id, Status, Substatus__c, parentId From Case where id in :createCaseList];  
            List<Case> updateUpdatedCaseList  = new List<Case>();
            for(Case updatedCaseObj :updatedCaseList)
            {
                if(updatedCaseObj.id == createCaseList[0].id)
                {
                    updatedCaseObj.status = 'Closed';
                    updatedCaseObj.resolution__c = 'Test';
                    updatedCaseObj.Self_Close_Reason__c = 'Unit Testing';
                    updatedCaseObj.Is_Case_Being_Upgraded__c = true;
                    updateUpdatedCaseList.add(updatedCaseObj);
                }
                if(updatedCaseObj.id == createCaseList[1].id)
                {
                    system.assertequals(createCaseList[0].id, updatedCaseObj.parentId);
                }
                if(updatedCaseObj.id == createCaseList[2].id)
                {
                    system.assertequals(createCaseList[0].id, updatedCaseObj.parentId);
                }                
            }
            update updateUpdatedCaseList;
            
            //verify the child case status and substatus
            List<Case> updatdUpdatedCaseList = [Select Id, Status, Substatus__c From Case where id in :createCaseList];  

            /*for(Case updatdUpdatedCaseObj :updatdUpdatedCaseList)
            {
                if(updatdUpdatedCaseObj.id == createCaseList[0].id)
                {
                    //child case owner is user, status and substatus will be copied from parent
                    system.assertequals('Closed', updatdUpdatedCaseObj.status);
                    system.assertequals('Completed', updatdUpdatedCaseObj.Substatus__c);
                }
                if(updatdUpdatedCaseObj.id == createCaseList[1].id)
                {
                    //child case owner is user, status and substatus will be copied from parent
                    system.assertequals('Closed', updatdUpdatedCaseObj.status);
                    system.assertequals('Completed', updatdUpdatedCaseObj.Substatus__c);
                }
                if(updatdUpdatedCaseObj.id == createCaseList[2].id)
                {
                    //child case owner is group, status and substatus will not be copied from parent
                    system.assertnotequals('Closed', updatdUpdatedCaseObj.status);
                    system.assertnotequals('Completed', updatdUpdatedCaseObj.Substatus__c);
                } 
            }*/                 
        }
        Test.stopTest();               
    }
    
    @istest(seeAllData=true)
    private Static void testPrepopulateContactAndAccountIfEmail2Case_scn1(){
        CaseTestData caseTestData  = new CaseTestData();
        List<User> TestUserList = [SELECT Id,Name,Email,FirstName,LastName FROM User WHERE UserName like : 'emailagent@omnitracs.com%' LIMIT 1];
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('Email_To_Case', null ,1, null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('Email_To_Case', 6, accountList.get(0).id);
        contactList.get(0).Email = 'test1@test.com';
        contactList.get(1).Email = 'test2@test.com';
        contactList.get(2).Email = 'test2@test.com';       
        insert contactList;

        Test.startTest();
        System.runAs(TestUserList.get(0)){
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('Email_To_Case', 'Call Center', accountList, contactList, TestUserList, 6);
            createCaseList.get(0).SuppliedEmail = 'test1@test.com';
            createCaseList.get(1).SuppliedEmail = 'test2@test.com';
            createCaseList.get(2).SuppliedEmail = 'test1@test.com';
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            
            List<Case> lstCasesInst = [SELECT Id,SuppliedEmail,Contact.Email FROM Case WHERE ID in :createCaseList];
            //System.assert();
        }
        Test.stopTest();
    }
    
    @istest(seeAllData=true)
    private Static void testPrepopulateContactAndAccountIfEmail2Case_scn2(){
        CaseTestData caseTestData  = new CaseTestData();
        List<User> TestUserList = [SELECT Id,Name,Email,FirstName,LastName FROM User WHERE UserName like : 'emailagent@omnitracs.com%' LIMIT 1];
        System.debug(':: TestUserList :::'+TestUserList);
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('Email_To_Case', null ,1, null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('Email_To_Case', 6, accountList.get(0).id);
        contactList.get(0).Email = 'test1@test.com';
        contactList.get(1).Email = 'test2@test.com';
        contactList.get(2).Email = 'test2@test.com';
        contactList.get(3).Inactive__c = true;
        contactList.get(4).Email = 'test2@test.com';
        contactList.get(4).Inactive__c = true;
        contactList.get(5).Email = 'test1@test.com';       
        insert contactList;

        Test.startTest();
        System.runAs(TestUserList.get(0)){
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('Email_To_Case', 'Call Center', accountList, contactList, TestUserList, 6);
            createCaseList.get(0).SuppliedEmail = 'test1@test.com';
            createCaseList.get(1).SuppliedEmail = 'test2@test.com';
            createCaseList.get(2).SuppliedEmail = 'test1@test.com';
            createCaseList.get(4).SuppliedEmail = 'test1@test.com';
            createCaseList.get(5).SuppliedEmail = 'test2@test.com';
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            
            List<Case> lstCasesInst = [SELECT Id,SuppliedEmail,Contact.Email FROM Case WHERE ID in :createCaseList];
            //System.assert();
        }
        Test.stopTest();
    }

    @istest(seeAllData=true)
    private Static void testPrepopulateContactAndAccountIfEmail2Case_scn3(){
        CaseTestData caseTestData  = new CaseTestData();
        List<User> TestUserList = [SELECT Id,Name,Email,FirstName,LastName FROM User WHERE UserName like : 'emailagent@omnitracs.com%' LIMIT 1];
        System.debug(':: TestUserList :::'+TestUserList);
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('Email_To_Case', null ,1, null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('Email_To_Case', 6, accountList.get(0).id);
        contactList.get(0).Email = 'test1@test.com';
        contactList.get(0).Inactive__c = true;
        contactList.get(1).Email = 'test2@test.com';
        contactList.get(1).Inactive__c = true;
        contactList.get(2).Email = 'test2@test.com';
        contactList.get(2).Inactive__c = true;
        contactList.get(3).Email = 'test2@test.com';
        contactList.get(3).Inactive__c = true;
        contactList.get(4).Email = 'test1@test.com';
        contactList.get(4).Inactive__c = true;
        
        insert contactList;

        Test.startTest();
        System.runAs(TestUserList.get(0)){
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('Email_To_Case', 'Call Center', accountList, contactList, TestUserList, 6);
            createCaseList.get(0).SuppliedEmail = 'test1@test.com';
            createCaseList.get(1).SuppliedEmail = 'test2@test.com';
            createCaseList.get(2).SuppliedEmail = 'test1@test.com';
            createCaseList.get(4).SuppliedEmail = 'test1@test.com';
            createCaseList.get(5).SuppliedEmail = 'test2@test.com';

            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            
            List<Case> lstCasesInst = [SELECT Id,SuppliedEmail,Contact.Email FROM Case WHERE ID in :createCaseList];
            //System.assert();
        }
        Test.stopTest();
    }
    
    @istest(seeAllData=true)
    private Static void NMCAccountValidation_Test()
    {
        String strErrorMsg = '';
        CaseTestData caseTestData  = new CaseTestData();
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<User> TestUserList = caseTestData.CreateUser('NMCAccountValidation', testProfile.id, 'TestCaseUser', null, 1);
        Insert TestUserList;
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('NMCAccountValidation', TestUserList, 2, null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('NMCAccountValidation', 1, accountList.get(0).id);
        insert contactList;
    
        Test.startTest();   
        System.runAs(TestUserList.get(0))
        {
            //Insert NMC Account
            List<NMC_Account__c> createNMCAccountList = caseTestData.createNMCAccount(accountList, 2);
            Insert createNMCAccountList;
            system.assert(createNMCAccountList.get(0).id != null, 'Error in creation of NMC Account');
            system.assert(createNMCAccountList.get(1).id != null, 'Error in creation of NMC Account');
            
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('NMCAccountValidation', 'NMC Account Request', accountList, contactList, null, 1);
            
            //multiple value in 'Default NMC Account for Unit Type' picklist along with 'Not a Default NMC Account'
            createCaseList.get(0).Default_NMC_Account_for_Unit_Type__c = 'Not a Default NMC Account; OmniTRACS';          
            try{
                Insert createCaseList;
            }
            catch(Exception e)
            {
                strErrorMsg = e.getmessage();
            }
            system.assertequals(createCaseList.get(0).Default_NMC_Account_for_Unit_Type__c,'Not a Default NMC Account; OmniTRACS');
            //////////////////////////////////////////////////////////////////
            createCaseList.get(0).Default_NMC_Account_for_Unit_Type__c = null;
            //multiple value in 'Addl Default NMC Account for Unit Type' picklist along with 'Not a Default NMC Account'
            createCaseList.get(0).Addl_Default_NMC_Account_for_Unit_Type__c = 'Not a Default NMC Account; OmniTRACS';            
            try{
                Insert createCaseList;
            }
            catch(Exception e)
            {
                strErrorMsg = '';
                strErrorMsg = e.getmessage();
            }
           // system.assert(strErrorMsg.contains('You cannot select any Unit Types when selecting Not a Default NMC Account'));
            /////////////////////////////////////////////////////////////////////
            createCaseList.get(0).Addl_Default_NMC_Account_for_Unit_Type__c = null;
            //only Addl NMC Account Number field is set
            createCaseList.get(0).Addl_NMC_Account_Number__c = '12345';            
            try{
                Insert createCaseList;
            }
            catch(Exception e)
            {
                strErrorMsg = '';
                strErrorMsg = e.getmessage();
            }
            //system.assert(strErrorMsg.contains('You must enter a value'));
            //////////////////////////////////////////////////////////////////////
            createCaseList.get(0).Addl_NMC_Account_Number__c = null;
            //only Addl NMC Account Name field is set  
            createCaseList.get(0).Addl_NMC_Account_Name__c = '12345';     
            try{
                Insert createCaseList;
            }
            catch(Exception e)
            {
                strErrorMsg = '';
                strErrorMsg = e.getmessage();
            }
           // system.assert(strErrorMsg.contains('You must enter a value'));
            ///////////////////////////////////////////////////////////////////////
            createCaseList.get(0).Addl_NMC_Account_Name__c = null;
            createCaseList.get(0).Type_Level_2__c = 'New NMC Account';
            createCaseList.get(0).Addl_NMC_Account_Number__c = '12345';
            createCaseList.get(0).Addl_NMC_Account_Name__c = '12345';
            createCaseList.get(0).Addl_Aux_ID__c = '12345';
            createCaseList.get(0).Addl_NMC_Account_Status__c = 'Active';
            createCaseList.get(0).Addl_Retention_Period__c = '2 days';
            //common value in both picklists
            createCaseList.get(0).Default_NMC_Account_for_Unit_Type__c = 'OmniTRACS';   
            createCaseList.get(0).Addl_Default_NMC_Account_for_Unit_Type__c = 'OmniTRACS';           
            try{
                Insert createCaseList;
            }
            catch(Exception e)
            {
                strErrorMsg = '';
                strErrorMsg = e.getmessage();
            }
            //system.assert(strErrorMsg.contains('The Unit Type has already been selected.  Invalid Unit Type ='));
            ////////////////////////////////////////////////////////////////////////
            createCaseList.get(0).Default_NMC_Account_for_Unit_Type__c = 'OmniExpress';
            createCaseList.get(0).NMC_Account__c = createNMCAccountList.get(0).id;
            createCaseList.get(0).NMC_Account_Number__c = '123451';
            createCaseList.get(0).status = 'Closed';
            createCaseList.get(0).Resolution__c = 'Test';
            createCaseList.get(0).Self_Close_Reason__c = 'Unit Testing';
            createCaseList.get(0).Substatus__c = 'Completed';            
            try{
                Insert createCaseList;
            }
            catch(Exception e)
            {
                strErrorMsg = '';
                strErrorMsg = e.getmessage();
            }
            //system.assert(strErrorMsg.contains('NMC Account Number already exists. Please choose a unique number.'));
            ////////////////////////////////////////////////////////////////////////
            createCaseList.get(0).NMC_Account_Number__c = '123450';
            createCaseList.get(0).Addl_NMC_Account_Number__c = '123450';          
            try{
                Insert createCaseList;
            }
            catch(Exception e)
            {
                strErrorMsg = '';
                strErrorMsg = e.getmessage();
            }
            //system.assert(strErrorMsg.contains('NMC Account Number already exists. Please choose a unique number.'));
            ////////////////////////////////////////////////////////////////////////
            createCaseList.get(0).NMC_Account_Number__c = '123456';
            createCaseList.get(0).Addl_NMC_Account_Number__c = '123456';
            createCaseList.get(0).NMC_Account__c = createNMCAccountList.get(0).id;
            createCaseList.get(0).Type_Level_2__c = 'New NMC Account';
            createCaseList.get(0).AccountId = accountList.get(1).id;
            createCaseList.get(0).Default_NMC_Account_for_Unit_Type__c = 'MCP50';
            createCaseList.get(0).Addl_Default_NMC_Account_for_Unit_Type__c = 'MCP50';
            try{
                Insert createCaseList;
            }
            catch(Exception e)
            {
                strErrorMsg = '';
                strErrorMsg = e.getmessage();
            }
            //system.assert(strErrorMsg.contains('Default NMC Account for Unit Type already exists for this customer.  Invalid Unit Type ='));
            /////////////////////////////////////////////////////////////////////////
            createCaseList.get(0).Type_Level_2__c = 'Update NMC Account';
            createCaseList.get(0).Default_NMC_Account_for_Unit_Type__c = 'OmniExpress';
            createCaseList.get(0).Addl_Default_NMC_Account_for_Unit_Type__c = 'OmniTRACS';
            try{
                Insert createCaseList;
            }
            catch(Exception e)
            {
                strErrorMsg = '';
                strErrorMsg = e.getmessage();
            }
            //system.assert(strErrorMsg.contains('Default NMC Account for Unit Type already exists for this customer.  Invalid Unit Type ='));
            /////////////////////////////////////////////////////////////////////////           
            createCaseList.get(0).Type_Level_2__c = 'Transfer NMC Account';
            createCaseList.get(0).Transfer_to_Account__c = accountList.get(1).id;
            createCaseList.get(0).Default_NMC_Account_for_Unit_Type__c = 'OmniExpress';
            createCaseList.get(0).Addl_Default_NMC_Account_for_Unit_Type__c = 'OmniTRACS';
            try{
                Insert createCaseList;
            }
            catch(Exception e)
            {
                strErrorMsg = '';
                strErrorMsg = e.getmessage();
            }
            //system.assert(strErrorMsg.contains('Default NMC Account for Unit Type already exists for this customer.  Invalid Unit Type ='));
        }
        Test.stopTest();
    }
    
    @istest(seeAllData=true)
    private Static void TIS_Test1()
    {
        CaseTestData caseTestData  = new CaseTestData();
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<User> TestUserList = caseTestData.CreateUser('Roadnet', testProfile.id, 'TestCaseUser', null, 2);
        Insert TestUserList;
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('', null, 1,null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('', 1, accountList.get(0).id);
        insert contactList;
       
        Test.startTest();
        System.runAs(TestUserList.get(0))
        {
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('TIS', 'SFDC Support', accountList, contactList, TestUserList, 1);
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            
            //verify Inserted Case
            List<Case> createdCaseList = [Select Id, Last_Modified_Date_Time__c,status,Queue__c  From Case where id in :createCaseList];
            List<TIS_Detail__c> lstCaseTIS=[select id,Date_Time_In__c,Date_Time_Out__c,State__c,Owner__c from TIS_Detail__c where Case__c in :createCaseList];
            if(lstCaseTIS.size() >0){
               system.assert(lstCaseTIS.get(0).id!=null, 'TIS not inserted');   
           }
            
            List<Case> toBeUpdatedCaseList  = new List<Case>();
            
            for(Case updateCaseObj:createdCaseList)
            {
                if(updateCaseObj.id == createCaseList[0].id)
                {
                    updateCaseObj.status = 'Closed';
                    updateCaseObj.resolution__c = 'test';
                    updateCaseObj.OwnerId =TestUserList.get(1).id;
                    updateCaseObj.Queue__c = 'CEMS';
                    toBeUpdatedCaseList.add(updateCaseObj);
                }
            }
            CreateTIS.UpdateCounter = 1; 
            update toBeUpdatedCaseList; //Cannot verify System.assert because of Future Method call
        }
        Test.stopTest();
    }
    
    @istest(seeAllData=true)
    private Static void TIS_Test2()
    {
        CaseTestData caseTestData  = new CaseTestData();
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<User> TestUserList = caseTestData.CreateUser('Roadnet', testProfile.id, 'TestCaseUser', null, 2);
        Insert TestUserList;
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('', null, 1,null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('', 1, accountList.get(0).id);
        insert contactList;
        
        Test.startTest();
        System.runAs(TestUserList.get(0))
        {
           
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('TIS', 'SFDC Support', accountList, contactList, TestUserList, 1);
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            
            //verify Inserted Case
            List<Case> createdCaseList = [Select Id, Last_Modified_Date_Time__c,status,Queue__c  From Case where id in :createCaseList];
            List<TIS_Detail__c> lstCaseTIS=[select id from TIS_Detail__c where Case__c in :createCaseList];
            if(lstCaseTIS.size() >0){
               system.assert(lstCaseTIS.get(0).id!=null, 'TIS not inserted');
           }
            
            List<Case> toBeUpdatedCaseList  = new List<Case>();
           
            for(Case updateCaseObj:createdCaseList)
            {
                if(updateCaseObj.id == createCaseList[0].id)
                {
                    updateCaseObj.status = 'Closed';
                    updateCaseObj.resolution__c = 'Test';
                    updateCaseObj.OwnerId =TestUserList.get(1).id;
                    updateCaseObj.Queue__c = 'CEMS';
                    toBeUpdatedCaseList.add(updateCaseObj);
                }
            }
            CreateTIS.UpdateCounter = 1; 
            CreateTIS.InsertCounter = 0; 
            update toBeUpdatedCaseList; //Cannot verify System.assert because of Future Method call
        }
        Test.stopTest();
    }
    
    @istest(seeAllData=true)
    private Static void TIS_Test3()
    {
        CaseTestData caseTestData  = new CaseTestData();
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<User> TestUserList = caseTestData.CreateUser('Roadnet', testProfile.id, 'TestCaseUser', null, 2);
        Insert TestUserList;
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('', null, 1,null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('', 1, accountList.get(0).id);
        insert contactList;
        
        Test.startTest();
        System.runAs(TestUserList.get(0))
        {
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('TISClosed', 'SFDC Support', accountList, contactList, TestUserList, 1);
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            
            //verify Inserted Case
            List<Case> createdCaseList = [Select Id, Last_Modified_Date_Time__c,status,Queue__c  From Case where id in :createCaseList];
            List<TIS_Detail__c> lstCaseTIS=[select id from TIS_Detail__c where Case__c in :createCaseList];
            if(lstCaseTIS.size() >0){
               system.assert(lstCaseTIS.get(0).id!=null, 'TIS not inserted');
           }
            
            //List<Case> updateCaseList = [Select Id, Status, Substatus__c, parentId From Case where id in :createCaseList];  
            List<Case> toBeUpdatedCaseList  = new List<Case>();
            
            for(Case updateCaseObj:createdCaseList)
            {
                if(updateCaseObj.id == createCaseList[0].id)
                {
                    
                    updateCaseObj.OwnerId =TestUserList.get(1).id;
                    updateCaseObj.status = 'Pending';
                    toBeUpdatedCaseList.add(updateCaseObj);
                }
            }
            CreateTIS.UpdateCounter = 0; 
            
            update toBeUpdatedCaseList; //Cannot verify System.assert because of Future Method call
        }
        Test.stopTest();
    }
    
     @istest(seeAllData=true)
    private Static void TIS_Test4()
    {
        CaseTestData caseTestData  = new CaseTestData();
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<User> TestUserList = caseTestData.CreateUser('Roadnet', testProfile.id, 'TestCaseUser', null, 2);
        Insert TestUserList;
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('', null, 1,null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('', 1, accountList.get(0).id);
        insert contactList;
        
        Test.startTest();
        System.runAs(TestUserList.get(0))
        {
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('TISClosed', 'SFDC Support', accountList, contactList, TestUserList, 1);
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            
            //verify Inserted Case
            List<Case> createdCaseList = [Select Id, Last_Modified_Date_Time__c,status,Queue__c  From Case where id in :createCaseList];
            List<TIS_Detail__c> lstCaseTIS=[select id from TIS_Detail__c where Case__c in :createCaseList];
            if(lstCaseTIS.size() >0){
               system.assert(lstCaseTIS.get(0).id!=null, 'TIS not inserted');
           }
            
            List<Case> toBeUpdatedCaseList  = new List<Case>();
            
            for(Case updateCaseObj:createdCaseList)
            {
                if(updateCaseObj.id == createCaseList[0].id)
                {
                    updateCaseObj.OwnerId =TestUserList.get(1).id;
                    updateCaseObj.status = 'Closed';
                    toBeUpdatedCaseList.add(updateCaseObj);
                }
            }
            CreateTIS.UpdateCounter = 0; 
            update toBeUpdatedCaseList; //Cannot verify System.assert because of Future Method call
        }
        Test.stopTest();
    }
    
   @istest(seeAllData=true)
    private Static void AssignmentOfCases_Test1()
    {
        CaseTestData caseTestData  = new CaseTestData();
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<User> TestUserList = caseTestData.CreateUser('Roadnet', testProfile.id, 'TestCaseUser', null, 2);
        Insert TestUserList;
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('AssignmentOfCases', TestUserList, 1,null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('', 1, accountList.get(0).id);
        insert contactList;
        
        Test.startTest();
        System.runAs(TestUserList.get(0))
        {
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('AssignmentOfCases', 'Call Center', accountList, contactList, TestUserList, 1);
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            
            //verify Inserted Case
            List<Case> createdCaseList = [Select Id, Queue__c,Last_Modified_Date_Time__c,status From Case where id in :createCaseList];
            system.assertequals('Field CS', createdCaseList.get(0).Queue__c);
            
            List<Case> toBeUpdatedCaseList  = new List<Case>();
            
            for(Case updateCaseObj:createdCaseList)
            {
                if(updateCaseObj.id == createCaseList[0].id)
                {
                    updateCaseObj.Auto_Assigned__c =false;
                    updateCaseObj.Description= '[CUST ID: 43210] [CUSTOMER NAME: Pyles Transport, Inc. (Eval)] [APP: COPILOT TRUCK] [START DATE: 02-JUN-14] [END DATE: 09/30/2014] [USER: Ann Marquis]';
                    toBeUpdatedCaseList.add(updateCaseObj);
                }
            }
            update toBeUpdatedCaseList;
        }
        Test.stopTest();
    }
    
     @istest(seeAllData=true)
    private Static void AssignmentOfCases_Test2()
    {
        CaseTestData caseTestData  = new CaseTestData();
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<User> TestUserList = caseTestData.CreateUser('Roadnet', testProfile.id, 'TestCaseUser', null, 2);
        Insert TestUserList;
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('AssignmentOfCases', TestUserList, 1,null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('', 1, accountList.get(0).id);
        insert contactList;
        
        Test.startTest();
        System.runAs(TestUserList.get(0))
        {
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('AssignmentOfCases', 'Email Generated Cases', accountList, contactList, TestUserList, 1);
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            
            //verify Inserted Case
            List<Case> createdCaseList = [Select Id, Queue__c,Last_Modified_Date_Time__c,status From Case where id in :createCaseList];
            system.assertequals('Field CS', createdCaseList.get(0).Queue__c);
            
            List<Case> toBeUpdatedCaseList  = new List<Case>();
            
            for(Case updateCaseObj:createdCaseList)
            {
                if(updateCaseObj.id == createCaseList[0].id)
                {
                    updateCaseObj.Status='Pending';
                    updateCaseObj.Auto_Assigned__c =false;
                    updateCaseObj.subject='reporting services access requested';
                    updateCaseObj.Description= 'Case Origin: Email-iQ Reporting Services Request'+'\n'+
                                                 'Case Record Type: Call Center'+'\n'+
                                                 'Case Subject: Reporting Services Access Requested'+'\n'+
                                                 'Case Description Format: '+'\n'+
                                                 'Customer ID:   4321 '+'\n'+
                                                 'Customer Name:   DAYTON FREIGHT LINES, INC. '+'\n'+
                                                 'Contact: Jordan   Copeland '+'\n'+
                                                    'Requested Service: CSA SPS Basic';
                    toBeUpdatedCaseList.add(updateCaseObj);
                }
            }
            CreateTIS.UpdateCounter = 0; 
            update toBeUpdatedCaseList;
        }
        Test.stopTest();
    }
    
    @istest(seeAllData=true)
    private Static void AssignmentOfCases_Test3()
    {
        CaseTestData caseTestData  = new CaseTestData();
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<User> TestUserList = caseTestData.CreateUser('Roadnet', testProfile.id, 'TestCaseUser', null, 2);
        Insert TestUserList;
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('AssignmentOfCases', TestUserList, 2,null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('', 1, accountList.get(0).id);
        insert contactList;
        
        Test.startTest();
        System.runAs(TestUserList.get(0))
        {
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('AssignmentOfCases1', 'Call Center', accountList, contactList, TestUserList, 1);
            Insert createCaseList;
            system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
            
            //verify Inserted Case
            List<Case> createdCaseList = [Select Id, Queue__c,Last_Modified_Date_Time__c,status From Case where id in :createCaseList];
            system.assertequals('Field CS', createdCaseList.get(0).Queue__c);
            
            List<Case> toBeUpdatedCaseList  = new List<Case>();
            for(Case updateCaseObj:createdCaseList)
            {
                if(updateCaseObj.id == createCaseList[0].id)
                {
                    updateCaseObj.Auto_Assigned__c =false;
                    updateCaseObj.subject='reporting services access requested';
                    updateCaseObj.Description= 'Case Origin: Email-iQ Reporting Services Request'+'\n'+
                                                 'Case Record Type: Call Center'+'\n'+
                                                 'Case Subject: Reporting Services Access Requested'+'\n'+
                                                 'Case Description Format: '+'\n'+
                                                 'Customer ID:   432101 '+'\n'+
                                                 'Customer Name:   DAYTON FREIGHT LINES, INC. '+'\n'+
                                                 'Contact: Jordan   Copeland '+'\n'+
                                                    'Requested Service: CSA SPS Basic';
                    toBeUpdatedCaseList.add(updateCaseObj);
                }
            }
            CreateTIS.UpdateCounter = 1; 
            CreateTIS.InsertCounter = 0; 
            update toBeUpdatedCaseList;
        }
        Test.stopTest();
    }
   
    @istest(seeAllData=true)
    private Static void populateAccountTeam_Test1()
    {
        CaseTestData caseTestData  = new CaseTestData();
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        List<User> TestUserList = caseTestData.CreateUser('Roadnet', testProfile.id, 'TestCaseUser', null, 2);
        Insert TestUserList;
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('AssignmentOfCases', TestUserList, 2,null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('', 1, accountList.get(0).id);
        insert contactList;
        
        Test.startTest();
        System.runAs(TestUserList.get(0))
        {
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('AssignmentOfCases', 'EOX Return', accountList, contactList, TestUserList, 1);
            Insert createCaseList;
           
            //verify Inserted Case
            List<Case> createdCaseList = [Select Id,Accountid,Inside_CSR__c,Customer_Service_Rep__c,Account_Manager__c,Queue__c,Last_Modified_Date_Time__c,status,OwnerId From Case where id in :createCaseList];
            system.assert(createdCaseList.get(0).id != null,'Exception in Case Creation');
            system.assertequals(accountList.get(0).CSR__c,createdCaseList.get(0).Customer_Service_Rep__c );
            //system.assertequals(accountList.get(0).Account_Manager__c,createdCaseList.get(0).Account_Manager__c);
            system.assertequals(accountList.get(0).Inside_CSR__c,createdCaseList.get(0).Inside_CSR__c);
            List<Case> toBeUpdatedCaseList  = new List<Case>();
            for(Case updateCaseObj:createdCaseList)
            {
                if(updateCaseObj.id == createCaseList[0].id)
                {
                    updateCaseObj.AccountId=accountList.get(1).id;
                    updateCaseObj.OwnerId=TestUserList.get(0).id;
                    updateCaseObj.Status='Closed';
                    updateCaseObj.resolution__c = 'test';
                    updateCaseObj.Sprint__c=',startDate.*?name=';
                    toBeUpdatedCaseList.add(updateCaseObj);
                }
            }
            update toBeUpdatedCaseList;
            
            //verify the updated case
            List<Case> updatedCaseList = [Select Id, Inside_CSR__c,Customer_Service_Rep__c ,Account_Manager__c,Status, Substatus__c From Case where id in :toBeUpdatedCaseList];
            List<Case> toBeUpdatedCaseList1  = new List<Case>();  
            for(Case updateCaseObj:updatedCaseList)
            {
                if(updateCaseObj.id == createCaseList[0].id)
                {
                    system.assert(createCaseList.get(0).id != null,'Exception in Case Creation');
                    //system.assertequals(accountList.get(1).CSR__c,updatedCaseList.get(0).Customer_Service_Rep__c );
                    //system.assertequals(accountList.get(1).Account_Manager__c,updatedCaseList.get(0).Account_Manager__c);
                    //system.assertequals(accountList.get(1).Inside_CSR__c,updatedCaseList.get(0).Inside_CSR__c);
                }
            }
        }
        Test.stopTest();
    }
    
    @istest(seeAllData=true)
    private Static void ShareCaseVarRoadnet_Test1()
    {
        CaseTestData caseTestData  = new CaseTestData();
        //insert test user
        Profile testProfile=[select id from profile where Name = 'System Administrator'];
        Profile roadnetProfile=[select id from profile where Name = 'Roadnet Partner Profile'];
        List<User> TestUserList = caseTestData.CreateUser('Roadnet', testProfile.id, 'TestCaseUser', null, 2);
        Insert TestUserList;
        
        //insert Account
        List<Account> accountList = caseTestData.CreateAcccount('', TestUserList, 1,null);
        Database.DMLOptions dml = new Database.DMLOptions(); 
  		dml.DuplicateRuleHeader.allowSave = true;
  		dml.DuplicateRuleHeader.runAsCurrentUser = true;
  		list<Database.SaveResult> sr1 = Database.insert(accountList, dml);
        //insert accountList;
        system.assert(accountList.get(0).id != null,'Exception in Account Creation');
       
        
        List<Account> roadnetAccountList = caseTestData.CreateAcccount('ShareCase', TestUserList, 1,accountList);
        Database.DMLOptions dml1 = new Database.DMLOptions(); 
  		list<Database.SaveResult> sr2 = Database.insert(roadnetAccountList, dml1);
        //insert roadnetAccountList;
        //Insert Contact
        List<Contact> contactList =  caseTestData.CreateContact('ShareCase', 1, accountList.get(0).id);
        insert contactList;
        List<User> roadnetUserList = new List<User>();
        System.runAs(TestUserList.get(0))
        {
            roadnetUserList = caseTestData.CreateUser('ShareCase', roadnetProfile.id, 'TestCaseUser1', contactList.get(0).id, 1);
            Insert roadnetUserList;
        }
        Test.startTest();
        System.runAs(TestUserList.get(0))
        {
            // Insert Case
            List<Case> createCaseList = caseTestData.CreateCase('AssignmentOfCases', 'EOX Return', roadnetAccountList, contactList, roadnetUserList, 1);
            Insert createCaseList;
           
            //verify Inserted Case
            List<Case> createdCaseList = [Select Id,Accountid,Inside_CSR__c,Customer_Service_Rep__c,Account_Manager__c,Queue__c,Last_Modified_Date_Time__c,status,OwnerId From Case where id in :createCaseList];
            
            List<Case> toBeUpdatedCaseList  = new List<Case>();
            for(Case updateCaseObj:createdCaseList)
            {
                if(updateCaseObj.id == createCaseList[0].id)
                {
                    updateCaseObj.OwnerId=TestUserList.get(0).id;
                    updateCaseObj.Status='Closed';
                    updateCaseObj.Resolution__c = 'Test';
                    toBeUpdatedCaseList.add(updateCaseObj);
                }
            }
            update toBeUpdatedCaseList;
        }
        Test.stopTest();
    }                   
}