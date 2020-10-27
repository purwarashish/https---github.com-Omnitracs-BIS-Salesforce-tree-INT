global class TxnLogScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        ID batchProcessId = Database.executeBatch(new TxnLogBatch(), (Test.isRunningTest() ? 4 : 1));
    }
}