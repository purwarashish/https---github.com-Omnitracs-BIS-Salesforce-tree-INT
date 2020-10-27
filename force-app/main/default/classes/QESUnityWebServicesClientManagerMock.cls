@isTest
global class QESUnityWebServicesClientManagerMock implements WebServiceMock{
    
    global void doInvoke(
        
        Object stub,
        
        Object request,
        
        Map<String, Object> response,
        
        String endpoint,
        
        String soapAction,
        
        String requestName,
        
        String responseNS,
        
        String responseName,
        
        String responseType) 
    {
        
        if(request instanceof QESUnitySuperLinkWebServices.MyActiveLinksByGroupInput)
            response.put('response_x', new QESUnitySuperLinkWebServices.getMyActiveLinksByGroupResponse());
        return;
    }
    
}