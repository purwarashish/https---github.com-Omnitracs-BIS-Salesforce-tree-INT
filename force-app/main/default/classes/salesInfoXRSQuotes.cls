/*@@@ Created by Arindam Laik, Aug 27 2015
  @@@ This class is used by 'XRS: Sales Information from XRS Quotes' VF template
*/
public class salesInfoXRSQuotes{
public String OpportunityId{get;set;}
public String OpportunityOwnerName{get;set;}
public String OpportunityOwnerEmail{get;set;}

Public String baseURL
{
   get
   {
       baseURL = URL.getSalesforceBaseUrl().toExternalForm();
       return baseURL;
   }
   set;
}       

public VCG_CPQ_Quote__c objQuote
{
    get
    {
        List<VCG_CPQ_Quote__c> lstQuote = new List<VCG_CPQ_Quote__c>();
        objQuote = new VCG_CPQ_Quote__c();
        lstQuote =[SELECT Name,ShippingAddress__r.Address_Line_1__c,ShippingAddress__r.Address_Line_2__c,
                   ShippingAddress__r.City__c,ShippingAddress__r.State_Province__c,ShippingAddress__r.Zip_Postal_Code__c,
                   Invoice_Address__r.Address_Line_1__c,Invoice_Address__r.Address_Line_2__c,Invoice_Address__r.City__c,
                   Invoice_Address__r.State_Province__c,Invoice_Address__r.Zip_Postal_Code__c
                   FROM VCG_CPQ_Quote__c WHERE Opportunity__c =: this.OpportunityId AND Is_Primary__c = true LIMIT 1];
        
        if (!lstQuote.isEmpty())
        {
            objQuote = lstQuote[0];
        }
        return objQuote;
    }
    set;
}
public List<opportunityLineItem> lstOpportunityProduct
{
    get
    {
        lstOpportunityProduct = new List<opportunityLineItem>();
        lstOpportunityProduct = [SELECT Product2.Name, Quantity, ProductCode FROM opportunityLineItem WHERE OpportunityId =: this.OpportunityId
                                 AND Product2.Product_Type__c = 'Hardware'  and Line_Type__c != 'Decommission' LIMIT 50000];
        
        return lstOpportunityProduct;
    }
    set;
}
public opportunity objOpportunity
{
    get
    {
        List<opportunity> lstOpportunity = new List<opportunity>();
        List<user> lstUser = new List<User>();
        lstOpportunity = [SELECT Id, Name,Ownerid, Account.Name, Account.QWBS_Cust_ID__c, Host_Information__r.Host_Company_ID__c, Send_XRS_Shipment_Request__c,
                          Freight_Method__c,Host_Company_Id__c,Contact__r.Name, Contact__r.Phone, Contact__r.email FROM opportunity WHERE Id =: this.OpportunityId LIMIT 1];
        
        if(!lstOpportunity.isEmpty())
        {
            objOpportunity = lstOpportunity[0];
            lstUser = [select name , email from user where id =: lstOpportunity[0].Ownerid limit 1];
            
            if(!lstUser.isEmpty())
            {
                OpportunityOwnerName = lstUser[0].name;
                OpportunityOwnerEmail = lstUser[0].email;
            }
            
            
        }
        return objOpportunity;
    }
    set;
}
}