/**
 * This class contains unit tests for validating the behavior of Apex Class ForgotPasswordController
 */
@isTest
private class TestForgotPassword {
    public static testMethod void testForgotPasswordController() {
        // Instantiate a new controller with all parameters in the page
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.username = 'test@salesforce.com';        
    
        System.assertEquals(controller.forgotPassword(),null); 
    }
}