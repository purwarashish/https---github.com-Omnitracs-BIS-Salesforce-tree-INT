/*******************************************************************************
 * File:  ScheduleCaseMetricCreate.cls
 * Date:  May 14, 2015
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
global class ScheduleCaseMetricCreate implements Schedulable
{
	public static string SECONDS = '0';
    public static string MINUTES = '0';
    public static string HOURS = '1';
    public static string DAY_OF_MONTH = '?';
    public static string MONTH = '*';
    public static string DAY_OF_WEEK= '1';//  sunday
    
    public static string TIME_TO_RUN = SECONDS + ', ' + MINUTES + ', ' + HOURS + ', ' + DAY_OF_MONTH + ', ' + MONTH + ', ' + DAY_OF_WEEK;
    public static string NAME_OF_JOB = 'Create Case Metric - Articles Attached To Cases';
    global void execute(SchedulableContext SC)
    {
        
        /*
        BE ADVISED!!! use this to schedule to run every sunday at 1:00am
        ScheduleCaseMetricCreate SCMC = new ScheduleCaseMetricCreate();
		System.Schedule(ScheduleCaseMetricCreate.NAME_OF_JOB, ScheduleCaseMetricCreate.TIME_TO_RUN, SCMC);
        */
        CaseArticle[] caseArticles;
        try
        {
        	caseArticles = [select id,KnowledgeArticleId, case.business_unit__c, createddate, case.casenumber, caseid from CaseArticle 
        		where createddate = last_week and
        		case.Include_In_Case_Metric__c = true];
        	
        }
        catch(Exception e)
        {
        	util.debug('could not query casearticles due to: ' + e.getMessage());
        	
        }
        if (caseArticles != null)
    	{
    		util.debug('caseArticles queried, num returned: ' + caseArticles.size());
    		 Case_Metric__c cm = new Case_Metric__c();
			cm.Week_run__c = date.today();
			cm.name = 'Case Metric - Articles Attached To Cases';
			cm.Articles_Attached_To_Cases__c = caseArticles.size();
			database.insert(cm);
    		util.debug('metric should have been created');
    	}
        
        
    }
}