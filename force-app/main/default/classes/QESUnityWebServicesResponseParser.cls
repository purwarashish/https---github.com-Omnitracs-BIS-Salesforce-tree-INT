/**
 * @description Class that provides static methods for parsing the entire
 * LinkGroup List received in a response from the WS call made
 * to the SuperLink WS-methods get<type>LinksByGroup()
 * @author Pratyush Kumar
 * @date October 3, 2011
 */
public class QESUnityWebServicesResponseParser {
    /**
     * @desciption Link Type for the Menu-Headers
     */
    public static final Integer MENU_LINKS_TYPE = 0;

    /**
     * @desciption Link Type for the Quicklinks
     */
    public static final Integer QUICK_LINKS_TYPE = 1;
    
    /**
     * @desciption Link Type for the UserProfileData
     */    
    public static final Integer USER_PROFILE_TYPE = 2;

    /**
     * @description Method to parse a LinkGroupList and return the corresponding HTML
     * in <ul><li><ul><li></li></ul></li></ul> notation
     * @param LinkGroupList A LinkGroupList object of the type 
     *  QESUnitySuperLinkWebServices.LinkGroupList_element
     * @param LinkTypes Type of LinkGroupList - MENU_LINKS_TYPE, QUICK_LINKS_TYPE, USER_PROFILE_TYPE
     * @param Boolean True if LinkGroupId has to be appended, false otherwise
     * @return String HTML in <ul><li><ul><li></li></ul></li></ul> notation
     */
    public static String parseLinkGroupList(QESUnitySuperLinkWebServices.LinkGroupList_element LinkGroupList,
                                            Integer linkType, String className, Boolean addLinkGroupId) {
        String str = '';
        if(null == LinkGroupList || null == LinkGroupList.LinkGroup) {
            return('');
        }

        for(integer i = 0; i < LinkGroupList.LinkGroup.size(); i++) {

            if( (null != LinkGroupList.LinkGroup[i].LinkList) && 
                (null != LinkGroupList.LinkGroup[i].LinkList.link) ) {
                LinkGroupList.LinkGroup[i].LinkList.link = 
                               mergeSortLinkList(LinkGroupList.LinkGroup[i].LinkList.Link,
                                                 0, 
                                                 LinkGroupList.LinkGroup[i].LinkList.Link.size() - 1);
            }                

            if(MENU_LINKS_TYPE == linkType){
                str = str + parseLinkGroup(LinkGroupList.LinkGroup[i], 
                                           MENU_LINKS_TYPE, 
                                           className, 
                                           addLinkGroupId);
            }
            else if(QUICK_LINKS_TYPE == linkType) {
                str = str + parseQuickLink(LinkGroupList.LinkGroup[i], 
                                           QUICK_LINKS_TYPE, 
                                           className);
            }
            else if(USER_PROFILE_TYPE == linkType) {
                str = str + parseUserProfileLinkGroup(LinkGroupList.LinkGroup[i], 
                                                      QUICK_LINKS_TYPE, 
                                                      className);
            }
        }

        return str;
    }

    /**
     * @description Recursive method to sort a LinkedList using MergeSort. The sorting
     * is done based on the sortOrder specified for each of the Links in th list.
     * @param LinkList List of Links that need to be sorted. The startIndex and
     *  the endIndex define the window in the list tha need to be sorted.
     * @param startIndex The starting-index in the list 
     * @param endIndex The end-index in the list
     * @return QESUnitySuperLinkWebServices.link[] The sorted list.
     */
    public static QESUnitySuperLinkWebServices.link[] 
    mergeSortLinkList(QESUnitySuperLinkWebServices.link[] LinkList, 
                      Integer startIndex, 
                      Integer endIndex) {

        Integer middleIndex = -1;
        
        if( (null == LinkList) || (1 >= LinkList.size()) ) {
            return LinkList;
        }
        if(startIndex >= endIndex) {
            // List is sorted
            return LinkList;
        }
        
        middleIndex = (startIndex + endIndex) / 2;
         
        mergeSortLinkList(LinkList, startIndex, middleIndex);
        mergeSortLinkList(LinkList, middleIndex + 1, endIndex);        
        return mergeLinkLists(LinkList, startIndex, middleIndex, endIndex);    
    }

    /*------------------------ PRIVATE MEMBERS ---------------------------*/

    /**
     * @description Method to parse a LinkGroup and return the corresponding HTML
     * in <ul><li><ul><li></li></ul></li></ul> notation
     * @param LinkGroup A LinkGroupList object of the type 
     *  QESUnitySuperLinkWebServices.linkGroup
     * @param LinkTypes Type of LinkGroupList - MENU_LINKS_TYPE, QUICK_LINKS_TYPE, USER_PROFILE_TYPE
     * @param className The HTML class-name that need t be appended while generating the HTML
     * @param Boolean True if LinkGroupId has to be appended, false otherwise     
     * @return String HTML in <ul><li><ul><li></li></ul></li></ul> notation
     */
    private static String parseLinkGroup(QESUnitySuperLinkWebServices.linkGroup LinkGroup,
                                        Integer linkType, String className, boolean addLinkGroupId) {
        String str = '';
        boolean blnContainsGroupLinkType = false;
        boolean blnLiStarted = false;

        if(null == LinkGroup || (null == LinkGroup.LinkList && null == LinkGroup.LinkGroupList)) {
            return '';
        }
    

        String linkGroupHref = '';
        
        if(null != LinkGroup.LinkList && null != LinkGroup.LinkList.Link) {
            for(integer i = 0; i < LinkGroup.LinkList.Link.size(); i++) {
                if('G' == LinkGroup.LinkList.Link[i].LinkType) {
                    blnContainsGroupLinkType = true;
                    if( (null != LinkGroup.LinkList.Link[i].LinkUrl) &&
                        ('' != LinkGroup.LinkList.Link[i].LinkUrl.trim()) ) {
                        //Change for CR 64185
                       /* if('support' == className ) {
                            
                            Integer index = LinkGroup.LinkList.Link[i].LinkUrl.indexOf('//', 0);
                            if(-1 == index) {
                                linkGroupHref = 'href="' + LinkGroup.LinkList.Link[i].LinkUrl + '"';
                                blnContainsGroupLinkType = true;
                            }
                            else {
                                index = LinkGroup.LinkList.Link[i].LinkUrl.indexOf('/', index + 2);
                                if(-1 == index) {
                                    linkGroupHref = 'href="' + LinkGroup.LinkList.Link[i].LinkUrl + '"';
                                    blnContainsGroupLinkType = true;
                                }
                                else {
                                    
                                    linkGroupHref = 'href="/apex' +
                                                    LinkGroup.LinkList.Link[i].LinkUrl.subString(index,  
                                                    LinkGroup.LinkList.Link[i].LinkUrl.length()) +
                                                    '"';
                                                
                                    blnContainsGroupLinkType = true;
                                }
                            }
                        } // End - if( 'support' == className)
                        else {
                            linkGroupHref = 'href="' + LinkGroup.LinkList.Link[i].LinkUrl + '"';
                            blnContainsGroupLinkType = true;
                        }                        */
                        
                        linkGroupHref = 'href="' + LinkGroup.LinkList.Link[i].LinkUrl + '"';
                        blnContainsGroupLinkType = true;
                    }

                    if(addLinkGroupId) {
                        str = str + '<li>';
                        str = str + '<a id="id1" ' + linkGroupHref + '>' +
                              + LinkGroup.LinkList.Link[i].Title.replace('\'', '\\\'') + '</a>';
                    }
                    else {
                        str = str + '<li>';
                        str = str + '<a id="linkGroupLinkList' + LinkGroup.LinkList.Link[i].LinkGuid + 
                                    '" class="' + className + '" ' + linkGroupHref + '></a>';
                    }
                    blnLiStarted = true; 
System.debug('*************** str' + str);           
            
                    break;
                } // End - if ('G' == '')
            }
        }

        if( blnContainsGroupLinkType && (1 != LinkGroup.LinkList.Link.size()) ) {
            str = str + '<ul>';
        }
        
        if(null != LinkGroup.LinkList && null != LinkGroup.LinkList.Link) {
            for(integer i = 0; i < LinkGroup.LinkList.Link.size(); i++) {
                if( (null != LinkGroup.LinkList.Link[i].LinkType) &&
                    ('G' == LinkGroup.LinkList.Link[i].LinkType) ) {
                    continue;
                }
                String linkUrl = '';
                //Change for CR 64185
                /*if('support' == className && LinkGroup.LinkList.Link[i].LinkUrl.contains('salesforce.com')) {
                    if(null != LinkGroup.LinkList.Link[i].LinkUrl) {
                        Integer index = LinkGroup.LinkList.Link[i].LinkUrl.indexOf('//', 0);
                        if(-1 == index) {
                            linkUrl = LinkGroup.LinkList.Link[i].LinkUrl;
                        }
                        else {
                            index = LinkGroup.LinkList.Link[i].LinkUrl.indexOf('/', index + 2);
                            if(-1 == index) {
                                linkUrl = LinkGroup.LinkList.Link[i].LinkUrl;
                            }
                            else {
                                
                                //Change for CR 64185
                                if(LinkGroup.LinkList.Link[i].LinkUrl.contains('salesforce.com') && !LinkGroup.LinkList.Link[i].LinkUrl.contains('/apex'))
                                linkUrl = '/apex' + LinkGroup.LinkList.Link[i].LinkUrl.subString(index,  
                                                    LinkGroup.LinkList.Link[i].LinkUrl.length());
                                else
                                linkUrl =  LinkGroup.LinkList.Link[i].LinkUrl.subString(index,  
                                                    LinkGroup.LinkList.Link[i].LinkUrl.length());                    
                            }
                        }
                    }
                }
                else {
                    linkUrl = LinkGroup.LinkList.Link[i].LinkUrl;
                }*/
                 linkUrl = LinkGroup.LinkList.Link[i].LinkUrl;
                str = str + '<li>';
                str = str + '<a class="me1"  id="linkGroupLinkList' + LinkGroup.LinkList.Link[i].LinkGuid + '" ';
                if(null != LinkGroup.LinkList.Link[i].LinkUrl) {
                    str = str + 'href="' + linkUrl + '"';
                }
                str = str + '>' + LinkGroup.LinkList.Link[i].Title.replace('\'', '\\\'') + '</a>';
                str = str + '</li>';
            }
        }

        if(null != LinkGroup.LinkGroupList && null != LinkGroup.LinkGroupList.LinkGroup) {
            if( blnContainsGroupLinkType && (1 == LinkGroup.LinkList.Link.size()) ) {
                if(!blnLiStarted) {
                    str = str + '<li>';
                    blnLiStarted = true;
                }
                str = str + '<ul>';
            }
            //if(!blnLiStarted) {
            //    str = str + '<li>';
            //    blnLiStarted = true;
            //}
            
            str = str + parseLinkGroupList(LinkGroup.LinkGroupList, linkType, className, true);

            if( blnContainsGroupLinkType && (1 == LinkGroup.LinkList.Link.size()) ) {
                str = str + '</ul>';
            }            
        }
        if( blnContainsGroupLinkType && (1 != LinkGroup.LinkList.Link.size()) ) {
            str = str + '</ul>';
        }

        if(blnLiStarted) {
            str += '</li>';
        }
        return str;
    }

     /**
     * @description Method to parse the QuickLinks and return the corresponding HTML
     * in <ul><li><ul><li></li></ul></li></ul> notation
     * @param LinkGroup A LinkGroupList object of the type QESUnitySuperLinkWebServices.linkGroup
     * @param LinkTypes Type of LinkGroupList - MENU_LINKS_TYPE, QUICK_LINKS_TYPE, USER_PROFILE_TYPE
     * @param className The HTML class-name that need t be appended while generating the HTML
     * @return String HTML in <ul><li><ul><li></li></ul></li></ul> notation
     */
    private static String parseQuickLink(QESUnitySuperLinkWebServices.linkGroup LinkGroup,
                                        integer linkType, String className) {
        String str = '';
        String GrpID = '';
        boolean setClosingUlTag = false;

        if(null == LinkGroup || (null == LinkGroup.LinkList && null == LinkGroup.LinkGroupList)) {
            return '';
        }
        
        if(null != LinkGroup.LinkList && null != LinkGroup.LinkList.Link) {
            setClosingUlTag = true;

            str = str + '<li>';
            for(integer i = 0; i < LinkGroup.LinkList.Link.size(); i++) {
                if( (null != LinkGroup.LinkList.Link[i].LinkType) &&
                    ('G' == LinkGroup.LinkList.Link[i].LinkType) ) {
                    str = str + '<a><span>'+ LinkGroup.LinkList.Link[i].Title.replace('\'', '\\\'') +'</span></a>';
                    break;
                }
            }
            
            str = str + '<ul class="sub_menu2">';
            for(integer i = 0; i < LinkGroup.LinkList.Link.size(); i++) {
                if( (null != LinkGroup.LinkList.Link[i].LinkType) &&
                    ('G' == LinkGroup.LinkList.Link[i].LinkType) ) {
                    continue;
                }                
                str = str + '<li>';
                str = str + '<a class="redirectTo" id="id4" ';
                if(null != LinkGroup.LinkList.Link[i].LinkUrl) {
                    str = str + 'href="' + LinkGroup.LinkList.Link[i].LinkUrl + '"';
                }
                str = str + '>' + LinkGroup.LinkList.Link[i].Title.replace('\'', '\\\'') + '</a>';
                str = str + '</li>';
            }
            str = str + '</ul>';
        }

        if(null != LinkGroup.LinkGroupList && null != LinkGroup.LinkGroupList.LinkGroup) {
            if(!setClosingUlTag) {
                setClosingUlTag = true;
                str = str + '<li>';
                str = str + '<a><span>'+ GrpId +'</span></a>';
            }
            str = str + '<ul>';
            str = str + parseLinkGroupList(LinkGroup.LinkGroupList,linkType, className, true);
            str = str + '</ul>';
        }

        if(setClosingUlTag) {
            str = str + '</li>';
        }

        return str;
    }
    
    /**
     * @description Method to parse a LinkList and return the corresponding HTML
     * in <ul><li><ul><li></li></ul></li></ul> notation
     * @param LinkList A LinkList object of the type QESUnitySuperLinkWebServices.LinkList_element
     * @param LinkTypes Type of LinkGroupList - MENU_LINKS_TYPE, QUICK_LINKS_TYPE, USER_PROFILE_TYPE
     * @param className The HTML class-name that need t be appended while generating the HTML      
     * @return String HTML in <ul><li><ul><li></li></ul></li></ul> notation
     */
    private static String parseUserProfileLinkGroup(QESUnitySuperLinkWebServices.linkGroup LinkGroup,
                                                   integer linkType, String className) {
        String str = '';
        
        if(null == LinkGroup.LinkList || null == LinkGroup.LinkList.Link) {
            return '';
        }

        for(integer i = 0; i < LinkGroup.LinkList.Link.size(); i++) {
            if( (null == LinkGroup.LinkList.Link[i].LinkType) ||
                ('G' == LinkGroup.LinkList.Link[i].LinkType) ) {
                continue;
            }
            str = str + '<li>';
            str = str + '<a class="redirectTo" id="id5" ';
            if(null != LinkGroup.LinkList.Link[i].LinkUrl) {
                str = str + 'href="' + LinkGroup.LinkList.Link[i].LinkUrl + '"';
            }
            str = str + '>' + LinkGroup.LinkList.Link[i].Title.replace('\'', '\\\'') + '</a>';
            str = str + '</li>';
        }
        
        return str;
    }   

    /**
     * @description Method to merge the 2 sorted section of a LinkList. It does
     * not implement complete in-place sorting. Consequently, the space-complexity
     * would be a little higher, but the time complexity would be the same. Since,
     * we do not have more than 20 values in a list, we decided to avoid in-place
     * sorting to reduce the complexity of coding.
     * @param LinkList The list whose sections have to be merged.
     * @param startIndex The startIndex of the first-section
     * @param middleIndex The index that marks the start of the second-section
     * @param endIndex The index that marks the end of the second-section
     * @return A new list that consists of both the sections merged and sorted.
     */        
    private static QESUnitySuperLinkWebServices.link[] 
        mergeLinkLists(QESUnitySuperLinkWebServices.link[] LinkList,
                       Integer startIndex,
                       Integer middleIndex,
                       Integer endIndex)
    {
        QESUnitySuperLinkWebServices.link[] tmpList = 
             new QESUnitySuperLinkWebServices.link[LinkList.size()];        
        Integer x = startIndex;
        Integer y = middleIndex + 1;
        Integer z = startIndex;

        // Copy all the items to the tmpList        
        for(Integer m = startIndex; m <= endIndex; m++) {
            tmpList.add(m, LinkList[m]);
        }
        
        // Compare the items in the 2 sections and accordingly 
        // replace them in the existing list
        while( (x <= middleIndex) && (y <= endIndex) ) {
            if(tmpList[x].sortOrder <= tmpList[y].sortOrder) {
                LinkList[z] = tmpList[x];
                x++;
            }
            else {
                LinkList[z] = tmpList[y];
                y++;
            }
            z++;
        }
        
        // Copy all the left-over items in the 1st section
        while(x <= middleIndex) {
            LinkList[z] = tmpList[x];
            x++;
            z++;
        }

        // Copy all the left-over items in the 2st section        
        while(y <= endIndex) {
            LinkList[z] = tmpList[y];
            y++;
            z++;
        }
        tmpList = null;
        return LinkList;
    }    
}