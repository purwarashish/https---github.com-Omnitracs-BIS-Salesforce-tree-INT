/*******************************************************************************
 * File:  Util.cls
 * Date:  May 25th, 2010
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
public class Util 
{
    public static string LIVE_URL = 'https://na1.salesforce.com/';
    public static string joeHutchId = '0033000000XoqnJ'; 
    public static string queriesUsed
    {
    	get
    	{
    		return 'QueryLimit: ' + Limits.getLimitQueries() + 
    		  ' QueriesUsed: ' + Limits.getQueries() + 
    		  ' QueriesLeft:' + (Limits.getLimitQueries() - Limits.getQueries());
    		  
    	}
    }
    public static string josephUserRecordId
    {
        get
        {
             //= '00530000001f8ouAAA';
             User josephRecord;
             try
             {
                josephRecord = [select id, name from User where name = 'Joseph Hutchins' and isactive = true limit 1];
                return josephRecord.id;
             }
             catch(exception e)
             {
                //  if my user record doesn't exist, then just pull up the first system admin
                return [select id, name from user where profile.name = 'System Administrator' and isactive = true limit 1].id;
             }
             
        }
    }
    public static string testEmailTemplateId = '00XQ0000000EDpl';
    public static string janesTestAccountId = '0013000000OOHer';
    
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
   
    public static string convertListStringsToOneString(string[] strings)
    {
        string theString='';
        for (integer i = 0; i <strings.size(); i++)
        {
            if (i + 1 > strings.size())//  don't append semi colon
            {
                theString += strings[i];
                break;  
            }
            else
            {
                theString += strings[i] + '; ';
                
            }
        }   
        return theString;
    }
    public static boolean zeroOrNull(decimal value)
    {
        if (value == null)
        {
            return true;
        }
        else if (value == 0.0)
        {
            return true;
        }
        return false;
    }
    
    public static string FromAddressForCases
    {
        get
        {
            if (isRnEnvironment)
            {
                util.debug('userinfo profile id = ' + userInfo.getProfileId() + ' and the boolean = ' + (userinfo.getProfileId() == '00e30000000h3p2'));
                //  if the user logged in is system admin, use the generaic email address
                if (userinfo.getName() == 'Joseph Hutchins' || userinfo.getName() == 'Amy Bowser')
                {
                    return NOT_VALID_EMAIL;
                }
                else
                {
                    return null;
                }
            }
            else
            {
                return null;
            }
            
        }
    }
    public static boolean isSandbox
    {
        get
        {
            //  not sure how to differenate between sandboxes.... i'll see if the org id has any indicator on there or maybe
            //  the username which will have .mibos or .backup
            //  mibos sandbox: 00DW0000008wBkoMAE
            //  uat3 sandbox:  00DR0000001yEIDMA2
            // roadnet sanbox: 00DQ000000GK5zcMAD
            //  roadnet live: 00D300000001QkBEAU
            //  so there are no differences in the id, so we will need to check the user's username and look for the .mibos...
            
            //  here is mibos uat3 sandbox username: jhutchins@roadnet.omnitracs.com.uat
            //  mibos sandbox is: .mibos
            //  oursandbox is .backup
            //  and the production enviroments we can assume will  be username@domain.com  with nothing at the back
            string userName = userInfo.getUserName();
            return userName != null &&
              userName.Contains('.mibos') ||
              userName.Contains('.uat') ||
              userName.Contains('.backup');
        }
    }
    
    public static boolean isRnEnvironment
    {
        get
        {
            string orgName = UserInfo.getOrganizationName();
            return orgName.Contains('Roadnet');
            /*
            id userOrgId = userInfo.getOrganizationId();
            
            
            final id RN_SANDBOX_ORG_ID = '00DQ000000GK5zcMAD';
            final id RN_PRODUCTION_ORG_ID = '00D300000001QkB';
            return userOrgId == RN_SANDBOX_ORG_ID || userOrgId == RN_PRODUCTION_ORG_ID;
            */
        }
    }
    public static boolean isMibosEnvironment
    {
        get
        {
            string orgName = UserInfo.getOrganizationName();
            return orgName.Contains('Mibos');
        }
    }
    public static string BASE_URL
    {
        GET
        {
            return URL.getSalesforceBaseUrl().toExternalForm() + '/';
        }
        
    }
    public static string NOT_VALID_EMAIL
    {
        get
        {
            return '0D230000000TN6P';
        }
    }
    public static void breakPoint(string msg)
    {
        throw new UtilException('******  Break point set ' + msg + ' **********');  
    }
    public static void breakPoint(boolean b)
    {
        throw new UtilException('******  Break point set ' + b + ' **********');  
    }
    public static void breakPoint(integer theCount)
    {
        throw new UtilException('******  Break point set ' + theCount + ' **********');
    }
    public static void breakPoint(Id theId)
    {
        throw new UtilException('******  Break point set ' + theId + ' **********');
    }
    public static void breakPoint(date theDate)
    {
        throw new UtilException('******  Break point set ' + theDate + ' **********');
    }
    public static void breakPoint(datetime theDateTime)
    {
        throw new UtilException('******  Break point set ' + theDateTime + ' **********');
    }
    public static void breakPoint()
    {
        throw new UtilException('******  Break point set **********');  
    }
    public static void debug(string msg)
    {
        system.debug('CTRLF @@@@@@@@@@@@@@@@@ ' + msg + ' @@@@@@@@@@@@@@@@@@@');
    }
    public static void debug(decimal msg)
    {
        system.debug('CTRLF @@@@@@@@@@@@@@@@@ ' + msg + ' @@@@@@@@@@@@@@@@@@@');
    }
    public static void debug(integer msg)
    {
        system.debug('CTRLF @@@@@@@@@@@@@@@@@ ' + msg + ' @@@@@@@@@@@@@@@@@@@');
    }
    public static boolean isBlank(string str)
    {
        return str == null || str.length() == 0;
    }
    public static PageReference notReadyYet()
    {
        throw new UtilException('This method/class has not been implemented yet.');
    }
    public class UtilException extends Exception{}
}