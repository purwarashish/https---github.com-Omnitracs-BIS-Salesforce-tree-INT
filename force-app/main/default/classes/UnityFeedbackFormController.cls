public class UnityFeedbackFormController
{
    
    public String ratingUse { get; set; } //to rate overall use
    
    public String ratingAction { get; set; } //variable to store rating for action
    
    public String RatingIsHelpful { get; set; } //variable to store rating for usefullness
    
    public String ratingForLabel { get; set; } //variable to store rating for label
    
    public String chooseContact { get; set; } //store value for mode of contact
    
    public String suggestions { get; set; } //stores suggestion
    
    public String comments { get; set; } //stores comment
    
    public String pageName { get; set; } //stores page name from which feedback button was clicked
    
    public Case newCase{get;set;}{newCase = new Case();} //case type object
    
    public String emailField{get;set;}
    
    public String caseContactId{get;set;}
    public String test{get;set;}
    
    public String caseAccountId{get;set;}
    
    public String caseQueueId{get;set;}
    
    public String phoneField{get;set;}
    
    public UnityFeedbackFormController(ApexPages.StandardController controller)
    {
        User loggedInUser = [SELECT Id, Queue__c, Email, Phone,ContactId,AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        List<Contact> loggedInUserContactDetails =
                                    [
                                        SELECT
                                            Id,
                                            Email,
                                            Phone
                                        FROM
                                            Contact
                                        WHERE
                                            Id = :loggedInUser.ContactId
                                        LIMIT
                                            1
                                    ];
    
        if( (null != loggedInUserContactDetails) &&
            (0 != loggedInUserContactDetails.size()) ) {
            emailField = loggedInUserContactDetails[0].Email;
            phoneField = loggedInUserContactDetails[0].Phone;
        }
        else {
            emailField = loggedInUser.Email;
            phoneField = loggedInUser.Phone;            
        }

        chooseContact = emailField;        
        
        caseContactId = loggedInUser.ContactId;
        
        caseAccountId = loggedInUser.AccountId;
        
        caseQueueId = loggedInUser.Queue__c;
    }
    
    public UnityFeedbackFormController() {}
    
    public List<SelectOption> getUseRatingValues()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1', ''));
        options.add(new SelectOption('2', ''));
        options.add(new SelectOption('3', ''));
        return options;
    }
    public List<SelectOption> getActionRatingValues() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1', ''));
        options.add(new SelectOption('2', ''));
        options.add(new SelectOption('3', ''));
        return options;
    }

    public List<SelectOption> getHelpratingValues() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1', ''));
        options.add(new SelectOption('2', ''));
        options.add(new SelectOption('3', ''));
        return options;
    }

    public List<SelectOption> getLabelRatingValues() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1', ''));
        options.add(new SelectOption('2', ''));
        options.add(new SelectOption('3', ''));
        return options;
    }
    
    public List<SelectOption> getChooseContactValues() {
       List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(emailField, 'Email'));
        options.add(new SelectOption(phoneField, 'phone'));
        return options;
    }
/**
  *@Description:
**/
    
    public PageReference submitCase() 
    {
        pageName = ApexPages.currentPage().getParameters().get('pn');        
        
        String strContactMethod;
        
        if(null == chooseContact) 
        {
            chooseContact='';
        }
        if(ratingForLabel == null && RatingIsHelpful == null && ratingAction == null && ratingUse == null)
        {
          system.debug('radio buttons are null');
          if((comments == null || comments == '') && (suggestions == null || suggestions == ''))
          {
             system.debug('textbox are null');
             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select a rating or enter in comments before submitting your feedback.');
             ApexPages.addMessage(msg);
             return null;
          }  
        }
        
        newCase.Customer_Portal_Page__c = pageName;
        
        newCase.status = 'New - Unassigned';
        
        newCase.Substatus__c='';
        
        newCase.priority='2-Medium';
        
        newCase.Origin='Customer Portal';
        
        newCase.Subject='Customer Portal Feedback';
        
        if(caseContactId != null)
            newCase.ContactId=caseContactId;
        
        if(caseAccountId != null)
            newCase.AccountId=caseAccountId;
        
//Added by Avinash Kaltari to assign a valur for Queue field when a Feedback case is created
        newCase.Queue__c = 'Customer Portal Feedback';
        
        newCase.RecordTypeId=System.Label.CALL_CENTER_RECORDTYPEID;
        
        newCase.Category__c='Customer Portal Feedback';
        
        if(chooseContact.contains('@'))
            {
                strContactMethod = 'Email';
                test = emailField;
            }
        else
            {
                strContactMethod = 'Phone';
                test = phoneField;
            }
        
        newCase.Description='How do you Rate this page.' +
        '\nAre the labels and Instruction clear?'+ratingForLabel+
        '\nIs information included on this page helpful?'+RatingIsHelpful+
        '\nCan you easily take the action you need on this page?'+ratingAction+
        '\nOverall Use:'+ratingUse+
        '\nComments :'+comments+
        '\nWhat would make this page better for you to work with?'+suggestions+
        '\nWOULD YOU LIKE US TO CONTACT YOU?'+ strContactMethod+ ' :'+test;
        
        //if(strContactMethod == 'Email')
        //  newCase.Description += strContactMethod+ ' :'+chooseContact;
        //else 
        //  newCase.Description += strContactMethod+ ' :'+phoneField;
//System.debug('Description'+newCase.Description);
        
      //Assigns default Assignment rules
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;//assignmentRuleID = '01Q50000000AQsC';
        
        dmlOpts.EmailHeader.triggerUserEmail = true;
        
        dmlOpts.optAllOrNone = true;
        
        newCase.setOptions(dmlOpts);
        
        try
        {
            insert newCase;
        }
        catch(Exception e)
        {
            system.debug('Exception' + e);
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Insert failed');
            ApexPages.addMessage(msg);
            return null;
        }
        newCase = [Select id,subject  from Case where id=:newCase.Id limit 1];
        newCase.subject = newCase.subject+'';
        newCase.setOptions(dmlOpts);
        update newCase;
        PageReference myPage = new PageReference('/apex/feedbackconfirm');
        myPage.setRedirect(true);
        return myPage;
    }

}