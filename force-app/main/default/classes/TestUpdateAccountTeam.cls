@isTest(SeeAllData = true)
public class TestUpdateAccountTeam {
static testmethod void myUpdateAccountTeam () {
//Insert a new Account with a Customer Service Rep and Territory
User sampleUser = [SELECT Id, Name FROM User WHERE (IsActive != null AND Profile.Name = 'System Administrator') LIMIT 1];
String UserName = userInfo.getUserName();
list<Account> lstAccount = new list<Account>();
list<id> lstAccountId = new list<id>();
Account newAccount = new Account( Name = 'test acct', 
QWBS_Market__c = 'T&L Eastern Region',
BillingStreet = '123 Main', 
BillingCity = 'San Diego', 
BillingState = 'CA', 
BillingCountry = 'USA',
BillingPostalCode = '75252',
CSR__c = sampleUser.Id,
Account_Manager__c = sampleUser.Id,
Inside_Sales_Rep__c = sampleUser.Id,
AR_Representative__c = sampleUser.Id,
Partner_Agent__c = sampleUser.Id,
Inside_CSR__c = sampleUser.Id,
FRA_Account_Manager__c = sampleUser.Id,
FRA_Customer_Service_Rep__c = sampleUser.Id,
FRA_Software_Application_Eng__c = sampleUser.Id,
Segment__c = 'TL',
Fleet_Size__c = 25,                                 
/*Professional_Services_Rep__c = sampleUser.Id,
Software_Application_Eng__c = sampleUser.Id,*/
Contracts_Administrator__c = sampleUser.Id);
insert newAccount;
lstAccountId.add(newAccount.id);

AccountTeamMember[] atmList = [SELECT a.AccountId, a.Id, a.UserId 
FROM AccountTeamMember a
WHERE a.AccountId = :newAccount.Id
AND a.UserId = :sampleUser.Id];
//Confirm that the CSR user was added to the Account Team
//System.assertEquals(1, atmList.size());
//Confirm that the AccountShare has been updated for this Account Team member
AccountShare[] aShareList = [SELECT a.AccountId, a.Id, a.UserOrGroupId, a.AccountAccessLevel
FROM AccountShare a
WHERE a.AccountId = :newAccount.Id
AND a.UserOrGroupId = :sampleUser.Id]; 
//Confirm that the CSR user was added to the Account Team
//System.assertEquals(1, aShareList.size());
//System.assertEquals('Edit', aShareList[0].AccountAccessLevel);
UpdateAccountTeam.setAlreadyExecuted();  
UpdateAccountTeam.hasAlreadyExecuted();
UpdateAccountTeam.UpdateAccountTeam(UserName,lstAccountId);
}

}