/**********************************************************************************************
* @author  vishal Shanbhag       
* @date     28.April.2014    
* @description:   Test class for VCG_CPQ_NeedsFieldsTrigHandler
*
* @Revision(s):
**********************************************************************************************/
@isTest
public class VCG_CPQ_NeedsFieldTrig_Test {
    /**********************************************************************************************
* @author  vishal Shanbhag       
* @date     29.April.2014    
* @description:   Test method testNeedsTriggerHandler to test new  VCG_CPQ_NeedsFieldsTrigHandler
*                 on insert,update,delete of VCG_CPQ_Pricing_Condition__c,VCG_CPQ_Pricing_Access_Sequence__c
*                 VCG_CPQ_Pricing_Sequence_Condition__c,VCG_CPQ_Pricing_Procedure_Sequence__c   
                
*
* @Revision(s):
*********************************************************************************************/
    static testMethod void testNeedsTriggerHandler(){
        //
        //create VCG_CPQ_Pricing_Condition_Data__c data
        VCG_CPQ_Pricing_Condition__c pricingCond= VCG_CPQ_HelperTestClass.createPricingConditionRecord();
        insert pricingCond;
        VCG_CPQ_Pricing_Condition__c pricingCond2= VCG_CPQ_HelperTestClass.createPricingConditionRecord();
        insert pricingCond2;
        //
        //create VCG_CPQ_Pricing_Access_Sequence__c data
        VCG_CPQ_Pricing_Access_Sequence__c pricingAccSeq = VCG_CPQ_HelperTestClass.createPricingAccessSequenceRecord();
        insert pricingAccSeq;
        VCG_CPQ_Pricing_Access_Sequence__c pricingAccSeq2 = VCG_CPQ_HelperTestClass.createPricingAccessSequenceRecord();
        insert pricingAccSeq2;
        //
        //create VCG_CPQ_Pricing_Procedure__c data
        VCG_CPQ_Pricing_Procedure__c pricingProc = VCG_CPQ_HelperTestClass.createPricingProcedureRecord();
        insert pricingProc;
        VCG_CPQ_Pricing_Procedure__c pricingProc2 = VCG_CPQ_HelperTestClass.createPricingProcedureRecord();
        insert pricingProc2;
        
        test.startTest();
        //
        //creating VCG_CPQ_Pricing_Sequence_Condition__c records
        //List to store VCG_CPQ_Pricing_Sequence_Condition__c records
        List<VCG_CPQ_Pricing_Sequence_Condition__c> priSeqCondList = new List<VCG_CPQ_Pricing_Sequence_Condition__c>();
        VCG_CPQ_Pricing_Sequence_Condition__c pricingSeqCond = new VCG_CPQ_Pricing_Sequence_Condition__c();
        pricingSeqCond.Sequence__c = 1.0;
        pricingSeqCond.Condition__c = pricingCond.Id;
        pricingSeqCond.Access_Sequence__c = pricingAccSeq.Id;
        priSeqCondList.add(pricingSeqCond);
        VCG_CPQ_Pricing_Sequence_Condition__c pricingSeqCond2 = new VCG_CPQ_Pricing_Sequence_Condition__c();
        pricingSeqCond2.Sequence__c = 2.0;
        pricingSeqCond2.Condition__c = pricingCond2.Id;
        pricingSeqCond2.Access_Sequence__c = pricingAccSeq.Id;
        priSeqCondList.add(pricingSeqCond2);
        insert priSeqCondList;
        //
        //asserting VCG_CPQ_Pricing_Access_Sequence__c records to find needs fields
        //
        VCG_CPQ_Pricing_Access_Sequence__c pricingCon = [select Needs_Fields__c 
                                                                from VCG_CPQ_Pricing_Access_Sequence__c 
                                                                where id =: pricingSeqCond.Access_Sequence__c];
        //system.assertEquals('Asset__r.field__c;Asset__r.License_Metric_Quantity__c;Asset__r.License_Metric_Quantity__c', pricingCon.Needs_Fields__c);
        //
        //creating VCG_CPQ_Pricing_Procedure_Sequence__c records
        //List to store VCG_CPQ_Pricing_Procedure_Sequence__c records
        List<VCG_CPQ_Pricing_Procedure_Sequence__c> priProcSeqList = new List<VCG_CPQ_Pricing_Procedure_Sequence__c>();
        VCG_CPQ_Pricing_Procedure_Sequence__c pricingProcSeq = new VCG_CPQ_Pricing_Procedure_Sequence__c();
        pricingProcSeq.Sequence__c = 1.0;
        pricingProcSeq.Access_Sequence__c = pricingAccSeq.Id;
        pricingProcSeq.Pricing_Procedure__c = pricingProc.Id;
        priProcSeqList.add(pricingProcSeq);
        VCG_CPQ_Pricing_Procedure_Sequence__c pricingProcSeq2 = new VCG_CPQ_Pricing_Procedure_Sequence__c();
        pricingProcSeq2.Sequence__c = 2.0;
        pricingProcSeq2.Access_Sequence__c = pricingAccSeq2.Id;
        pricingProcSeq2.Pricing_Procedure__c = pricingProc.Id;
        priProcSeqList.add(pricingProcSeq2);
        insert priProcSeqList;
        //
        // Asserting VCG_CPQ_Pricing_Procedure__c record to check needcs fields
        VCG_CPQ_Pricing_Procedure__c pricingProcedure = [select Needs_Fields__c 
                                                                from VCG_CPQ_Pricing_Procedure__c 
                                                                where id =: pricingProcSeq.Pricing_Procedure__c];
        //system.assertEquals('Sales_Price__c;Asset_Term_Start_Date__c;Asset__r.License_Metric_Quantity__c;Asset__r.field__c;Asset__r.field__c', 
        //pricingProcedure.Needs_Fields__c);
        //
        //Updating VCG_CPQ_Pricing_Condition__c records
        //List to update VCG_CPQ_Pricing_Condition__c records
        List<VCG_CPQ_Pricing_Condition__c> pricingCondList= new List<VCG_CPQ_Pricing_Condition__c>();
        pricingCond.Needs_Fields__c = 'temp_needs1__c';
        pricingCondList.add(pricingCond);
        pricingCond2.Needs_Fields__c = 'temp_needs2__c';
        pricingCondList.add(pricingCond2); 
        update  pricingCondList;
        //
        //asserting VCG_CPQ_Pricing_Access_Sequence__c to check needs fields
        VCG_CPQ_Pricing_Access_Sequence__c pricingAccs = [select Needs_Fields__c 
                                                                from VCG_CPQ_Pricing_Access_Sequence__c 
                                                                where id =: pricingSeqCond.Access_Sequence__c];
        //system.assertEquals('temp_needs2__c;temp_needs1__c',pricingAccs.Needs_Fields__c);
        //
        //Updating VCG_CPQ_Pricing_Access_Sequence__c records
        //List to update VCG_CPQ_Pricing_Access_Sequence__c records
        List<VCG_CPQ_Pricing_Access_Sequence__c> pricingAccSeqList= new List<VCG_CPQ_Pricing_Access_Sequence__c>();
        pricingAccSeq.Needs_Fields__c ='temp_needs4__c';
        pricingAccSeqList.add(pricingAccSeq);
        //
        pricingAccSeq2.Needs_Fields__c ='temp_needs3__c';
        pricingAccSeqList.add(pricingAccSeq2);
        update pricingAccSeqList;
        //
        //asserting VCG_CPQ_Pricing_Procedure__c records to find the needs fields
        VCG_CPQ_Pricing_Procedure__c pricingProcedure2 = [select Needs_Fields__c 
                                                                    from VCG_CPQ_Pricing_Procedure__c 
                                                                    where id =: pricingProcSeq.Pricing_Procedure__c];
        //system.assertEquals('temp_needs3__c;temp_needs4__c',pricingProcedure2.Needs_Fields__c);
        //
        //testing reparanting of VCG_CPQ_Pricing_Sequence_Condition__c
        //Changing Condition__c of pricingSeqCond and updating
        pricingSeqCond.Condition__c = pricingCond2.Id;
        update pricingSeqCond;
        //asserting VCG_CPQ_Pricing_Access_Sequence__c to check needs fields
        VCG_CPQ_Pricing_Access_Sequence__c pricingAccs1 = [select Needs_Fields__c 
                                                                    from VCG_CPQ_Pricing_Access_Sequence__c 
                                                                    where id =: pricingSeqCond.Access_Sequence__c];
        //system.assertEquals('temp_needs2__c',pricingAccs1.Needs_Fields__c);
        //
        //testing reparanting of VCG_CPQ_Pricing_Sequence_Condition__c
        //Changing Access_Sequence__c of pricingSeqCond and updating
        pricingSeqCond.Access_Sequence__c = pricingAccSeq2.Id;
        update pricingSeqCond;
        //asserting VCG_CPQ_Pricing_Access_Sequence__c to ckeck needs fields
        VCG_CPQ_Pricing_Access_Sequence__c pricingAccs2 = [select Needs_Fields__c 
                                                                    from VCG_CPQ_Pricing_Access_Sequence__c 
                                                                    where id =: pricingSeqCond.Access_Sequence__c];
        //system.assertEquals('temp_needs2__c',pricingAccs2.Needs_Fields__c);
        //
        //testing reparanting of VCG_CPQ_Pricing_Procedure_Sequence__c
        //Changing Pricing_Procedure__c of pricingSeqCond and updating
        pricingProcSeq.Pricing_Procedure__c= pricingProc2.Id;
        update pricingProcSeq;
        //asserting VCG_CPQ_Pricing_Procedure__c record to check needs fields
        VCG_CPQ_Pricing_Procedure__c pricingProcedure3 = [select Needs_Fields__c 
                                                                    from VCG_CPQ_Pricing_Procedure__c 
                                                                    where id =: pricingProcSeq.Pricing_Procedure__c];
        //system.assertEquals('temp_needs2__c',pricingProcedure3.Needs_Fields__c);
        //
        //testing deletion of pricing condition record
        delete priSeqCondList;
        delete priProcSeqList;
        //delete pricingCond2;
        //asserting VCG_CPQ_Pricing_Access_Sequence__c record to check needs fields
        VCG_CPQ_Pricing_Access_Sequence__c pricingAccs3 = [select Needs_Fields__c 
                                                                    from VCG_CPQ_Pricing_Access_Sequence__c 
                                                                    where id =: pricingSeqCond.Access_Sequence__c];
        //system.assertEquals(null,pricingAccs3.Needs_Fields__c);
        //
        //testing deletion of pricing access sequence record
        delete pricingAccSeq;
        //asserting  VCG_CPQ_Pricing_Procedure__c record to check needs fields
        VCG_CPQ_Pricing_Procedure__c pricingProcedure4 = [select Needs_Fields__c 
                                                                    from VCG_CPQ_Pricing_Procedure__c 
                                                                    where id =: pricingProcSeq.Pricing_Procedure__c];
        //system.assertEquals(null,pricingProcedure4.Needs_Fields__c);
        
        test.stopTest();
        
        
    }
}