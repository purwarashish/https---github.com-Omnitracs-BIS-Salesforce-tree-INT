@isTest (seeAllData=true)
private class ProductDocumentationModelerTest
{
    public static testMethod void ProductDocumentationModelerTest()
        {
            ProductDocumentationModeler pdm = new ProductDocumentationModeler();
			pdm.getlistOfFilters();
			pdm.getlstFilteredApplicationDocs();
			pdm.getlstFilteredHardwareDocs();
			pdm.getlstFilteredTrainingDocs();
			pdm.filterAppList();
			pdm.filterHWList();
			pdm.filterTrainingList();
            pdm.next();
            pdm.previous();
            pdm.NextContent();
            pdm.PreviousContent();
            pdm.getNextTrainingDocs();
            pdm.getPreviousTrainingDocs();
            pdm.getNextHardwareDocs();
            pdm.getPreviousHardwareDocs();
            pdm.getNextApplicationDocs();
            pdm.getPreviousApplicationDocs();
            pdm.redirectTo();
            pdm.getResultData();
            pdm.setMapSpltProd ();
            pdm.getMapSpltProd ();
            
        }
     public static testMethod void ProductDocumentationModelerTest1()   
        {
            ContentDocument cd = [select Id from ContentDocument limit 1];
            ContentVersion cv = new ContentVersion();
            cv.title = 'test';
            cv.PathOnClient = 'testPath';
            cv.VersionData=blob.valueof('New Bitmap Image.bmp');
            //cv.Document_Category__c = 'Documentation';
            //cv.Type__c = 'testType';
            //cv.Product__c = 'testProduct';
            //cv.IsLatest = true;
            insert cv;
            
            
            ApexPages.currentPage().getParameters().put('doctype','DOC');
            ProductDocumentationModeler pdm = new ProductDocumentationModeler();
            
            ApexPages.currentPage().getParameters().put('prodtype','PROD');
            ProductDocumentationModeler pdm1 = new ProductDocumentationModeler();
            
            
            ApexPages.currentPage().getParameters().put('headertype','HEAD');
            ProductDocumentationModeler pdm2 = new ProductDocumentationModeler();
            
            
            
            ApexPages.currentPage().getParameters().put('doctype','CFA');
            ProductDocumentationModeler pdm3 = new ProductDocumentationModeler();
            
            pdm3.lstCmVer.add(cv);
            
          //  pdm.docType = 'DOC';
           // pdm.refreshInitializationData(); 
        }
}