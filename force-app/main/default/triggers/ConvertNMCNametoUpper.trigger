trigger ConvertNMCNametoUpper on NMC_Account__c bulk (before update, before insert){

// Convert the NMC Account Name to UPPERCASE and append the NMC Account Name to the NMC Account Number on Save and New actions.
// Created by Mark Silber - 073007

    for (NMC_Account__c NMCAcct: Trigger.new) {
        If (NMCAcct.NMC_Account_Name__c != NULL) {
            NMCAcct.NMC_Account_Name__c = NMCAcct.NMC_Account_Name__c.ToUpperCase();
            if (NMCAcct.NMC_Account__c != NULL) {
                NMCAcct.name = NMCAcct.NMC_Account__c + ' - ' + NMCAcct.NMC_Account_Name__c;
            }
            else { NMCAcct.name = NMCAcct.NMC_Account__c;
            }
        }
    }
}