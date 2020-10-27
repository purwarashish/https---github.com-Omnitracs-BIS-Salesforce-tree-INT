@isTest
global class QCSDASDeviceQueryMock implements WebServiceMock{
    
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
        
        if(request instanceof QCSDASDeviceQuery.FidoDataWebServicePort)
            response.put('response_x', new QCSDASDeviceQuery.FidoDataWebServicePort());
           System.debug('response of Mock class ********'+response.get('response_x'));
        return;
    }
    
}