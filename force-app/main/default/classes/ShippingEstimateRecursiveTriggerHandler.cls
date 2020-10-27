/**
 * Class to prevent a recursion on the ShippingEstimates.
 */

public with sharing class ShippingEstimateRecursiveTriggerHandler {
    public static Boolean isFirstTime = true;
}