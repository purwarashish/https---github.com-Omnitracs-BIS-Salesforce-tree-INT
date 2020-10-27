@isTest(SeeAllData=true)
class CaseServices_Test
{
    /**
     * @description Tests when a case pushes certain fields to Support Cases (all Related Cases) when an Engineering Case is updated
     * @author Kristian Vegerano 13.JAN.2014
     * @last modified 
     */
     //Commented by Arindam Laik, as we have consolidated all case related test classes into one
    /*public static testMethod void testEscalationCaseResponse(){
        //Set Test Variables
        Map<Id,Case> caseMap = new Map<Id,Case>();
        Case escalateCase = new Case(Subject = 'Escalate Case',
                                     Status = 'Close',
                                     //Case_Closure_Comments__c = 'Test Closure Comment',
                                     //Fixed_Version__c = 'Test Fixed Version',
                                     //Customer_Status__c = 'Need Values',
                                     JIRA_Issue__c = 'Test Dev No',
                                     //Internal_Category__c = 'Stampen_OneView',
                                     recordTypeId = SystemIds__c.getInstance().RecordTypeId_Case_Engineering__c);
        insert escalateCase;
        Case supportCase = new Case(Subject = 'Support Case', Engineering_Case__c = escalateCase.Id, status = 'New');
        insert supportCase;
        caseMap.put(escalateCase.Id,escalateCase);
        CaseServices.escalationCaseResponse(caseMap, caseMap.values());
    }*/
}