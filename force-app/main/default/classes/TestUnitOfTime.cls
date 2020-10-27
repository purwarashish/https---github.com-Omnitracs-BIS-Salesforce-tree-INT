@isTest(seealldata=true)
private class TestUnitOfTime 
{
 static testmethod void testMethodUnitOfTime()
    {
        Test.startTest();
        UnitOfTime uotD = UnitOfTime.Day;
        UnitOfTime uotW = UnitOfTime.Week;
        UnitOfTime uotM = UnitOfTime.Month;
        UnitOfTime uotQ = UnitOfTime.Quarter;
        UnitOfTime uotY = UnitOfTime.Year;
        UnitOfTime uotFq = UnitOfTime.FiscalQuarter;
        UnitOfTime uotFy = UnitOfTime.FiscalYear;
        Test.stopTest();
    }
}