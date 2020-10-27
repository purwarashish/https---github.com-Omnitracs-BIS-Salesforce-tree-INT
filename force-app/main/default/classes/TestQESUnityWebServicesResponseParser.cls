/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
*/
@isTest
private class TestQESUnityWebServicesResponseParser {
    static testMethod void myUnitTest() {
        
        // Create a LinkGroupList
        QESUnitySuperLinkWebServices.LinkGroupList_element LinkGroupList = 
                new QESUnitySuperLinkWebServices.LinkGroupList_element();
                
        // Parse the blank LinkGroupList
        QESUnityWebServicesResponseParser.parseLinkGroupList(LinkGroupList, 0, NULL, false);

        // Create an List of LinkGroups inside it
        LinkGroupList.linkGroup = new List<QESUnitySuperLinkWebServices.LinkGroup>();
        
        // Populate 10 different LinkGroups in the List of LinkGroups
        for(Integer i = 0; i < 10; i++) {
            // Create a tmpLinkGroup      
            QESUnitySuperLinkWebServices.LinkGroup tmpLg = new QESUnitySuperLinkWebServices.LinkGroup();
            
            // Create a LinkList inside the tmpLinkGroup
            tmpLg.LinkList = new QESUnitySuperLinkWebServices.LinkList_element();
            tmpLg.LinkList.link = 
                        new List<QESUnitySuperLinkWebServices.Link>();
            for(Integer j = 0; j < 10; j++) {
                QESUnitySuperLinkWebServices.Link tmpLink =
                        new QESUnitySuperLinkWebServices.Link();
                tmpLink.LinkGuid = 'xxxxxxxxxx';
                tmpLink.LinkId = 'xxxxxxxxxx';
                tmpLink.LinkURL = 'http://www.qualcomm.com';
                tmpLink.Title = 'xxxxxxxxxx';
                tmpLink.Body = 'xxxxxxxxxx';
                tmpLink.IconURL = 'http://www.qualcomm.com';
                tmpLink.LinkType = 'L';
                tmpLink.AltText = 'xxxxxxxxxx';
                tmpLink.LinkGroupGuid = 'xxxxxxxxxx';
                tmpLink.LinkGroupId = 'xxxxxxxxxx';
                
                if(0 == j) {
                    tmpLink.LinkType = 'G';
                }
                if(1 == j) {
                    tmpLink.LinkURL = 'http://www.qualcomm.com/support';
                }                               
                
                tmpLg.LinkList.link.add(tmpLink);       
            }
/*
            if(1 == i) {
                for(Integer m = 0; m < 5; m++) {
                    tmpLg.LinkGroupList = 
                            new QESUnitySuperLinkWebServices.LinkGroupList_element();
                                
                    // Create an List of LinkGroups inside it
                    tmpLg.LinkGroupList.linkGroup = new List<QESUnitySuperLinkWebServices.LinkGroup>();
                    
                    // Populate 10 different LinkGroups in the List of LinkGroups
                    for(Integer j = 0; j < 10; i++) {
                        // Create a tmpLinkGroup      
                        QESUnitySuperLinkWebServices.LinkGroup tmp1Lg = new QESUnitySuperLinkWebServices.LinkGroup();
                        
                        // Create a LinkList inside the tmpLinkGroup
                        tmp1Lg.LinkList = new QESUnitySuperLinkWebServices.LinkList_element();
                        tmp1Lg.LinkList.link = 
                                    new List<QESUnitySuperLinkWebServices.Link>();
                        for(Integer k = 0; k < 10; j++) {
                            QESUnitySuperLinkWebServices.Link tmpLink =
                                    new QESUnitySuperLinkWebServices.Link();
                            tmpLink.LinkGuid = 'xxxxxxxxxx';
                            tmpLink.LinkId = 'xxxxxxxxxx';
                            tmpLink.LinkURL = 'http://www.qualcomm.com';
                            tmpLink.Title = 'xxxxxxxxxx';
                            tmpLink.Body = 'xxxxxxxxxx';
                            tmpLink.IconURL = 'http://www.qualcomm.com';
                            tmpLink.LinkType = 'L';
                            tmpLink.AltText = 'xxxxxxxxxx';
                            tmpLink.LinkGroupGuid = 'xxxxxxxxxx';
                            tmpLink.LinkGroupId = 'xxxxxxxxxx';
                            
                            if(0 == k) {
                                tmpLink.LinkType = 'G';
                            }
                            if(1 == k) {
                                tmpLink.LinkURL = 'http://www.qualcomm.com/support';
                            }                               
                            
                            tmp1Lg.LinkList.link.add(tmpLink);       
                        }
                        
                        tmpLg.LinkGroupList.linkGroup.add(tmp1Lg);                                  
                    }           
                }               
            }           
            */
            LinkGroupList.linkGroup.add(tmpLg);                                 
        }
        
        // LinkGroupList prepared
        QESUnityWebServicesResponseParser.parseLinkGroupList(LinkGroupList, QESUnityWebServicesResponseParser.MENU_LINKS_TYPE, NULL, false);
        QESUnityWebServicesResponseParser.parseLinkGroupList(LinkGroupList, QESUnityWebServicesResponseParser.MENU_LINKS_TYPE, NULL, true);
        QESUnityWebServicesResponseParser.parseLinkGroupList(LinkGroupList, QESUnityWebServicesResponseParser.MENU_LINKS_TYPE, 'support', false);
        QESUnityWebServicesResponseParser.parseLinkGroupList(LinkGroupList, QESUnityWebServicesResponseParser.MENU_LINKS_TYPE, 'support', true);
        
        QESUnityWebServicesResponseParser.parseLinkGroupList(LinkGroupList, QESUnityWebServicesResponseParser.QUICK_LINKS_TYPE, NULL, false);
        QESUnityWebServicesResponseParser.parseLinkGroupList(LinkGroupList, QESUnityWebServicesResponseParser.USER_PROFILE_TYPE, NULL, false);      
    }
}