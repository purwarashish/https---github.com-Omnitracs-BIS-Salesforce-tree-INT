@isTest(seeAllData = true)
global class QESUnitySuperLinkWebServicesMock implements WebServiceMock{
    
    global void doInvoke(
        
        Object stub,
        
        Object request,
        
        Map<String, Object> response,
        
        String endpoint,
        
        String soapAction,
        
        String requestName,
        
        String responseNS,
        
        String responseName,
        
        String responseType) 
    {
        
     
       if(request instanceof  QESUnitySuperLinkWebServices.MyActiveLinksByGroupInput)
        {
            
            QESUnitySuperLinkWebServices.getMyActiveLinksByGroupResponse r = new  QESUnitySuperLinkWebServices.getMyActiveLinksByGroupResponse();
            r.StandardResponse = new QESUnitySuperLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        } else  if(request instanceof  QESUnityAdminLinkWebServices.UserInput)
        {
            
            QESUnityAdminLinkWebServices.UserOutput r = new  QESUnityAdminLinkWebServices.UserOutput();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
           else  if(request instanceof  QESUnitySuperLinkWebServices.ActiveLinksByGroupInput)
        {
            
           QESUnitySuperLinkWebServices.getActiveLinksByGroupResponse r = new  QESUnitySuperLinkWebServices.getActiveLinksByGroupResponse();
            r.StandardResponse = new QESUnitySuperLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
         else  if(request instanceof QESUnityAdminLinkWebServices.RoleListForUserInput)
        {
            
          QESUnityAdminLinkWebServices.getRoleListForUserResponse r = new  QESUnityAdminLinkWebServices.getRoleListForUserResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
         else  if(request instanceof QESUnityAdminLinkWebServices.getMigrationPlansBySearch)
        {
            
          QESUnityAdminLinkWebServices.getMigrationPlansBySearchResponse r = new  QESUnityAdminLinkWebServices.getMigrationPlansBySearchResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
         else  if(request instanceof QESUnityAdminLinkWebServices.CompanyInput)
        {
            
          QESUnityAdminLinkWebServices.getCompanyResponse r = new  QESUnityAdminLinkWebServices.getCompanyResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          else  if(request instanceof  QESUnityAdminLinkWebServices.MigrateSalesforceContactIdInput )
        {
            
          QESUnityAdminLinkWebServices.MigrateSalesforceContactIdOutput r = new  QESUnityAdminLinkWebServices.MigrateSalesforceContactIdOutput();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          else  if(request instanceof  QESUnityAdminLinkWebServices.AlertEmailAddressInput)
        {
            
            QESUnityAdminLinkWebServices.AlertEmailAddressOutput r = new  QESUnityAdminLinkWebServices.AlertEmailAddressOutput();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          else  if(request instanceof  QESUnityAdminLinkWebServices.GrantCapabilityToLinkedUserInput)
        {
            
            QESUnityAdminLinkWebServices.grantCapabilityToLinkedUserResponse r = new  QESUnityAdminLinkWebServices.grantCapabilityToLinkedUserResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          else  if(request instanceof   QESUnityAdminLinkWebServices.RevokeCapabilityFromLinkedUserInput )
        {
            
            QESUnityAdminLinkWebServices.revokeCapabilityFromLinkedUserResponse r = new  QESUnityAdminLinkWebServices.revokeCapabilityFromLinkedUserResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
           else  if(request instanceof   QESUnityAdminLinkWebServices.CreateCompanyInput)
        {
            
            QESUnityAdminLinkWebServices.createCompanyResponse r = new  QESUnityAdminLinkWebServices.createCompanyResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
           else  if(request instanceof QESUnityAdminLinkWebServices.CreateUserAccountInput)
        {
            
            QESUnityAdminLinkWebServices.createLinkedUserAccountResponse r = new  QESUnityAdminLinkWebServices.createLinkedUserAccountResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
           else  if(request instanceof QESUnityAdminLinkWebServices.CompanybyERPInput)
        {
            
            QESUnityAdminLinkWebServices.getCompanyByERPResponse r = new  QESUnityAdminLinkWebServices.getCompanyByERPResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
           else  if(request instanceof  QESUnityAdminLinkWebServices.UpdateCompanyInput)
        {
            
            QESUnityAdminLinkWebServices.updateCompanyResponse r = new  QESUnityAdminLinkWebServices.updateCompanyResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
           else  if(request instanceof  QESUnityAdminLinkWebServices.GenerateMigrationPlanDetailsInput)
        {
            
            QESUnityAdminLinkWebServices.GenerateMigrationPlanDetailsOutput r = new  QESUnityAdminLinkWebServices.GenerateMigrationPlanDetailsOutput();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
           else  if(request instanceof  QESUnityAdminLinkWebServices.EmailAddressInput)
        {
            
            QESUnityAdminLinkWebServices.EmailAddressOutput r = new  QESUnityAdminLinkWebServices.EmailAddressOutput();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
           else  if(request instanceof  QESUnityAdminLinkWebServices.ProcessMigrationPlanInput)
        {
            
            QESUnityAdminLinkWebServices.ProcessMigrationPlanOutput r = new  QESUnityAdminLinkWebServices.ProcessMigrationPlanOutput();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
           else  if(request instanceof  QESUnityAdminLinkWebServices.UpdateUserAccountInput)
        {
            
            QESUnityAdminLinkWebServices.updateLinkedUserAccountResponse r = new  QESUnityAdminLinkWebServices.updateLinkedUserAccountResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
           else  if(request instanceof  QESUnityAdminLinkWebServices.UpdateCompanyModelDetails)
        {
            
            QESUnityAdminLinkWebServices.updateCompanyModelDetailsResponse r = new  QESUnityAdminLinkWebServices.updateCompanyModelDetailsResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
           else  if(request instanceof  QESUnityAdminLinkWebServices.MigrateSalesforceCompIdInput)
        {
            
            QESUnityAdminLinkWebServices.MigrateSalesforceCompIdOutput r = new  QESUnityAdminLinkWebServices.MigrateSalesforceCompIdOutput();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          else  if(request instanceof  QESUnityAdminLinkWebServices.DeleteCompanyAccountInput)
        {
            
            QESUnityAdminLinkWebServices.deleteLinkedCompanyAccountResponse r = new  QESUnityAdminLinkWebServices.deleteLinkedCompanyAccountResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          else  if(request instanceof  QESUnityAdminLinkWebServices.CreateCompanyAccountInput)
        {
            
            QESUnityAdminLinkWebServices.createLinkedCompanyAccountResponse r = new  QESUnityAdminLinkWebServices.createLinkedCompanyAccountResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          else  if(request instanceof  QESUnityAdminLinkWebServices.CreateUserInput)
        {
            
            QESUnityAdminLinkWebServices.CreateUserOutput r = new  QESUnityAdminLinkWebServices.CreateUserOutput();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          else  if(request instanceof  QESUnityAdminLinkWebServices.StartChangeEmailAddressInput)
        {
            
            QESUnityAdminLinkWebServices.StartChangeEmailAddressOutput r = new  QESUnityAdminLinkWebServices.StartChangeEmailAddressOutput();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
           else  if(request instanceof  QESUnityAdminLinkWebServices.CompanyProvModeInput)
        {
            
            QESUnityAdminLinkWebServices.changeCompanyProvModeResponse r = new  QESUnityAdminLinkWebServices.changeCompanyProvModeResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
           else  if(request instanceof  QESUnityAdminLinkWebServices.SysConfigInput)
        {
            
            QESUnityAdminLinkWebServices.SysConfigOutput r = new  QESUnityAdminLinkWebServices.SysConfigOutput();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }   else  if(request instanceof  QESUnityAdminLinkWebServices.UpdateUserInput)
        {
            
            QESUnityAdminLinkWebServices.UpdateUserOutput r = new  QESUnityAdminLinkWebServices.UpdateUserOutput();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
   else  if(request instanceof  QESUnityAdminLinkWebServices.createMigrationPlan)
        {
            
            QESUnityAdminLinkWebServices.createMigrationPlanResponse r = new  QESUnityAdminLinkWebServices.createMigrationPlanResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
         else  if(request instanceof  QESUnityAdminLinkWebServices.AffiliateListForUserInput)
        {
            
            QESUnityAdminLinkWebServices.getAffiliatesForUserResponse r = new  QESUnityAdminLinkWebServices.getAffiliatesForUserResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
         else  if(request instanceof  QESUnityAdminLinkWebServices.CompanybyQSPInput)
        {
            
            QESUnityAdminLinkWebServices.getCompanyByQSPResponse r = new QESUnityAdminLinkWebServices.getCompanyByQSPResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
         else  if(request instanceof  QESUnityAdminLinkWebServices.getMigrationPlan)
        {
            
            QESUnityAdminLinkWebServices.getMigrationPlanResponse r = new  QESUnityAdminLinkWebServices.getMigrationPlanResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
         else  if(request instanceof  QESUnityAdminLinkWebServices.UpdateCompanyAccountInput)
        {
            
            QESUnityAdminLinkWebServices.updateLinkedCompanyAccountResponse r = new  QESUnityAdminLinkWebServices.updateLinkedCompanyAccountResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          else  if(request instanceof   QESUnityAdminLinkWebServices.deleteMigrationPlan)
        {
            
            QESUnityAdminLinkWebServices.deleteMigrationPlanResponse r = new  QESUnityAdminLinkWebServices.deleteMigrationPlanResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          else  if(request instanceof  QESUnityAdminLinkWebServices.UserPasswordInput)
        {
            
            QESUnityAdminLinkWebServices.setUserPasswordResponse r = new  QESUnityAdminLinkWebServices.setUserPasswordResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          else  if(request instanceof  QESUnityAdminLinkWebServices.UserProveModeInput)
        {
            
            QESUnityAdminLinkWebServices.UserProveModeOutput r = new  QESUnityAdminLinkWebServices.UserProveModeOutput();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          else  if(request instanceof   QESUnityAdminLinkWebServices.UserInput)
        {
            
            QESUnityAdminLinkWebServices.UserOutput  r = new  QESUnityAdminLinkWebServices.UserOutput ();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          else  if(request instanceof  QESUnityAdminLinkWebServices.ApplicationListInput)
        {
            
            QESUnityAdminLinkWebServices.ApplicationListOutput r = new QESUnityAdminLinkWebServices.ApplicationListOutput();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          else  if(request instanceof  QESUnityAdminLinkWebServices.DeleteUserAccountInput)
        {
            
            QESUnityAdminLinkWebServices.deleteLinkedUserAccountResponse r = new  QESUnityAdminLinkWebServices.deleteLinkedUserAccountResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          else  if(request instanceof  QESUnityAdminLinkWebServices.updateMigrationPlan)
        {
            
            QESUnityAdminLinkWebServices.updateMigrationPlanResponse r = new  QESUnityAdminLinkWebServices.updateMigrationPlanResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          else  if(request instanceof  QESUnityAdminLinkWebServices.MigrateCompanyAdminsAndUserInput)
        {
            
            QESUnityAdminLinkWebServices.MigrateCompanyAdminsAndUserOutput r = new  QESUnityAdminLinkWebServices.MigrateCompanyAdminsAndUserOutput();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
           else  if(request instanceof QESUnityAdminLinkWebServices.UpdateSupportContactDetails)
        {
            
            QESUnityAdminLinkWebServices.updateSupportContactDetailsResponse r = new QESUnityAdminLinkWebServices.updateSupportContactDetailsResponse();
            r.StandardResponse = new QESUnityAdminLinkWebServices.standardResponse();
            response.put('response_x', r); 
            return;
        }
          
    }
    
}