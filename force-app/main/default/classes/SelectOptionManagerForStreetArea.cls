/*******************************************************************************
 * File:  SelectOptionManagerForStreetArea.cls
 * Date:  April 12, 2009
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
public class SelectOptionManagerForStreetArea
{
    //  *****  class members  ******
    private list<string> userSelectedItemsToAdd;
    private list<string> userSelectedItemsToRemove;
    private list<string> itemsToSave;
    private list<selectoption> sourceList;
    private list<selectoption> selectedItemsList;
    private string savedItemsAsASingleString;
    
    //  *****  getters and setters   ******
    public list<selectoption> getSourceList()
    {
        return sourceList;
    }

    public list<selectoption> getSelectedItemsList()
    {
        return selectedItemsList;
    }
    
    public string getTheFinalProduct()
    {
        return turnListOfSelectOptionsToSingleString(selectedItemsList);
    }
    
    public void setUserSelectedItemsToAdd(list<string> strings)
    {
        userSelectedItemsToAdd = strings;
    }
    
    public void setNewSourceList(List<selectoption> options)
    {
        userSelectedItemsToRemove.clear();
        userSelectedItemsToAdd.clear();
        if (options != null)
        {
            sourceList = options;
        }
        else
        {
            throw new myException('cannot set a new source list with a null param');
        }
        
    }
    
    public void clearAll()
    {
        
        userSelectedItemsToAdd.clear();// = new List<string>();
        userSelectedItemsToRemove.clear();// = new List<string>();
        sourceList.clear();// = new List<selectoption>();
        selectedItemsList.clear();// = new List<selectoption>();
    
    }
    
    public list<string> getUserSelectedItemsToAdd(){return userSelectedItemsToAdd;}
    
    public list<string> getuserSelectedItemsToRemove(){return userSelectedItemsToRemove;}
        
    
    public void setUserSelectedItemsToRemove(List<string> strings)
    {
        userSelectedItemsToRemove = strings;
    }
   
    //  ******  public methods  *****
    public void addItemsToList()
    {
        //  we see if the user has any items selected,
        if (userSelectedItemsToAdd != null)
        {
            //  if so
            //  for each one we add them to the selectedItem list
            for (string singleStringFromList : userSelectedItemsToAdd)
            {
                //  assign the [nth] element in the list to a string
                //  check if this [nth] element is already in the other list,
                if (!isItDupe(singleStringFromList, selectedItemsList))
                {
                    //  if not, add it to the list
                    selectedItemsList.add(new selectoption(singleStringFromList,
                     findLabelByUsingSpecifiedValueInSelectOptionList(singleStringFromList)));
                }
                
            }
            //  sort both lists again
            sortListOfSelectOptionsByTheLabelName(sourceList);
            sortListOfSelectOptionsByTheLabelName(selectedItemsList);
        }
    }
    
    public void removeItemsFromList()
    {
        //  we see if the user has any of the items selected
        //  if so
        //  for each one, we remove them from this list
        //  and add it to the previous list
        //  BUT WE DONT ADD ANY DUPES
        //  what happens if we try to remove an item from this list that wasn't in the original list?
        //  nothing, it takes to much effort to do that
        //  we see if the user has any items selected,
        if (userSelectedItemsToRemove != null)
        {
            //  if so
            //  for each one we add them to the selectedItem list
            for (string singleStringFromList : userSelectedItemsToRemove)
            {
                removeItemFromSelectOptionList(singleStringFromList, selectedItemsList);
            }
            //  CLEAR THE userselectedlist afterwards.
            userSelectedItemsToRemove.clear();
            //  sort both lists again
            sortListOfSelectOptionsByTheLabelName(sourceList);
            sortListOfSelectOptionsByTheLabelName(selectedItemsList);
        }
    }
    
    public void cancelSelections()
    {
        userSelectedItemsToAdd.clear();
        userSelectedItemsToRemove.clear();
    }
    
    //  *****  private methods  *****
    private string findLabelByUsingSpecifiedValueInSelectOptionList(string theValue)
    {
        for (SelectOption so : sourceList )
        {
            if (so.getValue() == theValue)
            {
                return so.getLabel();
            }
        }
        return null;
    }
    
    private string[] parseString(string str)
    {
        //this function takes a string as argumetns and returns a list of strings.  it splits strings up by a semicolon.  for example, if the string passed in
        //was "this; is; a; string;"  then it would return 1-this 2-is 3-a 4-string
        string[] theStrings=new list<string>();
        if (str==null){}
        else
        {   
            theStrings=(str.split(';', 0));
            //lets make sure there isn't blank items in the list and try to clear in any leading trailign whitespaces
            for (integer i=0; i<theStrings.size();i++)
            {
                theStrings[i]=theStrings[i].trim();
                if (theStrings[i]=='') theStrings.remove(i);
            }
        }

        return theStrings;
    }
    
    private List<selectoption> parseSingleStringToSelectOptionList(string str)
    {
        List<selectoption> options = new list<selectoption>();
        list<string> strings = parseString(str);
        if (strings != null)
        {
            for (string theString : strings)
            {
                options.add(new selectoption(theString, theString));
            }
        }
        
        return options;
    }
    
    private list<selectoption> sortListOfSelectOptionsByTheLabelName(List<selectOption> options)
    {
        if (options == null)
        {
            return null;
        }
        Selectoption temp;
        
        for (integer j=0; j<(options.size()-1); j++)
        for (integer i=0; i<(options.size()-1); i++)
        {
            if (options[i+1].getLabel() < options[i].getLabel())
            {
                temp = options[i + 1];
                options[i + 1] = options[i];
                options[i] = temp;
            }
        }
        return options;
    /*
     public Attachment[] sortAttachmentsByDate(Attachment[] a)
    {
        Attachment temp=new Attachment();
        //assume the first element is the highest in the list
        
        for (integer j=0; j<(a.size()-1); j++)
        for (integer i=0; i<(a.size()-1); i++)
        {
            //is the second element in the list bigger than the first element
            if (a[i+1].createdDate>a[i].createdDate)
            {
                temp=a[i+1];
                a[i+1]=a[i];
                a[i]=temp;  
            }
        }
        return a;       
    }
    */
    }
    
    private string turnListOfSelectOptionsToSingleString(List<selectoption> strs)
    {
        //this function takes a list of strings and returns them as a single string with proper formatting
        
        if (strs==null) throw new myException('Strings passsed into argument are null');
        // if (strs.size()==0) throw new myException('No items in string list');
        //we create a tempstring, we use it for the assignemnt of the products
        string tempstring='';
        //add the products to the upslt_product__c field one by one
        for (integer i=0; i<strs.size(); i++)
        {
            //the equalviancey check later on in the function was failign due to each strs being added with a ; and whitespace, so i changed this so that last 
            //item assigned did not append the whitespace
            if (i != (strs.size() - 1))         
            tempstring += strs[i].getValue() + '; ';//the semicolon will be used as seperator for the parser function in another part of this class
            else tempstring += strs[i].getValue() + ';';
        }
        return tempstring;
    }
    
    private void removeItemFromSelectOptionList(string theItem, List<selectoption> options)
    {
        for (integer i = 0; i < options.size(); i++)
        {
            if (theItem == options[i].getValue())
            {
                options.remove(i);
            }
        }
    }
    
    public boolean isitDupe(string str, selectoption[] o)
    {
        for (integer count=0; count<o.size(); count++)
        {   
            if (str==o[count].getvalue())
                return true;
        }
        return false;
    }
    
    //  *****  constructors  ******
    public SelectOptionManagerForStreetArea(List<selectoption> selectOptionList)
    {
        if (selectOptionList == null)
        {
            throw new myException('Can not create this object with a null list of selectoptinos');
        }
        userSelectedItemsToAdd = new List<string>();
        userSelectedItemsToRemove = new List<string>();
        itemsToSave = new List<string>();
        sourceList = new List<selectoption>();
        selectedItemsList = new List<selectoption>();
        
        //  the original list of items is assigned to whats passed into the constructor.
        sourceList = sortListOfSelectOptionsByTheLabelName(selectOptionList);
        
    }
    
    public SelectOptionManagerForStreetArea(List<selectoption> selectoptionList, string alreadySelectedItemsFromPreviousRecord)
    {
        if (selectOptionList == null)
        {
            throw new myException('Can not create this object with a null list of selectoptinos');
        }
        userSelectedItemsToAdd = new List<string>();
        userSelectedItemsToRemove = new List<string>();
        itemsToSave = new List<string>();
        sourceList = new List<selectoption>();
        selectedItemsList = new List<selectoption>();
        
        //  the original list of items is assigned to whats passed into the constructor.
        sourceList = sortListOfSelectOptionsByTheLabelName(selectOptionList);
        //  try to parse the already selected items to a list of selectoptions
        if (alreadySelectedItemsFromPreviousRecord != null)
        {
            list<selectoption> tempListOfSelectoptions = parseSingleStringToSelectOptionList(alreadySelectedItemsFromPreviousRecord);
            //  if it worked, assign it to the selecteditems list
            selectedItemsList = sortListOfSelectOptionsByTheLabelName(tempListOfSelectoptions);
        }
    }   
    
    public SelectOptionManagerForStreetArea()
    {
        userSelectedItemsToAdd = new List<string>();
        userSelectedItemsToRemove = new List<string>();
        itemsToSave = new List<string>();
        sourceList = new List<selectoption>();
        selectedItemsList = new List<selectoption>();
    
    }
   
    public class myException extends Exception{}
    
    //  ***** TEST METHODS *****

    
}