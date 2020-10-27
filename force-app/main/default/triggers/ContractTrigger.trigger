/**************************************************************************************************************
    ARMAN -  Rewrote old code to use a SF Best Practice framework for Trigger class.
    NOTE: This Trigger should be further optimized to have almost no code, and use the Handler class instead.
    Also added 'ContractTriggerHandler.setContractOnAssets' method call.
    Date: 8/27/2018
**************************************************************************************************************/

trigger ContractTrigger on Contract (before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {

    BypassTriggerUtility u = new BypassTriggerUtility();
    if (u.isTriggerBypassed()) {
        return;
    }

    if (Trigger.isBefore) {
        if (!ContractTriggerHandler.runOnceBefore())
        {
            System.debug('Recursion detected in BEFORE Trigger. Exiting.');
            return;
        }

        if (Trigger.isInsert) {
            System.debug('-- In BEFORE_INSERT Contract Trigger');
        }

        if (Trigger.isUpdate) {
            System.debug('-- In BEFORE_UPDATE Contract Trigger');
            ContractTriggerHandler.preventContractActivated(Trigger.new, Trigger.oldMap);
            ContractTriggerHandler.populatePriceIncreaseCap(Trigger.oldMap, Trigger.newMap);
        }

        if (Trigger.isDelete) {
            System.debug('-- In BEFORE_DELETE Contract Trigger');
        }
    }
    else { // isAfter
        // VERIFY if this is correct to do here:
        if (!ContractTriggerHandler.runOnceAfter())
        {
            System.debug('Recursion detected in AFTER Trigger. Exiting.');
            return;
        }

        if (Trigger.isInsert) {
            System.debug('-- In AFTER_INSERT Contract Trigger');

            ContractTriggerHandler.updateOpportunity(Trigger.new);
            System.debug('-- AFTER updateOpportunity call');

            /////// Arman Shah - 8/26/2018
            ContractTriggerHandler.setContractOnAssets(Trigger.new);
            System.debug('-- AFTER setContractOnAssets call');
            ///////// END - Arman

            ContractTriggerHandler.renameSBParentContract(Trigger.new);
        }

        if (Trigger.isUpdate) {
            System.debug('-- In AFTER_UPDATE Contract Trigger');

            //Added to set Opportunity Contracted Activated checkbox to true upon Contract Activation
            //Assuming here that the custom Activate button is needed to activate a Contract, so disable for bulk loads
            if (Trigger.size == 1) {
                ContractTriggerHandler.activateContractOpportunities(Trigger.oldMap, Trigger.newMap);
                System.debug('-- AFTER activateContractOpportunities method');
            }

            ContractTriggerHandler.CallSpringCMOnTerminate(Trigger.oldMap, Trigger.newMap);
            System.debug('-- AFTER CallSpringCMOnTerminate method');
        }

        if (Trigger.isDelete) {
            System.debug('-- In AFTER_DELETE Contract Trigger');
        }

        if (Trigger.isUnDelete) {
            System.debug('-- In AFTER_UNDELETE Contract Trigger');
        }
    }
}