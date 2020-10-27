// This class contains unit tests for QCSDeviceSearchController
@isTest(seeAllData = true)
private class TestQCSDDIClasses{
    
    private static testmethod void testQcsDasCommonTypes()
    {
        QcsDasCommonTypes testDasCommonTypeRoot = new QcsDasCommonTypes();
        QcsDasCommonTypes.getDeviceStateRequest_element deviceRequestObj = new QcsDasCommonTypes.getDeviceStateRequest_element();       
        QcsDasCommonTypes.getDeviceStateResponse_element deviceResponseObj = new QcsDasCommonTypes.getDeviceStateResponse_element(); 
    }
    
    private static testmethod void testQcsDpcCommonTypes()
    {
        QCSDPCCommonTypes testDpcCommonType = new QCSDPCCommonTypes();
        QcsDpcCommonTypes.DeviceUpgrade d = new  QcsDpcCommonTypes.DeviceUpgrade();
        QcsDpcCommonTypes.DeviceUpgradeStateParam p = new  QcsDpcCommonTypes.DeviceUpgradeStateParam ();
        QcsDpcCommonTypes.DeviceUpgradeState s = new  QcsDpcCommonTypes.DeviceUpgradeState ();
        QcsDpcCommonTypes.DeviceUpgradeParam up = new  QcsDpcCommonTypes.DeviceUpgradeParam ();
        QcsDpcCommonTypes.DeviceChargerUpgradeState  cus= new  QcsDpcCommonTypes.DeviceChargerUpgradeState  ();
        QcsDpcCommonTypes.DeviceChargerUpgrade dcu = new  QcsDpcCommonTypes.DeviceChargerUpgrade ();
        QcsDpcCommonTypes.DeviceUpgradeTracker dut = new  QcsDpcCommonTypes.DeviceUpgradeTracker ();
        QcsDpcCommonTypes.FtdComponentSoftware fcs = new  QcsDpcCommonTypes.FtdComponentSoftware ();
        QcsDpcCommonTypes.FbcComponentSoftware fbs = new  QcsDpcCommonTypes.FbcComponentSoftware ();
        QcsDpcCommonTypes.DeviceChargerUpgradeStateParam dcus = new  QcsDpcCommonTypes.DeviceChargerUpgradeStateParam ();
        
        
    }
    
    /*private static testmethod void testQcsDasDeviceQuery()
{
QcsDasDeviceQuery deviceQueryObj = new QcsDasDeviceQuery();
QcsDasDeviceQuery.FidoDataWebServicePort port = new QcsDasDeviceQuery.FidoDataWebServicePort();
// port.isTestContext = true;
QcsDasCommonTypes.getDeviceStateResponse_element responseObj = new QcsDasCommonTypes.getDeviceStateResponse_element(); 
responseObj = port.getDeviceState('cdxxxxxxx','');
}*/
    
    private static testmethod void testQcsDpcDeviceQuery(){
        QcsDpcDeviceQuery.deviceInfoType deviceInfo;
        QcsDpcDeviceQuery.setAttributeParamType[] AttributeParam;
        QcsDpcDeviceQuery.fbcComponentSWVersionsAttribute fbcSW = new QcsDpcDeviceQuery.fbcComponentSWVersionsAttribute();
        QcsDpcDeviceQuery.getDeviceRecordType gdrt = new QcsDpcDeviceQuery.getDeviceRecordType ();
        QcsDpcDeviceQuery.GetAssociatedDevicesRequest_element gad = new QcsDpcDeviceQuery.GetAssociatedDevicesRequest_element();
        QcsDpcDeviceQuery.devicesType dt = new QcsDpcDeviceQuery.devicesType ();
        QcsDpcDeviceQuery.SetBulkAttributeRequest_element sba = new QcsDpcDeviceQuery.SetBulkAttributeRequest_element();
        QcsDpcDeviceQuery.ftdSRRSWVersionAttribType ftdSW = new QcsDpcDeviceQuery.ftdSRRSWVersionAttribType ();
        QcsDpcDeviceQuery.GetAssociatedDevicesResponse_element gadr = new QcsDpcDeviceQuery.GetAssociatedDevicesResponse_element ();
        QcsDpcDeviceQuery.GetUnassociatedDevicesRequest_element udr = new QcsDpcDeviceQuery.GetUnassociatedDevicesRequest_element();
        QcsDpcDeviceQuery.ftdDvcActivatableStateAttribType ftdDvc = new QcsDpcDeviceQuery.ftdDvcActivatableStateAttribType ();
        QcsDpcDeviceQuery.getAttributeParamType gapt = new QcsDpcDeviceQuery.getAttributeParamType ();
        QcsDpcDeviceQuery.ftdUpgradePkgVersionAttribType fup = new QcsDpcDeviceQuery.ftdUpgradePkgVersionAttribType ();
        QcsDpcDeviceQuery.ftdSerialNumberAttribType ftds = new QcsDpcDeviceQuery.ftdSerialNumberAttribType ();
        QcsDpcDeviceQuery.deviceRecordType drt = new QcsDpcDeviceQuery.deviceRecordType ();
        QcsDpcDeviceQuery.GetAttributeResponse_element gart = new QcsDpcDeviceQuery.GetAttributeResponse_element ();
        QcsDpcDeviceQuery.setDeviceRecordType sdrt = new QcsDpcDeviceQuery.setDeviceRecordType ();
        QcsDpcDeviceQuery.fbcSerialNumberAttribType fbcSnat = new QcsDpcDeviceQuery.fbcSerialNumberAttribType ();
        QcsDpcDeviceQuery.ftdHardwareVersionAttribType ftdHw = new QcsDpcDeviceQuery.ftdHardwareVersionAttribType ();
        QcsDpcDeviceQuery.ftdWirelessNetworkStateAttribType ftdWnsat = new QcsDpcDeviceQuery.ftdWirelessNetworkStateAttribType ();
        QcsDpcDeviceQuery.BulkType bt = new QcsDpcDeviceQuery.BulkType ();
        QcsDpcDeviceQuery.fbcUpgradePkgVersionAttribType fbcUp = new QcsDpcDeviceQuery.fbcUpgradePkgVersionAttribType ();
        QcsDpcDeviceQuery.SetBulkAttributeResponse_element sbar = new QcsDpcDeviceQuery.SetBulkAttributeResponse_element();
        QcsDpcDeviceQuery.fcaSWVersionAttribType fcaSw = new QcsDpcDeviceQuery.fcaSWVersionAttribType ();
        QcsDpcDeviceQuery.DeviceQueryPortTypeSoap11 dQp = new QcsDpcDeviceQuery.DeviceQueryPortTypeSoap11 ();
        QcsDpcDeviceQuery.GetUnassociatedDevicesResponse_element gudr = new QcsDpcDeviceQuery.GetUnassociatedDevicesResponse_element();
        QcsDpcDeviceQuery.setAttributeParamType sapt = new QcsDpcDeviceQuery.setAttributeParamType ();
        QcsDpcDeviceQuery.GetAttributeRequest_element gare = new QcsDpcDeviceQuery.GetAttributeRequest_element ();
        QcsDpcDeviceQuery.GetAssociatedKitIdRequest_element gakir = new QcsDpcDeviceQuery.GetAssociatedKitIdRequest_element ();
        QcsDpcDeviceQuery.KitIDAttribType kiat = new QcsDpcDeviceQuery.KitIDAttribType ();
        QcsDpcDeviceQuery.ftdBrewPkgVersionAttribType fbpvat = new QcsDpcDeviceQuery.ftdBrewPkgVersionAttribType ();
        QcsDpcDeviceQuery.ftdComponentSWVersionsAttribute fcsva = new QcsDpcDeviceQuery.ftdComponentSWVersionsAttribute ();
        QcsDpcDeviceQuery.GetAssociatedKitIdResponse_element gakire = new QcsDpcDeviceQuery.GetAssociatedKitIdResponse_element ();
        QcsDpcDeviceQuery.ftdFotaPkgVersionAttribType ffpvat = new QcsDpcDeviceQuery.ftdFotaPkgVersionAttribType ();
        QcsDpcDeviceQuery.fbcBrewPkgVersionAttribType fbcpvat = new QcsDpcDeviceQuery.fbcBrewPkgVersionAttribType ();
        QcsDpcDeviceQuery.fbcUpgradePkgVersionsAttribute fbcupva = new QcsDpcDeviceQuery.fbcUpgradePkgVersionsAttribute ();
        QcsDpcDeviceQuery.ftdUpgradePkgVersionsAttribute ftdupva = new QcsDpcDeviceQuery.ftdUpgradePkgVersionsAttribute ();
        QcsDpcDeviceQuery.fbcSRRSWVersionAttribType fssvat = new QcsDpcDeviceQuery.fbcSRRSWVersionAttribType ();
        QcsDpcDeviceQuery.deviceInfoType dit = new QcsDpcDeviceQuery.deviceInfoType ();
        QcsDpcDeviceQuery.fbcHardwareVersionAttribType fhvat = new QcsDpcDeviceQuery.fbcHardwareVersionAttribType ();         
    }
    
    private static testmethod void testQcsDeviceSearchSettings(){
        QcsDeviceSearchSettings.getInstance();            
        
    }
    
    private static testmethod void testQcsDevice(){
        QcsDevice qd = new QcsDevice();
        String tstresult = qd.result;
        String tstdeviceType = qd.deviceType; 
        String tstdeviceId = qd.deviceId; 
        String tstkitId = qd.kitId; 
        String tstftdClientApp = qd.ftdClientApp; 
        String tstftdSRR = qd.ftdSRR; 
        String tstfbcSRR = qd.fbcSRR; 
        String tstftdMCN = qd.ftdMCN; 
        String tstfbcMCN = qd.fbcMCN;
        String tstftdMFG = qd.ftdMFG;
        String tstfbcMFG = qd.fbcMFG;
        String tstnetworkState = qd.networkState;
        String tstdeviceServiceState = qd.deviceServiceState;
        String tstdeviceSecurityState = qd.deviceSecurityState;
        String tstdeviceReachabilityState = qd.deviceReachabilityState;
        String tsteligibleForActivation = qd.eligibleForActivation;       
    }
    
    private static testmethod void testQcsDeviceSearchControllernoDetails(){
        QcsDeviceSearchController qdsc = new QcsDeviceSearchController();
        qdsc.doDeviceSearch();
    }
    
    private static testmethod void testQcsDeviceSearchControllerNull(){
        QcsDeviceSearchController qdsc1 = new QcsDeviceSearchController();
        qdsc1.isTestContext=false;
        qdsc1.deviceId='AB-CDE-FGHI';
        qdsc1.doDeviceSearch();
    }
    
    private static testmethod void testQcsDeviceSearchCtnlrNotNull(){
        QcsDeviceSearchController qdsc1 = new QcsDeviceSearchController();
        qdsc1.isTestContext=true;
        qdsc1.deviceId='AB-CDE-FGHI';
        qdsc1.doDeviceSearch();
        qdsc1.doClear();
    }
    
    private static testmethod void testQcsDeviceSearchControllerNotNull(){
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new QCSDASDeviceQueryMock());
        QcsDeviceSearchController qdsc2 = new QcsDeviceSearchController();
        qdsc2.isTestContext=true;
        qdsc2.deviceId='AB-CDE-FGHI';   
        
        QcsDevice device = new QcsDevice();
        device.result='SUCCESS';
        qdsc2.deviceDetail = device;
        system.debug('RESULT:' + device.result);
        qdsc2.doDeviceSearch();
        
        QcsDevice deviceDetail = new QcsDevice();
        deviceDetail.result='SUCCESS';
        deviceDetail.deviceType='TRACKER';
        qdsc2.deviceDetail = deviceDetail;
        
        QcsDpcDevicequery.KitIDAttribType kit = new QcsDpcDevicequery.KitIDAttribType();
        kit.key='kit_key';
        kit.value='kit_value';
        QcsDpcDevicequery.fcaSWVersionAttribType fcaSWVersionAttribType = new QcsDpcDevicequery.fcaSWVersionAttribType();  
        fcaSWVersionAttribType.key='sw_key';
        fcaSWVersionAttribType.value='sw_value';
        
        QcsDpcDevicequery.ftdSRRSWVersionAttribType ftdSRRSWVersionAttribType = new QcsDpcDevicequery.ftdSRRSWVersionAttribType();
        ftdSRRSWVersionAttribType.key='srr_key';
        ftdSRRSWVersionAttribType.value='srr_value';
        
        QcsDpcDevicequery.ftdComponentSWVersionsAttribute ftdComponentSWVersionsAttrib = new QcsDpcDevicequery.ftdComponentSWVersionsAttribute();
        ftdComponentSWVersionsAttrib.fcaSWVersion = fcaSWVersionAttribType;
        ftdComponentSWVersionsAttrib.ftdSRRSWVersion = ftdSRRSWVersionAttribType ;
        
        QcsDpcDevicequery.ftdWirelessNetworkStateAttribType ftdWirelessNetworkState = new QcsDpcDevicequery.ftdWirelessNetworkStateAttribType();
        ftdWirelessNetworkState.Key='nwState_key';
        ftdWirelessNetworkState.value='nwState_vLUE';
        
        
        List<QcsDpcDevicequery.getAttributeParamType> deviceParameters = new  List<QcsDpcDevicequery.getAttributeParamType>();
        QcsDpcDevicequery.getAttributeParamType attributeObj = new QcsDpcDevicequery.getAttributeParamType();
        attributeObj.KitID = kit; 
        attributeObj.ftdComponentSWVersionAttrib = ftdComponentSWVersionsAttrib;
        attributeObj.ftdWirelessNetworkState = ftdWirelessNetworkState;
        deviceParameters.add(attributeObj);
        
        List<QcsDpcDevicequery.getDeviceRecordType> deviceRecordList= new  List<QcsDpcDevicequery.getDeviceRecordType>();
        QcsDpcDevicequery.getDeviceRecordType deviceRecord =  new QcsDpcDevicequery.getDeviceRecordType();
        deviceRecord.deviceType='TRACKER';  
        deviceRecord.deviceId='AB-CD-EFGH';
        deviceRecord.AttributeParam = deviceParameters;
        
        deviceRecordList.add(deviceRecord);
        qdsc2.getDeviceDetails(deviceDetail,deviceRecordList);
        Test.stopTest();
    }
    
    
    
    
    
    
}