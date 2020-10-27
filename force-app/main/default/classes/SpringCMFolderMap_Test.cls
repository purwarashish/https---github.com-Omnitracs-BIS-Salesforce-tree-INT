// Createdby: DLE

@IsTest
public class SpringCMFolderMap_Test {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'  \"Name\": \"Q-87131\",'+
		'  \"CreatedDate\": \"2018-08-10T02:55:33.34Z\",'+
		'  \"CreatedBy\": \"jonhusk@omnitracs.com\",'+
		'  \"UpdatedDate\": \"2018-08-10T02:55:33.34Z\",'+
		'  \"UpdatedBy\": \"jonhusk@omnitracs.com\",'+
		'  \"Description\": \"\",'+
		'  \"ParentFolder\": {'+
		'    \"Href\": \"https://apiuatna11.springcm.com/v201411/folders/330efdac-259b-e811-9c16-3ca82a1e3f41\"'+
		'  },'+
		'  \"BrowseDocumentsUrl\": \"https://uatna11.springcm.com/atlas/Link/Folder/8078/bb3d45d3-489c-e811-9c16-3ca82a1e3f41\",'+
		'  \"AccessLevel\": {'+
		'    \"See\": true,'+
		'    \"Read\": true,'+
		'    \"Write\": true,'+
		'    \"Move\": true,'+
		'    \"Create\": true,'+
		'    \"SetAccess\": true'+
		'  },'+
		'  \"Documents\": {'+
		'    \"Items\": ['+
		'      {'+
		'        \"Name\": \"Q-87131_FinalPackage.pdf\",'+
		'        \"CreatedDate\": \"2018-08-10T02:56:32.91Z\",'+
		'        \"CreatedBy\": \"Workflow\",'+
		'        \"UpdatedDate\": \"2018-08-10T03:19:05.76Z\",'+
		'        \"UpdatedBy\": \"Workflow\",'+
		'        \"Description\": \"Signature Rejected\",'+
		'        \"ParentFolder\": {'+
		'          \"Href\": \"https://apiuatna11.springcm.com/v201411/folders/bb3d45d3-489c-e811-9c16-3ca82a1e3f41\"'+
		'        },'+
		'        \"HistoryItems\": {'+
		'          \"Href\": \"https://apiuatna11.springcm.com/v201411/documents/611ecbf7-489c-e811-9c16-3ca82a1e3f41/historyitems\"'+
		'        },'+
		'        \"AccessLevel\": {'+
		'          \"See\": true,'+
		'          \"Read\": true,'+
		'          \"Write\": true,'+
		'          \"Move\": true,'+
		'          \"Create\": true,'+
		'          \"SetAccess\": true'+
		'        },'+
		'        \"PageCount\": 2,'+
		'        \"Lock\": {'+
		'          \"Href\": \"https://apiuatna11.springcm.com/v201411/documents/611ecbf7-489c-e811-9c16-3ca82a1e3f41/lock\"'+
		'        },'+
		'        \"PreviewUrl\": \"https://uatna11.springcm.com/atlas/documents/docexplorer?aid=8078&id=611ecbf7-489c-e811-9c16-3ca82a1e3f41\",'+
		'        \"Versions\": {'+
		'          \"Href\": \"https://apiuatna11.springcm.com/v201411/documents/611ecbf7-489c-e811-9c16-3ca82a1e3f41/versions\"'+
		'        },'+
		'        \"ShareLinks\": {'+
		'          \"Href\": \"https://apiuatna11.springcm.com/v201411/documents/611ecbf7-489c-e811-9c16-3ca82a1e3f41/sharelinks\"'+
		'        },'+
		'        \"DocumentProcessTrackingActivities\": {'+
		'          \"Href\": \"https://apiuatna11.springcm.com/v201411/documents/611ecbf7-489c-e811-9c16-3ca82a1e3f41/documentprocesstrackingactivities\"'+
		'        },'+
		'        \"DocumentReminders\": {'+
		'          \"Href\": \"https://apiuatna11.springcm.com/v201411/documents/611ecbf7-489c-e811-9c16-3ca82a1e3f41/documentreminders\"'+
		'        },'+
		'        \"RelatedDocuments\": {'+
		'          \"Href\": \"https://apiuatna11.springcm.com/v201411/documents/611ecbf7-489c-e811-9c16-3ca82a1e3f41/relateddocuments\"'+
		'        },'+
		'        \"DownloadDocumentHref\": \"https://apidownloaduatna11.springcm.com/v201411/documents/611ecbf7-489c-e811-9c16-3ca82a1e3f41\",'+
		'        \"NativeFileSize\": 323707,'+
		'        \"PdfFileSize\": 323707,'+
		'        \"Href\": \"https://apiuatna11.springcm.com/v201411/documents/611ecbf7-489c-e811-9c16-3ca82a1e3f41\"'+
		'      },'+
		'      {'+
		'        \"Name\": \"Q-87131_FinalPackage (1).pdf\",'+
		'        \"CreatedDate\": \"2018-08-10T03:23:55.163Z\",'+
		'        \"CreatedBy\": \"Workflow\",'+
		'        \"UpdatedDate\": \"2018-08-10T16:47:27.173Z\",'+
		'        \"UpdatedBy\": \"jonhusk@omnitracs.com\",'+
		'        \"Description\": \"Signed Package\",'+
		'        \"ParentFolder\": {'+
		'          \"Href\": \"https://apiuatna11.springcm.com/v201411/folders/bb3d45d3-489c-e811-9c16-3ca82a1e3f41\"'+
		'        },'+
		'        \"HistoryItems\": {'+
		'          \"Href\": \"https://apiuatna11.springcm.com/v201411/documents/eedd4d43-4c9c-e811-9c16-3ca82a1e3f41/historyitems\"'+
		'        },'+
		'        \"AccessLevel\": {'+
		'          \"See\": true,'+
		'          \"Read\": true,'+
		'          \"Write\": true,'+
		'          \"Move\": true,'+
		'          \"Create\": true,'+
		'          \"SetAccess\": true'+
		'        },'+
		'        \"PageCount\": 3,'+
		'        \"Lock\": {'+
		'          \"Href\": \"https://apiuatna11.springcm.com/v201411/documents/eedd4d43-4c9c-e811-9c16-3ca82a1e3f41/lock\"'+
		'        },'+
		'        \"PreviewUrl\": \"https://uatna11.springcm.com/atlas/documents/docexplorer?aid=8078&id=eedd4d43-4c9c-e811-9c16-3ca82a1e3f41\",'+
		'        \"Versions\": {'+
		'          \"Href\": \"https://apiuatna11.springcm.com/v201411/documents/eedd4d43-4c9c-e811-9c16-3ca82a1e3f41/versions\"'+
		'        },'+
		'        \"ShareLinks\": {'+
		'          \"Href\": \"https://apiuatna11.springcm.com/v201411/documents/eedd4d43-4c9c-e811-9c16-3ca82a1e3f41/sharelinks\"'+
		'        },'+
		'        \"DocumentProcessTrackingActivities\": {'+
		'          \"Href\": \"https://apiuatna11.springcm.com/v201411/documents/eedd4d43-4c9c-e811-9c16-3ca82a1e3f41/documentprocesstrackingactivities\"'+
		'        },'+
		'        \"DocumentReminders\": {'+
		'          \"Href\": \"https://apiuatna11.springcm.com/v201411/documents/eedd4d43-4c9c-e811-9c16-3ca82a1e3f41/documentreminders\"'+
		'        },'+
		'        \"RelatedDocuments\": {'+
		'          \"Href\": \"https://apiuatna11.springcm.com/v201411/documents/eedd4d43-4c9c-e811-9c16-3ca82a1e3f41/relateddocuments\"'+
		'        },'+
		'        \"DownloadDocumentHref\": \"https://apidownloaduatna11.springcm.com/v201411/documents/eedd4d43-4c9c-e811-9c16-3ca82a1e3f41\",'+
		'        \"NativeFileSize\": 438612,'+
		'        \"PdfFileSize\": 438612,'+
		'        \"Href\": \"https://apiuatna11.springcm.com/v201411/documents/eedd4d43-4c9c-e811-9c16-3ca82a1e3f41\"'+
		'      }'+
		'    ],'+
		'    \"Href\": \"https://apiuatna11.springcm.com/v201411/folders/bb3d45d3-489c-e811-9c16-3ca82a1e3f41/documents\",'+
		'    \"Offset\": 0,'+
		'    \"Limit\": 20,'+
		'    \"First\": \"https://apiuatna11.springcm.com/v201411/folders/bb3d45d3-489c-e811-9c16-3ca82a1e3f41/documents\",'+
		'    \"Last\": \"https://apiuatna11.springcm.com/v201411/folders/bb3d45d3-489c-e811-9c16-3ca82a1e3f41/documents\",'+
		'    \"Total\": 2'+
		'  },'+
		'  \"Folders\": {'+
		'    \"Href\": \"https://apiuatna11.springcm.com/v201411/folders/bb3d45d3-489c-e811-9c16-3ca82a1e3f41/folders\"'+
		'  },'+
		'  \"ShareLinks\": {'+
		'    \"Href\": \"https://apiuatna11.springcm.com/v201411/folders/bb3d45d3-489c-e811-9c16-3ca82a1e3f41/sharelinks\"'+
		'  },'+
		'  \"CreateDocumentHref\": \"https://apiuploaduatna11.springcm.com/v201411/folders/bb3d45d3-489c-e811-9c16-3ca82a1e3f41/documents{?name}\",'+
		'  \"Href\": \"https://apiuatna11.springcm.com/v201411/folders/bb3d45d3-489c-e811-9c16-3ca82a1e3f41\"'+
		'}';
		SpringCMFolderMap r = SpringCMFolderMap.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		SpringCMFolderMap.Documents objDocuments = new SpringCMFolderMap.Documents(System.JSON.createParser(json));
		System.assert(objDocuments != null);
		System.assert(objDocuments.Items == null);
		System.assert(objDocuments.Href == null);
		System.assert(objDocuments.Offset == null);
		System.assert(objDocuments.Limit_Z == null);
		System.assert(objDocuments.First == null);
		System.assert(objDocuments.Last == null);
		System.assert(objDocuments.Total == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		SpringCMFolderMap.Items objItems = new SpringCMFolderMap.Items(System.JSON.createParser(json));
		System.assert(objItems != null);
		System.assert(objItems.Name == null);
		System.assert(objItems.CreatedDate == null);
		System.assert(objItems.CreatedBy == null);
		System.assert(objItems.UpdatedDate == null);
		System.assert(objItems.UpdatedBy == null);
		System.assert(objItems.Description == null);
		System.assert(objItems.ParentFolder == null);
		System.assert(objItems.HistoryItems == null);
		System.assert(objItems.AccessLevel == null);
		System.assert(objItems.PageCount == null);
		System.assert(objItems.Lock == null);
		System.assert(objItems.PreviewUrl == null);
		System.assert(objItems.Versions == null);
		System.assert(objItems.ShareLinks == null);
		System.assert(objItems.DocumentProcessTrackingActivities == null);
		System.assert(objItems.DocumentReminders == null);
		System.assert(objItems.RelatedDocuments == null);
		System.assert(objItems.DownloadDocumentHref == null);
		System.assert(objItems.NativeFileSize == null);
		System.assert(objItems.PdfFileSize == null);
		System.assert(objItems.Href == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		SpringCMFolderMap objSpringCMFolderMap = new SpringCMFolderMap(System.JSON.createParser(json));
		System.assert(objSpringCMFolderMap != null);
		System.assert(objSpringCMFolderMap.Name == null);
		System.assert(objSpringCMFolderMap.CreatedDate == null);
		System.assert(objSpringCMFolderMap.CreatedBy == null);
		System.assert(objSpringCMFolderMap.UpdatedDate == null);
		System.assert(objSpringCMFolderMap.UpdatedBy == null);
		System.assert(objSpringCMFolderMap.Description == null);
		System.assert(objSpringCMFolderMap.ParentFolder == null);
		System.assert(objSpringCMFolderMap.BrowseDocumentsUrl == null);
		System.assert(objSpringCMFolderMap.AccessLevel == null);
		System.assert(objSpringCMFolderMap.Documents == null);
		System.assert(objSpringCMFolderMap.Folders == null);
		System.assert(objSpringCMFolderMap.ShareLinks == null);
		System.assert(objSpringCMFolderMap.CreateDocumentHref == null);
		System.assert(objSpringCMFolderMap.Href == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		SpringCMFolderMap.ParentFolder objParentFolder = new SpringCMFolderMap.ParentFolder(System.JSON.createParser(json));
		System.assert(objParentFolder != null);
		System.assert(objParentFolder.Href == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		SpringCMFolderMap.AccessLevel objAccessLevel = new SpringCMFolderMap.AccessLevel(System.JSON.createParser(json));
		System.assert(objAccessLevel != null);
		System.assert(objAccessLevel.See == null);
		System.assert(objAccessLevel.Read == null);
		System.assert(objAccessLevel.Write == null);
		System.assert(objAccessLevel.Move == null);
		System.assert(objAccessLevel.Create == null);
		System.assert(objAccessLevel.SetAccess == null);
	}
}