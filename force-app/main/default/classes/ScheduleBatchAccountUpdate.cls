/*******************************************************************************
 * File:  ScheduleBatchAccountUpdate.cls
 * Date:  Dec 29, 2014
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
global class ScheduleBatchAccountUpdate implements Schedulable
{
    public static string SECONDS = '0';
    public static string MINUTES = '30';
    public static string HOURS = '22';
    public static string DAY_OF_MONTH = '*';
    public static string MONTH = '*';
    public static string DAY_OF_WEEK= '?';
    
    public static string TIME_TO_RUN = SECONDS + ', ' + MINUTES + ', ' + HOURS + ', ' + DAY_OF_MONTH + ', ' + MONTH + ', ' + DAY_OF_WEEK;
    public static string NAME_OF_JOB = 'Batch Update Account';
    
    global void execute(SchedulableContext SC)
    {
        
        BatchAccountUpdate BAU = new BatchAccountUpdate();
        database.executeBatch(BAU);
        
    }
}