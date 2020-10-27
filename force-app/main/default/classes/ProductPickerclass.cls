/*******************************************************************************
 * File:  ProductPickerclass.cls
 * Date:  Janurary 12th, 2009
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
public class ProductPickerclass 
{
    /*productPickerClass constructor.  it takes a string as an argument.  this string should bein the formal of 'product1; product2; product3'
    it uses this string to prepopulate the selectedproduct list*/
    public string theMostImportantStringEvar;//this will hold the all of the products name
    public productPickerClass(string str)
    {
        //if (str==null) throw new myException('str passed into constructor was null');
        theMostImportantStringEvar=str;
        //try to initlize class data
                    
        try
        {
            initData(theMostImportantStringEvar);//pass the string into intilizae function
        }
        catch(Exception e)
        {
            throw new myException(e.getmessage());
        }
        
    }

    //public string contractid;
    public list<selectoption> products;//this list will contain the products
    public list<selectoption> filterOptions;//this list holds the options you could filter the products by--such as "all" "software" "hardware"
    public list<selectoption> getfilterOptions(){return filterOptions;}
    public list<selectoption> getProducts(){return products;}
    public list<selectoption> selectedProductsList;//this list will hold the products the user has seleceted to add to the contract
    public list<selectoption> getselectedProductsList(){return selectedProductsList;}
    //public string[] userChoiceProduct{get;set;}//contains the choices selection for products to add
    public string[] userchoiceproduct;
    public string[] getuserChoiceProduct()
    {
        return userchoiceproduct;   
    }
    public void setuserChoiceProduct(string[] strs)
    {
        system.debug('*************************************************************************setter function called');
        userchoiceproduct=strs; 
    }
    public string[] selectedProducts{get;set;}//keeps track of the products teh user wants to remove from the list
    public string productListFilter{get;set;}//keeps track of filter the user selected
    public integer AddOrRemoveSelector;//this variable is managed by a function--at this time, if its = 2 then the function will add products.  
    //if = 3 then it will remove the selected products..  if = 1 or 2 then nothing happens, those two values are reserved for future changes if needed.
    public string getAddOrRemoveSelector(){ return string.valueof(addorRemoveSelector); }
    private void initData(string theString)
    {
        /*initlizer function.  this should only run once and only be called by constructor. first, declares the variables of the class properly,
        then sets the filter to=All by default.  then it attempts to set the product list using the default filter setting (which should be null).
        it then inits the filter options,, and finally the selected products list, which is 
        d later in this class.*/
            filterOptions=new list<selectoption>();
            products=new list<selectoption>();
            userchoiceproduct=new list<string>();
            selectedproducts=new list<string>();
            selectedProductsList=new list<selectoption>();
            productListFilter='Software';
            AddOrRemoveSelector=1;
            
            //attempt to init product listing
            defineProducts(products,productListFilter);
            
            
            //attempt to init filter options
            defineFilterOptions(filterOptions);
            
            
            //attempt to init SelectedProducts List
            initselectedProductsList(selectedProductsList, theString);
            
            
        }

    public void defineFilterOptions(selectoption[] theList)
    {
        if (theList==null)
        {
            throw new myException('param passed in is null');
        }
        //clear the list
        theList.clear();
        
        theList.add(new selectoption('All','All'));
        theList.add(new selectoption('Software','Software'));
        theList.add(new selectoption('Roadnet University','Roadnet University'));
        theList.add(new selectoption('Hardware','Hardware'));
        theList.add(new selectoption('Maps','Maps'));
        theList.add(new selectoption('Special Projects','Special Projects'));
        theList.add(new selectoption('Subscription','Subscription'));
        theList.add(new selectoption('Other','Other'));
        system.assertEquals(theList.size(), 8);
        
    }
    public void defineProducts(selectoption[] theList, string theFilter)
    {
                 
        if (theFilter.contains('All')||theFilter.contains('Software')||theFilter.contains('Roadnet University')||
        theFilter.contains('Hardware')||theFilter.contains('Professional Service')||theFilter.contains('Maps')||
        theFilter.contains('Special Projects')||theFilter.contains('Subscription')||theFilter.contains('Other'))
        {
            //do nothing thefilter equals to a product_type__c we have in the system
        }
        else
        {
            throw new myException('The product type sent to defineProducts function  does not exsit in the system');
        }
        if (theList==null)
        {
            throw new myException('The product List was not initlized properly');
        }
        //clear the list
        theList.clear();
        
        //try to query the software products according to the fileter
        Product2[] tempProducts=new list<product2>();
        try 
        {
            if (theFilter.contains('All'))
                tempproducts=[select name from product2 where IsActive = true order by name];
            else
                tempProducts=[select name from product2 where product_type__c=:theFilter AND IsActive = true order by name];
        }
        catch(Exception e1)
        {
            throw new myException('Soql query failed due to: '+e1.getmessage());
        }
        
        //now add the products to the selectoptions one by one
        for (integer i=0; i<tempProducts.size(); i++)
        {
            SelectOption so =new selectoption(tempProducts[i].name,tempProducts[i].name) ;
            theList.add(so);
            util.debug('label = ' + so.getLabel() + ' value = ' + so.getValue()); 
        }
        
                    
    }
    public void changeSelectorToAdd()
    {
       // system.debug('***********************************************************************changeselectoraddfunction was called');
        //system.debug('**********************************************************************userChoiceProduct='+userChoiceProduct);
        AddOrRemoveSelector=2;
        refresh();
    }
    public void changeSelectorToRemove()
    {
        AddOrRemoveSelector=3;
        refresh();
    }
    public void refresh()
    {
        /*when teh visual force page calls this fucntion--it refreshes all fo teh data on the page.  we redefine the product list--incase the user has selected 
        a different filter for the products listting.  we then redefine the selected products list depending on what button the user pressed (add/remove products)*/
       
        //Exception refreshException;
        system.debug('***********************************************************************refresh function was called');
        //when page refreshes, we want to redefine the product list
        defineProducts(products,productlistFilter);
        
        //TODO when the page refreshes we want to call the define selected product list function
        manageAddOrRemoveSelector();
        
    }
       
    public static string saveProductsToString(list<string> strs)
    {
        //we create a tempstring, we use it for the assignemnt of the products
        string tempstring='';
        /*util.debug('strs has ' + strs.size() + ' items in it. i will play you the song of my people');
        for (string str : strs)
        {
            util.debug(str);    
        }
        */
        //add the products to the upslt_product__c field one by one
        for (integer i=0; i<strs.size(); i++)
        {
            //the equalviancey check later on in the function was failign due to each strs being added with a ; and whitespace, so i changed this so that last 
            //item assigned did not append the whitespace
            if (i!=(strs.size()-1))         
            tempstring+=strs[i]+'; ';//the semicolon will be used as seperator for the parser function in another part of this class
            else tempstring+=strs[i]+';';
        }
        //theMostImportantStringEvar=tempstring;
        util.debug('returning this: ' + tempstring);
        return tempstring;
    }
    
    public string assignProductsToString()
    {
        //this function takes the list of selectedproducts in this class and makes passes them to the saveproductststring function
        //  Exception saveException;
        string[] tempList=new list<string>();
                
        for (integer i = 0; i < selectedproductslist.size(); i++)
        {
            tempList.add(selectedproductslist[i].getValue());
        }
        
        return saveProductsToString(tempList);

    }
        
    public static string[] parseString(string str)
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

    public void initSelectedProductsList(list<selectoption> theList, string theStringWeArePullingItemsFrom)
    {
        //this fucntion checks to see if teh contract already has products added to it.  if it does, it populates 
        //  the list of products to add/remove with the products teh contract has currently.
        
        //clear the list
        theList.Clear();
    
        string tempstring=theStringWeArePullingItemsFrom;
    
        //call parser function to turn single string into list of strings
        string[] tempListOfStrings=parseString(tempstring);
        
        //add the strings to the list of selectoptions one by one
        for (integer i=0; i<tempListofStrings.size(); i++)
        {
            //  what i want to do, is too make sure the products that we are about to add to the selected products list
            //  have the right naming (since we've added our products table to the opportunity)
            //  i want to create a function that will have HARDCODED all of the old products names and return the new
            //  updated name--scratch that, i cant find a list of the old products in the system.
            SelectOption so = new selectoption(tempListOfStrings[i],tempListOfStrings[i]);
            theList.add(so);
        }
        
    }
    
    public void manageAddOrRemoveSelector()
    {
        //this function is a manager for the defineselectedproductslist function
        /*if addorremoveselctor==2 we are adding products, if ==3 we are removing products and if ==1 or 0, there is nothing defined to do with those values yet
            anythign else should return an error.*/
        
        if (addorRemoveSelector==1||addorRemoveSelector==2||addorRemoveSelector==3){}
        else
        {
             throw new myException('Error, addorremoveselector has an undefined value');
        }
        defineSelectedProductsList(addOrRemoveSelector, selectedproductslist,userChoiceProduct,selectedProducts);
        
    }
    public void defineSelectedProductsList(integer actionToTakePlace, selectoption[] theList, string[] listOfUsersSelectedProductsToAdd, string[] listOfProductsToRemove)
    {
        
        if (actionToTakePlace==0)
        {
            throw new myException('actionToTakePlace=0 is reserved.  Choose another choice');
        }
        else if (actionToTakePlace==1)
        {
            //return new myError('This is a default error. You can remove this exception handler when ready to test functin');
        }
        else if (actionToTakePlace==2)
        {
            addProducts(theList,listOfUsersSelectedProductsToAdd);
        }
        else if (actionToTakePlace==3)
        {
            removeProducts(theList,listOfProductsToRemove); 
        }
        else
        {
             throw new myException('acttiontotake place was = to either 1 or 2, this function does not know what to do');
        }
    }

    private void addProducts(selectoption[] theList, string[] strings)
    {
        system.assertNotEquals(null, theList);
        system.assertNotEquals(null, strings);
        
        //jsut to make sure the products are added to the list properly we are going to save
        //the size of the list and compare it later
        integer sizeOfOriginalList=theList.size();
        //now that its saved, lets add the users selection to the list, look out for dupes!
        for (integer i=0; i<strings.size();i++)
        {
            if (!isItDupe(strings[i], theList))
                theList.add(new selectoption(strings[i],strings[i]));
        }
       
    }
    private boolean isitDupe(string str, selectoption[] o)
    {
        
        for (integer count=0; count<o.size(); count++)
        {   
            if (str==o[count].getLabel())
                return true;
        }
        return false;
    }
    private void removeProducts(list<selectoption> theList, string[] productsToRemove)
    {
        //verify arguments are ok
        system.assertNotEquals(null, theList);
        system.assertNotEquals(null, productsToRemove);
        
        //lets store the size of the list so we can verify later on whether or not the removal of items occurred
        integer originalListSize=theList.size();
        
        //lets remove the items in the list one by one--but make sure the item exists in the lsit first
        for (integer i=0; i<productsToRemove.size(); i++)
        {
            //need to remember the location of the product in the list so we can remove it.... if we find something anyway
            integer rememberLocationInList=null;
            for (integer j=0; j<theList.size(); j++)
            {
                if (productsToRemove[i]==theList[j].getlabel()) rememberLocationInList=j;
            }
            if (rememberLocationInList!=null)
            theList.remove(rememberLocationInList);
        }
        //hopefully the items have been removed from the list, we test it just to make sure
        //if a product was asked to be removed, but it was not in the list, the following error will be returned.  it doesn't mean anything bad, its just
        //i want this error to be continued to be returned until im absolutely sure its ok not to check it
        if ((theList.size())!=(originalListSize-productsToRemove.size()))
        {
            throw new myException('Removal of items in the list error has occured.  Is it possible that an item that was supposed to be removed from the list could not be found in the list?');
        }
        
    }
    public class myException extends exception{}
    

    
}