@isTest(SeeAllData=True)
    private class TestCaseTemplateListController{
        public static testMethod void  testCaseTemplateListController(){

            User CurrentUser = [select UserType, ContactId, email  from User where Id =:UserInfo.getUserId() Limit 1];
            
            system.RunAs(CurrentUser){
                ApexPages.StandardController sdtCon;
                CaseTemplateListController newObj = new CaseTemplateListController(sdtCon);
                CaseTemplateListController newObj1 = new CaseTemplateListController();
                Template__c newTemplate = new Template__c();
                newTemplate.Name = 'Test Template';
                newTemplate.IsActive__c = true;
                newTemplate.NumTotal__c = 2;
                insert newTemplate;
                
                Templatedetail__c newTempDetail1 = new Templatedetail__c();
                newTempDetail1.TemplateID__c = newTemplate.Id;
                newTempDetail1.Name = 'RecordTypeId';
                newTempDetail1.Value__c = '01250000000DT5tAAG';
                insert newTempDetail1;
                
                newObj.templateID = ApexPages.currentPage().getParameters().put('tempID',newTemplate.Id);
                
                newObj.asce = true;
                newTemplate.Folder__c = 'AllFolders';
                update newTemplate;
                newObj.SelectedRecords();
                newTemplate.Folder__c = 'NaviGo';
                update newTemplate;
                newObj.SelectedRecords();
                newObj.asce = false;
                newObj.folder = 'AllFolders';
                newObj.SelectedRecords();
                newObj.folder = 'NaviGo';
                newObj.SelectedRecords();
                newObj.TemplateID = newTemplate.Id;
                
                newObj.createCase();
                newObj.asce = true;
                newObj.ChangeOrder();
                newObj.asce = false;
                newObj.ChangeOrder();
                List<SelectOption> sel = newObj.getoptions();
                newObj.setoptions(sel);
                
                Account newAccount = new Account();
                newAccount.Name = 'SFDC';
                newAccount.Type = 'Other';
                newAccount.BillingStreet = 'Test Address';
                newAccount.BillingCity = 'Test City';
                newAccount.BillingCountry = 'Test Country';
                newAccount.QWBS_Status__c = 'Contract Customer';
                newAccount.QWBS_Cust_ID__c='3452345452';
                insert newAccount;
                ApexPages.currentPage().getParameters().put('AccountId',newAccount.Id);
                
                newObj.createNewCase();
                
                Contact newcnt=new Contact();
                newcnt.FirstName='SFDC';
                newcnt.LastName='Salesforce';
                newcnt.MailingState='CA';
                newcnt.AccountId = newAccount.Id;
                insert newcnt;
                ApexPages.currentPage().getParameters().put('ContactId',newcnt.Id);
                newObj.createNewCase();
                
                test.startTest();
                NMC_Account__c nmcacct = new NMC_Account__c(Name='Test NMC Acct', NMC_Account_Name__c = 'Test NMC Name');
                nmcacct.account__c = newAccount.id;
                insert nmcacct;
                ApexPages.currentPage().getParameters().put('NMCAcct',nmcacct.Id);
                newObj.createNewCase();
                test.stopTest();
                
                list<Templatedetail__c> newTempDetail = new list<Templatedetail__c>();
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Description',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Status',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Reason',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Origin',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Subject',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Type',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Priority',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Call_Back__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Queue__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Product__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Category__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Queue__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Type_Level_2__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Area_Level_3__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Technical_Tip__c',Value__c='true'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Customer_Complaint__c',Value__c='true'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Human_Interest__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Engineering_Tracking__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Substatus__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='System__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='RMA__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Serial__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Firmware__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Siebel_ID__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Resolution__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Equipment_ID__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Created_by_Queue__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Shift_Report__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Add_Remove__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Aux_Sensor__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Cargo_Sensor__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Contract_Description__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Contract_Product__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Cross_Street_Location__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Customer_Hosted__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Door_Sensor__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='End_of_Eval__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Internal_Default_for_Status_Rpt_Interval__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Qualcomm_Hosted__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Queued_Status_Report_Interval__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Requested_Default_NMC_Acct_for_Unit_Type__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Requested_NMC_Account_Status__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Requested_Retention_Period__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Services__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Telecom_For_Customer_Hosted__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Telecom_For_Third_Party_Hosted__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Test_Account__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Third_Party_Hosted__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='Unit_Type__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='CI__c',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='AccountId',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='ContactId',Value__c='test'));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='NMC_Account__c',Value__c=nmcacct.Id));
                newTempDetail.add(new Templatedetail__c(TemplateId__c=newTemplate.Id,Name ='AccountId',Value__c = newAccount.Id));
                
                if(newTempDetail.size()>0)
                {
                    insert newTempDetail;
                }
                newObj.createNewCase();
                newObj.SelectedRecords();
            }
        }
    }