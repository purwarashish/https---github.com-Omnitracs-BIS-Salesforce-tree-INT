public class PartnerSupportInformationUtils {
    private static String unityCredentials = 'sf-non-prod@service.qes.qualcomm.com:saleSm3ggs';

    @future (callout=true)
    public static void updatePartnerSupportDetails(List<String> lstAccountId) {
        List<User> lstUser = null;
        List<Partner_Support_Information__c> lstPSI = null;
        
        lstPSI = [
                    SELECT
                        id,
                        Partner_Account__c,
                        Support_Name__c,
                        Support_Phone__c,
                        Support_Email__c,
                        Hours_Of_Service__c,
                        Logo__c,
                        Logo_Orientation__c
                    FROM
                        Partner_Support_Information__c
                    WHERE
                        Partner_Account__c in :lstAccountId
                    LIMIT
                        :lstAccountId.size()
                 ];                        
                 
        lstUser = [
                    SELECT
                        id,
                        FederationIdentifier
                    FROM
                        User
                    WHERE
                        id = :UserInfo.getUserId()
                    LIMIT
                        1
                  ];
                                
        QESUnityAdminLinkWebServices.AdminServiceSoapImplPort port = null;    
        QESUnityAdminLinkWebServices.standardResponse response = null;
        Integer retries = 1;

        try {        
            port = new QESUnityAdminLinkWebServices.AdminServiceSoapImplPort();
            String authorization = EncodingUtil.base64Encode(
                                   Blob.valueOf(unityCredentials ));
            port.inputHttpHeaders_x = new Map<String, String>();
            port.inputHttpHeaders_x.put('Authorization', 'Basic ' + authorization);
            
            for(Partner_Support_Information__c psi : lstPSI) {
                List<Account> lstAccounts = null;
                lstAccounts = [
                                SELECT
                                    id,
                                    AGUID__c,
                                    ownerId
                                FROM
                                    Account
                                WHERE
                                    id = :psi.Partner_Account__c
                                LIMIT
                                    1
                              ];
                System.debug('@@@@@@@@@@@@@@@@@@..' + lstAccounts.size());
                QESUnityAdminLinkWebServices.ExtendedCompany company = new QESUnityAdminLinkWebServices.ExtendedCompany();
                if(0 != lstAccounts.size()) {
                    company.CompanyGuid = lstAccounts[0].AGUID__C;
                }
                
                company.CompanyAttributeList = new QESUnityAdminLinkWebServices.CompanyAttributeList_element();
                List<QESUnityAdminLinkWebServices.CompanyAttribute> lstCompanyAttributes = new List<QESUnityAdminLinkWebServices.CompanyAttribute>();
                
                QESUnityAdminLinkWebServices.CompanyAttribute companyAttribute = new QESUnityAdminLinkWebServices.CompanyAttribute();
                companyAttribute.AttrName = 'SUPPORT_NAME';
                companyAttribute.AttrValueString = psi.Support_Name__c;
                lstCompanyAttributes.add(companyAttribute);
                
                companyAttribute = new QESUnityAdminLinkWebServices.CompanyAttribute();
                companyAttribute.AttrName = 'SUPPORT_EMAIL';
                companyAttribute.AttrValueString = psi.Support_Email__c;
                lstCompanyAttributes.add(companyAttribute);

                companyAttribute = new QESUnityAdminLinkWebServices.CompanyAttribute();
                companyAttribute.AttrName = 'SUPPORT_PHONE';
                companyAttribute.AttrValueString = psi.Support_Phone__c;
                lstCompanyAttributes.add(companyAttribute);
                
                companyAttribute = new QESUnityAdminLinkWebServices.CompanyAttribute();
                companyAttribute.AttrName = 'SUPPORT_HOURS';
                companyAttribute.AttrValueString = psi.Hours_of_Service__c;
                lstCompanyAttributes.add(companyAttribute);
                
                companyAttribute = new QESUnityAdminLinkWebServices.CompanyAttribute();
                companyAttribute.AttrName = 'SUPPORT_LOGO_URL';
                companyAttribute.AttrValueString = psi.Logo__c;
                lstCompanyAttributes.add(companyAttribute);                

                companyAttribute = new QESUnityAdminLinkWebServices.CompanyAttribute();
                companyAttribute.AttrName = 'SUPPORT_LOGO_ORIENTATION';
                companyAttribute.AttrValueString = psi.Logo_Orientation__c;
                lstCompanyAttributes.add(companyAttribute);                
                                                                                
                company.CompanyAttributeList.CompanyAttribute = lstCompanyAttributes;
                
                response = port.updateSupportContactDetails(company, lstUser[0].FederationIdentifier);
                System.debug('@@@@@@@@..' + response.status);        
                System.debug('@@@@@@@@..' + response.message);
            }    
        }
        catch(Exception e) {
            System.debug('@@@@@@@@..' + e);        
        } // End - catch        
    }    
}