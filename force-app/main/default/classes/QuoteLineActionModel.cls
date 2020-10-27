public class QuoteLineActionModel {
    public String contractNumber {get;set;}
	public String productId {get;set;}
    public Decimal qty {get;set;}
    public String qtyType {get;set;}// blank if quantity has to be replaced, INCREMENT if quantity has to be increased, DECREMENT if quantity has to be decreased
	public Boolean isNew {get;set;}
    public Decimal finalUnitPrice {get;set;}
	public String optyRecordType {get;set;}
	public String optyOrderType {get;set;}
	public String optyOrderSubType {get;set;}
    public Decimal additionalDisc {get;set;}
    public String discType {get;set;}
	public String priceBookId {get;set;}
	public String currencyCode {get;set;}
	public String oracleId {get;set;}
    
    public QuoteLineActionModel() {}
}