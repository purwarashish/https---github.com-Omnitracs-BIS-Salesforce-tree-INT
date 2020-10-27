/**
 * Batchable class used to update the CustomerAsset's related (MSA, Schedule, Eval, and Eval2) fields.
 */

global class CustomerAssetBatchable implements Database.Batchable<sObject>, Database.Stateful {

    // Defines the number of minutes to schedule the job in the future. 10 = 10 minutes.
    private boolean doReschedule;
    private Integer syncFrequency = 15;
    private final String QUERY = ''+
            'SELECT '+
                'Id, '+
                'Account__c, '+
                'MSA_Document__c, '+
                'Product_Schedule_Document__c, '+
                'Eval_Document__c, '+
                'Eval2_Document__c, '+
                'Latest_Opportunity__r.Order_Type__c, '+
                'Latest_Opportunity__r.Order_Sub_Type__c, '+
                'Latest_Quote_Line__c, '+
                'Latest_Quote_Line__r.Id, '+
                'Latest_Quote_Line__r.Product_Type__c, '+
                'Latest_Quote_Line__r.SBQQ__RequiredBy__c, '+
                'Latest_Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Id, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Contract_Category_1__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Contract_Category_2__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Agreement_Type__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Legal_Entity_Name__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_MSA_Document_Template__r.Status__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Contract_Category_1__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Contract_Category_2__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Agreement_Type__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Legal_Entity_Name__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_Schedule_Document_Template__r.Status__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Contract_Category_1__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Contract_Category_2__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Agreement_Type__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Legal_Entity_Name__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval_Document_Template__r.Status__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Contract_Category_1__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Contract_Category_2__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Agreement_Type__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Legal_Entity_Name__c, '+
                'Latest_Quote_Line__r.SBQQ__Product__r.Output_Eval2_Document_Template__r.Status__c, '+
                'Latest_Quote_Line__r.SBQQ__Quote__c, '+
                'Latest_Quote_Line__r.SBQQ__Quote__r.Id, '+
                'Latest_Quote_Line__r.SBQQ__Group__c, '+
                'Contract__c, '+
                'Steelbrick_Asset__c, '+
                'Steelbrick_Asset__r.Id, '+
                'Steelbrick_Subscription__c, '+
                'Steelbrick_Subscription__r.Id, '+
                'Steelbrick_Subscription__r.SBQQ__Contract__c '+
            'FROM Customer_Asset__c '+
            //+ Identify the Customer Assets that have no association with a (MSA, Schedule, Eval, Eval2) contract; but certainly should.
            'WHERE MSA_PS_Eval_Eval2_Initialized__c=false '+
            //- Identify the Customer Assets that have no association with a (MSA, Schedule, Eval, Eval2) contract; but certainly should.
            //+ Identify the Customer Assets that should have an updated association with a (MSA, Schedule, Eval, Eval2) contract.
            'OR    MSA_PS_Eval_Eval2_Requires_Update__c=true '+
            //- Identify the Customer Assets that should have an updated association with a (MSA, Schedule, Eval, Eval2) contract.
            //+ Capture any Customer Assets that need to have their relationship to a CPQ contract established.
            'OR    Contract__c=null';
            //- Capture any Customer Assets that need to have their relationship to a CPQ contract established.

    public CustomerAssetBatchable(boolean doReschedule) {
        this.doReschedule = doReschedule;
    }

    global Database.QueryLocator start(Database.BatchableContext batchableContext){
        System.debug('CustomerAssetBatchable.start() Starting customer asset batchable.');
        return Database.getQueryLocator(QUERY);
    }

    /**
     * Receive a list of Customer Asset objects based on the following criteria:
     * - Have no association with a (MSA, Schedule, Eval, Eval2) contract; but certainly should.
     * or
     * - Have an existing association with a (MSA, Schedule, Eval, Eval2) contract that should be updated.
     *
     * Send these into the CustomerAssetHandler and ensure that they're updated.
     */
    global void execute(Database.BatchableContext batchableContext, List<sObject> scope) {
        List<Customer_Asset__c> customerAssetList = new List<Customer_Asset__c>();

        for(sObject abstractObject: scope) {
            Customer_Asset__c customerAsset = (Customer_Asset__c) abstractObject;
            customerAssetList.add(customerAsset);
        }

//        CustomerAssetHandler.relateToSpringCMContracts(customerAssetList);
        customerAssetList = CustomerAssetHandler.updateCustomerAssetContracts(customerAssetList);
        CustomerAssetHandler.updateAssetContracts(customerAssetList);
    }

    global void finish(Database.BatchableContext batchableContext) {
        System.debug('CustomerAssetBatchable Finished');
        if (Test.isRunningTest()) { return; }
        if (this.doReschedule) {
            rescheduleThis();
        }
    }

    private void rescheduleThis() {
        CustomerAssetBatchable batch = new CustomerAssetBatchable(true);
        System.scheduleBatch(batch, 'CustomerAsset Batch Sync', syncFrequency);
    }
}