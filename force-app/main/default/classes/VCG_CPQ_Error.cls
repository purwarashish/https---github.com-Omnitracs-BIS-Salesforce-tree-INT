public without sharing class VCG_CPQ_Error {
    public String errorType;
    public String errorMessage;
    
    public VCG_CPQ_Error(String type, String message){
        this.errorType = type;
        this.errorMessage = message;
    }
    public VCG_CPQ_Error(String message){
        errorMessage = message;
    }
    
}