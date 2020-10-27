/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
*/
@isTest
private class TestCryptoUtils {
    static testMethod void myUnitTest() {
        String encryptedStr = CryptoUtils.encrypt('Hello World!!');
        CryptoUtils.decrypt(encryptedStr);
    }
}