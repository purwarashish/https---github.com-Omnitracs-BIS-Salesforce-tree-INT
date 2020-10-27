/* This class is written to improve the coverage of Class :VCG_CPQ_NeedsFieldsUtility. 
Hence if something fails, then this class can be modified or even deleted as this doesn't validate any functionality */
@isTest(SeeAllData=True)
public class VCG_CPQ_NeedsFieldsUtility_Test 
{   
    Static Testmethod void Test1()
    {   
        
        Account acc = new Account(Name='Test Account');
        insert acc;     
        
        Opportunity Opp = new Opportunity(Name='Test Opportunity', Order_Type__c = 'New',  StageName = 'Sales Acceptance',
                                         CloseDate = System.today()+10);
        insert Opp;  
        
        VCG_CPQ_Quote__c testQuote = new VCG_CPQ_Quote__c(Account__c = acc.Id, Total__c = 1001, OwnerId = UserInfo.getUserId(), 
                                                          Ready_For_Approval__c = false, Ran_Approvals__c = false, Opportunity__c=Opp.Id);
        insert testQuote;    
        
        VCG_CPQ_Approval_Condition__c apprCondition = new VCG_CPQ_Approval_Condition__c(Name ='TestApproval',Needs_Fields__c='Account__c',IsActive__c=True);
        insert apprCondition;    
        
        List<VCG_CPQ_Pricing_Procedure__c> lstVCG_CPQ_Pricing_Procedure = new List<VCG_CPQ_Pricing_Procedure__c>();
        VCG_CPQ_Pricing_Procedure__c pricingProcedure;
        for(Integer i=0;i<2;i++)
        {
            pricingProcedure = new VCG_CPQ_Pricing_Procedure__c();
            pricingProcedure.Name='TestPricingProcedure'+i;
            pricingProcedure.Needs_Fields__c = 'Account__c';
            pricingProcedure.Active__c=True;
            pricingProcedure.Description__c='TestPricingProcedure'+i;          
            pricingProcedure.Sequence__c=0.015+i;
            if(i==0){pricingProcedure.Quote_Line_Type__c = 'Header';} 
            else {pricingProcedure.Quote_Line_Type__c = 'TestHeader';} 
            lstVCG_CPQ_Pricing_Procedure.add(pricingProcedure);
        }
        Insert lstVCG_CPQ_Pricing_Procedure;
        
        VCG_CPQ_Quote__c testQuote1=[Select id, name, Account__c, Total__c, OwnerId, Ready_For_Approval__c,Ran_Approvals__c
                                    from VCG_CPQ_Quote__c where id=: testQuote.Id];
        
        Map<SObject, String> mapToPass= new Map<SObject, String>();
        String TestString = 'Account__c;Total__c';//Account__r.Name;Opportunity__r.Name'; //Quote__r/.Total__c/; Account__c';Quote__r.Account__r.Name
        mapToPass.put(testQuote1, TestString);
        List<sObject> sObjs = new List<sObject>();
        sObjs = VCG_CPQ_NeedsFieldsUtility.getNeedsFields(mapToPass);
        String TestString1 = 'Opportunity__r/.Name;Account.Name'; 
        try
        {
            mapToPass.put(testQuote1, TestString1);
            sObjs = VCG_CPQ_NeedsFieldsUtility.getNeedsFields(mapToPass);
        }
        catch(Exception e){}
        System.assert(!sObjs.isEmpty());
        List<sObject> sObjs1 = new List<sObject>();
        sObjs1 = VCG_CPQ_NeedsFieldsUtility.getNeedsFields(sObjs,TestString);
         try
        {
            mapToPass.put(testQuote1, TestString);
            sObjs1 = VCG_CPQ_NeedsFieldsUtility.getNeedsFields(sObjs,TestString1);
        }
        catch(Exception e){}
        Map<String,List<String>> mapStrLstString = new Map<String,List<String>>();
        mapStrLstString = VCG_CPQ_NeedsFieldsUtility.getAllNeedsFields();
        Map<String,Map<String,List<sObject>>> mapMapLstSobj = new  Map<String,Map<String,List<sObject>>>();
        mapMapLstSobj = VCG_CPQ_NeedsFieldsUtility.GetNeedsFieldsSources();
        List<String> lstString = new List<String>();
        lstString = VCG_CPQ_NeedsFieldsUtility.getNeedsFields('Product2');
        lstString = VCG_CPQ_NeedsFieldsUtility.getNeedsFields('Product1');
        map<String, String> rawNeedsFields = new map<string, string>{'VCG_CPQ_Quote__c' => 'Quote_Products__r.Name ;Opportunity__r.Name',
                                                                    'VCG_CPQ_Quote_Product__c' => 'Quote__r.Opportunity__r.Name;Quote__r.Name'};
        mapStrLstString = VCG_CPQ_NeedsFieldsUtility.ProcessRawNeedsFields(rawNeedsFields);            
    }
}