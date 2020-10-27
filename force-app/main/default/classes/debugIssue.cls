public class debugIssue{
public string res{set;get;}{res='';}

public debugIssue(){
                QESUnitySuperLinkWebServices.LinkServiceSoapImplPort port = null;    
                QESUnitySuperLinkWebServices.standardResponse response = null;
                QESUnitySuperLinkWebServices.Link[] LinkList = null;   
                Integer retries = 1;        
                port = new QESUnitySuperLinkWebServices.LinkServiceSoapImplPort();
                String authorization = EncodingUtil.base64Encode(
                                       Blob.valueOf(System.Label.UnamePwdLinkWebservice));
                System.debug('@@@@@@@@..' + authorization);
                port.inputHttpHeaders_x = new Map<String, String>();
                port.inputHttpHeaders_x.put('Authorization', 'Basic ' + authorization);
                
                //if(null != platformAppGroupId) {
                    //response = port.getActiveLinksByGroup(platformAppGroupId, 'Y');
                    response = port.getMyActiveLinksByGroup('SUP_HOME_TOP_KB', 'E917091DDB8056BCE0437A01EC0ABFDC', 'Y');
                    system.debug('--response1--'+response);
                    res = response.toString();
                        
                //}
                /*else {
                    //response = port.getActiveLinksByGroup('SUP_HOME_TOP_KB', 'Y');
                    response = port.getMyActiveLinksByGroup('SUP_HOME_TOP_KB', 'E917091DDB8056BCE0437A01EC0ABFDC', 'Y');
                    system.debug('--response2--'+response);
                    
                }*/
                
                // Fault Handling
                if( (null == response) || ('SUCCESS' != response.status) ) {
                    String errorMessage = '';
                    if(null == response) {
                        errorMessage += 'WebService Callout returned "null"';
                    }
                    else {
                        errorMessage += response.message;
                    }
                    System.debug(LoggingLevel.ERROR, errorMessage);
                }
}

}