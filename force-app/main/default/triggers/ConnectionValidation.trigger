trigger ConnectionValidation on Connection_Type__c bulk (before insert, before update) {
// Validation rules on Connection Type object
// Created by Mark Silber - 072707
// Last modified by Mark Silber - 073007

    for (Connection_Type__c ct: Trigger.new){
        String ConnStatus = ct.Connection_Status__c;
            String ConnType = ct.Connection_Type__c;
            String CIType = ct.CI_Type__c;
            // Validation rules for all Connection Types
            if (CIType == 'Persistent'){
                if (ct.CI_1__c == NULL){
                    ct.CI_1__c.adderror('CI 1 is required for Persistent CI Types');
                }
            }
            // Rules for Frame Relay Connection Types
            if (ConnType == 'Frame Relay'){
                if (ConnStatus.startsWith('Active')){
                    if (ct.Frame_SD_Network__c  == NULL) {
                        ct.Frame_SD_Network__c.adderror('Frame SD Network is required for Active Connection Types');
                    } 
                    if (ct.SD_Ethernet__c == NULL){
                        ct.SD_Ethernet__c.adderror('SD Ethernet is required for Active Connection Types');
                    }
                    if (ct.Frame_SD_Network__c < 0){
                        ct.Frame_SD_Network__c.adderror('Frame SD Network is required for Active Connection Types');
                    }
                    if (ct.Cust_S0_1_S2_0_to_SD_IP__c == NULL){
                        ct.Cust_S0_1_S2_0_to_SD_IP__c.adderror('Cust S0.1/S2.0 to SD IP is required for Active Connection Types');
                    }
                    if (ct.Port_on_SD_Router__c == NULL){
                        ct.Port_on_SD_Router__c.adderror('Port on SD Router is required for Active Connection Types');
                    }            
                    if (ct.Frame_SD_IP_Prefix__c == NULL){
                        ct.Frame_SD_IP_Prefix__c.adderror('Frame SD IP Prefix is required for Active Connection Types');
                    }
                    if (ct.Frame_SD_7507_IP__c == NULL){
                        ct.Frame_SD_7507_IP__c.adderror('Frame SD 7507 IP is required for Active Connection Types');
                    }
                    if (ct.LV_Ethernet__c == NULL){
                        ct.LV_Ethernet__c.adderror('LV Ethernet is required for Active Connection Types');
                    }
                    if (ct.Frame_LV_Network__c == NULL){
                        ct.Frame_LV_Network__c.adderror('Frame LV Network is required for Active Connection Types');
                    }
                    if (ct.Cust_S0_1_S2_0_to_LV_IP__c == NULL){
                        ct.Cust_S0_1_S2_0_to_LV_IP__c.adderror('Cust S0.1/S2.0 to LV IP is required for Active Connection Types');
                    }
                    if (ct.Frame_LV_IP_Prefix__c == NULL){
                        ct.Frame_LV_IP_Prefix__c.adderror('Frame LV IP Prefix  is required for Active Connection Types');
                    }
                    if (ct.Port_on_LV_Router__c == NULL){
                        ct.Port_on_LV_Router__c.adderror('Port on LV Router is required for Active Connection Types');
                    }
                    if (ct.Frame_LV_Broadcast__c== NULL){
                        ct.Frame_LV_Broadcast__c.adderror('Frame LV Broadcast is required for Active Connection Types');
                    }
                    if (ct.Frame_SD_Broadcast__c == NULL){
                        ct.Frame_SD_Broadcast__c.adderror('Frame SD Broadcast is required for Active Connection Types');
                    }
                    if (ct.Frame_LV_7507_IP__c == NULL){
                        ct.Frame_LV_7507_IP__c.adderror('Frame LV 7507 IP is required for Active Connection Types');
                    }
                    if (ct.SD_T1_CKT__c == NULL){
                        ct.SD_T1_CKT__c.adderror('SD T1 CKT is required for Active Connection Types');
                    }
                    if (ct.LV_T1_CKT__c == NULL){
                        ct.LV_T1_CKT__c.adderror('LV T1 CKT is required for Active Connection Types');
                    }
                    if (ct.Cust_Local_Circuit_ID__c == NULL){
                        ct.Cust_Local_Circuit_ID__c.adderror('Cust Local Circuit ID is required for Active Connection Types');
                    }
                    if (ct.DBU__c == 'DBU 800'){
                        if (ct.Cust_to_QC_DBU_SD__c == NULL){
                            ct.Cust_to_QC_DBU_SD__c.adderror('QC DBU SD is required for Active Connection Types if DBU is DBU 800');
                        }
                        if (ct.Cust_to_QC_DBU_LV__c == NULL){
                            ct.Cust_to_QC_DBU_LV__c.adderror('Cust to QC DBU LV is required for Active Connection Types if DBU is DBU 800');
                        }
                    }
                    if (ct.DBU__c == 'DBU Local'){
                        if (ct.Cust_to_QC_DBU_SD__c == NULL){
                            ct.Cust_to_QC_DBU_SD__c.adderror('QC DBU SD is required for Active Connection Types if DBU is DBU Local');
                        }
                        if (ct.Cust_to_QC_DBU_LV__c == NULL){
                            ct.Cust_to_QC_DBU_LV__c.adderror('Cust to QC DBU LV is required for Active Connection Types if DBU is DBU Local');
                        }
                    }
                } // End Status starts with Active
            } // End Connection Type = Frame Relay
            // Start Connection Type = VPN
            if (ConnType == 'VPN') {
                if (ConnStatus.startsWith('Active')){
                    if (ct.Date_Activated__c == NULL){
                        ct.Date_Activated__c.adderror('Date Activated is required for Active VPN Connection Types');
                    }
                }
            } // End ConnType = VPN
            // Start Connection Type = Dial in Local
            if (ConnType == 'Dial in Local'){
                if (ConnStatus.startsWith('Active')){
                    if (ct.Comm_Protocol__c <> 'Async'){
                        if (ct.Date_Activated__c == NULL){
                            ct.Date_Activated__c.adderror('Date Activated is required for Active Dial in Local Connection Types that are not Async');
                        }
                    }
                    if (ct.NMC_Password__c == NULL){
                        ct.NMC_Password__c.adderror('NMC Password is required for Active Dial in Local Connection Types');
                    }
                }
            }// End Connection Type = Dial in Local
    } // End Validation Check
} // End Trigger