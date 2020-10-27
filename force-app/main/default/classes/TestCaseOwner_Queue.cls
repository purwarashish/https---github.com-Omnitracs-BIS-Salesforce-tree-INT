@isTest(SeeAllData=True)
private class TestCaseOwner_Queue{

public static testmethod void TestCaseOwnermethod(){
    account acct1 = new account(QWBS_Market__c = 'T&L Eastern Region', Name = 'My Test',            BillingStreet = '123 Main', BillingCity = 'San Diego', BillingState = 'CA', BillingCountry = 'USA',QWBS_Cust_ID__c='12101986',RFC_ID__c='29051986');        
    insert acct1;

    Case CaseNew = new Case();
    CaseNew.Status = 'Open';
    CaseNew.Substatus__c ='In Progress';
    CaseNew.AccountId = acct1.Id;
    insert CaseNew;
    
    ApexPages.currentPage().getParameters().put('Id',CaseNew.Id);
    ApexPages.StandardController sdtCon;
    CaseOwnerAssignmentController newObj = new CaseOwnerAssignmentController(sdtCon);
    
    newObj.alphabet = 'A';
    newObj.Alphabet_Ordering();
    
    newObj.alphabet = 'All';
    newObj.Alphabet_Ordering();
    
    newObj.asce = true;
    newObj.ChangeOrder();
    
    newObj.asce = false;
    newObj.ChangeOrder();
    
    test.startTest();
    newObj.ShowAllUsers();
    test.stopTest();
    newObj.SelectedOwnerId = newObj.userList[0].Id;
    newObj.ShowUsersInCurrentQueue();
    newObj.sendEmail = true;
    newObj.AssignUser();
    newObj.CaseId = null;
    newObj.AssignUser();
    newObj.ShowUsersInCurrentQueue();
}


public static testmethod void TestCaseQueuemethod(){

    account acct1 = new account(QWBS_Market__c = 'T&L Eastern Region', Name = 'My Test',            BillingStreet = '123 Main', BillingCity = 'San Diego', BillingState = 'CA', BillingCountry = 'USA',QWBS_Cust_ID__c='12101986',RFC_ID__c='29051986');        
    insert acct1;
    
    Case CaseNew = new Case();
    CaseNew.Status = 'Open';
    CaseNew.Substatus__c ='In Progress';
    CaseNew.AccountId = acct1.Id;
    insert CaseNew;
    
    ApexPages.currentPage().getParameters().put('Id',CaseNew.Id);
    ApexPages.StandardController sdtCon;
    CaseQueueAssignmentController newObj = new CaseQueueAssignmentController(sdtCon);
    
    system.debug('QueueList:'+newObj.QueueList);
    
    newObj.asce = true;
    newObj.ChangeOrder();
    
    newObj.asce = false;
    newObj.ChangeOrder();
    
    //newObj.SelectedOwnerId = newObj.QueueList[0].Id;
    newObj.SelectedOwnerId = '0';
    newObj.AssignUser();
    newObj.sendEmail = true;
    newObj.AssignUser();
  
}

}