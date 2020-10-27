/**
 *  Scheduable Context to start the ContractBatchable job.
 */

global class ContractBatchableSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        ContractBatchable batchJob = new ContractBatchable(false);
        Id batchJobId = Database.executeBatch(batchJob);
        System.debug('ContractBatchableScheduable.execute() id: ' + batchJobId);
    }
}