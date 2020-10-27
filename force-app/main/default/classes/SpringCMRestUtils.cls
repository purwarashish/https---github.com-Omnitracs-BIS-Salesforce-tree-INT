public with sharing class SpringCMRestUtils {
    
    public static void StartWorkflowAccount (List <Account> newAccntList, Map<Id, Account> oldAccntMap, String sfType, String workFlowname) {
        if (String.isBlank(workflowname)) return;
        if (String.isBlank(sfType)) return;
        /*SpringCMEos__EOS_Type__c eos = getEOSObject(sfType);
        String selectclause = eos.SpringCMEos__Variables__c + (eos.SpringCMEos__Variables__c.containsNone('Id')
                ? (eos.SpringCMEos__Variables__c.containsNone('Name')
                    ? ', Id, Name'
                    : ', Id')
                : (eos.SpringCMEos__Variables__c.containsNone('Name')
                    ? ', Name'
                    : ''));

        String xml = buildWorkflowXML(listofsobjects, eos);*/
        String xml = buildWorkflowXMLAccount(newAccntList, oldAccntMap);
        startWorkflow(workFlowName, xml, UserInfo.getSessionId());
    }
    
    public static void StartWorkflowTermination (List <Contract> newContractList, String workFlowname) {
        String xml = buildWorkflowXMLTermination(newContractList);
        System.debug('********* xml -- '+xml);
        startWorkflow(workFlowName, xml, UserInfo.getSessionId());
    }
    
    private static String buildWorkflowXMLAccount(List <Account> newAccntList, Map<Id, Account> oldAccntMap) {
        string xml = '<sfData><records>';
        for(Account newAccnt : newAccntList){
            xml += '<eos>';
            xml += '<id>' + newAccnt.Id + '</id>';
            xml += '<sfType>Account</sfType>';
            xml += '<accountName>' + newAccnt.Name + '</accountName>';
            xml += '<oldName>' + oldAccntMap.get(newAccnt.Id).Legal_Name__c + '</oldName>';
            xml += '<newName>' + newAccnt.Legal_Name__c + '</newName>';
            xml += '</eos>';
        }
        xml += '</records></sfData>';
        return xml;
    }
    
    private static String buildWorkflowXMLTermination(List <Contract> newContractList) {
        string xml = '<sfData><records>';
        for(Contract newContract : newContractList){
            xml += '<Contract>';
            xml += '<id>' + newContract.Id + '</id>';
            xml += '<sfType>Contract</sfType>';
            xml += '<sfName>' +newContract.ContractNumber + '</sfName>';
            xml += '<sfPath>/Salesforce/Accounts/'+newContract.Account.name+'/Contracts</sfPath>';
            xml += '<TerminationDate>'+((newContract.EndDate != null)?newContract.EndDate:Date.Today())+'</TerminationDate>';
            if(String.isNotBlank(newContract.Parent_Contract__c)){
                xml += '<ParentContract>'+newContract.Parent_Contract__r.name+'</ParentContract>';
            }
            xml += '</Contract>';
        }
        xml += '</records></sfData>';
        return xml;
    }
    
    @future(callout=true)
    public static void startWorkflow(String workflowname, String xml, String session) {
        SpringCMService springcm = new SpringCMService(String.isBlank(session) ? false : true, session);
        SpringCMWorkflow workflow = new SpringCMWorkflow(workflowname, xml);
        workflow = springcm.startWorkflow(workflow);        
    }
    
}