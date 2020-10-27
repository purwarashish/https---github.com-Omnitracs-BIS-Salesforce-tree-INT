/**
 * @description A wrapper class for the Standard Controller for Case.
 * The class would ensure that a single instance of a CaseController
 * exists during the entire life of a process. QES Unity Support Site
 * classes would make use of this class and would not instantiate a 
 * standard case controller directly.
 */
public class CaseCacheManager {
    /**
     * @description Private variable for holding the reference to a 
     * standard case controller object.
     */
    private Case   cachedCase;
    private String cachedCaseNumber;       
    
    /**
     * @description Default constructor. Does not instantiate the member 
     * standard case controller object.
     */
    public CaseCacheManager() {
        cachedCase = new Case();
        cachedCaseNumber = '';
    }
        
    /**
     * @description Getter Method to access the standard case controller object.
     */
    public Case getCachedCase() {
        return cachedCase;
    }
    
    public String getCachedCaseNumber()
    {
        return cachedCaseNumber;
    }    
     
    public void updateCaseCache(Case caseCopy) {
         if(null != caseCopy)
         {
             cachedCaseNumber = caseCopy.CaseNumber;
             cachedCase = new Case();
             cachedCase.QES_Unity_CP_Phone__c= caseCopy.QES_Unity_CP_Phone__c;
             cachedCase.Subject = caseCopy.Subject;
             cachedCase.description = caseCopy.description;
             cachedCase.Application__c = caseCopy.Application__c;
             cachedCase.Platform__c = caseCopy.Platform__c;
             cachedCase.status = caseCopy.status;
             cachedCase.Serial__c = caseCopy.Serial__c;
             cachedCase.Resolution__c = caseCopy.Resolution__c;
             cachedCase.PCMEmail__c = caseCopy.PCMEmail__c;
             cachedCase.PCMPhone__c = caseCopy.PCMPhone__c;
             cachedCase.origin = caseCopy.origin;
         }     
     }     
}