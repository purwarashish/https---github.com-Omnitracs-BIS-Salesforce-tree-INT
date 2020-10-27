/********************************************************************
Purpose:To validate the functionality of fallowing classes
1.MainController
*********************************************************************/
@isTest(seeAllData = true)
private class MainController_Test 
{
    
    static testMethod void validateTestMainController() 
    {
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new QESUnitySuperLinkWebServicesMock());
        
        MainController testMC=new MainController();
        PageReference pageRef = new PageReference('/apex/supportPlatformsapps');
        Test.setCurrentPage(pageRef);
        
        testMC.searchText = 'abc';
        testMC.cookieDomainName ='sampleCookie';
        testMC.globalSearchRedirectTo();
        testMC.menuHeaderRedirectTo();
        testMC.getCaseCreationAllowed();
        testMC.getCachedCase();
        testMC.getCachedCaseNumber();
        testMC.pam_initSingleton();
        testMC.csm_initSingleton();
        testMC.qpm_initSingleton();
        testMC.qpm_initSupportLandingSingleton();
        testMC.rcm_initSingleton();
        testMC.arm_initSingleton();
        testMC.gsm_initSingleton();
        testMC.cvm_initSingleton();
        testMC.nfm_initSingleton();
        testMC.pdm_initSingleton();
        TrainingPagesModeler tpm = new TrainingPagesModeler();
        testMC.pdm_initSingleton();
        testMC.tpm_initSingleton();
        Test.stopTest();
        
    }
    
}