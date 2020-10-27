/*******************************************************************************
 * File:  ReOpenCaseExtension.cls
 * Date:  November 26th, 2013
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
public with sharing class ReOpenCaseExtension
{
    public Case theCase{get;set;}
    public String reason {get;set;}
    
    public ReOpenCaseExtension(apexpages.standardcontroller stdcontroller)
    {
        theCase = [select id, status, start_time__c, IsClosed, CaseNumber from case where id =: stdController.getId()];
    }
    public pageReference reOpenCase()
    {
        if (theCase.IsClosed && reason != '' && reason.length() > 1) {
            theCase.Status = 'RE-OPENED';
            theCase.Substatus__c = '';
            theCase.Start_Time__c = null;
            update theCase;
            
            Case_Event__c ce = new Case_Event__c();
            ce.Case__c = theCase.id;
            ce.Display_in_Customer_Portal__c = false;
            ce.Communication_Type__c = 'Internal';
            
            ce.Subject__c = 'Case Re-opened';
            ce.Details__c   = 'Case Re-open Reason: ' + reason;
            insert ce;
            
            PageReference pr = new PageReference('/' + theCase.id);
            pr.setRedirect(true);
            return pr;
        }
        else {
            if (reason == '') {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please provide a reason for re-opening the Case.'));
            }
            else if (reason.length() == 1) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please provide a longer reason for re-opening the Case.'));
            }
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Re-opening a case that is not closed is not allowed.'));
            }
            return null;
        }
    }
    public static ApexPages.StandardController generateController(Case theCase )
    {
        pagereference pageRef=new pagereference('Page.CaseTypeSupportPage');
        test.setcurrentpage(pageRef);       
        return new ApexPages.standardController(theCase);
    }
}