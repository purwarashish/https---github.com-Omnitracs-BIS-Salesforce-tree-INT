/***********************************************************************************
Date: 15 January 2012 
Author: David Ragsdale

Description:  This trigger will handle all apex functions related to the Connection Type object 
- Create Case when Connection type = QTRACS/Services Portal AND User ID/Login/Aux ID = Unity Admin User AND Connection Type was Created by QES Interface user

Dependencies:
- ConnectionTypeUtils.class

Modification History:

************************************************************************************/
trigger ConnectionTypeAll on Connection_Type__c (after insert) {

    string result;
    string CONNTYPE = 'QTRACS/Services Portal';
    string USRID_LOGIN = 'UNITY ADMIN USER';
    string CREATED_BY = 'QES Interface';
    
    if(trigger.isInsert)
    {
        for (Connection_Type__c newCT : Trigger.new)
        {
            if (newCT.Connection_Type__c == CONNTYPE && newCT.User_ID_Login_Aux_ID__c == USRID_LOGIN && newCT.CreatedById == system.label.QES_INTERFACE_ID)
            {
                result = ConnectionTypeUtils.createCase(newCT.NMC_Account__c, newCT.Company_ID__c);                         
            }
        }
    }

}