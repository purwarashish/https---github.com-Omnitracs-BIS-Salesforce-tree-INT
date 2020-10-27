/***************************************************************************************************************************************
Modified By  : Rittu Roy
Modified Date: 9/26/2015
Objective    : Added method validateUserForOpptyLock. This method verifies if the logged in user is allowed to edit closed opportunities
               and its related records.

****************************************************************************************************************************************/

global class ApexUserInfo{
        /*Verifies if the logged in user is allowed to edit closed opportunities and its related records. This 
      method gets called from OpportunityUtility class, New Quote and Set Primary Quote buttons on quote*/
    webService static Boolean validateUserForOpptyLock(String userId, String profileId) {
        List<Profile> lstProfiles = new List<Profile>();
        Boolean userBlockedFromEditingOppty = false; //Specifies if the logged in user is blocked from editing closed opportunities
        Set<Id> setBlockedUserIds = new Set<Id>();
        Set<Id> setAllowedUserIds = new Set<Id>();
        Set<String> setBlockedProfiles = new Set<String>();
        
        //Gets setBlockedProfiles. This custom label stores list of profiles which are blocked from editing closed opportunity
        if (Label.OpptyLock_BlockedProfiles != null && String.isNotBlank(Label.OpptyLock_BlockedProfiles)){
            setBlockedProfiles.addAll(Label.OpptyLock_BlockedProfiles.split(',',0));
        }
        
        //Gets setBlockedUserIds. This custom setting stores list of User ids blocked from editing closed opportunity
        if (Global_Variable__c.getInstance('OpptyLock_BlockedUsers') != null && String.isNotBlank(Global_Variable__c.getInstance('OpptyLock_BlockedUsers').value__c)){
            for (String blockedUserId : Global_Variable__c.getInstance('OpptyLock_BlockedUsers').value__c.split(',',0)){
                setBlockedUserIds.add(Id.valueOf(blockedUserId ));
            }
        }
        
        //Gets setAllowedUserIds. This custom setting stores list of User ids whose profile is blocked but user needs the ability to edit opportunities
        if (Global_Variable__c.getInstance('OpptyLock_AllowedUsers') != null && String.isNotBlank(Global_Variable__c.getInstance('OpptyLock_AllowedUsers').value__c)){
            for (String allowedUserId : Global_Variable__c.getInstance('OpptyLock_AllowedUsers').value__c.split(',',0)){
                setAllowedUserIds.add(Id.valueOf(allowedUserId ));
            }
        }
        
        //Get the logged in users profile name
        if (String.isNotBlank(profileId)){
            lstProfiles = [SELECT id, Name FROM Profile WHERE Id = :profileId LIMIT 1];
        }
        
        //Checks if logged in user's userId or profileId is part of blocked lists.
        if (setBlockedUserIds.contains(userId) || (!lstProfiles.isEmpty() && setBlockedProfiles.contains(lstProfiles[0].Name))){
            //Excludes users whose profile is part of blocked profiles list but included in the allowed users' list
            if (!setAllowedUserIds.contains(userId)){
                userBlockedFromEditingOppty = true;
            }
        }
        return userBlockedFromEditingOppty;
    }     
}