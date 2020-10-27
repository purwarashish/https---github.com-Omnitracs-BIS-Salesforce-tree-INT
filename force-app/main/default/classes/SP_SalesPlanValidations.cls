public class SP_SalesPlanValidations {
    public static string pValues(string stageNME){
        Schema.DescribeFieldResult F = Opportunity.Stagename.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();  

        map<integer,string> pMap = new map<integer,string>();
        map<string,integer> iMap = new map<string,integer>();

        list<string> pVal = new list<string>();
        for(Schema.PicklistEntry o: P){
            pVal.add(o.getValue());   
        }
        System.debug(pVal);
        System.debug('\n\n\n********pVal*******' + pVal.size() + '***********');
        for(integer i = 0; i<pVal.size() ;i++){
               pMap.put(i,pVal[i]);            
        }
        System.debug(pMap);

        for(integer i: pMap.keySet()){
            iMap.put(pMap.get(i),i);    
        }
        System.debug(stageNME);

        string retVal = pMap.get(iMap.get(stageNME) - 1);
        if(retVal == null){
            retVal = pMap.get(0);
        }
        return retVal;
        }
    
    
    public static void validateRequiredActions (Map<Id,Opportunity> newOpps, Map<Id,Opportunity> oldOpps) {
        
        for (Opportunity newOpp : newOpps.values()) {   
            //Opportunity Stage has changed - check for uncompleted required Tasks
            if (newOpp.StageName != oldOpps.get(newOpp.Id).StageName && newOpp.StageName != 'Closed Lost') {
                String oppRecordType = SP_RecordTypeManager.getNameById(newOpp.RecordTypeId, 'Opportunity');
                System.debug('stage name' + newOpp.StageName);
                string stageNME = pValues(newOpp.StageName);
                List<Objective_Action__c> reqActions = [SELECT Id, Name, Opportunity_Type__c, Opportunity_Order_Type__c, Opportunity_Order_SubType__c, Effective_Date__c, Exempt_Profiles__c, Exempt_Users__c, Exempt_Products__c 
                                                          FROM Objective_Action__c 
                                                         WHERE Stage_Name__c = :stageNME
                                                               AND Action_Type__c = 'Required'
                                                               AND (Opportunity_Record_Type__c INCLUDES (:oppRecordType)) 
                                                               AND (Opportunity_Type__c INCLUDES (:newOpp.Type)
                                                               AND Opportunity_Order_Type__c INCLUDES (:newOpp.Order_Type__c)
                                                               AND Opportunity_Order_SubType__c INCLUDES (:newOpp.Order_Sub_Type__c))
                                                               AND (Effective_Date__c= null or Effective_Date__c <= :newOpp.CreatedDate.Date())];
                System.debug(reqActions);
                                                               
                List<Task> completedActions = [SELECT Id, ObjectiveActionID__c 
                                                 FROM Task 
                                                WHERE WhatId = :newOpp.Id 
                                                      AND StageObjectiveID__c != null
                                                      AND ObjectiveActionID__c != null
                                                      AND IsClosed = true];
                
            //  Boolean allProdsExempt = SP_OpportunityActionPlanExtension.checkExemptProducts(newOpp.SP_Products__c);
                                                      
                for (Objective_Action__c req : reqActions) {
                    //is this user exempt from the Action?
                    if ((req.Exempt_Users__c != null && req.Exempt_Users__c.contains(UserInfo.getUserId().mid(0,15))) || (req.Exempt_Profiles__c != null && req.Exempt_Profiles__c.contains(UserInfo.getProfileId().mid(0,15))) || newOpp.Sales_Plan_Opt_Out__c) {
                        continue;
                    }
                    //are all products in the exempt list?
                 /*   if (allProdsExempt && req.Exempt_Products__c) {
                        continue;
                    }*/
                    
                    /*if (((newOpp.Type != null && req.Opportunity_Type__c != null && req.Opportunity_Type__c.contains(newOpp.Type))
                         && (newOpp.Order_Type__c != null && req.Opportunity_Order_Type__c != null && req.Opportunity_Order_Type__c.contains(newOpp.Order_Type__c)) 
                         && (newOpp.Order_Sub_Type__c != null && req.Opportunity_Order_SubType__c != null && req.Opportunity_Order_SubType__c.contains(newOpp.Order_Sub_Type__c))
                         && req.Opportunity_Record_Type__c.contains(oppRecordType))
                        && (req.Effective_Date__c <= newOpp.CreatedDate || req.Effective_Date__c == null)) {*/
                        Boolean found = false;
                        for (Task tsk : completedActions) {
                            if (tsk.ObjectiveActionId__c == req.Id) {
                                found = true;
                                break;
                            }
                        }
                        if (!found) {
                            newOpp.addError('You cannot advance this Opportunity until all required Sales Plan actions have been completed (' + req.Name + ')');
                            break;
                        }
                    //}
                }
            }
        }
    }
    /*public static void validateRequiredActions (Map<Id,Opportunity> newOpps, Map<Id,Opportunity> oldOpps) {
        for (Opportunity newOpp : newOpps.values()) {
            String oppRecordType = SP_RecordTypeManager.getNameById(newOpp.RecordTypeId, 'Opportunity');
            //Opportunity Stage has changed - check for uncompleted required Tasks
            if (newOpp.StageName != oldOpps.get(newOpp.Id).StageName && newOpp.StageName != 'Closed Lost') {
                List<Objective_Action__c> reqActions = [SELECT Id, Name, Opportunity_Type__c, Opportunity_Order_Type__c, Opportunity_Order_SubType__c, Effective_Date__c, Exempt_Profiles__c, Exempt_Users__c, Exempt_Products__c 
                                                          FROM Objective_Action__c 
                                                         WHERE Stage_Name__c = :oldOpps.get(newOpp.Id).StageName 
                                                               AND Action_Type__c = 'Required'
                                                               AND (Opportunity_Record_Type__c INCLUDES (:oppRecordType))
                                                               AND (Opportunity_Type__c INCLUDES (:newOpp.Type)
                                                               AND Opportunity_Order_Type__c INCLUDES (:newOpp.Order_Type__c)
                                                               AND Opportunity_Order_SubType__c INCLUDES (:newOpp.Order_Sub_Type__c))];
                System.debug(reqActions);                                              
                List<Task> completedActions = [SELECT Id, ObjectiveActionID__c 
                                                 FROM Task 
                                                WHERE WhatId = :newOpp.Id 
                                                      AND StageObjectiveID__c != null
                                                      AND ObjectiveActionID__c != null
                                                      AND IsClosed = true];
                
                Boolean allProdsExempt = SP_OpportunityActionPlanExtension.checkExemptProducts(newOpp.SP_Products__c);
                                                      
                for (Objective_Action__c req : reqActions) {
                    //is this user exempt from the Action?
                    if ((req.Exempt_Users__c != null && req.Exempt_Users__c.contains(UserInfo.getUserId().mid(0,15))) || (req.Exempt_Profiles__c != null && req.Exempt_Profiles__c.contains(UserInfo.getProfileId().mid(0,15))) || newOpp.Sales_Plan_Opt_Out__c) {
                        continue;
                    }
                    //are all products in the exempt list?
                    if (allProdsExempt && req.Exempt_Products__c) {
                        continue;
                    }
                    
                    /*if ((( req.Opportunity_Type__c.contains(newOpp.Type))
                         && (req.Opportunity_Order_Type__c.contains(newOpp.Order_Type__c)) 
                         && (req.Opportunity_Order_SubType__c.contains(newOpp.Order_Sub_Type__c))
                         && req.Opportunity_Record_Type__c.contains(oppRecordType))
                        && (req.Effective_Date__c <= newOpp.CreatedDate || req.Effective_Date__c == null)) {
                        Boolean found = false;
                        for (Task tsk : completedActions) {
                            if (tsk.ObjectiveActionId__c == req.Id) {
                                found = true;
                                break;
                            }
                        }
                        if (!found) {
                            newOpp.addError('You cannot advance this Opportunity until all required Sales Plan actions have been completed (' + req.Name + ')');
                            break;
                        }
                    //}
                    
                }
            }
        }
    }*/

}