global class CreateAccount {
	
	webService static ServiceResponse ValidateAccountCreation(String accountName){
		
		ServiceResponse sr = new ServiceResponse();
		if(String.isNotBlank(accountName)){
			List<Account> accntList = [select Id, name from Account where Name = :accountName or Legal_Name__c = :accountName];
			if(accntList.size() > 0){
				sr.status = 'Error';
				sr.Message = 'Account already exists for the requested account name.';
				sr.AccountId = accntList.get(0).Id;
				return sr;
			}
			else{
				List<String> accountNameList = accountName.split(' ');
				if(accountNameList != null && accountNameList.size() > 0){
					String caName = '';
					for(Integer i=0; i<accountNameList.size()-1;i++){
						caName = caName.trim()+accountNameList.get(i).trim();
					}
					String accountQry = 'select Id, name from Account where Name like \''+accountName.trim()+'%\' or Legal_Name__c = \''+accountName.trim()+'%\'';
					accntList = Database.query(accountQry);
					if(accntList.size() > 0){
						for(Account accnt : accntList){
							List<String> tanameList = accnt.name.split(' ');
							if(tanameList != null && tanameList.size() > 0){
								String taName = '';
								for(Integer i=0; i<tanameList.size()-1;i++){
									taName = taName.trim()+tanameList.get(i).trim();
								}
								if(taName == caName){
									sr.status = 'Error';
									sr.Message = 'Account already exists for the requested account name.';
									sr.AccountId = accnt.Id;
									return sr;
								}
							}
						}
					}
					
				}
			}
			
		
		}
		sr.Status = 'Success';
        sr.Message = 'Could not find the account in Salesforce for the requested account name.';
		return sr;
	}
	
	global class ServiceResponse{
    	webservice String Status {get;set;}
        webservice String Message {get;set;}
        webservice String AccountID {get;set;}
    }
}