/*******************************************************************************
 * File:  OpportunityHasBeenConvertedExtension.cls
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
public class OpportunityHasBeenConvertedExtension
{
    private id opptId = null;
    
    public OpportunityHasBeenConvertedExtension(apexpages.standardcontroller stdController)
    {
        opptId = stdController.getId();
    }
    
    public PageReference back()
    {
        PageReference pr = new PageReference('/' + opptId);
        pr.setRedirect(true);
        
        return pr;
    }
    
 
}