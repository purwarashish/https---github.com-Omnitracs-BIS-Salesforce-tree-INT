/**
 * This class contains unit tests for validating the behavior of all Event and Task Apex classes
 *
 *
 */
@isTest(SeeAllData=True)
public class TestEventAndTaskAll
{
    /*********** Common Data Initialization ****************************/
       Static Event eventObj = new Event();
       Static LessonsLearnedEvents LLEvents = new LessonsLearnedEvents();
       Static Lessons_Learned__c lessonsLearned =new Lessons_Learned__c();
    /******************************************************************/
    
   
    /****************** testUpdateEvents ****************************************************/
    static testMethod void testUpdateEvents() {
    
    Account Acct = GenericTestClass.insertAccount();
    Contact cont = GenericTestClass.insertContact(Acct.Id);
    
    Case testcase = GenericTestClass.insertCase(Acct.Id, Cont.Id); 
   // LessonsLearnedEvents LLEvents = new LessonsLearnedEvents();
  //  Lessons_Learned__c lessonsLearned =new Lessons_Learned__c(); 
    lessonsLearned.Case_Number__c=testcase.Id;
    lessonsLearned.Status__c='Open';
    lessonsLearned.eventClose__c = 1;
    insert lessonsLearned;
    ID LL=[Select Id,closeTask__c,OpenTask__c From Lessons_Learned__c limit 1].Id;
    //Event eventObj = new Event();
    eventObj.WhatId=lessonsLearned.Id;
    eventObj.Subject='Subjectt';
    eventObj.ActivityDate=date.valueOf('2007-07-25');
    eventObj.DurationInMinutes=Integer.valueOf('0');
    eventObj.ActivityDateTime=datetime.valueOf('2008-12-03 13:51:00');
    insert eventObj;
    eventObj.Subject='Reeee';
    update eventObj;
    
    //Modified By Shruti Karn for CR# 22542
    
     Event eventObj2 = new Event();
     eventObj2.WhatId=lessonsLearned.Id;
     eventObj2.Subject='Subjectt';
     eventObj2.ActivityDate=date.valueOf('2007-07-25');
     eventObj2.DurationInMinutes=Integer.valueOf('0');
     eventObj2.ActivityDateTime=datetime.valueOf('2008-12-03 13:51:00');
     insert eventObj2;
     delete eventObj;
    }
    /***************************** End testUpdateEvents ******************************************/
    /****************************** TestLessonsLearnedEvents *********************************************/
     public static testMethod void testLessonsLearnedEvents()
     {
       //ID testcase=[Select Id From Case limit 1].Id;
       Case testcase = GenericTestClass.insertCase('', '');
       
      // LessonsLearnedEvents LLEvents = new LessonsLearnedEvents();
     //  Lessons_Learned__c lessonsLearned =new Lessons_Learned__c(); 
       lessonsLearned.Case_Number__c=testcase.Id;
       lessonsLearned.Status__c='Open';
       lessonsLearned.eventClose__c = 1;
       insert lessonsLearned;
      LLEvents.thisLLId=[Select Id,closeTask__c,OpenTask__c From Lessons_Learned__c limit 1].Id;
      // Event eventObj = new Event();
       eventObj.WhatId=lessonsLearned.Id;
       eventObj.Subject='Subjectt';
       eventObj.ActivityDate=date.valueOf('2007-07-25');
      eventObj.DurationInMinutes=Integer.valueOf('0');
      eventObj.ActivityDateTime=datetime.valueOf('2008-12-03 13:51:00');
      
      insert eventObj;
      LLEvents.getEvent();
      Task taskObj = new Task();
      taskobj.WhatId =lessonsLearned.Id;
      taskObj.Status='Completed';
      taskObj.Subject='repeat';
      taskObj.Description='beginn';
      insert taskObj;
       LLEvents.getTask();
  
     }
    /****************************** End TestLessonsLearnedEvents *********************************************/
    
    /******************************TestMassCreateTask *********************************************/
        public static testmethod void TestCaseOwnermethod()
        {

            ApexPages.StandardController sdtCon;
            MassCreateTaskController newObj = new MassCreateTaskController(sdtCon);
            
            String[] leftvalues = new String[]{newObj.userList[0].Id};
            
            newObj.setSelectedUsers(leftValues);
            
            String[] rightValues=newObj.getSelectedUsers();
            newObj.setfinallist(rightValues);
            
            List<SelectOption> testList = new List<SelectOption> ();
            testList.add(new SelectOption('Test1','Test1'));
            testList.add(new SelectOption('Test2','Test2'));
            
            newObj.setoptions(testList);
            newObj.setUsers(testList);
            newObj.setStatusList(testList);
            newObj.setPriorityList(testList);
            
            testList = newObj.getoptions();
            testList = newObj.getUsers();
            testList = newObj.getStatusList();
            testList = newObj.getPriorityList();
            
            newObj.ObjectType = '500';
            //newObj.ChangeObj();
            newObj.AddUsers();
            newObj.TaskNew.Subject = 'Call';
            DateTime dt = System.now();
            Date currentDate = date.newinstance(dt.year(), dt.month(), dt.day());
            //activityDate.activityDate = 
            
            newObj.TaskNew.ActivityDate = currentDate;
            newObj.taskStatus = 'Not Started';
            newObj.taskPriority ='High';
            //system.debug('LeftMap:'+newObj.LeftMap);
            newObj.save();
            
            newObj.search_value = 'Shruti Karn';
            newObj.Search();
            newObj.RemoveUsers();
            newObj.getfinallist();
            
            
           
            
        }
    /******************************End TestMassCreateTask *********************************************/    
    
    /****************************** testUpdateTask ************************************/
     static testMethod void testUpdateTask() {
      
    Account Acct = GenericTestClass.insertAccount();
    Contact cont = GenericTestClass.insertContact(Acct.Id);
    Case testcase= GenericTestClass.insertCase(Acct.Id, Cont.Id);
    
    //LessonsLearnedEvents LLEvents = new LessonsLearnedEvents();
    //Lessons_Learned__c lessonsLearned =new Lessons_Learned__c(); 
    lessonsLearned.Case_Number__c=testcase.Id;
    lessonsLearned.Status__c='Open';
    insert lessonsLearned;
    
    ID LL=[Select Id,closeTask__c,OpenTask__c From Lessons_Learned__c limit 1].Id;
    Task taskObj = new Task();
    taskObj.WhatId=lessonsLearned.Id;
    taskObj.Status='Completed';
    taskObj.Subject='repeat';
    taskObj.Description='beginn';
    insert taskObj;
    
System.debug('taskobjjjj'+taskObj);
    taskObj.Status='Not Started';
    update taskObj;
    
    //Modified By Shruti Karn for CR# 22542 
    Task taskObj2 = new Task();
    taskObj2.WhatId=lessonsLearned.Id;
    taskObj2.Status='Completed';
    taskObj2.Subject='repeat';
    taskObj2.Description='beginn';
    insert taskObj2;
    delete taskObj;
    }
    /******************************End testUpdateTask ************************************/
    
    
    
        



}