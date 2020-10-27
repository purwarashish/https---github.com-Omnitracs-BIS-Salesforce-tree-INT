/*
 *  @Author:        Mark David De Chavez
 *  @Date-created:  October 1, 2014
 *  @Description:   Create/update FinancialForce Timecards (pse__Timecard_Header__c) 
 *                  based on Case Time entries, which are attached to Cases.
 */

global class TimeCardBatchSchedule implements Schedulable{

    Boolean sendEmail;
    Integer batchSize;
    
    global TimeCardBatchSchedule(Boolean sendEmail, Integer batchSize) {
        this.sendEmail = sendEmail;
        this.batchSize = batchSize;
    } 

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new TimeCardBatch(this.sendEmail), this.batchSize);
    }
}