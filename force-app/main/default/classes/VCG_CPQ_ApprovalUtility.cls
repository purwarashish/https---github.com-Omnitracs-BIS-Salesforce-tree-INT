/***********************************************************************************************************************
* @description   
* @author  Scott Warren <swarren@vepcg.com>
* @since   24.Mar.2014
*
* Assumptions: 
*   1) The Approval Groups will be evaluated at a static step in the approval process. They will not be dynamically assigned like individual users.
* 
* 
* @todo Finish Email Template / Component / Controller
* @todo Ensure the Approval Chaining feature works
* @todo Allow for situation where no approvals are fired
************************************************************************************************************************/
public without sharing class VCG_CPQ_ApprovalUtility {
    public static Integer runCount = 0; 
    public static List<String> groupApprovalFields;

/*************** Trigger Handler ***************/

    /*  was created for case no 01930168  but we need to go another route with it as we get too many soql queries when this is called
	public static void updateOpptQuoteProductField(List<VCG_CPQ_Quote__c> triggerRecords)
	{
		
		//  pull out only the primary quotes as thse are the only ones that need to update to the oppts product name field
		List<VCG_CPQ_Quote__c> primaryQuotes = new List<VCG_CPQ_Quote__c>();
		Set<id> opptIds = new SEt<Id>();
		for (VCG_CPQ_Quote__c q : triggerRecords)
		{
			if (q.is_primary__c)
			{
				primaryQuotes.add(q);
				//  i'll also use this time to get a unique set of oppt ids so i can mass query them below
				if (q.Opportunity__c != null && !opptIds.contains(q.Opportunity__c))
				{
					opptIds.add(q.Opportunity__c);
				}
			}
		}
		//  now we have the primary quotes, we need to make two queries: 1-all of the quote products that point to these primary quotes and 
		// 2-all of the oppts of the primary quotes so we can update them, we do both bulk/batch so we dont have muiple queries
		//  after validating deployment agaisnt live, i was getting too many soql queries in VCG_CPQ_QuoteController_Test, at this time
		//  i am not 100% sure what the cause could be but i am goin gtosee if i can prevent the query below from being cvalled
		//  if the amount of queries used exceeds the 2 queries needed below
		integer numOfQueriesAvailable = (Limits.getLimitQueries() - Limits.getQueries());
		
		util.debug('numOfQueriesAvailable:' + numOfQueriesAvailable + 
		  ' num of queries used: ' + Limits.getQueries() + 
		  ' num of queries allowed max: ' + Limits.getLimitQueries());
		if (numOfQueriesAvailable >= 2 &&  
		  primaryQuotes != null && primaryQuotes.size() > 0)
		{
			
			//  query the quote products of the primary quotes
			List<VCG_CPQ_Quote_Product__c> quoteProductsOfPrimaryQuotes = 
			     [select id, product__c, product__r.name,quote__c from VCG_CPQ_Quote_Product__c where quote__c in: primaryQuotes];
			//  query the oppts of the primary quotes
			List<Opportunity> opptsOfPrimaryQuotes = [select id, Quote_Products__c from Opportunity where id in: opptIds];
			
			//  now that we have the oppts and the quote products, we can now scroll thru the oppts to set the quote products field
			for (Opportunity oppt : opptsOfPrimaryQuotes)
			{
			    //  since we mass queried the quote products a few lines above, we need to make sure we are only looking at those
			    //  that apply to the oppt in context so pull out all of those that point to the oppt 
				VCG_CPQ_Quote__c primaryQuote = findPrimaryQuote(oppt.id, primaryQuotes);
				
				if (primaryQuote != null)//  should not be null, if it is, a bug in the code has occured
				{
					List<VCG_CPQ_Quote_Product__c> quoteProductsOfOppt = findPrimaryQuoteProducts(primaryQuote.id, quoteProductsOfPrimaryQuotes);
					//  now we can create the string of products... i am offloading this to another method to make this assignment a little bit more cleanr
					oppt.Quote_Products__c = createStringOfQuoteProducts(quoteProductsOfOppt);
				}
			}
			
			//  Lastly, update the opportunities, in a try block... since its possible the oppt is failing validaiton 
			try
			{
				//  the false tells the update method to try to update all oppts, if one fails, the others will still get updated
				database.update(opptsOfPrimaryQuotes, false);
			}
			catch(Exception e)
			{
				//  if catasthpoic failure occurs, output exception metssage to debug log
				util.debug('oppt update failed due to: ' + e.getMessage());
			}
		}
		
	}
	private static VCG_CPQ_Quote__c findPrimaryQuote(Id opptId, List<VCG_CPQ_Quote__c> quotes)
    {
    	for (VCG_CPQ_Quote__c q : quotes)
    	{
    		if (q.Opportunity__c == opptId)
    		{
    			return q;
    		}
    	}
    	return null;
    	
	}
	
	
	private static List<VCG_CPQ_Quote_Product__c> findPrimaryQuoteProducts(id primaryQuoteId, List<VCG_CPQ_Quote_Product__c> quoteProducts)
	{
		List<VCG_CPQ_Quote_Product__c> quoteProductsToReturn = new List<VCG_CPQ_Quote_Product__c>();
		
		for (VCG_CPQ_Quote_Product__c qp : quoteProducts)
		{
			if (qp.Quote__c == primaryQuoteId)
			{
				quoteProductstoReturn.add(qp);
			}
		}
		return quoteProductstoReturn;
	}
	
	private static string createStringOfQuoteProducts(List<VCG_CPQ_Quote_Product__c> quoteProducts)
	{
		string stringToReturn = '';
        for (integer i = 0; i < quoteProducts.size(); i++)
        {
        	if (quoteProducts[i].Product__c != null && 
        	   quoteProducts[i].product__r.name != null)
    	   {
    	   	   stringToreturn += quoteProducts[i].Product__r.name;
    	   }
    	   //  adds a semicolon as a name sperator UNLESS we are on the last product
    	   if (i != quoteProducts.size() -1)
    	   {
    	   	   stringToReturn += '; ';
    	   }
        }
        //  field was long text area but changed to text area prior to uat deployments, so need to truncate to 255 if
        //  there are more than 255 chars in string
        if (stringToReturn != null && stringToReturn.length() > 255)
        {
        	stringToReturn = truncateString(stringToReturn, 255);
        }
        return stringToReturn;
	}
	private static string truncateString(string str, integer fieldMaxLength)
    {
        system.assert(str.length() > fieldMaxLength);
        string stringToReturn = str.substring(0, fieldMaxLength - 3);//  the last 3 chars on the end of the string will be ...
        stringToReturn += '...';
        return stringToReturn; 
    }
    */
	
    public static void quoteTriggerHandler(List<VCG_CPQ_Quote__c> oldQuotes, List<VCG_CPQ_Quote__c> newQuotes, String context){

        runCount++;
//System.debug('Context + runCount: ' + context + ' - ' + runCount);        
        List<VCG_CPQ_Quote__c> checkNeedsApprovalQuotes = new List<VCG_CPQ_Quote__c>();
        List<VCG_CPQ_Quote__c> setupApprovalQuotes = new List<VCG_CPQ_Quote__c>();
        List<VCG_CPQ_Quote__c> nextApprovalQuotes = new List<VCG_CPQ_Quote__c>();
        List<VCG_CPQ_Quote__c> recallApprovalQuotes = new List<VCG_CPQ_Quote__c>();
        List<VCG_CPQ_Quote__c> initializeApprovals = new List<VCG_CPQ_Quote__c>(); //Only used for approval chaining
        
        //Call the approval methods as appropriate
        for(VCG_CPQ_Quote__c oldQuote : oldQuotes){
            for(VCG_CPQ_Quote__c newQuote : newQuotes){
                if(oldQuote.Id == newQuote.Id){                 

                    // If not already in the approval process, see if we need approval for anything
//                    if (context == 'beforeUpdate'
//                        && newQuote.Check_Approvals__c == true
//                        && newQuote.Ready_For_Approval__c == false && newQuote.Ran_Approvals__c == false) {
                        // Comment this out for ACT-0054
                        // checkNeedsApprovalQuotes.add(newQuote);
//                    }
                    
                    //Setup the initial approval structure for the quote
                    if(context == 'beforeUpdate' && oldQuote.Ready_For_Approval__c == false && newQuote.Ready_For_Approval__c == true
                        && newQuote.Ran_Approvals__c == false){
                        setupApprovalQuotes.add(newQuote);
                    }
                    
                    //Update the quote record / quote approval records for the next approval step
                    if(context == 'beforeUpdate' && oldQuote.Last_Approved_By__c != newQuote.Last_Approved_By__c
                       && oldQuote.Ran_Approvals__c == true){
                        nextApprovalQuotes.add(newQuote);
                    }
                    
                    if(context == 'beforeUpdate' && oldQuote.Ready_For_Approval__c == true && newQuote.Ready_For_Approval__c == false
                        && newQuote.Ran_Approvals__c == true){
                        recallApprovalQuotes.add(newQuote);
                    }
                    //If additional Approval steps are necessary, chain approvals here
                    if(context == 'afterUpdate' && 
                         ((oldQuote.Approval_Process__c != null && oldQuote.Approval_Process__c != '' && oldQuote.Ran_Approvals__c == true
                            && oldQuote.Approval_Process__c != newQuote.Approval_Process__c && newQuote.Ready_For_Approval__c == true
                         ) || newQuote.Evaluated_Status__c == 'Evaluated')) {
                            
                        initializeApprovals.add(newQuote);
                    }
//                    System.debug('context: ' + context + ' | old process: ' + oldQuote.Approval_Process__c + ' | new process: ' + newQuote.Approval_Process__c);
                }
            }
        }
        
//        if(!checkNeedsApprovalQuotes.isEmpty()){
//            System.debug(LoggingLevel.ERROR, '====> Calling checkNeedsApprovals - context: ' + context + ' with ' + checkNeedsApprovalQuotes.size() + ' quotes');
            // comment this method out for ACT-0054
            // checkNeedsApprovals(checkNeedsApprovalQuotes);
//        }
        
        if(!recallApprovalQuotes.isEmpty()){
//          System.debug(LoggingLevel.ERROR, '====> Calling recallApprovals - context: ' + context + ' with ' + recallApprovalQuotes.size() + ' quotes');
            recallApprovals(recallApprovalQuotes);
        }
        
        if(!setupApprovalQuotes.isEmpty()){
//            System.debug(LoggingLevel.ERROR, '====> Calling setupApprovals - context: ' + context + ' with ' + setupApprovalQuotes.size() + ' quotes');
            setupApproval(setupApprovalQuotes);
            //initializeApprovalProcess(oldQuotes, newQuotes);
        }
        
        if(!nextApprovalQuotes.isEmpty()){
//          System.debug(LoggingLevel.ERROR, '====> Calling setNextApproval - context: ' + context + ' with ' + nextApprovalQuotes.size() + ' quotes');
            setNextApproval(nextApprovalQuotes);
        }
        
        if(!initializeApprovals.isEmpty()){
//          System.debug(LoggingLevel.ERROR, '====> Calling initializeApprovals - context: ' + context + ' with ' + initializeApprovals.size() + ' quotes');
            initializeApprovalProcess(initializeApprovals);
        }
        
    }
    


    
    
    
    


//////////////////////// Entry Methods ////////////////////////
    /**
    * @description This method checks to see if there are any approval conditions that the give quotes triggers. If so,
    *              marks them as needing approval. Does not save approval records. Otherwise virtually the same as the
    *              setupApproval() method below.
    *
    * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
    * @since   8.Oct.2014
    */
    public static void checkNeedsApprovals(List<VCG_CPQ_Quote__c> quotes){
        
        Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Approval__c>> quoteApprovalMap = getCreateQuoteApprovals(quotes);
        
        { // start debug block
//            System.debug('====> checkNeedsApprovals - QuoteApprovalMap: ' + quoteApprovalMap);
            if (quoteApprovalMap.containsKey(quotes[0]))
            {
                List<String> reasons = new List<String>();
                for (VCG_CPQ_Quote_Approval__c app : quoteApprovalMap.get(quotes[0]))
                {
                  reasons.add(app.Approval_Reason__c);
                }
//                System.debug('====> Approval Reasons: ' + String.join(reasons, '; '));
            }
            else
            {
//                System.debug('====> No Approval Reasons');
            }
        } // end debug block
        
        for (VCG_CPQ_Quote__c quote : quotes) {
            // All we really care about is whether or not there are any records in the quoteApprovalMap for this quote
            if (quoteApprovalMap.containsKey(quote)) {
                quote.Needs_Approval__c = true;
            }
            else {
                quote.Needs_Approval__c = false;
            }
        }
        
    }
    
    
/***********************************************************************************************************************
* @description This method is used to generate Quote Approval records and prep the quote for the approval process
* @author  Scott Warren <swarren@vepcg.com>
* @since   24.Mar.2014

************************************************************************************************************************/
    public static void setupApproval(List<VCG_CPQ_Quote__c> quotes){
        
        // getCreateQuoteApprovals()
        Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Approval__c>> quoteApprovalMap = getCreateQuoteApprovals(quotes);
        
//System.debug('QuoteApprovalMap: ' + quoteApprovalMap);
        List<VCG_CPQ_Quote__c> updateQuotes = new List<VCG_CPQ_Quote__c>();
        List<VCG_CPQ_Quote_Approval__c> insertQuoteApprovals = new List<VCG_CPQ_Quote_Approval__c>();
        VCG_CPQ_Quote_Approval__c firstApproval = new VCG_CPQ_Quote_Approval__c();
        Decimal sequence;
        
        Set<Id> queryQuoteIds = new Set<Id>();
        for(VCG_CPQ_Quote__c quote : quotes){

//System.debug('quote before: ' + quote);
//System.debug('quoteApprovalMap: ' + quoteApprovalMap);
            
            // First, reset all approval-related fields. If this is a cloned quote, it may have
            // Last_Approved_By populated, or any of the group checkboxes checked, but we are recalculating
            // approvals, so we want to reset them.
            ResetApprovalFields(quote);
            
            sequence = 0;
            firstApproval = new VCG_CPQ_Quote_Approval__c();
            if(quoteApprovalMap.containsKey(quote)){
                for(VCG_CPQ_Quote_Approval__c approval : quoteApprovalMap.get(quote)){
                    if(sequence == 0){
                        firstApproval = approval;
                        sequence = approval.Sequence__c;
                    }
                    else if(sequence > 0 && approval.Sequence__c < sequence){
                        firstApproval = approval;
                        sequence = approval.Sequence__c;
                    }
                    
                    if(approval.Approval_Group__c != null){
                        if(!Test.isRunningTest()){
                            quote.put(approval.Quote_Field__c, true);
                        }
                    }
                    
                    insertQuoteApprovals.add(approval);
                }
                // set the quote.Needs_Approval__c = true here
                quote.Needs_Approval__c = true; 
                
            } else {
                // set the quote.Needs_Approval__c = false here
                quote.Needs_Approval__c = false; 
            }
            
            
            //insertQuoteApprovals.addAll(quoteApprovalMap.get(quote));

            if(firstApproval.Approver__c != null){
                quote.Approver__c = firstApproval.Approver__c;
            }

            quote.Ran_Approvals__c = true;
            quote.Approval_Status__c = 'Pending Approval';
            quote.Approval_Sequence__c = firstApproval.Sequence__c;

//System.debug('quote after: ' + quote);                        
        }

        try{
            if(!insertQuoteApprovals.isEmpty()){
                insert insertQuoteApprovals;
            }   
        }
        catch(DMLException dmlE){
            System.debug('DML Exception: ' + dmlE);
        }               
    }

    /**
     * @description  Resets approval-related fields
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   2.Mar.2015
     */
    public static void ResetApprovalFields(VCG_CPQ_Quote__c quote){
        quote.Last_Approved_By__c = null;
        
        ClearGroupApprovalFields(quote);
    }
    
    /**
     * @description  Sets all group approval checkboxes to false
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   2.Mar.2015
     */
    public static void ClearGroupApprovalFields(VCG_CPQ_Quote__c quote){
        if (groupApprovalFields == null)
        {
        	groupApprovalFields = new List<String>();
        	
            List<VCG_CPQ_Approval_Group__c> approvalGroups = [SELECT Quote_Field__c FROM VCG_CPQ_Approval_Group__c];
            for (VCG_CPQ_Approval_Group__c grp : approvalGroups)
            {
                System.debug(LoggingLevel.ERROR, '====> Got group approval field "' + grp.Quote_Field__c + '" from rec: ' + grp.Id);
                groupApprovalFields.add(grp.Quote_Field__c);
            } 
        }
        
        System.debug(LoggingLevel.ERROR, '====> groupApprovalFields: ' + groupApprovalFields);
        
        // Set all approval group fields to false
        for (String fieldName : groupApprovalFields)
        {
            System.debug(LoggingLevel.ERROR, '====> Setting group approval field "' + fieldName + '" to false');
            quote.put(fieldName, false);
        }
    }

/***********************************************************************************************************************
* @description This method is used to generate Quote Approval records and prep the quote for the approval process
* @author  Scott Warren <swarren@vepcg.com>
* @since   24.Mar.2014
*
************************************************************************************************************************/    
    
    public static void setNextApproval(List<VCG_CPQ_Quote__c> quotes){
       //String objectAPIName = someId.getSObjectType().getDescribe().getName();
       
       Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Approval__c>> quote_approvals_map = getCreateQuoteApprovals(quotes);
       VCG_CPQ_Quote_Approval__c nextApproval = new VCG_CPQ_Quote_Approval__c(); 
       VCG_CPQ_Quote_Approval__c approvedApproval = new VCG_CPQ_Quote_Approval__c(); 
       List<VCG_CPQ_Quote_Approval__c> updateApprovals = new List<VCG_CPQ_Quote_Approval__c>();
       Decimal sequence;
       Decimal nextSequence;
       for(VCG_CPQ_Quote__c quote : quote_approvals_map.keySet()){
           nextApproval = new VCG_CPQ_Quote_Approval__c();
           sequence = 0;

           for(VCG_CPQ_Quote_Approval__c approval : quote_approvals_map.get(quote)){
                if(Id.valueOf(quote.Last_Approved_By__c).getSObjectType().getDescribe().getName() == 'User'){
                    //User stuff            
                    if(approval.Approver__c == Id.valueOf(quote.Last_Approved_By__c)){
                        if(quote.Approval_Status__c != 'Rejected'){
                            approval.Status__c = 'Approved';    
                        }
                        else{
                            approval.Status__c = 'Rejected';
                        }
                        
                        if(sequence == 0){
                            sequence = approval.Sequence__c;
                        }
                        else if(approval.Sequence__c < sequence){
                            sequence = approval.Sequence__c;
                        }
                    }
                }
                else if(Id.valueOf(quote.Last_Approved_By__c).getSObjectType().getDescribe().getName() == 'VCG_CPQ_Approval_Group__c'){
                    //Group stuff
                    if(approval.Approval_Group__c == Id.valueOf(quote.Last_Approved_By__c)){                        
                        if(quote.Approval_Status__c != 'Rejected'){
                            approval.Status__c = 'Approved';
                        }
                        else{
                            approval.Status__c = 'Rejected';
                        }
                        
                        if(sequence == 0){
                            sequence = approval.Sequence__c;
                        }
                        else if(approval.Sequence__c < sequence){
                            sequence = approval.Sequence__c;
                        }
                    }
                }                                   
           }

//System.debug('quote_approvals_map.get(quote) : ' + quote_approvals_map.get(quote));
//System.debug('Sequence : ' + sequence);           
           if(quote.Approval_Status__c != 'Rejected'){
                for(VCG_CPQ_Quote_Approval__c approval : quote_approvals_map.get(quote)){
                    if(approval.Status__c == 'Pending Approval'){
                        if(nextApproval.Id == null){
                            nextApproval = approval;
                        }
                        else if(approval.Sequence__c > sequence && approval.Sequence__c < nextApproval.Sequence__c){
                            nextApproval = approval;
                        }   
                    }
                    else{
                        continue;
                    }
                    
//System.debug('approval loop : ' + approval);
//System.debug('Next approval : ' + nextApproval);                      
                }               
           }
           
           
           updateApprovals.addAll(quote_approvals_map.get(quote));           

//System.debug('Final Next Approval : ' + nextApproval);           
           if(nextApproval != null && nextApproval.Approver__c != null){
//System.debug('...Assigning next approver...');               
               quote.Approver__c = nextApproval.Approver__c;
           }
           else{
//System.debug('...Nulling next approver...');              
               quote.Approver__c = null;
           }                         
       }
       
       try{
            update updateApprovals; 
       }
       catch(DMLException dmlE){
            System.debug('DML Exception: ' + dmlE);
       }
            
    }
    
    
    

/***********************************************************************************************************************
* @description Initiate the chain approval process
* @author  Scott Warren <swarren@vepcg.com>
* @since   24.Mar.2014
************************************************************************************************************************/   
    public static void initializeApprovalProcess(List<VCG_CPQ_Quote__c> newQuotes){
//System.debug('Inside Initialize Approval Process...\n\n New Quotes: ' + newQuotes + '\n\n');        
        for(VCG_CPQ_Quote__c newQuote : newQuotes){                 
            Approval.ProcessSubmitRequest appReq = new Approval.Processsubmitrequest();
            appReq.setComments('Initialized by CPQ Dynamic Approval Engine');
            appReq.setObjectId(newQuote.Id);
            
            if(!Test.isRunningTest()){
                Approval.ProcessResult result = Approval.process(appReq);
            }
        }           
    }

    
    
/***********************************************************************************************************************
* @description This method is used to delete the Quote Approval records when a quote has been recalled from approval.
* @author  Scott Warren <swarren@vepcg.com>
* @since   24.Mar.2014

************************************************************************************************************************/
    public static void recallApprovals(List<VCG_CPQ_Quote__c> quotes){
//      System.debug('Inside recall approvals...');
        List<Id> quoteIds = new List<Id>();     
        
        List<VCG_CPQ_Approval_Group__c> approvalGroups = new List<VCG_CPQ_Approval_Group__c>([Select Id, Quote_Field__c
                                                                                            FROM VCG_CPQ_Approval_Group__c]);       
        for(VCG_CPQ_Quote__c quote : quotes){
            quoteIds.add(quote.Id);
            
            quote.Ready_For_Approval__c = false;
            quote.Ran_Approvals__c = false;
            quote.Approval_Process__c = '';
            quote.Approval_Status__c = '';
            quote.Last_Approved_By__c = '';
            for(VCG_CPQ_Approval_Group__c approvalGroup : approvalGroups){
                quote.put(approvalGroup.Quote_Field__c, FALSE);
            }
            
        }
        
        List<VCG_CPQ_Quote_Approval__c> quoteApprovals = new List<VCG_CPQ_Quote_Approval__c>([SELECT Id, Quote__c 
                                                                                            FROM VCG_CPQ_Quote_Approval__c
                                                                                            WHERE Quote__c in :quoteIds]);      
        delete quoteApprovals;                                                                                  
                                                                                                    
    }    

/***********************************************************************************************************************
* @description Dynamically create approvals for a non-saved quote
* @author  Scott Warren <swarren@vepcg.com>
* @since   24.Mar.2014
************************************************************************************************************************/
    //Called by the quote controller prior to saving the quote. Provides reps with a dynamic view of which approvals will be required upon save.
    public static List<VCG_CPQ_Quote_Approval__c> getTempQuoteApprovals(VCG_CPQ_Quote__c quote, List<VCG_CPQ_Quote_Product__c> prods){
        List<VCG_CPQ_Quote__c> quotes = new List<VCG_CPQ_Quote__c>{quote};
        List<VCG_CPQ_Quote_Approval__c> approvals = new List<VCG_CPQ_Quote_Approval__c>();
               
        Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Approval__c>> quote_approval_map = createApprovals(quotes, prods);
        System.debug(LoggingLevel.ERROR, '====> quote_approval_map: ' + quote_approval_map);
        approvals.addAll(quote_approval_map.get(quote));
        
        return approvals;
    }
        




/***********************************************************************************************************************
* @description This method is used to retrieve Quote Approval records from queries or generations
* @author  Scott Warren <swarren@vepcg.com>
* @since   24.Mar.2014
************************************************************************************************************************/
    public static Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Approval__c>> getCreateQuoteApprovals(List<VCG_CPQ_Quote__c> quotes){
        Map<Id, VCG_CPQ_Quote_Approval__c> approvalMap = new Map<Id, VCG_CPQ_Quote_Approval__c>();
        List<VCG_CPQ_Quote__c> newQuotes = new List<VCG_CPQ_Quote__c>();
        List<VCG_CPQ_Quote__c> queryQuotes = new List<VCG_CPQ_Quote__c>();
        
        Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Approval__c>> quote_approval_map = queryApprovals(quotes);
        
        for(VCG_CPQ_Quote__c quote : quotes){
            if(!quote_approval_map.containsKey(quote)){
                //add to creation list
                newQuotes.add(quote);
            }
        }

        Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Approval__c>> new_quote_approval_map = new Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Approval__c>>();
        if(!newQuotes.isEmpty()){
            new_quote_approval_map = createApprovals(newQuotes);
        }
        
        for(VCG_CPQ_Quote__c newQuote : new_quote_approval_map.keySet()){
            quote_approval_map.put(newQuote, new_quote_approval_map.get(newQuote));
        }
        
        return quote_approval_map;
    }
        
        

/***********************************************************************************************************************
* @description
* @author  Scott Warren <swarren@vepcg.com>
* @since   24.Mar.2014
************************************************************************************************************************/    
    private static Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Approval__c>> queryApprovals(List<VCG_CPQ_Quote__c> quotes){
        Map<Id, VCG_CPQ_Quote__c> quoteMap = new Map<Id, VCG_CPQ_Quote__c>();
        Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Approval__c>> quote_approval_map = new Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Approval__c>>();  
        quoteMap.putAll(quotes);
        
        Map<Id, VCG_CPQ_Quote_Approval__c> approvalMap = new Map<Id, VCG_CPQ_Quote_Approval__c>([SELECT Id, Name, Quote__c, Approval_Group__c, Approval_Reason__c, Quote_Field__c, Sequence__c, Approver__c, Approval_Condition__c, Status__c
                                                                                                FROM VCG_CPQ_Quote_Approval__c
                                                                                                WHERE Quote__c in :quoteMap.keySet()]);
        if(approvalMap.isEmpty()){
            return quote_approval_map;
        }
        else{
            for(VCG_CPQ_Quote__c quote : quotes){
                for(VCG_CPQ_Quote_Approval__c approval : approvalMap.values()){
                    if(approval.Quote__c == quote.Id){
                        if(quote_approval_map.containsKey(quote)){
                            quote_approval_map.get(quote).add(approval);
                        }
                        else{
                            quote_approval_map.put(quote, new List<VCG_CPQ_Quote_Approval__c>{approval});
                        }
                    }
                }       
            }                                                                                               
            
            return quote_approval_map;                  
        }                                                                                               
    }
    
    private static Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Approval__c>> createApprovals(List<VCG_CPQ_Quote__c> quotes){
        return createApprovals(quotes, new List<VCG_CPQ_Quote_Product__c>());
    }
  
  
    private static Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Approval__c>> createApprovals(List<VCG_CPQ_Quote__c> quotes, List<VCG_CPQ_Quote_Product__c> qProducts){
        //return variable
        Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Approval__c>> quote_approval_map = new Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Approval__c>>();
        //query variable
        List<Id> quoteIds = new List<Id>();
        List<Id> quoteOwnerIds = new List<Id>();
        List<VCG_CPQ_Quote_Product__c> quoteProds = new List<VCG_CPQ_Quote_Product__c>();
            
        //Assign Quote Ids to list for Quote Product Query
        for(VCG_CPQ_Quote__c quote : quotes){
            if(quote.Id != null){
                quoteIds.add(quote.Id);
            }
            if(quote.OwnerId != null){
                quoteOwnerIds.add(quote.OwnerId);
            }
        }
      
        List<VCG_CPQ_Approval_Group_Matrix__c> groupMatrices = new List<VCG_CPQ_Approval_Group_Matrix__c>([SELECT Id, Name, Approval_Condition__c, Approval_Group__c, Approval_User_Role__c, Sequence__c
                                                                                                          FROM VCG_CPQ_Approval_Group_Matrix__c]);

        List<Id> conditionsNeeded = new List<Id>();
        for(VCG_CPQ_Approval_Group_Matrix__c mtrx : groupMatrices){
            conditionsNeeded.add(mtrx.Approval_Condition__c);
        }
        
        // Flag to indicate whether or not to include non-deployed conditions
        Boolean runNonDeployed = false;
        
        if (VCG_CPQ_Options__c.getInstance() != null && VCG_CPQ_Options__c.getInstance().Run_Un_Deployed_Components__c != null)
        {
            runNonDeployed = VCG_CPQ_Options__c.getInstance().Run_Un_Deployed_Components__c.contains(UserInfo.getUserName());
        }
        
        String soql = ' SELECT Id, Name, Calculation_Compiled__c, Approval_Reason__c, Needs_Fields__c '
                    + ' FROM VCG_CPQ_Approval_Condition__c '
                    + ' WHERE Id IN :conditionsNeeded'
                    + '       AND IsActive__c = TRUE'
                    + (runNonDeployed ? '' : ' AND IsDeployed__c = TRUE')
                    + ' ORDER BY Name';
        System.debug(LoggingLevel.ERROR, '====> Approval Conditions query: ' + soql);
        
        List<VCG_CPQ_Approval_Condition__c> conditions = new List<VCG_CPQ_Approval_Condition__c>((List<VCG_CPQ_Approval_Condition__c>)Database.query(soql));
        System.debug(LoggingLevel.ERROR, '====> Conditions: ' + conditions);
        
        String quoteNeedsFields = '';
        List<String> qpNeedsFields = new List<String>();
        
        for (VCG_CPQ_Approval_Condition__c condition : conditions)
        {
            if (condition.Needs_Fields__c != null)
            {
                List<String> needsFieldsList = condition.Needs_Fields__c.split(';');
                
                for (String needsField : needsFieldsList)
                {
                    if (needsField != null && needsField.startsWith('Quote_Products__r'))
                    {
                        qpNeedsFields.add(needsField.replace('Quote_Products__r.',''));
                    }
                    else
                    {
                        quoteNeedsFields += needsField + ';';
                    }
                }
            }
        }
        
        List<VCG_CPQ_Quote__c> needsFieldsQuotes = VCG_CPQ_NeedsFieldsUtility.getNeedsFields(quotes, quoteNeedsFields);
        
        Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Product__c>> quote_product_map = new Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Quote_Product__c>>(); 

        String quoteProdQuery;
        Map<String, Schema.SObjectField> fieldObjectMap = schema.SObjectType.VCG_CPQ_Quote_Product__c.fields.getMap();      
        //Handle quotes sent in after save 
        if(qproducts.isEmpty() && !quoteIds.isEmpty()){
            // Collect up QP fields - use set to ensure unique -- make *sure* field names are all lower case! (Sets are case sensitive!)
            Set<String> qpFieldSet = new Set<String>();
            
            // Add in fields from the schema describe
            for (Schema.SObjectField field : fieldObjectMap.values()){
                qpFieldSet.add(field.getDescribe().getName().toLowerCase());
            }
            
            // Add in needs fields
            for (String field : qpNeedsFields){
                qpFieldSet.add(field.toLowerCase());
            }
            
            // Now build the query from the set
            List<String> qpFieldsList = new List<String>();
            qpFieldsList.addAll(qpFieldSet);
            
            quoteProdQuery = 'SELECT ';
            quoteProdQuery += String.join(qpFieldsList, ',');
            quoteProdQuery += ' FROM VCG_CPQ_Quote_Product__c WHERE Quote__c in :quoteIds';         
            
            quoteProds = new List<VCG_CPQ_Quote_Product__c>();
            quoteProds = Database.query(quoteProdQuery);                                                                
                                                                
            for(VCG_CPQ_Quote__c quote : needsFieldsQuotes){
                for(VCG_CPQ_Quote_Product__c product : quoteProds){
                    if(quote.Id == product.Quote__c){
                        if(quote_product_map.containsKey(quote)){
                            quote_product_map.get(quote).add(product);
                        }
                        else{
                            quote_product_map.put(quote, new List<VCG_CPQ_Quote_Product__c>{product});
                        }                       
                    }
                }
            }
        }
        
        //Handle single quote sent in prior to save
        else{
            quoteProds.addAll(qProducts);
            VCG_CPQ_Quote__c unsavedQuote = needsFieldsQuotes[0];

            for(VCG_CPQ_Quote_Product__c prod : quoteProds){
                if(quote_product_map.containsKey(unsavedQuote)){
                    quote_product_map.get(unsavedQuote).add(prod);                  
                }
                else{
                    quote_product_map.put(unsavedQuote, new List<VCG_CPQ_Quote_Product__c>{prod});
                }               
            }
        }

        //Gather Approval Conditions which return a value of true related to each quote/quote product list
        Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Approval_Condition__c>> quote_conditions_map = new Map<VCG_CPQ_Quote__c, List<VCG_CPQ_Approval_Condition__c>>();
        List<VCG_CPQ_Approval_Condition__c> activeConditions = new List<VCG_CPQ_Approval_Condition__c>();

        for(VCG_CPQ_Quote__c quote : quote_product_map.keySet()){
            for(VCG_CPQ_Approval_Condition__c condition : conditions){      
                
                VCG_CPQ_Data.setChildren(quote, 'Quote_Products__r', quote_product_map.get(quote));

//                System.debug('condition formula: ' + condition.Calculation_Compiled__c);
                
                Decimal val;
                
                try {
                    val = VCG_CPQ_Formula.evaluate(quote, condition.Calculation_Compiled__c).value;
                }
                catch (Exception e) {
                    throw new VCG_CPQ_Formula.Formula_Exception('Error evaluating approval condition "' + condition.Name + '": ' + e.getMessage() + '\n' + e.getStackTraceString());
                }
                
//                System.debug('Formula Eval: ' + val);
                
                if (val == 1.0){
                    
                    if(quote_conditions_map.containsKey(quote)){
                        quote_conditions_map.get(quote).add(condition);
                        activeConditions.add(condition);
                    }
                    else{
                        //quote.Approval_Status__c = 'Pending Approval';
                        quote_conditions_map.put(quote, new List<VCG_CPQ_Approval_Condition__c>{condition});
                        activeConditions.add(condition);
                    }
                }
            }
        }
        
        List<String> groupIds = new List<String>();

        for(VCG_CPQ_Approval_Group_Matrix__c queryMatrix : groupMatrices){
            groupIds.add(queryMatrix.Approval_Group__c);
        }
        

        Map<Id, VCG_CPQ_Approval_Group__c> approvalGroups = new Map<Id, VCG_CPQ_Approval_Group__c>([SELECT Id, Name, Description__c, Quote_Field__c 
                                                                                                    FROM VCG_CPQ_Approval_Group__c 
                                                                                                    WHERE Id in : groupIds]);
        
        List<VCG_CPQ_User_Hierarchy__c> hierarchies = new List<VCG_CPQ_User_Hierarchy__c>([SELECT Id, Name, User__c, Related_User__c, Related_User_Role__c
                                                                                          FROM VCG_CPQ_User_Hierarchy__c
                                                                                          WHERE User__c in : quoteOwnerIds]);
        
        Map<String, Map<String, String>> owner_role_user_map = new Map<String, Map<String, String>>();
        for(String quoteOwnerId : quoteOwnerIds){
            for(VCG_CPQ_User_Hierarchy__c hierarchy : hierarchies){
                if(owner_role_user_map.containsKey(quoteOwnerId)){
                    owner_role_user_map.get(quoteOwnerId).put(hierarchy.Related_User_Role__c, hierarchy.Related_User__c);
                }
                else{
                    owner_role_user_map.put(quoteOwnerId, new Map<String, String>{hierarchy.Related_User_Role__c => hierarchy.Related_User__c});
                }
            }            
        }


        
        Map<VCG_CPQ_Approval_Condition__c, List<VCG_CPQ_Approval_Group_Matrix__c>> condition_matrix_map = new Map<VCG_CPQ_Approval_Condition__c, List<VCG_CPQ_Approval_Group_Matrix__c>>();
        for(VCG_CPQ_Approval_Condition__c condition : conditions){
            for(VCG_CPQ_Approval_Group_Matrix__c matrix : groupMatrices){
                if(matrix.Approval_Condition__c == condition.Id){
                    if(!condition_matrix_map.containsKey(condition)){
                        condition_matrix_map.put(condition, new List<VCG_CPQ_Approval_Group_Matrix__c>{matrix});
                    }
                    else{
                        condition_matrix_map.get(condition).add(matrix);
                    }
                }
            }           
        }

        for (VCG_CPQ_Quote__c quote : quote_conditions_map.keySet())
        {
            if (!quote_conditions_map.get(quote).isEmpty())
            {
                for (VCG_CPQ_Approval_Condition__c condition : quote_conditions_map.get(quote))
                {
                    if (condition_matrix_map.containsKey(condition))
                    {
                        for (VCG_CPQ_Approval_Group_Matrix__c matrix : condition_matrix_map.get(condition))
                        {
                            if (quote_approval_map.containsKey(quote))
                            {
                                if (matrix.Approval_User_Role__c != null)
                                {
/** @todo  Temp disabled per Don's request - to get us through UAT and avoid all the errors they've been receiving - LC 2014-10-22 */
//                                    if (!owner_role_user_map.containsKey(quote.OwnerId) || !owner_role_user_map.get(quote.OwnerId).containsKey(matrix.Approval_User_Role__c))
//                                    {
//                                        String ownerName = [SELECT Name FROM User WHERE Id = :quote.OwnerId][0].Name;
//                                        throw new VCG_CPQ_Formula.Formula_Exception('No approver defined for role: ' + matrix.Approval_User_Role__c + ' for user: ' + ownerName);
//                                    }
                                    if (owner_role_user_map.containsKey(quote.OwnerId) && owner_role_user_map.get(quote.OwnerId).containsKey(matrix.Approval_User_Role__c))
                                    {
                                        quote_approval_map.get(quote).add(new VCG_CPQ_Quote_Approval__c(Name = '', Sequence__c = matrix.Sequence__c, Approver__c = owner_role_user_map.get(quote.OwnerId).get(matrix.Approval_User_Role__c), Quote__c = quote.Id, /*Quote_Field__c = approvalGroups.get(matrix.Approval_Group__c).Quote_Field__c,*/ Approval_Reason__c = condition.Approval_Reason__c));
                                    }
                                }
                                if (matrix.Approval_Group__c != null)
                                {
                                    quote_approval_map.get(quote).add(new VCG_CPQ_Quote_Approval__c(Name = '', Sequence__c = matrix.Sequence__c, Approval_Group__c = matrix.Approval_Group__c, Quote__c = quote.Id, Quote_Field__c = approvalGroups.get(matrix.Approval_Group__c).Quote_Field__c, Approval_Reason__c = condition.Approval_Reason__c));
                                }   
                            }
                            else
                            {
                                if (matrix.Approval_User_Role__c != null)
                                {
/** @todo  Temp disabled per Don's request - to get us through UAT and avoid all the errors they've been receiving - LC 2014-10-22 */
//                                    if (!owner_role_user_map.containsKey(quote.OwnerId) || !owner_role_user_map.get(quote.OwnerId).containsKey(matrix.Approval_User_Role__c))
//                                    {
//                                        String ownerName = [SELECT Name FROM User WHERE Id = :quote.OwnerId][0].Name;
//                                        throw new VCG_CPQ_Formula.Formula_Exception('No approver defined for role: ' + matrix.Approval_User_Role__c + ' for user: ' + ownerName);
//                                    }
                                    if (owner_role_user_map.containsKey(quote.OwnerId) && owner_role_user_map.get(quote.OwnerId).containsKey(matrix.Approval_User_Role__c))
                                    {
                                        quote_approval_map.put(quote, new List<VCG_CPQ_Quote_Approval__c>{new VCG_CPQ_Quote_Approval__c(Name = '', Sequence__c = matrix.Sequence__c, Approver__c = owner_role_user_map.get(quote.OwnerId).get(matrix.Approval_User_Role__c), Quote__c = quote.Id, Approval_Reason__c = condition.Approval_Reason__c)});
                                    }
                                }
                                if (matrix.Approval_Group__c != null)
                                {
                                    quote_approval_map.put(quote, new List<VCG_CPQ_Quote_Approval__c>{new VCG_CPQ_Quote_Approval__c(Name = '', Sequence__c = matrix.Sequence__c, Approval_Group__c = matrix.Approval_Group__c, Quote_Field__c = approvalGroups.get(matrix.Approval_Group__c).Quote_Field__c, Quote__c = quote.Id, Approval_Reason__c = condition.Approval_Reason__c)});
                                }                                
                            }
                        }                       
                    }
                }                                   
            }               
        }

        return quote_approval_map;      
    }
        
}//END