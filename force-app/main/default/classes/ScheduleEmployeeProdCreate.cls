/*******************************************************************************
 * File:  ScheduleEmployeeProdCreate.cls
 * Date:  August 6, 2015
 * Author:  Joseph Hutchins
 *
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2015, UPS Logistics Technologies, Inc.  All rights reserved.
 *  *******************************************************************************/
global class ScheduleEmployeeProdCreate implements Schedulable
{
    global id AsyncApexJobId ;
    //global date dateValue;
    global Integer daysPrevious;
    global void execute (SchedulableContext SC){
        try{        
                    Date dateValue = Date.today().addDays(daysPrevious);
                    batchEmployeeProdCreate b1 = new  batchEmployeeProdCreate(dateValue);
                    if([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5)
                    {
                        database.executeBatch(b1);
                    }
                    else
                    {
                        // Rescheduling the same class after 30 minutes with the same date value
                        ScheduleEmployeeProdCreate schEmpProd = new ScheduleEmployeeProdCreate();
                        schEmpProd.daysPrevious = daysPrevious;
                        Datetime dt = Datetime.now() + (0.024305); // i.e. 30 mins
                        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
                        System.Schedule('ReschuledJob',timeForScheduler,schEmpProd);
                    }
            }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
    }
}