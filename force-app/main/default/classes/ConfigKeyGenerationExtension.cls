/*******************************************************************************
 * File:  ConfigKeyGenerationExtension.cls
 * Date:  March 17, 2009
 * Author:  Charlie Heaps
 *
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *
 * Purpose: 
 *   Class used to generate a Roadnet Transportation Suite Config Key from
 *   Salesforce. Used by ConfigKeyGenerationPage.
 *******************************************************************************/

public class ConfigKeyGenerationExtension
{
  // Accessors
    public Map<string, string> myMap = new Map<string, string>();
    
    public User currentUser{get;set;}
    
    public boolean isEmergencyKey{get;set;}
    
    public boolean doesAccountHaveAnyProducts{get; set;}//  
    public boolean showConfigKeySection{get;set;}
    public string editableCfgKey{get;set;}
  
    public String licenseKeyExpirationDate{get; set;}
  public String licensekeytype{get; set;}
  public List<SelectOption> lktList{get; set;}
  public Config_Key_Activity__c cfa {get; set;}
  public Account acct {get; set;}
  
    public boolean isDemoTestConfigKey{get; set;}
    
    // Constructor
  
    public ConfigKeyGenerationExtension(apexpages.standardController stdController)
    {
        PageReference mypageref = apexpages.currentpage();
        myMap = mypageref.getparameters();//  grab the url paramters
        
        isEmergencyKey = myMap.get('para') == '1'; //  we are passing in to the url an mapping of "para" and 1 or 2
        
        editableCfgKey ='';
        
        //  query the user record to see if they can use the standard or emergency button
        currentUser = [select id from User where id =: userInfo.getUserId()];
        
        isDemoTestConfigKey = false;
        showConfigKeySection = false;
        isEmergencyKey = false;
    
    cfa = new Config_Key_Activity__c();
    acct = new Account();
        account = [select id, Name, Clientele_ID__c, OwnerId, Owner.Email, /*webid__c,*/ Inherit_Parent_s_Products__c, parentid, license_key_type__c from Account where id = :stdController.getid()];
        user = [select Name, Email from User where Id = :UserInfo.getUserId()];
        
    
        consolidateLineItems();
        generateConfigKey();
    }
    
    
    public string getEmail()
    {
        if (email == null)
        {
            email = user.Email;
        }
        
        return email;
    }
    
  public List<SelectOption> getlktList()
  {
    List<SelectOption> options = new List<SelectOption>();
          
     Schema.DescribeFieldResult fieldResult = Schema.SObjectType.Account.fields.License_Key_Type__c;
    fieldResult = fieldResult.getSobjectField().getDescribe();
     List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
          
     for(Schema.PicklistEntry f : ple)
     {
        options.add(new SelectOption(f.getLabel(), f.getValue()));
     }       
     return options;
  }
  
    public void setEmail(string value)
    {
        email = value;
    }
    public string emergencyEmail
    {
        get
        {
            return user.Email;
        }   
    }
    
    public string getComment()
    {
        return comment;
    }
    
    public void setComment(string value)
    {
        comment = value;
    }
    

    public string getCfgKeyTxt()
    {
        return cfgKeyTxt;
    }
    
    public string getCfgKeyHtml()
    {
        return cfgKeyHtml;
    }
        
    public PageReference showMainSection()
    {
        showConfigKeySection = true;
        return null;
    }
        
    public PageReference sendEmail()
    {
        // Sends an email containing the config key as an attachment.
        if (IsEmergencyKey && Util.isBlank(emergencyEmail))
        {
            Account.AddError('Email address is required.');
            return null;    
        }
        else
        {
            //  so this is where the logic for the emergency key will take place.  simple put, if not emergency key create the email
            //  like normal, if it's emergency, make sure we use the edtiableConfigKey for the email's body
            //  and that the toemail are user.email, account.owner.email and support leads
            
            util.debug('Sending Email');
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Set<string> addressesSet = new Set<string>();
            
            if (isEmergencyKey)
            {
                addressesSet.Add(emergencyEmail);
                //  current logged in user's email has already been added, let's add the account owner and the support leads
                if (account.ownerId != null && account.Owner.Email != null && !addressesSet.Contains(account.owner.email) )
                {
                    addressesSet.Add(account.owner.Email);
                }
                
                Set<string> configKeyEmailRecips = Config_Key_Email_Recip__c.getAll().keySet();
                if (configKeyEmailRecips != null)
                {
                    for (string singleEmail : configKeyEmailRecips)
                    {
                       if (!addressesSet.contains(singleEmail))
                       {
                           addressesSet.Add(singleEmail);
                       }
                    }
                }
            }
            else
            {
                //addressesSet.Add(email);
                //  john asked for the config key to have the same screen as the emergency config key, to achivee this, i 
                //  took away the outputtext section of the vf page and it now shows the emergency key section
                // since we are looking at the emergency key section, we need to use the emergency email
                addressesSet.Add(emergencyemail);
            }
            
            //  this will either be one email or a couple depending on this is emergencyconfig key
            List<string> emailList = new List<string>();
            emaillist.addAll(addressesSet);
            mail.setToAddresses(emailList);
            
            mail.setSenderdisplayName('Salesforce.com');
            
            string subject = (isDemoTestConfigKey ? 'Test/Demo ' : '' ) + 
                'Config Key Text File for '+ account.name; 
            mail.setSubject(subject);
            
            string bodyText = (isDemoTestConfigKey ? 'Test/Demo ' : '' ) + 
                'Config Key Text File for '+ account.name + ' is attached.';
            
            if (comment != null && comment.length() > 0)
            {
                bodyText += '\n\nComment:  ' + comment;
            }
            
            mail.setPlainTextBody(bodyText);
    
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            
            List<Messaging.EmailFileAttachment> listOfEFAs=new List<Messaging.EmailFileAttachment>();
            
            string filename = account.Name.ReplaceAll(' ', '_') + '.txt';
            
            efa.setFileName(filename);
            if (isEmergencyKey)
            {
                //  use the users' editable config key text as the file attachment body
                efa.setBody(blob.valueof(editableCfgKey));
            }
            else
            {
                //  create email attachment just like the original button did using the non editabel config key text
                efa.setBody(blob.valueof(cfgKeyTxt));
            }
            
            listOfEFAs.add(efa);
            
            mail.setFileAttachments(listOfEFAs);
            
            {
                Messaging.sendemailResult[] ser = 
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
                //  create apex email record that email was sent successfully
                if (ser[0].isSuccess())
                {
                    
                }
                else
                {
                    throw new myException('Failed to send email due to ' + ser[0].getErrors()[0].getMessage());
                }
          
        
        Config_Key_Activity__c cfa = new Config_Key_Activity__c();
          cfa.Account__c = account.id;
        //if(isEmergencyKey == true){ (isEmergencyKey ? emergencyEmail : email);
                  cfa.Activity_Description__c  = 'Config Key text file e-mailed to ' + emergencyEmail;
        //}
        //else cfa.Activity_Description__c  = 'Config Key text file e-mailed for ' + account.Name;
                  cfa.comment__c = comment;
                  cfa.Emergency_Key__c = isEmergencyKey;
                  cfa.Test_Demo__c = isDemoTestConfigKey;
    if(licensekeytype != null){
          cfa.License_Key_Type__c = LicenseKeyType;
    }
    if(licenseKeyExpirationDate != null){
          cfa.Key_Expiration_Date__c = Date.parse(licenseKeyExpirationDate);
    }
        insert cfa;
        
        if(licensekeytype != null){
      account.Config_Key_Type__c = LicenseKeyType;
    }
    if(licenseKeyExpirationDate != null){
      account.Config_Key_Expiration_Date__c = Date.parse(licenseKeyExpirationDate);
    }
        
        update account;
                /*Task configTask = new Task();
                configTask.WhatId = account.id;
                configTask.License_Activity__c = 'Config Key Activity';
                configTask.License_Key_date__c = date.today();
                configTask.Status = 'Completed';
                configTask.Subject = 'Config Key text file e-mailed to ' + (isEmergencyKey ? emergencyEmail : email);
                configTask.Description = comment;
                configTask.Was_Emergency_Key__c = isEmergencyKey;
                configTask.Is_Test_Demo_Config_Key__c = isDemoTestConfigKey;*/
                
                
                //insert configTask;
               
            }
            
            return new PageReference('/' + account.id);
        }
    }
    
    public PageReference cancelEmail()
    {
        return new PageReference('/' + account.id);
    }        
    
    public PageReference resetConfigKeyData()
    {
        //  null out all of the previous line item asignemtns
        rnAss = null;
        tpAss = null;
        mcAss =  null;
        flAss =  null;
        //ricAss =  null;
        rpdAss =  null;
        wsMapAss =  null; //  the old product for this was  netMapAss;
        wsDataIntAss =  null;//  the old old product for this was netIntAss; 
        netSchAss =  null;
        merchAss =  null;
        mcDvirAss =  null;
        rtsConnectAss =  null;
        rnTeleAdaptAss =  null;
        rnActiveAlertAss =  null;
        
        voiceNavAss = null;
        
        consolidateLineItems();
        generateConfigKey();
        
        return null;        
    }

    // Begin Private methods
    private void generateConfigKey()
    {

        string orgId = account.Id;
        string currentVersion = '5'; //  previously 2, then 3, now 4 per sf issue:  https://na1.salesforce.com/a0W30000001dslQ
        // If an account was originally entered in Clientele, 
        // the Org ID is the Clientele ID. Otherwise, Org ID
        // is the Salesforce account ID.
        if (account.Clientele_ID__c != null)
        {
            orgId = account.Clientele_ID__c;
        }
        
        // Create the text of the Config Key.
        
        cfgKeyTxt = 'DATAINFO:\n';
        cfgKeyTxt += 'VERSION = ' + currentVersion + '\n';
        cfgKeyTxt += 'CUSTINFO:\n'; 
        cfgKeyTxt += account.Name + '\n';
        cfgKeyTxt += 'Org ID is ' + orgId + '\n';
        cfgKeyTxt += 'Common ID is Null' + '\n';
        cfgKeyTxt += 'RN5000 Config File:\n';
        cfgKeyTxt += 'Created on ' + Datetime.now() + ' By ' + user.Name + '\n';
        
        //  this bit of code will add ric as an asset if the customer has rn or mc and uses that rn/mc's term end date and vehicle metrics
        AssetEx ricTempAsset;
        boolean doesAccountOwnRnOrMc = false;
        
        
        if (rnAss != null || mcAss != null)
        {
            doesAccountOwnRnOrMc = true;
            if (rnAss != null)
            {
                //  scary assignment to make here as changes to ricTempAsset will be made to rnASs
                ricTempAsset = rnAss;
            }
            else if (mcAss != null)
            {
                ricTempAsset = mcAss;
            }
        }
        
        // Orders section
        
        cfgKeyTxt += 'PRODUCTS:\n';
        if (rnAss != null)
        {
            cfgKeyTxt += getProductShortName(rnAss) + ',' + getAssetDate(rnAss) + '\n';
        }
        if (tpAss != null)
        {
            cfgKeyTxt += getProductShortName(tpAss) + ',' + getAssetDate(tpAss) + '\n';
            cfgKeyTxt += 'DP' + ',' + getAssetDate(tpAss) + '\n';//  we always add dp along with tp
        }
        if (mcAss != null)
        {
            cfgKeyTxt += getProductShortName(mcAss) + ',' + getAssetDate(mcAss) + '\n';
        }
        if (doesAccountOwnRnOrMc)
        {
            cfgKeyTxt += 'RIC' + ',' + getAssetDate(ricTempAsset) + '\n';
        }
        if (flAss != null)
        {
            cfgKeyTxt += getProductShortName(flAss) + ',' + getAssetDate(flAss) + '\n';
        }
       /* if (ricAss != null)
        {
            cfgKeyTxt += getProductShortName(ricAss) + ',' + getAssetDate(ricAss) + '\n';
        }
        */
        if (rpdAss != null)
        {
            cfgKeyTxt += getProductShortName(rpdAss) + ',' + getAssetDate(rpdAss) + '\n';
        }
        if (wsMapAss != null)
        {
            cfgKeyTxt += getProductShortName(wsMapAss) + ',' + getAssetDate(wsMapAss) + '\n';
        }
        if (wsDataIntAss != null)
        {
            cfgKeyTxt += getProductShortName(wsDataIntAss) + ',' + getAssetDate(wsDataIntAss) + '\n';
        }
        if (netSchAss != null)
        {
            cfgKeyTxt += getProductShortName(netSchAss) + ',' + getAssetDate(netSchAss) + '\n';
        }
        if (merchAss != null)
        {
            cfgKeyTxt += getProductShortName(merchAss) + ',' + getAssetDate(merchAss) + '\n';
        }
        if (mcDvirAss != null)
        {
            cfgKeyTxt += getProductShortName(mcDvirAss) + ',' + getAssetDate(mcDvirAss) + '\n';
        }
        if (rtsConnectAss != null)
        {
            cfgKeyTxt += getProductShortName(rtsConnectAss) + ',' + getAssetDate(rtsConnectAss) + '\n';
        }
        if (rnTeleAdaptAss != null)
        {
            cfgKeyTxt += getProductShortName(rnTeleAdaptAss) + ',' + getAssetDate(rnTeleAdaptAss) + '\n';
        }
        if (rnActiveAlertAss != null)
        {
            cfgKeyTxt += getProductShortName(rnActiveAlertAss) + ',' + getAssetDate(rnActiveAlertAss) + '\n';
        }
        if (voiceNavAss != null)
        {
            cfgKeyTxt += getProductShortName(voiceNavAss) + ',' + getAssetDate(voiceNavAss) + '\n';
        }
        
        cfgKeyTxt += 'LIMITS:\n';
        if (rnAss != null)
        {
            cfgKeyTxt += getProductShortName(rnAss) + ',Users=' + nullToZero(rnAss.numberOfUsers) + ',Depots=' + nullToZero(rnAss.numberOfDcs) + ',Metric=' + nullToZero(rnAss.licenseMetricQuantity)  + '\n'; 
        }
        if (tpAss != null)
        {
            cfgKeyTxt += getProductShortName(tpAss) + ',Users=' + nullToZero(tpAss.numberOfUsers) + ',Depots=' + nullToZero(tpAss.numberOfDcs) + ',Metric=' + nullToZero(tpAss.licenseMetricQuantity)  + '\n';
            //  dp is always added with tp
            cfgKeyTxt += 'DP' + ',Users=' + nullToZero(tpAss.numberOfUsers) + ',Depots=' + nullToZero(tpAss.numberOfDcs) + ',Metric=' + nullToZero(tpAss.licenseMetricQuantity)  + '\n';
        }
        if (mcAss != null)
        {
            cfgKeyTxt += getProductShortName(mcAss) + ',Users=' + nullToZero(mcAss.numberOfUsers) + ',Depots=' + nullToZero(mcAss.numberOfDcs) + ',Metric=' + nullToZero(mcAss.licenseMetricQuantity)  + '\n'; 
        }
        //  this assigns the ric if they have rn or mc
        if (doesAccountOwnRnOrMc)
        {
            cfgKeyTxt += 'RIC' + ',Users=' + nullToZero(ricTempAsset.numberOfUsers) + ',Depots=' + nullToZero(ricTempAsset.numberOfDcs) + ',Metric=' + nullToZero(ricTempAsset.licenseMetricQuantity)  + '\n'; 
        }
        if (flAss != null)
        {
            cfgKeyTxt += getProductShortName(flAss) + ',Users=' + nullToZero(flAss.numberOfUsers) + ',Depots=' + nullToZero(flAss.numberOfDcs) + ',Metric=' + nullToZero(flAss.licenseMetricQuantity)  + '\n'; 
        }
        /*
        if (ricAss != null)
        {
            cfgKeyTxt += getProductShortName(ricAss) + ',Users=' + nullToZero(ricAss.numberOfUsers) + ',Depots=' + nullToZero(ricAss.numberOfDcs) + ',Metric=' + nullToZero(ricAss.licenseMetricQuantity)  + '\n'; 
        }
        */
        if (rpdAss != null)
        {
            cfgKeyTxt += getProductShortName(rpdAss) + ',Users=' + nullToZero(rpdAss.numberOfUsers) + ',Depots=' + nullToZero(rpdAss.numberOfDcs) + ',Metric=' + nullToZero(rpdAss.licenseMetricQuantity)  + '\n'; 
        }
        if (wsMapAss != null)
        {
            cfgKeyTxt += getProductShortName(wsMapAss) + ',Users=' + nullToZero(wsMapAss.numberOfUsers) + ',Depots=' + nullToZero(wsMapAss.numberOfDcs) + ',Metric=' + nullToZero(wsMapAss.licenseMetricQuantity)  + '\n'; 
        }
        if (wsDataIntAss != null)
        {
            cfgKeyTxt += getProductShortName(wsDataIntAss) + ',Users=' + nullToZero(wsDataIntAss.numberOfUsers) + ',Depots=' + nullToZero(wsDataIntAss.numberOfDcs) + ',Metric=' + nullToZero(wsDataIntAss.licenseMetricQuantity)  + '\n'; 
        }
        if (netSchAss != null)
        {
            cfgKeyTxt += getProductShortName(netSchAss) + ',Users=' + nullToZero(netSchAss.numberOfUsers) + ',Depots=' + nullToZero(netSchAss.numberOfDcs) + ',Metric=' + nullToZero(netSchAss.licenseMetricQuantity)  + '\n'; 
        }
        if (merchAss != null)
        {
            cfgKeyTxt += getProductShortName(merchAss) + ',Users=' + nullToZero(merchAss.numberOfUsers) + ',Depots=' + nullToZero(merchAss.numberOfDcs) + ',Metric=' + nullToZero(merchAss.licenseMetricQuantity)  + '\n'; 
        }
        if (mcDvirAss != null)
        {
            cfgKeyTxt += getProductShortName(mcDvirAss) + ',Users=' + nullToZero(mcDvirAss.numberOfUsers) + ',Depots=' + nullToZero(mcDvirAss.numberOfDcs) + ',Metric=' + nullToZero(mcDvirAss.licenseMetricQuantity)  + '\n'; 
        }
        if (rtsConnectAss != null)
        {
            cfgKeyTxt += getProductShortName(rtsConnectAss) + ',Users=' + nullToZero(rtsConnectAss.numberOfUsers) + ',Depots=' + nullToZero(rtsConnectAss.numberOfDcs) + ',Metric=' + nullToZero(rtsConnectAss.licenseMetricQuantity)  + '\n'; 
        }
        if (rnTeleAdaptAss != null)
        {
            cfgKeyTxt += getProductShortName(rnTeleAdaptAss) + ',Users=' + nullToZero(rnTeleAdaptAss.numberOfUsers) + ',Depots=' + nullToZero(rnTeleAdaptAss.numberOfDcs) + ',Metric=' + nullToZero(rnTeleAdaptAss.licenseMetricQuantity)  + '\n'; 
        }
        if (rnActiveAlertAss != null)
        {
            cfgKeyTxt += getProductShortName(rnActiveAlertAss) + ',Users=' + nullToZero(rnActiveAlertAss.numberOfUsers) + ',Depots=' + nullToZero(rnActiveAlertAss.numberOfDcs) + ',Metric=' + nullToZero(rnActiveAlertAss.licenseMetricQuantity)  + '\n'; 
        }
        if (voiceNavAss != null)
        {
            cfgKeyTxt += getProductShortName(voiceNavAss) + ',Users=' + nullToZero(voiceNavAss.numberOfUsers) + ',Depots=' + nullToZero(voiceNavAss.numberOfDcs) + ',Metric=' + nullToZero(voiceNavAss.licenseMetricQuantity)  + '\n'; 
        }
       
        cfgKeyTxt += '\n';
        
        // Convert the text version to an html version for display to the user
        cfgKeyHtml = cfgKeyTxt.replaceAll('\n', '<br/>');
        editableCfgKey = cfgKeyTxt;
        
    }

   
    private void consolidateLineItems()
    {
        //  if the account inherit's parents products, need to make sure we get the parents accounts assets also
        if (account.Inherit_Parent_s_Products__c && account.parentId != null)
        {
            accountAssets = 
                [select id, name, Eval__c, Asset_Status__c, Quantity__c, product__r.name, product__r.Product_Identifier__c, 
                Number_of_DCs__c, Number_of_Multi_Shift_Routes__c, Number_of_Users__c, Term_End_Date__c, License_Type__c, Product__c, Product__r.Is_Perpetual__c from Customer_Asset__c 
                where 
                (account__c =: account.id OR Account__c =: account.parentId) AND
                Eval__c =: isDemoTestConfigKey AND 
                Asset_Status__c = 'Active' AND 
                product__c != null AND
                    (Product_Type__c = 'Software' OR
                    Product__r.Product_Identifier__c = 'TMX' OR //  rn telematics adaptor - product type = hardware
                    Product__r.Product_Identifier__c = 'VOICENAV')]; //  co pilot voice nav  product type = navigation
        }
        else
        {
            accountAssets = 
                [select id, name, Eval__c, Asset_Status__c, Quantity__c, product__r.name, product__r.Product_Identifier__c, 
                Number_of_DCs__c,  Number_of_Users__c,Number_of_Multi_Shift_Routes__c, Term_End_Date__c, License_Type__c, Product__c, Product__r.Is_Perpetual__c from Customer_Asset__c 
                where 
                account__c =: account.id and
                Eval__c =: isDemoTestConfigKey AND 
                Asset_Status__c = 'Active' AND 
                product__c != null AND
                    (Product_Type__c = 'Software' OR
                    Product__r.Product_Identifier__c = 'TMX' OR //  rn telematics adaptor - product type = hardware
                    Product__r.Product_Identifier__c = 'VOICENAV')]; //  co pilot voice nav  product type = navigation
        }
        
        
        util.debug('consolidateLineItems called and assets queried, isDemoTestConfigKey: ' + 
            isDemoTestConfigKey + ' num of assets queried: ' + accountAssets.size());      
        doesAccountHaveAnyProducts = accountAssets == null || accountAssets.size() == 0;
        showConfigKeySection = !doesAccountHaveAnyProducts;
        
        //  so jane has confirmed that we need to sum these up, i am not going to use charlie's logic but using my own
        for (Customer_Asset__c ass : accountAssets)
        {
            if (isRn(ass))
            {
                if (rnAss == null)
                {
                    rnAss = new AssetEx(ass);
                    
                    //  i want to do a clone here becuase we need the lookup fields from the product table
                    //rnAss = ass.Clone(false, true);
                    cloneCertainAssetFields(rnAss, ass);
                }
                //  so i am trying to figure out the way i could avoid having to create more properties on the assetex class
                //  the problem is that since i am passing an object into the AssetEx constructor it is being passed by refernce
                //  so when i assign 0s to the number of dcs/users/license metric quanityt, it is doing it to the objects actual fields
                //  which makes the below summatino null... the fix... i want tto say is to just pass the asset into the method
                //  but thats what i was doing before making this change and it was working... so this is weird.. maybe i can modify the method
                //  to only assign 0 if the field is null?
                
                rnAss.numberOfDcs += nullToZero(ass.Number_of_DCs__c);
                rnAss.numberOfUsers += nullToZero(ass.Number_of_Users__c);
                
                //  a quick note on this.  the old salesforce code use to sum to the lineitem.number of lcienced vehciles the line items multishift vehicles
                //  this logic was lsot when i converted this to work with omnitracs stuff, per case no 01811270, john has requested that
                //  if the assets.mulit_shift_routes contains value, we use that, instead, we use the number of licensed vechiles which i BELIEVE is the
                //  licence metric qauntity. i am not sure if this is the right logic however, i am going to add what the config key did, and have roxanne test in uat,
                //  if it's wrong its easy to make th change
                rnAss.licenseMetricQuantity += nullToZero(ass.Quantity__c) + nullToZero(ass.Number_of_Multi_Shift_Routes__c);
                //  best way to explain the below is to give an example.  lets say an account has two roadnet assets.  forwatever reason
                //  one of them is pereptual, the other is not... now what we need to have happen is if at least one of the same/like assets
                //  is perpetual, all of them should be treated as perpetual meaning there end date would be VERY long
                //  so each time we sum up a like asset, we check if it is perpetual and if it is, we set the main assets' isperpetual to true
                if (ass.Product__r.Is_Perpetual__c)
                {
                    rnAss.isPerpetual = true;
                }
                
                if (!rnAss.IsPerpetual)//  only need to set the end term date if the aset is non perpetual
                {
                    //  the logic is thus, if the rnASs date is blank, we only want to set it if the curerent asset date is not null
                    //  if the date is set and the assest date is set, then do the date comparision
                    
                    if (rnAss.termEndDate == null && ass.Term_End_Date__c != null)
                    {
                        rnAss.termEndDate = ass.Term_End_date__c;
                    }
                    else if (rnAss.termEndDate != null && ass.Term_End_Date__c != null)
                    {
                        //  take the furtherst asset term end date
                        if (ass.Term_End_Date__c > rnAss.termEndDate)
                        {
                            rnAss.termEndDate = ass.Term_End_date__c;
                        }
                    }
                }
            }
            if (isTp(ass))
            {
                if (tpAss == null)
                {
                    
                    tpAss = new AssetEx(ass);
                    
                    //  i want to do a clone here becuase we need the lookup fields from the product table
                    //tpAss = ass.Clone(false, true);
                    cloneCertainAssetFields(tpAss, ass);
                }
                
                tpAss.numberOfDcs += nullToZero(ass.Number_of_DCs__c);
                tpAss.numberOfUsers += nullToZero(ass.Number_of_Users__c);
                tpAss.licenseMetricQuantity += nullToZero(ass.Quantity__c) + nullToZero(ass.Number_of_Multi_Shift_Routes__c);
                
                if (ass.Product__r.Is_Perpetual__c)
                {
                    tpAss.isPerpetual = true;
                }
                
                if (!tpAss.IsPerpetual)//  only need to set the end term date if the aset is non perpetual
                {
                    //  the logic is thus, if the rnASs date is blank, we only want to set it if the curerent asset date is not null
                    //  if the date is set and the assest date is set, then do the date comparision
                    
                    if (tpAss.termEndDate == null && ass.Term_End_Date__c != null)
                    {
                        tpAss.termEndDate = ass.Term_End_Date__c;
                    }
                    else if (tpAss.termEndDate != null && ass.Term_End_Date__c != null)
                    {
                        //  take the furtherst asset term end date
                        if (ass.Term_End_Date__c > tpAss.termEndDate)
                        {
                            tpAss.termEndDate = ass.Term_End_Date__c;
                        }
                    }
                }
            }
            
            if (isMc(ass))
            {
                if (mcAss == null)
                {
                    mcAss = new AssetEx(ass);
                    //  i want to do a clone here becuase we need the lookup fields from the product table
                    //mcAss = ass.Clone(false, true);
                    cloneCertainAssetFields(mcAss, ass);
                }
                
                mcAss.numberOfDcs += nullToZero(ass.Number_of_DCs__c);
                mcAss.numberOfUsers += nullToZero(ass.Number_of_Users__c);
                mcAss.licenseMetricQuantity += nullToZero(ass.Quantity__c) + nullToZero(ass.Number_of_Multi_Shift_Routes__c);
                
                if (ass.Product__r.Is_Perpetual__c)
                {
                    mcAss.isPerpetual = true;
                }
                
                if (!mcAss.IsPerpetual)//  only need to set the end term date if the aset is non perpetual
                {
                    //  the logic is thus, if the rnASs date is blank, we only want to set it if the curerent asset date is not null
                    //  if the date is set and the assest date is set, then do the date comparision
                    
                    if (mcAss.termEndDate == null && ass.Term_End_Date__c != null)
                    {
                        mcAss.termEndDate = ass.Term_End_Date__c;
                    }
                    else if (mcAss.termEndDate != null && ass.Term_End_Date__c != null)
                    {
                        //  take the furtherst asset term end date
                        if (ass.Term_End_Date__c > mcAss.termEndDate)
                        {
                            mcAss.termEndDate = ass.Term_End_Date__c;
                        }
                    }
                }
            }
            if (isFl(ass))
            {
                if (flAss == null)
                {
                    flAss = new AssetEx(ass);
                    //  i want to do a clone here becuase we need the lookup fields from the product table
                    //flAss = ass.Clone(false, true);
                    cloneCertainAssetFields(flAss, ass);
                }
                
                flAss.numberOfDcs += nullToZero(ass.Number_of_DCs__c);
                flAss.numberOfUsers += nullToZero(ass.Number_of_Users__c);
                flAss.licenseMetricQuantity += nullToZero(ass.Quantity__c) + nullToZero(ass.Number_of_Multi_Shift_Routes__c);
                
                if (ass.Product__r.Is_Perpetual__c)
                {
                    flAss.isPerpetual = true;
                }
                
                if (!flAss.IsPerpetual)//  only need to set the end term date if the aset is non perpetual
                {
                    //  the logic is thus, if the rnASs date is blank, we only want to set it if the curerent asset date is not null
                    //  if the date is set and the assest date is set, then do the date comparision
                    
                    if (flAss.termEndDate == null && ass.Term_End_Date__c != null)
                    {
                        flAss.termEndDate = ass.Term_End_Date__c;
                    }
                    else if (flAss.termEndDate != null && ass.Term_End_Date__c != null)
                    {
                        //  take the furtherst asset term end date
                        if (ass.Term_End_Date__c > flAss.termEndDate)
                        {
                            flAss.termEndDate = ass.Term_End_Date__c;
                        }
                    }
                }
            }
            /* ric is no longer a selectable asset, it comes with purchase of RN and/or MC
            if (isRic(ass))
            {
                if (ricAss == null)
                {
                    ricAss = new AssetEx(ass);
                    //  i want to do a clone here becuase we need the lookup fields from the product table
                    //ricAss = ass.Clone(false, true);
                    cloneCertainAssetFields(ricAss, ass);
                }
                
                ricAss.numberOfDcs += nullToZero(ass.Number_of_DCs__c);
                ricAss.numberOfUsers += nullToZero(ass.Number_of_Users__c);
                ricAss.licenseMetricQuantity += nullToZero(ass.Quantity__c) + nullToZero(ass.Number_of_Multi_Shift_Routes__c);
                
                if (ass.Product__r.Is_Perpetual__c)
                {
                    ricAss.isPerpetual = true;
                }
                
                if (!ricAss.IsPerpetual)//  only need to set the end term date if the aset is non perpetual
                {
                    //  the logic is thus, if the rnASs date is blank, we only want to set it if the curerent asset date is not null
                    //  if the date is set and the assest date is set, then do the date comparision
                    
                    if (ricAss.termEndDate == null && ass.Term_End_Date__c != null)
                    {
                        ricAss.termEndDate = ass.Term_End_Date__c;
                    }
                    else if (ricAss.termEndDate != null && ass.Term_End_Date__c != null)
                    {
                        //  take the furtherst asset term end date
                        if (ass.Term_End_Date__c > ricAss.termEndDate)
                        {
                            ricAss.termEndDate = ass.Term_End_Date__c;
                        }
                    }
                }
            }
            */
            if (isRpd(ass))
            {
                if (rpdAss == null)
                {
                    rpdAss = new AssetEx(ass);
                    //  i want to do a clone here becuase we need the lookup fields from the product table
                    //rpdAss = ass.Clone(false, true);
                    cloneCertainAssetFields(rpdAss, ass);
                }
                
                rpdAss.numberOfDcs += nullToZero(ass.Number_of_DCs__c);
                rpdAss.numberOfUsers += nullToZero(ass.Number_of_Users__c);
                rpdAss.licenseMetricQuantity += nullToZero(ass.Quantity__c) + nullToZero(ass.Number_of_Multi_Shift_Routes__c);
                
                if (ass.Product__r.Is_Perpetual__c)
                {
                    rpdAss.isPerpetual = true;
                }
                
                if (!rpdAss.IsPerpetual)//  only need to set the end term date if the aset is non perpetual
                {
                    //  the logic is thus, if the rnASs date is blank, we only want to set it if the curerent asset date is not null
                    //  if the date is set and the assest date is set, then do the date comparision
                    
                    if (rpdAss.termEndDate == null && ass.Term_End_Date__c != null)
                    {
                        rpdAss.termEndDate = ass.Term_End_Date__c;
                    }
                    else if (rpdAss.termEndDate != null && ass.Term_End_Date__c != null)
                    {
                        //  take the furtherst asset term end date
                        if (ass.Term_End_Date__c > rpdAss.termEndDate)
                        {
                            rpdAss.termEndDate = ass.Term_End_Date__c;
                        }
                    }
                }
            }
                
            if (isWsMapAss(ass))
            {
                if (wsMapAss == null)
                {
                    wsMapAss = new AssetEx(ass);
                    cloneCertainAssetFields(wsMapAss, ass);
                }
                
                wsMapAss.numberOfDcs += nullToZero(ass.Number_of_DCs__c);
                wsMapAss.numberOfUsers += nullToZero(ass.Number_of_Users__c);
                wsMapAss.licenseMetricQuantity += nullToZero(ass.Quantity__c) + nullToZero(ass.Number_of_Multi_Shift_Routes__c);
                
                if (ass.Product__r.Is_Perpetual__c)
                {
                    wsMapAss.isPerpetual = true;
                }
                
                if (!wsMapAss.IsPerpetual)//  only need to set the end term date if the aset is non perpetual
                {
                    //  the logic is thus, if the rnASs date is blank, we only want to set it if the curerent asset date is not null
                    //  if the date is set and the assest date is set, then do the date comparision
                    
                    if (wsMapAss.termEndDate == null && ass.Term_End_Date__c != null)
                    {
                        wsMapAss.termEndDate = ass.Term_End_Date__c;
                    }
                    else if (wsMapAss.termEndDate != null && ass.Term_End_Date__c != null)
                    {
                        //  take the furtherst asset term end date
                        if (ass.Term_End_Date__c > wsMapAss.termEndDate)
                        {
                            wsMapAss.termEndDate = ass.Term_End_Date__c;
                        }
                    }
                }
            }
            if (isWsDataIntAss(ass))
            {
                if (wsDataIntAss == null)
                {
                    wsDataIntAss = new AssetEx(ass);
                     cloneCertainAssetFields(wsDataIntAss, ass);
                }
                
                wsDataIntAss.numberOfDcs += nullToZero(ass.Number_of_DCs__c);
                wsDataIntAss.numberOfUsers += nullToZero(ass.Number_of_Users__c);
                wsDataIntAss.licenseMetricQuantity += nullToZero(ass.Quantity__c) + nullToZero(ass.Number_of_Multi_Shift_Routes__c);
                
                if (ass.Product__r.Is_Perpetual__c)
                {
                    wsDataIntAss.isPerpetual = true;
                }
                
                if (!wsDataIntAss.IsPerpetual)//  only need to set the end term date if the aset is non perpetual
                {
                    //  the logic is thus, if the rnASs date is blank, we only want to set it if the curerent asset date is not null
                    //  if the date is set and the assest date is set, then do the date comparision
                    
                    if (wsDataIntAss.termEndDate == null && ass.Term_End_Date__c != null)
                    {
                        wsDataIntAss.termEndDate = ass.Term_End_Date__c;
                    }
                    else if (wsDataIntAss.termEndDate != null && ass.Term_End_Date__c != null)
                    {
                        //  take the furtherst asset term end date
                        if (ass.Term_End_Date__c > wsDataIntAss.termEndDate)
                        {
                            wsDataIntAss.termEndDate = ass.Term_End_Date__c;
                        }
                    }
                }
            }
            if (isnetSchAss(ass))
            {
                if (netSchAss == null)
                {
                    netSchAss = new AssetEx(ass);
                     cloneCertainAssetFields(netSchAss, ass);
                }
                
                netSchAss.numberOfDcs += nullToZero(ass.Number_of_DCs__c);
                netSchAss.numberOfUsers += nullToZero(ass.Number_of_Users__c);
                netSchAss.licenseMetricQuantity += nullToZero(ass.Quantity__c) + nullToZero(ass.Number_of_Multi_Shift_Routes__c);
                
                if (ass.Product__r.Is_Perpetual__c)
                {
                    netSchAss.isPerpetual = true;
                }
                
                if (netSchAss.theAsset.Term_End_Date__c == null && ass.Term_End_Date__c != null)
                {
                    netSchAss.theAsset.Term_End_Date__c = ass.Term_End_Date__c;
                }
                else if (netSchAss.theAsset.Term_End_Date__c != null && ass.Term_End_Date__c != null)
                {
                    //  take the furtherst asset term end date
                    if (ass.Term_End_Date__c > netSchAss.theAsset.Term_End_Date__c)
                    {
                        netSchAss.theAsset.Term_End_Date__c = ass.Term_End_Date__c;
                    }
                }
            }
            if (isMerchAss(ass))
            {
                if (merchAss == null)
                {
                    merchAss = new AssetEx(ass);
                    cloneCertainAssetFields(merchAss, ass);
                }
                
                merchAss.numberOfDcs += nullToZero(ass.Number_of_DCs__c);
                merchAss.numberOfUsers += nullToZero(ass.Number_of_Users__c);
                merchAss.licenseMetricQuantity += nullToZero(ass.Quantity__c) + nullToZero(ass.Number_of_Multi_Shift_Routes__c);
                
                if (ass.Product__r.Is_Perpetual__c)
                {
                    merchAss.isPerpetual = true;
                }
                
                if (!merchAss.IsPerpetual)//  only need to set the end term date if the aset is non perpetual
                {
                    //  the logic is thus, if the rnASs date is blank, we only want to set it if the curerent asset date is not null
                    //  if the date is set and the assest date is set, then do the date comparision
                    
                    if (merchAss.termEndDate == null && ass.Term_End_Date__c != null)
                    {
                        merchAss.termEndDate = ass.Term_End_Date__c;
                    }
                    else if (merchAss.termEndDate != null && ass.Term_End_Date__c != null)
                    {
                        //  take the furtherst asset term end date
                        if (ass.Term_End_Date__c > merchAss.termEndDate)
                        {
                            merchAss.termEndDate = ass.Term_End_Date__c;
                        }
                    }
                }
            }
            if (isMcDvirAss(ass))
            {
                if (mcDvirAss == null)
                {
                    mcDvirAss = new AssetEx(ass);
                    cloneCertainAssetFields(mcDvirAss, ass);
                }
                
                mcDvirAss.numberOfDcs += nullToZero(ass.Number_of_DCs__c);
                mcDvirAss.numberOfUsers += nullToZero(ass.Number_of_Users__c);
                mcDvirAss.licenseMetricQuantity += nullToZero(ass.Quantity__c) + nullToZero(ass.Number_of_Multi_Shift_Routes__c);
                
                if (ass.Product__r.Is_Perpetual__c)
                {
                    mcDvirAss.isPerpetual = true;
                }
                
                if (!mcDvirAss.IsPerpetual)//  only need to set the end term date if the aset is non perpetual
                {
                    //  the logic is thus, if the rnASs date is blank, we only want to set it if the curerent asset date is not null
                    //  if the date is set and the assest date is set, then do the date comparision
                    
                    if (mcDvirAss.termEndDate == null && ass.Term_End_Date__c != null)
                    {
                        mcDvirAss.termEndDate = ass.Term_End_Date__c;
                    }
                    else if (mcDvirAss.termEndDate != null && ass.Term_End_Date__c != null)
                    {
                        //  take the furtherst asset term end date
                        if (ass.Term_End_Date__c > mcDvirAss.termEndDate)
                        {
                            mcDvirAss.termEndDate = ass.Term_End_Date__c;
                        }
                    }
                }
            }
            if (isRtsConnectAss(ass))
            {
                if (rtsConnectAss == null)
                {
                    rtsConnectAss = new AssetEx(ass);
                    cloneCertainAssetFields(rtsConnectAss, ass);
                }
                
                rtsConnectAss.numberOfDcs += nullToZero(ass.Number_of_DCs__c);
                rtsConnectAss.numberOfUsers += nullToZero(ass.Number_of_Users__c);
                rtsConnectAss.licenseMetricQuantity += nullToZero(ass.Quantity__c) + nullToZero(ass.Number_of_Multi_Shift_Routes__c);
                
                if (ass.Product__r.Is_Perpetual__c)
                {
                    rtsConnectAss.isPerpetual = true;
                }
                
                if (!rtsConnectAss.IsPerpetual)//  only need to set the end term date if the aset is non perpetual
                {
                    //  the logic is thus, if the rnASs date is blank, we only want to set it if the curerent asset date is not null
                    //  if the date is set and the assest date is set, then do the date comparision
                    
                    if (rtsConnectAss.termEndDate == null && ass.Term_End_Date__c != null)
                    {
                        rtsConnectAss.termEndDate = ass.Term_End_Date__c;
                    }
                    else if (rtsConnectAss.termEndDate != null && ass.Term_End_Date__c != null)
                    {
                        //  take the furtherst asset term end date
                        if (ass.Term_End_Date__c > rtsConnectAss.termEndDate)
                        {
                            rtsConnectAss.termEndDate = ass.Term_End_Date__c;
                        }
                    }
                }
            }
            if (isrnTeleAdaptAss(ass))
            {
                if (rnTeleAdaptAss == null)
                {
                    rnTeleAdaptAss = new AssetEx(ass);
                    cloneCertainAssetFields(rnTeleAdaptAss, ass);
                }
                
                rnTeleAdaptAss.numberOfDcs += nullToZero(ass.Number_of_DCs__c);
                rnTeleAdaptAss.numberOfUsers += nullToZero(ass.Number_of_Users__c);
                rnTeleAdaptAss.licenseMetricQuantity += nullToZero(ass.Quantity__c) + nullToZero(ass.Number_of_Multi_Shift_Routes__c);
                
                if (ass.Product__r.Is_Perpetual__c)
                {
                    rnTeleAdaptAss.isPerpetual = true;
                }
                
                if (!rnTeleAdaptAss.IsPerpetual)//  only need to set the end term date if the aset is non perpetual
                {
                    //  the logic is thus, if the rnASs date is blank, we only want to set it if the curerent asset date is not null
                    //  if the date is set and the assest date is set, then do the date comparision
                    
                    if (rnTeleAdaptAss.termEndDate == null && ass.Term_End_Date__c != null)
                    {
                        rnTeleAdaptAss.termEndDate = ass.Term_End_Date__c;
                    }
                    else if (rnTeleAdaptAss.termEndDate != null && ass.Term_End_Date__c != null)
                    {
                        //  take the furtherst asset term end date
                        if (ass.Term_End_Date__c > rnTeleAdaptAss.termEndDate)
                        {
                            rnTeleAdaptAss.termEndDate = ass.Term_End_Date__c;
                        }
                    }
                }
            }
            if (isrnActiveAlertAss(ass))//  BE ADVISED that this is considered product type = 'hardware' in rn sandbox so this will proably never be set
            {
                if (rnActiveAlertAss == null)
                {
                    rnActiveAlertAss = new AssetEx(ass);
                   cloneCertainAssetFields(rnActiveAlertAss, ass);
                }
                
                rnActiveAlertAss.numberOfDcs += nullToZero(ass.Number_of_DCs__c);
                rnActiveAlertAss.numberOfUsers += nullToZero(ass.Number_of_Users__c);
                rnActiveAlertAss.licenseMetricQuantity += nullToZero(ass.Quantity__c) + nullToZero(ass.Number_of_Multi_Shift_Routes__c);
                
                if (ass.Product__r.Is_Perpetual__c)
                {
                    rnActiveAlertAss.isPerpetual = true;
                }
                
               if (!rnActiveAlertAss.IsPerpetual)//  only need to set the end term date if the aset is non perpetual
                {
                    //  the logic is thus, if the rnASs date is blank, we only want to set it if the curerent asset date is not null
                    //  if the date is set and the assest date is set, then do the date comparision
                    
                    if (rnActiveAlertAss.termEndDate == null && ass.Term_End_Date__c != null)
                    {
                        rnActiveAlertAss.termEndDate = ass.Term_End_Date__c;
                    }
                    else if (rnActiveAlertAss.termEndDate != null && ass.Term_End_Date__c != null)
                    {
                        //  take the furtherst asset term end date
                        if (ass.Term_End_Date__c > rnActiveAlertAss.termEndDate)
                        {
                            rnActiveAlertAss.termEndDate = ass.Term_End_Date__c;
                        }
                    }
                }
            }
       
            if (isVoiceNavAss(ass))//  BE ADVISED that this is considered product type = 'hardware' in rn sandbox so this will proably never be set
            {
                if (voiceNavAss == null)
                {
                    voiceNavAss = new AssetEx(ass);
                   cloneCertainAssetFields(voiceNavAss, ass);
                }
                
                voiceNavAss.numberOfDcs += nullToZero(ass.Number_of_DCs__c);
                voiceNavAss.numberOfUsers += nullToZero(ass.Number_of_Users__c);
                voiceNavAss.licenseMetricQuantity += nullToZero(ass.Quantity__c) + nullToZero(ass.Number_of_Multi_Shift_Routes__c);
                
                if (ass.Product__r.Is_Perpetual__c)
                {
                    voiceNavAss.isPerpetual = true;
                }
                
               if (!voiceNavAss.IsPerpetual)//  only need to set the end term date if the aset is non perpetual
                {
                    //  the logic is thus, if the rnASs date is blank, we only want to set it if the curerent asset date is not null
                    //  if the date is set and the assest date is set, then do the date comparision
                    
                    if (voiceNavAss.termEndDate == null && ass.Term_End_Date__c != null)
                    {
                        voiceNavAss.termEndDate = ass.Term_End_Date__c;
                    }
                    else if (voiceNavAss.termEndDate != null && ass.Term_End_Date__c != null)
                    {
                        //  take the furtherst asset term end date
                        if (ass.Term_End_Date__c > voiceNavAss.termEndDate)
                        {
                            voiceNavAss.termEndDate = ass.Term_End_Date__c;
                        }
                    }
                }
            }
            
        }
        
    
    }
        
 private List<Customer_Asset__c> accountAssets  = new List<Customer_Asset__c>();
    
    private AssetEx rnAss;
    private AssetEx tpAss;
    private AssetEx mcAss;
    private AssetEx flAss;
    private AssetEx ricAss;
    private AssetEx rpdAss;
    private AssetEx wsMapAss; //  the old product for this was  netMapAss;
    private AssetEx wsDataIntAss;//  the old old product for this was netIntAss; 
    private AssetEx netSchAss;
    private AssetEx merchAss;
    private AssetEx mcDvirAss;
    private AssetEx rtsConnectAss;//  BE ADVISED THAT MIBOS ENVIROMENT DOESNT HAVE THIS PRODUCT
    private AssetEx rnTeleAdaptAss;
    private AssetEx rnActiveAlertAss;
    
    private AssetEx voiceNavAss;

    @testvisible private boolean isRn(Customer_Asset__c ass)
    {
        //  need to pass the whole ass into this because it is possible that the asset doesnt point to a product or its
        //  identifier is not set
        if (ass.Product__c == null || ass.Product__r.Product_Identifier__c == null)
        {
            return false;
        }
        else
        {
            return ass.Product__r.Product_Identifier__c == 'RN';
        }
        
    }
    @testvisible private boolean isTp(Customer_Asset__c ass)
    {
        if (ass.Product__c == null || ass.Product__r.Product_Identifier__c == null)
        {
            return false;
        }
        else
        {
            return ass.Product__r.Product_Identifier__c == 'TP';
        }
        
    }   
    @testvisible private boolean isMc(Customer_Asset__c ass)
    {
        if (ass.Product__c == null || ass.Product__r.Product_Identifier__c == null)
        {
            return false;
        }
        else
        {
            return ass.Product__r.Product_Identifier__c == 'MC';
        }
        
    }   
      @testvisible private boolean isFl(Customer_Asset__c ass)
    {
        if (ass.Product__c == null || ass.Product__r.Product_Identifier__c == null)
        {
            return false;
        }
        else
        {
            return ass.Product__r.Product_Identifier__c == 'FL';
        }
        
    }
     /*
     private boolean isRic(Asset__c ass)
    {
        if (ass.Product__c == null || ass.Product__r.Product_Identifier__c == null)
        {
            return false;
        }
        else
        {
            return ass.Product__r.Product_Identifier__c == 'RIC';
        }
        
    }  
*/  
    @testvisible private boolean isRpd(Customer_Asset__c ass)
    {
        if (ass.Product__c == null || ass.Product__r.Product_Identifier__c == null)
        {
            return false;
        }
        else
        {
            return ass.Product__r.Product_Identifier__c == 'RPD';
        }
        
    }
        @testvisible private boolean iswsMapAss(Customer_Asset__c ass)
    {
        if (ass.Product__c == null || ass.Product__r.Product_Identifier__c == null)
        {
            return false;
        }
        else
        {
            return ass.Product__r.Product_Identifier__c == 'RWS';
        }
        
    }
        @testvisible private boolean isWsDataIntAss(Customer_Asset__c ass)
    {
        if (ass.Product__c == null || ass.Product__r.Product_Identifier__c == null)
        {
            return false;
        }
        else
        {
            return ass.Product__r.Product_Identifier__c == 'TWS';
        }
        
    } 
    
    @testvisible private boolean isnetSchAss(Customer_Asset__c ass)
    {
        if (ass.Product__c == null || ass.Product__r.Product_Identifier__c == null)
        {
            return false;
        }
        else
        {
            return ass.Product__r.Product_Identifier__c == 'ATP';
        }
        
    } 
        @testvisible private boolean ismerchAss(Customer_Asset__c ass)
    {
        if (ass.Product__c == null || ass.Product__r.Product_Identifier__c == null)
        {
            return false;
        }
        else
        {
            return ass.Product__r.Product_Identifier__c == 'MERCH';
        }
        
    } 
        @testvisible private boolean ismcDvirAss(Customer_Asset__c ass)
    {
        if (ass.Product__c == null || ass.Product__r.Product_Identifier__c == null)
        {
            return false;
        }
        else
        {
            return ass.Product__r.Product_Identifier__c == 'DVIR';
        }
        
    }
        @testvisible private boolean isrtsConnectAss(Customer_Asset__c ass)
    {
        if (ass.Product__c == null || ass.Product__r.Product_Identifier__c == null)
        {
            return false;
        }
        else
        {
            return ass.Product__r.Product_Identifier__c == 'SAP';
        }
        
    }
    @testvisible private boolean isrnTeleAdaptAss(Customer_Asset__c ass)
    {
        if (ass.Product__c == null || ass.Product__r.Product_Identifier__c == null)
        {
            return false;
        }
        else
        {
            return ass.Product__r.Name == 'RN Telematics Adapter' ||
                ass.Product__r.Product_Identifier__c == 'TMX';
        }
        
    }
    @testvisible private boolean isrnActiveAlertAss(Customer_Asset__c ass)
    {
        if (ass.Product__c == null || ass.Product__r.Product_Identifier__c == null)
        {
            return false;
        }
        else
        {
            return ass.Product__r.Product_Identifier__c == 'RAA';
        }
        
    }
   
        @testvisible private boolean isVoiceNavAss(Customer_Asset__c ass)
    {
        if (ass.Product__c == null || ass.Product__r.Product_Identifier__c == null)
        {
            return false;
        }
        else
        {
            return ass.Product__r.Product_Identifier__c == 'VOICENAV';
        }
        
    } 
    @testvisible private void cloneCertainAssetFields(AssetEx obj1, Customer_Asset__c obj2)
    {
        //  so i just realized that the license type field is read only so i need to create a wrapper  that will only have the string license type
        //  there is a little bit of non cloning logic that needs to be added to this,
        //  if we find any asset with a  perpetual license type, we need to, when summing up like assets that the license type
        //  remains perpetual as this grants the customer unlimited usage of the product
        //  so when we are assigning the license type we need to check if the previous line item was not already perpetual
        
        obj1.theAsset.Product__c = obj2.Product__c;
        //obj1.theAsset.Term_End_Date__c = obj2.Term_End_Date__c;
        obj1.theAsset.Product__r = obj2.Product__r;
        //obj1.theAsset.Number_of_DCs__c = 0;
        //obj1.theAsset.Number_of_Users__c = 0;
        //obj1.theAsset.Contracted_Licenses__c = 0;
        
    }
    // Begin Private member variables
    
    // The account for which the Config Key will be generated.
    private Account account;
    
    // The current user
    private User user;

    // The text of the Config Key.    
    private string cfgKeyTxt;
    
    // Html version of the config key for displsy to the user in their browser.
    private string cfgKeyHtml;
    
    // The email address to which the config key will be sent.
    private string email = null;
    
    // Optional comment regarding the config key
    private string comment = null;
    
    // These line items represent the individual products that are
    // entered into the config key.
/*
    // These are the product names used in Salesforce.
    private string RN_SFDC_PRD_NM             = 'RN';
    private string TP_SFDC_PRD_NM             = 'TP';
    private string MC_SFDC_PRD_NM             = 'MC Server';
    private string FL_SFDC_PRD_NM             = 'FL';
    private string RIC_SFDC_PRD_NM            = 'RIC';
    private string RPD_SFDC_PRD_NM            = 'RPD';
    private string NET_MAP_SFDC_PRD_NM        = 'wsMapping';
    private string NET_INTEGRATOR_SFDC_PRD_NM = 'wsDataIntegrator';
    private string NET_SCHEDULER_SFDC_PRD_NM  = 'netScheduler';
    private string MERCH_SFDC_PRD_NM          = 'Merchandiser';
    private string RTS_CONNECT_SAP_PRD_NM     = 'RTS Connect';
    private string RN_TELEMATICS_ADAPTER_NM   = 'RN Telematics Adapter';

    // These are the text items that are written in the ORDERS section of the config key
    private string RN_ORD_05TO09    = 'RN5K (05-09)\n';
    private string RN_ORD_10TO19    = 'RN5K (10-19)\n';
    private string RN_ORD_20TO39    = 'RN5K (20-39)\n';
    private string RN_ORD_40TO49    = 'RN5K (40-49)\n';
    private string RN_ORD_50TO74    = 'RN5K (50-74)\n';
    private string RN_ORD_75PLUS    = 'RN5K (75+)\n';
    
    // Note: any TP order entry must be followed by a DP order entry.
    private string TP_ORD_05TO09    = 'TP (05-09)\nDP\n';
    private string TP_ORD_10TO19    = 'TP (10-19)\nDP\n';
    private string TP_ORD_20TO39    = 'TP (20-39)\nDP\n';
    private string TP_ORD_40TO49    = 'TP (40-49)\nDP\n';
    private string TP_ORD_50TO74    = 'TP (50-74)\nDP\n';
    private string TP_ORD_75PLUS    = 'TP (75+)\nDP\n';

    private string MC_ORD_01TO19    = 'MC (01-19)\n';
    private string MC_ORD_20TO49    = 'MC (20-49)\n';
    private string MC_ORD_50PLUS    = 'MC (50+)\n';
    
    private string FL_ORD           = 'FL\n';

    private string RIC_ORD_01TO19   = 'RIC (01-19)\n';
    private string RIC_ORD_20TO39   = 'RIC (20-39)\n';
    private string RIC_ORD_40TO99   = 'RIC (40-99)\n';
    private string RIC_ORD_100TO299 = 'RIC (100-299)\n';
    private string RIC_ORD_300TO599 = 'RIC (300-599)\n';
    private string RIC_ORD_600PLUS  = 'RIC (600+)\n';
    
    
    private string MERCH_ORD        = 'MERCH\n';
    private string MC_DVIR_ORD      = 'DVIR\n';
    
    // The following products do not need an entry in the orders section of the config key.
    // They only need an entry in the products section.
    private string RPD_ORD            = '';
    private string NET_MAP_ORD        = '';
    private string NET_INTEGRATOR_ORD = '';
    private string NET_SCHEDULER_ORD  = '';
    private string RTS_CONNECT_SAP_ORD = '';
    
    
    // These are the text items that are written in the PRODUCTS section of the config key
    
    private string RN_PRD             = 'RN5K\n';
    private string TP_PRD             = 'TP\n';
    private string MC_PRD             = 'MC\n';
    private string FL_PRD             = 'FL\n';
    private string RIC_PRD            = 'RIC\n';
    private string RPD_PRD            = 'RPD\n';
    private string NET_MAP_PRD        = 'NetMap\n';
    private string NET_INTEGRATOR_PRD = 'NetIntegrator\n';
    private string NET_SCHEDULER_PRD  = 'netScheduler\n';
    private string RTS_CONNECT_SAP_PRD = 'RTS-Connect-SAP\n'; 
    private string RNTA_PRD = 'RN Telematics Adapter\n';       
    private string RN_ACTIVE_ALERT_PRD = 'Roadnet Active Alert\n';
    
    // Merchandiser does not need an entry in the Products section of the config key.    
    private string MERCH_PRD = '';
    private string MC_DVIR_PRD = '';//  mc dvir is modeled after merch so it also does not need an entry in the PRODUCTS section
  */
    public static string overallEmergencyHelp
    {
        get
        {
            return 'For all entries below, make sure the spelling and character case are the same.  ' +
                'Items in brackets "[  ]" are variables and will need to be filled in by user if changes are needed';
            
            
        }
    }

    public static string limitsSectionDetailedHelp
    {
        get
        {
            return 'Entries underneath the Limits section contain the asset\'s product identifier followed by the asset\'s ' +
                'Term End Date.  It has syntax: [ProductIdentifier],[TermEndDate] <br />';
        }
        
    }
    public static string productsSectionDetailedHelp
    {
        get
        {
            return 'Entries undereath the Products Section contain the following syntax: <br />' + 
                '[ProductIdentifier],Users=[NumberOfUsers],Depots=[NumberOfDepots],Metric=[MetricQuantity]';
        }
    }
 
    
    // Begin testing methods.

   
    /*public static Account createTestDataSet1()
    {
        Database.SaveResult sr;
        
        // Create and insert account        
        Account acct = new Account();
        acct.Type = 'Customer';
        acct.Name = 'CWH Test Account 1';
        acct.BillingCountry = acct.ShippingCountry = 'Mexico';
        acct.billingstreet = 'Billing Street';
        acct.billingcity = 'Billing City';
        acct.billingstate = 'Billing State';
        acct.BillingPostalCode = 'Billing PostalCode';
        acct.Fleet_Size__c= 25;
        acct.Segment__c='TL';
        sr = Database.insert(acct);
        ID acctId = sr.getId();

        // Create and insert contract
        Contract ctrct = new Contract();
        ctrct.AccountId = sr.getId();
        ctrct.Status = 'Under negotiation';
        sr = Database.insert(ctrct);
        ID ctrctId = sr.getId();

        // Create and insert line items        
        List<Customer_Asset__c> assets = new List<Customer_Asset__c>();
        assets.add(createTestAsset(null, acctId, false, true));
        assets.add(createTestAsset(null, acctId, true, false));
        
        return acct;
    }

    public static Account createTestDataSet2()
    {
        Database.SaveResult sr;
        
        // Create and insert account        
        Account acct = new Account();
        acct.Type = 'Customer';
        acct.Name = 'CWH 2';
        acct.BillingCountry = acct.ShippingCountry = 'India';
        acct.billingstreet = 'Ranchview';
        acct.billingcity = 'Irving';
        acct.billingstate = 'Texas';
        acct.BillingPostalCode = '75252';
        acct.Fleet_Size__c= 25;
        acct.Segment__c='TL';
        sr = Database.insert(acct);
        ID acctId = sr.getId();
        
        // Create and insert line items        
        List<Customer_Asset__c> assets = new List<Customer_Asset__c>();
        assets.add(createTestAsset(null, acctId, false, false));

        return acct;        
    }*/
      @testvisible private static string getProductShortName(AssetEx assex)
    {
        if (assex.theAsset.Product__c != null)
        {
            if (assex.theAsset.Product__r.Product_Identifier__c != null)
            {
                return assex.theAsset.Product__r.Product_Identifier__c;
            }
            return null;
        }
        return null; 
        
    }
    @testvisible private static string getAssetDate(AssetEx theAssEx)
    {
        //  assets whose license type = 'Perpetual' never end so we need to make the date = todays date + 200 years
        if (theAssEx.isPerpetual)
        {
            return Date.Today().addYears(200).format();
        }
        //  if the assertTerm End date is null then it is considered Perpetual
        if (theAssEx.termEndDate == null)
        {
            return Date.Today().addYears(200).format();
        }
        else
        {
            return theAssEx.termEndDate.Format();
        }
    } 
   @testvisible private static integer nullToZero(decimal d)
    {
        if (d == null)
        {
            return 0;
        }
        else
        {
            return (integer)d;
        }
    }
  /* @testvisible private static Customer_Asset__c createTestAsset(string recordtypeName, id accountId, boolean isEval, boolean isPerpetual)
    {
        Customer_Asset__c testAss = new Customer_Asset__c();
        testAss.Product__c = [select id from Product2 where Product_Type__c = 'Software' and license_type__c != null and is_Perpetual__c =: isPerpetual limit 1].id;
        
        testAss.Number_Of_dcs__c = 1;
        testAss.Number_Of_Users__c = 2;
        testAss.Asset_Status__c = 'Active' ;
        testAss.Quantity__c = 3;
        testAss.Term_End_Date__c = date.Today().addDays(30);
        testAss.Account__c = accountId;
        testAss.Contract__c = [select id from contract where accountid != null limit 1].id;
        //testAss.Component_Allocation__c = 12.34;
        testAss.Eval__c = isEval;
        
        database.saveResult sr = database.insert(testAss);
        //  reading charles old code, noticed that database.insert(sobject) actually queries object for you
        return testAss;
        
    }*/
   @testvisible private Class AssetEx
    {
        public AssetEx(Customer_Asset__c ass)
        {
            theAsset = ass;
            numberOfDcs = 0;
            numberOfUsers = 0;
            licenseMetricQuantity = 0;
            isPerpetual = false;//  false by default, the consildate line item method will set this to true if any asset has the Is_Perpetual__c set
            termEndDate = ass.Term_End_Date__c;
            
             /*numberOfDcs = nullToZero(theAsset.Number_of_dcs__c);
            numberOfUsers = nullToZero(theAsset.Number_of_users__c);
            licenseMetricQuantity = nullToZero(theAsset.Contracted_Licenses__c);
            */
        }
        
        public Customer_Asset__c theAsset{get;set;}
        public decimal numberOfDcs;
        public decimal numberOfUsers;
        public decimal licenseMetricQuantity;
        public boolean isPerpetual;
        public Date termEndDate;
    }
    public class MyException extends Exception{}
}