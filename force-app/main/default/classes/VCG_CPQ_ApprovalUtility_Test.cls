/***********************************************************************************************************************
* @description
* @author  Scott Warren <swarren@vepcg.com>
* @since   10.Jul.2014
************************************************************************************************************************/
@isTest(SeeAllData=True)
public class VCG_CPQ_ApprovalUtility_Test{
    
    static testMethod void testApprovalSetup(){
        /*************************************************
        *   Test Data Setup
        **************************************************/        
        Profile p = [select id from profile where name='System Administrator'];
        List<User> users = new List<User>();
        users.add(new User(alias = 'SalesRep', email = 'test_rep@omnitracs.com', lastName = 'Rep', username = 'test_salesrep@vepcg.com', TimeZoneSIDKey = 'America/Chicago', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US'));
        users.add(new User(alias = 'Manager', email = 'test_Manager@omnitracs.com', lastName = 'Rep', username = 'test_Manager@vepcg.com', TimeZoneSIDKey = 'America/Chicago', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US'));
        users.add(new User(alias = 'VP', email = 'test_VP@omnitracs.com', lastName = 'VP', username = 'test_VP@vepcg.com', TimeZoneSIDKey = 'America/Chicago', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US'));
        users.add(new User(alias = 'DDUser', email = 'test_DealDeskUser@omnitracs.com', lastName = 'DealDeskUser', username = 'test_DealDeskUser@vepcg.com', TimeZoneSIDKey = 'America/Chicago', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US'));
        insert users;
        
        Group dealDesk = new Group(Name = 'DealDesk', type='Queue');
        insert dealDesk;
        QueuesObject queue = new QueuesObject(queueId = dealDesk.Id, SobjectType='VCG_CPQ_Quote__c');
        insert queue;
        
        System.runAs(users[1]){
            List<Product2> prodList = new List<Product2>();
            prodList.add(new Product2(Name = 'Product0', Family = 'Web', License_Metric__c = 'Seat'));
            prodList.add(new Product2(Name = 'Product1', Family = 'Web', License_Metric__c = 'Seat'));
            prodList.add(new Product2(Name = 'Product2', Family = 'Web', License_Metric__c = 'Seat'));
            prodList.add(new Product2(Name = 'Product3', Family = 'Web', License_Metric__c = 'Seat'));
            prodList.add(new Product2(Name = 'Product4', Family = 'Web', License_Metric__c = 'Seat'));
            prodList.add(new Product2(Name = 'Product5', Family = 'Web', License_Metric__c = 'Seat'));
            insert prodList;
            
            Account acc = new Account(Name='Test Account');
            insert acc;        
            
            List<VCG_CPQ_Approval_Condition__c> conditions = new List<VCG_CPQ_Approval_Condition__c>();
            List<VCG_CPQ_Approval_Group__c> approvalGroups = new List<VCG_CPQ_Approval_Group__c>();
            List<VCG_CPQ_Approval_Group_Matrix__c> matrices = new List<VCG_CPQ_Approval_Group_Matrix__c>();
            List<VCG_CPQ_User_Hierarchy__c> hierarchies = new List<VCG_CPQ_User_Hierarchy__c>();
            
            conditions.add(new VCG_CPQ_Approval_Condition__c(Approval_Reason__c = 'Reason 1', Calculation_Compiled__c = '{"op":">","p1":"Total__c","p2":1000.0}', Needs_Fields__c = 'Total__c', IsActive__c = true, IsDeployed__c = true));
            conditions.add(new VCG_CPQ_Approval_Condition__c(Approval_Reason__c = 'Reason 2', Calculation_Compiled__c = '{"op":">","p1":"Total__c","p2":100.0}', Needs_Fields__c = 'Total__c', IsActive__c = true, IsDeployed__c = true));
            insert conditions;
            
            // We use 'Needs_Approval__c' here as the Quote_Field rather than an actual "Approval_Group_XXX" checkbox because it is a checkbox and should exist in all orgs (there is no guarantee that every org will use the same Approval_Group_XXX field)
            approvalGroups.add(new VCG_CPQ_Approval_Group__c(Description__c = 'Deal Desk', Queue_Name__c = 'DealDesk', Quote_Field__c = 'Needs_Approval__c'));
            insert approvalGroups;
            
            matrices.add(new VCG_CPQ_Approval_Group_Matrix__c(Approval_Condition__c = conditions[0].Id, /*Approval_Group__c = '', */ Approval_User_Role__c = 'Manager', Sequence__c = 1));
            insert matrices;
            
            hierarchies.add(new VCG_CPQ_User_Hierarchy__c(Related_User__c = users[1].Id, Related_User_Role__c = 'Manager', User__c = users[0].Id));
            hierarchies.add(new VCG_CPQ_User_Hierarchy__c(Related_User__c = users[2].Id, Related_User_Role__c = 'VP', User__c = users[0].Id));
            insert hierarchies;
            
            
            /*************************************************
            *   Test General Use Case
            **************************************************/
            
            VCG_CPQ_Quote__c testQuote = new VCG_CPQ_Quote__c(Account__c = acc.Id, Total__c = 1001, OwnerId = users[0].Id, Ready_For_Approval__c = false, Ran_Approvals__c = false);
            insert testQuote;
            
            List<VCG_CPQ_Quote_Product__c> selectedCoreProds = new List<VCG_CPQ_Quote_Product__c>();        
            selectedCoreProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd0', Quantity__c=25, Quote__c = testQuote.Id, Product__c = prodList[0].Id, Product_Group__c = 'G1'));
            selectedCoreProds.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd1', Quantity__c=5, Quote__c = testQuote.Id, Product__c = prodList[1].Id, Product_Group__c = 'G1'));               
            insert selectedCoreProds;

            
            
            
            System.debug('\n\n*************** TEMP APPROVAL TEST BEGINS HERE ***************\n\n');
            
            List<VCG_CPQ_Quote_Product__c> tempProdList = new List<VCG_CPQ_Quote_Product__c>();
            VCG_CPQ_Quote__c tempTestQuote = new VCG_CPQ_Quote__c(Account__c = acc.Id, Total__c = 1001, OwnerId = users[0].Id, Ready_For_Approval__c = false, Ran_Approvals__c = false);
            
            tempProdList.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd0', Quantity__c=25, Product__c = prodList[0].Id, Product_Group__c = 'G1'));
            tempProdList.add(new VCG_CPQ_Quote_Product__c(Name='quoteProd1', Quantity__c=5, Product__c = prodList[1].Id, Product_Group__c = 'G1'));         
            
            List<VCG_CPQ_Quote_Approval__c> tempApprovals = VCG_CPQ_ApprovalUtility.getTempQuoteApprovals(tempTestQuote, tempProdList);
            System.debug('tempApprovals: ' + tempApprovals);
            
            
            
            
           
            System.debug('\n\n*************** NORMAL APPROVAL TEST BEGINS HERE ***************\n\n');
            
            testQuote = [select Id, Name, Ready_For_Approval__c, Approver__c from VCG_CPQ_Quote__c limit 1];
            testQuote.Ready_For_Approval__c = true;
            testQuote.Approval_Process__c = 'Process 1';
            update testQuote;
            
            List<VCG_CPQ_Quote_Approval__c> approvals = new List<VCG_CPQ_Quote_Approval__c>([SELECT Id, Approver__c, Sequence__c, Quote_Field__c, Quote__c, Approval_Reason__c, Approval_Group__c, Approval_Condition__c, Status__c
                                                                                            FROM VCG_CPQ_Quote_Approval__c
                                                                                            WHERE Quote__c = :testQuote.Id]);
            
            System.debug('approvals at setup: ' + approvals);
            
            System.debug('Trigger next approver...');
            testQuote = [select id, Name, Approver__c, Last_Approved_By__c from VCG_CPQ_Quote__c limit 1];
            
            System.debug('Quote before 2nd Update: ' + testQuote + ' __ ' + testQuote.Approver__c);
            
            
            
            System.debug('\n\n*************** TEST NEXT APPROVER ***************\n\n');
                        
           /* testQuote.Last_Approved_By__c = testQuote.Approver__c;
            update testQuote;
                        
            testQuote = [select id, Name, Approver__c, Last_Approved_By__c from VCG_CPQ_Quote__c limit 1];
            System.debug('after trigger quote: ' + testQuote);
            
            approvals = new List<VCG_CPQ_Quote_Approval__c>([SELECT Id, Approver__c, Sequence__c, Quote_Field__c, Quote__c, Approval_Reason__c, Approval_Group__c, Approval_Condition__c, Status__c
                                                                                            FROM VCG_CPQ_Quote_Approval__c
                                                                                            WHERE Quote__c = :testQuote.Id]);

            System.debug('approvals at next: ' + approvals);
            
            
            
            
            
            testQuote.Approval_Process__c = 'Process 2';
            update testQuote;           
            
            
            
            
            testQuote.Approval_Status__c = 'Rejected';
            update testQuote;  */         
            
        }
    }
    /*
    private static void testForupdateOpptQuoteProductField()
    {
        //  this should be a simple test, we need to query a quote product record, query it's quote record, and then perform an update on the quote
        //  that should force the method to get called and the private static methods will also get called as a result
        Savepoint sp = Database.setSavepoint();
        //  want to prevent the NON-Selective query thing so i am going to say product__r.name like roandet, i konw the product field is indexed but not
        //  sure if lookup to name is...
        VCG_CPQ_Quote_Product__c testQuoteProduct = [select id, name, product__c, Quote__c from VCG_CPQ_Quote_Product__c where product__c != null and product__r.name like '%Roadnet%' limit 1];
        if (testQuoteProduct != null)
        {
            VCG_CPQ_Quote__c testquote = [select id from VCG_CPQ_Quote__c where id =: testQuoteProduct.Quote__c];
            if (testquote != null)
            {
                update testquote;
            }
        }
        Database.rollback(sp);
    }  
    
    */
    
}