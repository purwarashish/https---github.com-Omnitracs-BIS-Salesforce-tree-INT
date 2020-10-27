trigger AccountS2S on Account (before insert, before update) {
    Map<String,Id> ownermap = new Map<String,Id>();
    Map<String,Id> parentMap = new Map<String,Id>();
    Map<String,Id> parentNetSuiteMap = new Map<String,Id>();
    Map<String,Id> supportMap = new Map<String,Id>();
    Map<String,Id> supportNetSuiteMap = new Map<String,Id>();
    Map<String,Id> ultimateMap = new Map<String,Id>();
    Map<String,Id> ultimateNetSuiteMap = new Map<String,Id>();
    Map<String,User> atMap = new Map<String,User>();
    set<String> ats = new set<String>();
    set<String> ownerset = new set<String>();
    set<String> parentset = new set<String>();
    set<String> supportset = new set<String>();
    if(trigger.size==1){
        if(trigger.new[0].ConnectionReceivedId != null && trigger.new[0].ConnectionReceivedId == '04P3F000000007cUAA'){
            trigger.new[0].RecordTypeId = '01250000000DQBAAA4'; //check with Anbu
            if(trigger.new[0].Customer_ID_S2S__c != null && trigger.new[0].Customer_ID_S2S__c != ''){
                switch on trigger.new[0].ID_Type_S2S__c {
                    when 'ERP' {trigger.new[0].QWBS_Cust_ID__c = trigger.new[0].Customer_ID_S2S__c;} 
                    when 'NetSuite' {trigger.new[0].NetSuite_Customer_ID__c = trigger.new[0].Customer_ID_S2S__c;}
                    when 'Roadnet' {trigger.new[0].Roadnet_Cust_ID__c = trigger.new[0].Customer_ID_S2S__c;}
                    when else {trigger.new[0].QWBS_Cust_ID__c = '';}
                }
            }
            if(trigger.new[0].Owner_Id_S2S__c!=null && trigger.new[0].Owner_Id_S2S__c!=''){
                ownerset.add(trigger.new[0].Owner_Id_S2S__c);
            }
            if(trigger.new[0].Parent_Id_S2S__c!=null && trigger.new[0].Parent_Id_S2S__c!=''){
                parentset.add(trigger.new[0].Parent_Id_S2S__c);
            }
            if(trigger.new[0].Support_Account_Id_S2S__c!=null && trigger.new[0].Support_Account_Id_S2S__c!=''){
                supportset.add(trigger.new[0].Support_Account_Id_S2S__c);
            }
            ats.add(trigger.new[0].Account_Manager_S2S__c);
            ats.add(trigger.new[0].Collector_Name_S2S__c);
            ats.add(trigger.new[0].Contracts_Administrator_S2S__c);
            ats.add(trigger.new[0].Customer_Success_Lead_S2S__c);
            ats.add(trigger.new[0].Customer_Success_Manager_S2S__c);
            ats.add(trigger.new[0].Inside_CSR_S2S__c);

            if(ownerset.size()>0){
                for(User u:[select id,email from user where email=:ownerset limit 1]){
                    ownermap.put(u.email,u.Id);
                }
            }
            if(ats.size()>0){
                for(User u:[select id,email,firstname,lastname from user where email=:ats]){
                    atMap.put(u.email,u);
                }
            }
            if(parentset.size()>0 && parentset!=null){
                for(Account a:[select id,NetSuite_Customer_ID__c from Account where NetSuite_Customer_ID__c =:parentset limit 1]){
                    parentNetSuiteMap.put(a.NetSuite_Customer_ID__c,a.Id);
                }
            }
            if(parentset.size()>0 && parentset!=null){
                for(Account a:[select id,QWBS_Cust_ID__c from Account where QWBS_Cust_ID__c =:parentset limit 1]){
                    parentMap.put(a.QWBS_Cust_ID__c,a.Id);
                }
            }
            if(supportset.size()>0){
                for(Account a:[select id,NetSuite_Customer_ID__c from Account where NetSuite_Customer_ID__c =:supportset limit 1]){
                    supportNetSuiteMap.put(a.NetSuite_Customer_ID__c,a.Id);
                }
            }
            if(supportset.size()>0){
                for(Account a:[select id,QWBS_Cust_ID__c from Account where QWBS_Cust_ID__c =:supportset limit 1]){
                    supportMap.put(a.QWBS_Cust_ID__c,a.Id);
                }
            }
            for(Account a:trigger.new){
                if(parentMap.containsKey(a.Parent_Id_S2S__c)){
                    a.ParentId = parentMap.get(a.Parent_Id_S2S__c); //Send extra field and map it in S2S and then find Id here
                }
                if(parentNetSuiteMap.containsKey(a.Parent_Id_S2S__c)){
                    a.ParentId = parentNetSuiteMap.get(a.Parent_Id_S2S__c);
                }
                a.UnityOnboardStatus__c = a.New_Org_Onboarding_Status__c;
                a.Primary_Business_Unit__c = 'Omnitracs domestic';
                a.Secondary_Business_Unit_s__c = 'Omnitracs domestic';
                a.Sic = a.SIC_Code_S2S__c;
                a.OwnerId = ownermap.get(a.Owner_Id_S2S__c);
                if(supportMap.containsKey(a.Support_Account_Id_S2S__c)){
                    a.Support_Account__c = supportMap.get(a.Support_Account_Id_S2S__c);
                }
                if(supportNetSuiteMap.containsKey(a.Support_Account_Id_S2S__c)){
                    a.Support_Account__c = supportNetSuiteMap.get(a.Support_Account_Id_S2S__c);
                }
                if(a.OwnerId == null){
                    a.OwnerId = System.Label.OmnitracsHouseAccountUser;
                }
                if(a.AGUID__c != null){
                    a.AGUID__c = a.AGUID__c.toUpperCase().replace('-','');
                }
                if(atMap.containsKey(a.Account_Manager_S2S__c) && a.Account_Manager_S2S__c!=null){
                    a.Account_Manager__c = atMap.get(a.Account_Manager_S2S__c).Id;
                }
                if(atMap.containsKey(a.Collector_Name_S2S__c) && a.Collector_Name_S2S__c!=null){
                    a.Collector_Name__c = atMap.get(a.Collector_Name_S2S__c).firstname+' '+atMap.get(a.Collector_Name_S2S__c).lastname;
                }
                if(atMap.containsKey(a.Contracts_Administrator_S2S__c) && a.Contracts_Administrator_S2S__c!=null){
                    a.Contracts_Administrator__c = atMap.get(a.Contracts_Administrator_S2S__c).Id;
                }
                if(atMap.containsKey(a.Customer_Success_Lead_S2S__c) && a.Customer_Success_Lead_S2S__c!=null){
                    a.Customer_Success_Lead__c = atMap.get(a.Customer_Success_Lead_S2S__c).Id;
                }
                if(atMap.containsKey(a.Customer_Success_Manager_S2S__c) && a.Customer_Success_Manager_S2S__c!=null){
                    a.CSR__c = atMap.get(a.Customer_Success_Manager_S2S__c).Id;
                }
                if(atMap.containsKey(a.Inside_CSR_S2S__c) && a.Inside_CSR_S2S__c!=null){
                    a.Inside_CSR__c = atMap.get(a.Inside_CSR_S2S__c).Id;
                }
                if(a.QWBS_Status__c == 'Active'){
                    if(a.Type == 'Prospect'){
                        a.QWBS_Status__c = 'Active Prospect';
                    }
                    if(a.Type == 'Customer - Direct' || a.Type == 'Customer - Channel Partner' || a.Type == 'Alliance Partner'){
                        a.QWBS_Status__c = 'Contract Customer';
                    }
                }
                if(a.QWBS_Status__c == 'Inactive'){
                    if(a.Type == 'Prospect'){
                        a.QWBS_Status__c = 'Inactive Prospect';
                    }
                    if(a.Type == 'Customer - Direct' || a.Type == 'Customer - Channel Partner' || a.Type == 'Alliance Partner'){
                        a.QWBS_Status__c = 'Closed Contract Customer';
                    }
                }
            }
        }
    }
}