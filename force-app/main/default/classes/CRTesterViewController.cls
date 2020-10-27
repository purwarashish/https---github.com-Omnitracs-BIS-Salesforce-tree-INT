/*******************************************************************************
 * File:  CRTesterViewController.cls
 * Date:  Sep 14, 2009  
 * Author:  Charlie Heaps
 *
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of Roadnet Technologies is strictly prohibited.
 *
 * Confidential, unpublished property of Roadnet Technologies.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, Roadnet Technologies, Inc.  All rights reserved.
 * *******************************************************************************/

public class CRTesterViewController 
{
    
    // Constructor
    public CRTesterViewController()
    {
        viewType = 'assigned';
        testerId = null;
        groupId = null;
        
        //  default the row display limit and test run sorting preferences to 
        //  what is stored in the group member record
        RetrieveUserPreferencesFromCRVersionTaskGroupMember();
        
        resetCachedProperties();
        
        //InitializeChartValues();
    }
    
    private void RetrieveUserPreferencesFromCRVersionTaskGroupMember()
    {
        CR_Version_Task_Group_Member__c groupMember;
        try
        {
            groupMember = [select Row_Display_Limit__c, Sort_Tests_Ascending__c, Test_Sorting_Preference__c from CR_Version_Task_Group_Member__c where member__c =: userInfo.getUserId() ];
        }
        catch(Exception e)
        {
            return;
        }
        
        if(groupMember != null)
        {
            if((groupMember.Sort_Tests_Ascending__c == true && groupMember.Test_Sorting_Preference__c == 'targetDate') || groupMember.Test_Sorting_Preference__c == null)
            {
                unsorted = true;
            }
            else
            {
                ascending = groupMember.Sort_Tests_Ascending__c;
                ordering = groupMember.Test_Sorting_Preference__c;
                unsorted = false;
            }
            
            if(groupMember.Row_Display_Limit__c != null)
            {
                displayLimit = groupMember.Row_Display_Limit__c.intValue();
            }   
        }
    }
    
    //
    // Gets all users in the current CR version task group
    //
    private List<Id> getCurrentUserGroupMembers()
    {
        groupId = [select CR_Version_Task_Group__c
                    from CR_Version_Task_Group_Member__c 
                    where Member__c = :testerId 
                        and CR_Version_Task_Group__r.Primary_Function__c = 'Testing'].CR_Version_Task_Group__c;
                    
        List<CR_Version_Task_Group_Member__c> groupMembers = [select Id, Member__c 
                                                              from CR_Version_Task_Group_Member__c 
                                                              where CR_Version_Task_Group__c = :groupId];
        List<Id> currentTesterIds = new List<Id>();
        for(CR_Version_Task_Group_Member__c member : groupMembers)
        {
            currentTesterIds.add(member.Member__c);
        }
        
        return currentTesterIds;
    }
    
    //
    // Gets all CRs assigned to the currently selected tester
    //
    /*
    public List<CR_Version__c> retrieveAssignedCRVersions()
    {
        List<CR_Version__c> crVersions = 
            [select 
                Id,
                Name,
                Urgency__c, 
                Testing_Resource__r.Name, 
                Summary__c, 
                Days_Open__c,
                Days_In_Need_Info__c,
                Target_Patch__c,
                Customer_Found__c,
                CS_Priority__c,
                Status__r.Name, 
                Status__r.Rejected__c,
                Status_Is_Override__c,
                Is_Found_In_Version__c,
                Product_Version__r.Name,
                Change_Request__c, 
                Change_Request__r.Name,
                Change_Request__r.Found_In_Product_Area__r.Short_Name__c
            from CR_Version__c
            where 
                Status__r.Name != 'N/A' and  
                Status__r.Name != 'Closed - Open Doc' and
                Status__r.Name != 'Posted' and  
                Status__r.Name != 'Passed' and 
                Status__r.Name != 'Insignificant' and 
                Status__r.Closed__c = false and
                Testing_Resource__c = :testerId
            order by 
                PD_Service_Level__c asc,
                Product_Version__r.Name asc,
                Created_Date__c asc,
                Id asc];
                
            return crVersions;
        }
        
    //
    // Gets all CRs submitted by the currently selected tester
    //    
    public List<CR_Version__c> retrieveSubmittedCRVersions()
    {
        List<CR_Version__c> crVersions = 
            [select 
                Id,
                Name, 
                Urgency__c, 
                Testing_Resource__r.Name, 
                Summary__c, 
                Days_Open__c,
                Days_In_Need_Info__c,
                Target_Patch__c,
                Customer_Found__c,
                CS_Priority__c,
                Status__r.Name, 
                Status__r.Rejected__c,
                Status_Is_Override__c,
                Status__r.Closed__c,
                Is_Found_In_Version__c,
                Product_Version__r.Name,
                Change_Request__c, 
                Change_Request__r.Name,
                Change_Request__r.Found_In_Product_Area__r.Short_Name__c
            from CR_Version__c
            where 
                Status__r.Name != 'N/A' and  
                Status__r.Name != 'Closed - Open Doc' and  
                Status__r.Name != 'Posted' and
                Status__r.Name != 'Passed' and  
                Status__r.Name != 'Insignificant' and
                Status__r.Closed__c = false and
                CreatedById = :testerId
            order by 
                PD_Service_Level__c asc,
                Product_Version__r.Name asc,
                Created_Date__c asc,
                Id asc];
                
            return crVersions;
        }
        
    //
    // Retrieves CR versions for the currently selected user's assigned or submitted CRs
    //
    public List<CRVersionEx> retrieveCRVersions()
    {
        List<CR_Version__c> crVersions;
        
        if (viewType == 'assignedCR')
        {
            crVersions = retrieveAssignedCRVersions();
        }
        else
        {
            crVersions = retrieveSubmittedCRVersions();
        }    
        
        crVersionCount = crVersions.size();
        
        List<CRVersionEx> newCRVersions = new List<CRVersionEx>();
            
        // Put crVersions with an exception status at the top of the list
        for (CR_Version__c crv : crVersions)
        {
            if (crVersionHasExceptionStatus(crv, testerId))
            {
                newCRVersions.add(new CRVersionEx(crv, testerId));
            }
        }
        
        for (CR_Version__c crv : crVersions)
        {
            if (crVersionHasExceptionStatus(crv, testerId))
            {
                // Already have these, don't add again.
                continue;
            }
            
            CRVersionEx newCRVersion = new CRVersionEx(crv, testerId);
            
            newCRVersions.add(newCRVersion);
        }
        
        // This list stores lists of CR versions that are for the same CR
        List<List<CRVersionEx>> groupedCRVersions = new List<List<CRVersionEx>>();
        
        // Map stores positions of existing CR versions that other versions
        // of the same CR can easily find
        Map<Id,Integer> CRVersionPositions = new Map<Id,Integer>();
        
        for (CRVersionEx versionEx : newCRVersions)
        {   
            ID crId = versionEx.crVersion.Change_Request__c;

            if(CRVersionPositions.get(crId) == null)
            {
                List<CRVersionEx> newCRVList = new List<CRVersionEx>();
                newCRVList.add(versionEx);
                groupedCRVersions.add(newCRVList);
                CRVersionPositions.put(versionEx.crVersion.Change_Request__c,groupedCRVersions.size()-1);
            }
            else
            {
                List<CRVersionEx> sameCR = groupedCRVersions[CRVersionPositions.get(crId)];
                versionEx.propagation = true;
                sameCR.add(versionEx);
            }
        }
        
        List<CRVersionEx> retCRVersions = new List<CRVersionEx>();
        for(List<CRVersionEx> versionsOfCR : groupedCRVersions)
        {
            if (usingDisplayLimit && (retCRVersions.size() >= displayLimit))
            {
                break;
            } 
            retCRVersions.addAll(versionsOfCR);
        }
        
        return retCRVersions;
    }
    
    //
    // Returns whether a CR version is in a state that needs attention
    //
    public static Boolean crVersionHasExceptionStatus(CR_Version__c crv, ID testerId)
    {
        return (crv.Status__r.Rejected__c == true ||
                crv.Status__r.Name == 'Need Info' ||
                (crv.Status__r.Name == 'Testing' && crv.Testing_Resource__c == testerId));
    }
    */
    
    //
    // Returns test case metrics for the scorecard
    //
    public TestCaseScorecardStats retrieveTestCaseStats(
        Date beginDate, 
        Date endDate,
        List<Id> testerIds)
    { 
        TestCaseScorecardStats stats = new TestCaseScorecardStats();

        // Get the Datetime of the beginning of the day on beginDate
        Datetime beginDateTime = 
           Datetime.newInstance(
               beginDate.year(), 
               beginDate.month(), 
               beginDate.day());

        // Get the Datetime of the end of the day on endDate
        Date endDatePlus1 = endDate.addDays(1); 

        Datetime endDateTime = 
           Datetime.newInstance(
               endDatePlus1.year(), 
               endDatePlus1.month(), 
               endDatePlus1.day());

        Date nextWeekBegin = (endDate.AddDays(6)).toStartOfWeek();

        stats.numSubmitted = [select count() 
                           from Test_Case__c 
                           where CreatedById in :testerIds
                                and CreatedDate >= :beginDateTime 
                                and CreatedDate <= :endDateTime];

        stats.numPassed = [select count()
                           from Test_Run__c
                           where Assigned_To__c in :testerIds
                                and Result__c = 'Pass'
                                and Status_Change_Date__c >= :beginDateTime
                                and Status_Change_Date__c <= :endDateTime];

        stats.numFailed = [select count()
                           from Test_Run__c
                           where Assigned_To__c in :testerIds
                                and Result__c = 'Fail'
                                and Status_Change_Date__c >= :beginDateTime
                                and Status_Change_Date__c <= :endDateTime];
        
        stats.numCasesRun = stats.numPassed + stats.numFailed;

        stats.numBlocked = [select count() 
                            from Test_Run__c
                            where Assigned_To__c in :testerIds
                                and Blocked_Date__c >= :beginDateTime
                                and Blocked_Date__c <= :endDateTime];

        stats.numApproved = [select count()
                             from Test_Case__c
                             where CreatedById in :testerIds
                                and Approval_Status__c = 'Approved'
                                and Approval_Status_Date__c >= :beginDateTime
                                and Approval_Status_Date__c <= :endDateTime];

        stats.numNeedRework = [select count() 
                               from Test_Case__c 
                               where CreatedById in :testerIds
                                and Need_Rework_Date__c >= :beginDateTime
                                and Need_Rework_Date__c <= :endDateTime];

        stats.numPending = [select count() 
                             from Test_Case__c 
                             where CreatedById in :testerIds
                                and Approval_Status__c = 'Awaiting approval'
                                and Approval_Status_Date__c >= :beginDateTime
                                and Approval_Status_Date__c <= :endDateTime];

        stats.numReviewed = [select count() 
                             from Test_Case__c 
                             where Reviewer_Id__c in :testerIds
                                and Approval_Status__c != 'Awaiting approval'
                                and Approval_Status_Date__c >= :beginDateTime
                                and Approval_Status_Date__c <= :endDateTime];

        stats.numRunsForWeek = [select count()
                                from Test_Run__c
                                where Assigned_To__c in :testerIds
                                    and Target_Completion_Date__c >= :beginDate
                                    and Target_Completion_Date__c < :nextWeekBegin
                                    and (((Result__c = 'Pass' or Result__c = 'Fail') 
                                        and Status_Change_Date__c >= :beginDateTime 
                                        and Status_Change_Date__c <= :endDateTime)
                                        or (Result__c = 'Not yet run' or Result__c = 'Blocked'))];
                                    

        return stats;
    }
/*
    //
    // Returns change request metrics for the scorecard
    //
    public ScorecardStats retrieveCRStats(
        Date beginDate, 
        Date endDate,
        List<Id> testerIds)
    {   
        ScorecardStats stats = new ScorecardStats();
        
        // Get the Datetime of the beginning of the day on beginDate
        Datetime beginDateTime = 
           Datetime.newInstance(
               beginDate.year(), 
               beginDate.month(), 
               beginDate.day());

        // Get the Datetime of the end of the day on endDate
        Date endDatePlus1 = endDate.addDays(1); 
        
        Datetime endDateTime = 
           Datetime.newInstance(
               endDatePlus1.year(), 
               endDatePlus1.month(), 
               endDatePlus1.day());
               
        stats.numCustomerDefectsSubmitted = 
            [Select count() 
             from CR_Version__c 
             where Customer_Found__c = 'True' and
                   Change_Request_Type__c = 'Defect' and
                   CreatedDate >= :beginDateTime and CreatedDate <= :endDateTime];

        List<CR_Event__c> submittedCrEvents = 
          [select id, Change_Request__r.Id, Change_Request__r.CreatedById, description__c 
           from CR_Event__c 
           where  Change_Request__r.CreatedById in :testerIds
                  and CreatedDate >= :beginDateTime
                  and CreatedDate <= :endDateTime
           order by CreatedDate desc];
        
        List<CR_Event__c> assignedCrEvents = 
          [select id, Change_Request__r.Id, CreatedById, description__c 
           from CR_Event__c 
           where  CreatedDate >= :beginDateTime and
                  CreatedDate <= :endDateTime and
                  CreatedById in :testerIds
           order by CreatedDate desc];
        
        Set<ID> rejectedPoorCRIds = new Set<ID>();
        Set<ID> rejectedOtherCRIds = new Set<ID>();
        Set<ID> needInfoCRIds = new Set<ID>();
        Set<ID> failedCRIds = new Set<ID>();
        
        Integer numVersionsPassed = 0;
        Integer numVersionsClosedOpenDoc = 0;

        for (CR_Event__c evt : submittedCrEvents)
        {
            if (evt.Description__c != null)
            {
                if (evt.Description__c.contains('> to <Rejected - CR Needs Improvement>'))
                {
                    if (!rejectedPoorCRIds.contains(evt.Change_Request__r.Id))
                    {
                        rejectedPoorCRIds.add(evt.Change_Request__r.Id);
                    }
                }
                else if (evt.Description__c.contains('> to <Rejected'))
                {
                    if (!rejectedOtherCRIds.contains(evt.Change_Request__r.Id))
                    {
                        rejectedOtherCRIds.add(evt.Change_Request__r.Id);
                    }
                }
                else if (evt.Description__c.contains('> to <Need Info>'))
                {
                    if (!needInfoCRIds.contains(evt.Change_Request__r.Id))
                    {
                        needInfoCRIds.add(evt.Change_Request__r.Id);
                    }
                }
            }
        }
        
        for (CR_Event__c evt : assignedCrEvents)
        {
            if (evt.Description__c != null)
            {
                if (evt.Description__c.contains('> to <Failed>'))
                {
                    if (!failedCRIds.contains(evt.Change_Request__r.Id))
                    {
                        failedCRIds.add(evt.Change_Request__r.Id);
                    }
                }
                else if (evt.Description__c.contains('> to <Passed>'))
                {
                    numVersionsPassed++;
                }
                else if(evt.Description__c.contains('> to <Closed - Open Doc') && !evt.Description__c.contains('Pass'))
                {
                    numVersionsClosedOpenDoc++;
                }
            }
        }
        
        stats.numRejectedPoor = rejectedPoorCRIds.size();
        stats.numRejectedOther = rejectedOtherCRIds.size();
        stats.numNeedInfo = needInfoCRIds.size();
        stats.numFailed = failedCRIds.size();
        
        stats.numSubmitted =
            [select count() 
             from Change_Request__c 
             where CreatedById in :testerIds
                   and CreatedDate >= :beginDateTime
                   and CreatedDate <= :endDateTime];
                   
        stats.numVersionsClosed =
            [select count() 
             from CR_Version__c 
             where Closed_By__c in :testerIds
                   and Closed_Date__c >= :beginDate 
                   and Closed_Date__c <= :endDate];
                   
        stats.numVersionsPassed = numVersionsPassed;
        stats.numVersionsClosed = stats.numVersionsClosed + numVersionsClosedOpenDoc;
        return stats;
    }
    */
    
    // Properties
    
    public String viewType {get; set;}  // assigned or submitted
    
    public String title {get; set;}
    
    public ID groupId {get; set;}
    
    public String groupDescription {get; set;}
    /*
    public List<CRVersionEx> crVersions 
    {
        get
        {
           return retrieveCRVersions();
        }
    }
*/
    public Boolean showScorecard
    {
        get
        {
            return viewType == 'scorecard';
        }
    }
    
    public Boolean showGroupScorecard
    {
        get
        {
            return viewType == 'groupScorecard';
        }
    }
    
    public Boolean showCRList
    {
        get
        {
            return (viewType == 'submittedCR' || viewType == 'assignedCR');
        }
    }
    
    public Boolean showTestRunsList
    {
        get
        {
            return viewType == 'assignedTestRuns';
        }
    }
    
    public Boolean showTestCaseList
    {
        get
        {
            return viewType == 'testCases';
        }
    }
    
    public Integer crVersionCount {get; set;}
    
    public Integer displayLimit 
    {
        get; 
        
        set
        {
            displayLimit = value;
        }
    }
    
    public Boolean usingDisplayLimit 
    {
        get
        {
            return displayLimit > 0;
        }
    }
    
    public ID testerId 
    {
        get; 
        
        set
        {
            testerId=value; 
        }
    }
    /*
    List<Test_Case_Metrics__c> m_testingMetrics = null;
    
    public List<Test_Case_Metrics__c> TestingMetrics
    {
        get
        {
            if(m_testingMetrics == null)
            {
                Date lastYearToday = System.Today();
                lastYearToday = lastYearToday.addYears(-1);
                
                m_testingMetrics = [select Week_End_Date__c,
                                         Cases_Added__c,
                                         Cases_Run__c,
                                         Defects_Added__c,
                                         Defects_Closed__c,
                                         Found_In_Versions_Closed__c 
                                    from Test_Case_Metrics__c 
                                    where Week_End_Date__c >= :lastYearToday
                                    order by Week_End_date__c asc];
            }
            return m_testingMetrics;
        }
    }
    
    */
    /*
    public Date ChartEndDate
    {
        get
        {
            return TestingMetrics[TestingMetrics.size()-1].Week_End_Date__c;
        }
    }
    */
    public List<Integer> DefectMetricChartValues
    {
        get; set;
    }
    
    public List<Integer> TestCaseMetricChartValues
    {
        get; set;
    }
    /*    
    public void InitializeChartValues()
    {
        List<Integer> CasesAddedMetrics = new List<Integer>();
        List<Integer> CasesRunMetrics = new List<Integer>();
        List<Integer> CRsAddedMetrics = new List<Integer>();
        List<Integer> OtherCRVsClosedMetrics = new List<Integer>();
        List<Integer> FoundinVersionsClosedMetrics = new List<Integer>();
        TestCaseMetricChartValues = new List<Integer>();
        DefectMetricChartValues = new List<Integer>();
        
        for(Test_Case_Metrics__c metric : TestingMetrics)
        {
            CasesAddedMetrics.add(metric.Cases_Added__c.intValue());
            CasesRunMetrics.add(metric.Cases_Run__c.intValue());
            CRsAddedMetrics.add(metric.Defects_Added__c.intValue());
            OtherCRVsClosedMetrics.add(metric.Defects_Closed__c.intValue());
            FoundInVersionsClosedMetrics.add(metric.Found_In_Versions_Closed__c.intValue());
        }
        
        TestCaseMetricChartValues.addAll(CasesAddedMetrics);
        TestCaseMetricChartValues.addAll(CasesRunMetrics);
        DefectMetricChartValues.addAll(CRsAddedMetrics);
        DefectMetricChartValues.addAll(OtherCRVsClosedMetrics);
        DefectMetricChartValues.addAll(FoundinVersionsClosedMetrics);
    }
    */
    
    public List<String> TestCaseMetricChartColors
    {
        get
        {
            List<String> colors = new List<String>();
            colors.add('0000FF');
            colors.add('00FF00');
            return colors;
        }
    }
    
    
    public List<String> DefectMetricChartColors
    {
        get
        {
            List<String> colors = new List<String>();
            colors.add('FF0000');
            colors.add('00FF00');
            colors.add('0099FF');
            return colors;
        }
    }
    
    public List<String> TestCaseMetricChartLabels
    {
        get
        {
            List<String> labels = new List<String>();
            labels.add('Test Cases added');
            labels.add('Test Cases run');
            return labels;
        }
    }
    
    public List<String> DefectMetricChartLabels
    {
        get
        {
            List<String> labels = new List<String>();
            labels.add('Defects added by TE');
            labels.add('Other CR versions closed');
            labels.add('CR \'Found in\' Versions closed');
            return labels;
        }
    }
    /*
    public ScorecardStats thisWeekCRStats 
    {
        get
        {
            Date thisWeekBeginDate = Date.today().toStartOfWeek().addDays(1); // this Monday
            
            List<Id> testerIdList = new List<Id>();
            testerIdList.add(testerId);
            return retrieveCRStats(thisWeekBeginDate, 
                                    Date.today(),
                                    testerIdList);
        }
    }
        
    public ScorecardStats lastWeekCRStats 
    {
        get
        {
            Date lastWeekEndDate = Date.today().toStartOfWeek(); // Sunday of previous week
            Date lastWeekBeginDate = lastWeekEndDate.addDays(-6); // Monday of previous week
            List<Id> testerIdList = new List<Id>();
            testerIdList.add(testerId);
            return retrieveCRStats(lastWeekBeginDate, 
                                    lastWeekEndDate,
                                    testerIdList);
        }
    }
    
    public ScorecardStats thisWeekGroupCRStats 
    {
        get
        {
            Date thisWeekBeginDate = Date.today().toStartOfWeek().addDays(1); // this Monday
            
            List<Id> currentTesterIds = getCurrentUserGroupMembers();
            
            return retrieveCRStats(thisWeekBeginDate, 
                                    Date.today(),
                                    currentTesterIds);
        }
    }

    public ScorecardStats lastWeekGroupCRStats 
    {
        get
        {
            Date lastWeekEndDate = Date.today().toStartOfWeek(); // Sunday of previous week
            Date lastWeekBeginDate = lastWeekEndDate.addDays(-6); // Monday of previous week
            
            List<Id> currentTesterIds = getCurrentUserGroupMembers();
            return retrieveCRStats(lastWeekBeginDate, 
                                    lastWeekEndDate,
                                    currentTesterIds);
        }
    }
    
    public TestCaseScorecardStats thisWeekCaseStats
    {
        get
        {
            Date thisWeekBeginDate = Date.today().toStartOfWeek().addDays(1); // this Monday
            
            List<Id> testerIdList = new List<Id>();
            testerIdList.add(testerId);
            return retrieveTestCaseStats(thisWeekBeginDate, 
                                        Date.today(),
                                        testerIdList);
        }
    }
    
    public TestCaseScorecardStats lastWeekCaseStats
    {
        get
        {
            Date lastWeekEndDate = Date.today().toStartOfWeek(); // Sunday of previous week
            Date lastWeekBeginDate = lastWeekEndDate.addDays(-6); // Monday of previous week
            
            List<Id> testerIdList = new List<Id>();
            testerIdList.add(testerId);
            
            return retrieveTestCaseStats(lastWeekBeginDate, 
                                        lastWeekEndDate,
                                        testerIdList);

        }
    }
    
    public TestCaseScorecardStats lastWeekGroupCaseStats
    {
        get
        {
            Date lastWeekEndDate = Date.today().toStartOfWeek(); // Sunday of previous week
            Date lastWeekBeginDate = lastWeekEndDate.addDays(-6); // Monday of previous week
            
            List<Id> currentTesterIds = getCurrentUserGroupMembers();
            return retrieveTestCaseStats(lastWeekBeginDate,
                                            lastWeekEndDate,
                                            currentTesterIds);
        }
    }
    
    public TestCaseScorecardStats thisWeekGroupCaseStats
    {
        get
        {
                Date thisWeekBeginDate = Date.today().toStartOfWeek().addDays(1); // this Monday
                
                List<Id> currentTesterIds = getCurrentUserGroupMembers();
                return retrieveTestCaseStats(thisWeekBeginDate, 
                                                Date.today(),
                                                currentTesterIds);
        }
    }
        */
    private User m_tester = null;
    public User tester 
    {
        get
        {
            if (m_tester == null)
            {
                m_tester = [select Id, Name from User where Id = :testerId];
            }
            return m_tester;
        }
    }
    
    public String scorecardTitle
    {
        get 
        {
            if (showGroupScorecard)
            {
                return 'Scorecard for ' + groupDescription + '\'s group';
            }
            else
            {
                return 'Scorecard for ' + tester.Name;
            }
        }
    }
/*
    public String crVersionQueueTitle
    {
        get 
        {
            return crVersions.size() + ' of ' + crVersionCount + '. ';
        }
    }
    */
    public String assignedTestRunQueueTitle
    {
        get
        {
            return '(' + displayedRunList.size() + ' of ' +  notYetRunList.size() + ')';
        }
    }
    
    public String assignedTestRunPageCounter
    {
        get
        {
            return 'Page ' + (m_testRunPage + 1) + ' of ' + numberOfPages();
        }
    }
    
    public String blockedTestRunQueueTitle
    {
        get
        {
            return '(' + displayedBlockedRuns.size() + ' of ' + blockedRunList.size() + ')';
        }
    }
    
    private Datetime m_lastWeekEnd = null;
    public String lastWeekEndDate 
    {
        get
        {
            if (m_lastWeekEnd == null)
            {
                Date prevSunday = Date.today().toStartOfWeek();
                Integer year = prevSunday.year();
                Integer month = prevSunday.month();
                Integer day = prevSunday.day();
                
                m_lastWeekEnd = Datetime.newInstance(year, month, day);
            }
            return m_lastWeekEnd.format('E dd-MMM-yyyy');
        }
    }
    
    private Datetime m_thisWeekEnd = null;
    public String thisWeekEndDate 
    {
        get
        {
            if (m_thisWeekEnd == null)
            {
                Date followingSunday = Date.today().toStartOfWeek().addDays(7);
                Integer year = followingSunday.year();
                Integer month = followingSunday.month();
                Integer day = followingSunday.day();
                
                m_thisWeekEnd = Datetime.newInstance(year, month, day);
            }
            return m_thisWeekEnd.format('E dd-MMM-yyyy');
        }
    }

    private List<TestRunEx> m_displayedBlockedRuns;
    public List<TestRunEx> displayedBlockedRuns
    {
        get
        {
            if(m_displayedBlockedRuns == null)
            {
                Integer i = 0;
                List<TestRunEx> displayed = new List<TestRunEx>();
                
                while((i < displayLimit && usingDisplayLimit && i < blockedRunList.size()) || 
                      (i < blockedRunList.size() && !usingDisplayLimit))
                {
                    displayed.add(new TestRunEx(blockedRunList[i]));
                    i++;
                }
                m_displayedBlockedRuns = displayed;
            }
            
            return m_displayedBlockedRuns;
        }
    }
    
    private List<Test_Run__c> m_blockedRunList;
    public List<Test_Run__c> blockedRunList
    {
        get
        {
            if(m_blockedRunList == null)
            {
                m_blockedRunList = [select Id, 
                                           Name, 
                                           Test_Case__c, 
                                           Product_Version_PL__c,
                                           Product_Patch__c,
                                           Result__c,
                                           Notes__c,
                                           Test_Case__r.Test_Objective__c,
                                           Test_Case__r.Product_Family_PL__c,
                                           Test_Case__r.Product_Area_PL__c,
                                           Test_Case__r.Priority__c,
                                           Test_Case__r.Function_PL__c,
                                           Test_Case__r.Subfunction_PL__c,
                                           Test_Case__r.Name,
                                           Target_Completion_Date__c,
                                           Parameters__c
                                     from Test_Run__c
                                     where Assigned_To__c = :testerId
                                        and Result__c = 'Blocked'
                                     order by Target_Completion_Date__c asc nulls last, 
                                              Name asc];
            }
                    
            return m_blockedRunList;
        }
    }
    
    
    private String ordering;
    private Boolean ascending = true;
 
    private Integer m_runsPerPage = 1;
    private Integer m_testRunPage = 0;
    
    public void firstRunPage()
    {
        m_displayedRunList = null;
        m_testRunPage = 0;
    }
    public void nextRunPage()
    {
        if(m_testRunPage < numberOfPages() - 1)
        {
            m_displayedRunList = null;
            m_testRunPage++;
        }
    }
    public void prevRunPage()
    {
        if(m_testRunPage > 0)
        {
            m_displayedRunList = null;
            m_testRunPage--;
        }
    }
    public void lastRunPage()
    {
        m_displayedRunList = null;
        m_testRunPage= numberOfPages() - 1;
    }
    
    private Integer numberOfPages()
    {
        Integer notYetRunListSize = m_notYetRunList == null ? 0 : m_notyetRunList.size();
        
        Integer numPages = notYetRunListSize / m_runsPerPage;
        if(notYetRunListSize - (numPages * m_runsPerPage) > 0)
        {
            return numPages + 1;
        }
        if(numPages == 0)
        {
            return 1;
        }
        return numPages;
    }
        
    private Boolean unsorted = true;
    
    private List<TestRunEx> m_displayedRunList;
    public List<TestRunEx> displayedRunList
    {
        get
        {
            if(m_displayedRunList == null)
            {
                m_displayedRunList = new List<TestRunEx>();
                
                
                if(usingDisplayLimit)
                {
                    m_runsPerPage = displayLimit;
                }
                else
                {
                    m_runsPerPage = 100;
                }
    
                if(unsorted)
                {
                    m_displayedRunList = new List<TestRunEx>();
                    Integer listPosition = m_runsPerPage * m_testRunPage;
                    for(Integer i = 0; i < m_runsPerPage && listPosition + i < notYetRunList.size(); i++)
                    {
                        m_displayedRunList.add(new TestRunEx(notYetRunList[listPosition + i]));
                    }
                }
                else
                {
                    List<TestRunEx> sortedRuns = new List<TestRunEx>();
                    String order = ordering;
                    if(order == null)
                    {
                        order = 'targetDate';
                    }
        
                    if(ascending)
                    {
                        sortedRuns = sortRunsAsc(notYetRunList, order);
                    }
                    else
                    {
                        sortedRuns = sortRunsDesc(notYetRunList, order);
                    }
                    
                    Integer listPosition = m_runsPerPage * m_testRunPage;
                    
                    for(Integer i = 0; i < m_runsPerPage && listPosition + i < sortedRuns.size(); i++)
                    {
                        m_displayedRunList.add(sortedRuns[listPosition + i]);
                    }
                }
            }
            
            return m_displayedRunList;
        }
        
        set;
    }
    
    private List<TestRunEx> sortRunsAsc(List<Test_Run__c> testRuns, String orderBy)
    {
        List<TestRunEx> sortedRuns = new List<TestRunEx>();
        
        for(Test_Run__c newRun : testRuns)
        {
            Boolean placed = false;
            
            for(Integer i = 0; i < sortedRuns.size() && !placed; i++)
            {
                if(orderBy == 'targetDate')
                {
                    if(newRun.Target_Completion_Date__c < sortedRuns[i].testRun.Target_Completion_Date__c )
                    {
                        sortedRuns.add(i, new TestRunEx(newRun));
                        placed = true;
                    }
                }
                else if(orderBy == 'id')
                {
                    if(newRun.Name.toLowerCase() < sortedRuns[i].testRun.Name.toLowerCase())
                    {
                        sortedRuns.add(i, new TestRunEx(newRun));
                        placed = true;
                    }
                }
                else if(orderBy == 'testObjective')
                {
                    if(newRun.Test_Case__r.Test_Objective__c < sortedRuns[i].testRun.Test_Case__r.Test_Objective__c)
                    {
                        sortedRuns.add(i, new TestRunEx(newRun));
                        placed = true;
                    }
                }
                else if(orderBy == 'runParams')
                {
                    if(newRun.Parameters__c < sortedRuns[i].testRun.Parameters__c)
                    {
                        sortedRuns.add(i, new TestRunEx(newRun));
                        placed = true;
                    }
                }
                else if(orderBy == 'function')
                {
                    if(newRun.Test_Case__r.Function_PL__c < sortedRuns[i].testRun.Test_Case__r.Function_PL__c)
                    {
                        sortedRuns.add(i, new TestRunEx(newRun));
                        placed = true;
                    }
                }
                else if(orderBy == 'subfunction')
                {
                    if(newRun.Test_Case__r.Subfunction_PL__c < sortedRuns[i].testRun.Test_Case__r.Subfunction_PL__c)
                    {
                        sortedRuns.add(i, new TestRunEx(newRun));
                        placed = true;
                    }
                }
                else if(orderBy == 'testCaseId')
                {
                    if(newRun.Test_Case__r.Name < sortedRuns[i].testRun.Test_Case__r.Name)
                    {
                        sortedRuns.add(i, new TestRunEx(newRun));
                        placed = true;
                    }
                }
            }
            if(placed == false)
            {
                sortedRuns.add(new TestRunEx(newRun));
            }
        }
        
        return sortedRuns;
    }

    private List<TestRunEx> sortRunsDesc(List<Test_Run__c> testRuns, String orderBy)
    {
        List<TestRunEx> sorted = sortRunsAsc(testRuns, orderBy);
        
        for(Integer i = 0; i < sorted.size()-1; i++)
        {
            TestRunEx removed = sorted.remove(sorted.size()-1);
            sorted.add(i, removed);
        }
        
        return sorted;
    }
    
    private List<Test_Run__c> m_notYetRunList;
    public List<Test_Run__c> notYetRunList
    {
        get
        {
            if(m_notYetRunList == null)
            {
                m_notYetRunList = [select Id, 
                                      Name, 
                                      Test_Case__c, 
                                      Product_Version_PL__c,
                                      Product_Patch__c,
                                      Result__c,
                                      Notes__c,
                                      Test_Case__r.Test_Objective__c,
                                      Test_Case__r.Product_Family_PL__c,
                                      Test_Case__r.Product_Area_PL__c,
                                      Test_Case__r.Priority__c,
                                      Test_Case__r.Function_PL__c,
                                      Test_Case__r.Subfunction_PL__c,
                                      Test_Case__r.Name,
                                      Target_Completion_Date__c,
                                      Parameters__c
                                from Test_Run__c
                                where Assigned_To__c = :testerId
                                    and Result__c = 'Not yet run'
                                order by Target_Completion_Date__c asc nulls last, 
                                         Function__c asc, Subfunction__c asc,
                                         Name asc];
            }
            return m_notYetRunList;
        }
    }
    
    public void sortTestRuns(String orderBy)
    {
        m_displayedRunList = null;
        if(ordering == orderBy)
        {
            ascending = !ascending;
        }
        else
        {
            ascending = true;
        }
        ordering = orderBy;
        
        saveSortingPreferences();
        
        unsorted = false;
    }
    
    public void saveSortingPreferences()
    {
        CR_Version_Task_Group_Member__c tempMember;
        try
        {                
            tempMember = 
                [select id, row_display_limit__c 
                from CR_Version_Task_Group_Member__c where member__c =: userInfo.getUserId()]; 
        }
        catch(Exception e)
        {
            //  do nothing if it fails
            return;
        }
        
        if (tempMember != null)
        {
            tempMember.Sort_Tests_Ascending__c = ascending;
            tempMember.Test_Sorting_Preference__c = ordering;
            try
            {
                update tempMember;
            }   
            catch(Exception e)
            {
                //  do nothing if it fails
                return ;
            }
        }
    }
    
    public void sortRunsById()
    {
        sortTestRuns('Id');
    }
    
    public void sortRunsByTargetDate()
    {
        sortTestRuns('targetDate');
    }
    
    public void sortRunsByObjective()
    {
        sortTestRuns('testObjective');
    }
    
    public void sortRunsByParameters()
    {
        sortTestRuns('runParams');
    }
    
    public void sortRunsByFunction()
    {
        sortTestRuns('function');
    }
    
    public void sortRunsBySubfunction()
    {
        sortTestRuns('subfunction');
    }
    
    public void sortRunsByTestCase()
    {
        sortTestRuns('testCaseId');
    }
    


    public List<TestCaseEx> testCaseList
    {
        get
        {
            List<TestCaseEx> m_testCaseList = new List<TestCaseEx>();
            List<Test_Case__c> testCases = new List<Test_Case__c>();
            testCases = [select Id, 
                                Name,
                                Approval_Status__c,
                                Test_Objective__c,
                                Product_Area_PL__c,
                                Function_PL__c,
                                Subfunction_PL__c,
                                Product_Family_PL__c,
                                Reviewer_Id__r.Name 
                         from Test_Case__c 
                         where CreatedById = :testerId 
                            and Approval_Status__c != 'Approved'
                            and Approval_Status__c != 'Not submitted'];
            for(Test_Case__c testCase : testCases)
            {
                m_testCaseList.add(new TestCaseEx(testCase));
            }
            return m_testCaseList;
        }
    }
    
    public List<Test_Case__c> testCasesToReview
    {
        get
        {
            return [select Id, 
                      Name,
                      Test_Objective__c,
                      CreatedBy.Name,
                      Approval_Status__c
                    from Test_Case__c 
                    where Reviewer_Id__c = :testerId 
                        and (Approval_Status__c = 'Awaiting approval' 
                        or Approval_Status__c = 'Rework complete')];

        }
    }
    
    
    // Visualforce Event Handlers
    
    public PageReference onDisplayLimitChange()
    {
        //  since the user has requested a limit change, we will query the cr version task
        //  member record, and assign the current limit to be their new row display limit
        if (displayLimit != null)
        {
            //  this is not coming over to mibos: CRDeveloperTaskViewController.saveNewDisplayLimitOnTaskGroupMemberRecord(displayLimit);
        }
        
        m_displayedRunList = null;
        m_testRunPage = 0;
        
        return null;
    }
    
    public PageReference onDeveloperChange()
    {
        resetCachedProperties();
        return null;
    }
    
    public PageReference refresh()
    {
        return null;
    }
    
    //
    // Saves changes to the Target Run Date on assigned test runs
    //
    public void saveRunTargetChanges()
    {
        for(TestRunEx testRun : displayedRunList)
        {
            if(testRun.OriginalTargetRunDate != testRun.testRun.Target_Completion_Date__c)
            {
                update testRun.testRun;
            }
        }
        
        m_displayedRunList = null;
        m_notYetRunList = null;
        //m_blockedRunList = null;
    }
    
    //
    // Saves changes to the Target Run Date on blocked test runs
    //
    public void saveBlockedRunTargetChanges()
    {
        for(TestRunEx testRun : displayedBlockedRuns)
        {
            if(testRun.OriginalTargetRunDate != testRun.testRun.Target_Completion_Date__c)
            {
                update testRun.testRun;
            }
        }
        
        m_blockedRunList = null;
        //m_notYetRunList = null;
        m_displayedBlockedRuns = null;
    }
    
    //
    // Cancels changes to Target Run Dates for either test run list.
    // Just causes both lists to be re-read from the database.
    //
    public PageReference cancelRunTargetChanges()
    {
        m_notYetRunList = null;
        m_blockedRunList = null;
        return null;
    }
    
    private void resetCachedProperties()
    {
        m_tester = null;
    }
    
    public static String cvtToText(Integer count)
    {
        if (count == 0)
        {
            return '-';
        }
        else
        {
            return String.valueOf(count);
        }
    }
        
    // --------------------------------------------------------------------------------
    // Inner Classes
    
    //
    // Class for holding statistics on test cases and test runs
    // 
    public class TestCaseScorecardStats
    {
        public Integer numSubmitted {get; set;}
        public Integer numApproved {get; set;}
        public Integer numNeedRework {get; set;}
        public Integer numCasesRun {get; set;}
        public Integer numPassed {get; set;}
        public Integer numFailed {get; set;}
        public Integer numBlocked {get; set;}
        public Integer numReviewed {get; set;}
        public Integer numPending {get; set;}
        public Integer numRunsForWeek {get; set;}
        
        public String numSubmittedTxt {get{return cvtToText(numSubmitted);}}
        public String numFailedTxt {get{return cvtToText(numFailed);}}
        public String numPassedTxt {get{return cvtToText(numPassed);}}
        public String numBlockedTxt {get{return cvtToText(numBlocked);}}
        public String numApprovedTxt {get{return cvtToText(numApproved);}}
        public String numReviewedTxt {get{return cvtToText(numReviewed);}}
        public String numNeedReworkTxt {get{return cvtToText(numNeedRework);}}
        public String numPendingTxt {get{return cvtToText(numPending);}}
        public String numCasesRunTxt {get{return cvtToText(numCasesRun);}}
        public String numRunsForWeekTxt {get{return cvtToText(numRunsForWeek);}}
    }
    
    //
    // Class for holding Change Request statistics
    // 
    public class ScorecardStats
    {
        public Integer numRejectedPoor {get; set;}
        public Integer numRejectedOther {get; set;}
        public Integer numNeedInfo {get; set;}
        public Integer numFailed {get; set;}
        public Integer numSubmitted {get; set;}
        public Integer numVersionsPassed {get; set;}
        public Integer numVersionsClosed {get; set;}
        public Integer numCustomerDefectsSubmitted {get; set;}
        
        public String numRejectedPoorTxt {get{return cvtToText(numRejectedPoor);}}
        public String numRejectedOtherTxt {get{return cvtToText(numRejectedOther);}}
        public String numNeedInfoTxt {get{return cvtToText(numNeedInfo);}}
        public String numFailedTxt {get{return cvtToText(numFailed);}}
        public String numSubmittedTxt {get{return cvtToText(numSubmitted);}}
        public String numVersionsPassedTxt {get{return cvtToText(numVersionsPassed);}}
        public String numVersionsClosedTxt {get{return cvtToText(numVersionsClosed);}}
        public String numCustomerDefectsSubmittedTxt {get{return cvtToText(numCustomerDefectsSubmitted);}}
    }
    
    //
    // Class to extend the Test Run with a CSS style property
    //
    public class TestRunEx
    {
        public TestRunEx(Test_Run__c tr)
        {
            testRun = tr;
            originalTargetRunDate = tr.Target_Completion_Date__c;
        }
        
        public Test_Run__c testRun {get; set;}
        
        public Datetime originalTargetRunDate {get; set;}
        
        // CSS style that colors Test Runs that need attention
        public String Style
        {
            get
            {
                if(testRun.Target_Completion_Date__c < System.today())
                {
                    return 'background-color:crimson;';
                }
                else if(testRun.Result__c == 'Blocked')
                {
                    return 'background-color:dodgerblue';
                }
                else
                {
                    return '';
                }
            }
        }
    }
    
    //
    // Class to extend the Test Case with a CSS style property
    //
    public class TestCaseEx
    {
        public TestCaseEx(Test_Case__c tc)
        {
            testCase = tc;
        }
        
        public Test_Case__c testCase {get; set;}
        
        // CSS style that colors Test Cases that need attention
        public String Style
        {
            get
            {
                if(testCase.Approval_Status__c == 'Rework needed')
                {
                    return 'background-color:crimson;';
                }
                else
                {
                    return '';
                }
            }
        }
    }
    /*
    public class CRVersionEx
    {
        public CRVersionEx(CR_Version__c crVersion, ID testerId)
        {
           m_crVersion = crVersion;   
           m_testerId = testerId;
           propagation = false;
        }
        
        private CR_Version__c m_crVersion = null;
        private ID m_testerId = null;
        private Date m_startOfWeek = null;
        
         //propagation is true if the crVersion is for the same Change Request as a
         //crVersion that was previously added to the display list.
       
        public Boolean propagation {get; set;}

        
        public CR_Version__c crVersion
        {
            get
            {
                return m_crVersion;
            }
        } 
        
        public String versionStatusStyle
        {
            get
            {
                if (m_crVersion.Status__r.Rejected__c == true)
                {
                    return 'background-color:red;';     
                }
                else if (m_crVersion.Status__r.Name == 'Need Info')
                {
                    return 'background-color:yellow;';
                }
                else if (m_crVersion.Status__r.Name == 'Testing' &&
                         m_crVersion.Testing_Resource__c == m_testerId)
                {
                    return 'background-color:green;';
                }
                else
                {
                    return '';
                }
            }
        }
        
        public Boolean customerFound
        {
            get
            {
                return crVersion.Customer_Found__c == 'True';
            }
            
            set;
        }
        
        public Date startOfWeek()
        {
            if (m_startOfWeek == null)
            {
                m_startOfWeek = Date.today().toStartOfWeek().addDays(1); // Monday of current week.
            }   
            
            return m_startOfWeek;
        }
    }
    */
    
}