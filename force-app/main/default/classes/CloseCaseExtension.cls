/*******************************************************************************
 * File:  CloseCaseExtension.cls
 * Date:  June 30th, 2009
 * Author:  Joseph Hutchins
 *
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *  *******************************************************************************/
public class CloseCaseExtension 
{
    
    //  used for throwing custom exceptions
    public class myException extends Exception{}
    
    //  **********  Member Variables  **********
    private Case theCase;
    private Case_Event__c m_finalCaseEvent;
    private Map<string,string> urlParameterMap;
    public boolean isSubmittingToKnowledgeBase = false;
    //private Solution solution = new Solution();
    //public boolean notifyContactOnCaseClose = false;
    private Case_Event__c caseEvent = new Case_Event__c();
    private Case_Event__c[] caseEventsAssociatedWithCase = new List<Case_Event__c>();
    //public string contactEmailAddress;
    
    //  **********  Constructor(s)  ***********
    public CloseCaseExtension(apexpages.standardcontroller stdcontroller)
    {
        theCase = new Case();
        urlParameterMap = new Map<string, string>();
        //  get the parmareters from the url and assign it the map
        PageReference mypageref = apexpages.currentpage();
        theCase = (Case)stdController.getRecord();
        m_finalCaseEvent = new Case_Event__c();
        m_finalCaseEvent.Case__c = theCase.id;
        
        //solutionCategory = new list<string>();
        
        if (theCase.id != null)
        {
            theCase = [select id, subject, accountid, description, recordType.name, casenumber, contactId, email__c, status, closed_by__c, 
               IsOkToSendAutoEmail__c, account.Spotlight_Account__c,
               lastmodifieddate, Start_Time__c, Time_Spent__c, OwnerId, Reason__c, 
               //Sub_Reason__c, 
               IsVisibleInSelfService, 
               Solution__c, Product_PL__c, Sub_Reason_PL__c
               from case where id =: theCase.id];
            
            //  user will have ability to change the cases value here and the case event should match its value
            m_finalCaseEvent.Display_in_Customer_Portal__c = theCase.IsVisibleInSelfService;
        
            theCase.Start_Time__c = DateTime.now();
            //theCase.End_Time__c = null;
        }
        
        urlParameterMap = mypageref.getparameters();
        
        //initSolutionFields(theCase);
        //  so i guess if the case is customer portal and the contact has not opted out of email then we default to notify contact on case close
        //  johns asked if this was defaulted.  i will allow it to default if contact has not opted out
        //notifyContactOnCaseClose = false;//  by default
    
        //isOldCaseReason = !CaseClassHelperClass.isCaseValidReason(theCase.Reason2__c, theCase.Product__c);
        
        defineProductPicklist();
        //  this logic is to make sure if the case has a product selected that the product picklist doesn't have (like an now deactivated product)
        //  we still want the product to show up in the product list as selectable
        /*if (!doesProductExistInPicklist(theCase.Product__c, productPicklist.options))
        {
            //  product selected for the case doesn't exsit in the product picklist, query and add the product to the picklist
            try
            {
                Product2 tempProduct = [select id, name from Product2 where id =: theCase.product__c];
                if (tempProduct != null)
                {
                    //  placement in the list does not matter, as long as it is present
                    productPicklist.options.add(new selectoption(tempProduct.id, tempProduct.name));
                }
            }
            catch(Exception e)
            {
                //  we dont want to prevent the entire case from being closed if the product cant be queried, the user will just have to pick a new product
                //  which is something they wouldve done anyway
            }
            
        }*/
        
        //productPicklist.selection = theCase.Product__c;
        defineCaseReasonPicklist();
        caseReasonPicklist.Selection = theCase.Reason__c;
        
        defineSubReasonPicklist();
        //subReasonPicklist.selection = theCase.Sub_Reason__c;
        
    }
    
    
    //  **********  Setters and Getters  **********
    public string isVisibleInSelfServiceFieldLabel
    {
        get
        {
            return isVisibleInSelfServiceFieldLabel;
        }
    }
    public static string isVisibleInSelfServiceFieldLabel
    {
        get
        {
            return 'Contact Receives Case Emails';
        }
    }
    public Case_Event__c finalCaseEvent
    {
        get
        {
            return m_finalCaseEvent;
        }
        set
        {
            m_finalCaseEvent = value;
        }
        
    }
    public PL productPicklist
    {
        get
        {
            if (productPicklist == null)
            {
                productPicklist = new PL();
            }
            return productPicklist;
        }
        set;
    }
    
    public PL caseReasonPicklist
    {
        get 
        {
            if (caseReasonPicklist == null)
            {
                caseReasonPicklist = new PL();
            }
            return caseReasonPicklist;
        }
        set;
    
    }
    public PL subReasonPicklist
    {
        get 
        {
            if (subReasonPicklist == null)
            {
                subReasonPicklist = new PL();
            }
            return subReasonPicklist;
        }
        set;
    
    }
    //public Case_Event__c getCaseEvent(){return caseEvent;}
    //public void setCaseEvent(Case_Event__c ce){ caseEvent = ce;}
    public Case gettheCase(){return theCase;}
    public void settheCase(Case b){theCase = b;}
    //public Solution getSolution(){return solution;}
    //public void setSolution(Solution s){solution = s;}
    //public boolean getIsSubmittingToKnowledgeBase(){return isSubmittingToKnowledgeBase;}
   // public void setIsSubmittingToKnowledgeBase(boolean b){isSubmittingToKnowledgeBase = b;}
    //public boolean getNotifyContactOnCaseClose(){return notifyContactOnCaseClose;}
    //public void setNotifyContactOnCaseClose(boolean b){notifyContactOnCaseClose = b;}
   // public string getContactEmailAddress(){return contactEmailAddress;}
    //public void setContactEmailAddress(string s){contactEmailAddress = s;}
    //public void setCaseEventSubject(string s){caseEvent.subject__c = s;}
    //public void setCaseEventDetails(string s){caseEvent.Details__c = s;}
    //public void setSolutionName(string s){solution.solutionName = s;}
    //public string[] solutionCategory{get; set;}
    public boolean isOldCaseReason{get;set;}
    
    public boolean isTimeSpentRequired
    {
        get
        {
            //  needs to be a domestic support case
            if (theCase == null)
            {
                return false;
            }
            else
            {
                return theCase.Recordtype.Name == 'Support'; //&& !theCase.Is_International_Support_Case__c;
            }
        }
    }
    public string standardAccountAlertDetail
    {
        get
        {
            return 'Please Treat This Customer With The Utmost Care';
        }
    }
    
    public string spotlightAccountTitle
    {
        get
        {
            return 'This is a Spotlight Account!';
        }
    }
    
    public string accountIsEvalStatusTitle
    {
        get
        {
            return 'This Account is On Evaulation Status';
        }
    }
    public static boolean doesProductExistInPicklist(id productId, List<selectOption> options )
    {
        for (Selectoption so : options)
        {
            
            if (so.getValue() != '--None--' && productId == so.getValue())
            {
                return true;
            }
        }
        return false;
    }

    public boolean isCaseSupport
    {
        get
        {
            if (theCase == null)
            {
                return false;
            }
            else
            {
                return (theCase.REcordtype.name == 'Support');
            }
        }
    }
    
    public integer caseMinutes
    {
        get
        {
            if (thecase.Start_Time__c == null) //|| theCase.End_Time__c == null)
            {
               return 0;
            }
            else
            {
                /*integer minutes = integer.valueOf(CaseClassHelperClass.timeBetweenInMinutes(theCase.Start_Time__c, theCase.End_Time__c));
                
                if (minutes < 1)
                {
                    return 1;
                }
                else
                {
                    return minutes;
                }
                */
                return 0;
            }
        }
    }
    //  **********  Public Instance Functions  ***********
    public PageReference now()
    {
        //theCase.End_Time__c = DateTime.now();
        return null;
    }
    public PageReference back()
    {
        return new PageReference('/' + theCase.id);
    }

    public PageReference save()
    {
        //Database.SaveResult saveResultForSolution;
        PageReference concurrentCheck = ConcurrentEditChecker.checkForConcurrentUpdate(theCase);
            
        if (concurrentCheck != null)
        {
           return concurrentCheck;  
        }
        else
        {
            if (isTimeSpentRequired)
            {
                boolean isOkToSave = true;
                //  the user shouldve set a case reason and sub reasson so first check that they are set
                /*if (theCase.Product_PL__c == null)
                {
                    theCase.Product_PL__c.addError('Please pick a product');
                    isOkTosave = false;
                }
                if (theCase.Case_Reason_PL__c == null)
                {
                    theCase.Case_Reason_PL__c.AddError('Please pick a valid case reason');
                    isOkTosave = false;
                }
                &*/
                if (theCase.Sub_Reason_PL__c == null)
                {
                    theCase.Sub_Reason_PL__c.addError('Please pick a valid sub reason');
                    isOkToSave = false;
                }
                
                if (!isOktoSave)
                {
                    return null;
                }
                else
                {
                    //theCase.Product__c = productPicklist.selection;
                    //theCase.Reason2__c = caseREasonPicklist.selection;
                    //theCase.Sub_Reason__c = subReasonPicklist.selection;
                    //isOldCaseReason = false;
                }
            }
          
            if (checkForRequriedFields())
            {
                theCase.status = 'Closed';
                
                try
                {
                    update theCase;
                }
                catch(Exception e)
                {
                    theCase.addError('Failed to update the case\'s status to closed due to ' + e.getMessage());
                    //EmailClass.sendErrorEmail('Failed to update the case\'s status to closed due to ' + e.getMessage(), theCase.id);
                    return null;
                }
                //  the case trigger now handles this, we dont need it to do it here any longer
                //CaseClassHelperclass.createCaseTimeForCase(new List<Case>{theCase});                
                
                //  now we can insert the case event here
                if (isTimeSpentRequired)//  currently the case event is only exposed for domestic support cases
                {
                    //   we only want to create the case event if it's has data in the fields
                    if (!Util.isBlank(m_finalCaseEvent.Subject__c))
                    {
                        insert m_finalCaseEvent;
                    }
                }
                
                PageReference pr;           
                //  redirect user to either solution or the case after save
               
                //else
                {
                     //  per carisa's request, this will now redirect you to the queue or whatever is in this method
                    pr =  redirectUserToApprioriateSaveAndClosePage(theCase);
                    
                }
                
                return pr;
            }
            else
            {
                return null;
            }
        }
        
        return null;
    }
    public static PageReference redirectUserToApprioriateSaveAndClosePage(Case theCase)
    {
        system.assertNotEquals(null, theCase);
        system.assertNotEquals(null, theCase.Id);
        system.assertNotEquals(null, theCase.recordtypeId);
        
        Pagereference pr = null;
        string recordTypeName = [select name from Recordtype where id =: theCase.recordTypeId].name;
        
        //  first check if the logged in user is either carisa or bettye haynes,  then see if the user's profile is intl
        User currentLoggedInUser = [select id, name from User where id =: userInfo.getUserId()];
        string profileName = [select id, name from Profile where id =: UserInfo.getProfileId()].name;
        
        if (currentLoggedInUser.name == 'Carisa Kreichauf')//  redirect to carisa's preferred view
        {
            pr = new PageReference('/500?fcf=00B30000006E8Po');//  INTL STR view
        }
        else if (currentLoggedInUser.name == 'Kufre Akpaidmeim' || currentLoggedInUser.name == 'Colleen Watson')//  redirect to bettye preferred view
        {
            pr = new PageReference('/500?fcf=00B30000006ZfUN');//  INTL SUPPORT
        }
        else if (profileName.contains('Intl'))
        {
            pr = new PageReference('/500?fcf=00B30000006ZfUN'); //  int'l case view
        }
        else if (profileName.contains('VAR'))//  user is a var, redirect to my open cases
        {
            pr = new PageReference('/500?fcf=00B30000006ERWf'); // My Open Cases view
        }
        else
        {
            if (recordTypeName == 'Support')
            {
                pr = new PageReference('/500?fcf=00B30000008pf34');//  Primay support queue
            }
            else if (recordTypeName == 'Admin' || recordTypeName == 'Professional Services')
            {
               if (theCase.accountId != null)
               {
                   pr = new PageReference('/' + theCase.accountId);
               }
               else
               {
                  pr = new PageReference('/' + theCase.id);
               }
            }
          /*  else if (recordTypeName == 'Enhancement')
            {
               pr = new PageReference('/' + theCase.Id);
            }
            else if (recordTypeName == 'Consulting Case')
            {
                pr = new PageReference('/500?fcf=00B30000006ERWf'); // my open cases
            }
            else if (recordTypeName == 'Customer Portal')
            {
                pr = new PageReference('/' + theCase.Id);
            } */
            else
            {
               throw new myException('Could not determine where to direct user after Save and Close button was selected.');
            }
        }
        pr.setRedirect(true);
        
        return pr;
    }
    public PageReference updateCaseEventExternalVisibleCheckbox()
    {
        //  if the user decides to create a case event when the case is closed, we need to make sure the case events' external visible
        //  matches what is set on this screen.  this method is callee when the user changes
        m_finalCaseEvent.Display_in_Customer_Portal__c = theCase.IsVisibleInSelfService;
        return null;
    }
    public PageReference redefineCaseReasonPicklist()
    {
        defineCaseReasonPicklist();
        caseReasonPicklist.selection = '--None--';
        
        redefineSubReasonPicklist();
        return null;
    }
    public PageReference redefineSubReasonPicklist()
    {
        defineSubReasonPicklist();
        subReasonPicklist.selection = '--None--';
        return null;
    }
    //  **********  Private Instance Functions  **********
    
    private void defineProductPicklist()
    {
        /*productPicklist.options = CaseClassHelperClass.defineProductListForSupportCases(
            theCase.AccountId,
            theCase.Is_Support_Case_Demo__c,
            theCase.Is_Related_To_A_Specific_Product__c);
            */
    }
    private void defineCaseReasonPicklist()
    {
        //caseReasonPIcklist.options = CaseClassHelperClass.defineCaseReasonsForSupportCases(productPicklist.selection);
    }
    
    private void  defineSubReasonPicklist()
    {
        //subReasonPicklist.options = CaseClassHelperClass.defineSubReasons(caseReasonPIcklist.selection, productPicklist.selection);
    }

    private boolean checkForRequriedFields()
    {
        final string GENERIC_ERROR_MESSAGE = 'Required Field Missing.';
        if (isTimeSpentRequired)
        {
            if (theCase.Start_Time__c == null)
            {
                theCase.Start_Time__c.addError('Required field missing.');
                return false;
            }
            /*if (theCase.End_Time__c == null)
            {
                theCase.End_Time__c.addError('Required field missing.');
                return false;
            }
            */
            //  for now, the final case event subject and case master subject
            //  are only required for deomstic support cases, i'm not sure if this new logic should apply to all types of cases
            if (util.isblank(theCase.subject))
            {
                theCase.AddError('Case Master Subject Required Field Missing.');
                return false;
            }
        }
      
        return true;
    }

      
    //  **********  Static Functions  **********
    public static ApexPages.StandardController generateController(Case theCase, string id )
    {
        pagereference pageRef=new pagereference('Page.CloseCaseExtension');
        test.setcurrentpage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', id);
            
        return new ApexPages.standardController(theCase);
    }
    
}