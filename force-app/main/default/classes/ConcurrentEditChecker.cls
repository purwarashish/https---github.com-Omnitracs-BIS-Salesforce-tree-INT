/*******************************************************************************
 * File:  ConcurrentEditChecker
 * Date:  July 22, 2009
 * Author:  Charlie Heaps
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
 * Purpose: 
 *   Utility class used to check for concurrent edits to an object.
 *******************************************************************************/
public class ConcurrentEditChecker 
{
    
    public static PageReference checkForConcurrentUpdate(sObject myObject)
    {
        // Check if another user modified this object while we were editing it.
        sObject testObject;
        
        try
        {
            String className = myObject.getSObjectType().getDescribe().getName();
            
            String queryString = 
               'select Id, LastModifiedById, LastModifiedDate from ' + className + ' where Id = \'' + myObject.Id + '\' for update';
            
            testObject = Database.query(queryString);
            
            if (String.valueOf(testObject.get('LastModifiedDate')) != 
                String.valueOf(myObject.get('LastModifiedDate')))
            {
                // LastModifiedDate doesn't match. This means someone modified the record since the 
                // time we started editing it. Redirect the user to the error page.
                PageReference errorPage = 
                   new PageReference(
                       '/apex/ConcurrentEditErrorPage?object_id=' + testObject.Id + 
                       '&user_id=' + testObject.get('LastModifiedById'));
        
                return errorPage;
            }
            
            return null;
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
            return null;
        }
    }

    // Test methods
   

}