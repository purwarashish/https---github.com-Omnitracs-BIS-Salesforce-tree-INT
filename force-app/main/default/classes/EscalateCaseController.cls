public class EscalateCaseController{
    public Case ccCase;
    public String internalComment;
    
    public EscalateCaseController(){
        try{
        ccCase = new Case();
        //Query the field values of the original case to be escalated
        ccCase = [SELECT Id,
                         AccountId,
                         ContactId, 
                         Asset__c, 
                         //Component__c, 
                         Subject, 
                         Description,
                         Business_Unit__c
                         //Browser__c,
                         //Internal_Category__c
                  FROM Case 
                  WHERE Id = :ApexPages.currentPage().getParameters().get('Id') LIMIT 1];
        internalComment = ApexPages.currentPage().getParameters().get('Comment');
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'There was an error fetching the Case record details. Please contact your administrator.'));
        }
    }
    
    /**
     * @description Method that is called immediately after the EscalateCase Visualforce page has been called.
     * @author K. Vegerano <kristian.vegerano@cloudsherpas.com>
     */
    public PageReference EscalateToEngineering(){
        try{
            //Get recordTypeId necessary for escalated case
            Id rtId = SystemIds__c.getInstance().RecordTypeId_Case_Engineering__c;
            //Get Engineering Queue Id
            Id engineeringId = [SELECT Id, Name, Type 
                                FROM Group 
                                WHERE Type = 'Queue' 
                                    AND Name = 'Software Engineering' LIMIT 1].Id;
            
            Id roadnetEngineeringId = [SELECT Id, Name, Type 
                                FROM Group 
                                WHERE Type = 'Queue' 
                                    AND Name = 'RN Tier 2' LIMIT 1].Id;
                                    
            Id sylectusEngineeringId = [SELECT Id, Name, Type 
                                FROM Group 
                                WHERE Type = 'Queue' 
                                    AND Name = 'Sylectus Tech Support' LIMIT 1].Id;
                                    
            Id mexicoEngineeringId = [SELECT Id, Name, Type 
                                FROM Group 
                                WHERE Type = 'Queue' 
                                    AND Name = 'CNR Engineering' LIMIT 1].Id;
            
            //Create Escalated Case based from ccCase (Original Case)
            Case newCase = new Case(Asset__c = ccCase.Asset__c,
                                    recordTypeId = rtId, //Engineering Case record type
                                    //ownerId = engineeringId, //Set Engineering queue as the case Owner
                                    Escalation_Comments__c = internalComment,
                                    //Component__c = ccCase.Component__c,
                                    Subject = ccCase.Subject,
                                    Description = ccCase.Description,
                                    //Steps_to_Reproduce__c = ccCase.Steps_to_Reproduce__c,
                                    //Browser__c = ccCase.Browser__c,
                                    //Hide_Case_in_Portal__c = true,
                                    //Internal_Category__c = ccCase.Internal_Category__c,
                                    Business_Unit__c = ccCase.Business_Unit__c,
                                    AccountId = ccCase.AccountId,
                                    ContactId = ccCase.ContactId);
            if (ccCase.Business_Unit__c == 'Roadnet') {
                newCase.OwnerId = roadnetEngineeringId;
            }
            else if (ccCase.Business_Unit__c == 'Sylectus') {
                newCase.OwnerId = sylectusEngineeringId;
            }
            else if (ccCase.Business_Unit__c == 'Omnitracs MX') {
                newCase.OwnerId = mexicoEngineeringId;
            }
            else {
                newCase.OwnerId = engineeringId;
            }
            insert newCase;
            //Query attachments of support case
            List<Attachment> supportAttachmentsList = [SELECT Id, ParentId, Body, Name FROM Attachment WHERE ParentId = :ccCase.Id];
            List<Attachment> escalateAttachmentsList = supportAttachmentsList.deepClone(false, true, true);
            for(Attachment loopAttachments : escalateAttachmentsList){
                loopAttachments.parentId = newCase.Id;
            }
            insert escalateAttachmentsList;
            //Update original Case
            ccCase.Is_Escalated_to_Dev__c = true;
            ccCase.JIRA_Issue__c = newCase.CaseNumber;
            ccCase.Substatus__c = 'Escalated - Engineering';
            ccCase.Engineering_Case__c = newCase.Id;//Linked Case
            update ccCase;
            //Update escalation case
            newCase.Description = ccCase.Description;
            update newCase;
            //Redirect to edit page of the Escalated Case
            return new PageReference('/' + newCase.Id + '/e?retURL=/' + newCase.Id);
        }catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;
        }
    }
}