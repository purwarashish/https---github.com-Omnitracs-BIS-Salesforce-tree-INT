/*This test class unit test the following Trigger and class. To unit test Time and state
*/
@isTest(SeeAllData=true)
private class TestViewTISController{
    public static user createUser(){
        Profile p = [select id from profile where name='Standard User'];
        User newuser = new User(alias = 'standt', email='standarduser1@omnitracs.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles', username='standarduser1237@testorg.com');
        insert newUser;
        return newUser;
                          
    }
    public static Group createGroup(){
        Group grp = new Group();
        grp = new Group(name = 'testQueue1', type = 'Queue');
        insert grp;
        
        return grp;
    }
    public static testmethod void insertAndUpdateOpp(){
        user RecOwner =  createUser();
        Opportunity testOpp=new Opportunity(Name='test',StageName='Shipped',CloseDate=Date.today()+1);
        test.startTest();
            insert testOpp;
            testopp.OwnerId=RecOwner.Id;
            update testOpp;
            testViewTICContrl(testOpp,null);
        test.stopTest();             
    }
    public static testmethod void insertAndUpdateLead(){
        user RecOwner =  createUser();
        Lead testlead=new Lead(FirstName='test',Lastname='testlast',Company='tcs',City='San Diego',State='CA',Country='US');
        test.startTest();
            insert testlead;
            testlead.OwnerId=RecOwner.Id;
            update testlead;
            Group grp = createGroup();
            QueueSobject mappingObject = new QueueSobject(QueueId = grp.Id, SobjectType = 'Lead');
            System.runAs(new User(Id = UserInfo.getUserId()))
            {
                insert mappingObject;
            }
            testlead.OwnerId=grp.Id;
            update testlead;
            testViewTICContrl(null,testlead); 
        test.stopTest();             
    }
    public static void testViewTICContrl(Opportunity opp,Lead ld){
        
        if(opp != null){
            ApexPages.currentPage().getParameters().put('Id',opp.id);
            ApexPages.StandardController cnt = new ApexPages.StandardController(opp);
            ViewTISController  tis =  new ViewTISController(cnt);
            tis.showTISDetail();
        }
        else{
            ApexPages.currentPage().getParameters().put('Id',ld.id);
            ApexPages.StandardController cnt = new ApexPages.StandardController(ld);
            ViewTISController tis =  new ViewTISController(cnt);
            tis.showTISDetail();
        }
                       
    }   
    
}