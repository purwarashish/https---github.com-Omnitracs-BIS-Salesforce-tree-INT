/*******************************************************************************
 * File:  MapSetExtension.cls
 * Date:  March 6th, 2009
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
public class MapSetExtension
{
    private Map_Set__c mapSet;
    private boolean isClone = false;
    public boolean isVFPageInNewMode{get; set;}
    private Map_Set__c tempMapSetForClone;
    
    public MapSetExtension(ApexPages.standardController stdController)
    {
        //  determines if the page is in new or edit mode
        PageReference mypageref = apexpages.currentpage();
        Map<string, string> myMap = mypageref.getparameters();                           
        isVFPageInNewMode = determineIfVFPageIsInNewMode(myMap);
        isClone = determineIfVFPageIsInCloneMode(myMap);
        
        final string ACCOUNT_ID_IN_URL_FOR_THE_LIVE_ENVIRONMENT = 'CF00N30000003CpH3_lkid';
         
        if (isClone)
        {
            initMapSetForClone(stdController.getId());
            
        }      
        else if (!isVFPageInNewMode)
        {
            mapSet = [SELECT Id, OwnerId, Name, CreatedDate, CreatedById,
                               LastModifiedDate, LastModifiedById, 
                               vendor_map_version_pl__c, 
                               Account__c, Clientele_Mapset_Id__c, Comments__c,map_vendor__c,
                               postal_areas_purchased__c, Product_Type__c,
                               Historical_Traffic_Data_Inrix__c, Number_of_Licensed_Vehicles__c,
                               Date_Purchased__c, End_Date__c from 
                               Map_Set__c where
                               id =: stdController.getId()];
        }
        else
        {
            mapSet = new Map_Set__c();
            mapSet.account__c = myMap.get(ACCOUNT_ID_IN_URL_FOR_THE_LIVE_ENVIRONMENT); 
        }
    }
   
    public Map_Set__c getmapSet(){return mapSet;}
    
    public void setmapSet(Map_Set__c og){mapSet = og;}
    
    public List<selectoption> getMapVendorAccountList()
    {
        List<selectoption> options = new list <selectoption>();
        
        Account[] accounts = [select id, name from account where map_vendor__c = true order by name];
        for (Account a : accounts)
        {
            options.add(new selectoption(a.id,a.name));
        }
        
        return options;
    }
    /*
    public list<selectoption> getVendorMapVersionList()
    {
        List<selectoption> options = new list <selectoption>();
        Vendor_Map_Version__c[] theList = [select id, name from vendor_Map_version__c order by name];
        
        for (Vendor_Map_Version__c vmv : theList)
        {
            options.add(new selectoption(vmv.id,vmv.name));
        }
        return options;
    }
    */
    public boolean determineIfVFPageIsInCloneMode(Map<string,string> myMap)
    {
        if (myMap.get('clone') == '1')
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    public boolean determineIfVFPageIsInNewMode(Map<string,string> myMap)
    {
        //  its an edit page
        if (myMap.get('id') != null)
        {
                return false;
        }   
        else  //  its a new page
        {
            return true;    
        }
    }
    
    public PageReference save()
    {
        database.saveResult sr = null;
        
        //  if the page is in new mode, we insert a new record
        if (isClone)
        {
            sr = performSaveOfClone(tempMapSetForClone.id);
            if (sr.isSuccess())
            {
                return new PageReference('/' + sr.id);
            }
            else
            {
                mapSet.addError('failed to save the record due to unexpected error');
            }
        }
        else if (isVFPageInNewMode)
        {
            try
            {
                sr = database.insert(mapSet);
                if (sr.isSuccess())
                {
                    return new PageReference('/' + sr.id);
                }   
                else
                {
                    mapSet.addError('failed to save the record due to unexpected error');
                }
            }   
            catch(Exception e)
            {
                mapSet.addError('failed to save the record due to ' + e.getMessage());    
            }
        }   
        else  //  the page is edit mode, just update the record.  
        {
            PageReference concurrentCheck = ConcurrentEditChecker.checkForConcurrentUpdate(mapSet);
            if (concurrentCheck != null)
            {
               return concurrentCheck;  
            }
            else
            {           
                try
                {
                    update mapSet;
                    return new PageReference('/' + mapSet.id); 
                }   
                catch(Exception e)
                {
                    mapSet.addError('failed to update the record due to ' + e.getMessage());  
                }
            }
        }
        return null;
    }
    
    public void initMapSetForClone(id mapSetId)
    {    
        tempMapSetForClone = queryMapSet(mapSetId);
        mapSet = new Map_Set__c();
        mapSet.account__c = tempMapSetForClone.account__c;
        mapSet.Clientele_Mapset_Id__c = tempMapSetForClone.Clientele_Mapset_Id__c;
        mapSet.postal_Areas_Purchased__c = tempMapSetForClone.postal_areas_Purchased__c;
        mapSet.Historical_Traffic_Data_Inrix__c = tempMapSetForClone.Historical_Traffic_Data_Inrix__c;
        mapSet.vendor_map_version_pl__c = tempMapSetForClone.vendor_map_version_PL__c;
        mapset.Date_Purchased__c = tempMapSetForClone.Date_Purchased__c;
        mapSet.comments__c = tempMapSetForClone.comments__c;
        mapSet.Map_Vendor__c = tempMapSetForClone.Map_Vendor__c;
        
    }
    
    public DataBase.saveResult  performSaveOfClone(Id idOfMapSetBeingCloned)
    {
        Street_Area__c[] streetAreas = new List<Street_Area__c>();
        Street_Area__c[] streetAreasToAttachToNewlyClonedMapSet = new List<Street_Area__c>();
        
        //  first and foremost we need to have a back up plan incase anything below fails, we need to delete the cloned map set
        Database.SaveResult sr = database.insert(mapSet);
        
        if (sr.isSuccess())
        {
            //  so we save the map set first, then try everything below, if it doens't work at any tiem we need to delete the mapset
            try
            {
                //  we query the streetareas of the previous mapset
                streetAreas = [SELECT Id, OwnerId, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                  Map_Set__c, Clientele_MapItem_Id__c, 
                  Map_Nation__c, Map_State__c, Map_County__c, IsMapStateSpecified__c, IsMapCountySpecified__c 
                  from street_area__c where map_set__c =: idOfMapSetBeingCloned];
                
                //  then for each street area, we create a new street area, and copy the infomration to the new street area
                for (Street_Area__c sa : streetAreas)
                {
                    Street_Area__c tempStreetArea = copyFieldInformationToNewStreetArea(sa, sr.id);
                    if (tempStreetArea != null)
                    {
                        streetAreasToAttachToNewlyClonedMapSet.add(tempStreetArea);
                    }
                }
                //  now that the street areas are populated with the field information we insert them into the database
                insert streetAreasToAttachToNewlyClonedMapSet;
                return sr;
            }
            catch(Exception e)
            {
                database.delete(sr.id);
                throw new myException('Problem occured during cloning map set. Error mesage provided was ' + e.getMessage());
            }   
        }
        else
        {
            throw new myException('failed to save map set due to ' + sr.getErrors()[0]);
        }
            
    }
    
    public static Street_Area__c copyFieldInformationToNewStreetArea(Street_Area__c streetAreaThatIsGettingInformationCopiedFrom, Id mapSetId)
    {
        Street_Area__c streetArea = new Street_Area__c();
        streetArea.map_set__c = mapSetId;
        streetArea.Clientele_MapItem_Id__c = streetAreaThatIsGettingInformationCopiedFrom.Clientele_MapItem_Id__c;
        streetArea.IsMapCountySpecified__c = streetAreaThatIsGettingInformationCopiedFrom.IsMapCountySpecified__c;
        streetArea.IsMapStateSpecified__c = streetAreaThatIsGettingInformationCopiedFrom.IsMapStateSpecified__c;
        streetArea.map_nation__c = streetAreaThatIsGettingInformationCopiedFrom.map_nation__c;
        streetArea.map_state__c = streetAreaThatIsGettingInformationCopiedFrom.map_state__c;
        streetArea.map_county__c = streetAreaThatIsGettingInformationCopiedFrom.map_county__c;
        return streetArea;
    }
    
    public static Map_Set__c queryMapSet(string mapSetId)
    {
        if (mapSetId != null)
        {
            return [SELECT Id, OwnerId, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
              Vendor_Map_Version_pl__c,
              Account__c, Clientele_Mapset_Id__c,
              Number_of_Licensed_Vehicles__c, 
              Comments__c, Date_Purchased__c, Postal_Areas_Purchased__c, Historical_Traffic_Data_Inrix__c, Map_Vendor__c from map_set__c where id =: mapSetId];
        }
        else
        {
            return null;
        }
    }
    public static ApexPages.StandardController generateController(Map_Set__c og)
    {
        pagereference pageRef=new pagereference('Page.OrderFileGenerationPage');
        test.setcurrentpage(pageRef);
        //declare apexpages.standardcontroller so that we can pass it into this class's constructor
        return new ApexPages.standardController(og);
    }
    public static ApexPages.StandardController generateControllerWithCloneArgument(Map_Set__c og, Boolean isCloneSpecified)
    {
        pagereference pageRef=new pagereference('Page.OrderFileGenerationPage');
        if (isCloneSpecified)
        {
            ApexPages.currentPage().getParameters().put('clone', '1');
        }
        
        
        test.setcurrentpage(pageRef);
        //declare apexpages.standardcontroller so that we can pass it into this class's constructor
        return new ApexPages.standardController(og);
    }
    
    public static Map_Set__c CreateTestMapSet(string recordtype)
    {
        Map_Set__c mp = new Map_Set__c();
        mp.Account__c = [select id from Account limit 1].id;
        mp.Postal_Areas_Purchased__c = true;
        mp.Vendor_Map_Version_PL__c = ' Analytics Peru';
        mp.Historical_Traffic_Data_Inrix__c = true;
        mp.Map_Vendor__c = [select id, name from account where map_vendor__c = true limit 1].id;
        mp.date_Purchased__c = Date.Today();
        mp.comments__c = 'testComments';
        
        database.saveResult sr = database.insert(mp);
        if (sr.isSuccess())
        {
            mp = [Select 
                m.Vendor_Map_Version_PL__c, 
                m.Postal_Areas_Purchased__c, m.OwnerId, m.Name, m.Map_Vendor__c, 
                m.LastModifiedDate, m.LastModifiedById,m.Id, m.Historical_Traffic_Data_Inrix__c, m.Date_Purchased__c, 
                m.CreatedDate, m.CreatedById, m.Comments__c, m.Number_of_Licensed_Vehicles__c, 
                m.Clientele_Mapset_Id__c, m.Account__c From Map_Set__c m where id =: sr.id];
        }
        else
        {
            mp = null;
        }
        return mp;
    }

    public class myException extends Exception{}
    
    
}