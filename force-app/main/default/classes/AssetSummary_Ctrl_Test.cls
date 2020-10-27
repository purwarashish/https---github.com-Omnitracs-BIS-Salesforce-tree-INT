@isTest(seeAllData=true)
public class AssetSummary_Ctrl_Test {

    static testMethod void testConstructor() {
        Account a = TestUtils.getAccount('ut acc1');
        insert a;
        Product2 p1 = TestUtils.getProduct('up1', 'family1'); insert p1;
        Product2 p2 = TestUtils.getProduct('up2', 'family2'); insert p2;
        Contract cont = TestUtils.getContract(a);
        insert cont;
        Asset__c va1 = TestUtils.getAsset(a, p1, cont); va1.Name = 'v1';
        Asset__c va2 = TestUtils.getAsset(a, p2, cont); va2.Name = 'v2';
        insert va1;
        insert va2;
        
        ApexPages.StandardController std = new ApexPages.StandardController(a);
        Test.startTest();
        AssetSummary_Ctrl con = new AssetSummary_Ctrl(std);
        //System.assertEquals(2, con.assetList.size());
        Test.stopTest();
    }
    
    //  **** added by joseph hutchins for the little map set section of the asset page
    private static testmethod void TestForMapSetSection()
    {
        Savepoint sp = Database.setSavepoint();
        Account testAccount = RoadnetUnitTests.CreateTestAccount(null);
        Map_Set__c testMapSet = RoadnetUnitTests.CreateTestMapSet(null, testAccount.id);
        
        AssetSummary_Ctrl testExtension = new AssetSummary_Ctrl(AssetSummary_Ctrl.generateController(testAccount));
        system.assertNotEquals(null, testExtension.getLatestMapSetPurchased());
        system.assertNotEquals(null, testExtension.mostCurrentMapSet);
        
        Account acc = TestUtils.getAccount('ut acc2');
        insert acc;
        
        Account acc1 = TestUtils.getAccount('ut acc3');
        insert acc1;
        
        Customer_Asset__c asset = new Customer_Asset__c();
        asset.Name = 'Test Asset';
        asset.Account__c = acc.Id;
        insert asset;
        
        /*Customer_Asset__c assetDupe = new Customer_Asset__c();
        assetDupe.Name = 'Test Asset Dupe';
        asset.Account__c = acc1.Id;
        insert assetDupe;*/
        
        AssetSummary_Ctrl.AssetSummaryRow test = new AssetSummary_Ctrl.AssetSummaryRow(asset);
        AssetSummary_Ctrl.isRnaRouting('Test');
        AssetSummary_Ctrl.isRnaRouting('Anywhere Routing');
        AssetSummary_Ctrl.isRnaDispatch('Test');
        AssetSummary_Ctrl.isRnaDispatch('Anywhere Dispatching');
        AssetSummary_Ctrl.isRnaTracking('Test');
        AssetSummary_Ctrl.isRnaTracking('Anywhere Tracking');
        
        AssetSummary_Ctrl.zeroOutNullNumberFieldsOnLineItem(asset);
        AssetSummary_Ctrl.AssetSummaryRow obj = new AssetSummary_Ctrl.AssetSummaryRow(asset);
        //AssetSummary_Ctrl.AssetSummaryRow objDupe = new AssetSummary_Ctrl.AssetSummaryRow(assetDupe);
        AssetSummary_Ctrl.checkForDupeUsingUnknownCriteria(obj, obj );
        AssetSummary_Ctrl.zeroOutNullFields(obj);
        AssetSummary_Ctrl.checkForDupeUsingTheQuantityAsCriteria(obj, obj );
        
        list<AssetSummary_Ctrl.AssetSummaryRow> objlist = new list<AssetSummary_Ctrl.AssetSummaryRow> ();
        objlist.add(obj);
        AssetSummary_Ctrl.removeDuplicateRNASubscriptionLineItemsAndUpAllValues(objlist);
        AssetSummary_Ctrl.removeDupesAndAddAllValues(objlist);
        AssetSummary_Ctrl.removeDupesAndAssignQuantityAndMoreToSFLI(objlist,0,0);
        
        
        
        
        Database.rollback(sp);
    }

}