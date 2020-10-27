public class QuoteLineActionModelHolder {
    public String contractNumber;
	public String contractId;
	public Boolean isExpired;
    public List<QuoteLineActionModel> modelList = new List<QuoteLineActionModel>();
    
    public QuoteLineActionModelHolder() {}
    
    public QuoteLineActionModelHolder(String contractNumber, String contractId, Boolean isExpired, List<QuoteLineActionModel> modelList) {
		this.contractNumber = contractNumber;
		this.contractId = contractId;
		this.isExpired = isExpired;
        this.modelList = modelList;
    }
}