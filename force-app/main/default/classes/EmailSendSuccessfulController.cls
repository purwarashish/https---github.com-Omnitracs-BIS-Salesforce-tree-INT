/*******************************************************************************
 * File:  EmailSendSuccessfulController.cls
 * Date:  April 9th, 2010
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
public with sharing class EmailSendSuccessfulController
{
    private string returnURL;
    
    //  *****  Constructor(s)  *****
    public EmailSendSuccessfulController(ApexPages.standardController stdController)
    {
        PageReference mypageref = apexpages.currentpage();
        Map<string, string> urlMap = mypageref.getparameters();  
        returnUrl = urlMap.get('retURL');
    }
    
    public PageReference back()
    {
        PageReference pr = new PageReference(returnURL);
        pr.setRedirect(true);
        return pr;
    }
    
    public static ApexPages.StandardController generateController(Account a, string returnURL)
    {
        pagereference pageRef=new pagereference('Page.BillingDetailPage');
        test.setcurrentpage(pageRef);
        //declare apexpages.standardcontroller so that we can pass it into this class's constructor
        if (returnURL != null)
        {
            ApexPages.currentPage().getParameters().put('retURL', returnURL);
        }
        
        return new ApexPages.standardController(a);
    }
    //  ***********  Test Methods  **************
  
}