/*******************************************************************************
 * File:  ArticleToCaseConversion.cls
 * Date:  August 29, 2013
 * Author:  Joseph Hutchins
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 *  *******************************************************************************/
public class ArticleToCaseConversion
{
    public ArticleToCaseConversion(ApexPages.KnowledgeArticleVersionStandardController knowledgeController)
    {
        //  alright first time using this lets not bug it up
        //  we need to cast the sobject passed into this constructor into a article type that exists inthe system
        Sobject article = knowledgeController.getRecord();
        string sourceId = knowledgeController.getSourceId();// this should be the case id
                
        //  then query the case,
        Case tempCase = [select id, subject, description, accountid, account.database_platform__c, 
            Product_Family_PL__c, Business_Unit__c,  solution_long__c         
            from case where id =: sourceId];
        
        if (tempCase.Business_Unit__c == 'Roadnet')
        {
 
            //  aritcle doesn't have a change request, assign case description.
            article.put('summary', tempCase.description);
        
                
            //  then assign values to the article using the case fields
            article.put('title', tempCase.subject);
            
            article.put('Business_Unit__c', tempCase.Business_Unit__c);
            article.put('Details__c', tempCase.Solution_long__c);
        }
        //  environmen can be grabbed from account
        //article.put('Environment__c', tempCase.account.DataBase_Platform__c);
        
        //  visilbity booleans can be set... i'm assuming it has something to do with the channels
        /*article.put('IsVisibleInCsp', 'true');
        article.put('IsVisibleInPkb', 'true');
        article.put('IsVisibleInPrm', 'true');
        */
        //  as it stands right now, we can only populate the category gruop and one level down for the category
        //  so i can prepop Support -> Roadnet Anywhere but cannot prepop like this Support -> Roanet Anywhere -> Plan
        //  my thoughts was to restructure the data categories so i can do something like Roadnet Anywhere -> Plan
        //  but this doesn't work since we can only go one level down and the next lvl down after Roadnet Anywhere is all THEN Plan
        //  so it would ahve to look like Roadnet Anywhere -> All -> Plan
        //  with the current setup, i'll use the case's produt family to decide what the category could be:
        /*if (tempCase.Product_Family_PL__c == 'Roadnet Transportation Suite')
        {
            knowledgeController.selectDataCategory('Support', 'Roadnet_Transporation_Suite');  
        }
        else if (tempCase.Product_Family_PL__c == 'Roadnet Anywhere')
        {
            knowledgeController.selectDataCategory('Support', 'Roadnet_Anywhere');
        }
        else if (tempCase.Product_Family_PL__c == 'RN Telematics')
        {
            knowledgeController.selectDataCategory('Support', 'Telematics');
        }
        else//  by default, just set the category group to be Support
        {
            knowledgeController.selectDataCategory('Support', '');  
        }
        */
        
    }
}