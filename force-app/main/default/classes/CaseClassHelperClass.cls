/*******************************************************************************
 * File:  CaseClassHelperClass.cls
 * Date:  April 28th, 2009
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
public class CaseClassHelperClass
{

    //  be advised this is the same as in the CaseBeforeUpdateTrigger
    public static boolean isCaseSupport(string recordtypeId)
    {
        util.debug('inside of isCaseSupport.  value of loggedInuser: ' + loggedInuser + ' value of caseRecordTypes: ' + caseRecordTypes);
        //  cases that fall in this category need to have their case times created for them and total work effort summed
        boolean isEmailGeneratedButSupportProfile = 
           recordTypeid == retrieveRecordType('Email Generated Cases') &&
           loggedInUser != null &&
           loggedInUser.Profile.Name != null &&
           (loggedInUser.Profile.Name == 'Call Center Manager' ||
                loggedINUser.Profile.Name == 'Call Center User' ||
                loggedInUser.Profile.Name == 'CS Support' ||
                loggedInUser.Profile.Name == 'CS Lead John');
        
        util.debug('isEmailGeneratedButSupportProfile: ' + isEmailGeneratedButSupportProfile);   
        //  we so far have 4 different suppprt recordtypes, support, rescue pin support, call center, and engineering case
        return isEmailGeneratedButSupportProfile || 
            recordTypeId == retrieveRecordType('Support') ||
           recordTypeId == retrieveRecordType('Rescue Pin Support') ||
           recordTypeId == retrieveRecordType('Call Center') ||
           recordTypeId == retrieveRecordType('Engineering Case');
    }
    
    public static User loggedInUser
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
    
    private static List<RecordType> caseRecordTypes;    
    
    private static Id retrieveRecordType(string recordTypeName)
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
    private static boolean isOwnerQueue(Id userId, List<QueueSobject> queues)
    {
        for (QueueSobject q : queues)
        {
            if (q.QueueId == userId)
            {
                return true;
            }
        }
        return false;
    }
    
    public static boolean isOwnerQueue(id UserId)
    {
        for (QueueSobject queue : [select id, queueid from QueueSobject where sobjecttype = 'Case' ])
        {
            if (queue.QueueId == userId)
            {
                return true;
            }
        }
        return false;
        
    }
    
    public static integer findCaseTimeTotal(Id caseid)
    {
        List<Mibos_Case_Time__c> caseTimes = [select id, work_effort__c from Mibos_Case_Time__c where case__c =: caseId];
        integer sumWorkEffort = 0;
        for (Mibos_Case_Time__c ct : caseTimes)
        {
            sumWorkEffort += (integer)(ct.Work_Effort__c == null ? 0 : ct.Work_Effort__c);
        }
        return sumWorkEffort;
        
        return 0;
    }   
}