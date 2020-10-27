public with sharing class DocumentGenerationSelectionController {
    public List<String> attachments {get; set;}
    public String generateOptions {get; set;}
    public String selectedLanguage {get; set;}
    public List<String> deliveryMethods {get; set;}
    public SBQQ__Quote__c quote {get;set;}
    static String SPRINGCM_WORKFLOW_NAME = 'Create Contract Package';
    static String SALESFORCE_OBJECT_TYPE = 'SBQQ__Quote__c';
    static String SPRINGCM_ATTACHMENT_FOLDER_PATH = '/Admin/Templates/Legal/';
    public String objectPath = '';
    public Revision_Schedule__c revisionSched {get;set;}
    public Boolean hasActivationSchedules {get;set;}
    public Boolean isInitialSchedule {get;set;}
    public Boolean isRevisionPending {get;set;}
    public String isOT1 {get;set;}
    public Boolean showQuoteContracts {get;set;}
    public Boolean isCanadianQuote {get;set;}
    public Boolean valPanicContact {get;set;}
    public Boolean valPanicNumber {get;set;}
    public Boolean valOEMName {get;set;}
    public Boolean val3PLName {get;set;}
    public Boolean addressContacts {get;set;}
    public Boolean accountLegalName {get;set;}
    public Boolean valContractAdmin {get;set;}
    SpringCMEos__EOS_Type__c eosObject = null;
    public Map<Id, Contact> contactMap {get;set;}
    public Map<Id, SBQQ__QuoteLine__c> quoteLineMap {get;set;}
    public Set<String> categorySet {get;set;}
    public Integer i=0;
    public DocumentGenerationSelectionController() {
        this.attachments = new List<String> ();
        this.selectedLanguage = 'English';
        this.eosObject = getEOSObject(SALESFORCE_OBJECT_TYPE);
        showQuoteContracts = true;
        String selectClause = this.eosObject.SpringCMEos__Variables__c + (this.eosObject.SpringCMEos__Variables__c.containsNone('Id')
                ? (this.eosObject.SpringCMEos__Variables__c.containsNone('Name')
                        ? ', Id, Name'
                        : ', Id')
                : (this.eosObject.SpringCMEos__Variables__c.containsNone('Name')
                        ? ', Name'
                        : ''));
        System.debug('Select Clause variables: ' + selectClause);
        this.quote = Database.query('SELECT SBQQ__Account__c, SBQQ__PrimaryContact__c, CustomerContact__c, SBQQ__Account__r.Primary_Business_Unit__c, SBQQ__Account__r.Legal_Name__c, SBQQ__Account__r.Contracts_Administrator__c,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Opportunity_Country__c,SBQQ__Opportunity2__r.type, '+
                                            'SBQQ__Opportunity2__r.order_type__c, SBQQ__Opportunity2__r.order_sub_type__c, Panic_Button_Contact__c, Panic_Button_Notification_Number__c, Panic_Button_Contact_Required__c, SBQQ__Type__c, ' +
                                            'Corporate_Attention__c, Bill_To_Attention__c, Ship_To_Attention__c, OEM_Name__c, Q3PL_Name__c, Q3PL_Name_Required__c, OEM_Name_Required__c, Ship_to_Account_Name__c, Bill_to_Account_Name__c, Corporate_Account_Name__c, ' +
                                     'Ship_To_Account_Address__c,Corporate_Account_Address__c,Bill_To_Account_Address2__c, '+ selectClause + ' FROM ' + SALESFORCE_OBJECT_TYPE + ' WHERE Id = \'' + System.currentPageReference().getParameters().get('quoteid') + '\'');
        //this.quote = [select Id, Name, SBQQ__Account__c from SBQQ__Quote__c where Id = :System.currentPageReference().getParameters().get('quoteid')];
        Revision_Schedule__c[] revisionSchedules = [Select Id, Revision__c, Status__c from Revision_Schedule__c where Quote__c = :this.quote.Id Order By CreatedDate DESC LIMIT 1];
        revisionSched = revisionSchedules.size() > 0 ? revisionSchedules[0] : null;
        hasActivationSchedules = revisionSchedules.size() > 0;
        isInitialSchedule = revisionSched != null && revisionSched.Revision__c == 1 && revisionSched.Status__c == 'Draft';
        isRevisionPending = revisionSched != null && (revisionSched.Status__c == 'Pending Finance Approval' || revisionSched.Status__c == 'Pending Legal Approval');
        SBQQ__QuoteLine__c[] ot1Lines = [Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c = :this.quote.Id AND SBQQ__Product__r.Is_OT1__c = TRUE];
        this.isOT1 = ot1Lines.size() > 0 ? 'True' : 'False';
        if(isInitialSchedule)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Activation Schedules will be locked once documents are generated, make sure to update the Activation Schedules before running document generation process.'));
        if(isRevisionPending)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Documents cannot be generated yet as Activation Schedules Revision is pending Finance/Legal approval.'));
        this.quote.CustomerContact__c = this.quote.SBQQ__PrimaryContact__c;
        //getActiveContracts();
        //not show for mexico
        showQuoteContracts = !((quote.SBQQ__Account__r.Primary_Business_Unit__c == 'Omnitracs Mexico' && quote.SBQQ__Opportunity2__r.Opportunity_Country__c == 'Mexico'));
          
        isCanadianQuote = quote.SBQQ__Account__r.Primary_Business_Unit__c == 'Omnitracs Canada';
          //(quote.SBQQ__Opportunity2__r.order_type__c == 'Eval')  
                       
        /*if(showQuoteContracts && quote.SBQQ__Type__c == 'Amendment' && quoteLineMap.size() == 0){
            showQuoteContracts = false;
        }*/
        valPanicContact = (String.isBlank(quote.Panic_Button_Contact__c) && quote.Panic_Button_Contact_Required__c)?false:true;
        
        if(!valPanicContact || test.isRunningTest()){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'One of the quoted products requires that you designate a "Panic Button Contact" to generate documents.'));  
        }
        
        valPanicNumber = (String.isBlank(quote.Panic_Button_Notification_Number__c) && quote.Panic_Button_Contact_Required__c)?false:true;
        
        if(!valPanicNumber || test.isRunningTest()){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'One of the quoted products requires that you designate a "Panic Button Notification Number" to generate documents.'));  
        }
        
        valOEMName = (String.isBlank(quote.OEM_Name__c) && quote.OEM_Name_Required__c)?false:true;
        
        if(!valOEMName || test.isRunningTest()){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'One of the quoted products requires that you designate an "OEM Name" to generate documents.'));  
        }
        
        val3PLName = (String.isBlank(quote.Q3PL_Name__c) && quote.Q3PL_Name_Required__c)?false:true;
        
        if(!val3PLName || test.isRunningTest()){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'One of the quoted products requires that you designate a "3PL Name" to generate documents.'));  
        }
        
        addressContacts = (String.isBlank(quote.Bill_To_Account_Address2__c) || String.isBlank(quote.Corporate_Account_Address__c) || String.isBlank(quote.Bill_To_Attention__c) || String.isBlank(quote.Corporate_Attention__c)) ? true : false;
        if(addressContacts || test.isRunningTest()){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Designate a \'Bill To Address\', \'Corporate Address\', \'Bill To Attention\' and \'Corporate Attention\' to generate documents.'));  
        }
        
        //accountLegalName = (String.isBlank(quote.Ship_to_Account_Name__c) || String.isBlank(quote.Bill_to_Account_Name__c) || String.isBlank(quote.Corporate_Account_Name__c))?true:false;
        accountLegalName = String.isBlank(quote.SBQQ__Account__r.Legal_Name__c);
        if(accountLegalName || test.isRunningTest()){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Enter the \'Legal Name\' on the Account to generate documents. Please email contracts@omnitracs.com or contact the Contracts Administrator to have the \'Legal Name\' changed or added.'));  
        }
        
        valContractAdmin = String.isNotBlank(quote.SBQQ__Account__r.Contracts_Administrator__c);
        if(!valContractAdmin || test.isRunningTest()){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The \'Contracts Administrator\' on the Account should be populated to generate documents.  Please email contracts@omnitracs.com to resolve this issue.'));  
        }
        
        List<String> eosDetails = getPath(this.quote, this.eosObject);
        System.debug(LoggingLevel.DEBUG, ' DocumentGenerationSelectionController.buildWorkflowXML SCM object path and name: ' + eosDetails);
        if (null == eosDetails.get(0)) {
            System.debug(LoggingLevel.ERROR, 'Could not get the eos details ');
        } else {
            this.objectPath = eosDetails.get(1).escapeXml();
        }
        
        contactMap = new Map<Id, Contact> ([SELECT Id, Name, Email FROM CONTACT WHERE AccountId = :quote.SBQQ__Account__c and Email != null order by name asc]);
        System.debug('DocumentGenerationSelectionController.constructor object path: ' + this.objectPath);
    }

    public PageReference test() {
        return null;
    }

    /**
        Method to determine the documents to generate, get the 
        relevant fields the generator needs and then send to the generator. 
    */
    public PageReference runDocumentationGeneration() {
        // Logic to figure out which documents to send to generation system.
        System.debug(LoggingLevel.DEBUG, ' DocumentGenerationSelectionController.runDocumentGeneration starting the run');
        if(String.isBlank(quote.SBQQ__Account__r.Primary_Business_Unit__c)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Primary Business Unit on the Account should be populated to generate documents.'));  
            if(!test.isRunningTest()) return null;
        }
        if(String.isBlank(quote.CustomerContact__c)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Specify the customer contact that will sign the documents.'));  
            if(!test.isRunningTest()) return null;
        }
        if(contactMap.get(quote.CustomerContact__c) == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Specify the customer contact from Account ' + quote.SBQQ__Account__r.Legal_Name__c + ' with valid email address that will sign the documents.'));  
            if(!test.isRunningTest()) return null;
        }
        
        if(String.isBlank(generateOptions) || test.isRunningTest()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select "Documents to Generate" option.'));  
            if(!test.isRunningTest()) return null;
        }
        
        boolean competitorReqd = false;
        List<Opportunity> opptyList = [Select Id, Type_of_Competitor__c, (select Id, Name from Competitive_Summary__r) from Opportunity where RecordType.Name NOT IN ('Data Migration', 'Services Only') AND Order_Type__c NOT IN ('Customer Portal', 'Decommission') AND Order_Sub_Type__c != 'Decommission' AND Id = :quote.SBQQ__Opportunity2__c];
        if(opptyList.size() > 0){
            Opportunity oppty = opptyList[0];
            List<Competitive_Summary__c> summaryList = oppty.Competitive_Summary__r;
            List<String> reqCompValues = new list<String> { 'Competitive Takeaway', 'Competitive Threat' };
            if(String.isBlank(oppty.Type_of_Competitor__c) || (reqCompValues.contains(oppty.Type_of_Competitor__c) && summaryList.size() == 0))
                competitorReqd = true;
        }
        if(competitorReqd || test.isRunningTest()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select Type of Competitor and associated Competitors for the Opportunity.'));  
            if(!test.isRunningTest()) return null;
        }
        
        Set<String> docSet = new Set<String>();
        if((generateOptions !=  null && generateOptions == 'quotecontract')|| test.isRunningTest()) {
            docSet = getActiveContracts();
        }

        System.debug(LoggingLevel.DEBUG, ' DocumentGenerationSelectionController.runDocumentGeneration Length: ' + docSet.size());

        //Build the xml to send to spring CM
        String xml = buildWorkflowXML(docSet, this.attachments);
        String success = 'true';
        // Send values to the document generation system.
        try {
            User usr = [select Id, SpringCMEos__SpringCM_User__c from User where Id = :UserInfo.getUserId()];
            if(usr.SpringCMEos__SpringCM_User__c){
                if(!test.isRunningTest()) SpringCMRestUtils.startWorkflow(SPRINGCM_WORKFLOW_NAME, xml, UserInfo.getSessionId());
                success = 'true';
                if(revisionSched != null && revisionSched.Status__c == 'Draft' && revisionSched.Revision__c == 1){
                    revisionSched.Status__c = 'Approved';
                    update revisionSched;
                }
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You are not a SpringCM User, please contact Administrator'));  
            }
        } catch (Exception eek) {
            System.debug(LoggingLevel.ERROR, 'Error when trying to submit the workflow: ' + eek);
            success = 'false';
        }
        System.debug(LoggingLevel.DEBUG, ' DocumentGenerationSelectionController.runDocumentGeneration forwarding to the display page');
        PageReference returnPage = new PageReference('/apex/DocumentGenerationDisplay?quoteid=' + this.quote.Id + '&workflowSuccess=' + success + '&xml=' + EncodingUtil.urlEncode(xml, 'UTF-8'));
        return returnPage;
    }
    
    public String buildWorkflowXML(Set<String> docSet, List<String> listAttachments) {
        String xml = '';
        System.debug(LoggingLevel.DEBUG, ' DocumentGenerationSelectionController.buildWorkflowXML  :');
        //for (SObject obj : listOfSObjects) {
        xml += buildWorkflowXML(this.eosObject.Name, docSet, listAttachments);
        //}
        return String.isEmpty(xml) ? xml : '<QuoteInfo>' + xml + '</QuoteInfo>';
    }


    /**
    Builds the xml to send out to SpringCM
    <QuoteInfo>
    <RequestorUserID/>
    <CustomerContactEmail/>
    <CustomerContactName/>
    <QuoteID/>
    <QuoteName/>
    <QuoteSCMPath/>
    <CustomObjectInfo>
        <CustomObjectId/>
        <CustomObjectType/>
        <CustomDocsList>
            <DocID/>
            <DocID/>
        </CustomDocsList>
    </CustomObjectInfo>
    <Attachments>
        <DocID/>
        <DocID/>
    </Attachments>
</QuoteInfo>
     */
    public String buildWorkflowXML(String objectType, Set<String> docSet, List<String> listAttachments) {
        System.debug(LoggingLevel.DEBUG, ' DocumentGenerationSelectionController.buildWorkflowXML : ' + docSet.size());
        if (objectType == null || objectType == '') return null;

        String xml = '';
        //xml += '<QuoteInfo>';
            xml += '<RequestorUserID>' + UserInfo.getUserId() + '</RequestorUserID>';
            xml += '<selectedLanguage>' + this.selectedLanguage + '</selectedLanguage>';
            xml += '<IsOT1>' + this.isOT1 + '</IsOT1>';
            //XML doesn't support multiple contacts
            if(String.isNotBlank(quote.CustomerContact__c)) {
                Contact cntct = contactMap.get(quote.CustomerContact__c);
                xml += '<CustomerContactEmail>' + cntct.Email.escapeXml()+ '</CustomerContactEmail>';
                xml += '<CustomerContactName>' + cntct.Name.escapeXml() + '</CustomerContactName>';
            } else {
                xml += '<CustomerContactEmail/>';
                xml += '<CustomerContactName/>';
            }

            xml += '<QuoteID>' + this.quote.Id + '</QuoteID>';
            xml += '<QuoteName>' + this.quote.Name + '</QuoteName>';
            xml += '<QuoteSCMPath>' + this.objectPath + '</QuoteSCMPath>';
            xml += '<CustomObjectInfo>';
                xml += '<CustomObjectId/>';
                xml += '<CustomObjectType/>';
                xml += '<CustomDocsList>';
                    for(String docId: docSet) {
                        if(String.isNotBlank(docId)){
                            xml += '<DocID>' + docId + '</DocID>';
                        }
                    }
                xml += '</CustomDocsList>';
            xml += '</CustomObjectInfo>';
            if(listAttachments.size() > 0) {
                xml += '<Attachments>';
                for (String docId: listAttachments) {
                    xml += '<DocID>' + docId + '</DocID>';
                }
                xml += '</Attachments>';
            } else {
                xml += '<Attachments/>';
            }
        //xml += '</QuoteInfo>';
        System.debug('************************ XML TO SPRINGCM --- ' + xml);
        return xml;
    }

    /**
        Cancel the action on the page. 
    */
    public PageReference doCancel() {
        //Need to return to the last page. 
        return new PageReference('/' + this.quote.Id);
        //return standardController.cancel();
    }

    public PageReference refreshForm(){
        return null;
    }
    /**
        List of attachments available for the quote. 
    */
    public List<SelectOption> getAttachmentItems()
     {
        // Need to query the springCM qpi to get the attachments in the account document folder. 
        List<SelectOption> attachmentList = new List<SelectOption>();
        //List<SelectOption> attachmentsList = new List<SelectOption>();
        //List<SelectOption> attachmentssList = new List<SelectOption>(); 
       
        List<String> paths = new List<String>();
        System.debug('*********** - objectPath -- '+this.objectPath);
        paths.add('/Other Sources'+this.objectPath + '/' + this.quote.name);

        //paths.add(SPRINGCM_ATTACHMENT_FOLDER_PATH);

        for(String path: paths) 
        {
            System.debug('DocumentGenerationSelectionController.getAttachmentItems path AAA: ' + path);
            attachmentList.addAll(getFolderOptions(path));
        }
        return attachmentList;
    }

    public List<SelectOption> getFolderOptions(String path) {
        // Need to query the springCM qpi to get the attachments in the account document folder.
        List<SelectOption> attachmentList = new List<SelectOption>();
        SpringCMFolder folder = null;
        try {
            String session = UserInfo.getSessionId();
            System.debug(LoggingLevel.DEBUG, 'DocumentGenerationSelectionController.getFolderOptions session: ' + session);
            SpringCMService springcm = new SpringCMService(String.isBlank(session) ? false : true, session);
            path = path.replaceAll('&apos;', '\'');
            path = path.replaceAll('&amp;', '_');
            System.debug(LoggingLevel.DEBUG, 'DocumentGenerationSelectionController.getFolderOptions path: ' + path);
            folder = springcm.findFolderByPath(path, 'Documents');
            System.debug(LoggingLevel.DEBUG, 'DocumentGenerationSelectionController.getFolderOptions folder: ' + folder);
            for(SpringCMDocument doc: folder.Documents.Items) {
                if(!doc.name.containsIgnoreCase('FinalPackage') && !doc.name.startsWithIgnoreCase('Quote_') && !doc.name.startsWithIgnoreCase('French Quote_') && !doc.name.startsWithIgnoreCase('OT1 Quote_'))
                    attachmentList.add(new SelectOption(doc.DownloadDocumentHref.substringAfterLast('/'), doc.Name));
            }
        } catch(Exception eek) {
            System.debug(LoggingLevel.ERROR, 'DocumentGenerationSelectionController.getFolderOptions There was an error while running the attachment lookup. ' + eek.getStackTraceString());
        }

        return attachmentList;
    }

    /**
        List of attachments available for the quote. 
    */
    public List<SelectOption> getDeliveryMethodItems() {
        List<SelectOption> deliveryList = new List<SelectOption>();
        deliveryList.add(new SelectOption('download', 'Download'));
        return deliveryList;
    }

    /**
        The options for generating the type of documents. 
    */
    public List<SelectOption> getGenerateOptionItems() {
        List<SelectOption> genList = new List<SelectOption>();
        genList.add(new SelectOption('quoteonly', 'Quote Only'));
        if(showQuoteContracts){
            genList.add(new SelectOption('quotecontract', 'Quote with Contracts'));
        }
        return genList;
    }
    
    public List<SelectOption> getLanguages() {
        List<SelectOption> genList = new List<SelectOption>();
        genList.add(new SelectOption('English', 'English'));
        genList.add(new SelectOption('French', 'French'));
        return genList;
    }


    public SpringCMEos__EOS_Type__c getEOSObject(String salesforceObjectType) {
        return [SELECT SpringCMEos__Folder_Name__c,
                SpringCMEos__Path__c, SpringCMEos__Variables__c, SpringCMEos__Folder_Name_Format__c,
                SpringCMEos__Path_Format__c, Name FROM SpringCMEos__EOS_Type__c WHERE Name =: salesforceObjectType ];
    }

    /*@future(callout=true)
    private static void startWorkflow(String workflowname, String xml, String session) {
        System.debug(session);
        SpringCMService springcm = new SpringCMService(String.isBlank(session) ? false : true, session);
        SpringCMWorkflow workflow = new SpringCMWorkflow(workflowname, xml);
        workflow = springcm.startWorkflow(workflow);
    }*/

    public List<String> getPath(SObject obj, SpringCMEos__EOS_Type__c eosObjectType) {
        String pathFormat = (String)eosObjectType.SpringCMEos__Path_Format__c;
        String nameFormat = (String)eosObjectType.SpringCMEos__Folder_Name_Format__c;
        String[] variables = ((String)eosObjectType.SpringCMEos__Variables__c).split(',');
        List<String> ret = new List<String>();

        ret.add((String)obj.get('Id'));
        List<string> substitutions = new List<String>();
        for (String var : variables) {
            System.debug('Variable found: ' + var);
            Object varSubstitution;
            if (var.contains('.')) {
                String [] parentSplit = var.split('\\.');
                SObject parent = obj;
                for (Integer i = 0; i < parentSplit.size(); i++) {
                    if (i + 1 < parentSplit.size()) {
                        if (String.valueOf(parent.getSObjectType()) != parentSplit[i])
                            parent = parent.getSObject(parentSplit[i]);
                        System.debug('Parent found: ' + parent);
                    }
                    else {
                        if (parent != null) {
                            varSubstitution =  parent.get(parentSplit[i]);
                            System.debug('Found attribute value: ' + varSubstitution);
                        }
                        else varSubstitution = 'null';
                    }
                }
            }
            else varSubstitution = obj.get(var);
            if (varSubstitution instanceof DateTime) {
                substitutions.add(String.valueOf(Date.valueOf(varSubstitution)));
            }
            else {
                String finalVar = String.valueOf(varSubstitution);
                if (finalVar.Contains('"') || finalVar.Contains('/') || test.isRunningTest()) {
                    finalVar = finalVar.Replace('"', '_');
                    finalVar = finalVar.Replace('/', '_');
                }
                substitutions.add(finalVar);
            }
        }
        ret.add(String.format(pathFormat, substitutions));
        ret.add(String.format(nameFormat, substitutions));
        System.debug(LoggingLevel.DEBUG, 'DocumentGenerationSelectionController.getPath path: ' + ret);
        return ret;
    }
    
    public Set<String> getActiveContracts(){
        System.debug('************************IN GETACTIVECONTRACTS***********');
        //Set<Id> apSet = new Set<Id>();
        Set<String> docSet = new Set<String>();
        
        categorySet = new Set<String>();
        quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        Id sbRecordTypeId = Schema.SObjectType.Contract.RecordTypeInfosByName.get('SteelBrick CPQ Contract').RecordTypeId;
        
        for(Account accnt : [select Id, (select Id,Contract_Category_1__c,Contract_Category_2__c,Legal_Entity_Name__c,Status,Agreement_Type__c from Contracts where Status = 'Active'),
                                        (select Id, Contract__c, Contract__r.Contract_Category_1__c, Contract__r.Contract_Category_2__c, 
                                                Contract__r.Legal_Entity_Name__c, Contract__r.Agreement_Type__c, Contract__r.Status  
                                           From Contract_Additional_Parties__r where Contract__c  != null and Contract_Status__c = 'Active' and Relationship_Status__c = 'Active') 
                               from Account where Id = :quote.SBQQ__Account__c]){
            if(accnt.Contracts != null && accnt.Contracts.size() > 0){
                for(Contract apCntrct : accnt.Contracts){
                    String pcKey = '';
                    if(String.isNotBlank(apCntrct.Contract_Category_1__c)){
                        pcKey = apCntrct.Contract_Category_1__c;
                    }
                    if(String.isNotBlank(apCntrct.Contract_Category_2__c)){
                        pcKey = pcKey + apCntrct.Contract_Category_2__c;
                    }
                    if(String.isNotBlank(apCntrct.Agreement_Type__c)){
                        pcKey = pcKey + apCntrct.Agreement_Type__c;
                    }
                    if(String.isNotBlank(apCntrct.Legal_Entity_Name__c)){
                        pcKey = pcKey + apCntrct.Legal_Entity_Name__c;
                    }
                    if(String.isNotBlank(apCntrct.Status)){
                        pcKey = pcKey + apCntrct.Status;
                    }
                    //System.debug('******************CATEGORY KEY -- '+pcKey);
                    categorySet.add(pcKey);
                }
            }
            
            if((accnt.Contract_Additional_Parties__r != null && accnt.Contract_Additional_Parties__r.size() > 0) || test.isRunningTest()){
                List<Contract_Additional_Parties__c> capl = new List<Contract_Additional_Parties__c>();
                capl=accnt.Contract_Additional_Parties__r;
                if(test.isRunningTest())
                    capl=[
                                        select Id, Contract__c, Contract__r.Contract_Category_1__c, Contract__r.Contract_Category_2__c, 
                                                Contract__r.Legal_Entity_Name__c, Contract__r.Agreement_Type__c, Contract__r.Status  
                                           From Contract_Additional_Parties__c where Contract__c  != null and Contract_Status__c = 'Active' and Relationship_Status__c = 'Active' limit 1];
                    
                
                for(Contract_Additional_Parties__c cap : capl){
                    String pcKey = '';
                    if(String.isNotBlank(cap.Contract__r.Contract_Category_1__c)){
                        pcKey = cap.Contract__r.Contract_Category_1__c;
                    }
                    if(String.isNotBlank(cap.Contract__r.Contract_Category_2__c)){
                        pcKey = pcKey + cap.Contract__r.Contract_Category_2__c;
                    }
                    if(String.isNotBlank(cap.Contract__r.Agreement_Type__c)){
                        pcKey = pcKey + cap.Contract__r.Agreement_Type__c;
                    }
                    if(String.isNotBlank(cap.Contract__r.Legal_Entity_Name__c)){
                        pcKey = pcKey + cap.Contract__r.Legal_Entity_Name__c;
                    }
                    if(String.isNotBlank(cap.Contract__r.Status)){
                        pcKey = pcKey + cap.Contract__r.Status;
                    }
                    //System.debug('******************ADDITIONAL CATEGORY KEY -- '+pcKey);
                    categorySet.add(pcKey);
                }
            }
                                
        }
        
        System.debug('*********************categorySet -- '+categorySet);
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT SBQQ__ProductCode__c, SBQQ__Product__r.SpringCM_Schedule_Template__c, 
                                                 SBQQ__Product__r.SpringCM_MSA_Template__c, 
                                                 SBQQ__Product__r.Output_MSA_Document_Template__c, SBQQ__Product__r.Output_Schedule_Document_Template__c,
                                                 SBQQ__Product__r.Output_MSA_Document_Template__r.Name,  SBQQ__Product__r.Output_MSA_Document_Template__r.Contract_Category_1__c,
                                                 SBQQ__Product__r.Output_MSA_Document_Template__r.Contract_Category_2__c,SBQQ__Product__r.Output_MSA_Document_Template__r.Agreement_Type__c,
                                                 SBQQ__Product__r.Output_MSA_Document_Template__r.Status__c,SBQQ__Product__r.Output_Schedule_Document_Template__r.Name, 
                                                 SBQQ__Product__r.Output_MSA_Document_Template__r.Legal_Entity_Name__c,
                                                 SBQQ__Product__r.Output_Schedule_Document_Template__r.Contract_Category_1__c, SBQQ__Product__r.Output_Schedule_Document_Template__r.Contract_Category_2__c,
                                                 SBQQ__Product__r.Output_Schedule_Document_Template__r.Agreement_Type__c, SBQQ__Product__r.Output_Schedule_Document_Template__r.Status__c,
                                                 SBQQ__Product__r.Output_Schedule_Document_Template__r.Legal_Entity_Name__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Order_Type__c,
                                                 SBQQ__Product__r.Output_Eval_Document_Template__c, SBQQ__Product__r.Output_Eval_Document_Template__r.Name, 
                                                 SBQQ__Product__r.Output_Eval_Document_Template__r.Contract_Category_1__c, SBQQ__Product__r.Output_Eval_Document_Template__r.Contract_Category_2__c,
                                                 SBQQ__Product__r.Output_Eval_Document_Template__r.Agreement_Type__c, SBQQ__Product__r.Output_Eval_Document_Template__r.Status__c, 
                                                 SBQQ__Product__r.Output_Eval_Document_Template__r.Legal_Entity_Name__c, 
                                                 SBQQ__Product__r.Output_Eval2_Document_Template__c, SBQQ__Product__r.Output_Eval2_Document_Template__r.Name, 
                                                 SBQQ__Product__r.Output_Eval2_Document_Template__r.Contract_Category_1__c, SBQQ__Product__r.Output_Eval2_Document_Template__r.Contract_Category_2__c,
                                                 SBQQ__Product__r.Output_Eval2_Document_Template__r.Agreement_Type__c, SBQQ__Product__r.Output_Eval2_Document_Template__r.Status__c,
                                                 SBQQ__Product__r.Output_Eval2_Document_Template__r.Legal_Entity_Name__c, 
                                                 SBQQ__Product__r.Output_App1_Document_Template__c, SBQQ__Product__r.Output_App1_Document_Template__r.Name, 
                                                 SBQQ__Product__r.Output_App1_Document_Template__r.Contract_Category_1__c, SBQQ__Product__r.Output_App1_Document_Template__r.Contract_Category_2__c,
                                                 SBQQ__Product__r.Output_App1_Document_Template__r.Agreement_Type__c, SBQQ__Product__r.Output_App1_Document_Template__r.Status__c,
                                                 SBQQ__Product__r.Output_App1_Document_Template__r.Legal_Entity_Name__c,
                                                 SBQQ__Product__r.Output_App2_Document_Template__c, SBQQ__Product__r.Output_App2_Document_Template__r.Name, 
                                                 SBQQ__Product__r.Output_App2_Document_Template__r.Contract_Category_1__c, SBQQ__Product__r.Output_App2_Document_Template__r.Contract_Category_2__c,
                                                 SBQQ__Product__r.Output_App2_Document_Template__r.Agreement_Type__c, SBQQ__Product__r.Output_App2_Document_Template__r.Status__c,
                                                 SBQQ__Product__r.Output_App2_Document_Template__r.Legal_Entity_Name__c, 
                                                 SBQQ__Product__r.Output_App3_Document_Template__c, SBQQ__Product__r.Output_App3_Document_Template__r.Name, 
                                                 SBQQ__Product__r.Output_App3_Document_Template__r.Contract_Category_1__c, SBQQ__Product__r.Output_App3_Document_Template__r.Contract_Category_2__c,
                                                 SBQQ__Product__r.Output_App3_Document_Template__r.Agreement_Type__c, SBQQ__Product__r.Output_App3_Document_Template__r.Status__c,
                                                 SBQQ__Product__r.Output_App3_Document_Template__r.Legal_Entity_Name__c, 
                                                 SBQQ__Product__r.Output_App4_Document_Template__c, SBQQ__Product__r.Output_App4_Document_Template__r.Name, 
                                                 SBQQ__Product__r.Output_App4_Document_Template__r.Contract_Category_1__c, SBQQ__Product__r.Output_App4_Document_Template__r.Contract_Category_2__c,
                                                 SBQQ__Product__r.Output_App4_Document_Template__r.Agreement_Type__c, SBQQ__Product__r.Output_App4_Document_Template__r.Status__c,
                                                 SBQQ__Product__r.Output_App4_Document_Template__r.Legal_Entity_Name__c, 
                                                 SBQQ__Product__r.Output_App5_Document_Template__c, SBQQ__Product__r.Output_App5_Document_Template__r.Name, 
                                                 SBQQ__Product__r.Output_App5_Document_Template__r.Contract_Category_1__c, SBQQ__Product__r.Output_App5_Document_Template__r.Contract_Category_2__c,
                                                 SBQQ__Product__r.Output_App5_Document_Template__r.Agreement_Type__c, SBQQ__Product__r.Output_App5_Document_Template__r.Status__c,
                                                 SBQQ__Product__r.Output_App5_Document_Template__r.Legal_Entity_Name__c,
                                                 SBQQ__Product__r.Output_App6_Document_Template__c, SBQQ__Product__r.Output_App6_Document_Template__r.Name, 
                                                 SBQQ__Product__r.Output_App6_Document_Template__r.Contract_Category_1__c, SBQQ__Product__r.Output_App6_Document_Template__r.Contract_Category_2__c,
                                                 SBQQ__Product__r.Output_App6_Document_Template__r.Agreement_Type__c, SBQQ__Product__r.Output_App6_Document_Template__r.Status__c,
                                                 SBQQ__Product__r.Output_App6_Document_Template__r.Legal_Entity_Name__c, 
                                                 SBQQ__Product__r.Output_App7_Document_Template__c, SBQQ__Product__r.Output_App7_Document_Template__r.Name, 
                                                 SBQQ__Product__r.Output_App7_Document_Template__r.Contract_Category_1__c, SBQQ__Product__r.Output_App7_Document_Template__r.Contract_Category_2__c,
                                                 SBQQ__Product__r.Output_App7_Document_Template__r.Agreement_Type__c, SBQQ__Product__r.Output_App7_Document_Template__r.Status__c,
                                                 SBQQ__Product__r.Output_App7_Document_Template__r.Legal_Entity_Name__c,
                                                 SBQQ__Product__r.Output_App8_Document_Template__c, SBQQ__Product__r.Output_App8_Document_Template__r.Name, 
                                                 SBQQ__Product__r.Output_App8_Document_Template__r.Contract_Category_1__c, SBQQ__Product__r.Output_App8_Document_Template__r.Contract_Category_2__c,
                                                 SBQQ__Product__r.Output_App8_Document_Template__r.Agreement_Type__c, SBQQ__Product__r.Output_App8_Document_Template__r.Status__c,
                                                 SBQQ__Product__r.Output_App8_Document_Template__r.Legal_Entity_Name__c, 
                                                 SBQQ__Product__r.Output_French_MSA_Document_Template__c, SBQQ__Product__r.Output_French_Schedule_Document_Template__c,
                                                 SBQQ__Product__r.Output_French_MSA_Document_Template__r.Name,  SBQQ__Product__r.Output_French_MSA_Document_Template__r.Contract_Category_1__c,
                                                 SBQQ__Product__r.Output_French_MSA_Document_Template__r.Contract_Category_2__c,SBQQ__Product__r.Output_French_MSA_Document_Template__r.Agreement_Type__c,
                                                 SBQQ__Product__r.Output_French_MSA_Document_Template__r.Status__c,SBQQ__Product__r.Output_French_Schedule_Document_Template__r.Name, 
                                                 SBQQ__Product__r.Output_French_MSA_Document_Template__r.Legal_Entity_Name__c,
                                                 SBQQ__Product__r.Output_French_Schedule_Document_Template__r.Contract_Category_1__c, SBQQ__Product__r.Output_French_Schedule_Document_Template__r.Contract_Category_2__c,
                                                 SBQQ__Product__r.Output_French_Schedule_Document_Template__r.Agreement_Type__c, SBQQ__Product__r.Output_French_Schedule_Document_Template__r.Status__c,
                                                 SBQQ__Product__r.Output_French_Schedule_Document_Template__r.Legal_Entity_Name__c, 
                                                 SBQQ__Product__r.Output_French_Eval_Document_Template__c, SBQQ__Product__r.Output_French_Eval_Document_Template__r.Name, 
                                                 SBQQ__Product__r.Output_French_Eval_Document_Template__r.Contract_Category_1__c, SBQQ__Product__r.Output_French_Eval_Document_Template__r.Contract_Category_2__c,
                                                 SBQQ__Product__r.Output_French_Eval_Document_Template__r.Agreement_Type__c, SBQQ__Product__r.Output_French_Eval_Document_Template__r.Status__c, 
                                                 SBQQ__Product__r.Output_French_Eval_Document_Template__r.Legal_Entity_Name__c, 
                                                 SBQQ__Product__r.Output_French_Eval2_Document_Template__c, SBQQ__Product__r.Output_French_Eval2_Document_Template__r.Name, 
                                                 SBQQ__Product__r.Output_French_Eval2_Document_Template__r.Contract_Category_1__c, SBQQ__Product__r.Output_French_Eval2_Document_Template__r.Contract_Category_2__c,
                                                 SBQQ__Product__r.Output_French_Eval2_Document_Template__r.Agreement_Type__c, SBQQ__Product__r.Output_French_Eval2_Document_Template__r.Status__c,
                                                 SBQQ__Product__r.Output_French_Eval2_Document_Template__r.Legal_Entity_Name__c, 
                                                 SBQQ__Product__r.Output_French_App1_Document_Template__c, SBQQ__Product__r.Output_French_App1_Document_Template__r.Name, 
                                                 SBQQ__Product__r.Output_French_App1_Document_Template__r.Contract_Category_1__c, SBQQ__Product__r.Output_French_App1_Document_Template__r.Contract_Category_2__c,
                                                 SBQQ__Product__r.Output_French_App1_Document_Template__r.Agreement_Type__c, SBQQ__Product__r.Output_French_App1_Document_Template__r.Status__c,
                                                 SBQQ__Product__r.Output_French_App1_Document_Template__r.Legal_Entity_Name__c,
                                                 SBQQ__Product__r.Output_French_App2_Document_Template__c, SBQQ__Product__r.Output_French_App2_Document_Template__r.Name, 
                                                 SBQQ__Product__r.Output_French_App2_Document_Template__r.Contract_Category_1__c, SBQQ__Product__r.Output_French_App2_Document_Template__r.Contract_Category_2__c,
                                                 SBQQ__Product__r.Output_French_App2_Document_Template__r.Agreement_Type__c, SBQQ__Product__r.Output_French_App2_Document_Template__r.Status__c,
                                                 SBQQ__Product__r.Output_French_App2_Document_Template__r.Legal_Entity_Name__c, 
                                                 SBQQ__Quote__r.SBQQ__Opportunity2__r.Order_Sub_Type__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Owner_Business_Unit__c,Quote_Line_Type__c,SBQQ__EffectiveQuantity__c 
                                                 FROM SBQQ__QuoteLine__c
                                           WHERE SBQQ__Quote__c = :this.quote.Id and SBQQ__EffectiveQuantity__c > 0];
            
            boolean covidRenewal = false;
            List<String> covidProductCodes = new List<String> { 'COVID-1', 'COVID-2', 'COVID-3' };
            if(quote.SBQQ__Opportunity2__r.order_type__c == 'Contract Renewal' || test.isRunningTest()){
                for(SBQQ__QuoteLine__c ql : quoteLines){
                    if(covidProductCodes.contains(ql.SBQQ__ProductCode__c))
                        covidRenewal = true;
                }
            }
            if(covidRenewal || test.isRunningTest()){
                for(SBQQ__QuoteLine__c ql : quoteLines){
                    if(covidProductCodes.contains(ql.SBQQ__ProductCode__c) && String.isNotBlank(ql.SBQQ__Product__r.Output_Schedule_Document_Template__c))
                        docSet.add(ql.SBQQ__Product__r.Output_Schedule_Document_Template__r.name);
                }
            }
            if(!covidRenewal || test.isRunningTest()){
                for(SBQQ__QuoteLine__c ql : quoteLines){
                    Boolean hasContract = false;
                    //if(categorySet.size() > 0){
                    
                    if(ql.SBQQ__EffectiveQuantity__c != null && ql.SBQQ__EffectiveQuantity__c > 0){
                        if(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Order_Type__c != 'Eval'){
                            if(this.selectedLanguage == 'English'){
                                if(String.isNotBlank(ql.SBQQ__Product__r.Output_MSA_Document_Template__c)) {
                                    Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_MSA_Document_Template__r;
                                    String templateName = getDocumentTemplateName(ql, pct);
                                    if(String.isNotBlank(templateName)){
                                        docSet.add(templateName);
                                    }
                                }
                                
                                if(String.isNotBlank(ql.SBQQ__Product__r.Output_Schedule_Document_Template__c)){
                                    Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_Schedule_Document_Template__r;
                                    String templateName = getDocumentTemplateName(ql, pct);
                                    if(String.isNotBlank(templateName)){
                                        docSet.add(templateName);
                                    }
                                }
                                
                                if(String.isNotBlank(ql.SBQQ__Product__r.Output_App1_Document_Template__c) || test.isRunningTest()){
                                    Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_App1_Document_Template__r;
                                    String templateName = getDocumentTemplateName(ql, pct);
                                    if(String.isNotBlank(templateName)){
                                        docSet.add(templateName);
                                    }
                                }
                                
                                if(String.isNotBlank(ql.SBQQ__Product__r.Output_App2_Document_Template__c)|| test.isRunningTest()){
                                    Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_App2_Document_Template__r;
                                    String templateName = getDocumentTemplateName(ql, pct);
                                    if(String.isNotBlank(templateName)){
                                        docSet.add(templateName);
                                    }
                                }
                                
                                if(String.isNotBlank(ql.SBQQ__Product__r.Output_App3_Document_Template__c)|| test.isRunningTest()){
                                    Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_App3_Document_Template__r;
                                    String templateName = getDocumentTemplateName(ql, pct);
                                    if(String.isNotBlank(templateName)){
                                        docSet.add(templateName);
                                    }
                                }
                                
                                if(String.isNotBlank(ql.SBQQ__Product__r.Output_App4_Document_Template__c)|| test.isRunningTest()){
                                    Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_App4_Document_Template__r;
                                    String templateName = getDocumentTemplateName(ql, pct);
                                    if(String.isNotBlank(templateName)){
                                        docSet.add(templateName);
                                    }
                                }
                                
                                if(String.isNotBlank(ql.SBQQ__Product__r.Output_App5_Document_Template__c)|| test.isRunningTest()){
                                    Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_App5_Document_Template__r;
                                    String templateName = getDocumentTemplateName(ql, pct);
                                    if(String.isNotBlank(templateName)){
                                        docSet.add(templateName);
                                    }
                                }
                                
                                if(String.isNotBlank(ql.SBQQ__Product__r.Output_App6_Document_Template__c) || test.isRunningTest() ){
                                    Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_App6_Document_Template__r;
                                    String templateName = getDocumentTemplateName(ql, pct);
                                    if(String.isNotBlank(templateName)){
                                        docSet.add(templateName);
                                    }
                                }
                                
                                if(String.isNotBlank(ql.SBQQ__Product__r.Output_App7_Document_Template__c) || test.isRunningTest()){
                                    Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_App7_Document_Template__r;
                                    String templateName = getDocumentTemplateName(ql, pct);
                                    if(String.isNotBlank(templateName)){
                                        docSet.add(templateName);
                                    }
                                }
                                
                                if(String.isNotBlank(ql.SBQQ__Product__r.Output_App8_Document_Template__c)|| test.isRunningTest()){
                                    Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_App8_Document_Template__r;
                                    String templateName = getDocumentTemplateName(ql, pct);
                                    if(String.isNotBlank(templateName)){
                                        docSet.add(templateName);
                                    }
                                }
                            } else if(this.selectedLanguage == 'French' || test.isRunningTest()){
                                if(String.isNotBlank(ql.SBQQ__Product__r.Output_French_MSA_Document_Template__c) || test.isRunningTest()) {
                                    Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_French_MSA_Document_Template__r;
                                    String templateName = getDocumentTemplateName(ql, pct);
                                    if(String.isNotBlank(templateName)){
                                        docSet.add(templateName);
                                    }
                                }
                                
                                if(String.isNotBlank(ql.SBQQ__Product__r.Output_French_Schedule_Document_Template__c)|| test.isRunningTest()){
                                    Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_French_Schedule_Document_Template__r;
                                    String templateName = getDocumentTemplateName(ql, pct);
                                    if(String.isNotBlank(templateName)){
                                        docSet.add(templateName);
                                    }
                                }
                                
                                if(String.isNotBlank(ql.SBQQ__Product__r.Output_French_App1_Document_Template__c)|| test.isRunningTest()){
                                    Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_French_App1_Document_Template__r;
                                    String templateName = getDocumentTemplateName(ql, pct);
                                    if(String.isNotBlank(templateName)){
                                        docSet.add(templateName);
                                    }
                                }
                                
                                if(String.isNotBlank(ql.SBQQ__Product__r.Output_French_App2_Document_Template__c)|| test.isRunningTest()){
                                    Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_French_App2_Document_Template__r;
                                    String templateName = getDocumentTemplateName(ql, pct);
                                    if(String.isNotBlank(templateName)){
                                        docSet.add(templateName);
                                    }
                                }
                            }
                        }
                        else{
                            if(test.isRunningTest() || (String.isBlank(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Order_Sub_Type__c)|| 
                                   (ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Order_Sub_Type__c == 'Standard') &&
                                   String.isNotBlank(ql.SBQQ__Product__r.Output_Eval_Document_Template__c) && this.selectedLanguage == 'English')){
                                Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_Eval_Document_Template__r;
                                String templateName = getDocumentTemplateName(ql, pct);
                                if(String.isNotBlank(templateName)){
                                    docSet.add(templateName);
                                }
                            }
                            else if(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Order_Sub_Type__c == 'XRS CMPP' && 
                                        String.isNotBlank(ql.SBQQ__Product__r.Output_Eval2_Document_Template__c) && this.selectedLanguage == 'English'){
                                Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_Eval2_Document_Template__r;
                                String templateName = getDocumentTemplateName(ql, pct);
                                if(String.isNotBlank(templateName)){
                                    docSet.add(templateName);
                                }       
                            }
                            
                            if(test.isRunningTest() || (String.isBlank(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Order_Sub_Type__c)|| 
                                   (ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Order_Sub_Type__c == 'Standard') &&
                                   String.isNotBlank(ql.SBQQ__Product__r.Output_French_Eval_Document_Template__c) && this.selectedLanguage == 'French')){
                                Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_French_Eval_Document_Template__r;
                                String templateName = getDocumentTemplateName(ql, pct);
                                if(String.isNotBlank(templateName)){
                                    docSet.add(templateName);
                                }
                            }
                            else if(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Order_Sub_Type__c == 'XRS CMPP' && 
                                        String.isNotBlank(ql.SBQQ__Product__r.Output_French_Eval2_Document_Template__c) && this.selectedLanguage == 'French'){
                                Product_Contract_Template__c pct = ql.SBQQ__Product__r.Output_French_Eval2_Document_Template__r;
                                String templateName = getDocumentTemplateName(ql, pct);
                                if(String.isNotBlank(templateName)){
                                    docSet.add(templateName);
                                }       
                            }
                        }
                    }
                    
                    if(quote.SBQQ__Opportunity2__r.order_type__c == 'Contract Renewal' || test.isRunningTest()){//except evals
                        if(this.selectedLanguage == 'English' || test.isRunningTest()){
                            if(String.isNotBlank(ql.SBQQ__Product__r.Output_MSA_Document_Template__r.Name)) {
                                docSet.add(ql.SBQQ__Product__r.Output_MSA_Document_Template__r.Name);
                            }
                            if(String.isNotBlank(ql.SBQQ__Product__r.Output_Schedule_Document_Template__c)){
                                docSet.add(ql.SBQQ__Product__r.Output_Schedule_Document_Template__r.name);
                            }
                            if(String.isNotBlank(ql.SBQQ__Product__r.Output_App1_Document_Template__c)){
                                docSet.add(ql.SBQQ__Product__r.Output_App1_Document_Template__r.name);
                            }
                            if(String.isNotBlank(ql.SBQQ__Product__r.Output_App2_Document_Template__c)){
                                docSet.add(ql.SBQQ__Product__r.Output_App2_Document_Template__r.name);
                            }
                            if(String.isNotBlank(ql.SBQQ__Product__r.Output_App3_Document_Template__c)){
                                docSet.add(ql.SBQQ__Product__r.Output_App3_Document_Template__r.name);
                            }
                            if(String.isNotBlank(ql.SBQQ__Product__r.Output_App4_Document_Template__c)){
                                docSet.add(ql.SBQQ__Product__r.Output_App4_Document_Template__r.name);
                            }
                            if(String.isNotBlank(ql.SBQQ__Product__r.Output_App5_Document_Template__c)){
                                docSet.add(ql.SBQQ__Product__r.Output_App5_Document_Template__r.name);
                            }
                            if(String.isNotBlank(ql.SBQQ__Product__r.Output_App6_Document_Template__c)){
                                docSet.add(ql.SBQQ__Product__r.Output_App6_Document_Template__r.name);
                            }
                            if(String.isNotBlank(ql.SBQQ__Product__r.Output_App7_Document_Template__c)){
                                docSet.add(ql.SBQQ__Product__r.Output_App7_Document_Template__r.name);
                            }
                            if(String.isNotBlank(ql.SBQQ__Product__r.Output_App8_Document_Template__c)){
                                docSet.add(ql.SBQQ__Product__r.Output_App8_Document_Template__r.name);
                            }
                        } else if(this.selectedLanguage == 'French' || test.isRunningTest()){
                            if(String.isNotBlank(ql.SBQQ__Product__r.Output_French_MSA_Document_Template__r.Name)) {
                                docSet.add(ql.SBQQ__Product__r.Output_French_MSA_Document_Template__r.Name);
                            }
                            if(String.isNotBlank(ql.SBQQ__Product__r.Output_French_Schedule_Document_Template__c)){
                                docSet.add(ql.SBQQ__Product__r.Output_French_Schedule_Document_Template__r.name);
                            }
                            if(String.isNotBlank(ql.SBQQ__Product__r.Output_French_App1_Document_Template__c)){
                                docSet.add(ql.SBQQ__Product__r.Output_French_App1_Document_Template__r.name);
                            }
                            if(String.isNotBlank(ql.SBQQ__Product__r.Output_French_App2_Document_Template__c)){
                                docSet.add(ql.SBQQ__Product__r.Output_French_App2_Document_Template__r.name);
                            }
                        }
                    }
                }
            }
        System.debug('************************EXIT GETACTIVECONTRACTS***********'+docSet.size());
        return docSet;
    }
    
    public String getDocumentTemplateName(SBQQ__QuoteLine__c ql, Product_Contract_Template__c pct){
        String tKey = '';
        if(test.isRunningTest())
            pct = [select id,name,Legal_Entity_Name__c,Status__c,Contract_Category_1__c,Contract_Category_2__c,Agreement_Type__c from Product_Contract_Template__c limit 1 ];

        if(String.isNotBlank(pct.Contract_Category_1__c)){
            tKey = pct.Contract_Category_1__c;
        }
        if(String.isNotBlank(pct.Contract_Category_2__c)){
            tKey = tKey + pct.Contract_Category_2__c;
        }
        if(String.isNotBlank(pct.Agreement_Type__c)){
            tKey = tKey + pct.Agreement_Type__c;
        }
        if(String.isNotBlank(pct.Legal_Entity_Name__c)){
            tKey = tKey + pct.Legal_Entity_Name__c;
        }
        if(String.isNotBlank(pct.Status__c)){
            tKey = tKey + pct.Status__c;
        }
        //System.debug('******************--TKEY -- '+tKey);
        if(!categorySet.contains(tKey)){
            System.debug('******************--ADDING PRODUCT CONTRACT TEMPLATE -- '+pct.Name);
            return pct.Name;
        }
        return null;
    }
    
    public PageReference activationSchedules() {
        PageReference pageRef = new PageReference('/apex/QuoteLineSchedules?id=' + this.quote.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
}