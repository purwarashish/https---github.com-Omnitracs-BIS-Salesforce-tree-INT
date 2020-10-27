public class CalculateRevenueSum {
	
 //Limit the size of list by using Sets which do not contain duplicate elements
  
	
	  public static void trigNew(List <Asset__c >triggerNew) {
		set<Id> subscriptionAccountIds = new set<Id>();
  		set<Id> arrAccountIds = new set<Id>();
		List <Account >AccountsToUpdate = new List <Account >();
		for (Asset__c ast :triggerNew) {
            if (ast.Maintenance_Status__c == 'On Maintenance') {
                if (ast .License_Type__c == 'Subscription') {
                    subscriptionAccountIds.add(ast.Account__c);
                }
                else {
                    arrAccountIds.add(ast.Account__c);
                }
            }
		}
	
	
	map <Id, Double>AccountMap = new map <Id, Double>();
	if (!subscriptionAccountIds.isEmpty()) {
		for (AggregateResult q :[select Account__c,sum(ARR__c)
	            from Asset__c where Account__c IN :subscriptionAccountIds group by Account__c]) {
			AccountMap .put((Id)q .get('Account__c'), (Double)q .get('expr0'));
		}
		for (Account a :[Select Id, Summation_Of_Subscription_Revenue__c from Account where Id IN :subscriptionAccountIds])
		{
			Double RevenueSum = AccountMap.get(a.Id);
			a .Summation_Of_Subscription_Revenue__c = RevenueSum;
			AccountsToUpdate .add(a);
		}
	}
	
	else {
		if (!arrAccountIds .isEmpty())
		{
			for (AggregateResult q :[select Account__c,sum(ARR__c)
	                from Asset__c where Account__c IN :aRRAccountIds group by Account__c])
			{
				AccountMap .put((Id)q .get('Account__c'), (Double)q .get('expr0'));
			}
			for (Account a :[Select Id, Summation_of_SA_Revenue__c from Account where Id IN :aRRAccountIds])
			{
				Double RevenueSum = AccountMap.get(a.Id);
				a .Summation_of_SA_Revenue__c = RevenueSum;
				AccountsToUpdate .add(a);
			}
		}
	}
	
	if (!AccountsToUpdate .isEmpty())
	{
		update AccountsToUpdate;
	}
	}
	
	public static void trigOld(List <Asset__c >triggerOld){
		set<Id> subscriptionAccountIds = new set<Id>();
  		set<Id> arrAccountIds = new set<Id>();
		List <Account >AccountsToUpdate = new List <Account >();
		for (Asset__c ast :triggerold) {
            if (ast.Maintenance_Status__c == 'On Maintenance') {
                
                if (ast .License_Type__c == 'Subscription') {
                    subscriptionAccountIds .add(ast .Account__c);
                } else {
                    arrAccountIds .add(ast .Account__c);
                }
            }
		}
	
	
	map <Id, Double>AccountMap = new map <Id, Double>();
	if (!subscriptionAccountIds .isEmpty()){
		for (AggregateResult q :[select Account__c,sum(ARR__c) from Asset__c where Account__c IN :subscriptionAccountIds group by Account__c]){
			AccountMap .put((Id)q .get('Account__c'), (Double)q .get('expr0'));
		 }
		for (Account a :[Select Id, Summation_Of_Subscription_Revenue__c from Account where Id IN :subscriptionAccountIds]){
			Double RevenueSum = AccountMap .get(a .Id);
			a .Summation_Of_Subscription_Revenue__c = RevenueSum;
			AccountsToUpdate .add(a);
		}
	}
	
	else {
		if (!arrAccountIds .isEmpty()){
			for (AggregateResult q :[select Account__c,sum(ARR__c) from Asset__c where Account__c IN :aRRAccountIds group by Account__c]){
				AccountMap .put((Id)q .get('Account__c'), (Double)q .get('expr0'));
			}
			for (Account a :[Select Id, Summation_of_SA_Revenue__c from Account where Id IN :aRRAccountIds]){
				Double RevenueSum = AccountMap .get(a .Id);
				a .Summation_of_SA_Revenue__c = RevenueSum;
				AccountsToUpdate .add(a);
			}
		}
	}
	
	if (!AccountsToUpdate .isEmpty()){
		update AccountsToUpdate;
	}
  }
}