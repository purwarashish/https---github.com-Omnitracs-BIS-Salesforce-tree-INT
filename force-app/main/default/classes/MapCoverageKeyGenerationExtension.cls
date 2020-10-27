/*******************************************************************************
 * File:  MapCoverageKeyGenerationExtension.cls
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
 *   Class used to generate a Roadnet Transportation Suite Map Coverage Key from
 *   Salesforce. Used by MapCoverageKeyGenerationPage.
 *************************************************************joseph test******************/

public class MapCoverageKeyGenerationExtension
{

    // Constructor
    public mapCoverageKeyGenerationExtension(apexpages.standardController stdController)
    {
        mapSet = 
            [select 
                id, 
                Name, 
                map_vendor__r.Name, 
                Postal_Areas_Purchased__c, 
                Historical_Traffic_Data_Inrix__c,
                account__c,
                account__r.Name,
                Vendor_Map_Version_PL__c
                
             from Map_Set__c 
             where id = :stdController.getid()];
        
        user = [select Name, Email from User where Id = :UserInfo.getUserId()];

        generateCoverageKey();
    }
    
    // Accessors
    
    public string getEmail()
    {
        if (email == null)
        {
            email = user.Email;
        }
        
        return email;
    }
    
    public void setEmail(string value)
    {
        email = value;
    }

    public string getComment()
    {
        return comment;
    }
    
    public void setComment(string value)
    {
        comment = value;
    }

    public string getCoverageKeyText()
    {
        return coverageKeyText;
    }
    
    public string getCoverageKeyHtml()
    {
        return coverageKeyHtml;
    }       
    
    public string getDefaultKeyFilename()
    {
        if (defaultKeyFilename == null)
        {
            if (mapSet.Vendor_Map_Version_PL__c != null)
            {
                defaultKeyFilename = mapSet.Account__r.Name;
                defaultKeyFilename += '_' + mapSet.Vendor_Map_Version_PL__c;
                // Change non-friendly filename characters to underscores.
                defaultKeyFilename = defaultKeyFilename.ReplaceAll('(\\W|_)+', '_'); 
            }
            else
            {
                defaultKeyFilename = 'covgen';
            }
        }        
        
        return defaultKeyFilename;
    }
    
    public void setDefaultKeyFilename(string name)
    {
        defaultKeyFilename = name;
    }
    
    
    public PageReference sendEmail()
    {
        // Sends an email containing the config key as an attachment. 

        if (defaultKeyFilename == null || defaultKeyFilename.length() == 0)
        {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, 'You must supply a coverage key name.'));
            return null;
        }        

        system.debug('Sending Email');
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        string[] addresses = new string[]{email};
                
        mail.setToAddresses(addresses );
        
        mail.setSenderdisplayName('Salesforce.com');
        
        mail.setSubject('Map Coverage Ord File for '+ mapSet.Account__r.Name);
        
        String salesCoverageKeyFolder = '<\\\\lt-md-fs\\sales\\CPDATA\\Access\\MAPS\\KEYS>';
        
        String message = 
            'A Map Coverage Ord file for ' + mapSet.Account__r.Name + 
            ' is attached to this email. To create the corresponding Map Coverage Key ' + 
            'open the attached ORD file by double-clicking on the attachment.\n\n';
            
        if (comment != null && comment.length() > 0)
        {
            message += 'Comment: ' + comment + '\n\n\n';
        }

        message +=        
            'First time users please note:\n\n' + 
            'A window may be displayed saying ' + 
            '\"Windows cannot open this file...What would you like to do?\" \n' + 
            'If this happens, you will need to perform the following one-time setup: \n' + 
            '1. Click \"Select the program from a list\" and press OK. A Program Selection window will open. \n' +
            '2. Check the box that says \"Always use the selected program to open this kind of file\" and click Browse... \n' + 
            '3. In the filename entry field, enter R:\\keys\\CreateCoverageKey.bat and press Open. \n' +
            '4. Click OK on the "Open With" window to complete the setup.';
            
        mail.setPlainTextBody(message);
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        
        List<Messaging.EmailFileAttachment> listOfEFAs=new List<Messaging.EmailFileAttachment>();
        
        string filename = defaultKeyFilename + '.ord';
        efa.setFileName(filename);
        
        efa.setBody(blob.valueof(coverageKeyText));
        
        listOfEFAs.add(efa);
        
        mail.setFileAttachments(listOfEFAs);
        
        try
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            // Create and insert a new Map Coverage Key Activity record to keep 
            // track of who is creating Map Coverage Keys.
            Task t = new Task();
            
            t.whatid = mapSet.Account__c;
            t.subject = 'Map Coverage Ord file e-mailed to ' + email;
            t.status = 'Completed';
            t.License_Activity__c = 'Account Map Coverage Key Activity';
            t.License_Key_date__c = date.today();
            t.Description = 'Map Coverage Ord file e-mailed to ' + email;
            t.RecordTypeId = [select id from RecordType where sobjecttype = 'Task' and name = 'License'].id;
            database.saveresult sr = database.insert(t);
            if (sr.isSuccess())
            {
                util.debug('task created with id: ' + sr.getId());
            }
           
           
            /*Account_Map_Coverage_Key_Activity__c keyActivity = new Account_Map_Coverage_Key_Activity__c();
            keyActivity.Account__c = mapSet.Account__c;
            keyActivity.Map_Set__c = mapSet.Id;
            keyActivity.Activity_Description__c = 'Map Coverage Ord file e-mailed to ' + email;
            keyActivity.Comment__c = comment;
               
            insert keyActivity;
            */
            
        }
        catch(Exception e)
        {
            system.debug('Email sending has failed');   
        }
        
        return new PageReference('/' + mapSet.id);
    }
    
    public PageReference cancelEmail()
    {
        return new PageReference('/' + mapSet.id);
    }        
    
    
    // Begin Private methods
    
    private void generateCoverageKey()
    {
        coverageKeyText = '';
        
        coverageKeyText += '#Customer name: ' + mapSet.account__r.Name + '\n';
        coverageKeyText += '#Map Set: '       + mapSet.Name + '\n';
        coverageKeyText += '#Vendor: '        + mapSet.map_vendor__r.Name + '\n';
        coverageKeyText += '#Product: '       + mapSet.vendor_map_version_PL__c + '\n';
        coverageKeyText += '#Description: '   + '\n';
        coverageKeyText += '#Created On: '    + Datetime.now() + ' by ' + user.Name + '\n';

         
        List<Street_Area__c> streetAreas = 
            [Select 
                Map_Nation__r.ISO3__c, 
                isMapStateSpecified__c,
                Map_State__r.Name, 
                isMapCountySpecified__c,
                Map_County__r.Name,
                Map_Nation__r.Name
             From Street_Area__c 
             where Map_Set__c = :mapSet.Id 
             order by Map_Nation__r.ISO3__c, Map_State__r.Name, Map_County__r.Name];
        
        if (mapSet.Historical_Traffic_Data_Inrix__c)
        {
            // Customer purchased Historical Traffic Data
            coverageKeyText += 'H=1\n';
        }
        else
        {
            // Customer did not purchase Historical Traffic Data.
            coverageKeyText += 'H=0\n';
        }
        
        // Write out the street areas
        
        writeCoverageKeyEntries('S=', streetAreas);
        
        if (mapSet.postal_areas_purchased__c)
        {
            // Customer purchased postal areas. Write them out.
            writeCoverageKeyEntries('P=', streetAreas);
        }
        else if (doesCanadianStreetAreaExist(streetAreas) )
        {
            List<Street_Area__c> canadaOnlyStreetAreas = retrieveOnlyCanadaStreetAreasFromList(streetAreas);
            writeCoverageKeyEntries('P=', canadaOnlyStreetAreas);
        }
        
        
        // Convert the text version to an html version for display to the user
        coverageKeyHtml = coverageKeyText.replaceAll('\n', '<br/>');
    }
    
    private void writeCoverageKeyEntries(string prefix, List<Street_Area__c> streetAreas)
    {
                
        for (Street_Area__c streetArea : streetAreas)
        {
            if (streetArea.map_nation__r != null)
            {
                if (streetArea.map_state__r != null && streetArea.IsMapStateSpecified__c == true)
                {
                    if (streetArea.map_county__r != null && streetArea.IsMapCountySpecified__c == true)
                    {
                        coverageKeyText += 
                             prefix +
                             streetArea.map_nation__r.ISO3__c + '!' +
                             streetArea.map_state__r.Name + '!' + 
                             streetArea.map_county__r.Name + '\n';                    
                    }
                    else
                    {
                        coverageKeyText += 
                             prefix +
                             streetArea.map_nation__r.ISO3__c + '!' +
                             streetArea.map_state__r.Name + '\n';                    
                    }
                }
                else
                {
                    coverageKeyText += 
                         prefix +
                         streetArea.map_nation__r.ISO3__c + '\n';
                }
            }
        }
    }
        
    
    // Begin Private member variables
    
    // The map_set object for which the Coverage Key will be generated.
    private Map_Set__c mapSet;    
    
    // The current user
    private User user;

    // The text of the map coverage key.    
    private string coverageKeyText;
    
    // Html version of the config key for displsy to the user in their browser.
    private string coverageKeyHtml;
    
    // The email address to which the config key will be sent.
    private string email = null;
    
    // Optional comment regarding this coverage key.
    private string comment = null;
    
    // The default name for the coverage key determined from the account and map set.
    private string defaultKeyFilename = null;
    
    public static List<Street_Area__c> retrieveOnlyCanadaStreetAreasFromList(List<Street_Area__c> streetAreas)
    {
        List<Street_Area__c> theList = new List<Street_Area__c>();
        
        for (Street_Area__c sa : streetAreas)
        {
            if (sa.Map_Nation__r.Name == 'Canada')
            {
                theList.add(sa);
            }
        }
        
        return theList;
    }
    private static boolean doesCanadianStreetAreaExist(List<Street_Area__c> streetAreas)
    {
        system.assertNotEquals(null, streetAreas);
        for (Street_Area__c sa : streetAreas)
        {
            if (sa.Map_Nation__r.Name == 'Canada')
            {
                return true;
            }
        }
        
        return false;
    }
    public static Map_Set__c createTestData()
    {
        Database.SaveResult sr;

        Account acct;
        Map_Set__c mapSet;
        Street_Area__c streetArea;
        List<Street_Area__c> streetAreas;
        
        // Create and insert account        
        acct = new Account();
        acct.Type = 'Customer';
        acct.Name = 'CWH Test Account 1';
        acct.BillingStreet = '8945 Test Dr';
        acct.BillingPostalCode = '75062';
        acct.BillingCity = 'Dallas';
        acct.BillingState = 'TX';
        acct.billingCountry = acct.ShippingCountry = 'Mexico';
        acct.Fleet_Size__c = 35;
        acct.Segment__c = 'TL';
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true; 
        sr = Database.insert(acct, dml);
        //sr = Database.insert(acct);
        ID acctId = sr.getId();

        mapSet = new Map_Set__c();
        mapSet.Account__c = acctId;
        mapSet.Postal_Areas_Purchased__c = false;
        sr = Database.insert(mapSet);
        ID mapSetId = sr.getId();

        streetAreas = new List<Street_Area__c>();
        
        streetArea = new Street_Area__c();
        streetArea.Map_Set__c = mapSetId;
        streetArea.Map_Nation__c = [select Id from Map_Nation__c where Name = 'United States' LIMIT 1].Id;
        streetArea.IsMapStateSpecified__c = false;
        streetArea.IsMapCountySpecified__c = false;

        streetAreas.add(streetArea);
        
        Database.insert(streetAreas);
        
        return mapSet;
    }

    
}