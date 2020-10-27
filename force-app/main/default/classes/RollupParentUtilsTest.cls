/**
 * Created by Yasir Arafat
 */

@IsTest
private class RollupParentUtilsTest {
    private static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
    
    @testSetup
    static void SetupData() {
        TestUtils.defineCustomSettings();
    }

    @IsTest
    static void testRollupParentUtils() {
        Test.startTest();
        Account parentAccount = util.createAccount('Parent Test Account');
        Account childAccount = util.createAccount('Child Test Account');
        RollupParentUtils.rollupParentExecuted = false;
        childAccount.ParentId = parentAccount.Id;
        update childAccount;
        RollupParentUtils.rollupParentExecuted = false;
        delete parentAccount;
        RollupParentUtils.rollupParentExecuted = false;
        undelete parentAccount;
        Test.stopTest();
    }
}