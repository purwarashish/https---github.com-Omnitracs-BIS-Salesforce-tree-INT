@isTest(seeAllData = true)
class QuoteProductUtil_Test
{

        Static testmethod void UpdateSourceAddOnTest()
        {
            list<VCG_CPQ_Quote_Product__c> lstTestData = [select Add_on_Source_Quote_Product__c,Quote__c from VCG_CPQ_Quote_Product__c where Quote__c!= null and Add_on_Source_Quote_Product__c != null limit 2];
            
            if (!lstTestData.isEmpty())
            {
                  
                  if(lstTestData[0].Quote__c != lstTestData[1].Quote__c){
                  
                  VCG_CPQ_Quote_Product__c clonedData = new VCG_CPQ_Quote_Product__c();
                  clonedData.Quote__c = lstTestData[0].Quote__c;
                  clonedData.Add_on_Source_Quote_Product__c = lstTestData[1].id;
                  
                  insert clonedData;
                  
            }
                
          }
            
        }

}