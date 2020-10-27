@isTest(SeeAllData=True)
public class EscalateCaseController_Test{    
    private static VistaAssetHelperUtil util = new VistaAssetHelperUtil();
    /**
     * @description Method that tests a success redirection method of EscalateCaseController.
     * @author original K. Vegerano <kristian.vegerano@cloudsherpas.com>
     */
    public static testMethod void testEscalateToEngineeringSuccess(){
        //Set Test Variables
        Account testAccount = util.createAccount('Test Account');
        Asset__c testAsset = new Asset__c(Name='Test Asset', 
                                          Account__c = testAccount.Id, 
                                          Term_Start_Date__c = System.today(), 
                                          Term_End_Date__c = System.today());
        insert testAsset;
        
        Case testCase = new Case(Subject = 'testCase', Asset__c = testAsset.Id, AccountId = testAccount.Id,
                                 Description = 'Test Description');
        insert testCase;
        //Create Attachment to the case
        Attachment attach = new Attachment(Name = 'Unit Test Attachment',
                                           Body = Blob.valueOf('Unit Test Attachment Body'),
                                           parentId = testCase.Id);     
        insert attach;
        
        PageReference testPage = new PageReference('/apex/EscalateCase?id=' + testCase.id + '&Comment=TestComment');
        Test.startTest();
            Test.setCurrentPage(testPage);
            EscalateCaseController controller = new EscalateCaseController();
            controller.EscalateToEngineering();
        Test.stopTest();
    }
    
    /**
     * @description Method that tests a fail redirection method of EscalateCaseController with a use of wrong case Id.
     * @author original K. Vegerano <kristian.vegerano@cloudsherpas.com>
     */
    public static testMethod void testEscalateToEngineeringFail(){
        Case testCase = new Case(Subject = 'testCase');
        insert testCase;
        PageReference testPage = new PageReference('/apex/EscalateCase?id=' + testCase.id + '1');
        Test.startTest();
            Test.setCurrentPage(testPage);
            EscalateCaseController controller = new EscalateCaseController();
            controller.EscalateToEngineering();
        Test.stopTest();
    }
}