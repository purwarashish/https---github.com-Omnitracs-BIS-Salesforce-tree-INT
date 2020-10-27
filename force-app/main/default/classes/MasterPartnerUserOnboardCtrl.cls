public with sharing class MasterPartnerUserOnboardCtrl {
    
	public Account acc {get; set;}
	public String licenseType {get; set;}
	public List<String> accountNameLength = new List<String>();
	public String nameToSplit;
	public ID retAcctID {get; set;}
	public ID retLeadQueueID {get; set;}
	public String retName {get; set;}
	
	public MasterPartnerUserOnboardCtrl(){
		
	}
	
	public MasterPartnerUserOnboardCtrl(ApexPages.StandardController ctrl){
		this.acc = (Account)ctrl.getRecord();
		//if a.recordtype = reseller, a.market = indirect
		//retAcctID = ApexPages.currentPage().getParameters().get('standalone');
		//retLeadQueueID = ApexPages.currentPage().getParameters().get('standalone');
		//standalone = ApexPages.currentPage().getParameters().get('standalone');
		
	}
	
	public PageReference save(){
		Account a = [Select Name, ID from Account where id =: acc.Id];
		
		
		User u = new User();
		Group leadQueue = new Group(type = 'queue');
		Group newGroup = new Group();
		
		String groupName = a.Name + ' Group';
		String queueName = a.Name + ' Queue';
		String userName = a.Name;
		String regexName = a.Name;
		
		newGroup.name = groupName;
		insert newGroup;
		
		regexName = regexName.replaceAll('&', '');
		regexName = regexName.replaceAll('\\.', '');
		regexName = regexName.replaceAll('\'', '');
		regexName = regexName.replaceAll(',', '');
		accountNameLength = regexName.split(' ');
		
		if(accountNameLength.size() == 1){
			u.FirstName = 'Var';
			u.LastName = accountNameLength[0];
			
		}
		
		else if (accountNameLength.size() == 2){
			u.FirstName = accountNameLength[0];
			u.LastName = accountNameLength[1];
		}
		
		else if(accountNameLength.size() == 3){
			u.FirstName = accountNameLength[0];
			u.LastName = accountNameLength[1] + accountNameLength[2];
		}
		
		else if(accountNameLength.size()==4){
			u.FirstName = accountNameLength[0];
			u.LastName = accountNameLength[1] + accountNameLength[2] + accountNameLength[3];
		}
		else{
			
		}
		//leadQueue.sObjectType = 'Lead';
		leadQueue.name = queueName;
		insert leadQueue;
		
		queuesobject q1 = new queuesobject (queueid=leadQueue.id, sobjecttype='Lead');

		insert q1;
		
		//u.LastName = userName.replaceAll('\\s+', '');
		if(Test.isRunningTest()){
			u.Alias = regexName.subString(0, 3);
		}
		else u.Alias = regexName.subString(0, 5);
		u.Email = 'prmsupport@omnitracs.com';
		u.userName = u.FirstName + u.LastName + 'masterowner@omnitracs.com';
		u.CommunityNickname = u.LastName;
		//u.UserType = 'Standard';
		u.ProfileID = '00e500000018pOe';
		u.UserRoleID = '00E50000001DsJu';
		u.LanguageLocaleKey = 'en_US';
		u.LocaleSidKey = 'en_US';
		u.EmailEncodingKey = 'UTF-8';
		u.TimeZoneSidKey = 'GMT';
		insert u;
		
		PageReference pg = new PageReference('/apex/MasterPartnerUserOnboardPage2?retName='+ a.Name + '&retAcctID=' + a.ID+ '&retLeadQueueID=' + leadQueue.ID); 
		return pg;
		
	}
	
	public void insertPRMAcctQueueCombination(){
		/*retAcctId = a.ID;
		retLeadQueueID = leadQueue.ID;	
		retName = a.Name;*/
		PRMAcctQueueCombination__c newCSElement = new PRMAcctQueueCombination__c();
		
		newCSElement.Name = ApexPages.currentPage().getParameters().get('retName');
		newCSElement.AccountID__c = ApexPages.currentPage().getParameters().get('retAcctID');
		newCSElement.QueueIDs__c = ApexPages.currentPage().getParameters().get('retLeadQueueID');
		
		insert newCSElement;
	}
}