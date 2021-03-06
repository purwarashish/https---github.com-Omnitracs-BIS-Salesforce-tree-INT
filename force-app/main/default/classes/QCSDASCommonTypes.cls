//Generated by wsdl2apex

public class QCSDASCommonTypes{
    public class getDeviceStateRequest_element {
        public String ftdId;
        public String stateType;
        private String[] ftdId_type_info = new String[]{'ftdId','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] stateType_type_info = new String[]{'stateType','http://model.service.web.csrdata.das.qcs.qualcomm.com','DeviceStateType','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://model.service.web.csrdata.das.qcs.qualcomm.com','false','false'};
        private String[] field_order_type_info = new String[]{'ftdId','stateType'};
    }
    public class getDeviceStateResponse_element {
        public String securityState;
        public String serviceState;
        public String reachableState;
        private String[] securityState_type_info = new String[]{'securityState','http://model.service.web.csrdata.das.qcs.qualcomm.com','DeviceSecurityState','0','1','false'};
        private String[] serviceState_type_info = new String[]{'serviceState','http://model.service.web.csrdata.das.qcs.qualcomm.com','DeviceServiceState','0','1','false'};
        private String[] reachableState_type_info = new String[]{'reachableState','http://model.service.web.csrdata.das.qcs.qualcomm.com','DeviceReachableState','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://model.service.web.csrdata.das.qcs.qualcomm.com','false','false'};
        private String[] field_order_type_info = new String[]{'securityState','serviceState','reachableState'};
    }
}