@isTest(seeAllData = true)
private class TestSsoLoginController {

    static testMethod void TestssoLoginController() {
        test.startTest();
        Map<String, String> urlParam = new Map<String, String>();
        Apexpages.currentPage().getParameters().put('target','test');
        //urlParam.put('target','test');
        ssoLoginController sLogCon = new ssoLoginController();
        
        sLogCon.runTest();
        test.stopTest();
        }
    }