public class PostChatController {

    public ID contactID {get;set;}
    public ID accountID {get;set;}
    public ID caseID {get;set;}
    public ID agentID {get;set;}
    public String feedback {get;set;}
    public String cAdditionalFeedback {get;set;}
    
    public PostChatController() {
        String attachedRecords = ApexPages.currentPage().getParameters().get('attachedRecords');
        String chatDetails = ApexPages.currentPage().getParameters().get('chatDetails');
        if(String.isnotBlank(attachedRecords)){
            contactID = JSON2Apex.parse(attachedRecords).contactID;
            accountID = JSON2Apex.parse(attachedRecords).accountID;
            caseId = JSON2Apex.parse(attachedRecords).caseID;
        }
        if(String.isnotBlank(chatDetails)){
            agentID = JSON2Apex.parse(chatDetails).AgentID;
        }
    }
    
    public void submitFeedback(){
        Survey__c nSurvey = new Survey__c(Account__c=accountID, Contact_survey_lookup__c = contactID, Case__c = caseID, Agent__c = agentId,
                                          Customer_Feedback__c=feedback,Additional_comments_on_support_exp__c=cAdditionalFeedback);
        insert nSurvey;
        return;
    }
    
}