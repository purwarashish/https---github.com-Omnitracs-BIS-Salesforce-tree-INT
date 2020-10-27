/*******************************************************************************
 * File:  ContractHandoffExtension.cls
 * Date:  February 21, 2011
 * Author:  Joseph Hutchins
 *
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *  *******************************************************************************/
public class ContractHandoffExtension
{
    //   BE ADVISED I LEARNED HOW TO CREATE A NEW VF BUTTON WHERE WE DONT NEED THESE HARDCODED IDS
    public static final string LIVE_OPPT_FIELD_ID = 'CF00N30000008uKA4_lkid';//  this is for the ContractHandoff2 object
    public static final string LIVE_ACCOUNT_FIELD_ID = 'CF00N30000008uIKn_lkid';// same here for the contracthandoff2 object
    public static final string MIBOS_SANDBOX_OPPT_FIELD_ID = '00NW0000000ZFR0_lkid';
    public static final string MIBOS_SANDBOX_ACCOUNT_FIELD_ID ='00NW0000000ZFQo_lkid';
    public static final string MIBOS_SANDBOX_CONTRACT_FIELD_ID  ='00NW0000000ZFQv_lkid';
    
    public static final string SANDBOX_CONTRACT_FIELD_ID = 'CF00NV0000000f0Je_lkid';//  sandbox field id
    public static final string LIVE_CONTRACT_FIELD_ID = 'CF00N3000000BhuVl_lkid';//  sandbox field id
    
    public static final string INFUFFICIENT_PRIVILIEGES_ERROR_MESSAGE = 'Insufficient Privileges.  ' + 
                   'You do not have the level of access necessary to perform the operation you requested.' + 
                   'Please contact the owner of the record or your administrator if access is necessary.';
                   
    private PageReference mypageref = apexpages.currentpage();
    private Map<string, string> myMap = mypageref.getparameters();
    private boolean newMode = false;
    private User[] consultantsAndSales = 
        [select id, name, email, firstname, lastname from User where isactive = true and
        (profile.name like '%Consulting%' or
        profile.Name like '%CS Professional%' OR  
        profile.name like '%Sales%' or 
        profile.name = 'System Administrator') order by lastname, firstname ];
    
    public ContractHandoffExtension(apexpages.standardcontroller stdcont)
    {
        contractHandoff = new Contract_Handoff2__c();
        editMode = false;
                
        string opptFieldId;
        string accountFieldId;
        string contractFieldId;
        if (util.isRnEnvironment)
        {
            opptFieldId = LIVE_OPPT_FIELD_iD;
            accountFieldId = LIVE_ACCOUNT_FIELD_ID;
            contractFieldId = LIVE_CONTRACT_FIELD_ID;
        }
        else
        {
            opptFieldId = MIBOS_SANDBOX_OPPT_FIELD_ID;
            accountFieldId = MIBOS_SANDBOX_ACCOUNT_FIELD_ID;
            contractFieldId = MIBOS_SANDBOX_CONTRACT_FIELD_ID;
        }
         
        if (myMap.get('id') != null)//  id is in the url, the page isin edit mode
        {
            editMode = true;
            newMode = false;
        }
        else
        {
            editMode = false;
            newMode = true;
        }
        
        if (newMode)
        {
            //  this can come from an account or opportuinty or it could come from nowhere, the user now has the ability to change the account or oppt
            string opptid = myMap.get('opptId');
            
            string accountId = myMap.get('acctId');
            string contractId = myMap.get('contractId');
            
            system.debug('##################################################-'+myMap);
            if (opptId != null && opptId.length() != 0)
            {
                system.assertNotEquals(null, opptid);
                oppt = queryOppt(opptid);
                                            
                system.assertNotEquals(null, oppt.accountId);
                account = [select id, name, PrimaryERPSystem__c, Industry, fleetsize__c, 
                    number_of_depots__c from account where id =: oppt.accountid  ];//queryAccount(oppt.accountId);
                
                contractHandoff.account__c = account.id;
                contractHandoff.Opportunity__c = oppt.id;
                contractHandoff.champion__c = queryOppContRole(oppt.id, 'Sponsor');
                contractHandoff.Blocker__c = queryOppContRole(oppt.id, 'Adversary');
                    
                //  pre pop answer questions with help text
                prePopSalesHandoffFields();
                
                //  i get a couple of error emails about the contract not being set... i queried for contract handoffs whose contract is not set
                //  and found only 3 test ones.  to help with future diagnosis, this will shot out the account id or oppt id if the ocntract id isnt 
                //  set so i can easily see where the problem is
                if (contractid == null)
                {
                    //  before throwing the excpetion, let's see if we can't query the contract that the oppoturnity points to
                    contractId = oppt.Contract__c;
                }
                //  if the contractid is set, go ahead an prepopute the fields
                if (contractid != null)
                {
                    contract = [select id, accountid, contractNumber, Closed_Opportunity__c from contract where id =: contractId];
                    contractHandoff.Contract__c = contractId;
                }
                
                        
            }
            else if (contractId != null && contractId.length() != 0)
            {
                contractHandoff.Contract__c = contractId;//  can we populate oppt and account info here? yes, the acount and opt is stored on the contract
                contract = [select id, accountid, contractNumber, Closed_Opportunity__c from contract where id =: contractId];
                account = [select id, name, PrimaryERPSystem__c, Industry, fleetsize__c, 
                    number_of_depots__c from account where id =: contract.accountid  ];//queryAccount(oppt.accountId);
                
                oppt = queryOppt(contract.Closed_Opportunity__c);    
                
                contractHandoff.account__c = contract.Accountid;
                contractHandoff.Opportunity__c = contract.Closed_Opportunity__c;
                contractHandoff.Contract__c = contract.id;
                
                
                contractHandoff.champion__c = queryOppContRole(contract.Closed_Opportunity__c, 'Sponsor');
                contractHandoff.Blocker__c = queryOppContRole(contract.Closed_Opportunity__c, 'Adversary');
                
                //  pre pop answer questions with help text
                prepopSalesHandofffields();
            }
            
            else if (accountid != null && accountId.length() != 0)
            {
                contractHandoff.Account__c = account.id;
            }
            
            originalHandoff = contractHandoff.clone(false, true);
        }
        else
        {
            //  assuming its in edit mode,there really isn't anything else that changes from edit to new, only differnce
            //  is with the new mode the oppt field id is passed in, whereaas
            //  so we need to use the mymap to get the id, query the contacthandoff, query opt and the order
            system.assertNotEquals(null, stdcont.getid());
            contractHandoff = queryContractHandoff(stdcont.getId());
            originalHandoff = contractHandoff.clone(false, true);
            
            system.assertNOtEquals(null, contractHandoff.account__c);
            try
            {
                account = [select id, name, PrimaryERPSystem__c, Industry, fleetsize__c, 
                    number_of_depots__c from account where id =: contractHandoff.Account__c  ];//queryAccount(contractHandoff.Account__c);
                
                if (contractHandoff.Opportunity__c != null)
                {
                    oppt = queryOppt(contractHandoff.Opportunity__c);
                }
                if (contractHandoff.Contract__c != null)
                {
                    contract = [select id, accountid, contractNumber, Closed_Opportunity__c from contract where id =: contractHandoff.Contract__c];
                }
            }
            catch(Exception e)
            {
                throw new myException('query failed for account with id ' + contractHandoff.account__c + ' due to ' + e.getMessage());
            }            
        }
    }
    
    public Opportunity oppt {get;set;}
    public account account{get;set;}
    public Contract contract{get;set;}
    public Contract_Handoff2__c contractHandoff{get;set;}
    private Contract_Handoff2__c originalHandoff{get;set;}
    
    public boolean editMode{get;set;}

  /*public string multiDaycheckbox
    {
        get
        {
           if (account == null)
           {
               return null;
           }
           else
           {
               return (account.Multi_Day_Checkbox__c ? 'Yes' : 'No');
           }
        }
    }*/
    @testvisible private void prepopSalesHandoffFields()
    {
        contractHandoff.Project_Overview__c = '[Give a very brief summary of the project outlining the planned objectives.]';
        contractHandoff.Project_organization__c = '[List all project stakeholders including contact information, title, phone, and email address]';
        contractHandoff.Point_of_contact_for_implementation__c = 'Please give contact detail, and any pertinent background information.\n\n' + 
            'Point of Contact Name - \n\n' + 
            'Point of Contact Email - \n\n' + 
            'Point of Contact Phone # - ';
        contractHandoff.Target_Schedule_Information__c = '[Please give schedule detail, and any hard cutoffs or pertinent issues we needs to know about and work around]\n\n' + 
            'Target End Date - [Please enter their Target End Date if applicable]';
        contractHandoff.Company_Background__c = '[Please give relevant company background]';
        contractHandoff.Host_System__c = 'Host Name - [Please provide name and a description of their primary ERP (host) system. Does an existing interface exists?]';
        contractHandoff.Host_Exported_Flat_Files_or_Web_Services__c = 'Web Services/Flat File Creation - [Has the need for a Space Delimited (NOT CSV) format been explained? How do they anticipate begin able to create this file? Please indicate any potential pitfalls with file creation.]';
        contractHandoff.Contract_Information__c = 'Industry - [Please enter their industry - Beer, Beverage, Produce, Fuel, etc.]\n\n' + 
            'Geographic Area - [Please enter their geographical area]\n\n' + 
            'Number of Depots - [Please enter the number of depots]\n\n' + 
            'Number of Customer Locations - [Please enter the number of cust locations]\n\n' + 
            'Fleet Size - [Please enter their Fleet Size (total & per depot if more than 1)]';
        contractHandoff.Scenarios__c = '[Were you able to uncover any workarounds? If yes, please provide details.]';
        contractHandoff.Products_question__c = '[Provide a list of RTI Porudcts sold to the customer including the priority/order in which the customer expects the products to be delivered. - RN, TP MC, FL, TM, RIC, etc]';
        contractHandoff.Product_Usage__c = '[How will they be using the software? Please note any special usage - such as MC without RN or other outside product integration.]';
        contractHandoff.Product_goals__c = '[Provide the overall goal of using our products including the customer\'s measure of success criteria, perceived benefits of using our products. This is especially important in dynamic scnerios i.e. taking trucks off the road, reducing miles, overtime, etc.]';
        contractHandoff.Product_Drivers__c = '[List the events which caused the customer to purchase our products.]';
        contractHandoff.roadnet__c = 'Routing Type - [Dynamic or Standard?]\n\n' +
            'Same/Next Day - [Please Enter if they route same day or for next day deliveries]\n\n' + 
            'Multiple Day/Overnight Routes, pickups, backhauls, or reloads - [Please indicate which, if any, apply]\n\n' + 
            'Number of stops per route - [Please enter the approx. number of stop/route]\n\n' +
            'Time Windows - [Please indicate if present]\n\n' +
            'Driver Pay Type - [Please indicate if drivers are paid by mile,hour,stop,case,etc.]\n\n' +
            'Number of Vehicles - [Please enter the approx. number of stop/route]\n\n' + 
            'Hours Per Route - [Please indicate how many hours a typical route is]\n\n' +
            'Order Cutoff - [Please indicate any hard order cutoffs]\n\n' +
            'Notes - [Please enter any special notes on Roadnet - M-S instead of M-F, barriers, needs, or options suggetes should be listed here. (ie. cells, routes are driver owned, etc.)]';
        contractHandoff.Terrority_Planner_question__c = 'Please note TP data - [rerouting for drivers, or sales or both?]\n\n' +
            'Please note if known: [Cycle - Weekly, monthly, quarterly deliveries]\n\n' +
            'Seasonality - [High and Low seasons, also sometimes holiday season]\n\n' +
            'Other - [Please enter any other specifics]';
        contractHandoff.MobileCast__c = 'Phone type/name - [Please note the type of phone the customer is purchasing. and specific phone, if known **If suggested by sales, please provide the 3rd party suggested for MobileCast devices - name of contact & email/phone information]';
        contractHandoff.Telematics__c = '[Please provide the customer goals for Telematics such as idling reduction, speeding, etc]';
        contractHandoff.Route_Test_or_RFP__c = 'Sales Engineer- [If a route test was completed, which sales engineer (se) was involved? Note: if a route test was completed, SE should be included during the handoff meeting. Any available demo files/work should be sent to the project manager.]';
        contractHandoff.vehicle_list__c = '[Is there a vehicle list available? If not, when will it be available?]';
            
    }

    public integer numOfRows
    {
        get
        {
            return 5;
        }
    }
    public integer numOfCols
    {
        get
        {
            return 100;
        }
    }
    public string hostSystem
    {
        get
        {
            if (account != null)//  got a null exception error
            {
                return (account.PrimaryERPSystem__c == null ? 'None' : account.PrimaryERPSystem__c);    
            }
            else
            {
                return 'None';
            }
            
        }
    }
    public Attachment rfp
    {
        get
        {
            //  so we are bascially lokoing for any attachment that has the text RFP in there. prety much.
            Attachment attachment;
            try
            {
                attachment  = 
                 [select id, name from Attachment where name like '%RFP%' and parentid =: oppt.id order by lastmodifieddate desc limit 1];
                return attachment;
            }
            catch(Exception e)
            {
                return new Attachment();
            }
        }
    }

    @testvisible private static id queryOppContRole(id opptid, string role)
    {
        OpportunityContactRole blarg;
        try
        {
            blarg = [select id,  contact.id, contact.name from OpportunityContactRole where Role =: role and OpportunityId =: opptid order by lastmodifieddate limit 1 ];
            return blarg.contact.id;
        }
        catch(Exception e)
        {
            return null;
        }       
    }
    
    public PageReference save()
    {
        Database.UpsertResult sr = DataBase.upsert(contractHandoff);
        if (sr.isSuccess())
        {
            //  we need to add some new logic here if the is complete checkbox is being set, then send email alert to oppt owner that the sales
            //  handoff has completed and link to it  
            
            if (hasIsCompleteChanged && contractHandoff.is_Complete__c)
            {
                emailOpptOwner();
            } 
            PageReference pr = new PageReference('/' + sr.getid());
            pr.setRedirect(true);
            return pr;
        }
        else
        {
            throw new myException('Failed to save record.');
        }
    }
    private boolean hasIsCompleteChanged
    {
        get
        {
            return originalHandoff.Is_Complete__c != contractHandoff.Is_Complete__c;
        }
    }
    public void emailOpptOwner()
    {
        
        //  the oppt owner shouldve been queried at the init function so its basiclaly just creating a simple email that is sent out to sales person
        list<string> toEmail = new List<string>();
        string lastmodifiedUsername = [select name from user where id =: userInfo.getUserId()].name;
        
        string linkToOppt = oppt == null ?
           'No Opportunity Tied to Sales Handoff.'  : EmailClassRoadnet.createHyperLink(Util.base_url + oppt.id, oppt.name);
        string linkToAccount = account == null ?
           'No Account Tied to Sales Handoff.' : EmailClassRoadnet.createHyperLink(Util.base_url + account.id, account.name);
        string linkTocontract = contract == null ?
           'No Contract Tied To Sales Handoff.' : EmailClassRoadnet.createHyperLink(util.base_url + contract.Id, contract.ContractNumber);
        
        string subject = 'Sales Handoff has been completed for ' + oppt.name + ' by ' + lastmodifiedUsername;
        string body = 'Sales Handoff has been completed for opportunity ' + linkToOppt + 
           ' with assoicated contract ' + linktoContract + 
           ' belonging to account ' + linkToAccount + '.';
        
        //  it is possible for a contrat handoff to belong an contract or oppt and there is no promise that it will belong to either or both
        //  so i'll check both to see if i can find out if its pro services from there
        
        if (oppt.owner.email != null)
        {
            toEmail.add(oppt.owner.email);
            /*david ginn is no longer apart of the team, amy took his spot, but she doesnt like getting these emails
            if (isHandoffAssoicatedWithProfServObject())
            {
                Apex_Email_Alert__c aea = [select id, to_email__c from Apex_Email_Alert__c where name = 'Prof Serv Sales Handoff Completed' and Object__c = 'Contract_Handoff2__c'];
                toEmail.addAll(ContractClassHelperClass.parseString(aea.To_Email__c));
            }*/
        }
            
        EmailClassRoadnet.sendEmailAsync(toEmail, null, null, subject, body, body, null);
    }
    public boolean isHandoffAssoicatedWithProfServObject()
    {
        //  i designed this kind of wrong, i was under the assumption that a contrat handoff could have a blank oppt or contract field or both
        //  however as i start testing, it looks liek the contract handoff needs to have an opppt at the latest
        //  so we can check for the oppt if it exists
        //  the new logic here will be to check the contracts recordt tpe if the oppts is missing
        
        //  because of this i need to check the oppts recordtype name and the contract recordtype name before confirmting
        // that the contract handoff is ascoited with a prof serv contract oppt
        if (contractHandoff.Opportunity__c != null)
        {
            system.AssertNotEquals(true, Util.isBlank(contractHandoff.Opportunity__r.Recordtype.name));
            if (isOpportunityProfServ(contractHandoff.Opportunity__r.recordtype.name))
            {
                return true;
            }           
        }
        else if (contractHandoff.Contract__c != null)//  oppt was null, we now need to check the contract recordtype name
        {
            system.AssertNotEquals(true, Util.isBlank(contractHandoff.Contract__r.Recordtype.name));
            if (isContractProvServ(contractHandoff.Contract__r.Recordtype.name))
            {
                return true;
            }
        }
        return false;//  return false by default.  this could mean the contracthandoof didnt have an oppt or a contract or both
    } 
    public static boolean isOpportunityProfServ(string recordTypeName)
    {
        if (util.isBlank(recordTypeName))
        {
            return false;
        }
        else
        {
            return 
              recordtypeName == 'Dom. Consulting Days' ||
              recordtypeName == 'Dom. Special Projects' ||
              recordtypeName == 'Dom. RN University' ||
              recordtypeName == 'Dom. Special Projects' ||
              recordtypeName == 'Intl. Consulting Days' ||
              recordtypeName == 'Intl. Special Projects' ||
              recordtypeName == 'Intl. Special Projects';
            
        }
        
        
        return null;
    }
    public static boolean isContractProvServ(string recordTypeName)
    {
        if (util.isBlank(recordTypeName))
        {
            return false;
        }
        else
        {
            return
               recordTypeName == 'Dom - Database Projects' ||
               recordTypeName == 'Dom. Consulting Days' ||
               recordTypeName == 'Dom. Projects' ||
               recordTypeName == 'Dom. RN University' ||
               recordTypeName == 'International Pro. Services' ||
               recordTypeName == 'Professional Services';
        }
        
    }
   
    
    private static Opportunity queryOppt(id opptId)
    {
        return [select id, accountid, Contract__c, Owner.Name, OwnerId, Owner.email, Name from Opportunity where id =: opptId];
    }
    
    
    private static Contract_Handoff2__c queryContractHandoff(id chid)
    {
        return [Select c.Vehicle_List__c, c.blocker__r.name, c.Terrority_Planner_question__c, c.Telematics__c, c.Target_Schedule_Information__c, 
            c.SystemModstamp, c.Scenarios__c, c.Route_Test_or_RFP__c, c.Roadnet__c, c.Question_9__c, c.Question_8__c, c.Question_7__c, c.Question_6__c,
            c.Question_5__c, c.Question_4__c, c.Question_3__c, c.Question_2__c, c.Question_1__c, c.Question_10__c, c.Project_Overview__c, 
            c.Project_Organization__c, c.Products_question__c, c.Products__c, c.Product_Usage__c, c.Product_Goals__c, c.Product_Drivers__c, 
            c.Point_of_Contact_for_Implementation__c, c.OwnerId, c.Opportunity__c, c.Name, c.MobileCast__c, c.LastModifiedDate, 
            c.LastModifiedById, c.LastActivityDate, c.IsDeleted, c.Id, c.Host_System__c, c.Host_Exported_Flat_Files_or_Web_Services__c, 
            c.CreatedDate, c.CreatedById, c.Contract_Information__c, c.ConnectionSentId, c.ConnectionReceivedId, c.Company_Background__c,
            c.Contract__c, c.Champion__c, c.Blocker__c, c.Attachments__c, c.Additional_Comments__c, c.Account__c, c.is_complete__c,
            c.Contract__r.RecordtypeId, c.Contract__r.Recordtype.name, c.Opportunity__r.RecordtypeId, Opportunity__r.RecordType.Name, c.CreatedBy.name 
            From Contract_Handoff2__c c 
               where id =: chid];
    }
    
    public static ApexPages.StandardController gencon(Contract_Handoff2__c ch, string mode)
    {
        pagereference pageRef=new pagereference('Page.OrderMasterExtension');
        test.setcurrentpage(pageRef);
        
        string opptfieldId;
        opptFieldId = LIVE_OPPT_FIELD_iD;
        string contractFieldId =  LIVE_CONTRACT_FIELD_ID;
        
        if (mode == 'new')
        {
            ApexPages.currentPage().getParameters().put(opptfieldId,'0063000000NzMrd');
            ApexPages.currentPage().getParameters().put(contractFieldId,'80030000000SUcK');//  test cotnract that exists int hel ive and sandbox numbered 00049240
        }

        else// edit
        {
            ApexPages.currentPage().getParameters().put('id', ch.id);
        }
        
        return new ApexPages.standardController(ch);
    }

    public static Contract_Handoff2__c CreateTestConHandOff()
    {
        Contract_Handoff2__c er = new Contract_Handoff2__c();
        Contract testContract = [select id, accountid from contract where accountid != null limit 1];
        
        //Opportunity testOppt = '0063000000qmwyZ';// hard coded due to ridicolus problems deploying[select id, accountid from opportunity limit 1];
        er.Opportunity__c = [select id from opportunity limit 1].id;
        
        er.Account__c = testContract.AccountId;
        er.Contract__c = testContract.Id; //  hardcoding becaue the note above says its hard coded due to problems with testing        
        database.saveResult sr = database.insert(er);
        if (sr.isSuccess())
        {
            er = [Select c.Question_8__c, c.Question_7__c, c.Question_6__c, c.Question_5__c, 
                c.Question_4__c, c.Question_3__c, c.Question_2__c, c.Question_1__c, c.OwnerId, c.Opportunity__c, c.Name, c.account__c,
                c.LastModifiedDate, c.LastModifiedById, c.Id, c.CreatedDate, c.CreatedById, 
                c.Champion__c, c.Blocker__c From Contract_Handoff2__c c where id =: sr.id];
        }
        else
        {
            er = null; //throw new myException('could not create Order due to wut');
        }
        return er;
    } 

    private class InsufficientPrivilegesException extends Exception{}
    private class MyException extends Exception{}
    
}