@isTest(seeAllData = true)
public class SP_Common_Test{
    public static testMethod void testCommonMethod(){
        SP_TestingUtil testingUtil = new SP_TestingUtil();
		SP_SalesCoachSetup SCS = new SP_SalesCoachSetup();
		System.assert(SCS.getShowSections()!=null);
		SCS.getScStage();
		System.assert(SCS.getScActivities()==null);
		System.assert(SCS.getSwi()==null);
		System.assert(SP_SalesCoachSetup.getOpptyStages()!=null);
		System.assert(SCS.getSections()==null);
		SCS.saveSections();
		SCS.stage='Closed Won';
		SCS.getSections();
		SCS.stage='Prospecting';      
		System.assert(SCS.getSections()==null);
		SCS.saveActivities();
		SCS.saveStage();
		SCS.saveSections();
		SCS.deleteSection();
		SCS.deleteActivity();
		SCS.deleteSectionItem();
    }
	
	public static testMethod void testSCollection(){
        List<Account> accs = TestDataFactory.createAcctList(10, 'Common Account Test');
        List<Contact> cons = new List<Contact>();

        List<Id> accIds = new List<Id>();
        for(Database.SaveResult res:database.insert(accs)){
            if(res.isSuccess()){
                accIds.add(res.getId());
            }
        }
        for(Id accId:accIds){
            List<Contact> conList = TestDataFactory.createConList(1, 'LastName');
			Contact con = conList[0];
            con.LastName = 'Test Contact ' + accId;
			con.AccountId = accId;
            cons.add(con);
        }
        List<Id> conIds = new List<Id>();
        for(Database.SaveResult res:database.insert(cons)){
				if(res.isSuccess()){
					conIds.add(res.getId());
			}
		}
           
		test.StartTest();
		
			SP_sCollection.idMap(cons, Contact.AccountId);
			SP_sCollection.idMap(cons, 'AccountId');
				 
			SP_sCollection.stringMap(cons,Contact.name);
			SP_sCollection.stringMap(cons,'name');
				  
			SP_sCollection.idSet(cons,Contact.AccountId);
			SP_sCollection.idSet(cons,'AccountId');
				  
			SP_sCollection.stringSet(cons,Contact.name);
			SP_sCollection.stringSet(cons,'name');
				   
			Map<Id, List<sObject>> conIdMap = SP_sCollection.idListMap(cons,Contact.AccountId);
			SP_sCollection.idListMap(cons,'AccountId');
				 
			Map<String, List<sObject>> conStringMap = SP_sCollection.stringListMap(cons,Contact.name);
			SP_sCollection.stringListMap(cons,'name');
			
			SP_sCollection.puts(accs, Account.Name,'Override Test Account');
			SP_sCollection.puts(accs, Account.Name,new List<String>{'List Override Test Account 1','List Override Test Account 2'});
			
			SP_sCollection.flatten(conIdMap);
			SP_sCollection.flatten(conStringMap);
			
			System.assertEquals(accs[4].Name,'Override Test Account');
			System.assertEquals(accs[1].Name,'List Override Test Account 2');
			  
		test.StopTest();
    }
}