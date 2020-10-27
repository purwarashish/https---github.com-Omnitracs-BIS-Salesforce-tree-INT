public class QCSDeviceSearchController
{
    public String deviceId {get;set;}
    public String deviceIdForSevice {get;set;}    
    
    //Helper Attributes
    public Boolean hasResults {get;set;}{hasResults = false;}
    public Boolean validationErrors {get;set;}
    public Boolean isDeviceIdEmpty {get;set;}{isDeviceIdEmpty = true;}
     
    //Device Attributes
    public List<QcsDevice> deviceDetailLst {get;set;}
    public QcsDevice deviceDetail {get;set;}
    public Boolean isTestContext {get;set;}{isTestContext = false;}
    public pageReference doDeviceSearch()
    {       
        validationErrors = false;               
        processFormValidation();
        system.debug('Validation_Errors:'+validationErrors);
        if(validationErrors == false)
        {   
            deviceDetailLst = new List<QcsDevice>();
            deviceDetail = new QcsDevice();
            
            //device is in correct format. Call the DPC web service methods
          
            qcsDpcDevicequery.DeviceQueryPortTypeSoap11 DpcRequest  = new qcsDpcDevicequery.DeviceQueryPortTypeSoap11();
            qcsDpcDevicequery.deviceRecordType  findDevice = new qcsDpcDevicequery.deviceRecordType();
            findDevice.deviceId = deviceIdForSevice;
            DpcRequest.timeout_x = 60000;
            
            qcsDpcDevicequery.GetAttributeResponse_element DpcResponse = new qcsDpcDevicequery.GetAttributeResponse_element();
            
            //invoke getAttibute method of DPC web service. 
            try
            {  
               if(!isTestContext){
                  DpcResponse = DpcRequest.GetAttribute(findDevice);
               }
            }
            catch(Exception e)
            {
                system.debug('Exception occured'+e);
                hasResults = false;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Communication with DPC (Device Provisioning and Configuration) cannot be established. Please try again.',''));                       
                ErrorUtils.handleError(e);
                return null;                        
            }
           
            //process DPC response
             if(!isTestContext){
              deviceDetail.result = DpcResponse.result;
             }
            deviceDetail.DeviceId = deviceId;

            List<QcsDpcDevicequery.getDeviceRecordType> deviceRecord = DpcResponse.deviceRecord;
                                 
            deviceDetail=getDeviceDetails(deviceDetail,deviceRecord);
            deviceDetailLst.add(deviceDetail);
        }
        
        return null;
    }  
    
    public QcsDevice getDeviceDetails(QcsDevice deviceDetail,List<QcsDpcDevicequery.getDeviceRecordType> deviceRecord){
      if(deviceDetail.result == 'SUCCESS')  
            {
                hasResults = True;
                for(Integer i= 0;i<deviceRecord.size();i++)
                {
                    List<QcsDpcDevicequery.getAttributeParamType> deviceParameters = deviceRecord[i].AttributeParam;
                    system.debug('Device Type--'+deviceRecord[i].deviceType);
                    deviceDetail.deviceType = deviceRecord[i].deviceType;
                    system.debug(deviceDetail);
                    system.debug('deviceParameters -->'+deviceParameters);
                    Integer deviceParametersSize=0;
                    if(deviceParameters!=null){
                       deviceParametersSize = deviceParameters.size();
                    }
                    for(Integer j=0;j<deviceParametersSize;j++)
                    {
                        
                       QcsDpcDevicequery.KitIDAttribType KitID = deviceParameters[j].KitId ;        
                        if(KitID!=null)                        
                            deviceDetail.KitId = KitID.Value;
                        
                        QcsDpcDevicequery.ftdComponentSWVersionsAttribute ftdComponentSWVersionsAttrib = deviceParameters[j].ftdComponentSWVersionAttrib;
                        system.debug('FtdComponentSWAttribute-->'+ftdComponentSWVersionsAttrib);
                        if(ftdComponentSWVersionsAttrib!=null)
                        {
                            QcsDpcDevicequery.ftdSRRSWVersionAttribType ftdSRRSWVersion = ftdComponentSWVersionsAttrib.ftdSRRSWVersion;
                            deviceDetail.ftdSRR = ftdSRRSWVersion.value;
                            QcsDpcDevicequery.fcaSWVersionAttribType fcaSWVersion = ftdComponentSWVersionsAttrib.fcaSWVersion;
                            deviceDetail.ftdClientApp = fcaSWVersion.Value;
                        }
                        
                        QcsDpcDevicequery.fbcComponentSWVersionsAttribute fbcComponentSWVersionAttrib = deviceParameters[j].fbcComponentSWVersionAttrib;
                        if(fbcComponentSWVersionAttrib!=null)
                        {
                            QcsDpcDevicequery.fbcSRRSWVersionAttribType fbcSRRSWVersion = fbcComponentSWVersionAttrib.fbcSRRSWVersion;
                            deviceDetail.fbcSRR = fbcSRRSWVersion.Value;
                        }
                        QcsDpcDevicequery.ftdWirelessNetworkStateAttribType ftdWirelessNetworkState = deviceParameters[j].ftdWirelessNetworkState ;
                        if(ftdWirelessNetworkState!=null)
                        deviceDetail.networkState = ftdWirelessNetworkState.Value;
                        
                        QcsDpcDevicequery.ftdHardwareVersionAttribType ftdHardwareVersionAttrib = deviceParameters[j].ftdHardwareVersionAttrib;
                        if(ftdHardwareVersionAttrib!=null)
                        deviceDetail.ftdMCN =  ftdHardwareVersionAttrib.Value;
                        
                        QcsDpcDevicequery.ftdSerialNumberAttribType ftdSerialNumberAttrib = deviceParameters[j].ftdSerialNumberAttrib;
                        if(ftdSerialNumberAttrib!=null)
                        deviceDetail.ftdMFG = ftdSerialNumberAttrib.Value;
                        
                        QcsDpcDevicequery.fbcHardwareVersionAttribType fbcHardwareVersionAttrib = deviceParameters[j].fbcHardwareVersionAttrib;
                        if(fbcHardwareVersionAttrib!=null)
                        deviceDetail.fbcMCN = fbcHardwareVersionAttrib.Value;
                        
                        QcsDpcDevicequery.fbcSerialNumberAttribType fbcSerialNumberAttrib = deviceParameters[j].fbcSerialNumberAttrib;
                        if(fbcSerialNumberAttrib!=null)
                        deviceDetail.fbcMFG = fbcSerialNumberAttrib.Value;
                         
                        QcsDpcDevicequery.ftdDvcActivatableStateAttribType ftdActivatableState = deviceParameters[j].ftdActivatableState;
                        if(ftdActivatableState!=null)
                        deviceDetail.eligibleForActivation = ftdActivatableState.Value;
                                                                
                    }
                    system.debug('elemts -->'+i);
                }
                
                //if device is FTD, invoke DAS to get device state details
                if(deviceDetail.deviceType == 'TRACKER')
                {
                    QcsDasDeviceQuery.FidoDataWebServicePort requestDAS = new QcsDasDeviceQuery.FidoDataWebServicePort();
                    try
                    {
                        QcsDasCommonTypes.getDeviceStateResponse_element DASdetails = requestDAS.getDeviceState(deviceIdForSevice,'');                        
                        if(DASdetails!=null)
                        {
                            deviceDetail.deviceServiceState = DASdetails.serviceState;
                            deviceDetail.deviceSecurityState  = DASdetails.securityState;
                            deviceDetail.deviceReachabilityState  = DASdetails.reachableState; 
                            system.debug('DAS Details-->'+DASdetails);  
                           
                        }
                         
                    }
                    catch(System.CalloutException e)
                    {
                        hasResults = false;
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Communication with DAS (Device Application Server) cannot be established. Please try again.',''));                       
                        ErrorUtils.handleError(e);
                        return null;                        
                    }
                    
                }
                return deviceDetail;
            }
            else
            {                
                system.debug('Device ID can not be found');                                  
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Device ID cannot be found',''));                       
                return null;                
            }   
      
    }

    public void doClear()
    {
        isDeviceIdEmpty = true;
        hasResults = false;
        deviceId='';
                
    }
    
    public void processFormValidation()
    {   
      isDeviceIdEmpty = false;     
        if(deviceId == null || deviceId.trim()=='')
        {
             
             system.debug('Please enter Device ID to perform a search');                                  
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter Device ID to perform a search',''));                       
             validationErrors = true;
             isDeviceIdEmpty = true;
        }       
        else
        {
          deviceIdForSevice = DeviceId.trim();
          system.debug('Device Id =='+ deviceIdForSevice);          
          deviceIdForSevice = deviceIdForSevice.replaceAll('-','');
          system.debug('Device Id after strip =='+ deviceIdForSevice);
          if(deviceIdForSevice.length()!=9 || !pattern.matches('^[a-zA-Z]+$',deviceIdForSevice))
          {
          
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter a valid Device ID',''));
              validationErrors = true;
          } 
            
        }       
    } 
       
}