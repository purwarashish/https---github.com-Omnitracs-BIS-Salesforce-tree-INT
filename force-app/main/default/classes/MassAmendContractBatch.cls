global class MassAmendContractBatch implements Database.Batchable<Object>, Database.Stateful{
    
    public List<Object> modelList;
    public List<String> quoteIds = new List<String>();
    global String mailCsvContent;
    Id pricebookId;
    public String actionTxt;
    
    
    global MassAmendContractBatch(List<Object> dataList, String action){
        mailCsvContent = 'ContractNumber,Status,Add On Opportunity,Remarks,Additional Comments\n';
        pricebookId = (Test.isRunningTest() ? (TestUtils.getStandardPriceBook()).Id : [select Id from Pricebook2 where Name = 'Domestic PriceBook'][0].Id);
        modelList = dataList;
        actionTxt = String.isBlank(action) ? 'Contracts Mass Amend' : action;
    }
    
    // Start Method
    global List<Object> start(Database.BatchableContext BC){
        return modelList;
    }
  
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Object> quoteLineActionModelList){
        for(Object obj : quoteLineActionModelList){
            String mailContent = '';
            String lineErrors = '';
            QuoteLineActionModelHolder modelHolder = (QuoteLineActionModelHolder) obj;
            try{
                if(String.isNotBlank(modelHolder.contractId) && !modelHolder.isExpired){
                    String idInfo = '';
                    List<QuoteLineActionModel> quoteLineModels = modelHolder.modelList;
                    String quoteJSON = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', modelHolder.contractId, null);
                    QuoteModel quoteModel = (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
                    idInfo = quoteModel.record.Id + ':::';
                    //quoteIds.add(quoteModel.record.Id);
                    mailContent = modelHolder.contractNumber + ',Success,' + quoteModel.record.SBQQ__Opportunity2__c + ',Contract Amended successfully.';
                    Account acct = [Select Id, Name, OwnerId, QWBS_Cust_ID__c from Account where Id = :quoteModel.record.SBQQ__Account__c];
                    Opportunity oppty = [Select Id, Type, OwnerId, Order_Type__c, Order_Sub_Type__c, RecordTypeId from Opportunity where Id = :quoteModel.record.SBQQ__Opportunity2__c];
                    oppty.Type = 'Existing Customer';
                    oppty.Order_Type__c = String.isBlank(quoteLineModels[0].optyOrderType) ? 'Customer Portal' : quoteLineModels[0].optyOrderType;
                    oppty.Order_Sub_Type__c = String.isBlank(quoteLineModels[0].optyOrderSubType) ? 'AddOn' : quoteLineModels[0].optyOrderSubType;
                    oppty.Name = acct.QWBS_Cust_ID__c + ' – ' + oppty.Order_Sub_Type__c + ' – contract #' + quoteModel.record.SBQQ__MasterContract__r.ContractNumber;
                    oppty.RecordTypeId = String.isNotBlank(quoteLineModels[0].optyRecordType) ? Id.valueOf(quoteLineModels[0].optyRecordType) : oppty.RecordTypeId;
                    oppty.OwnerId = acct.OwnerId;
                    update oppty;
                    
                    Id requiredBy = null;
                    for(QuoteLineModel quoteLineModel : quoteModel.lineItems){
                        SBQQ__QuoteLine__c quoteLine = quoteLineModel.record;
                        if(quoteLine.isWrapper__c){
                            requiredBy = quoteLine.Id;
                            break;
                        }
                    }
                    List<ProductModel> productModels = new List<ProductModel>();
                    for(QuoteLineActionModel model : quoteLineModels){
                        if(model.isNew){
                            ProductReader reader = new ProductReader();
                            try{
                                ProductModel productModel = reader.read(model.productId, String.isNotBlank(model.priceBookId) ? model.priceBookId : pricebookId, String.isNotBlank(model.currencyCode) ? model.currencyCode : 'USD');
                                productModels.add(productModel);
                            }catch(Exception e){
                                lineErrors += String.isBlank(lineErrors) ? 'Issue Adding Product(s): ' + model.productId : ', ' + model.productId;
                            }
                        }
                    }
                    lineErrors = String.isBlank(lineErrors) ? '' : lineErrors + '. ';
                    if(productModels.size() > 0){
                        ProductAdder adder = new ProductAdder();
                        quoteModel = adder.add(quoteModel, productModels, 0);
                    }
                    List<String> oracleIds = new List<String>();
                    List<String> optSkuIds = new List<String>();
                    for(QuoteLineActionModel model : quoteLineModels){
                        if(String.isNotBlank(model.oracleId) && model.isNew){
                            oracleIds.add(model.oracleId);
                            optSkuIds.add(model.productId);
                        }
                    }
                    Map<String, SBQQ__ProductOption__c> idOptionMap = new Map<String, SBQQ__ProductOption__c>();
                    System.debug('OracleIds: ' + oracleIds);
                    System.debug('OptSkuIds: ' + optSkuIds);
                    System.debug('requiredBy: ' + requiredBy);
                    if(oracleIds.size() > 0){
                        List<SBQQ__ProductOption__c> optionList = [Select Id, SBQQ__Type__c, SBQQ__OptionalSKU__c from SBQQ__ProductOption__c where SBQQ__OptionalSKU__c in :optSkuIds AND Oracle_Id__c in :oracleIds];
                        System.debug('optionList: ' + optionList);
                        for(SBQQ__ProductOption__c option : optionList){
                            idOptionMap.put(option.SBQQ__OptionalSKU__c, option);
                        }
                    }
                    boolean isFirstError = true;
                    for(QuoteLineActionModel model : quoteLineModels){
                        QuoteLineModel[] lineItems = quoteModel.lineItems;
                        boolean flag = false;
                        for(QuoteLineModel quoteLineModel : lineItems){
                            Id quoteLineProduct = quoteLineModel.record.SBQQ__Product__c;
                            if(Id.valueOf(model.productId) == quoteLineProduct){
                                flag = true;
                                break;
                            }
                        }
                        if(!flag && !model.isNew){
                            lineErrors += isFirstError ? 'Issue Amending Product(s): ' + model.productId : ', ' + model.productId;
                            isFirstError = false;
                        }
                    }
                    lineErrors = String.isBlank(lineErrors) ? '' : ',"' + lineErrors + '"';
                    for(QuoteLineActionModel model : quoteLineModels){
                        QuoteLineModel[] lineItems = quoteModel.lineItems;
                        boolean flag = true;
                        System.debug('ModelProductId: ' + model.productId);
                        for(QuoteLineModel quoteLineModel : lineItems){
                            SBQQ__QuoteLine__c quoteLine = quoteLineModel.record;
                            Id quoteLineProduct = quoteLine.SBQQ__Product__c;
                            System.debug('quoteLineProduct: ' + quoteLineProduct + ' -- QuoteLineId' + quoteLine.Id);
                            if(quoteLine.SBQQ__Description__c != 'Wrapper' && Id.valueOf(model.productId) == quoteLineProduct && flag){
                                quoteLine.SBQQ__Quantity__c = String.isBlank(model.qtyType) ? model.qty : quoteLine.SBQQ__Quantity__c + model.qty;
                                if(model.isNew && model.finalUnitPrice != null && model.finalUnitPrice > 0){
                                    SBQQ__ProductOption__c option = idOptionMap.get(Id.valueOf(model.productId));
                                    if(null != option){
                                        quoteLine.SBQQ__ProductOption__c = option.Id;
                                        quoteLine.SBQQ__OptionType__c = option.SBQQ__Type__c;
                                    }
                                    if(null != requiredBy)
                                        quoteLine.SBQQ__RequiredBy__c = requiredBy;
                                    idInfo += Id.valueOf(model.productId) + ':' + String.valueOf(model.finalUnitPrice) + ':' + quoteLine.Id + ':' + model.oracleId + '@@@';
                                    //quoteLine.Additional_DiscQLE__c = quoteLine.SBQQ__OriginalPrice__c - model.finalUnitPrice;
                                    //quoteLine.AdditionalDiscountUnitQLE__c = '$';
                                }
                                /*if(model.additionalDisc != null && model.additionalDisc != 0){
                                    quoteLine.Additional_DiscQLE__c = model.additionalDisc;
                                    quoteLine.AdditionalDiscountUnitQLE__c = '$';
                                }*/
                                flag = false;
                                break;
                            }
                        }
                    }
                    quoteIds.add(idInfo);
                    QuoteSaver qs = new QuoteSaver();
                    qs.save(quoteModel);
                    System.debug('Contract: ' + modelHolder.contractNumber);
                }else{
                    mailContent = modelHolder.contractNumber + ',Failed,,' + (modelHolder.isExpired ? 'Not able to amend the expired Contract.' : 'No CPQ Contract exists with given Contract Number.');
                }
            }catch(Exception e){
                String errMsg = 'Error Occured: ' + e.getMessage();
                mailContent += String.isBlank(mailContent) ? modelHolder.contractNumber + ',Failed,,' + errMsg : ' But an ' + errMsg;
            }finally{
                mailCsvContent += mailContent + lineErrors + '\n';
            }
        }
    }
 
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
        System.debug('Batch Execution of ' + actionTxt + ' completed, proceeding with discounts if any and quote calculations.');
        
        String sEmailBody='Please see the attached file for details of the ' + actionTxt + ' processing.';
        Blob csvBlob = Blob.valueOf(mailCsvContent);
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        csvAttc.setFileName(actionTxt + '_Result.csv');
        csvAttc.setContentType('text/csv');
        csvAttc.setBody(csvBlob);
        //Create Email      
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'omnitracs.sfdc.noreply@omnitracs.com'];
        if(owea.size() > 0){
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }else{
            email.setSenderDisplayName(actionTxt + ' Batch Job Status');
        }
        /*String[] toAddresses = new List<String> {UserInfo.getUserEmail()};
        String[] ccAddresses = new List<String> {'yarafat@omnitracs.com'};*/
        String[] toAddresses = new List<String> {'sales.ops@omnitracs.com',UserInfo.getUserEmail()};
        String[] ccAddresses = new List<String> {'weisheit@omnitracs.com','yarafat@omnitracs.com'};

        email.setSubject(actionTxt + ' Batch Job Status');       

        email.setToAddresses(toAddresses);
        email.setCcAddresses(ccAddresses);        

        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        email.setPlainTextBody(sEmailBody);

        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        //Database.executeBatch(new QuoteCalculatorBatch(quoteIds), 1);
        System.scheduleBatch(new QuoteCalculatorBatch(quoteIds), 'Quote Calculator Batch: ' + System.now(), 1, 1);
    }
}