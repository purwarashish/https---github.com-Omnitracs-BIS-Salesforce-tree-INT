@isTest
public class WebServiceExecutionTest {
	
	static testMethod void myUnitTest() {
		Test.startTest();
		WebServiceExecution.ExecuteTxnLogBatch();
        Test.stopTest();
    }
}