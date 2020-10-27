global class MergeProvisionIntoContract  implements Database.Batchable<sObject>{
	
	global Database.querylocator start(Database.BatchableContext BC){
        String query = 'select Id, Name,Accounting_Memo_Requirement__c,Accounting_Treatment_OMNI__c,Accounting_Treatment_Details__c,Add_On_Contract_c__c,Annual_Fees_Billing_Done_By__c,'+
			'Start_Date_of_Annual_Maintenance__c,Application_Discounts__c,Applications__c,Assignment_Notes__c,Bill_To__c,CAS_Clause__c,Check__c,Check_Amount__c,Closed__c,Comments_Alternate_Payment_Schedule__c,'+
			'Confidentiality__c,Confidentiality_Details__c,Contains_52_222_54_E_Verify__c,Contingency_Details__c,Contingency_Provision__c,Contract_Grade__c,Contract_Grade_Notes__c,Product_Type__c,'+
			'Convenience_Clause__c,Customer_Indemnification__c,Counterparty_Limitation_of_Liability__c,Customer_s_Assignability_Rights__c,Currency_of_EULA__c,Data_Access__c,Data_Policy_c__c,'+
			'Date_of_Final_Payment__c,Date_Received__c,DCs__c,DD250_Required__c,DD882_Required__c,Depost_with_Schedule_1__c,Detailed_Order_Status_c__c,DVIR_Fee_Schedule_3__c,DVIR_Units__c,'+
			'Email_for_Primary_Contact__c,Evaluation_Term__c,Exchange_Rate_1_if_USD__c,Ext_Terminal_Maintenance_Discount__c,Extended_Terminal_Maintenance__c,FAR_12_FAR_15__c,Fee_Start_Extension_c__c,Fees__c,'+
			'File_Destruction_Date__c,Final_Payment_Received__c,Finance_Audit_Comments__c,Free_Driver_Dispatcher_Training__c,Free_Installation__c,Free_Installation_Details__c,Free_Installation_Training__c,'+
			'Free_Service_Messaging__c,Free_Technical_Services__c,Funding_Date__c,Future_Products_Obsolescence_Clause__c,Governing_Law_Venue__c,Governing_Law_Venue_Notes__c,Government_Agency__c,'+
			'Government_Property_Clause__c,Gov_t_Automated_Invoicing_Required__c,GSA__c,Hardware_MFN__c,Hardware_Platform__c,HOS_Fee_Schedule_3__c,HOS_Units__c,If_cause_is_Other_explain__c,'+
			'If_cause_is_Restructure_or_Successor__c,If_with_exception_cause__c,In_Service__c,In_Service_NRF__c,Insurance__c,Insurance_Details__c,Invoicing__c,Last_Approved_By__c,License_Type__c,'+
			'Limitation_of_Funds_Clause__c,Location_Type__c,Maintenance_Amount__c,Maintenance_Fee_Type__c,Term_of_Maintenance__c,Map_Coverage_Area__c,Map_Royalties_USD_if_paid_by_Roadnet__c,Map_Vendor__c,'+
			'Maps_Sold_by__c,MobileCast_Fee_Schedule_3__c,MobileCast_Units__c,Mounts_Discount__c,Non_Standard_CP_Indemnification_Detail__c,Non_Standard_Equipment_Terms__c,'+
			'Non_Standard_Invoicing_Pmt_or_Tax_Term__c,Non_Standard_Omni_Indemnification_Detail__c,Non_Standard_Payment_Terms_Details__c,Non_Standard_Service_Terms__c,Non_Standard_Software_Terms__c,'+
			'Non_Standard_Term_Termination_Terms__c,Non_Standard_Termination_Fees_or_Terms__c,Non_Standard_Cust_Limitation_of_Liabili__c,Non_Standard_Omni_Limitation_of_Liabilit__c,Number_of_Installations__c,'+
			'Number_of_Licensed_Sites__c,Number_of_Mobile_Assets__c,Number_Of_RNT_Users__c,Number_of_RTI_Training_Days_Quoted__c,Number_of_Sales_Reps_T_Planner__c,Number_of_Support_Recipients__c,'+
			'Number_of_Vehicles__c,OMNI_assign_w_o_consent_restructure__c,Omni_Assignability_Rights__c,Omni_Indemnification__c,Omni_Limitation_of_Liability__c,CTel_Contract_Number__c,Order_Status__c,'+
			'Other_Hardware_Discounts__c,Other_Negotiated_Terms__c,Other_Non_Standard_Discounts__c,Other_Shipment_Terms_Details__c,OTN__c,P_O_or_Check__c,Payment_1_Days__c,Date_of_VAR_Payment_to_UPSLT__c,'+
			'Payment_1_to_UPSLT_USD__c,Payment_2_Days__c,Date_of_Payment_2_to_UPSLT__c,Payment_2_to_RTI_USD__c,Payment_3_Days__c,Date_of_Payment_3_to_UPSLT__c,Payment_3_to_UPSLT_USD__c,Payment_4_Days__c,'+
			'Date_of_Payment_4_to_UPSLT__c,Payment_4_to_UPSLT_if_applicable_USD__c,Payment_5_Days__c,Payment_5_to_UPSLT_USD__c,Payment_6_Days_after_Delivery__c,Payment_6_to_RTI_USD__c,'+
			'Payment_Due_with_Contract__c,Payment_Due_With_Contract_RNT__c,Payment_Method__c,Payment_Terms__c,Payment_Type_to_RTI__c,Payment_Withholds__c,Pending_SLA__c,Per_Day_Consulting_Fee_Quoted_UPSLT__c,'+
			'Per_Day_Consulting_Fee_Quoted_VAR__c,PO_Amount__c,PO_Amount_RNT__c,Price_Guarantee_Details__c,Price_Increase_Cap__c,Price_Increase_Notice_Period_in_Days__c,Price_Increases_Y_N__c,'+
			'Prime_or_Sub_Contractor__c,Project__c,Provision_ID_TCM__c,Related_Party__c,Related_Party_Details__c,Remarketing_Rights__c,Renewal_Rate__c,Replacement_Or_Addon__c,Reseller__c,'+
			'Retention_Toolkit_Terms__c,RNT_Fee_Schedule_3__c,RNT_Hardware_Total__c,RNT_Installation_Total__c,RNT_Units__c,UPSLT_Portion_of_Annual_Fees__c,UPSLT_Portion_of_SW_Fees__c,UPSLT_Products__c,'+
			'SBA_Plan_Prepared__c,Service_Data_Plan_Discounts_Notes__c,Service_MFN__c,Service_Plan__c,Ship_To__c,Shipment_Terms__c,SLA__c,SLApercentage__c,SLA_Credit__c,SLA_Details__c,Software__c,'+
			'Software_Amount__c,Software_Credits__c,Software_MFN__c,Sole_Source_or_Competitive__c,Stated_Renewal__c,Subscription_Fee_per_Truck__c,Subscription_Stated_Renew__c,Telecom_Link__c,'+
			'Telematics_Install_Type__c,Telematics_Provider__c,Terminal_Commitment_Delivery_Timeframe__c,Terminal_Commitment_Quantity__c,Terminal_Credit_Details__c,Terminal_Credits__c,'+
			'Terminal_List_Price_Discount_Details__c,Terrestrial_Data_Plan__c,Total_Funding__c,Trade_In_Program__c,Trade_In_Program_Details__c,Type_of_Price_Guarantee__c,User_Type__c,'+
			'VAR_Portion_of_Annual_Fees__c,VAR_Portion_of_SW_Fees__c,Version__c,What_is_Being_Purchased__c,Written_Consent__c,'+
			'(select Id, name, RecordTypeId,Accounting_Memo_Requirement__c,Accounting_Treatment_OMNI__c,Accounting_Treatment_Details__c,Add_On_Contract__c,Annual_Fees_Billing_Done_By__c,'+
				    'Start_Date_of_Annual_Maintenance__c,Application_Discounts__c,Applications__c,Assignment_Notes__c,Bill_To__c,CAS_Clause__c,Check__c,Check_Amount__c,Closed__c,'+
				    'Comments_Alternate_Payment_Schedule__c,Confidentiality__c,Confidentiality_Details__c,Contains_52_222_54_E_Verify__c,Contingency_Details__c,Contingency_Provision__c,Contract_Grade__c,'+
				    'Contract_Grade_Notes__c,Product_Type__c,Convenience_Clause__c,Customer_Indemnification__c,Customer_Limitation_of_Liability__c,Customer_s_Assignability_Rights__c,Currency_of_EULA__c,'+
				    'Data_Access__c,Data_Policy__c,Date_of_Final_Payment__c,Date_Received__c,DCs__c,DD250_Required__c,DD882_Required__c,Depost_with_Schedule_1__c,Detailed_Order_Status__c,'+
				    'DVIR_Fee_Schedule_3__c,DVIR_Units__c,Email_for_Primary_Contact__c,Evaluation_Term__c,If_No_Exchange_Rate__c,Ext_Terminal_Maintenance_Discount__c,Extended_Terminal_Maintenance__c,'+
				    'FAR_12_FAR_15__c,Fee_Start_Extension__c,Fees__c,File_Destruction_Date__c,Final_Payment_Received__c,Finance_Audit_Comments__c,Free_Driver_Dispatcher_Training__c,Free_Installation__c,'+
				    'Free_Installation_Details__c,Free_Installation_Training__c,Free_Service_Messaging__c,Free_Technical_Services__c,Funding_Date__c,Future_Products_Obsolescence_Clause__c,'+
				    'Governing_Law_Venue__c,Governing_Law_Venue_Notes__c,Government_Agency__c,Government_Property_Clause__c,Gov_t_Automated_Invoicing_Required__c,GSA__c,Hardware_MFN__c,Hardware_Platform__c,'+
				    'HOS_Fee_Schedule_3__c,HOS_Units__c,If_cause_is_Other_explain__c,If_cause_is_Restructure_or_Successor__c,If_with_exception_cause__c,In_Service__c,In_Service_NRF__c,Insurance__c,'+
				    'Insurance_Details__c,Invoicing__c,Last_Approved_By__c,License_Type__c,Limitation_of_Funds_Clause__c,Location_Type__c,Maintenance_Amount__c,Maintenance_Fee_Type__c,Term_of_Maintenance__c,'+
				    'Map_Coverage_Area__c,Map_Royalties_USD_if_paid_by_UPSLT__c,Map_Vendor__c,Maps_sold_by__c,MobileCast_Fee__c,MobileCast_Units__c,Mounts_Discount__c,Non_Standard_Cust_Indemnification_Detai__c,'+
				    'Non_Standard_Equipment_Terms__c,Non_Standard_Invoicing_Pmt_or_Tax_Term__c,Non_Standard_Omni_Indemnification_Detail__c,Non_Standard_Payment_Terms_Details__c,Non_Standard_Service_Terms__c,'+
				    'Non_Standard_Software_Terms__c,Non_Standard_Term_Termination_Terms__c,Non_Standard_Termination_Fees_or_Terms__c,Non_Standard_Cust_Limitation_of_Liabili__c,'+
				    'Non_Standard_Omni_Limitation_of_Liabilit__c,Number_of_Installations__c,Number_of_Licensed_Sites__c,Number_of_Mobile_Assets__c,Number_Of_RNT_Users__c,of_UPSLT_Training_Days_Quoted__c,'+
				    'Number_of_Sales_Reps_T_Planner__c,Number_of_Support_Recipients__c,Number_of_Vehicles__c,OMNI_ok_to_assign_w_o_consent_restructu__c,Omni_Assignability_Rights__c,Omni_Indemnification__c,'+
				    'Omni_Limitation_of_Liability__c,CTel_Contract_Number__c,Order_Status__c,Other_Hardware_Discounts__c,Other_Negotiated_Terms__c,Other_Non_Standard_Terms__c,Other_Shipment_Terms_Details__c,'+
				    'OTN__c,P_O_or_Check__c,Payment_1_Days__c,Date_of_VAR_Payment_to_UPSLT__c,Payment_1_to_UPSLT_USD__c,Payment_2_Days__c,Date_of_Payment_2_to_UPSLT__c,Payment_2_to_UPSLT_USD__c,'+
				    'Payment_3_Days__c,Date_of_Payment_3_to_UPSLT__c,Payment_3_to_UPSLT_USD__c,Payment_4_Days__c,Date_of_Payment_4_to_UPSLT__c,Payment_4_to_UPSLT_if_applicable_USD__c,Payment_5_Days__c,'+
				    'Payment_5_to_UPSLT_USD__c,Payment_6_Days__c,Payment_6_to_UPSLT_USD__c,Payment_Due_with_Contract__c,Payment_Due_With_Contract_RNT__c,Payment_Method__c,Payment_Terms_QES__c,'+
				    'Payment_Type_to_UPSLT__c,Payment_Withholds__c,Pending_SLA__c,Per_Day_Consulting_Fee_Quoted_UPSLT__c,Per_Day_Consulting_Fee_Quoted_VAR__c,PO_Amount__c,PO_Amount_RNT__c,'+
				    'Price_Guarantee_Details__c,Price_Increase_Cap__c,Price_Increase_Notice_Period_in_Days__c,Price_Increases_Y_N__c,Prime_or_Sub_Contractor__c,Project__c,Provision_ID_TCM__c,'+
				    'Related_Party__c,Related_Party_Details__c,Remarketing_Rights__c,Renewal_Rate__c,Replacement_Or_Addon__c,Reseller__c,Retention_Toolkit_Terms__c,RNT_Fee_Schedule_3__c,RNT_Hardware_Total__c,'+
				    'RNT_Installation_Total__c,RNT_Units__c,UPSLT_Portion_of_Annual_Fees__c,UPSLT_Portion_of_SW_Fees__c,UPSLT_Products__c,SBA_Plan_Prepared__c,Service_and_or_Data_Plan_Discounts_Not__c,'+
				    'Service_MFN__c,Service_Plan__c,Ship_To__c,Shipment_Terms__c,SLA__c,SLApercentage__c,SLA_Credit__c,SLA_Details__c,Software__c,Software_Amount__c,Software_Discounts__c,'+
				    'Software_MFN__c,Sole_Source_or_Competitive__c,Stated_Renewel__c,Subscription_Fee_per_Truck__c,Subscription_Stated_Renew__c,Telecom_Link__c,Telematics_Install_Type__c,'+
				    'Telematics_Provider__c,Terminal_Commitment_Delivery_Timeframe__c,Terminal_Commitment_Quantity__c,Terminal_Credit_Details__c,Terminal_Credits__c,Terminal_List_Price_Discount_Details__c,'+
				    'Terrestrial_Data_Plan__c,Total_Funding__c,Trade_In_Program__c,Trade_In_Program_Details__c,Type_of_Price_Guarantee__c,User_Type__c,VAR_Portion_of_Annual_Fees__c,VAR_Portion_of_SW_Fees__c,'+
				    'Version__c,What_is_Being_Purchased__c,Written_Consent__c from Provisions__r) from Contract';   
        return Database.getQueryLocator(Query);
    }
    
	global void execute(Database.BatchableContext BC, List<Contract> scope){
		
		Map<Id, Contract> updateContractMap = new Map<Id, Contract>();
		for(Contract cntrct : scope){
			 if(cntrct.Provisions__r != null && cntrct.Provisions__r.size() > 0){
			 	if(cntrct.Provisions__r.size() == 1){
			 		Provision__c prov = cntrct.Provisions__r.get(0);
			 		if(String.isBlank(cntrct.Accounting_Memo_Requirement__c)){cntrct.Accounting_Memo_Requirement__c = prov.Accounting_Memo_Requirement__c;}
					if(String.isBlank(cntrct.Accounting_Treatment_OMNI__c)){cntrct.Accounting_Treatment_OMNI__c = prov.Accounting_Treatment_OMNI__c;}
					if(String.isBlank(cntrct.Accounting_Treatment_Details__c)){cntrct.Accounting_Treatment_Details__c = prov.Accounting_Treatment_Details__c;}
					if(!cntrct.Add_On_Contract_c__c){cntrct.Add_On_Contract_c__c = prov.Add_On_Contract__c;}
					if(String.isBlank(cntrct.Annual_Fees_Billing_Done_By__c)){cntrct.Annual_Fees_Billing_Done_By__c = prov.Annual_Fees_Billing_Done_By__c;}
					if(String.isBlank(cntrct.Start_Date_of_Annual_Maintenance__c)){cntrct.Start_Date_of_Annual_Maintenance__c = prov.Start_Date_of_Annual_Maintenance__c;}
					if(String.isBlank(cntrct.Application_Discounts__c)){cntrct.Application_Discounts__c = prov.Application_Discounts__c;}
					if(String.isBlank(cntrct.Applications__c)){cntrct.Applications__c = prov.Applications__c;}
					if(String.isBlank(cntrct.Assignment_Notes__c)){cntrct.Assignment_Notes__c = prov.Assignment_Notes__c;}
					if(String.isBlank(cntrct.Bill_To__c)){cntrct.Bill_To__c = prov.Bill_To__c;}
					if(String.isBlank(cntrct.CAS_Clause__c)){cntrct.CAS_Clause__c = prov.CAS_Clause__c;}
					if(String.isBlank(cntrct.Check__c)){cntrct.Check__c = prov.Check__c;}
					if(cntrct.Check_Amount__c == null){cntrct.Check_Amount__c = prov.Check_Amount__c;}
					if(String.isBlank(cntrct.Closed__c)){cntrct.Closed__c = prov.Closed__c;}
					if(String.isBlank(cntrct.Comments_Alternate_Payment_Schedule__c)){cntrct.Comments_Alternate_Payment_Schedule__c = prov.Comments_Alternate_Payment_Schedule__c;}
					if(String.isBlank(cntrct.Confidentiality__c)){cntrct.Confidentiality__c = prov.Confidentiality__c;}
					if(String.isBlank(cntrct.Confidentiality_Details__c)){cntrct.Confidentiality_Details__c = prov.Confidentiality_Details__c;}
					if(String.isBlank(cntrct.Contains_52_222_54_E_Verify__c)){cntrct.Contains_52_222_54_E_Verify__c = prov.Contains_52_222_54_E_Verify__c;}
					if(String.isBlank(cntrct.Contingency_Details__c)){cntrct.Contingency_Details__c = prov.Contingency_Details__c;}
					if(String.isBlank(cntrct.Contingency_Provision__c)){cntrct.Contingency_Provision__c = prov.Contingency_Provision__c;}
					if(String.isBlank(cntrct.Contract_Grade__c)){cntrct.Contract_Grade__c = prov.Contract_Grade__c;}
					if(String.isBlank(cntrct.Contract_Grade_Notes__c)){cntrct.Contract_Grade_Notes__c = prov.Contract_Grade_Notes__c;}
					if(String.isBlank(cntrct.Product_Type__c)){cntrct.Product_Type__c = prov.Product_Type__c;}
					if(!cntrct.Convenience_Clause__c){cntrct.Convenience_Clause__c = prov.Convenience_Clause__c;}
					if(String.isBlank(cntrct.Customer_Indemnification__c)){cntrct.Customer_Indemnification__c = prov.Customer_Indemnification__c;}
					if(String.isBlank(cntrct.Counterparty_Limitation_of_Liability__c)){cntrct.Counterparty_Limitation_of_Liability__c = prov.Customer_Limitation_of_Liability__c;}
					if(String.isBlank(cntrct.Customer_s_Assignability_Rights__c)){cntrct.Customer_s_Assignability_Rights__c = prov.Customer_s_Assignability_Rights__c;}
					if(String.isBlank(cntrct.Currency_of_EULA__c)){cntrct.Currency_of_EULA__c = prov.Currency_of_EULA__c;}
					if(String.isBlank(cntrct.Data_Access__c)){cntrct.Data_Access__c = prov.Data_Access__c;}
					if(String.isBlank(cntrct.Data_Policy_c__c)){cntrct.Data_Policy_c__c = prov.Data_Policy__c;}
					if(cntrct.Date_of_Final_Payment__c==null){cntrct.Date_of_Final_Payment__c = prov.Date_of_Final_Payment__c;}
					if(cntrct.Date_Received__c==null){cntrct.Date_Received__c = prov.Date_Received__c;}
					if(cntrct.DCs__c==null){cntrct.DCs__c = prov.DCs__c;}
					if(String.isBlank(cntrct.DD250_Required__c)){cntrct.DD250_Required__c = prov.DD250_Required__c;}
					if(String.isBlank(cntrct.DD882_Required__c)){cntrct.DD882_Required__c = prov.DD882_Required__c;}
					if(cntrct.Depost_with_Schedule_1__c==null){cntrct.Depost_with_Schedule_1__c = prov.Depost_with_Schedule_1__c;}
					if(String.isBlank(cntrct.Detailed_Order_Status_c__c)){cntrct.Detailed_Order_Status_c__c = prov.Detailed_Order_Status__c;}
					if(cntrct.DVIR_Fee_Schedule_3__c==null){cntrct.DVIR_Fee_Schedule_3__c = prov.DVIR_Fee_Schedule_3__c;}
					if(cntrct.DVIR_Units__c==null){cntrct.DVIR_Units__c = prov.DVIR_Units__c;}
					if(String.isBlank(cntrct.Email_for_Primary_Contact__c)){cntrct.Email_for_Primary_Contact__c = prov.Email_for_Primary_Contact__c;}
					if(String.isBlank(cntrct.Evaluation_Term__c)){cntrct.Evaluation_Term__c = prov.Evaluation_Term__c;}
					if(cntrct.Exchange_Rate_1_if_USD__c==null){cntrct.Exchange_Rate_1_if_USD__c = prov.If_No_Exchange_Rate__c;}
					if(cntrct.Ext_Terminal_Maintenance_Discount__c==null){cntrct.Ext_Terminal_Maintenance_Discount__c = prov.Ext_Terminal_Maintenance_Discount__c;}
					if(String.isBlank(cntrct.Extended_Terminal_Maintenance__c)){cntrct.Extended_Terminal_Maintenance__c = prov.Extended_Terminal_Maintenance__c;}
					if(String.isBlank(cntrct.FAR_12_FAR_15__c)){cntrct.FAR_12_FAR_15__c = prov.FAR_12_FAR_15__c;}
					if(cntrct.Fee_Start_Extension_c__c==null){cntrct.Fee_Start_Extension_c__c = prov.Fee_Start_Extension__c;}
					if(cntrct.Fees__c==null){cntrct.Fees__c = prov.Fees__c;}
					if(cntrct.File_Destruction_Date__c==null){cntrct.File_Destruction_Date__c = prov.File_Destruction_Date__c;}
					if(String.isBlank(cntrct.Final_Payment_Received__c)){cntrct.Final_Payment_Received__c = prov.Final_Payment_Received__c;}
					if(String.isBlank(cntrct.Finance_Audit_Comments__c)){cntrct.Finance_Audit_Comments__c = prov.Finance_Audit_Comments__c;}
					if(String.isBlank(cntrct.Free_Driver_Dispatcher_Training__c)){cntrct.Free_Driver_Dispatcher_Training__c = prov.Free_Driver_Dispatcher_Training__c;}
					if(String.isBlank(cntrct.Free_Installation__c)){cntrct.Free_Installation__c = prov.Free_Installation__c;}
					if(String.isBlank(cntrct.Free_Installation_Details__c)){cntrct.Free_Installation_Details__c = prov.Free_Installation_Details__c;}
					if(String.isBlank(cntrct.Free_Installation_Training__c)){cntrct.Free_Installation_Training__c = prov.Free_Installation_Training__c;}
					if(String.isBlank(cntrct.Free_Service_Messaging__c)){cntrct.Free_Service_Messaging__c = prov.Free_Service_Messaging__c;}
					if(String.isBlank(cntrct.Free_Technical_Services__c)){cntrct.Free_Technical_Services__c = prov.Free_Technical_Services__c;}
					if(cntrct.Funding_Date__c==null){cntrct.Funding_Date__c = prov.Funding_Date__c;}
					if(String.isBlank(cntrct.Future_Products_Obsolescence_Clause__c)){cntrct.Future_Products_Obsolescence_Clause__c = prov.Future_Products_Obsolescence_Clause__c;}
					if(String.isBlank(cntrct.Governing_Law_Venue__c)){cntrct.Governing_Law_Venue__c = prov.Governing_Law_Venue__c;}
					if(String.isBlank(cntrct.Governing_Law_Venue_Notes__c)){cntrct.Governing_Law_Venue_Notes__c = prov.Governing_Law_Venue_Notes__c;}
					if(String.isBlank(cntrct.Government_Agency__c)){cntrct.Government_Agency__c = prov.Government_Agency__c;}
					if(String.isBlank(cntrct.Government_Property_Clause__c)){cntrct.Government_Property_Clause__c = prov.Government_Property_Clause__c;}
					if(String.isBlank(cntrct.Gov_t_Automated_Invoicing_Required__c)){cntrct.Gov_t_Automated_Invoicing_Required__c = prov.Gov_t_Automated_Invoicing_Required__c;}
					if(String.isBlank(cntrct.GSA__c)){cntrct.GSA__c = prov.GSA__c;}
					if(String.isBlank(cntrct.Hardware_MFN__c)){cntrct.Hardware_MFN__c = prov.Hardware_MFN__c;}
					if(String.isBlank(cntrct.Hardware_Platform__c)){cntrct.Hardware_Platform__c = prov.Hardware_Platform__c;}
					if(cntrct.HOS_Fee_Schedule_3__c==null){cntrct.HOS_Fee_Schedule_3__c = prov.HOS_Fee_Schedule_3__c;}
					if(cntrct.HOS_Units__c==null){cntrct.HOS_Units__c = prov.HOS_Units__c;}
					if(String.isBlank(cntrct.If_cause_is_Other_explain__c)){cntrct.If_cause_is_Other_explain__c = prov.If_cause_is_Other_explain__c;}
					if(String.isBlank(cntrct.If_cause_is_Restructure_or_Successor__c)){cntrct.If_cause_is_Restructure_or_Successor__c = prov.If_cause_is_Restructure_or_Successor__c;}
					if(String.isBlank(cntrct.If_with_exception_cause__c)){cntrct.If_with_exception_cause__c = prov.If_with_exception_cause__c;}
					if(String.isBlank(cntrct.In_Service__c)){cntrct.In_Service__c = prov.In_Service__c;}
					if(String.isBlank(cntrct.In_Service_NRF__c)){cntrct.In_Service_NRF__c = prov.In_Service_NRF__c;}
					if(String.isBlank(cntrct.Insurance__c)){cntrct.Insurance__c = prov.Insurance__c;}
					if(String.isBlank(cntrct.Insurance_Details__c)){cntrct.Insurance_Details__c = prov.Insurance_Details__c;}
					//if(!cntrct.Invoicing__c){cntrct.Invoicing__c = prov.Invoicing__c;}
					if(String.isBlank(cntrct.Last_Approved_By__c)){cntrct.Last_Approved_By__c = prov.Last_Approved_By__c;}
					if(String.isBlank(cntrct.License_Type__c)){cntrct.License_Type__c = prov.License_Type__c;}
					if(String.isBlank(cntrct.Limitation_of_Funds_Clause__c)){cntrct.Limitation_of_Funds_Clause__c = prov.Limitation_of_Funds_Clause__c;}
					if(String.isBlank(cntrct.Location_Type__c)){cntrct.Location_Type__c = prov.Location_Type__c;}
					if(cntrct.Maintenance_Amount__c==null){cntrct.Maintenance_Amount__c = prov.Maintenance_Amount__c;}
					if(String.isBlank(cntrct.Maintenance_Fee_Type__c)){cntrct.Maintenance_Fee_Type__c = prov.Maintenance_Fee_Type__c;}
					if(String.isBlank(cntrct.Term_of_Maintenance__c)){cntrct.Term_of_Maintenance__c = prov.Term_of_Maintenance__c;}
					if(String.isBlank(cntrct.Map_Coverage_Area__c)){cntrct.Map_Coverage_Area__c = prov.Map_Coverage_Area__c;}
					if(cntrct.Map_Royalties_USD_if_paid_by_Roadnet__c==null){cntrct.Map_Royalties_USD_if_paid_by_Roadnet__c = prov.Map_Royalties_USD_if_paid_by_UPSLT__c;}
					if(String.isBlank(cntrct.Map_Vendor__c)){cntrct.Map_Vendor__c = prov.Map_Vendor__c;}
					if(String.isBlank(cntrct.Maps_Sold_by__c)){cntrct.Maps_Sold_by__c = prov.Maps_sold_by__c;}
					if(cntrct.MobileCast_Fee_Schedule_3__c==null){cntrct.MobileCast_Fee_Schedule_3__c = prov.MobileCast_Fee__c;}
					if(cntrct.MobileCast_Units__c==null){cntrct.MobileCast_Units__c = prov.MobileCast_Units__c;}
					if(String.isBlank(cntrct.Mounts_Discount__c)){cntrct.Mounts_Discount__c = prov.Mounts_Discount__c;}
					if(String.isBlank(cntrct.Non_Standard_CP_Indemnification_Detail__c)){cntrct.Non_Standard_CP_Indemnification_Detail__c = prov.Non_Standard_Cust_Indemnification_Detai__c;}
					if(String.isBlank(cntrct.Non_Standard_Equipment_Terms__c)){cntrct.Non_Standard_Equipment_Terms__c = prov.Non_Standard_Equipment_Terms__c;}
					if(String.isBlank(cntrct.Non_Standard_Invoicing_Pmt_or_Tax_Term__c)){cntrct.Non_Standard_Invoicing_Pmt_or_Tax_Term__c = prov.Non_Standard_Invoicing_Pmt_or_Tax_Term__c;}
					if(String.isBlank(cntrct.Non_Standard_Omni_Indemnification_Detail__c)){cntrct.Non_Standard_Omni_Indemnification_Detail__c = prov.Non_Standard_Omni_Indemnification_Detail__c;}
					if(String.isBlank(cntrct.Non_Standard_Payment_Terms_Details__c)){cntrct.Non_Standard_Payment_Terms_Details__c = prov.Non_Standard_Payment_Terms_Details__c;}
					if(String.isBlank(cntrct.Non_Standard_Service_Terms__c)){cntrct.Non_Standard_Service_Terms__c = prov.Non_Standard_Service_Terms__c;}
					if(String.isBlank(cntrct.Non_Standard_Software_Terms__c)){cntrct.Non_Standard_Software_Terms__c = prov.Non_Standard_Software_Terms__c;}
					if(String.isBlank(cntrct.Non_Standard_Term_Termination_Terms__c)){cntrct.Non_Standard_Term_Termination_Terms__c = prov.Non_Standard_Term_Termination_Terms__c;}
					if(String.isBlank(cntrct.Non_Standard_Termination_Fees_or_Terms__c)){cntrct.Non_Standard_Termination_Fees_or_Terms__c = prov.Non_Standard_Termination_Fees_or_Terms__c;}
					if(String.isBlank(cntrct.Non_Standard_Cust_Limitation_of_Liabili__c)){cntrct.Non_Standard_Cust_Limitation_of_Liabili__c = prov.Non_Standard_Cust_Limitation_of_Liabili__c;}
					if(String.isBlank(cntrct.Non_Standard_Omni_Limitation_of_Liabilit__c)){cntrct.Non_Standard_Omni_Limitation_of_Liabilit__c = prov.Non_Standard_Omni_Limitation_of_Liabilit__c;}
					if(cntrct.Number_of_Installations__c==null){cntrct.Number_of_Installations__c = prov.Number_of_Installations__c;}
					if(cntrct.Number_of_Licensed_Sites__c==null){cntrct.Number_of_Licensed_Sites__c = prov.Number_of_Licensed_Sites__c;}
					if(cntrct.Number_of_Mobile_Assets__c==null){cntrct.Number_of_Mobile_Assets__c = prov.Number_of_Mobile_Assets__c;}
					if(cntrct.Number_Of_RNT_Users__c==null){cntrct.Number_Of_RNT_Users__c = prov.Number_Of_RNT_Users__c;}
					if(cntrct.Number_of_RTI_Training_Days_Quoted__c==null){cntrct.Number_of_RTI_Training_Days_Quoted__c = prov.of_UPSLT_Training_Days_Quoted__c;}
					if(cntrct.Number_of_Sales_Reps_T_Planner__c==null){cntrct.Number_of_Sales_Reps_T_Planner__c = prov.Number_of_Sales_Reps_T_Planner__c;}
					if(cntrct.Number_of_Support_Recipients__c==null){cntrct.Number_of_Support_Recipients__c = prov.Number_of_Support_Recipients__c;}
					if(cntrct.Number_of_Vehicles__c==null){cntrct.Number_of_Vehicles__c = prov.Number_of_Vehicles__c;}
					if(String.isBlank(cntrct.OMNI_assign_w_o_consent_restructure__c)){cntrct.OMNI_assign_w_o_consent_restructure__c = prov.OMNI_ok_to_assign_w_o_consent_restructu__c;}
					if(String.isBlank(cntrct.Omni_Assignability_Rights__c)){cntrct.Omni_Assignability_Rights__c = prov.Omni_Assignability_Rights__c;}
					if(String.isBlank(cntrct.Omni_Indemnification__c)){cntrct.Omni_Indemnification__c = prov.Omni_Indemnification__c;}
					if(String.isBlank(cntrct.Omni_Limitation_of_Liability__c)){cntrct.Omni_Limitation_of_Liability__c = prov.Omni_Limitation_of_Liability__c;}
					if(String.isBlank(cntrct.CTel_Contract_Number__c)){cntrct.CTel_Contract_Number__c = prov.CTel_Contract_Number__c;}
					if(String.isBlank(cntrct.Order_Status__c)){cntrct.Order_Status__c = prov.Order_Status__c;}
					if(String.isBlank(cntrct.Other_Hardware_Discounts__c)){cntrct.Other_Hardware_Discounts__c = prov.Other_Hardware_Discounts__c;}
					if(String.isBlank(cntrct.Other_Negotiated_Terms__c)){cntrct.Other_Negotiated_Terms__c = prov.Other_Negotiated_Terms__c;}
					if(String.isBlank(cntrct.Other_Non_Standard_Discounts__c)){cntrct.Other_Non_Standard_Discounts__c = prov.Other_Non_Standard_Terms__c;}
					if(String.isBlank(cntrct.Other_Shipment_Terms_Details__c)){cntrct.Other_Shipment_Terms_Details__c = prov.Other_Shipment_Terms_Details__c;}
					if(String.isBlank(cntrct.OTN__c)){cntrct.OTN__c = prov.OTN__c;}
					if(String.isBlank(cntrct.P_O_or_Check__c)){cntrct.P_O_or_Check__c = prov.P_O_or_Check__c;}
					if(cntrct.Payment_1_Days__c==null){cntrct.Payment_1_Days__c = prov.Payment_1_Days__c;}
					if(String.isBlank(cntrct.Date_of_VAR_Payment_to_UPSLT__c)){cntrct.Date_of_VAR_Payment_to_UPSLT__c = prov.Date_of_VAR_Payment_to_UPSLT__c;}
					if(cntrct.Payment_1_to_UPSLT_USD__c==null){cntrct.Payment_1_to_UPSLT_USD__c = prov.Payment_1_to_UPSLT_USD__c;}
					if(cntrct.Payment_2_Days__c==null){cntrct.Payment_2_Days__c = prov.Payment_2_Days__c;}
					if(String.isBlank(cntrct.Date_of_Payment_2_to_UPSLT__c)){cntrct.Date_of_Payment_2_to_UPSLT__c = prov.Date_of_Payment_2_to_UPSLT__c;}
					if(cntrct.Payment_2_to_RTI_USD__c==null){cntrct.Payment_2_to_RTI_USD__c = prov.Payment_2_to_UPSLT_USD__c;}
					if(cntrct.Payment_3_Days__c==null){cntrct.Payment_3_Days__c = prov.Payment_3_Days__c;}
					if(String.isBlank(cntrct.Date_of_Payment_3_to_UPSLT__c)){cntrct.Date_of_Payment_3_to_UPSLT__c = prov.Date_of_Payment_3_to_UPSLT__c;}
					if(cntrct.Payment_3_to_UPSLT_USD__c==null){cntrct.Payment_3_to_UPSLT_USD__c = prov.Payment_3_to_UPSLT_USD__c;}
					if(cntrct.Payment_4_Days__c==null){cntrct.Payment_4_Days__c = prov.Payment_4_Days__c;}
					if(String.isBlank(cntrct.Date_of_Payment_4_to_UPSLT__c)){cntrct.Date_of_Payment_4_to_UPSLT__c = prov.Date_of_Payment_4_to_UPSLT__c;}
					if(cntrct.Payment_4_to_UPSLT_if_applicable_USD__c==null){cntrct.Payment_4_to_UPSLT_if_applicable_USD__c = prov.Payment_4_to_UPSLT_if_applicable_USD__c;}
					if(cntrct.Payment_5_Days__c==null){cntrct.Payment_5_Days__c = prov.Payment_5_Days__c;}
					if(cntrct.Payment_5_to_UPSLT_USD__c==null){cntrct.Payment_5_to_UPSLT_USD__c = prov.Payment_5_to_UPSLT_USD__c;}
					if(cntrct.Payment_6_Days_after_Delivery__c==null){cntrct.Payment_6_Days_after_Delivery__c = prov.Payment_6_Days__c;}
					if(cntrct.Payment_6_to_RTI_USD__c==null){cntrct.Payment_6_to_RTI_USD__c = prov.Payment_6_to_UPSLT_USD__c;}
					if(!cntrct.Payment_Due_with_Contract__c){cntrct.Payment_Due_with_Contract__c = prov.Payment_Due_with_Contract__c;}
					if(!cntrct.Payment_Due_With_Contract_RNT__c){cntrct.Payment_Due_With_Contract_RNT__c = prov.Payment_Due_With_Contract_RNT__c;}
					if(String.isBlank(cntrct.Payment_Method__c)){cntrct.Payment_Method__c = prov.Payment_Method__c;}
					if(String.isBlank(cntrct.Payment_Terms__c)){cntrct.Payment_Terms__c = prov.Payment_Terms_QES__c;}
					if(String.isBlank(cntrct.Payment_Type_to_RTI__c)){cntrct.Payment_Type_to_RTI__c = prov.Payment_Type_to_UPSLT__c;}
					if(String.isBlank(cntrct.Payment_Withholds__c)){cntrct.Payment_Withholds__c = prov.Payment_Withholds__c;}
					if(!cntrct.Pending_SLA__c){cntrct.Pending_SLA__c = prov.Pending_SLA__c;}
					if(cntrct.Per_Day_Consulting_Fee_Quoted_UPSLT__c==null){cntrct.Per_Day_Consulting_Fee_Quoted_UPSLT__c = prov.Per_Day_Consulting_Fee_Quoted_UPSLT__c;}
					if(cntrct.Per_Day_Consulting_Fee_Quoted_VAR__c==null){cntrct.Per_Day_Consulting_Fee_Quoted_VAR__c = prov.Per_Day_Consulting_Fee_Quoted_VAR__c;}
					if(cntrct.PO_Amount__c==null){cntrct.PO_Amount__c = prov.PO_Amount__c;}
					if(cntrct.PO_Amount_RNT__c==null){cntrct.PO_Amount_RNT__c = prov.PO_Amount_RNT__c;}
					if(String.isBlank(cntrct.Price_Guarantee_Details__c)){cntrct.Price_Guarantee_Details__c = prov.Price_Guarantee_Details__c;}
					if(String.isBlank(cntrct.Price_Increase_Cap__c)){cntrct.Price_Increase_Cap__c = prov.Price_Increase_Cap__c;}
					if(cntrct.Price_Increase_Notice_Period_in_Days__c==null){cntrct.Price_Increase_Notice_Period_in_Days__c = prov.Price_Increase_Notice_Period_in_Days__c;}
					if(String.isBlank(cntrct.Price_Increases_Y_N__c)){cntrct.Price_Increases_Y_N__c = prov.Price_Increases_Y_N__c;}
					if(String.isBlank(cntrct.Prime_or_Sub_Contractor__c)){cntrct.Prime_or_Sub_Contractor__c = prov.Prime_or_Sub_Contractor__c;}
					if(String.isBlank(cntrct.Project__c)){cntrct.Project__c = prov.Project__c;}
					if(String.isBlank(cntrct.Provision_ID_TCM__c)){cntrct.Provision_ID_TCM__c = prov.Provision_ID_TCM__c;}
					if(String.isBlank(cntrct.Related_Party__c)){cntrct.Related_Party__c = prov.Related_Party__c;}
					if(String.isBlank(cntrct.Related_Party_Details__c)){cntrct.Related_Party_Details__c = prov.Related_Party_Details__c;}
					if(String.isBlank(cntrct.Remarketing_Rights__c)){cntrct.Remarketing_Rights__c = prov.Remarketing_Rights__c;}
					if(cntrct.Renewal_Rate__c==null){cntrct.Renewal_Rate__c = prov.Renewal_Rate__c;}
					if(String.isBlank(cntrct.Replacement_Or_Addon__c)){cntrct.Replacement_Or_Addon__c = prov.Replacement_Or_Addon__c;}
					if(String.isBlank(cntrct.Reseller__c)){cntrct.Reseller__c = prov.Reseller__c;}
					if(String.isBlank(cntrct.Retention_Toolkit_Terms__c)){cntrct.Retention_Toolkit_Terms__c = prov.Retention_Toolkit_Terms__c;}
					if(cntrct.RNT_Fee_Schedule_3__c==null){cntrct.RNT_Fee_Schedule_3__c = prov.RNT_Fee_Schedule_3__c;}
					if(cntrct.RNT_Hardware_Total__c==null){cntrct.RNT_Hardware_Total__c = prov.RNT_Hardware_Total__c;}
					if(cntrct.RNT_Installation_Total__c==null){cntrct.RNT_Installation_Total__c = prov.RNT_Installation_Total__c;}
					if(cntrct.RNT_Units__c==null){cntrct.RNT_Units__c = prov.RNT_Units__c;}
					if(cntrct.UPSLT_Portion_of_Annual_Fees__c==null){cntrct.UPSLT_Portion_of_Annual_Fees__c = prov.UPSLT_Portion_of_Annual_Fees__c;}
					if(cntrct.UPSLT_Portion_of_SW_Fees__c==null){cntrct.UPSLT_Portion_of_SW_Fees__c = prov.UPSLT_Portion_of_SW_Fees__c;}
					if(String.isBlank(cntrct.UPSLT_Products__c)){cntrct.UPSLT_Products__c = prov.UPSLT_Products__c;}
					if(String.isBlank(cntrct.SBA_Plan_Prepared__c)){cntrct.SBA_Plan_Prepared__c = prov.SBA_Plan_Prepared__c;}
					if(String.isBlank(cntrct.Service_Data_Plan_Discounts_Notes__c)){cntrct.Service_Data_Plan_Discounts_Notes__c = prov.Service_and_or_Data_Plan_Discounts_Not__c;}
					if(String.isBlank(cntrct.Service_MFN__c)){cntrct.Service_MFN__c = prov.Service_MFN__c;}
					if(String.isBlank(cntrct.Service_Plan__c)){cntrct.Service_Plan__c = prov.Service_Plan__c;}
					if(String.isBlank(cntrct.Ship_To__c)){cntrct.Ship_To__c = prov.Ship_To__c;}
					if(String.isBlank(cntrct.Shipment_Terms__c)){cntrct.Shipment_Terms__c = prov.Shipment_Terms__c;}
					if(String.isBlank(cntrct.SLA__c)){cntrct.SLA__c = prov.SLA__c;}
					if(String.isBlank(cntrct.SLApercentage__c)){cntrct.SLApercentage__c = prov.SLApercentage__c;}
					if(String.isBlank(cntrct.SLA_Credit__c)){cntrct.SLA_Credit__c = prov.SLA_Credit__c;}
					if(String.isBlank(cntrct.SLA_Details__c)){cntrct.SLA_Details__c = prov.SLA_Details__c;}
					if(String.isBlank(cntrct.Software__c)){cntrct.Software__c = prov.Software__c;}
					if(cntrct.Software_Amount__c==null){cntrct.Software_Amount__c = prov.Software_Amount__c;}
					if(String.isBlank(cntrct.Software_Credits__c)){cntrct.Software_Credits__c = prov.Software_Discounts__c;}
					if(String.isBlank(cntrct.Software_MFN__c)){cntrct.Software_MFN__c = prov.Software_MFN__c;}
					if(String.isBlank(cntrct.Sole_Source_or_Competitive__c)){cntrct.Sole_Source_or_Competitive__c = prov.Sole_Source_or_Competitive__c;}
					if(!cntrct.Stated_Renewal__c){cntrct.Stated_Renewal__c = prov.Stated_Renewel__c;}
					if(cntrct.Subscription_Fee_per_Truck__c==null){cntrct.Subscription_Fee_per_Truck__c = prov.Subscription_Fee_per_Truck__c;}
					if(!cntrct.Subscription_Stated_Renew__c){cntrct.Subscription_Stated_Renew__c = prov.Subscription_Stated_Renew__c;}
					if(String.isBlank(cntrct.Telecom_Link__c)){cntrct.Telecom_Link__c = prov.Telecom_Link__c;}
					if(String.isBlank(cntrct.Telematics_Install_Type__c)){cntrct.Telematics_Install_Type__c = prov.Telematics_Install_Type__c;}
					if(String.isBlank(cntrct.Telematics_Provider__c)){cntrct.Telematics_Provider__c = prov.Telematics_Provider__c;}
					if(String.isBlank(cntrct.Terminal_Commitment_Delivery_Timeframe__c)){cntrct.Terminal_Commitment_Delivery_Timeframe__c = prov.Terminal_Commitment_Delivery_Timeframe__c;}
					if(String.isBlank(cntrct.Terminal_Commitment_Quantity__c)){cntrct.Terminal_Commitment_Quantity__c = prov.Terminal_Commitment_Quantity__c;}
					if(String.isBlank(cntrct.Terminal_Credit_Details__c)){cntrct.Terminal_Credit_Details__c = prov.Terminal_Credit_Details__c;}
					if(String.isBlank(cntrct.Terminal_Credits__c)){cntrct.Terminal_Credits__c = prov.Terminal_Credits__c;}
					if(String.isBlank(cntrct.Terminal_List_Price_Discount_Details__c)){cntrct.Terminal_List_Price_Discount_Details__c = prov.Terminal_List_Price_Discount_Details__c;}
					if(String.isBlank(cntrct.Terrestrial_Data_Plan__c)){cntrct.Terrestrial_Data_Plan__c = prov.Terrestrial_Data_Plan__c;}
					if(cntrct.Total_Funding__c==null){cntrct.Total_Funding__c = prov.Total_Funding__c;}
					if(String.isBlank(cntrct.Trade_In_Program__c)){cntrct.Trade_In_Program__c = prov.Trade_In_Program__c;}
					if(String.isBlank(cntrct.Trade_In_Program_Details__c)){cntrct.Trade_In_Program_Details__c = prov.Trade_In_Program_Details__c;}
					if(String.isBlank(cntrct.Type_of_Price_Guarantee__c)){cntrct.Type_of_Price_Guarantee__c = prov.Type_of_Price_Guarantee__c;}
					if(String.isBlank(cntrct.User_Type__c)){cntrct.User_Type__c = prov.User_Type__c;}
					if(cntrct.VAR_Portion_of_Annual_Fees__c==null){cntrct.VAR_Portion_of_Annual_Fees__c = prov.VAR_Portion_of_Annual_Fees__c;}
					if(cntrct.VAR_Portion_of_SW_Fees__c==null){cntrct.VAR_Portion_of_SW_Fees__c = prov.VAR_Portion_of_SW_Fees__c;}
					if(String.isBlank(cntrct.Version__c)){cntrct.Version__c = prov.Version__c;}
					if(String.isBlank(cntrct.What_is_Being_Purchased__c)){cntrct.What_is_Being_Purchased__c = prov.What_is_Being_Purchased__c;}
					if(String.isBlank(cntrct.Written_Consent__c)){cntrct.Written_Consent__c = prov.Written_Consent__c;}
					
			 	}
			 	else{
					for(Provision__c prov : cntrct.Provisions__r){
						if(String.isBlank(cntrct.Accounting_Memo_Requirement__c)){cntrct.Accounting_Memo_Requirement__c = prov.Accounting_Memo_Requirement__c;}
						if(String.isBlank(cntrct.Accounting_Treatment_OMNI__c)){cntrct.Accounting_Treatment_OMNI__c = prov.Accounting_Treatment_OMNI__c;}
						if(String.isBlank(cntrct.Accounting_Treatment_Details__c)){cntrct.Accounting_Treatment_Details__c = prov.Accounting_Treatment_Details__c;}
						if(!cntrct.Add_On_Contract_c__c){cntrct.Add_On_Contract_c__c = prov.Add_On_Contract__c;}
						if(String.isBlank(cntrct.Annual_Fees_Billing_Done_By__c)){cntrct.Annual_Fees_Billing_Done_By__c = prov.Annual_Fees_Billing_Done_By__c;}
						if(String.isBlank(cntrct.Start_Date_of_Annual_Maintenance__c)){cntrct.Start_Date_of_Annual_Maintenance__c = prov.Start_Date_of_Annual_Maintenance__c;}
						if(String.isBlank(cntrct.Application_Discounts__c)){cntrct.Application_Discounts__c = prov.Application_Discounts__c;}
						if(String.isBlank(cntrct.Applications__c)){cntrct.Applications__c = prov.Applications__c;}
						if(String.isBlank(cntrct.Assignment_Notes__c)){cntrct.Assignment_Notes__c = prov.Assignment_Notes__c;}
						if(String.isBlank(cntrct.Bill_To__c)){cntrct.Bill_To__c = prov.Bill_To__c;}
						if(String.isBlank(cntrct.CAS_Clause__c)){cntrct.CAS_Clause__c = prov.CAS_Clause__c;}
						if(String.isBlank(cntrct.Check__c)){cntrct.Check__c = prov.Check__c;}
						if(cntrct.Check_Amount__c == null){cntrct.Check_Amount__c = prov.Check_Amount__c;}
						if(String.isBlank(cntrct.Closed__c)){cntrct.Closed__c = prov.Closed__c;}
						if(String.isBlank(cntrct.Comments_Alternate_Payment_Schedule__c)){cntrct.Comments_Alternate_Payment_Schedule__c = prov.Comments_Alternate_Payment_Schedule__c;}
						if(String.isBlank(cntrct.Confidentiality__c)){cntrct.Confidentiality__c = prov.Confidentiality__c;}
						if(String.isBlank(cntrct.Confidentiality_Details__c)){cntrct.Confidentiality_Details__c = prov.Confidentiality_Details__c;}
						if(String.isBlank(cntrct.Contains_52_222_54_E_Verify__c)){cntrct.Contains_52_222_54_E_Verify__c = prov.Contains_52_222_54_E_Verify__c;}
						if(String.isBlank(cntrct.Contingency_Details__c)){cntrct.Contingency_Details__c = prov.Contingency_Details__c;}
						if(String.isBlank(cntrct.Contingency_Provision__c)){cntrct.Contingency_Provision__c = prov.Contingency_Provision__c;}
						if(String.isBlank(cntrct.Contract_Grade__c)){cntrct.Contract_Grade__c = prov.Contract_Grade__c;}
						if(String.isBlank(cntrct.Contract_Grade_Notes__c)){cntrct.Contract_Grade_Notes__c = prov.Contract_Grade_Notes__c;}
						if(String.isBlank(cntrct.Product_Type__c)){cntrct.Product_Type__c = prov.Product_Type__c;}
						if(!cntrct.Convenience_Clause__c){cntrct.Convenience_Clause__c = prov.Convenience_Clause__c;}
						if(String.isBlank(cntrct.Customer_Indemnification__c)){cntrct.Customer_Indemnification__c = prov.Customer_Indemnification__c;}
						if(String.isBlank(cntrct.Counterparty_Limitation_of_Liability__c)){cntrct.Counterparty_Limitation_of_Liability__c = prov.Customer_Limitation_of_Liability__c;}
						if(String.isBlank(cntrct.Customer_s_Assignability_Rights__c)){cntrct.Customer_s_Assignability_Rights__c = prov.Customer_s_Assignability_Rights__c;}
						if(String.isBlank(cntrct.Currency_of_EULA__c)){cntrct.Currency_of_EULA__c = prov.Currency_of_EULA__c;}
						if(String.isBlank(cntrct.Data_Access__c)){cntrct.Data_Access__c = prov.Data_Access__c;}
						if(String.isBlank(cntrct.Data_Policy_c__c)){cntrct.Data_Policy_c__c = prov.Data_Policy__c;}
						if(cntrct.Date_of_Final_Payment__c==null){cntrct.Date_of_Final_Payment__c = prov.Date_of_Final_Payment__c;}
						if(cntrct.Date_Received__c==null){cntrct.Date_Received__c = prov.Date_Received__c;}
						if(cntrct.DCs__c==null){cntrct.DCs__c = prov.DCs__c;}
						if(String.isBlank(cntrct.DD250_Required__c)){cntrct.DD250_Required__c = prov.DD250_Required__c;}
						if(String.isBlank(cntrct.DD882_Required__c)){cntrct.DD882_Required__c = prov.DD882_Required__c;}
						if(cntrct.Depost_with_Schedule_1__c==null){cntrct.Depost_with_Schedule_1__c = prov.Depost_with_Schedule_1__c;}
						if(String.isBlank(cntrct.Detailed_Order_Status_c__c)){cntrct.Detailed_Order_Status_c__c = prov.Detailed_Order_Status__c;}
						if(cntrct.DVIR_Fee_Schedule_3__c==null){cntrct.DVIR_Fee_Schedule_3__c = prov.DVIR_Fee_Schedule_3__c;}
						if(cntrct.DVIR_Units__c==null){cntrct.DVIR_Units__c = prov.DVIR_Units__c;}
						if(String.isBlank(cntrct.Email_for_Primary_Contact__c)){cntrct.Email_for_Primary_Contact__c = prov.Email_for_Primary_Contact__c;}
						if(String.isBlank(cntrct.Evaluation_Term__c)){cntrct.Evaluation_Term__c = prov.Evaluation_Term__c;}
						if(cntrct.Exchange_Rate_1_if_USD__c==null){cntrct.Exchange_Rate_1_if_USD__c = prov.If_No_Exchange_Rate__c;}
						if(cntrct.Ext_Terminal_Maintenance_Discount__c==null){cntrct.Ext_Terminal_Maintenance_Discount__c = prov.Ext_Terminal_Maintenance_Discount__c;}
						if(String.isBlank(cntrct.Extended_Terminal_Maintenance__c)){cntrct.Extended_Terminal_Maintenance__c = prov.Extended_Terminal_Maintenance__c;}
						if(String.isBlank(cntrct.FAR_12_FAR_15__c)){cntrct.FAR_12_FAR_15__c = prov.FAR_12_FAR_15__c;}
						if(cntrct.Fee_Start_Extension_c__c==null){cntrct.Fee_Start_Extension_c__c = prov.Fee_Start_Extension__c;}
						if(cntrct.Fees__c==null){cntrct.Fees__c = prov.Fees__c;}
						if(cntrct.File_Destruction_Date__c==null){cntrct.File_Destruction_Date__c = prov.File_Destruction_Date__c;}
						if(String.isBlank(cntrct.Final_Payment_Received__c)){cntrct.Final_Payment_Received__c = prov.Final_Payment_Received__c;}
						if(String.isBlank(cntrct.Finance_Audit_Comments__c)){cntrct.Finance_Audit_Comments__c = prov.Finance_Audit_Comments__c;}
						if(String.isBlank(cntrct.Free_Driver_Dispatcher_Training__c)){cntrct.Free_Driver_Dispatcher_Training__c = prov.Free_Driver_Dispatcher_Training__c;}
						if(String.isBlank(cntrct.Free_Installation__c)){cntrct.Free_Installation__c = prov.Free_Installation__c;}
						if(String.isBlank(cntrct.Free_Installation_Details__c)){cntrct.Free_Installation_Details__c = prov.Free_Installation_Details__c;}
						if(String.isBlank(cntrct.Free_Installation_Training__c)){cntrct.Free_Installation_Training__c = prov.Free_Installation_Training__c;}
						if(String.isBlank(cntrct.Free_Service_Messaging__c)){cntrct.Free_Service_Messaging__c = prov.Free_Service_Messaging__c;}
						if(String.isBlank(cntrct.Free_Technical_Services__c)){cntrct.Free_Technical_Services__c = prov.Free_Technical_Services__c;}
						if(cntrct.Funding_Date__c==null){cntrct.Funding_Date__c = prov.Funding_Date__c;}
						if(String.isBlank(cntrct.Future_Products_Obsolescence_Clause__c)){cntrct.Future_Products_Obsolescence_Clause__c = prov.Future_Products_Obsolescence_Clause__c;}
						if(String.isBlank(cntrct.Governing_Law_Venue__c)){cntrct.Governing_Law_Venue__c = prov.Governing_Law_Venue__c;}
						if(String.isBlank(cntrct.Governing_Law_Venue_Notes__c)){cntrct.Governing_Law_Venue_Notes__c = prov.Governing_Law_Venue_Notes__c;}
						if(String.isBlank(cntrct.Government_Agency__c)){cntrct.Government_Agency__c = prov.Government_Agency__c;}
						if(String.isBlank(cntrct.Government_Property_Clause__c)){cntrct.Government_Property_Clause__c = prov.Government_Property_Clause__c;}
						if(String.isBlank(cntrct.Gov_t_Automated_Invoicing_Required__c)){cntrct.Gov_t_Automated_Invoicing_Required__c = prov.Gov_t_Automated_Invoicing_Required__c;}
						if(String.isBlank(cntrct.GSA__c)){cntrct.GSA__c = prov.GSA__c;}
						if(String.isBlank(cntrct.Hardware_MFN__c)){cntrct.Hardware_MFN__c = prov.Hardware_MFN__c;}
						if(String.isBlank(cntrct.Hardware_Platform__c)){cntrct.Hardware_Platform__c = prov.Hardware_Platform__c;}
						if(cntrct.HOS_Fee_Schedule_3__c==null){cntrct.HOS_Fee_Schedule_3__c = prov.HOS_Fee_Schedule_3__c;}
						if(cntrct.HOS_Units__c==null){cntrct.HOS_Units__c = prov.HOS_Units__c;}
						if(String.isBlank(cntrct.If_cause_is_Other_explain__c)){cntrct.If_cause_is_Other_explain__c = prov.If_cause_is_Other_explain__c;}
						if(String.isBlank(cntrct.If_cause_is_Restructure_or_Successor__c)){cntrct.If_cause_is_Restructure_or_Successor__c = prov.If_cause_is_Restructure_or_Successor__c;}
						if(String.isBlank(cntrct.If_with_exception_cause__c)){cntrct.If_with_exception_cause__c = prov.If_with_exception_cause__c;}
						if(String.isBlank(cntrct.In_Service__c)){cntrct.In_Service__c = prov.In_Service__c;}
						if(String.isBlank(cntrct.In_Service_NRF__c)){cntrct.In_Service_NRF__c = prov.In_Service_NRF__c;}
						if(String.isBlank(cntrct.Insurance__c)){cntrct.Insurance__c = prov.Insurance__c;}
						if(String.isBlank(cntrct.Insurance_Details__c)){cntrct.Insurance_Details__c = prov.Insurance_Details__c;}
						//if(!cntrct.Invoicing__c){cntrct.Invoicing__c = prov.Invoicing__c;}
						if(String.isBlank(cntrct.Last_Approved_By__c)){cntrct.Last_Approved_By__c = prov.Last_Approved_By__c;}
						if(String.isBlank(cntrct.License_Type__c)){cntrct.License_Type__c = prov.License_Type__c;}
						if(String.isBlank(cntrct.Limitation_of_Funds_Clause__c)){cntrct.Limitation_of_Funds_Clause__c = prov.Limitation_of_Funds_Clause__c;}
						if(String.isBlank(cntrct.Location_Type__c)){cntrct.Location_Type__c = prov.Location_Type__c;}
						if(cntrct.Maintenance_Amount__c==null){cntrct.Maintenance_Amount__c = prov.Maintenance_Amount__c;}
						if(String.isBlank(cntrct.Maintenance_Fee_Type__c)){cntrct.Maintenance_Fee_Type__c = prov.Maintenance_Fee_Type__c;}
						if(String.isBlank(cntrct.Term_of_Maintenance__c)){cntrct.Term_of_Maintenance__c = prov.Term_of_Maintenance__c;}
						if(String.isBlank(cntrct.Map_Coverage_Area__c)){cntrct.Map_Coverage_Area__c = prov.Map_Coverage_Area__c;}
						if(cntrct.Map_Royalties_USD_if_paid_by_Roadnet__c==null){cntrct.Map_Royalties_USD_if_paid_by_Roadnet__c = prov.Map_Royalties_USD_if_paid_by_UPSLT__c;}
						if(String.isBlank(cntrct.Map_Vendor__c)){cntrct.Map_Vendor__c = prov.Map_Vendor__c;}
						if(String.isBlank(cntrct.Maps_Sold_by__c)){cntrct.Maps_Sold_by__c = prov.Maps_sold_by__c;}
						if(cntrct.MobileCast_Fee_Schedule_3__c==null){cntrct.MobileCast_Fee_Schedule_3__c = prov.MobileCast_Fee__c;}
						if(cntrct.MobileCast_Units__c==null){cntrct.MobileCast_Units__c = prov.MobileCast_Units__c;}
						if(String.isBlank(cntrct.Mounts_Discount__c)){cntrct.Mounts_Discount__c = prov.Mounts_Discount__c;}
						if(String.isBlank(cntrct.Non_Standard_CP_Indemnification_Detail__c)){cntrct.Non_Standard_CP_Indemnification_Detail__c = prov.Non_Standard_Cust_Indemnification_Detai__c;}
						if(String.isBlank(cntrct.Non_Standard_Equipment_Terms__c)){cntrct.Non_Standard_Equipment_Terms__c = prov.Non_Standard_Equipment_Terms__c;}
						if(String.isBlank(cntrct.Non_Standard_Invoicing_Pmt_or_Tax_Term__c)){cntrct.Non_Standard_Invoicing_Pmt_or_Tax_Term__c = prov.Non_Standard_Invoicing_Pmt_or_Tax_Term__c;}
						if(String.isBlank(cntrct.Non_Standard_Omni_Indemnification_Detail__c)){cntrct.Non_Standard_Omni_Indemnification_Detail__c = prov.Non_Standard_Omni_Indemnification_Detail__c;}
						if(String.isBlank(cntrct.Non_Standard_Payment_Terms_Details__c)){cntrct.Non_Standard_Payment_Terms_Details__c = prov.Non_Standard_Payment_Terms_Details__c;}
						if(String.isBlank(cntrct.Non_Standard_Service_Terms__c)){cntrct.Non_Standard_Service_Terms__c = prov.Non_Standard_Service_Terms__c;}
						if(String.isBlank(cntrct.Non_Standard_Software_Terms__c)){cntrct.Non_Standard_Software_Terms__c = prov.Non_Standard_Software_Terms__c;}
						if(String.isBlank(cntrct.Non_Standard_Term_Termination_Terms__c)){cntrct.Non_Standard_Term_Termination_Terms__c = prov.Non_Standard_Term_Termination_Terms__c;}
						if(String.isBlank(cntrct.Non_Standard_Termination_Fees_or_Terms__c)){cntrct.Non_Standard_Termination_Fees_or_Terms__c = prov.Non_Standard_Termination_Fees_or_Terms__c;}
						if(String.isBlank(cntrct.Non_Standard_Cust_Limitation_of_Liabili__c)){cntrct.Non_Standard_Cust_Limitation_of_Liabili__c = prov.Non_Standard_Cust_Limitation_of_Liabili__c;}
						if(String.isBlank(cntrct.Non_Standard_Omni_Limitation_of_Liabilit__c)){cntrct.Non_Standard_Omni_Limitation_of_Liabilit__c = prov.Non_Standard_Omni_Limitation_of_Liabilit__c;}
						if(cntrct.Number_of_Installations__c==null){cntrct.Number_of_Installations__c = prov.Number_of_Installations__c;}
						if(cntrct.Number_of_Licensed_Sites__c==null){cntrct.Number_of_Licensed_Sites__c = prov.Number_of_Licensed_Sites__c;}
						if(cntrct.Number_of_Mobile_Assets__c==null){cntrct.Number_of_Mobile_Assets__c = prov.Number_of_Mobile_Assets__c;}
						if(cntrct.Number_Of_RNT_Users__c==null){cntrct.Number_Of_RNT_Users__c = prov.Number_Of_RNT_Users__c;}
						if(cntrct.Number_of_RTI_Training_Days_Quoted__c==null){cntrct.Number_of_RTI_Training_Days_Quoted__c = prov.of_UPSLT_Training_Days_Quoted__c;}
						if(cntrct.Number_of_Sales_Reps_T_Planner__c==null){cntrct.Number_of_Sales_Reps_T_Planner__c = prov.Number_of_Sales_Reps_T_Planner__c;}
						if(cntrct.Number_of_Support_Recipients__c==null){cntrct.Number_of_Support_Recipients__c = prov.Number_of_Support_Recipients__c;}
						if(cntrct.Number_of_Vehicles__c==null){cntrct.Number_of_Vehicles__c = prov.Number_of_Vehicles__c;}
						if(String.isBlank(cntrct.OMNI_assign_w_o_consent_restructure__c)){cntrct.OMNI_assign_w_o_consent_restructure__c = prov.OMNI_ok_to_assign_w_o_consent_restructu__c;}
						if(String.isBlank(cntrct.Omni_Assignability_Rights__c)){cntrct.Omni_Assignability_Rights__c = prov.Omni_Assignability_Rights__c;}
						if(String.isBlank(cntrct.Omni_Indemnification__c)){cntrct.Omni_Indemnification__c = prov.Omni_Indemnification__c;}
						if(String.isBlank(cntrct.Omni_Limitation_of_Liability__c)){cntrct.Omni_Limitation_of_Liability__c = prov.Omni_Limitation_of_Liability__c;}
						if(String.isBlank(cntrct.CTel_Contract_Number__c)){cntrct.CTel_Contract_Number__c = prov.CTel_Contract_Number__c;}
						if(String.isBlank(cntrct.Order_Status__c)){cntrct.Order_Status__c = prov.Order_Status__c;}
						if(String.isBlank(cntrct.Other_Hardware_Discounts__c)){cntrct.Other_Hardware_Discounts__c = prov.Other_Hardware_Discounts__c;}
						if(String.isBlank(cntrct.Other_Negotiated_Terms__c)){cntrct.Other_Negotiated_Terms__c = prov.Other_Negotiated_Terms__c;}
						if(String.isBlank(cntrct.Other_Non_Standard_Discounts__c)){cntrct.Other_Non_Standard_Discounts__c = prov.Other_Non_Standard_Terms__c;}
						if(String.isBlank(cntrct.Other_Shipment_Terms_Details__c)){cntrct.Other_Shipment_Terms_Details__c = prov.Other_Shipment_Terms_Details__c;}
						if(String.isBlank(cntrct.OTN__c)){cntrct.OTN__c = prov.OTN__c;}
						if(String.isBlank(cntrct.P_O_or_Check__c)){cntrct.P_O_or_Check__c = prov.P_O_or_Check__c;}
						if(cntrct.Payment_1_Days__c==null){cntrct.Payment_1_Days__c = prov.Payment_1_Days__c;}
						if(String.isBlank(cntrct.Date_of_VAR_Payment_to_UPSLT__c)){cntrct.Date_of_VAR_Payment_to_UPSLT__c = prov.Date_of_VAR_Payment_to_UPSLT__c;}
						if(cntrct.Payment_1_to_UPSLT_USD__c==null){cntrct.Payment_1_to_UPSLT_USD__c = prov.Payment_1_to_UPSLT_USD__c;}
						if(cntrct.Payment_2_Days__c==null){cntrct.Payment_2_Days__c = prov.Payment_2_Days__c;}
						if(String.isBlank(cntrct.Date_of_Payment_2_to_UPSLT__c)){cntrct.Date_of_Payment_2_to_UPSLT__c = prov.Date_of_Payment_2_to_UPSLT__c;}
						if(cntrct.Payment_2_to_RTI_USD__c==null){cntrct.Payment_2_to_RTI_USD__c = prov.Payment_2_to_UPSLT_USD__c;}
						if(cntrct.Payment_3_Days__c==null){cntrct.Payment_3_Days__c = prov.Payment_3_Days__c;}
						if(String.isBlank(cntrct.Date_of_Payment_3_to_UPSLT__c)){cntrct.Date_of_Payment_3_to_UPSLT__c = prov.Date_of_Payment_3_to_UPSLT__c;}
						if(cntrct.Payment_3_to_UPSLT_USD__c==null){cntrct.Payment_3_to_UPSLT_USD__c = prov.Payment_3_to_UPSLT_USD__c;}
						if(cntrct.Payment_4_Days__c==null){cntrct.Payment_4_Days__c = prov.Payment_4_Days__c;}
						if(String.isBlank(cntrct.Date_of_Payment_4_to_UPSLT__c)){cntrct.Date_of_Payment_4_to_UPSLT__c = prov.Date_of_Payment_4_to_UPSLT__c;}
						if(cntrct.Payment_4_to_UPSLT_if_applicable_USD__c==null){cntrct.Payment_4_to_UPSLT_if_applicable_USD__c = prov.Payment_4_to_UPSLT_if_applicable_USD__c;}
						if(cntrct.Payment_5_Days__c==null){cntrct.Payment_5_Days__c = prov.Payment_5_Days__c;}
						if(cntrct.Payment_5_to_UPSLT_USD__c==null){cntrct.Payment_5_to_UPSLT_USD__c = prov.Payment_5_to_UPSLT_USD__c;}
						if(cntrct.Payment_6_Days_after_Delivery__c==null){cntrct.Payment_6_Days_after_Delivery__c = prov.Payment_6_Days__c;}
						if(cntrct.Payment_6_to_RTI_USD__c==null){cntrct.Payment_6_to_RTI_USD__c = prov.Payment_6_to_UPSLT_USD__c;}
						if(!cntrct.Payment_Due_with_Contract__c){cntrct.Payment_Due_with_Contract__c = prov.Payment_Due_with_Contract__c;}
						if(!cntrct.Payment_Due_With_Contract_RNT__c){cntrct.Payment_Due_With_Contract_RNT__c = prov.Payment_Due_With_Contract_RNT__c;}
						if(String.isBlank(cntrct.Payment_Method__c)){cntrct.Payment_Method__c = prov.Payment_Method__c;}
						if(String.isBlank(cntrct.Payment_Terms__c)){cntrct.Payment_Terms__c = prov.Payment_Terms_QES__c;}
						if(String.isBlank(cntrct.Payment_Type_to_RTI__c)){cntrct.Payment_Type_to_RTI__c = prov.Payment_Type_to_UPSLT__c;}
						if(String.isBlank(cntrct.Payment_Withholds__c)){cntrct.Payment_Withholds__c = prov.Payment_Withholds__c;}
						if(!cntrct.Pending_SLA__c){cntrct.Pending_SLA__c = prov.Pending_SLA__c;}
						if(cntrct.Per_Day_Consulting_Fee_Quoted_UPSLT__c==null){cntrct.Per_Day_Consulting_Fee_Quoted_UPSLT__c = prov.Per_Day_Consulting_Fee_Quoted_UPSLT__c;}
						if(cntrct.Per_Day_Consulting_Fee_Quoted_VAR__c==null){cntrct.Per_Day_Consulting_Fee_Quoted_VAR__c = prov.Per_Day_Consulting_Fee_Quoted_VAR__c;}
						if(cntrct.PO_Amount__c==null){cntrct.PO_Amount__c = prov.PO_Amount__c;}
						if(cntrct.PO_Amount_RNT__c==null){cntrct.PO_Amount_RNT__c = prov.PO_Amount_RNT__c;}
						if(String.isBlank(cntrct.Price_Guarantee_Details__c)){cntrct.Price_Guarantee_Details__c = prov.Price_Guarantee_Details__c;}
						if(String.isBlank(cntrct.Price_Increase_Cap__c)){cntrct.Price_Increase_Cap__c = prov.Price_Increase_Cap__c;}
						if(cntrct.Price_Increase_Notice_Period_in_Days__c==null){cntrct.Price_Increase_Notice_Period_in_Days__c = prov.Price_Increase_Notice_Period_in_Days__c;}
						if(String.isBlank(cntrct.Price_Increases_Y_N__c)){cntrct.Price_Increases_Y_N__c = prov.Price_Increases_Y_N__c;}
						if(String.isBlank(cntrct.Prime_or_Sub_Contractor__c)){cntrct.Prime_or_Sub_Contractor__c = prov.Prime_or_Sub_Contractor__c;}
						if(String.isBlank(cntrct.Project__c)){cntrct.Project__c = prov.Project__c;}
						if(String.isBlank(cntrct.Provision_ID_TCM__c)){cntrct.Provision_ID_TCM__c = prov.Provision_ID_TCM__c;}
						if(String.isBlank(cntrct.Related_Party__c)){cntrct.Related_Party__c = prov.Related_Party__c;}
						if(String.isBlank(cntrct.Related_Party_Details__c)){cntrct.Related_Party_Details__c = prov.Related_Party_Details__c;}
						if(String.isBlank(cntrct.Remarketing_Rights__c)){cntrct.Remarketing_Rights__c = prov.Remarketing_Rights__c;}
						if(cntrct.Renewal_Rate__c==null){cntrct.Renewal_Rate__c = prov.Renewal_Rate__c;}
						if(String.isBlank(cntrct.Replacement_Or_Addon__c)){cntrct.Replacement_Or_Addon__c = prov.Replacement_Or_Addon__c;}
						if(String.isBlank(cntrct.Reseller__c)){cntrct.Reseller__c = prov.Reseller__c;}
						if(String.isBlank(cntrct.Retention_Toolkit_Terms__c)){cntrct.Retention_Toolkit_Terms__c = prov.Retention_Toolkit_Terms__c;}
						if(cntrct.RNT_Fee_Schedule_3__c==null){cntrct.RNT_Fee_Schedule_3__c = prov.RNT_Fee_Schedule_3__c;}
						if(cntrct.RNT_Hardware_Total__c==null){cntrct.RNT_Hardware_Total__c = prov.RNT_Hardware_Total__c;}
						if(cntrct.RNT_Installation_Total__c==null){cntrct.RNT_Installation_Total__c = prov.RNT_Installation_Total__c;}
						if(cntrct.RNT_Units__c==null){cntrct.RNT_Units__c = prov.RNT_Units__c;}
						if(cntrct.UPSLT_Portion_of_Annual_Fees__c==null){cntrct.UPSLT_Portion_of_Annual_Fees__c = prov.UPSLT_Portion_of_Annual_Fees__c;}
						if(cntrct.UPSLT_Portion_of_SW_Fees__c==null){cntrct.UPSLT_Portion_of_SW_Fees__c = prov.UPSLT_Portion_of_SW_Fees__c;}
						if(String.isBlank(cntrct.UPSLT_Products__c)){cntrct.UPSLT_Products__c = prov.UPSLT_Products__c;}
						if(String.isBlank(cntrct.SBA_Plan_Prepared__c)){cntrct.SBA_Plan_Prepared__c = prov.SBA_Plan_Prepared__c;}
						if(String.isBlank(cntrct.Service_Data_Plan_Discounts_Notes__c)){cntrct.Service_Data_Plan_Discounts_Notes__c = prov.Service_and_or_Data_Plan_Discounts_Not__c;}
						if(String.isBlank(cntrct.Service_MFN__c)){cntrct.Service_MFN__c = prov.Service_MFN__c;}
						if(String.isBlank(cntrct.Service_Plan__c)){cntrct.Service_Plan__c = prov.Service_Plan__c;}
						if(String.isBlank(cntrct.Ship_To__c)){cntrct.Ship_To__c = prov.Ship_To__c;}
						if(String.isBlank(cntrct.Shipment_Terms__c)){cntrct.Shipment_Terms__c = prov.Shipment_Terms__c;}
						if(String.isBlank(cntrct.SLA__c)){cntrct.SLA__c = prov.SLA__c;}
						if(String.isBlank(cntrct.SLApercentage__c)){cntrct.SLApercentage__c = prov.SLApercentage__c;}
						if(String.isBlank(cntrct.SLA_Credit__c)){cntrct.SLA_Credit__c = prov.SLA_Credit__c;}
						if(String.isBlank(cntrct.SLA_Details__c)){cntrct.SLA_Details__c = prov.SLA_Details__c;}
						if(String.isBlank(cntrct.Software__c)){cntrct.Software__c = prov.Software__c;}
						if(cntrct.Software_Amount__c==null){cntrct.Software_Amount__c = prov.Software_Amount__c;}
						if(String.isBlank(cntrct.Software_Credits__c)){cntrct.Software_Credits__c = prov.Software_Discounts__c;}
						if(String.isBlank(cntrct.Software_MFN__c)){cntrct.Software_MFN__c = prov.Software_MFN__c;}
						if(String.isBlank(cntrct.Sole_Source_or_Competitive__c)){cntrct.Sole_Source_or_Competitive__c = prov.Sole_Source_or_Competitive__c;}
						if(!cntrct.Stated_Renewal__c){cntrct.Stated_Renewal__c = prov.Stated_Renewel__c;}
						if(cntrct.Subscription_Fee_per_Truck__c==null){cntrct.Subscription_Fee_per_Truck__c = prov.Subscription_Fee_per_Truck__c;}
						if(!cntrct.Subscription_Stated_Renew__c){cntrct.Subscription_Stated_Renew__c = prov.Subscription_Stated_Renew__c;}
						if(String.isBlank(cntrct.Telecom_Link__c)){cntrct.Telecom_Link__c = prov.Telecom_Link__c;}
						if(String.isBlank(cntrct.Telematics_Install_Type__c)){cntrct.Telematics_Install_Type__c = prov.Telematics_Install_Type__c;}
						if(String.isBlank(cntrct.Telematics_Provider__c)){cntrct.Telematics_Provider__c = prov.Telematics_Provider__c;}
						if(String.isBlank(cntrct.Terminal_Commitment_Delivery_Timeframe__c)){cntrct.Terminal_Commitment_Delivery_Timeframe__c = prov.Terminal_Commitment_Delivery_Timeframe__c;}
						if(String.isBlank(cntrct.Terminal_Commitment_Quantity__c)){cntrct.Terminal_Commitment_Quantity__c = prov.Terminal_Commitment_Quantity__c;}
						if(String.isBlank(cntrct.Terminal_Credit_Details__c)){cntrct.Terminal_Credit_Details__c = prov.Terminal_Credit_Details__c;}
						if(String.isBlank(cntrct.Terminal_Credits__c)){cntrct.Terminal_Credits__c = prov.Terminal_Credits__c;}
						if(String.isBlank(cntrct.Terminal_List_Price_Discount_Details__c)){cntrct.Terminal_List_Price_Discount_Details__c = prov.Terminal_List_Price_Discount_Details__c;}
						if(String.isBlank(cntrct.Terrestrial_Data_Plan__c)){cntrct.Terrestrial_Data_Plan__c = prov.Terrestrial_Data_Plan__c;}
						if(cntrct.Total_Funding__c==null){cntrct.Total_Funding__c = prov.Total_Funding__c;}
						if(String.isBlank(cntrct.Trade_In_Program__c)){cntrct.Trade_In_Program__c = prov.Trade_In_Program__c;}
						if(String.isBlank(cntrct.Trade_In_Program_Details__c)){cntrct.Trade_In_Program_Details__c = prov.Trade_In_Program_Details__c;}
						if(String.isBlank(cntrct.Type_of_Price_Guarantee__c)){cntrct.Type_of_Price_Guarantee__c = prov.Type_of_Price_Guarantee__c;}
						if(String.isBlank(cntrct.User_Type__c)){cntrct.User_Type__c = prov.User_Type__c;}
						if(cntrct.VAR_Portion_of_Annual_Fees__c==null){cntrct.VAR_Portion_of_Annual_Fees__c = prov.VAR_Portion_of_Annual_Fees__c;}
						if(cntrct.VAR_Portion_of_SW_Fees__c==null){cntrct.VAR_Portion_of_SW_Fees__c = prov.VAR_Portion_of_SW_Fees__c;}
						if(String.isBlank(cntrct.Version__c)){cntrct.Version__c = prov.Version__c;}
						if(String.isBlank(cntrct.What_is_Being_Purchased__c)){cntrct.What_is_Being_Purchased__c = prov.What_is_Being_Purchased__c;}
						if(String.isBlank(cntrct.Written_Consent__c)){cntrct.Written_Consent__c = prov.Written_Consent__c;}
						
					}
			 	}
			 	updateContractMap.put(cntrct.Id, cntrct);
			 }
		}
		if(updateContractMap.size() > 0){
			Database.update(updateContractMap.values());
		}		    

	}
	
	 global void finish(Database.BatchableContext BC){
    }
    
}