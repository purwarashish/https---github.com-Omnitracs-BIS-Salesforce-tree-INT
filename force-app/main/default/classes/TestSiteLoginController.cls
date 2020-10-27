/**
 * This class contains unit tests for validating the behavior of SiteLoginController.
 */
@isTest
private class TestSiteLoginController {

     public static testMethod void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null);                           
    }    
}