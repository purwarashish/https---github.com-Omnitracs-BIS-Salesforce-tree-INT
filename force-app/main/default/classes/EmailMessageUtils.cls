global class EmailMessageUtils {
    public static void processTermination(EmailMessage[] emails) {
        for(EmailMessage em : emails){
            String subject = em.Subject;
            String textBody = em.TextBody;
            if(subject.startsWithIgnoreCase('AUTO') && subject.endsWithIgnoreCase('Approve') && textBody.startsWithIgnoreCase('The following AUTO transaction requires your completion') && (subject.contains('EARLY_TERMINATION') || subject.contains('STANDARD_TERMINATION') || subject.contains('SERVICE_SHUTOFF'))){
                try {
                    System.debug('Subject: ' + em.subject);
                    String[] emailLines = textBody.split('\n');
                    String acctCustId = '';
                    Set<String> productLineSet = new Set<String>();
                    Map<String, String> productSynonymMap = new Map<String, String>{'OV2' => 'MCP200', 'OTIS1' => 'IVG', 'OV' => 'MCP100S', 'OVT' => 'MCP100T'};
                    Set<String> productSynonymSet = productSynonymMap.keySet();
                    boolean custAssetFlag = false;
                    boolean productFlag = false;
                    for(String line : emailLines){
                        if(custAssetFlag){
                            Pattern pat = Pattern.compile('[\\W]* ([0-9]+) [\\W]*');
                            Matcher matcher = pat.matcher(line);
                            Boolean matches = matcher.find();
                            if(matches){
                                acctCustId = matcher.group(1);
                                custAssetFlag = false;
                            }
                        }
                        if(productFlag){
                            if(String.isNotBlank(line)){
                                if(!line.containsIgnoreCase('CONTRACT DETAILS')){
                                    Pattern pat = Pattern.compile('([a-zA-Z0-9]+)');
                                    Matcher matcher = pat.matcher(line);
                                    Boolean matches = matcher.find();
                                    if(matches){
                                        String match = matcher.group(1);
                                        if(productSynonymSet.contains(match))
                                            productLineSet.add(productSynonymMap.get(match));
                                        productLineSet.add(match);
                                    }
                                }else{
                                    productFlag = false;
                                }
                            }
                        }
                        if(line.contains('Customer Name') && line.contains('Customer ID') && line.contains('Contact Name') && !custAssetFlag){
                            custAssetFlag = true;
                        }
                        if(line.containsIgnoreCase('Units to be returned by Customer') && !productFlag){
                            productFlag = true;
                        }
                    }
                    System.debug('Cust Id: ' + acctCustId);
                    System.debug('Product Set: ' + productLineSet);
                    if(String.isNotBlank(acctCustId)){
                        if(subject.contains('SERVICE_SHUTOFF')){
                            Account acct = [Select Id, Service_Shutoff_Requested__c, Service_Shutoff_Requested_Date__c from Account where QWBS_Cust_ID__c = :acctCustId LIMIT 1][0];
                            acct.Service_Shutoff_Requested__c = true;
                            acct.Service_Shutoff_Requested_Date__c = Date.Today();
                            update acct;
                        }else{
                            Set<String> chargeCodeSet = new Set<String>();
                            List<Line_Charge_Code_Mapping__c> chargeCodeList = [Select Charge_Code__c from Line_Charge_Code_Mapping__c where Product_Line__c IN :productLineSet];
                            for (Line_Charge_Code_Mapping__c item : chargeCodeList){
                                chargeCodeSet.add(item.Charge_Code__c);
                            }
                            List<Customer_Asset__c> custAssetList = [select Oracle_Id__c, Product__c, Account__r.QWBS_Cust_ID__c from Customer_Asset__c where Account__r.QWBS_Cust_ID__c = :acctCustId AND (Product_Line__c IN :productLineSet OR Oracle_Id__c IN :chargeCodeSet)];
                            System.debug('Size: ' + custAssetList.size());
                            System.debug(custAssetList);
                            Id cpqRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('SteelBrick CPQ Contract').getRecordTypeId();
                            Contract contract = (Test.isRunningTest() ? [Select Id, ContractNumber, of_Days_Remaining_in_Term__c from Contract where RecordType.Name = 'SteelBrick CPQ Contract' LIMIT 1][0] : [select Id, ContractNumber, of_Days_Remaining_in_Term__c from Contract where Account.QWBS_Cust_ID__c = :acctCustId AND RecordTypeId = :cpqRecordTypeId AND StartDate != null Order By StartDate DESC LIMIT 1][0]);
                            System.debug('Contract Number: ' + contract.contractNumber);
                            List<QuoteLineActionModelHolder> dataList = new List<QuoteLineActionModelHolder>();
                            List<QuoteLineActionModel> quoteLineModels = new List <QuoteLineActionModel>();
                            for (Customer_Asset__c custAsset : custAssetList){
                                QuoteLineActionModel model = new QuoteLineActionModel();
                                model.contractNumber = contract.contractNumber;
                                model.productId = custAsset.Product__c;
                                model.qty = 0;
                                model.isNew = FALSE;
                                model.optyOrderType = 'Decommission';
                                model.optyOrderSubType = 'Full Cancellation';
                                quoteLineModels.add(model);
                            }
                            Decimal daysRemaining = contract.of_Days_Remaining_in_Term__c;
                            Boolean isExpired = daysRemaining == null || daysRemaining <= 0;
                            QuoteLineActionModelHolder modelHolder = new QuoteLineActionModelHolder(contract.contractNumber, String.valueOf(contract.Id), false, quoteLineModels);
                            dataList.add(modelHolder);
                            Database.executeBatch(new MassAmendContractBatch(dataList, 'Account (Cust ID - ' + acctCustId + ') Termination'), 1);
                        }
                    }else{
                        SearchException e = new SearchException();
                        e.setMessage('Not able to find Account CUST ID from Termination email, maybe a parsing issue.');
                        throw e;
                    }
                }catch(Exception e) {
                    System.debug('Error Occured: ' + e.getMessage());
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'omnitracs.sfdc.noreply@omnitracs.com'];
                    if(owea.size() > 0){
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }else{
                        email.setSenderDisplayName('Termination Automation Job Status');
                    }
                    String[] toAddresses = new List<String> {UserInfo.getUserEmail()};
                    String[] ccAddresses = new List<String> {'yarafat@omnitracs.com'};
                    /*String[] toAddresses = new List<String> {'sales.ops@omnitracs.com',UserInfo.getUserEmail()};
                    String[] ccAddresses = new List<String> {'weisheit@omnitracs.com','yarafat@omnitracs.com'};*/

                    email.setSubject('Error Processing: ' + subject + ' Job Status');       

                    email.setToAddresses(toAddresses);
                    email.setCcAddresses(ccAddresses);        
                    email.setPlainTextBody('Error Processing Automated Job for: ' + subject + '\n\nError Details: ' + e.getMessage() + '\n\nPlease process the request manually.');

                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                }
            }
        }
    }
}