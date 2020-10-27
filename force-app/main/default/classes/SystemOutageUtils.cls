/*********************************************************************
Name    : SystemOutageUtils
Author  : Shruti Karn
Date    : 08 June 2011

Usage   : Provides various utility operations for the System Outage object 
    
Dependencies : None

*********************************************************************/
public class SystemOutageUtils{

/********************************************************************************************
    Qforce Case# 32899
    This method updates the Case Severity to '1-Critical' whenever a System Outage record is 
    created/updated.
*********************************************************************************************/
    
    public static void updateCase(list<System_Outage__c> lstSystemOutage)
    {
        //String strError = '';
        list<Id> lstId = new list<Id>();
        list<case> lstCase = new list<Case>();
        for(System_Outage__c sysOut : lstSystemOutage)
        {
            lstId.add(sysOut.Case__c);
        }
        
        if(!(lstId.isEmpty()))
        {
            lstCase = [Select Priority from Case where id in:lstId limit 10000];
            for(Case c: lstCase)
            {
                c.Priority = '1-Critical';
            }
        }
        try
        {
            update lstCase;
        }
        catch(Exception e)
        {
system.debug('Exception in UpdateRelatedCase trigger:'+e);
            //strError = 'The Case cannot be updated due to some error. Please contact your System Administrator';
        }
        //return strError;
    }
}