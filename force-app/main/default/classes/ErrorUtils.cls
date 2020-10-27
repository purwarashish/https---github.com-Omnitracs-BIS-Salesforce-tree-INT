global class ErrorUtils {

    global static void handleError(Exception e){
        if(e != null){
            handleError(
                'An error occurred in salesforce.com for ' 
                    + UserInfo.getOrganizationName() 
                    + ' (' 
                    + UserInfo.getOrganizationId()
                    + ')', 
                'An error occurred in salesforce.com.\n\n'
                    + 'User: '
                    + UserInfo.getName()
                    + ' (' 
                    + UserInfo.getUserName() 
                    + ',' 
                    + UserInfo.getUserId()
                    + ')\nOrganization: ' 
                    + UserInfo.getOrganizationName() 
                    + ' (' 
                    + UserInfo.getOrganizationId()
                    + ')\nDate/time: '
                    + Datetime.now()
                    + '\n\nError:\n\n' 
                    + e.getMessage()
            );
        }
    }

    global static void handleError(String summary, String description){
      //SK_To replace managed package with unmanaged package
      //if(al.StringUtils.isNotBlank(QcsDeviceSearchSettings.getInstance().supportEmail)){
        if(StringUtils.isNotBlank(QcsDeviceSearchSettings.getInstance().supportEmail)){
        try{
//              al.emailutils.sendTextEmail(
//                  new List<String>{QcsDeviceSearchSettings.getInstance().supportEmail}
//                  ,summary  //subject
//                  ,description //body
//              );
              system.debug('Summary:'+summary);
              system.debug('Description:'+description);
        }catch(Exception e){}
      }
    }
}