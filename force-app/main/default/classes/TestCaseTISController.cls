/**
 * This class contains unit tests for validating the behavior of Apex Class CaseTISControllerExtension
 */
@isTest(seeAllData=true)
private class TestCaseTISController {
    public static testmethod void TestController()
    {

    Case newCase = new Case();
    insert newCase;
    ApexPages.StandardController sdtCon = new ApexPages.StandardController(newCase);
    CaseTISControllerExtension Controller = new CaseTISControllerExtension(sdtCon);
    Controller.CalculateOptionsList();
    Controller.TrueToggleShowDetail();
    Controller.FalseToggleShowDetail();
    Controller.getTISSummary();
    Controller.getTISDetail();
    Controller.getItems();
    Controller.ReturntoCase();
    }
}