/*******************************************************************************
 * File:  MibosCaseTimeTrigger.cls
 * Date:  April 9th, 2015 
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
trigger MibosCaseTimeTrigger on Mibos_Case_Time__c (before insert)
{
    if (Trigger.isBefore && Trigger.IsInsert)
    {
        //  so the idea here is that for each case time, we need to mass query the cases, update the total work effort,
        // and swipe out the work effort in minutes, this should only be done for cases whose status is not closed
        Set<id> caseIds = new Set<Id>();
        for (Mibos_Case_Time__c ct : Trigger.new)
        {
           if (ct.Case__c != null && !caseIds.Contains(ct.case__c) )
           {    
               caseIds.add(ct.case__c);
           }
        }
        
        List<Case> specificCases = [select id, work_effort_in_minutes__c, total_work_effort__c, last_case_event__c from case where 
           id in: caseIds];
           
        List<Mibos_Case_Time__c> caseTimesOfCases = [select id, work_effort__c, case__c from Mibos_Case_Time__c where Case__c in: specificCases];
        
        //  alright diff logic here to use
        //  we'll scroll thru the cases and pull out all of thoese that are in the trigger
        for (Case singleCase : specificCases)
        {
            //  the reason this is needed is due to the fact the more than one case time can come into the trigger that point to the same case
            //  (for example my testing with having an eassittant tech on a case)
            //  becuase of this we need to push all of the case times that point to the case into the summation method, because remember
            //  this is the before insert trigger so the other records dont exist in the system yet
            List<Mibos_Case_Time__c> triggerCaseTimes = pullOutLikeCaseTimes(singleCase.id, Trigger.new);
            List<MIbos_Case_Time__c> alreadyExsitingCaseTimes = pullOutLikeCaseTimes(singleCase.id, caseTimesOfCases);
            
            singleCase.Total_Work_Effort__c =  sumCaseTimes(triggerCaseTimes, alreadyExsitingCaseTimes);
            singleCase.Work_Effort_In_Minutes__c = null;
            singleCase.Last_Case_Event__c = null; //  swipe this out as it should only be set when a case event is created
        }
        /*
        for (Mibos_Case_Time__c ct : Trigger.new)
        {
            Case tempCase = findCase(ct.Case__c, specificCases);
            if (tempCase != null)//  should never be null but if it is
            {
                //  update the case time fields
                //  the only field 
                //  then the case fields
                //  so the problem here is that we have two case times coming that point to the same case and those two neither have been inserted
                //  what that means if that when the query up above occurs, its only going to have those tha already existing the system
                //  lets say for example, if i almost want to say the fix for this is having this lopo thru the case times passed into 
                //  see if any point to the case we are updating and if so, pass in the list of case times to this method...
                //  the only caveat to that is that for those two case times, its going to run this twice, but that is ok, i think this a is 
                //  a simple fix that doenst require to much side effects
                List<Mibos_Case_Time__c> caseTimesPointingToSameCase = findSimilarCaseTimes(tempcase.id, Trigger.new);
                
                tempCase.Total_Work_Effort__c = sumCaseTimes(caseTimesPointingToSameCase, tempCase.id, caseTimesOfCases);
                tempCase.Work_Effort_In_Minutes__c = null;
                tempCase.Last_Case_Event__c = null; //  swipe this out as it should only be set when a case event is created
            }
        }
       */
        update specificCases;
    }
    
    private static decimal sumCaseTimes(List<Mibos_Case_Time__c> triggerCaseTimes, List<Mibos_Case_Time__c> alreadyExsitingCaseTimes)
    {
        //  i changed this to the before insert so i can update fields on the case times, that means when we do the summation, we have to include the case
        //  time that is being inserted
        decimal sum = 0;
        
        for (Mibos_Case_Time__c ct : triggerCaseTimes)
        {
            sum += nullToZero(ct.Work_Effort__c);
        }
        
        for (Mibos_Case_Time__c ct : alreadyExsitingCaseTimes)
        {
            sum += nullToZero(ct.Work_Effort__c);
        }
        return sum;
    }
    
    private List<Mibos_Case_Time__c> pullOutLikeCaseTimes(id caseId, List<Mibos_Case_Time__c> caseTimes)
    {
        List<Mibos_Case_Time__c> recordsToReturn = new List<Mibos_Case_Time__c>();
        for (Mibos_Case_Time__c ct : caseTimes)
        {
            if (ct.Case__c == caseId)
            {
                recordsToReturn.add(ct);
            }
        }
        
        return recordsToReturn;
    }
    /*
    private Case findCase(id caseId, List<Case> cases)
    {
        for (Case c : cases)
        {
            if (c.id == caseId)
             {
                return c;
             }
        }
        return null;
    }
    */
    private decimal nullToZero(decimal d)
    {
        return (d == null ? 0 : d);
    }
}