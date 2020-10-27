//Device properties for QCS devices - used for CSR device search.
//Contains attributes for DPC and DAS servers 
public class QCSDevice
{
    //Attributes from DPC server
    public String deviceId {get;set;}
    public String result {get;set;}
    public String deviceType {get;set;}
    public String kitId {get;set;}
    public String ftdClientApp {get;set;} //This corresponds to fcaSWVersion in DPC
    public String ftdSRR {get;set;}       //This corresponds to ftdSRRSWVersion in DPC
    public String fbcSRR {get;set;}       //This corresponds to fbcSRRSWVersion in DPC 
    public String ftdMCN {get;set;}       //This corresponds to ftdHardwareVersionAttrib in DPC 
    public String fbcMCN {get;set;}       //This corresponds to fbcHardwareVersionAttrib in DPC 
    public String ftdMFG {get;set;}       //This corresponds to ftdSerialNumberAttrib in DPC     
    public String fbcMFG {get;set;}       //This corresponds to fbcSerialNumberAttrib in DPC 
    public String networkState {get;set;} //This corresponds to ftdWirelessNetworkState in DPC     
    public String eligibleForActivation {get;set;} //This corresponds to ftdActivatableState in DPC 
    
    //Attributes from DAS server
    public String deviceServiceState {get;set;}
    public String deviceSecurityState {get;set;} 
    public String deviceReachabilityState {get;set;}  
}