/*******************************************************************************
 * File:  RnDeviceMassUpdater.cls
 * Date:  August 16th, 2012
 * Author:  Joseph Hutchins
 *
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *  *******************************************************************************/

public class RnDeviceMassUpdater
{
    public Account account{get;set;}
    public List<DeviceEx> devices{get;set;}
    public List<RN_Telematics_Devices__c> devicesOfAccount{get; set;}
    public boolean selectAll{get;set;}
    public Date activationDate{get;set;}
    public Date installationDate{get;set;}
    public string userSelection{get;set;}
    public string deviceSerialNumbers{get;set;}
    public string sortBySelection{get;set;}
    public string ascdescSelection{get;set;}
    
    public List<DeviceEx> foundDevices{get;set;}
    
    //public List<string> notFoundDevices{get;set;}
    
    public RN_Telematics_Devices__c tempDevice{get; set;}
    
    public RnDeviceMassUpdater(ApexPages.standardController stdCont)
    {
        //  this will live at the device for now
        RN_Telematics_Devices__c theDevice = [select Account__c from RN_Telematics_Devices__c where id =: stdCont.getId()];
        
        account = [select id, name from Account where id =: theDevice.account__c];
        
        currentPageNumber = 0;
        
        userSelection = 'Find by Contract #';
        sortBySelection = 'LastModifiedDate';
        ascDescSelection = 'desc';
        
        devices = new List<DeviceEx>();
        queryAndSetupDevices();
        
        selectAll = false;
        tempDevice = new RN_Telematics_Devices__c();        
    }
    public boolean showFindByContractLabel
    {
        get
        {
            return userSelection == 'Find by Contract #';
        }
    }
    public boolean showFindByPoLabel
    {
        get
        {
            return userSelection == 'Find by PO#';
        }
    }
    public boolean showFindBySection
    {
        get
        {
           return userSelection != 'Account';   
        }
        
    }
    
    public integer maxPerPage = 100;
    public integer beginIndex
    {
        get
        {
            
            //return 0;
            return currentPageNumber * maxPerPage;
        }
    }
    public integer endIndex
    {
        get
        {
            return beginIndex + maxPerPage;
            //return (beginIndex + maxPerPage) - 1;
        }
    }
    public integer numOfPages
    {
        get
        {
            //  what we want to do is scroll thru the tasks
            //  and count up the maxPerPage
            //  when we hit a count of maxPerPage, increment the count of pages 
            integer countOfPages = 1;
            integer count = 0;
            for (integer i = 0; i < devices.size(); i++)
            {
              count++;
              if (count > maxPerPage)
              {
                countOfPages++;
                count = 0;
              }
            }
                        
            return countOfPages;
        }
    }
    
    public integer currentPageNumber{get; set;}
    public List<selectoption> pageNumberPickList
    {
        get
        {
            LIst<selectoption> options = new List<SelectOption>();
            
            if (numOfPages == 0)//  only one page to pick from, add the value of 1
            {
                options.add(new SelectOption('0', '1'));
            }
            else//  add pages to picklist
            {
                //  Too many code statements: 200001 error email, did quick test and found out that
                //  a getter being used in a for loop ending condition calls the getter and the code in there each iteration
                //  to fix this i'm assing the value of num of pages to a integer variable in this getter
                integer tempNumOfPages = numOfPages;
                
                for (integer i = 0; i < tempNumOfPages; i++)
                {
                    SelectOption so = new selectoption(i.format(), (i+1).format());
                    options.add(so);    
                }
            }
            return options;
        }
    }
    public List<DeviceEx> deviceSubSet
    {
        get
        {
            List<DeviceEx> toReturn = new List<DeviceEx>();
            for (integer i = beginIndex; (i < (endIndex)) && (i <devices.size()); i++)
            {
                toReturn.add(devices[i]);
            }
            return toReturn;
            //for (integer i = beginIndex; (i < (endIndex + 1)) && (i < allTasksCount); i++)
            //for (integer i = 0; (i < maxPerPage && i < devices.size()); i++)
            /*util.debug('begin index = ' + beginIndex + ' endIndex ' + endIndex + 'devices.size() ' + devices.size());
            
            for (integer i = beginIndex; (i < (endIndex + 1)) && (i < devices.size()); i++)
            {
                toReturn.add(devices[i]);
            }
            return toReturn;
            */
        }
    }
    public integer deviceSerialNumberCount
    {
        get
        {
            if (deviceSerialNumbers != null)
            {
                
               list<string> devicesParsed = deviceSerialNumbers.split('\n', 0);
               return devicesParsed.size();
            }
            else
            {
                return 0;
            }
        }
    }
    /*
    private void queryFoundDevices()
    {
        if (deviceSerialNumbers != null && deviceSerialNumbers.length() > 0)
        {
            list<string> devicesParsed = deviceSerialNumbers.split('\n', 0);
            string queryString = 'select id, Serial_Number__c, Installation_Date__c, Activation_Date__c, Contract__c, Current_Status__c, ' +
               ' Product_type__c, Assoicated_HOS_Device_Id__c, Account__c from RN_Telematics_Devices__c where ';
            for (integer i = 0; i < devicesParsed.size(); i++)
            {
                if (i == 0)
                {
                    queryString += '( NAME = \'' + devicesParsed[i].trim() + '\'';
                }
                else
                {
                  queryString += ' or name = \'' + devicesParsed[i].trim() + '\'';
                }
            }
            queryString += ') order by LastModifiedDate asc limit 1000';
            
            //util.breakpoint(queryString);
            
            List<RN_Telematics_Devices__c> tempDevices = database.query(queryString);
            
            //util.BREAKPOINT('# of devices returned = ' + tempDevices.size());
            
            foundDevices = new List<DEviceEx>();
            for (RN_Telematics_Devices__c d : tempDevices)
            {
                foundDevices.add(new DeviceEx(d));
            }
            
        }
    }
    */
    
    public PageReference findDevices()
    {
        //  parse the serial numbers into a list of strings
        queryAndSetupDevices();
        
        return null; 
    }

    public PageReference assignActivationDate()
    {
        for (DeviceEx d : deviceSubSet)
        {
            if (d.shouldUpdate)
            {
                d.device.Activation_Date__c = tempDevice.Activation_Date__c;
            }
        }
        /*
        if (userSelection == 'Account')
        {
            for (DeviceEx d : devices)
            {
                if (d.shouldUpdate)
                {
                    d.device.Activation_Date__c = tempDevice.Activation_Date__c;
                }
            }
        }
        else
        {
            for (DeviceEx d : foundDevices)
            {
                if (d.shouldUpdate)
                {
                    d.device.Activation_Date__c = tempDevice.Activation_Date__c;
                }
            }
        }
        */
        return null;
    }
    
    public PageReference assignInstallationDate()
    {
        for (DeviceEx d : deviceSubSet)
            {
                if (d.shouldUpdate)
                {
                    d.device.Installation_Date__c = tempDevice.Installation_Date__c;
                }
            }
            /*
        if (userSelection == 'Account')
        {
            for (DeviceEx d : devices)
            {
                if (d.shouldUpdate)
                {
                    d.device.Installation_Date__c = tempDevice.Installation_Date__c;
                }
            }
        }
        else
        {
            for (DeviceEx d : foundDevices)
            {
                if (d.shouldUpdate)
                {
                    d.device.installation_date__c = tempDevice.Installation_Date__c;
                }
            }
        }*/
        return null;
    }
    public PageReference assignAccount()
    {
        for (DeviceEx d : deviceSubSet)
        {
            if (d.shouldUpdate)
            {
                d.device.Account__c = tempDevice.Account__c;
            }
        }
        return null;
    }
    public PageReference assignInstaller()
    {
        for (DeviceEx d : deviceSubSet)
        {
            if (d.shouldUpdate)
            {
                d.device.Installer__c = tempDevice.Installer__c;
            }
        }
        return null;
    }
    
    public PageReference assignCurrentStatus()
    {
        for (DeviceEx d : deviceSubSet)
            {
                if (d.shouldUpdate)
                {
                    d.device.Current_Status__c = tempDevice.Current_Status__c;
                }
            }
            /*
        if (userSelection == 'Account')
        {
            for (DeviceEx d : devices)
            {
                if (d.shouldUpdate)
                {
                    d.device.Current_Status__c = tempDevice.Current_Status__c;
                }
            }
        }
        else
        {
            for (DeviceEx d : foundDevices)
            {
                if (d.shouldUpdate)
                {
                    d.device.Current_Status__c = tempDevice.Current_Status__c;
                }
            }
        }*/
        
        return null;
    }    

    public PageReference selectAllOnChange()
    {
        for (DeviceEx d : deviceSubSet)
            {
                if (selectAll)
                {
                    d.shouldUpdate = true;
                }
                else
                {
                    d.shouldUpdate = false;
                }
            }
            /*
        if (userSelection == 'Account')
        {
            for (DeviceEx d : devices)
            {
                if (selectAll)
                {
                    d.shouldUpdate = true;
                }
                else
                {
                    d.shouldUpdate = false;
                }
            }
        }
        else
        {
            for (DeviceEx d : foundDevices)
            {
                if (selectAll)
                {
                    d.shouldUpdate = true;
                }
                else
                {
                    d.shouldUpdate = false;
                }
            }
        }*/
        return null;
    }
    
    public PageReference saveRecords()
    {
        List<RN_Telematics_Devices__c> devicesToUpdate = new List<RN_Telematics_Devices__c>();
        for (DeviceEx d : deviceSubSet)
            {
                if (d.shouldUpdate)
                {
                    devicesToUpdate.add(d.device);
                }
            }
            update devicesToUpdate;
            
            queryAndSetupDevices();
            /*
        if (userSelection == 'Find by SN#')
        {
            List<RN_Telematics_Devices__c> devicesToUpdate = new List<RN_Telematics_Devices__c>();
            for (DeviceEx d : foundDevices)
            {
                if (d.shouldUpdate)
                {
                    devicesToUpdate.add(d.device);
                }
            }
            update devicesToUpdate;
            queryFoundDevices();
            
        }
        if (userSelection == 'Account')
        {
            List<RN_Telematics_Devices__c> devicesToUpdate = new List<RN_Telematics_Devices__c>();
            for (DeviceEx d : devices)
            {
                if (d.shouldUpdate)
                {
                    devicesToUpdate.add(d.device);
                }
            }
            update devicesToUpdate;
            
            queryAndSetupDevices();
            
        }*/

        return null;
    }
    private integer queryLimit = 40000;
    
    private string deviceFields = 'select id, Serial_Number__c, Installation_Date__c, Activation_Date__c, Contract__c, Current_Status__c, Product_type__c,' +
                'Purchase_Order__c, Assoicated_HOS_Device_Id__c, Account__c, Installer__c, is_eval__c, is_hos__c';
    
    public void queryAndSetupDevices()
    {
        devices.clear();
        string queryString = '';
        
        if (userSelection == 'Account')
        {
            //  query the records display them, allow the fields to be editable
            queryString = deviceFields + ' from RN_Telematics_Devices__c where ' + 
                'Account__c = \'' + account.id + '\'';
                
            queryString += ' order by ' + sortBySelection + ' ' + ascDescSelection + ' NULLS LAST limit ' + queryLimit;
            util.debug('query sttring used = ' + queryString);
            
            List<RN_Telematics_Devices__c> tempDevices = database.query(queryString);
                    
            for (RN_Telematics_Devices__c d : tempDevices)
            {
                devices.add(new DeviceEx(d));
            }
        }
        else if (userSelection == 'Find By SN#' )
        {
            if (deviceSerialNumbers != null && deviceSerialNumbers.length() > 0)
            {
                list<string> devicesParsed = deviceSerialNumbers.split('\n', 0);
                queryString = deviceFields + ' from RN_Telematics_Devices__c where ';
                for (integer i = 0; i < devicesParsed.size(); i++)
                {
                    if (i == 0)
                    {
                        queryString += '( NAME = \'' + devicesParsed[i].trim() + '\'';
                    }
                    else
                    {
                      queryString += ' or NAME = \'' + devicesParsed[i].trim() + '\'';
                    }
                }
                queryString += ')';
                queryString += ' order by ' + sortBySelection + ' ' + ascDescSelection + ' NULLS LAST limit ' + queryLimit;
                util.debug('query sttring used = ' + queryString);
                
                List<RN_Telematics_Devices__c> tempDevices = database.query(queryString);
                        
                for (RN_Telematics_Devices__c d : tempDevices)
                {
                    devices.add(new DeviceEx(d));
                }
            }
        }
        else if (userSelection == 'Find By PO#')
        {
            if (deviceSerialNumbers != null && deviceSerialNumbers.length() > 0)
            {
                list<string> devicesParsed = deviceSerialNumbers.split('\n', 0);
                queryString = deviceFields + ' from RN_Telematics_Devices__c where ';
                for (integer i = 0; i < devicesParsed.size(); i++)
                {
                    if (i == 0)
                    {
                        queryString += '( Purchase_Order__c = \'' + devicesParsed[i].trim() + '\'';
                    }
                    else
                    {
                      queryString += ' or Purchase_Order__c = \'' + devicesParsed[i].trim() + '\'';
                    }
                }
                queryString += ')';
                queryString += ' order by ' + sortBySelection + ' ' + ascDescSelection + ' NULLS LAST limit ' + queryLimit;
                util.debug('query sttring used = ' + queryString);
                
                List<RN_Telematics_Devices__c> tempDevices = database.query(queryString);
                        
                for (RN_Telematics_Devices__c d : tempDevices)
                {
                    devices.add(new DeviceEx(d));
                }
            }
        }
        else if (userSelection == 'Find by Contract #')
        {
            if (deviceSerialNumbers != null && deviceSerialNumbers.length() > 0)
            {
                list<string> devicesParsed = deviceSerialNumbers.split('\n', 0);
                queryString = deviceFields + ' from RN_Telematics_Devices__c where ';
                for (integer i = 0; i < devicesParsed.size(); i++)
                {
                    if (i == 0)
                    {
                        queryString += '( Contract__r.ContractNumber = \'' + devicesParsed[i].trim() + '\'';
                    }
                    else
                    {
                      queryString += ' or Contract__r.ContractNumber = \'' + devicesParsed[i].trim() + '\'';
                    }
                }
                queryString += ')';
                queryString += ' order by ' + sortBySelection + ' ' + ascDescSelection + ' NULLS LAST limit ' + queryLimit;
                util.debug('query sttring used = ' + queryString);
                
                List<RN_Telematics_Devices__c> tempDevices = database.query(queryString);
                        
                for (RN_Telematics_Devices__c d : tempDevices)
                {
                    devices.add(new DeviceEx(d));
                }
            }
        }
    }
    public class DeviceEx
    {
        public RN_Telematics_Devices__c device{get;set;}
        public boolean shouldUpdate{get; set;}
        
        public DeviceEx(RN_Telematics_Devices__c d)
        {
           device = d;
           shouldUpdate = false;    
        }
    }
    
    public static RN_Telematics_Devices__c createTestDevice()
    {
        RN_Telematics_Devices__c device = new RN_Telematics_Devices__c();
        Contract testContract = [select id, accountid from contract limit 1];
        device.Contract__c = testContract.id;
        device.Account__c = testContract.accountId;
        
        database.saveResult sr = database.insert(device);
        if (sr.isSuccess())
        {
            device = [Select r.Vendor__c, r.Serial_Number__c, r.Purchase_Order__c, r.Product_Type__c, r.OwnerId, r.Name, r.LastModifiedDate, r.LastModifiedById, 
                r.Installation_Date__c, r.Id,  r.Defective__c, r.Current_Status__c, r.CreatedDate, r.CreatedById, r.Contract__c, 
                r.Contract_Price__c, r.Comments__c,  r.Activation_Date__c, r.Account__c, r.Assoicated_HOS_Device_Id__c, r.is_eval__c, r.is_hos__c
                From RN_Telematics_Devices__c r where id =: sr.id];
        }
        else
        {
            device = null;
        }
        return device;
    }
    
    public static ApexPages.StandardController genCont(RN_Telematics_Devices__c device)
    {
        pagereference pageRef=new pagereference('Page.BillingTransactionExtension');
        test.setcurrentpage(pageRef);
        
        return new ApexPages.standardController(device);
    }

    public class myException extends Exception{}
}