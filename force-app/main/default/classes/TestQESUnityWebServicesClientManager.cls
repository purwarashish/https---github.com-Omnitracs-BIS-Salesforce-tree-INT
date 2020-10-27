@isTest
public class TestQESUnityWebServicesClientManager
{
    static testmethod void TestmethodForQWC1()
    {
        Test.startTest();
            Test.setMock(WebServiceMock.class, new QESUnitySuperLinkWebServicesMock());
           QESUnityWebServicesClientManager tst = new QESUnityWebServicesClientManager(10);
           tst.getUserType();
           tst.setDefaultSearchOption(null);
           tst.setDefaultSearchOption('Testing');
           tst.getSearchOptionUrl(null);
           tst.getSearchOptionUrl('Test the url');
           tst.getSupportLandingTrainingData();
           tst.getPlatformAppTrainingData();
           
           tst.trainingList = new List<QESUnityTraining>();
           QESUnityTraining tstQESUnityTraining = new QESUnityTraining();
           tstQESUnityTraining .linkUrl='testUrl';
           tstQESUnityTraining .title='Title';
           tstQESUnityTraining.body='TstBody';
           
           tst.trainingList.add(tstQESUnityTraining );
           tst.getSupportLandingTrainingData();
           tst.getPlatformAppTrainingData();
           
           tst.trainingList.add(tstQESUnityTraining );
           tst.getSupportLandingTrainingData();
           tst.getPlatformAppTrainingData();
           
           tst.trainingList.add(tstQESUnityTraining );
           tst.getPlatformAppTrainingData();
           
           tst.refreshTrainingData('Test');
         Test.stopTest(); 
         
    }
    
    static testmethod void TestmethodForQWC2()
    {
        Test.startTest();
              Test.setMock(WebServiceMock.class, new QESUnitySuperLinkWebServicesMock());
           QESUnityWebServicesClientManager tst = new QESUnityWebServicesClientManager(10);
           tst.refreshNewFeaturesData();
           
         Test.stopTest(); 
          
    }
    
    static testmethod void TestmethodForQWC3()
    {
        Test.startTest();
              Test.setMock(WebServiceMock.class, new QESUnitySuperLinkWebServicesMock());
           QESUnityWebServicesClientManager tst = new QESUnityWebServicesClientManager(10);
           
           tst.getMenuLinks();
        Test.stopTest();
        
    }
    
    static testmethod void TestmethodForQWC4()
    {
        Test.startTest();
              Test.setMock(WebServiceMock.class, new QESUnitySuperLinkWebServicesMock());
           QESUnityWebServicesClientManager tst = new QESUnityWebServicesClientManager(10);
          
           tst.getQuickLinks();
        Test.stopTest();
      
    }
    
     static testmethod void TestmethodForQWC5()
    {
        Test.startTest();
              Test.setMock(WebServiceMock.class, new QESUnitySuperLinkWebServicesMock());
           QESUnityWebServicesClientManager tst = new QESUnityWebServicesClientManager(10);
          
           tst.getUserProfileLinks();
         
        Test.stopTest();
    }
    
     static testmethod void TestmethodForQWC6()
    {
        Test.startTest();
              Test.setMock(WebServiceMock.class, new QESUnitySuperLinkWebServicesMock());
           QESUnityWebServicesClientManager tst = new QESUnityWebServicesClientManager(10);
          
           tst.getGlobalSearchOptions();
         
        Test.stopTest();
    }
    
     static testmethod void TestmethodForQWC7()
    {
        Test.startTest();
              Test.setMock(WebServiceMock.class, new QESUnitySuperLinkWebServicesMock());
           QESUnityWebServicesClientManager tst = new QESUnityWebServicesClientManager(10);
         
           tst.getCriticalAlerts();
          
        Test.stopTest();
    }
    
     static testmethod void TestmethodForQWC8()
    {
        Test.startTest();
              Test.setMock(WebServiceMock.class, new QESUnitySuperLinkWebServicesMock());
           QESUnityWebServicesClientManager tst = new QESUnityWebServicesClientManager(10);
         
           tst.getNotifications();
        Test.stopTest();
    }
    
     static testmethod void TestmethodForQWC9()
    {
        Test.startTest();
              Test.setMock(WebServiceMock.class, new QESUnitySuperLinkWebServicesMock());
           QESUnityWebServicesClientManager tst = new QESUnityWebServicesClientManager();
          
        Test.stopTest();
    }
    
     static testmethod void TestmethodForQWC10()
    {
        Test.startTest();
              Test.setMock(WebServiceMock.class, new QESUnitySuperLinkWebServicesMock());
           QESUnityWebServicesClientManager tst = new QESUnityWebServicesClientManager(10);
         
           tst.refreshTrainingData('');
        Test.stopTest();
    }
    
     static testmethod void TestmethodForQWC11()
    {
        Test.startTest();
              Test.setMock(WebServiceMock.class, new QESUnitySuperLinkWebServicesMock());
           QESUnityWebServicesClientManager tst = new QESUnityWebServicesClientManager(10);
         
           tst.getTopArticlesList();
        Test.stopTest();
     }
     
  }