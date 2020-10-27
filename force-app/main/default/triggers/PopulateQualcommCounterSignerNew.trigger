/***********************************************************************************
Date: 14 August 2009 
Author: Kasia Dinen

Description:  This trigger will update the Qualcomm Counter-Signer field based upon selected
    Criteria.
    
Update: 16 June 2011 - David Ragsdale
    - Updated trigger to allow for use in Managed Package.  Since fieldnames cannot be changed
    modified code so both the managed ES field AND the Qualcomm Counter-Signer field will be updated  
    
Update: 27 Mar 2015 - Abhishek
    - Indirect XRS Opportunities Counter Signature should not get populated 

Update: 14 Nov 2015 - Rittu Roy
    - Added method call 'updateContractStatus' to update contract and opportunity statuses once customer has sigend the 
      agreement. 
    - Case #01965247 - Commented lines which were populating field 'Additional Recipient 1 (Contact)'
   
  
************************************************************************************/
trigger PopulateQualcommCounterSignerNew on echosign_dev1__SIGN_Agreement__c (before update, before insert, after update) 
{

    echosign_dev1__SIGN_Agreement__c Agreement = Trigger.New[0];
    ID acctId = Agreement.echosign_dev1__Account__c;

    List<Account> parentAccount = [select Id, Sales_Director__c,District__c FROM Account 
            WHERE Id = :acctId limit 1];
    string director = null;
    If (! parentAccount.isEmpty())   
    {     
    director  = parentAccount[0].Sales_Director__c;
    }
    
    try
    {
        if (trigger.isBefore && Agreement.echosign_dev1_Agreement_Type__c != 'Professional Services') 
        {
           
            if (Agreement.Recipient4__c == null) 
            {  
                
                if (Agreement.echosign_dev1_Agreement_Type__c == 'Evaluation Contract'                     
                    && director != null) 
                {
                    
                    if(parentAccount[0].District__c == 'West District 1'
                        ||parentAccount[0].District__c == 'West District 2'
                        ||parentAccount[0].District__c == 'West District 3'
                        ||parentAccount[0].District__c == 'West District 4'
                        ||parentAccount[0].District__c == 'West District 5') 
                    {  
                     
                    User userRecord = [SELECT Id, Name FROM User WHERE Id = :director limit 1];
                    
                    for(Contact contactRecord :[SELECT Id, Name FROM Contact 
                            WHERE Name = :userRecord.Name limit 1])
                        {
                        
                        //Since this is a managed package...  Cannot change Recipient4 fieldname
                        //Therefore update custom and managed field
                        //Manage field is used by Echosign to send email to QC Counter Signer
                        populateCounterSigner(contactRecord.Id,Agreement);
                        //Agreement.Recipient4__c = contactRecord.Id; 
                        //Agreement.echosign_dev1__Recipient2__c = contactRecord.Id;
                        }
                    }
                }
                else
                { 
                    Account parentAccount2 = [SELECT Id, Contracts_Administrator__c FROM Account 
                            WHERE Id = :acctId limit 1];
                    
                    User userRecord2 = [SELECT Id, Name FROM User 
                            WHERE Id = :parentAccount2.Contracts_Administrator__c limit 1];
                
                    for (Contact contactRecord2 :[SELECT Id, Name FROM Contact 
                            WHERE Name = :userRecord2.Name limit 1])
                    {
                        //Since this is a managed package...  Cannot change Recipient4 fieldname
                        //Therefore update custom and managed field
                        //Manage field is used by Echosign to send email to QC Counter Signer   
                        
                       
                        populateCounterSigner(contactRecord2.Id,Agreement);
                        //Agreement.Recipient4__c = contactRecord2.Id;
                        //Agreement.echosign_dev1__Recipient2__c = contactRecord2.Id;
                    }
                }
                         
            }else{
               //Update the managed recipient with the Qualcomm Counter-signer if the user manually enters the QC Counter Signer
               //Commented as part of Case #01965247
               Agreement.echosign_dev1__Recipient2__c = Agreement.Recipient4__c;
            }
        }
    } catch(exception err){
        err.getMessage();
    }
    
    if (trigger.isAfter){
        if (trigger.isUpdate){
            AgreementUtils.updateContractStatus(Trigger.New, Trigger.oldMap);
        }
    }

    
    public void populateCounterSigner(id contactRecordId, echosign_dev1__SIGN_Agreement__c lstAgreement)
    {
        List<echosign_dev1__SIGN_Agreement__c> newAgreement = new List<echosign_dev1__SIGN_Agreement__c>() ;
        List<User> oppOwnerProfile = new List<User>(); 
        newAgreement.add(lstAgreement);
        
        
        List<Opportunity> newOpp = [Select Product_name__c,ownerid,id from Opportunity where id in
                                 (select Opportunity__c from VCG_CPQ_Quote__c where id =: newAgreement[0].Quote__c ) limit 1];
        
        If (! newOpp.isEmpty())   
        {                           
            oppOwnerProfile = [Select ProfileId from user where id = :newOpp[0].ownerid limit 1];
        } 
                                
         If (!oppOwnerProfile.isEmpty())   
        { 
             If( newOpp[0].Product_name__c == System.label.Opportunity_Product_Name &&  oppOwnerProfile[0].ProfileId == System.label.Agreement_Owner_Profile && newAgreement[0].recordtypeid == System.label.Agreement_Record_Type)                     
                {
                   Agreement.Recipient4__c = null;
                   Agreement.echosign_dev1__Recipient2__c = null;
                }
             else
                { 
                   Agreement.Recipient4__c = contactRecordId;
                   Agreement.echosign_dev1__Recipient2__c = contactRecordId;
                }
         }
         else /* When Agreement is not associated with a Quote */
         {
                   Agreement.Recipient4__c = contactRecordId;
                   
                   //Commented as part of Case #01965247
                   Agreement.echosign_dev1__Recipient2__c = contactRecordId; 
         }    
    }
    
}