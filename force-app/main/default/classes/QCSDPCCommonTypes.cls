//Generated by wsdl2apex

public class QCSDPCCommonTypes {
    public class DeviceUpgrade {
        public QcsDpcCommonTypes.DeviceUpgradeParam[] device;
        public Boolean allTrackers;
        public QcsDpcCommonTypes.FtdComponentSoftware upgradeVersion;
        private String[] device_type_info = new String[]{'device','http://qcs.qualcomm.com/schema/dpcCommonTypes','DeviceUpgradeParam','1','-1','false'};
        private String[] allTrackers_type_info = new String[]{'allTrackers','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] upgradeVersion_type_info = new String[]{'upgradeVersion','http://qcs.qualcomm.com/schema/dpcCommonTypes','FtdComponentSoftware','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://qcs.qualcomm.com/schema/dpcCommonTypes','true','false'};
        private String[] field_order_type_info = new String[]{'device','allTrackers','upgradeVersion'};
    }
    public class DeviceUpgradeStateParam {
        public String id;
        public QcsDpcCommonTypes.FtdComponentSoftware version;
        public String status;
        public String message;
        private String[] id_type_info = new String[]{'id','http://qcs.qualcomm.com/schema/dpcCommonTypes','deviceIdType','1','1','false'};
        private String[] version_type_info = new String[]{'version','http://qcs.qualcomm.com/schema/dpcCommonTypes','FtdComponentSoftware','1','1','false'};
        private String[] status_type_info = new String[]{'status','http://qcs.qualcomm.com/schema/dpcCommonTypes','DeviceUpgradeStatus','1','1','false'};
        private String[] message_type_info = new String[]{'message','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://qcs.qualcomm.com/schema/dpcCommonTypes','true','false'};
        private String[] field_order_type_info = new String[]{'id','version','status','message'};
    }
    public class DeviceUpgradeState {
        public QcsDpcCommonTypes.DeviceUpgradeStateParam[] device;
        public Long transactionId;
        private String[] device_type_info = new String[]{'device','http://qcs.qualcomm.com/schema/dpcCommonTypes','DeviceUpgradeStateParam','1','-1','false'};
        private String[] transactionId_type_info = new String[]{'transactionId','http://www.w3.org/2001/XMLSchema','long','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://qcs.qualcomm.com/schema/dpcCommonTypes','true','false'};
        private String[] field_order_type_info = new String[]{'device','transactionId'};
    }
    public class DeviceUpgradeParam {
        public String id;
        private String[] id_type_info = new String[]{'id','http://qcs.qualcomm.com/schema/dpcCommonTypes','deviceIdType','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://qcs.qualcomm.com/schema/dpcCommonTypes','true','false'};
        private String[] field_order_type_info = new String[]{'id'};
    }
    public class DeviceChargerUpgradeState {
        public QcsDpcCommonTypes.DeviceChargerUpgradeStateParam[] device;
        public Long transactionId;
        private String[] device_type_info = new String[]{'device','http://qcs.qualcomm.com/schema/dpcCommonTypes','DeviceChargerUpgradeStateParam','1','-1','false'};
        private String[] transactionId_type_info = new String[]{'transactionId','http://www.w3.org/2001/XMLSchema','long','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://qcs.qualcomm.com/schema/dpcCommonTypes','true','false'};
        private String[] field_order_type_info = new String[]{'device','transactionId'};
    }
    public class DeviceChargerUpgrade {
        public QcsDpcCommonTypes.DeviceUpgradeParam[] device;
        public Boolean allChargers;
        public QcsDpcCommonTypes.FbcComponentSoftware upgradeVersion;
        private String[] device_type_info = new String[]{'device','http://qcs.qualcomm.com/schema/dpcCommonTypes','DeviceUpgradeParam','1','-1','false'};
        private String[] allChargers_type_info = new String[]{'allChargers','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] upgradeVersion_type_info = new String[]{'upgradeVersion','http://qcs.qualcomm.com/schema/dpcCommonTypes','FbcComponentSoftware','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://qcs.qualcomm.com/schema/dpcCommonTypes','true','false'};
        private String[] field_order_type_info = new String[]{'device','allChargers','upgradeVersion'};
    }
    public class DeviceUpgradeTracker {
        public QcsDpcCommonTypes.DeviceUpgradeStateParam device;
        public QcsDpcCommonTypes.FtdComponentSoftware compSwVer;
        private String[] device_type_info = new String[]{'device','http://qcs.qualcomm.com/schema/dpcCommonTypes','DeviceUpgradeStateParam','1','1','false'};
        private String[] compSwVer_type_info = new String[]{'compSwVer','http://qcs.qualcomm.com/schema/dpcCommonTypes','FtdComponentSoftware','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://qcs.qualcomm.com/schema/dpcCommonTypes','true','false'};
        private String[] field_order_type_info = new String[]{'device','compSwVer'};
    }
    public class FtdComponentSoftware {
        public String ftdSrr;
        public String fca;
        private String[] ftdSrr_type_info = new String[]{'ftdSrr','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] fca_type_info = new String[]{'fca','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://qcs.qualcomm.com/schema/dpcCommonTypes','true','false'};
        private String[] field_order_type_info = new String[]{'ftdSrr','fca'};
    }
    public class FbcComponentSoftware {
        public String fbcSrr;
        private String[] fbcSrr_type_info = new String[]{'fbcSrr','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://qcs.qualcomm.com/schema/dpcCommonTypes','true','false'};
        private String[] field_order_type_info = new String[]{'fbcSrr'};
    }
    public class DeviceChargerUpgradeStateParam {
        public String id;
        public QcsDpcCommonTypes.FbcComponentSoftware version;
        public String status;
        public String message;
        private String[] id_type_info = new String[]{'id','http://qcs.qualcomm.com/schema/dpcCommonTypes','deviceIdType','1','1','false'};
        private String[] version_type_info = new String[]{'version','http://qcs.qualcomm.com/schema/dpcCommonTypes','FbcComponentSoftware','1','1','false'};
        private String[] status_type_info = new String[]{'status','http://qcs.qualcomm.com/schema/dpcCommonTypes','DeviceUpgradeStatus','1','1','false'};
        private String[] message_type_info = new String[]{'message','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://qcs.qualcomm.com/schema/dpcCommonTypes','true','false'};
        private String[] field_order_type_info = new String[]{'id','version','status','message'};
    }
}