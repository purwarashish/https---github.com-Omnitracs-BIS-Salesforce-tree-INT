trigger ContentDocLinkTrigger on ContentDocumentLink (before insert) {
    
    Id profileId = UserInfo.getProfileId();
    String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
    
    for(ContentDocumentLink contentDoc : Trigger.new){
        if(profileName == 'TL Regional Sales Profile - Outlook'){
            //contentDoc.addError('You don\'t have permission to upload Files for Sales Account');
        }
    }

}