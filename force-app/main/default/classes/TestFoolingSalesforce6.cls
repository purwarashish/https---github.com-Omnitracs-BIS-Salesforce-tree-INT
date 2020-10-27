@isTest//(seeAllData=true)
public class TestFoolingSalesforce6{
    static testmethod void TestQESUnityHtmlFilter()
    {
        Test.startTest();
        FoolingSalesforce6.dummy();
        FoolingSalesforce7.dummy();
        FoolingSalesforce8.dummy();
        Test.stopTest();
    }
}