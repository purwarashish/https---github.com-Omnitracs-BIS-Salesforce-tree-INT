/*******************************************************************************
 * File:  RemainingCharactersComponentController.cls
 * Date:  February  18th, 2010
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
public class RemainingCharactersComponentController
{
    //  PLEASE NOTE ONLY ONE COMPONENT CAN BE USED PER PAGE.
    //  this is due to an error with javascript method.  it can only be called once per page, otherwise the # of chars will not update
    public RemainingCharactersComponentController()
    {
        //  empty constuctor, the callnig component should set the field defaults
    }
    
    //public string labelOfField{get; set;}
    //public boolean isRequired{get; set;}
    public string inputTextAreaField{get; set;}
    public integer maxLength{get; set;}
    public integer sizeOfCharRemaingBox{get;set;}
    public integer numOfCols{get; set;}
    public integer numOfRows{get; set;}
    
    //  *****  TEST METHODS  *****

    
}