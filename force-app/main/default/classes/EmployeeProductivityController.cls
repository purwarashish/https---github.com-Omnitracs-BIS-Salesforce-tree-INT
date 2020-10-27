/*******************************************************************************
 * File:  EmployeeProductivity.cls
 * Date:  August 10, 2015
 * Author:  Joseph Hutchins
 *
 * Modifier : Abhishek Dey
 * Date : 2/5/2015
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
public class EmployeeProductivityController
{
    
    public EmployeeProductivityController()
    {
        init();
    }
    //  **********  GETTERS AND SETTERS  *********
    public boolean isLead
    {
        get
        {
            return TimeCardExtension.isCustomerSupportLead(loggedInUser.Profile.name);
        }
    }
    public User loggedInUser
    {
        get
        {
            if (loggedINuser == null)
            {
                loggedInUser = [select id, name, profile.name, business_unit__c from User where id =: userInfo.getUserId()];
            }
            return loggedInUser;
        }
        set;
    }
    
    public Case_Team__c loggedInUserCaseTeam
    {
        get
        {
            if (loggedInUserCaseTeam == null)
            {
                loggedInuserCaseTeam = [select id, business_unit__c, group_name__c, user__c, user__r.name 
                    from Case_Team__c where user__c =: loggedInuser.id  order by lastmodifieddate limit 1];
            }
            return loggedInUserCaseTeam;
            
        }
        set;
    }
    
    public Time_Card__c timeCardForBeginDateOnly{get;set;}
    public Time_Card__c timeCardForEndDateOnly{get;set;}
  
    public string businessUnitUserChoice{get;set;}

    public List<Case_Team__c> caseTeamREcords{get;set;}
    public string variablePageBlockSectionTitle
    {
        get
        {
            //  makesiaah (and testing shows steve does also) 
            // has case team users who belong to both omni and xrs so we need the label of that table to differ depening on the bu
            // that is picked
            if (businessUnitUserChoice == 'All')
            {
                return 'Omnitracs / XRS';
            }
            if (businessUnitUserChoice == 'Omnitracs')
            {
                return 'Omnitracs';
            }
            if (businessUnitUserChoice == 'XRS')
            {
                return 'XRS';
            }
            return 'Omnitracs';//  by default
        }
    }
    public string managerUserChoice{get;set;}
    private transient List<Employee_Productivity__c> m_roadnetPrimarySupport;
    
    public  List<Employee_Productivity__c>  roadnetPrimarySupport
    {
        get
        {
            m_roadnetPrimarySupport = new List<Employee_Productivity__c>();
            for (Case_Team__c ct : summedEpRecords.keySet())
            {
                if (ct.group_name__c == 'Primary Support')
                {
                    m_roadnetPrimarySupport.add(summedEpRecords.get(ct));
                }
             }
            //  need to add an average row and total row, doing total FIRST then will add average
            m_roadnetPrimarySupport.addAll(computeTotalAndAverageRecords(m_roadnetPrimarySupport));
             return m_roadnetPrimarySupport;
        }
    }
    
    private transient List<Employee_Productivity__c> m_roadnetStrategicSupport;
    public  List<Employee_Productivity__c>  roadnetStrategicSupport
    {
        get
        {
            m_roadnetStrategicSupport = new List<Employee_Productivity__c>();
            for (Case_Team__c ct : summedEpRecords.keySet())
            {
                if (ct.group_name__c == 'Strategic Support')
                {
                    m_roadnetStrategicSupport.add(summedEpRecords.get(ct));
                }
            }
            m_roadnetStrategicSupport.addAll(computeTotalAndAverageRecords(m_roadnetStrategicSupport));
            return m_roadnetStrategicSupport;
        }
    }
    private transient List<Employee_Productivity__c> m_RobinsonTier1;
    public List<Employee_Productivity__c>  RobinsonTier1
    {
        get
        {
            m_RobinsonTier1 = new List<Employee_Productivity__c>();
            for (Case_Team__c ct : summedEpRecords.keySet())
            {
                if (ct.Lead__c != null && 
                    ct.group_name__c == 'Tier 1' && 
                    ct.Lead__r.Name == 'Makeissah Robinson')
                {
                    m_RobinsonTier1.add(summedEpRecords.get(ct));
                }
            }
            m_RobinsonTier1.addAll(computeTotalAndAverageRecords(m_RobinsonTier1));
            util.debug('size of m_RobinsonTier1 = ' + m_RobinsonTier1.size());
            return m_RobinsonTier1;
        }
    }
    
    private transient List<Employee_Productivity__c> m_RobinsonTier2;
    public List<Employee_Productivity__c>  RobinsonTier2
    {
        get
        {
            m_RobinsonTier2 = new List<Employee_Productivity__c>();
            for (Case_Team__c ct : summedEpRecords.keySet())
            {
                if (ct.Lead__c != null && 
                    ct.group_name__c == 'Tier 2' && 
                    ct.Lead__r.Name == 'Makeissah Robinson')
                {
                    m_RobinsonTier2.add(summedEpRecords.get(ct));
                }
            }
            m_RobinsonTier2.addAll(computeTotalAndAverageRecords(m_RobinsonTier2));
            util.debug('size of m_RobinsonTier2 = ' + m_RobinsonTier2.size());
            return m_RobinsonTier2;
        }
    }
    private transient List<Employee_Productivity__c> m_loweTier1;
    public List<Employee_Productivity__c>  loweTier1
    {
        get
        {
            m_loweTier1 = new List<Employee_Productivity__c>();
            for (Case_Team__c ct : summedEpRecords.keySet())
            {
                if (ct.Lead__c != null && 
                    ct.group_name__c == 'Tier 1' && 
                    ct.Lead__r.Name == 'Marcus Lowe')
                {
                    m_loweTier1.add(summedEpRecords.get(ct));
                }
            }
            m_loweTier1.addAll(computeTotalAndAverageRecords(m_loweTier1));
            util.debug('size of m_loweTier1 = ' + m_loweTier1.size());
            return m_loweTier1;
        }
    }
    
    private transient List<Employee_Productivity__c> m_loweTier2;
    public List<Employee_Productivity__c>  loweTier2
    {
        get
        {
            m_loweTier2 = new List<Employee_Productivity__c>();
            for (Case_Team__c ct : summedEpRecords.keySet())
            {
                if (ct.Lead__c != null && 
                    ct.group_name__c == 'Tier 2' && 
                    ct.Lead__r.Name == 'Marcus Lowe')
                {
                    m_loweTier2.add(summedEpRecords.get(ct));
                }
            }
            m_loweTier2.addAll(computeTotalAndAverageRecords(m_loweTier2));
            util.debug('size of m_loweTier2 = ' + m_loweTier2.size());
            return m_loweTier2;
        }
    }
    private transient List<Employee_Productivity__c> m_featherTier1;
    public List<Employee_Productivity__c>  featherTier1
    {
        get
        {
            m_featherTier1 = new List<Employee_Productivity__c>();
            for (Case_Team__c ct : summedEpRecords.keySet())
            {
                if (ct.Lead__c != null && 
                    ct.group_name__c == 'Tier 1' && 
                    ct.Lead__r.Name == 'Michael Feathers')
                {
                    m_featherTier1.add(summedEpRecords.get(ct));
                }
            }
            m_featherTier1.addAll(computeTotalAndAverageRecords(m_featherTier1));
            util.debug('size of m_featherTier1 = ' + m_featherTier1.size());
            return m_featherTier1;
        }
    }
    
    private transient List<Employee_Productivity__c> m_featherTier2;
    public List<Employee_Productivity__c>  featherTier2
    {
        get
        {
            m_featherTier2 = new List<Employee_Productivity__c>();
            for (Case_Team__c ct : summedEpRecords.keySet())
            {
                if (ct.Lead__c != null && 
                    ct.group_name__c == 'Tier 2' && 
                    ct.Lead__r.Name == 'Michael Feathers')
                {
                    m_featherTier2.add(summedEpRecords.get(ct));
                }
            }
            m_featherTier2.addAll(computeTotalAndAverageRecords(m_featherTier2));
            util.debug('size of m_featherTier2 = ' + m_featherTier2.size());
            return m_featherTier2;
        }
    }
    
    private transient List<Employee_Productivity__c> m_jacobsTier0;
    public List<Employee_Productivity__c>  jacobsTier0
    {
        get
        {
            m_jacobsTier0 = new List<Employee_Productivity__c>();
            for (Case_Team__c ct : summedEpRecords.keySet())
            {
                if (ct.Lead__c != null && 
                    ct.group_name__c == 'Tier 0' && 
                    ct.Lead__r.Name == 'Scott Jacobs')
                {
                    m_jacobsTier0.add(summedEpRecords.get(ct));
                }
            }
            m_jacobsTier0.addAll(computeTotalAndAverageRecords(m_jacobsTier0));
            util.debug('size of m_jacobsTier0 = ' + m_jacobsTier0.size());
            return m_jacobsTier0;
        }
    }
    
    private transient List<Employee_Productivity__c> m_jacobsTier1;
    public List<Employee_Productivity__c>  jacobsTier1
    {
        get
        {
            m_jacobsTier1 = new List<Employee_Productivity__c>();
            for (Case_Team__c ct : summedEpRecords.keySet())
            {
                if (ct.Lead__c != null && 
                    ct.group_name__c == 'Tier 1' && 
                    ct.Lead__r.Name == 'Scott Jacobs')
                {
                    m_jacobsTier1.add(summedEpRecords.get(ct));
                }
            }
            m_jacobsTier1.addAll(computeTotalAndAverageRecords(m_jacobsTier1));
            util.debug('size of m_jacobsTier1 = ' + m_jacobsTier1.size());
            return m_jacobsTier1;
        }
    }
    
    private transient List<Employee_Productivity__c> m_jacobsTier2;
    public List<Employee_Productivity__c>  jacobsTier2
    {
        get
        {
            m_jacobsTier2 = new List<Employee_Productivity__c>();
            for (Case_Team__c ct : summedEpRecords.keySet())
            {
                if (ct.Lead__c != null && 
                    ct.group_name__c == 'Tier 2' && 
                    ct.Lead__r.Name == 'Scott Jacobs')
                {
                    m_jacobsTier2.add(summedEpRecords.get(ct));
                }
            }
            m_jacobsTier2.addAll(computeTotalAndAverageRecords(m_jacobsTier2));
            util.debug('size of m_jacobsTier2 = ' + m_jacobsTier2.size());
            return m_jacobsTier2;
        }
    }

    private transient List<Employee_Productivity__c> m_bolhmanTier1;
    public List<Employee_Productivity__c>  bolhmanTier1
    {
        get
        {
            m_bolhmanTier1 = new List<Employee_Productivity__c>();
            for (Case_Team__c ct : summedEpRecords.keySet())
            {
                if (ct.Lead__c != null && 
                    ct.group_name__c == 'Tier 1' && 
                    ct.Lead__r.Name == 'Steve Bohlman')
                {
                    m_bolhmanTier1.add(summedEpRecords.get(ct));
                }
            }
            m_bolhmanTier1.addAll(computeTotalAndAverageRecords(m_bolhmanTier1));
            util.debug('size of m_bolhmanTier1 = ' + m_bolhmanTier1.size());
            return m_bolhmanTier1;
        }
    }
    
    private transient List<Employee_Productivity__c> m_bolhmanTier2;
    public List<Employee_Productivity__c>  bolhmanTier2
    {
        get
        {
            m_bolhmanTier2 = new List<Employee_Productivity__c>();
            for (Case_Team__c ct : summedEpRecords.keySet())
            {
                if (ct.Lead__c != null && 
                    ct.group_name__c == 'Tier 2' && 
                    ct.Lead__r.Name == 'Steve Bohlman')
                {
                    m_bolhmanTier2.add(summedEpRecords.get(ct));
                }
            }
            m_bolhmanTier2.addAll(computeTotalAndAverageRecords(m_bolhmanTier2));
            util.debug('size of m_bolhmanTier2 = ' + m_bolhmanTier2.size());
            return m_bolhmanTier2;
        }
    }    
    
    //  **********  PUBLIC METHODS  *********
    public PageReference refresh()
    {
        m_roadnetPrimarySupport = new List<Employee_Productivity__c>();
        m_roadnetStrategicSupport = new List<Employee_Productivity__c>();
        m_RobinsonTier1 = new List<Employee_Productivity__c>();
        m_RobinsonTier2 = new List<Employee_Productivity__c>();
        m_loweTier1 = new List<Employee_Productivity__c>();
        m_loweTier2 = new List<Employee_Productivity__c>();
        
        m_featherTier1 = new List<Employee_Productivity__c>();
        m_featherTier2 = new List<Employee_Productivity__c>();
        
        m_jacobsTier1 = new List<Employee_Productivity__c>();
        m_jacobsTier2 = new List<Employee_Productivity__c>();
        
        m_bolhmanTier1 = new List<Employee_Productivity__c>();
        m_bolhmanTier2 = new List<Employee_Productivity__c>();
        
    
        system.debug('ctrlf  ***************** refresh called. cpu time: ' + limits.getCpuTime());
       if (isLead)
       {
            if (loggedInUserCaseTeam != null)
            {
                system.debug('ctrlf  ***************** about to call createCaseTeamTableRecords cpu time: ' + limits.getCpuTime());
                createCaseTeamTableRecords();
                system.debug('ctrlf  ***************** createCaseTeamTableRecords method finished executing cpu time: ' + limits.getCpuTime());
            }
            else
            {
                throw new myexception('Case Team record could not be found for current user');
            }
       }
       else
       {
            //  query the case team record of the user
            //  query ep records of the case team user
            //  construct the ep record live data
            //  construc the tables/compoenents
       }
       
       system.debug('ctrlf  ***************** refresh method call complete. cpu time: ' + limits.getCpuTime());
       return null;
        
    }
   
    public PageReference verifyUserIsApartOfCaseTeam()
    {
        //  security to the page will be set by the vf page security but just in case a non support user
        //  gets access to the page, we at the very min want to check that the user is on a case team before we allow viewing
        //  same goes for the time card page
        Case_Team__c tempCaseTeam;
        try
        {
           tempCaseTeam = [select id from Case_Team__c where user__c =: userInfo.getUserId() limit 1];
        }
        catch(Exception e)
        {
            
        }
        if (tempCaseTeam != null)
        {
           return null;
        }
        else
        {
            return Page.InsufficientPrivileges;
        }
    }
    private void createCaseTeamTableRecords()
    {
        util.debug('inside of createCaseTeamTableRecords');
        summedEpRecords = new Map<Case_Team__c, Employee_Productivity__c>();//  clear the table
        
        if (businessUnitUserChoice == 'All')
        {
            caseTeamRecords = [select id, business_unit__c, group_name__c, user__c, user__r.name, lead__c, lead__r.name from Case_Team__c order by user__r.lastname asc];
        }
        else
        {
            //  query the case team records of the users business unit
            caseTeamRecords = [select id, business_unit__c, group_name__c, user__c, user__r.name, lead__c, lead__r.name from Case_Team__c 
                where Business_unit__c =: businessUnitUserChoice order by user__r.lastname asc];
        }
        
        util.debug('businessUnitUserChoice: ' + businessUnitUserChoice + ' num of records returned: ' + (caseTeamREcords == null ? 0 : caseTeamRecords.size() )) ;
      
        //  query ep records of the case teams, with the specified begin and end date
        employeeProdRecords = queryEmployeeProdRecords(caseTeamRecords, timeCardForBeginDateOnly.Week_Begin__c, timeCardForEndDateOnly.Week_Begin__c);
       
        
        if (employeeProdRecords == null || employeeProdRecords.size() == 0)
        {
            return;//  if no records found, there is nothing to do 
        }
        
        util.debug('query for emp prod records complete:  num returned: ' + (employeeProdRecords == null ? 0 : employeeProdRecords.size()) );
        
        system.assertNotEquals(null, employeeProdrecords);
        system.assertNotEquals(null, caseTeamRecords);
             
        //  now cursor thru the map, creating a new map which contains the summatino of all ep records for each case team
        for (Case_Team__c ct : caseTeamRecords)
        {
            //  for each case team, scroll thru their emp prod records and create the summed  emp record
            List<Employee_Productivity__c> epRecordsOfCaseTeam = retrieveEpRecords(ct.id, employeeProdRecords);//caseTeamEmpProdMap.get(ct);
            Employee_Productivity__c summedRecord = new Employee_Productivity__c();
            
            
            //Abhishek Added
            Integer availableHours = retrieveNumOfAvailableHours(timeCardForBeginDateOnly.Week_Begin__c, timeCardForEndDateOnly.Week_Begin__c);
            
            util.debug('availableHours***'+ availableHours);
            
            Decimal workDay = 0; 
            
            nullOutEmpRecordFields(summedRecord);
            
            summedRecord = sumEpRecords(summedRecord, epRecordsOfCaseTeam);
            
            Decimal workHours = availableHours - Math.roundToLong(summedrecord.Absence_Time_Sum_All__c);
            workDay = (workHours/450);
                        
            // This workDay and workHours are used specifically for the calculations of 'Case Activity By Work Day ' and 'Closed Cases Per Work Day'
            
            summedrecord.name = ct.User__r.Name;
            
            if(workDay != 0){
            summedrecord.Case_Activity_by_Day__c = nullToZero(summedrecord.Case_Activity_by_Day__c/workDay) ;
            summedRecord.Closed_Cases_By_Day__c = nullToZero(summedRecord.Closed_Cases_By_Day__c/workDay); 
            } 
             
            if(summedrecord.Hours_Worked__c != 0) {
            double workHoursForUtilization = ((summedrecord.Hours_Worked__c*60) - summedrecord.Absence_Time_Sum_All__c) ; // Calculated in minutes
             
            summedrecord.Utilization_Rate_Overall_Sum__c = nullToZero(summedrecord.Case_Work_Time__c/(summedrecord.Hours_Worked__c*60))*100; // Utilization Rate (Pure Case Time) Sum            
            if(workHoursForUtilization != null && workHoursForUtilization > 0){
                summedrecord.Utilization_Work_Minutes_Time_Card_Sum__c = nullToZero((summedrecord.Case_Work_Time__c + summedrecord.Non_Case_Time_TC_Subtractors__c )/workHoursForUtilization)*100; // Utilization Work Minutes Time Card Sum
            }
            }
            summedEpRecords.put(ct, summedRecord);//  this is the map that will be shown on the table
         }
    }
    
   
    
    private static List<Employee_Productivity__c> computeTotalAndAverageRecords(List<Employee_Productivity__c> totalRecordList)
    {
        Employee_Productivity__c totalRecord = new Employee_Productivity__c();
        totalRecord.Name = 'Total';
        nullOutEmpRecordFields(totalRecord);
        
        integer caseActivityByDayCounter = 0;
        integer caseEventsCounter = 0;
        integer casesClosedCounter = 0;
        integer casesOpenedCounter = 0;
        integer caseWorkTimeCounter = 0;
        integer closedCasesByDayCounter = 0;
        integer totalCasesWorkedOnCounter = 0;
        integer nonCaseTimeCounter = 0;
        integer absenceTimeCounter = 0;
        integer engineeringCasesOpenedCounter = 0;
        integer articlesLinkedCounter = 0;
        integer articlesCreatedCounter = 0;
        
        integer UtilizationRaterOverallSumCounter = 0;
        integer UtilizationWorkMinutesTimeCardSumCounter = 0;
        Decimal TotalUtilizationRaterOverallSum = 0;
        Decimal TotalUtilizationWorkMinutesTimeCardSum = 0;
        
        for (Employee_Productivity__c ep : totalRecordList)
        {
         if (nullToZero(ep.Case_Activity_by_Day__c) != 0)
            {
                caseActivityByDayCounter++;
            }
            totalRecord.Case_Activity_by_Day__c += nullToZero(ep.Case_Activity_by_Day__c);
            
            if (nullToZero(ep.case_events__c) != 0)
            {
                caseEventsCounter++;
            }
            totalRecord.case_events__c += nullToZero(ep.case_events__c);
            
            if (nullToZero(ep.Cases_Closed__c) != 0)
            {
                casesClosedCounter++;
            }
            totalRecord.Cases_Closed__c += nullToZero(ep.Cases_Closed__c);
            
            if (nullToZero(ep.Cases_Opened__c) != 0)
            {
                casesOpenedCounter++;
            }
            totalRecord.Cases_Opened__c += nullToZero(ep.Cases_Opened__c);
            
            if (nullToZero(ep.Case_Work_Time__c) != 0)
            {
                caseWorkTimeCounter++;
            }
            totalRecord.Case_Work_Time__c += nullToZero(ep.Case_Work_Time__c);
            
            if (nullToZero(ep.Closed_Cases_By_Day__c) != 0)
            {
                closedCasesByDayCounter++;
            }
            totalRecord.Closed_Cases_By_Day__c += nullToZero(ep.Closed_Cases_By_Day__c);

            if (nullToZero(ep.Total_Cases_Worked_On__c) != 0)
            {
                totalCasesWorkedOnCounter++;
            }
            totalRecord.Total_Cases_Worked_On__c += nullToZero(ep.Total_Cases_Worked_On__c);
            
            //  start of copy pasting the new columns
            if (nullToZero(ep.Non_Case_Time_TC_Subtractors__c) != 0)
            {
                nonCaseTimeCounter++;
            }
            totalRecord.Non_Case_Time_TC_Subtractors__c += nullToZero(ep.Non_Case_Time_TC_Subtractors__c);
            
            if (nullToZero(ep.Absence_Time_Sum_All__c) != 0)
            {
                absenceTimeCounter++;
            }
            totalRecord.Absence_Time_Sum_All__c += nullToZero(ep.Absence_Time_Sum_All__c);
            
            if (nullToZero(ep.Engineering_Cases_Opened__c) != 0)
            {
                engineeringCasesOpenedCounter++;
            }
            totalRecord.Engineering_Cases_Opened__c += nullToZero(ep.Engineering_Cases_Opened__c);
            
            if (nullToZero(ep.Articles_Linked__c) != 0)
            {
                articlesLinkedCounter++;
            }
            totalRecord.Articles_Linked__c += nullToZero(ep.Articles_Linked__c);
            
            if (nullToZero(ep.Articles_Created__c) != 0)
            {
                articlesCreatedCounter++;
            }
            totalRecord.Articles_Created__c += nullToZero(ep.Articles_Created__c);
            
            
            //  end of copy pasting the new columns
            
            //  when we get here, we are looking at the summedEpRecords, at this point of time, we no longer care about the formula field overall util fields
            //  we only want to look at the sum field
            
            if (nullToZero(ep.Utilization_Rate_Overall_sum__c) != 0)
            {
                UtilizationRaterOverallSumCounter++;
                TotalUtilizationRaterOverallSum = TotalUtilizationRaterOverallSum + ep.Utilization_Rate_Overall_sum__c;
            }
            //totalRecord.Utilization_Rate_Overall_Sum__c += nullToZero(ep.Utilization_Rate_Overall_sum__c);
            
            
            totalRecord.Hours_Worked__c += nullToZero(ep.Hours_Worked__c);
            
            
            if (nullToZero(ep.Utilization_Work_Minutes_Time_Card_sum__c) != 0)
            {
                UtilizationWorkMinutesTimeCardSumCounter++;
                TotalUtilizationWorkMinutesTimeCardSum = TotalUtilizationWorkMinutesTimeCardSum + ep.Utilization_Work_Minutes_Time_Card_sum__c;
            }
            
          
        } 
        
        
        System.debug('totalRecord.Case_Work_Time__c***'+ totalRecord.Case_Work_Time__c);
        System.debug('totalRecord.Hours_Worked__c****'+ totalRecord.Hours_Worked__c);
        
        if((totalRecord.Hours_Worked__c != 0)&&(totalRecord.Case_Work_Time__c != 0))
        {
        //totalRecord.Utilization_Rate_Overall_Sum__c = nullToZero(totalRecord.Case_Work_Time__c/(totalRecord.Hours_Worked__c*60))*100;
        }
                
        
        if((totalRecord.Hours_Worked__c != 0))
        {
        double workHoursForUtilizationTotal = ((totalRecord.Hours_Worked__c*60) - totalRecord.Absence_Time_Sum_All__c);
        //totalRecord.Utilization_Work_Minutes_Time_Card_Sum__c =  nullToZero((totalRecord.Case_Work_Time__c + totalRecord.Non_Case_Time_TC_Subtractors__c )/workHoursForUtilizationTotal )*100;
        }
        
        
        //  now that the total record has been created and couters summed, we'll create the average record with data from the total recor
        Employee_Productivity__c averageRecord = new Employee_Productivity__c();
        averageRecord.name = 'Average';
        
        if (caseActivityByDayCounter == 0)
        {
            averageRecord.Case_Activity_by_Day__c = 0;
        }
        else
        {
            averageRecord.Case_Activity_by_Day__c = (totalRecord.Case_Activity_by_Day__c / caseActivityByDayCounter);
        }
        
        if (caseEventsCounter == 0)
        {
            averageRecord.case_events__c = 0;
        }
        else
        {
            averageRecord.case_events__c = (totalRecord.case_events__c / caseEventsCounter);
        }
        
        if (casesClosedCounter == 0)
        {
            averageRecord.Cases_Closed__c = 0;
        }
        else
        {
            averageRecord.Cases_Closed__c = (totalRecord.Cases_Closed__c / casesClosedCounter);
        }
        
        if (casesOpenedCounter == 0)
        {
            averageRecord.Cases_Opened__c = 0;
        }
        else
        {
            averageRecord.Cases_Opened__c = (totalRecord.Cases_Opened__c / casesOpenedCounter);
        }
        
        if (caseWorkTimeCounter == 0)
        {
            averageRecord.Case_Work_Time__c = 0;
        }
        else
        {
            averageRecord.Case_Work_Time__c = (totalRecord.Case_Work_Time__c / caseWorkTimeCounter);
        }
        
        if (closedCasesByDayCounter == 0)
        {
            averageRecord.Closed_Cases_By_Day__c = 0;
        }
        else
        {
            averageRecord.Closed_Cases_By_Day__c = (totalRecord.Closed_Cases_By_Day__c / closedCasesByDayCounter);
        }
        
        if (totalCasesWorkedOnCounter == 0)
        {
            averageRecord.Total_Cases_Worked_On__c = 0;
        }
        else
        {
            averageRecord.Total_Cases_Worked_On__c = (totalRecord.Total_Cases_Worked_On__c / totalCasesWorkedOnCounter);
        }
        
        
        //  start of copying in the new column logic
        if (nonCaseTimeCounter == 0)
        {
            averageRecord.Non_Case_Time_TC_Subtractors__c = 0;
        }
        else
        {
            averageRecord.Non_Case_Time_TC_Subtractors__c = (totalRecord.Non_Case_Time_TC_Subtractors__c / nonCaseTimeCounter);
        }
        
        if (absenceTimeCounter == 0)
        {
            averageRecord.Absence_Time_Sum_All__c = 0;
        }
        else
        {
            averageRecord.Absence_Time_Sum_All__c = (totalRecord.Absence_Time_Sum_All__c / absenceTimeCounter);
        }

        if (engineeringCasesOpenedCounter == 0)
        {
            averageRecord.Engineering_Cases_Opened__c = 0;
        }
        else
        {
            averageRecord.Engineering_Cases_Opened__c = (totalRecord.Engineering_Cases_Opened__c / engineeringCasesOpenedCounter);
        }
        
        if (articlesLinkedCounter == 0)
        {
            averageRecord.Articles_Linked__c = 0;
        }
        else
        {
            averageRecord.Articles_Linked__c = (totalRecord.Articles_Linked__c / articlesLinkedCounter);
        }

        if (articlesCreatedCounter == 0)
        {
            averageRecord.Articles_Created__c = 0;
        }
        else
        {
            averageRecord.Articles_Created__c = (totalRecord.Articles_Created__c / articlesCreatedCounter);
        }        
        //  end of copying in the new column logic
        if (UtilizationRaterOverallSumCounter == 0)
        {
            averageRecord.Utilization_Rate_Overall_sum__c = 0;
        }
        else
        {
            averageRecord.Utilization_Rate_Overall_sum__c = (TotalUtilizationRaterOverallSum / UtilizationRaterOverallSumCounter);
        }
        
        if (UtilizationWorkMinutesTimeCardSumCounter == 0)
        {
            averageRecord.Utilization_Work_Minutes_Time_Card_sum__c = 0;
        }
        else
        {
            averageRecord.Utilization_Work_Minutes_Time_Card_sum__c = (TotalUtilizationWorkMinutesTimeCardSum / UtilizationWorkMinutesTimeCardSumCounter);
        }  
        
        Employee_Productivity__c[] recordsToREturn = new List<Employee_Productivity__c>();
        recordsToReturn.add(totalRecord);
        recordsToReturn.add(averageRecord);
        return recordsToReturn;
        
    }    
    private static List<Employee_Productivity__c> retrieveEpRecords(id caseTeamId, List<Employee_Productivity__c> epRecords)
    {
        List<Employee_Productivity__c> recordsToReturn = new List<Employee_Productivity__c>();
        for (Employee_Productivity__c ep : epRecords)
        {
            if (ep.CAse_Team__c == caseTeamId)
            {
                recordsToReturn.add(ep);
            }
        }
        return recordsToReturn;
    }
    
    //Abhishek Added
    private static Integer retrieveNumOfAvailableHours( Date startDate , Date endDate )
    {
        Integer count;
        Integer countAvailableHours;
        
        DateTime startDateTime = datetime.newInstance(startDate.year(), startDate.month(),startDate.day());
        DateTime endDateTime = datetime.newInstance(endDate.year(), endDate.month(),endDate.day());
        
        Integer totalnumberDays = startDate.daysBetween(endDate);
        count = (totalnumberDays - countWeekends(startDateTime, endDateTime));
        
        //Available Days * 7.5 hrs * 60 minutes 
        
        countAvailableHours = count*450;
        
        return countAvailableHours;
    }
    
   public static Integer countWeekends(DateTime startDateTime, DateTime endDateTime)
       {
         Integer countDays = 0;
                
         while (startDateTime < endDateTime) {
           if (startDateTime.format('E') == 'Sat' | startDateTime.format('E') == 'Sun'){
             countDays = countDays + 1;
           }
         startDateTime = startDateTime.addDays(1);
         }
         
         return countDays;
       }
        
    //  **********  PRIVATE METHODS  *********
    private void init()
    {
        timeCardForBeginDateOnly = new Time_Card__c();
        timeCardForEndDateOnly = new Time_Card__c();
        timeCardForBeginDateOnly.Week_Begin__c = date.today().toSTartOfWeek();//date.newInstance(2015, 5, 31);//
        timeCardForEndDateOnly.week_begin__c = date.today();
        User tempLoggedInUser = [select id, business_unit__c, profile.name from user where id =: userInfo.getUserId()];
        businessUnitUserChoice = tempLoggedInUser.business_unit__c;
        //defineManagerPicklist();
        managerUserChoice = 'All';
        // need this bool here because class's getters cannot be accesiable in constructor
        boolean tempIsLead = TimeCardExtension.isCustomerSupportLead(tempLoggedInUser.profile.name);
           
    }
    
    private transient List<Employee_Productivity__c> employeeProdRecords{get;set;}
    private transient List<Mibos_Case_Time__c> lstCaseTime{get;set;}
    private Map<Case_Team__c, List<Employee_Productivity__c>> caseTeamEmpProdMap = new Map<Case_Team__c, List<Employee_Productivity__c>>(); 
    private Map<Case_Team__c, Employee_Productivity__c> summedEpRecords = new Map<Case_Team__c, Employee_Productivity__c>();
    
    //  **********  STATIC METHODS  *********
    public static boolean isDebug //  formerly istesting
    {
        get
        {
            return userinfo.getLastName() == 'Hutchins';
            //  there are some fields on the vf page i need to see to confirm the trending are correct 
            //return EmailClass.isUserinSandbox();
        }
    }
/*
    private static boolean isWeekEnd(Date dateToCheck)
    {
        //    Date sunday = dateToCheck.ToStartOfweek();
        //    Date saturday = sunday.AddDays(6);
    
        return ((dateToCheck == dateToCheck.ToStartOfWeek()) || (dateToCheck == dateToCheck.ToStartOfWeek().addDays(6)));
    }
    */
    private static List<Employee_Productivity__c> queryEmployeeProdRecords(Case_Team__c[] caseTeams, Date startDate, Date endDate)
    {
        util.debug('caseteams: ' + (caseteams == null ? 0 : caseteams.size()) + 'start date: ' + startDate + ' enddate: ' + endDate);
        return [Select e.Week_Begin__c,e.Name, e.Total_Cases_Worked_On__c, 
            /*
            e.Survey_Score__c, e.Sick_Time__c, e.Professional_Services_Work_Time__c, e.Personal_Time__c, e.Vacation_Time__c, 
            e.Jury_Duty_Time__c, e.In_Lieu_Days_Time__c, e.Id, e.Holiday_Time__c, e.Employee_Time_In_Office__c, e.Bereavement_Time__c, 
            e.Available_Work_Minutes__c, e.Available_Work_Minutes_Time_Card__c, e.Actual_Work_Minutes__c, e.Actual_Work_Minutes_Time_Card__c, 
            */
            e.Closed_Cases_By_Day__c, e.Cases_Opened__c, e.Utilization_Rate_Overall__c, e.Utilization_Work_Minutes_Time_Card__c,
            e.Cases_Closed__c, e.Case_Work_Time__c, e.Case_Team__c, e.Case_Events__c, e.Case_Activity_by_Day__c, 
            e.Absence_Time_Sum_All__c, e.Articles_Linked__c, e.Articles_Created__c, e.Engineering_Cases_Opened__c,e.Hours_Worked__c, e.Non_Case_Time_TC_Subtractors__c
            From Employee_Productivity__c e
                where Case_Team__c in: caseteams and
                (day__c >=: startDate and day__c <=: endDate)//Abhi's change
                order by day__c desc, Case_Team__r.User__r.LastName asc];
    }
    
    private static Employee_Productivity__c sumEpRecords(Employee_Productivity__c summedRecord, List<Employee_Productivity__c> epRecords)
    {
        decimal surveyScoreSum = 0.0;

        for (Employee_Productivity__c ep : epRecords)
        {
           summedRecord.Case_Activity_by_Day__c += nullToZero(ep.Case_Activity_by_Day__c);
           summedRecord.Case_Events__c += nullToZero(ep.Case_Events__c);
           summedRecord.Cases_Closed__c += nullToZero(ep.Cases_Closed__c);
           summedRecord.Cases_Opened__c += nullToZero(ep.Cases_Opened__c);
           summedRecord.Case_Work_Time__c += nullToZero(ep.Case_Work_Time__c);
           summedRecord.Closed_Cases_By_Day__c += nullToZero(ep.Closed_Cases_By_Day__c);
           summedRecord.Total_Cases_Worked_On__c += nullToZero(ep.Total_Cases_Worked_On__c);
           summedRecord.Absence_Time_Sum_All__c += nullToZero(ep.Absence_Time_Sum_All__c);
           summedRecord.Articles_Created__c += nullToZero(ep.Articles_Created__c);
           summedRecord.Articles_Linked__c += nullToZero(ep.Articles_Linked__c);
           summedRecord.Engineering_Cases_Opened__c += nullToZero(ep.Engineering_Cases_Opened__c);
           summedRecord.Non_Case_Time_TC_Subtractors__c += nullToZero(ep.Non_Case_Time_TC_Subtractors__c);
           summedRecord.Hours_Worked__c += nullToZero(ep.Hours_Worked__c);
           
           
           
           //  we are taking the percentage of each record and adding ito this field
           //  for example if each record is at 100% and the total amount of records = 10, then the sum is going to be 1000
           //  so i tink at the end of the summatoin, we can perform the division and assign it to the fiel
           //summedRecord.Utilization_Rate_Overall_Sum__c += nullToZero(ep.Utilization_Rate_Overall__c);
           //summedRecord.Utilization_Work_Minutes_Time_Card_sum__c += nullToZero(ep.Utilization_Work_Minutes_Time_Card__c);
           
           
           //surveyScoreSum += nullToZero(ep.survey_score__c);
        }
        if (epRecords.size() != 0)
        {
            summedRecord.Utilization_Rate_Overall_Sum__c = summedRecord.Utilization_Rate_Overall_Sum__c / epRecords.size();
            summedRecord.Utilization_Work_Minutes_Time_Card_sum__c = summedRecord.Utilization_Work_Minutes_Time_Card_sum__c / epRecords.size();
        }
        
       
        return summedRecord;
    } 
    private static void nullOutEmpRecordFields(Employee_Productivity__c ep)
    {
        
        ep.Case_Activity_by_Day__c =0;
        ep.case_events__c = 0;
        ep.Cases_Closed__c = 0;
        ep.Cases_Opened__c = 0;
        ep.Case_Work_Time__c = 0;
        ep.Closed_Cases_By_Day__c = 0;
        ep.Absence_Time_Sum_All__c = 0;
        ep.Articles_Created__c = 0;
        ep.Articles_Linked__c = 0;
        ep.Engineering_Cases_Opened__c = 0;
        ep.Non_Case_Time_TC_Subtractors__c = 0;
        ep.Total_Cases_Worked_On__c = 0;
        ep.Hours_Worked__c = 0;
        ep.Utilization_Rate_Overall_sum__c = 0;
        ep.Utilization_Work_Minutes_Time_Card_sum__c = 0;
        
    }
    private static decimal nullToZero(decimal d)
    {
        if (d == null)
        {
            return 0.0;
        }
        else
        {
            return d;
        }
    }
    private static boolean doesContain(string leadId, List<SelectOption> options)
    {
        for (SelectOption so : options)
        {
            if (so.getVAlue() == leadId)
            {
                return true;
            }
        }
        return false;
    }


    public class myException extends Exception{}

}