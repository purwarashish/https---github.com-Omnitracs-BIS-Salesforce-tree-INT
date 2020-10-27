@isTest
public class TestTrainingPagesModeler
{
    static testmethod void myUnitTest()
    {
        
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new QESUnityWebServicesClientManagerMock());
        ApexPages.currentPage().getParameters().put('ret','www.xyz.com');
        ApexPages.currentPage().getParameters().put('name','hello');
        ApexPages.currentPage().getParameters().put('prodType','hello');
        ApexPages.currentPage().getParameters().put('docType','hello');
        TrainingPagesModeler tpm1 = new TrainingPagesModeler();
        
        tpm1.trainingListSize = 3;
        //tpm1.next();
        //tpm1.previous();
    }
    
    static testmethod void myUnitTest1()
    {
        
        Test.setMock(WebServiceMock.class, new QESUnityWebServicesClientManagerMock());
        ApexPages.currentPage().getParameters().put('ret','www.xyz.com');
        ApexPages.currentPage().getParameters().put('name','hello');
        ApexPages.currentPage().getParameters().put('prodType','hello');
        ApexPages.currentPage().getParameters().put('docType','hello');
        TrainingPagesModeler tpm1 = new TrainingPagesModeler();
        
        tpm1.trainingListSize = 5;
        tpm1.next();
        tpm1.previous();
    }
}