/**
 * Scheduable for the CustomerAssetBatchable class.
 */

global class CustomerAssetBatchableScheduable implements Schedulable {
    global void execute(SchedulableContext sc) {
        CustomerAssetBatchable batchJob = new CustomerAssetBatchable(false);
        Id batchJobId = Database.executeBatch(batchJob, 25);
        System.debug('CustomerAssetBatchableScheduable.execute() id: ' + batchJobId);
    }
}