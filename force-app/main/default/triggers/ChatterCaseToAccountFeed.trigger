/***********************************************************************************
Date: 2 Dec 2010 
Author: David Ragsdale

Description:  This trigger will update the Chatter feed of the Account associated with the Case 

Modification History:

20 July 2011 - DAR - Added check to not update feed post if user is Connection User
************************************************************************************/
trigger ChatterCaseToAccountFeed on Case (after insert, after update) {

     /*BypassTriggerUtility btu = new BypassTriggerUtility();  
     if (btu.isTriggerBypassed()) {
         return;
     }

/* ========== VARIABLES NOT CURRENTLY USED =============
    //string URLText;
    //string prodOrgID = '00D500000006kZI';    
========================================================*/
    
    /*List<FeedPost> posts = new List<FeedPost>();
    string bodyText;
    string userID = UserInfo.getUserId(); 
    string GVConnectionUser = '00550000001b4gPAAQ';
    boolean updateChatterFeed;
    Id connectionId = ConnectionHelper.getConnectionId(System.Label.S2S_Connection_Name);
    
    for(Case newCase : Trigger.new) 
    {
        //Do Not update chatter feed if Case is created by the Connection User
        //if(newCase.ConnectionreceivedId == null || newCase.ConnectionreceivedId == '')
        //{

/* ==========Not currently used ================================
            //if (prodOrgId == UserInfo.getOrganizationId())
            //{
            //    URLText = 'http://www.salesforce.com/' + newCase.id;
            //} else {
            //    URLText = '';
            //}
==============================================================*/
        
            /*if (trigger.isInsert)
            {
                //CaseUtils.insertAccountChatterFeed(newCase, bodyText, updateChatterFeed); 
                bodyText = 'Case Created: ' + newCase.CaseNumber + ' : '+newCase.Subject+'.';  
                updateChatterFeed = true;             
            } else if (trigger.isUpdate) {
                Case oldCase = Trigger.oldMap.get(newCase.id);

/* =========== DAR - 20 December 2010 - Removed Status updates =============                    
                //if(newCase.Status != oldCase.Status) 
                //{         
                    //bodyText ='The Status of Case: ' + newCase.CaseNumber + ' Was Updated from '+oldCase.Status+' to '+newCase.Status+'.';
                    //updateChatterFeed = true;     
                //}
=============================================================================*/
                
                /*if (newCase.AccountId != oldCase.AccountId)
                {
                    bodyText = 'Case Created: ' + newCase.CaseNumber + ' : '+newCase.Subject+'.'; 
                    updateChatterFeed = true;                  
                }
            }
        
            try 
            {
                //Ensure an id is associated with post
                if (newCase.Accountid != null || newCase.Accountid != '')
                {
                    FeedPost AccountPost = new FeedPost ();
                    AccountPost.Body = bodyText;
                    AccountPost.ParentID = newCase.Accountid;
                    //AccountPost.LinkUrl = URLText;
                    posts.add(AccountPost);
                    bodyText = '';
                }
            } catch (exception err){
            err.getMessage();
            }
        //}
    }

    try
    {
        if (posts.size() > 0)
        {
            if(CaseUtils.chatterFeedUpdated == false)
            {
                if (updateChatterFeed == true && userID != GVConnectionUser)
                {
                    insert posts;
                    CaseUtils.chatterFeedUpdated = true;
                }
            }
        }
    } catch (exception err){
            err.getMessage();
    }*/
}