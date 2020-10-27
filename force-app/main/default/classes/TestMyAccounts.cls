@isTest(SeeAllData=True)
private class TestMyAccounts{

public static testmethod void TestMyAccountsmethod(){

    User AcctTeam = [select id,name from user where username LIKE '%c_skarn%' limit 1];
    
    list<Account> lstAccount = new list<Account>();
    test.startTest();
    Account newAccount = new Account();
    newAccount.Name = 'SFDC';
    newAccount.Type = 'Other';
    newAccount.BillingStreet = 'Test Address1';
    newAccount.BillingCity = 'Test City1';
    newAccount.BillingCountry = 'Test Country1';
    newAccount.BillingState = 'Test State1';
    newAccount.BillingPostalCode = '75053';
    newAccount.Fleet_Size__c = 25;
    newAccount.Segment__c = 'TL';
    newAccount.Inside_CSR__c = AcctTeam.Id;
    insert newAccount;
        
    Account newAccount1 = new Account();
    newAccount1.Name = 'SFDC';
    newAccount1.Type = 'Other';
    newAccount1.BillingStreet = 'Test Address';
    newAccount1.BillingCity = 'City';
    newAccount1.BillingCountry = 'Test Country';
    newAccount1.BillingState = 'Test State';
    newAccount1.BillingPostalCode = '75052';
    newAccount1.Fleet_Size__c = 25;
    newAccount1.Segment__c = 'TL';
    newAccount1.Inside_CSR__c = AcctTeam.Id;
    Database.DMLOptions dml = new Database.DMLOptions(); 
	dml.DuplicateRuleHeader.allowSave = true;
	dml.DuplicateRuleHeader.runAsCurrentUser = true;
	Database.SaveResult sr1 = Database.insert(newaccount1, dml);
       
    ApexPages.StandardController sdtCon;
    MyAccountsController newObj = new MyAccountsController(sdtCon);
    
    newObj.userList.add(newAccount);
    newObj.pagination();
    newObj.asce =true;
    newObj.ChangeOrder();
    newObj.tempList.add(newObj.userList);
    if(!(newObj.tempList.isEmpty()))
    {
    newObj.currentPage = 0;
    newObj.next();
    newObj.currentPage = 2; 
    newObj.previous(); 
    }
    // Modified By Shruti Karn for CR# 22542
    String [] curr = new String[]{'BillingCity',/*'District__c',*/'QWBS_Cust_ID__c','Phone','BillingState','QWBS_Market__c','QWBS_Status__c','name'};
    for(integer i=0;i<curr.size();i++)
    {
        newObj.setCurrent_value(curr[i]);
        newObj.ChangeOrder();
    }
    newObj.asce =false;
    for(integer i=0;i<curr.size();i++)
    {
        newObj.setCurrent_value(curr[i]);
        newObj.ChangeOrder();
    }
    curr[0] = newObj.getCurrent_Value();
    test.stopTest();
}
}