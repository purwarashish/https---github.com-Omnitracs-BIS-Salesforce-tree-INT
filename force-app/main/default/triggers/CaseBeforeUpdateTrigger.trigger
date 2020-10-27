/*******************************************************************************
 * File:  CaseBeforeUpdateTrigger
 * Date:  November 8, 2013
 * Author:  Joseph Hutchins
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *
 * Purpose: 
 *   Trigger fired on Cases.
 *******************************************************************************/
trigger CaseBeforeUpdateTrigger on Case (before update)
{
    /*util.debug('case before update trigger called');
    
     BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }
    private List<RecordType> caseRecordTypes;

    private User loggedInUser
    {
        get
        {
            if (loggedInuser == null)
            {
                loggedInUser = [select id, profileid, profile.name from User where id =: userINfo.getUserid()];
            }
            
            return loggediNuser;
        }
    }
    private boolean isUserCustomerCommunity
    {
        get
        {
            if (loggedInuser != null)
            {
                return loggedInUser.Profile.Name != null && loggedInuser.Profile.Name.Contains('Customer Community');
            }
            return false;
        }
    }
    
    if (CheckRecursive.runOnce())   
    {
        if (Trigger.isBefore && Trigger.isUpdate)
        {
            System.debug('MM: Calling escalationCaseResponse');
            CaseServices.escalationCaseResponse(Trigger.oldMap, Trigger.new);
            CaseServices.getEngineeringInfo(Trigger.newMap, Trigger.oldMap);
            
            CaseServices.setLastModifiedDateTimeField(Trigger.new);
            CaseServices.populateJiraStatusFields(Trigger.new, retrieveRecordType('Call Center'), retrieveRecordType('Engineering Case'));
            
            for (integer i = 0; i < Trigger.New.size(); i++)
            {
                Case newCase = Trigger.New[i];
                Case oldCase = Trigger.oldMap.get(newCase.id);
                //  so the idea is that case times will only be created on case updates, case event creation and close cases
                //  the logic here is the user edits a case and put a value in work effort field
                //  the caes before trigger creates a case time using the value set in the case's work effort field
                //  then the field is wiped
                if (!isUserCustomerCommunity && CaseClassHelperClass.isCaseSupport(newCase.Recordtypeid) )
                {
                    if(oldCase.Status != newCase.Status &&  //  case is being closed
                        newCase.Status == 'Closed' &&
                        isNullOrZero(newCase.Total_Work_Effort__c) && //  total wo+k effort is blank
                        isNullOrZero(newCase.Work_Effort_In_Minutes__c)) //  the case close work effort in minutes is blank
                    {
                        //  newish logic jan 20, 2015, to fix issue with cases being closed with 0/null work effort
                        //  we are going to do one final check on the cases's work effort.  if it is 0/null,
                        //  the the user is required to set the work effort on the csae close screen before closing the case
                        newCase.Work_Effort_In_Minutes__c.addError('Cannot close case with 0 Total Work Effort.  Please place a non zero value in Work Effort In Minutes');
                    }
                    
                    //  ding the user only if the case owner is not changing, this is to prevent the work effort
                    //  from being required when changing the case owner
                    if ( (newCase.Work_Effort_In_Minutes__c == 0) &&
                        oldCase.OwnerId == newCase.OwnerId )//  possible to create an event for a case whose work effort in minutes = 0
                    {
                        //  since the work effort is now a NON Requeried field on the case object, we only do this check if the case
                        //  is not being closed...
                        if (newCase.Status != 'Closed')
                        {
                            newCase.Work_Effort_In_Minutes__c.addError('Please place a non zero value in Work Effort');
                        } 
                    }
                    if (newCase.Work_Effort_in_minutes__c > 480)
                    {
                        newCase.Work_Effort_in_minutes__c.addError('Work Effort value is too high.  Please specify a new value for work minutes.');
                    }
                }
                
                if (CaseClassHelperClass.isCaseSupport(newCase.RecordTypeId)  && newCase.Business_Unit__c == 'Roadnet')
                {
                    //  this checks the case sproduct for text "rna" and if found, it will change the product fmaily to RNA
                    checkCaseProductForRnaProducts(newCase);
                }
                
                assignCaseAge(newCase);
               
                if (newCase.RecordtypeId == retrieveRecordType('Professional Services'))
                {
                    //  the isvisibiliinselfservice portal flag should be false for all prof services cases
                    newCase.IsVisibleInSelfService = false;
                }
                
                //  if there is a differnce in case statuses (i.e. they have changed) and case is being closed
                if (oldCase.status != newCase.status && newCase.status == 'Closed')
                {
                    newcase.Closed_By__c = userInfo.getUserId();
                }
            }
        }
    }
    private boolean isNullOrZero(decimal d)
    {
        return (d == null || d == 0);
    }
    private Id retrieveRecordType(string recordTypeName)
    {
        if (caseRecordTypes == null)
        {
            caseRecordTypes = [select id, name from RecordType where sobjecttype = 'Case'];
        }
        
        for (RecordType rt : caseRecordTypes)
        {
            if (rt.name == recordTypeName)
            {
                return rt.id;
            }
        }
        
        return null;
    }

    private void checkCaseProductForRnaProducts(Case theCase)
    {
        util.debug('inside of checkCaseProductForRnaProducts. case product_pl__c: ' + 
           theCase.Product_Pl__c + ' product_family_pl__c: ' + theCase.Product_Family_PL__c);
        
        //  so right now we have athree RNA products. i have changed the ones inthe sandbox and the live
        //  to be rna dispatching, rna routing, and rna tracking
        //  so what the code here will do is see if the selectd proudct is one of the thre
        //  and if it is, it will change the cases product family to RNA 
        if (theCase.Product_PL__c != null)
        {
            if (theCase.Product_Pl__c.Contains('RNA'))
            {
                util.debug('case product contained rna text.. chaning the product family field');
                theCase.Product_Family_PL__c = 'Roadnet Anywhere';
                //theCase.Product_Family__c = rnaProductFamilyId;//  this is needed because the trigger still assoicates child records of the case using the appropiate table
            }
        }
    }

    private Id businessHourId
    {
        get
        {
            return SystemIds__c.getInstance().BusinessHoursId_Roadnet__c;
        }
    }
    public void assignCaseAge(Case c)
    {
        //  not sure if the closed date is set in teh before of the trigger
        id bhId = businessHourId;
        
        DateTime endDate;
        if (c.closedDate == null)
        {
            endDate = DateTime.now();
        }
        else
        {
            endDate = c.ClosedDate;
        }
        
        decimal ageInMilliSeconds = decimal.valueof(BusinessHours.diff(bhId, c.CreatedDate, enddate));
         
        c.Case_Age__c = ageInMilliSeconds / 1000;
       
    }
    private class CaseTriggerException extends Exception{}*/

}