global class WebServiceExecution{

    WebService static String ExecuteTxnLogBatch(){
        ID batchprocessid = Database.executeBatch(new TxnLogBatch(), 1);
        return String.valueOf(batchprocessid);
    }

}