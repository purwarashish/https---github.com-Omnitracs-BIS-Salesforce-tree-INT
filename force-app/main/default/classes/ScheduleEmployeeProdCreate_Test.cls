@isTest(SeeAllData=true)
class ScheduleEmployeeProdCreate_Test
{
    
    /*static testMethod void testCallEmployeeProdBatchClass()
    {
       test.startTest(); 
        for (integer count = 0; count <7; count++)
        {
            ScheduleEmployeeProdCreate test = new ScheduleEmployeeProdCreate();
            test.dateValue = Date.today().addDays(- count );    
            test.execute(null);
        }
        test.stoptest();
    }*/
    
    
    
    static testMethod void testCallTimeCardBatchClass()
    {
        test.startTest();
        ScheduleTimeCardCreate test1 = new ScheduleTimeCardCreate();
        test1.execute(null);
        test.stoptest();
        
    }
    
   
}