/*******************************************************************************
 * File:  StreetAreaExtension.cls
 * Date:  March 20th, 2009
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
public class StreetAreaExtension 
{
    public Street_Area__c streetArea;
    private string returnURL;
    public boolean isVFPageInNewMode;
    private boolean displayItemInStatePickListOnlyOnce;
    private boolean displayItemInCountyPickListOnlyOnce;
    public boolean isVFPageInCloneMode = false;
    private OnChangeClass IsMapStateSpecifiedOnChangeObject;
    private OnChangeClass IsSelectingMultipleStatesOnChangeObject;
    private OnChangeClass IsMapCountySpecifiedOnChangeObject;
    private final string MAP_SET_FIELD_ID = SystemIds__c.getInstance().FieldId_StreetArea_Map_Set__c;
    
    public Id streetAreaId;
    public boolean isSelectingMultipleStates {get; set;}
    public SelectOptionManagerForStreetArea stateObject;
    public SelectOptionManagerForStreetArea countyObject;
  
    
    public StreetAreaExtension(ApexPages.standardController stdController)
    {
        stateObject = new SelectOptionManagerForStreetArea();
        countyObject = new SelectOptionManagerForStreetArea();
        
        if (stdController.getId() != null)
        {
            streetAreaId = stdController.getId();
        }
        
        isSelectingMultipleStates = false;
        //  determines if the page is in new or edit mode
        PageReference mypageref = apexpages.currentpage();
        Map<string, string> myMap = mypageref.getparameters();  
        returnURL = myMap.get('retURL');                         
        isVFPageInNewMode = determineIfVFPageIsInNewMode(myMap);
        isVFPageInCloneMode = (myMap.get('clone') == '1');
        
        
        if (!isVFPageInNewMode || isVFPageInCloneMode)//  if in edit mode, we want the item the user alerady picked added only one time
        {
            displayItemInStatePickListOnlyOnce = true;
            displayItemInCountyPickListOnlyOnce = true;
        }
        else
        {
            displayItemInStatePickListOnlyOnce = false;
            displayItemInCountyPickListOnlyOnce = false;
        }
        
        if (isVFPageInCloneMode)
        {
            initIfPageInCloneMode(); //  query the fields of the previous record and assign it to the new streetArea
        }
        else if (!isVFPageInNewMode)//  edit mode
        {
             initIfPageIsInEditMode();
        }
        else //  new mode
        {
            streetArea = new Street_Area__c();
            //  set the map set id by getting the id from the url
            streetArea.map_set__c = retrieveMapSetId;
            util.debug('streetArea.map_set__c in constructor: ' + streetArea.map_set__c);
            //util.breakpoint(streetArea.map_set__c);
        }
        
        initOnChangeObjects();
    }
 
    private Id retrieveMapSetId
    {
        get
        {
            //https://omnitracs--uat.cs2.my.salesforce.com/apex/StreetAreaPage?00NR0000001IJ7y=a6eR00000008PWWIA2&retURL=%2Fa6eR00000008PWW
            PageReference mypageref = apexpages.currentpage();
            Map<string, string> tempMap = mypageref.getparameters();
            string mapSetName = tempMap.get('CF' + MAP_SET_FIELD_ID);
            id mapSetId = tempMap.get('CF' + MAP_SET_FIELD_ID + '_lkid');
            
            //CF00NR0000001IJ7y_lkid
            //util.breakpoint('url param = ' + tempMap.get('CF' + MAP_SET_FIELD_ID + '_lkid') + ' map set = ' + mapSetId);
            return mapSetId;
        }
    }
    public Street_Area__c getStreetArea(){return streetArea;}
 
    public void setStreetArea(Street_Area__c sa){streetArea = sa;}
    
    public boolean getdisplayItemInStatePickListOnlyOnce(){ return displayItemInStatePickListOnlyOnce;}
    
    public boolean getdisplayItemInCountyPickListOnlyOnce(){ return displayItemInCountyPickListOnlyOnce;}
    
    public Boolean getIsVFPageInNewMode(){ return (isVFPageInNewMode);}
    
    public SelectOptionManagerForStreetArea getStateObject(){return stateObject;}
    
    public void setStateObject(SelectOptionManagerForStreetArea som){stateObject = som;}  
   
    public SelectOptionManagerForStreetArea getCountyObject(){return countyObject;}
    
    public void setCountyObject(SelectOptionManagerForStreetArea com){countyObject = com;}          
    
    public PageReference redirectToNewOrEditPage()
    {
        PageReference pr;
        
        if (isVFPageInNewMode)
        {
            pr = new PageReference('/apex/StreetAreaPage?retURL=' + returnURL + '&' + 'CF' + MAP_SET_FIELD_ID +'_lkid' + '=' + retrieveMapSetId );
        }
        else if (isVFPageInCloneMode)
        {
            pr = new PageReference('/apex/StreetAreaEditPage?id=' + streetAreaId + '&clone=1');
        }
        else
        {
            pr = new PageReference('/apex/StreetAreaEditPage?id=' + streetAreaId);
        }
        
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference didIsMapStateSpecifiedFieldOnChange()
    {
        //  we pass in the current value of the isMapStateSpecified field.  the method determines if the value changed,
        //  if it did, it will return true, if not it will return false.  either way, it sets the oldvalue to the new value
        //  so if the method gets called again, it'll check onchange on that time
        if (IsMapStateSpecifiedOnChangeObject.didBooleanOnChange(streetArea.isMapStateSpecified__c))
        {
            return refreshData();           
        }
        else
        {
            return null;
        }
    }
    
    public PageReference didIsSelectingMultipleStatesFieldOnChange()
    {
        if (IsSelectingMultipleStatesOnChangeObject.didBooleanOnChange(isSelectingMultipleStates))
        {
            if (isSelectingMultipleStates)
            {
                clearMapCountyFields();
            }
            return refreshData();
        }
        else
        {
            return null;
        }
    }
    
    public PageReference didIsMapCountySpecifiedFieldOnChange()
    {
        if (IsMapCountySpecifiedOnChangeObject.didBooleanOnChange(streetArea.isMapCountySpecified__c))
        {
            redefineMapCountyFields();
        }
        
        return null;
    }
        
    public List<selectOption> getNationList()
    {
        List<selectoption> options = new List<selectoption>();
        Map_nation__c defaultMapNation = [select id, name from map_nation__c where name = 'United States' limit 1 ];
        selectoption defaultSelectOption = new Selectoption(defaultMapNation.id ,defaultMapNation.name );
        
        //  we need to populate this list depending on if we are in new or edit mode
        if (isVFPageInNewMode)//  new mode, generate a list with a default on top
        {
            options.add( defaultSelectOption);
            for (Map_Nation__c nation : [select name from map_nation__c order by Name])
            {
               SelectOption so = new selectOption(nation.id, nation.name); 
               if (!isItDupeCheckValue(so.getValue(), options))
               {
                    options.add(so);
               } 
            }
        }
        else
        {
            //  assign the exisiting value on top of the list
            Map_Nation__c tempMapNation = [select id, name from Map_Nation__c where id =: streetArea.map_nation__c limit 1];
            options.add( new selectoption(tempMapNation.id, tempMapNation.name) );
            for (Map_Nation__c nation : [select name from map_nation__c order by Name])
            {
                //  generate the rest of the list BUT DONT ADD DUPES
                if (!isItDupeCheckValue(nation.id, options))
                {
                    options.add( new selectOption(nation.id, nation.name) );
                } 
            }
            
        }
        if (options.size() > 0)
        {
           return options;
        }
        else
        {
             options.clear();  
             options.add( defaultSelectOption );
             return options;
        }
    }
    
    public List<selectOption> getStateList()
    {
        List<selectoption> options = new List<selectoption>();
        //  this is how this one works.
        Id nationId;
        if(streetArea.isMapStateSpecified__c)
        {
        
            if (streetArea.Map_Nation__c != null)
            {
                nationId = streetArea.Map_Nation__c;
            }
            else
            {
              nationId = null;  
            }
            //  if this is new page then we do the below
            if ( isVFPageInNewMode )
            {
               if (nationId == null)
               {
                   //  if a nation is not specified, then we have to assign a 
                   //  default value, its going to be an empty list
                   return options;
               }    
               else
               {
                   //  if a nation is specifed, then we query the states for that nation 
                    //  query all records
                    for (Map_State__c state : 
                           [select id, name from Map_State__c where nation__c =: nationId order by name])
                    {
                         //  generate the rest of the list BUT DONT ADD DUPES
                        if (!isItDupeCheckValue(state.id, options))
                        {
                            options.add( new selectoption(state.id, state.name) );
                        }
                    }
                    //  if the query for the states return nothing, then return an empty list  
                    if (options.size()>0)
                    { 
                       return options;
                    }
                    else
                    {
                       options.clear(); 
                       return options;
                    }
               }
            }
            else
            {
               //  if this is edit, add the item to the top of the list,
               if (streetArea.map_state__c != null)
               {
                   if (displayItemInStatePickListOnlyOnce)
                   {   Map_State__c tempMapState = [select id, name 
                           from map_state__c where id =: streetArea.map_state__c limit 1];
                       options.add(new selectoption(tempMapState.id, tempMapState.name));
                   }
               }
               //  if mapnation == null (it shouldn't so belay that)
               //  query the states
               
                for (Map_State__c state : 
                       [select id, name from Map_State__c where nation__c =: nationId order by name])
                {
                    //  generate the rest of the list BUT DONT ADD DUPES
                    if (!isItDupeCheckValue(state.id, options))
                    {
                        options.add( new selectoption(state.id, state.name) );
                    }
                }
                if (options.size()>0)
                { 
                   return options;
                }
                else
                {
                   options.clear(); 
                   return options;
                }
            }
        }
        else
        {
            return new list<selectoption>();
        }
    }
    
    public List<selectOption> getCountyList()
    {
        List<selectoption> options = new List<selectoption>();
        Id stateId;
        
        if(streetArea.isMapCountySpecified__c)
        {
            if (streetArea.map_state__c != null)
            {
                stateId = streetArea.map_state__c;
            }
            else
            {
                stateId = null; 
            }
            //  this is same as state list...
            
            //  if this is new page then we do the below
            if ( isVFPageInNewMode )
            {
               if (stateId == null)
               {
                   //  if a state is not specified, then we have to assign a 
                   //  default value, its going to be an empty list
                   return options;
               }    
               else
               {
                   //  if a state is specifed, then we query the states for that state
                    //  query all records
                    for (Map_County__c county : 
                           [select id, name from Map_County__c where state__c =: stateId order by name])
                    {
                         //  generate the rest of the list BUT DONT ADD DUPES
                        if (!isItDupeCheckValue(county.id, options))
                        {
                            options.add( new selectoption(county.id, county.name) );
                        }
                    }
                    //  if the query for the county return nothing, then return an empty list  
                    if (options.size()>0)
                    { 
                       return options;
                    }
                    else
                    {
                       options.clear(); 
                       return options;
                    }
               }
            }
            else
            {
                //  if map state is null then this list has to be empty by default
               if (stateId == null)
               {
                    options.clear();
                    return options;
               }
               //  if this is edit, add the item to the top of the list,
               if (stateId!= null)
               {
                   if (displayItemInCountyPickListOnlyOnce)
                   {   Map_County__c tempMapCounty = [select id, name 
                           from map_county__c where id =: streetArea.map_county__c limit 1];
                       options.add(new selectoption(tempMapCounty.id, tempMapCounty.name));
                   }
               }
               
               //  query the states
              // Id stateId = streetArea.map_state__c; 
                //  query all records
                for (Map_County__c county : 
                       [select id, name from Map_County__c where state__c =: stateId order by name])
                {
                     //  generate the rest of the list BUT DONT ADD DUPES
                    if (!isItDupeCheckValue(county.id, options))
                    {
                        options.add( new selectoption(county.id, county.name) );
                    }
                }
                //  if the query for the county return nothing, then return an empty list  
                if (options.size()>0)
                { 
                   return options;
                }
                else
                {
                   options.clear(); 
                   return options;
                }
            }
        }
        else
        {
            return new list<selectoption>();
        }
    }
        
    public PageReference refreshData()
    {
        //  on refresh we need to flush the state and county if necessary
        //  if the state list is = 0
        displayItemInStatePickListOnlyOnce = false;
        displayItemInCountyPickListOnlyOnce = false;
        
        if (isVfPageInNewMode)
        {
            
            if (!streetArea.isMapStateSpecified__c)
            {
                streetArea.isMapCountySpecified__c = false;
                isSelectingMultipleStates = false;
                stateObject.clearAll();
                countyObject.clearAll();//  clears any of the county data
            }
            if (streetArea.map_nation__c != null)
            {
                stateObject.setNewSourceList(getStateList());   
            }
            if (streetArea.map_state__c != null)
            {
                countyObject.setNewSourceList(getCountyList());
            }
        }
        else
        {
            if (!streetArea.isMapStateSpecified__c)
            {
                streetArea.IsMapCountySpecified__c = false;
                streetArea.map_state__c = streetArea.map_county__c = null;
            }
            if (!streetArea.IsMapCountySpecified__c)
            {
                streetArea.map_county__c = null;
            }
            
        }
        return null;
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
        database.saveResult sr;
        util.debug('streetArea.map_set__c in save method: ' + streetArea.map_set__c);
        //  if the page is in new mode, we insert a new record
        if (isVFPageInNewMode)
        {
            util.debug('streetArea.map_set__c inside of isVFPageInNewMode if statement: ' + streetArea.map_set__c);
            return goThruEachCaseToTryANewSave();
        }
        else if (isVFPageInCloneMode)
        {
            system.assertEquals(null, streetArea.id);
            
            try
            {
                insert streetArea;
                return new PageReference('/' + streetArea.id); 
            }   
            catch(Exception e)
            {
                streetArea.addError('failed to save cloen of record due to ' + e.getMessage());  
            }
            
        }    
        else  //  the page is edit mode, just update the record.  crap, i jsut realized i could've used an upsert
        {
            system.assertEquals(false, isVfPageInNewMode);
            
            PageReference concurrentCheck = ConcurrentEditChecker.checkForConcurrentUpdate(streetArea);
            if (concurrentCheck != null)
            {
               return concurrentCheck;  
            }
            else
            {
                try
                {
                    update streetArea;
                    return new PageReference('/' + streetArea.id); 
                }   
                catch(Exception e)
                {
                    streetArea.addError('failed to update the record due to ' + e.getMessage());  
                }
            
            }
        }
        return null;
    }
    
    private void redefineMapCountyFields()
    {
        if (!streetArea.isMapCountySpecified__c)//  if the field is false
        {
            //  we need to clear the select list options and any value that maybe set for the map nation
            countyObject.clearAll();
            streetArea.Map_County__c = null;
        }
        else  //  if the field is true
        {
            system.assertEquals(true, streetArea.isMapStateSpecified__c);
            system.assertEquals(false, isSelectingMultipleStates);
            //  we need to populate the select options if the map state is set
            if (streetArea.map_state__c != null)
            {
                countyObject.setNewSourceList(getCountyList());
            }           
        } 
    }
        
    private void clearMapCountyFields()
    {
        streetArea.isMapCountySpecified__c = false;
        countyObject.clearAll();
    }
    
    private boolean isItDupeCheckValue(string str, selectoption[] o)
    {
        for (integer count=0; count<o.size(); count++)
        {   
            if (str==o[count].getValue())
                return true;
        }
        return false;
    }
    
    public PageReference goThruEachCaseToTryANewSave()
    {
        util.debug('streetArea.map_set__c inside of goThruEachCaseToTryANewSave(): ' + streetArea.map_set__c);
        system.assertNotEquals(null, streetArea.map_set__c);
        //  there are different ways we could save this street area
        
        
        //  i could save without pickiing a state stateSpecified = false
        if ((streetArea.IsMapStateSpecified__c == false) &&
           (streetArea.isMapCountySpecified__c == false)  &&
           (streetArea.map_county__c == null) && (streetArea.map_state__c == null))
        {
            try
            {
                database.saveResult sr = database.insert(streetArea);
                if (sr.isSuccess())
                {
                    return new PageReference('/' + sr.id);
                }   
                else
                {
                    throw new myException('failed save.');
                }
            }  
            catch(Exception e)
            {
                streetArea.addError('Failed to insert record: ' + e.getMessage());
                return null;
            } 
            
        }
        //  i could save with only pickign a single state, statespeicifed = true
        else if ((streetArea.isMapStateSpecified__c == true) && 
                   (isSelectingMultipleStates == false) &&
                   (streetArea.isMapCountySpecified__c == false))
        {
            try
            {
                
                database.saveresult sr = database.insert(streetArea);
                if (sr.isSuccess())
                {
                    return new PageReference('/' + sr.id);
                }   
                else
                {
                    throw new myException('failed to save the record due to something');
                }
            }   
            catch(Exception e)
            {
                streetArea.addError('Failed to insert record: ' + e.getMessage());
                return null;
            } 
        }
        //  i could select multiple states and save awhole bunch at one time
        else if ((streetArea.isMapStateSpecified__c == true) && (isSelectingMultipleStates == true))
        {
            //  if multiple states are selected then we need to create several street areas
            //  we send the userchoices and street area to a function which will do the saves
            {
                createMultipleStreetAreasForMultipleStateSelections(streetArea, stateObject.getSelectedItemsList());    
            }
            
            //  we redirect the user to the map set page now since we cant redirect to a particular
            //  street area
            return new PageReference('/' + streetArea.Map_Set__c);
        }
        //  i could select multiple or a single county state specif = true, county specified = true
        else if ((streetArea.isMapCountySpecified__c == true))
        {

            {
                createMultipleStreetAreasForMultipleCountySelections(streetArea, countyObject.getSelectedItemsList());
            }
            
            return new PageReference('/' + streetArea.Map_Set__c);
        }
        else
        {
            throw new myException('a save case that was not forseen has taken place.  Could not save street area.');
        }
    }
       
    public void createMultipleStreetAreasForMultipleStateSelections(Street_Area__c sa, List<selectoption> stateOptions)
    {
        Street_Area__c[] streetAreasToInsert = new list<Street_Area__c>();
        if ((sa == null)||(stateOptions == null))
        {
            throw new myException('param sent to createMultipleStreetAreas was null');
        }
        //  for each state id,
        for (SelectOption so : stateOptions)
        {
            //  we declare a new Street Area
            Street_Area__c tempStreetArea = new Street_Area__c();
            tempStreetArea.map_nation__c = sa.map_nation__c;
            tempStreetArea.map_set__c = sa.map_set__c;
            tempStreetArea.map_state__c = so.getValue();//stateId;
            tempStreetArea.IsMapStateSpecified__c = true;
            streetAreasToInsert.add(tempStreetArea);
        }
        insert streetAreasToInsert; 
        
    }
    
    private void initOnChangeObjects()
    {
        IsMapStateSpecifiedOnChangeObject = new OnChangeClass(streetArea.isMapStateSpecified__c);
        IsSelectingMultipleStatesOnChangeObject = new OnChangeClass(false);
        IsMapCountySpecifiedOnChangeObject = new OnChangeClass(streetArea.isMapCountySpecified__c);
        
    }
    
    public void initIfPageIsInEditMode()
    {
        system.assertNotEquals(null, streetAreaId);
        
        streetArea = [SELECT Id, Name, CreatedDate, CreatedById, 
                 LastModifiedDate, LastModifiedById,Map_Set__c,
                 map_nation__c, map_state__c, map_county__c, isMapStateSpecified__c, isMapCountySpecified__c from 
                 street_area__c  where id =: streetAreaId];
             
        stateObject = new SelectOptionManagerForStreetArea(getStateList());
    }
    
    public void initIfPageInCloneMode()
    {
        system.assertEquals(true, isVFPageInCloneMode);
        system.assertNotEquals(null, streetAreaId);
        //throw new myException('just testing this is called');
        
        Street_Area__c tempStreetArea = [SELECT Id, Name, CreatedDate, CreatedById, 
             LastModifiedDate, LastModifiedById, Map_Set__c,
             map_nation__c, map_state__c, map_county__c, isMapStateSpecified__c, isMapCountySpecified__c from 
             street_area__c  where id =: streetAreaId];
        
        streetArea = new Street_Area__c();//  make sure the street area is clear
        streetArea.map_set__c = tempStreetArea.map_set__c;
        streetArea.map_nation__c = tempStreetArea.map_nation__c;
        streetArea.map_state__c = tempStreetArea.map_state__c;
        streetArea.map_county__c = tempStreetArea.Map_county__c;
        streetArea.isMapCountySpecified__c = tempStreetArea.IsMapCountySpecified__c;
        streetArea.IsMapStateSpecified__c = tempStreetArea.IsMapStateSpecified__c;
        
    }
    
    public void createMultipleStreetAreasForMultipleCountySelections(Street_Area__c sa, List<selectoption> countyOptions)
    {
        system.assertNotEquals(null, sa);
        system.assertNotEquals(null, countyOptions);
        system.assertNotEquals(false, streetArea.isMapCountySpecified__c);
                        
        Street_Area__c[] streetAreasToInsert = new list<Street_Area__c>();
        
        //  for each state id,
        for (SelectOption so : countyOptions)
        {
            //  we declare a new Street Area
            Street_Area__c tempStreetArea = new Street_Area__c();
            tempStreetArea.map_nation__c = sa.map_nation__c;
            tempStreetArea.map_set__c = sa.map_set__c;
            //  we have the county but we don't have the state
            //  assign the specific state by some type of magic
            tempStreetArea.map_state__c = findMapState(so.getValue());
            tempStreetArea.map_county__c = so.getValue();
            tempStreetArea.IsMapStateSpecified__c = true;
            tempStreetArea.IsMapCountySpecified__c = true;
            streetAreasToInsert.add(tempStreetArea);
        }
        insert streetAreasToInsert; 
    }
    
    private Id findMapState(Id countyId)
    {
        return [select state__c from map_county__c where id =: countyId limit 1].state__c;
        
        //  if so, return the state__c,
        //  if not query the state and all counties, and then look for the match and return it
        /* 
        if (testMap.size() < 0)
        {
            id tempStateId;
            try
            {
                tempStateId = [select id from map_county__c where id =: countyid limit 1].id;
            }
            catch(Exception e)
            {
                throw new myException('query failed for soem odd reason.');
            }
            //  now that we have the state id, we query ALL counties of that state
            list<Id> tempCountyListOfIds = new list<id>();
            try
            {
                Map_County__c[] tempMapCounties = [select id from map_county__c where state__c =: tempStateId];
                for (Map_County__c mc : tempMapCounties)
                {
                    tempCountyListofIds.add(mc.id);
                }
            }
            catch(Exception e)
            {
                throw new myException('query failed due to ' + e.getMessage());
            }
            //  now we add a mapping to the map list
            testMap.put(tempStateId, tempCountyListofIds);
       throw new myException('functino not finished yet');
        }
       //  we now go thru
       
        //  so this is what im thinking with this function
        //  the first time this runs, we query the state the county is assoicated with
        //  we then query all of the counties assoiacted with that state,
        //  and add them to a list
        //  when this function runs another time, we FIRST check if the county id
        //  is in the already queried list, if so we return the state,
        //  else we query the state and return then we keep going from there.
        */
    }
    public class OnChangeClass
    {
        private boolean boolOldValue;
        private boolean boolNewValue;
        
        public OnChangeClass()
        {
            boolOldValue = boolNewValue;
        }
        public OnChangeClass(boolean valueToSet)
        {
            boolOldValue = boolNewValue = valueToset;
        }
        public void setNewValue(boolean valueToSet)
        {
            system.assertNotEquals(null, valueToSet);
            
            boolNewValue = valueToSet;
        }
        
        public boolean didBooleanOnChange(boolean valueToCheckAgaisnt)
        {
            system.assertNotEquals(null, valueToCheckAgaisnt);
            
            boolNewValue = valueToCheckAgaisnt;
            
            if (boolNewValue != boolOldValue)
            {
                boolOldValue = boolNewValue;
                return true;
            }
            else
            {
              return false; 
            }
        }
    }
    public static Map_State__c createTestMapState()
    {
        Map_State__c mapState = new map_State__c();
        database.saveresult sr = database.insert(mapState);
        if (sr.isSuccess())
        {
            mapState = [select id, name from map_State__c where id =: sr.id limit 1];
        }
        
        return mapState;
    }
    
    public static Map_county__c createTestMapCounty()
    {
        Map_county__c mapcounty = new map_county__c();
        database.saveresult sr = database.insert(mapcounty);
        if (sr.isSuccess())
        {
            mapcounty = [select id, name from map_county__c where id =: sr.id limit 1];
        }
        
        return mapcounty;
    }
    
    public static Map_Nation__c createTestMapNation()
    {
        Map_nation__c mapnation = new map_nation__c();
        database.saveresult sr = database.insert(mapnation);
        if (sr.isSuccess())
        {
            mapnation = [select id, name from map_nation__c where id =: sr.id limit 1];
        }
        
        return mapnation;
    }
    
    public static Street_Area__c createTestStreetArea()
    {
        Street_Area__c streetArea = new Street_Area__c();
        database.saveresult sr = database.insert(streetArea);
        if (sr.isSuccess())
        {
            streetArea = [select id, map_nation__c, map_state__c, map_county__c, 
                isMapStateSpecified__c, isMapCountySpecified__c, map_set__c
                 from Street_Area__c where id =: sr.id limit 1];
        }
        
        return streetArea;
    }
    
    public static ApexPages.StandardController generateController(Street_Area__c sa)
    {
        pagereference pageRef=new pagereference('Page.StreetAreaPage');
        test.setcurrentpage(pageRef);
        string mapSetFieldId = SystemIds__c.getInstance().FieldId_StreetArea_Map_Set__c;
        
        if (sa.id == null)//  assume its a new entry
        {
            ApexPages.currentPage().getParameters().put('CF' + mapSetFieldId + '_lkid', [select id from Map_Set__c limit 1].id);
        }
        //declare apexpages.standardcontroller so that we can pass it into this class's constructor
        return new ApexPages.standardController(sa);
    }
    public static Street_Area__c createTestStreetArea(string recordtypeid)
    {
        Street_Area__c sa = new Street_Area__c();
        sa.Map_Set__c = [select id from Map_Set__c limit 1].id;
                                 
        database.saveResult saveresult = database.insert(sa);
        if (saveresult.isSuccess())
        {
            sa = [Select s.OwnerId, s.Name, s.Map_State__c, s.Map_Set__c, s.Map_Nation__c, 
            s.Map_County__c, s.LastModifiedDate, s.LastModifiedById, s.IsMapStateSpecified__c, s.IsMapCountySpecified__c, 
            s.Id, s.CreatedDate, s.CreatedById,
            s.Clientele_MapItem_Id__c From Street_Area__c s where id =: saveresult.id];
        }
        
        return sa;
        
    }
   
    public class myException extends Exception{}
    
    //  ***********************  TEST METHODS ******************************
   

}