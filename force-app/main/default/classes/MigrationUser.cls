/*******************************************************************************
 * File:  MigrationUser.cls
 * Date:  July 27th, 2009
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
 * 
 * Purpose:  To allow a user to import data without the triggers throwing exceptions.
 
 *  *******************************************************************************/
public class MigrationUser
{
    /*public static boolean isMigrationUser()
    {
        final string MIGRATION_USERNAME = 'muser@roadnet.com';
        //final string MIGRATION_USERNAME = 'jhutchins@ups.com.test';
                
        if (MIGRATION_USERNAME == userInfo.getUserName() ||
            userInfo.getUserName() == 'muser@roadnet.com.test' || 
            userInfo.getUserName() == 'muser@roadnet.com.backup')
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    public static boolean isUserIntegrationAutomation()
    {
        final string AUTOMATION_INTEGRATION_USERNAME_SANDBOX  = 'integrat@roadnet.com.backup';
        final string AUTOMATION_INTEGRATION_USERNAME_LIVE = 'integrat@roadnet.com';
        return (userInfo.getUserName() == AUTOMATION_INTEGRATION_USERNAME_SANDBOX || useRInfo.getUserName() == AUTOMATION_INTEGRATION_USERNAME_LIVE);
        
        
    }
    
    public static boolean isSAAUser()
    {
        final string SERVICE_AGREEMENT_ADJUSTMENT_USER = 'sauser@roadnet.com';
        //final string LINDA_HARRIS_EMAIL = 'lharris@roadnet.com';
        //final string LAURIE_LITTLE_EMAIL = 'llittle@roadnet.com';
        final string MELISSA_EMAIL = 'mrose@roadnet.com';
        final string MATT_EMAIL = 'mfleming@roadnet.com';
        
                   
        if (SERVICE_AGREEMENT_ADJUSTMENT_USER == userInfo.getUserName() || 
            MELISSA_EMAIL == userInfo.getUserName() ||
            MATT_EMAIL == userInfo.getUserName())
        {
            return true;
        }
        else
        {
            return false;
        }
        
    }
    /*
    public static boolean canUserByPassChangeRequestTriggers
    {
        get
        {
            //  this is very hacky but it determined to be the best way to do this.
            //  problem: how to allow a dev to mass update version records where they'll need to by pass triggers, but we want that same user
            //  to have triggers run for them if only editing one record.  
            //  so the logic is, if the user's can bypass cr trigger is true, and the logged in user's role is TE LEAD (not sure if needed)
            //  and the number of records in the trigger for the version trigger > 1 and for the task > 1 also
            id teLeadRoleId = '00E30000000yb5c';
            User userRecord = [select id, Can_Mass_Update_CRs__c, userRoleId from User where id =: userInfo.getUserId()];
            return userRecord.Can_Mass_Update_CRs__c &&
             userRecord.UserRoleId == teLeadRoleId;//  for now, only the person with test lead (Greg burke) can bypass the triggers, this logic might change in the future
        }    
    }
    */
    public class myException extends Exception{}

}