public class OmnitracsCreateCaseController {
    public case newCase {get; set;}{newCase = new  Case();}

    public Boolean isBizSolution {get; set;}
    public String reqestType {get; set;}
    public String impactedSystem {get; set;}
    public String requestorName {get; set;}
    public String requestorEmail {get; set;}
    public String requestorPhone {get; set;}
    
    public String filename {get;set;}
    public Blob fileBody {get;set;}
    
    public String filenameSec {get;set;}
    public Blob fileBodySec {get;set;}
    
    public String filenameThrd {get;set;}
    public Blob fileBodyThrd {get;set;}
    
    private List<attachment> lstAttachment = new List<attachment>();  
    public List<String> lstImpactedUsers {get; set;}
    public List<SelectOption> lstImpactedUserOptions {get;set;}{lstImpactedUserOptions = new List<SelectOption>();}
    public List<SelectOption> lstImpactedSysOptions {get;set;}{lstImpactedSysOptions = new List<SelectOption>();}
    public List<SelectOption> lstRequestType{get;set;}{lstRequestType = new List<SelectOption>();}  
    private List<Contact> lstCont = new List<Contact>();
    
    public OmnitracsCreateCaseController(ApexPages.StandardController controller) {
        lstRequestType.add(new SelectOption ('Case Request','Case Request'));
        lstRequestType.add(new SelectOption ('Project Request','Project Request')); 
        
        lstImpactedSysOptions.add(new SelectOption ('Customer Portal','Customer Portal'));
        lstImpactedSysOptions.add(new SelectOption ('Partner Portal','Partner Portal'));
        lstImpactedSysOptions.add(new SelectOption ('SFDC','SFDC'));
        lstImpactedSysOptions.add(new SelectOption ('Other','Other'));
         
        reqestType =  'Case Request';
        newCase.Case_Queue__c = 'SFDC';
        newCase.Is_this_a_production_issue__c = 'No'; 
        newCase.Case_Queue__c = 'SFDC Support';
        String loggedInUserEmail = userinfo.getUserEmail();
        system.debug('@@@@loggedInUserEmail'+loggedInUserEmail);
        lstCont = [Select 
                        id,
                        name,
                        email,
                        phone
                   from 
                       contact 
                   where 
                       email=: loggedInUserEmail

                   limit 1];
         system.debug('@@@@lstCont'+lstCont);
         if(!lstCont.isEmpty()){
             requestorName = lstCont[0].name;
             requestorEmail = lstCont[0].email;
             requestorPhone = lstCont[0].phone;   
         }
         
         //Biz Solution logic
          List<OmnitracsBizSolProfMapping__c> lstBizSolProf = OmnitracsBizSolProfMapping__c.getall().values();
          Set<String> setProfId = new Set<String>();
          system.debug('@@@lstBizSolProf'+lstBizSolProf);
          String userProfId = userInfo.getProfileId();
          if(lstBizSolProf != null && lstBizSolProf.size()>0){
               
               for(OmnitracsBizSolProfMapping__c lst:lstBizSolProf){
                   setProfId.add(lst.BizSolutionProfId__c);                   
               }
          }
          if(!setProfId.isEmpty() && setProfId.contains(userProfId) )
              isBizSolution = true;

    }
    
    public OmnitracsCreateCaseController(){
    }
    
    public pagereference createCase(){
                
        if(requestorName == '')
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Requestor name cannot be blank.');
            ApexPages.addMessage(msg);
            return null;
        }
        if(requestorEmail == '')
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Requestor email cannot be blank.');
            ApexPages.addMessage(msg);
            return null;
        }
        if(requestorPhone== '')
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Requestor phone cannot be blank.');
            ApexPages.addMessage(msg);
            return null;
        }
        if(reqestType == 'Case Request'){
            newCase.Case_Request_Type__c = 'Case Request';
            newCase.What_is_the_business_need__c = '';
            newCase.Is_this_a_production_issue__c = 'No';
            newCase.Who_is_impacted_by_this_request_when_imp__c = '';
            newCase.Which_internal_teams_are_impacted__c = '';
            newCase.What_are_the_expected_specific_benefits__c = '';
            newCase.What_do_you_want_it_to_do__c = '';
            newCase.Change_related_other_business_initiative__c = false;
            newCase.Description_Of_Similar_initiative__c = '';
            newCase.Is_there_a_defined_need_by_date__c = false;
            newCase.Defined_Need_By_Date__c = null;
            newCase.Defined_Need_By_Date_Justification__c = '';
            newCase.Recommended_UI__c = '';
            
            if(newCase.subject == '' ||newCase.subject == null)
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Subject cannot be blank.');
                ApexPages.addMessage(msg);
                return null;
            }
            if(newcase.Description == '' || newcase.Description == '')
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Description cannot be blank.');
                ApexPages.addMessage(msg);
                return null;
            }
        }
        if(reqestType == 'Project Request'){
            
            newcase.Description =' ';
            newCase.Subject = ' ';
            newCase.Case_Queue__c = 'Project Request';
            newCase.Case_Request_Type__c = 'Project Request';
            
            if(newCase.What_is_the_business_need__c == '' || newCase.What_is_the_business_need__c == null)
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'What is the business need? cannot be blank.');
                ApexPages.addMessage(msg);
                return null;
            }
            if(newcase.What_are_the_expected_specific_benefits__c == '' || newCase.What_are_the_expected_specific_benefits__c == null)
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'What are the business benefits to this project cannot be blank.');
                ApexPages.addMessage(msg);
                return null;
            }
            if(newcase.What_do_you_want_it_to_do__c == '' || newCase.What_do_you_want_it_to_do__c == null)
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'What should this project accomplish cannot be blank.');
                ApexPages.addMessage(msg);
                return null;
            }
            if(newcase.Who_is_impacted_by_this_request_when_imp__c == '' || newCase.Who_is_impacted_by_this_request_when_imp__c == null)
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Upon implementation who is impacted by this project request cannot be blank.');
                ApexPages.addMessage(msg);
                return null;
            }
            if(newcase.Is_there_a_defined_need_by_date__c == true &&(newCase.Defined_Need_By_Date__c == null|| newCase.Defined_Need_By_Date_Justification__c == ''||newCase.Defined_Need_By_Date_Justification__c == null))
            {
                system.debug('Inside if of date:::' +newcase.Is_there_a_defined_need_by_date__c);
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Defined Need By Date or Defined need by date Justification cannot be empty if defined need by date is checked.');
                ApexPages.addMessage(msg);
                return null;
            }
            if(newcase.Change_related_other_business_initiative__c == true && (newCase.Description_Of_Similar_initiative__c == '' ||newCase.Description_Of_Similar_initiative__c==null))
            {
               
                system.debug('Inside if of business initiative');
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Description Of Similar initiative cannot be blank if project request related to other business initiative is checked.');
                ApexPages.addMessage(msg);
                return null;
            }
        } 
        if(!lstCont.isEmpty())
            lstCont = new List<Contact>();
        
        lstCont = [Select id from contact where email=: requestorEmail limit 1];
        
        if(lstCont!=null && !lstCont.isEmpty())
            newCase.contactId = lstCont[0].id;
        newCase.Origin = 'Web';
        
        if(reqestType == 'Case Request')
            newCase.recordTypeId = System.label.Case_Request; //'012P00000008k47';
        else
            newCase.recordTypeId = System.label.Project_Request; //'012P00000008k3d'; 
        
        
        if(filename != null && fileBody != null){
            Attachment attch = new Attachment();
            attch.name= fileName;
            attch.body = fileBody; 
            lstAttachment.add(attch); 
        } 

        if(filenameSec != null && fileBodySec != null){
            Attachment attch = new Attachment();
            attch.name= filenameSec;
            attch.body = fileBodySec; 
            lstAttachment.add(attch); 
        } 
        
        if(filenameThrd!= null && fileBodyThrd != null){
            Attachment attch = new Attachment();
            attch.name= filenameThrd;
            attch.body = fileBodyThrd; 
            lstAttachment.add(attch); 
        } 
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
        dmlOpts.EmailHeader.triggerUserEmail = true;
        dmlOpts.optAllOrNone = true;
        
        newCase.setOptions(dmlOpts);
        try{
            system.debug('@@@@lstAttachment:::: '+lstAttachment);
            insert newCase;
            
                      
            system.debug('@@@@newcase id'+newCase.id);
            List<attachment> lstAttachInsert = new List<attachment>();
            for(Attachment attchtemp:lstAttachment){
                attchtemp.parentId = newCase.id;
                lstAttachInsert.add(attchtemp);    
            }
            insert lstAttachInsert;
            
            newCase = [Select id,contact.email, subject  from Case where id=:newCase.Id limit 1];
            system.debug('@@@@@@@11111'+newCase.contact.email);
            if(newCase.subject == null || newCase.subject== '')
                newCase.subject = '';    
            else    
                newCase.subject = newCase.subject+'';
            system.debug('@@@@newCase.subject'+newCase.subject);
            
            //code to send email notification to contact
            
            if(newCase.contact != null && newCase.contact.email != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(newCase.contactId);
                mail.setWhatId(newCase.Id);
                mail.setTemplateId(System.label.Case_Create_Notify_Contact_Template_Id);
                List<String> lstToAddr = new List<String>();
                lstToAddr.add(newCase.contact.email);
                mail.setToAddresses(lstToAddr);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                system.debug('@@@@mail'+mail);
            }
            newCase.setOptions(dmlOpts);
            update newCase;
            
            PageReference myPage = new PageReference('/apex/OmnitracsCaseConfirm');
            myPage.setRedirect(true);
            return myPage;
          
            
        }
        catch(Exception e){
            system.debug('@@@@exception caught'+e.getMessage());
            String msgTxt = e.getMessage();
           /* if(msgTxt != null && msgTxt != '')
                msgTxt = msgTxt.subString(msgTxt.indexOf(',')+1, msgTxt.lastIndexOf('.')); */
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Case cannot be created.' + msgTxt);
            ApexPages.addMessage(msg); 
            return null;
              
        }
               
    }
    public pageReference clear(){
        newCase = new Case();
        requestorName = '';
        requestorEmail = '';
        requestorPhone = '';
        PageReference myPage = new PageReference('/home/home.jsp');
        myPage.setRedirect(true);
        return myPage;  
    }
    
   

}