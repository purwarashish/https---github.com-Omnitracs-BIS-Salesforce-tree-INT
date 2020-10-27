global class batchEmployeeProdCreate implements Database.Batchable<sObject> {

    // Variable declaration..
    
    public static string SECONDS = '0';
    public static string MINUTES = '0';
    public static string HOURS = '1';
    public static string DAY_OF_MONTH = '?';
    public static string MONTH = '*';
    public static string DAY_OF_WEEK= '1';//  sunday
    public Date debugDate;
    public static string TIME_TO_RUN = SECONDS + ', ' + MINUTES + ', ' + HOURS + ', ' + DAY_OF_MONTH + ', ' + MONTH + ', ' + DAY_OF_WEEK;
    public static string NAME_OF_JOB = 'Create Employee Prod Records';
    
    //  global properties
    global Map<Case_Team__c, List<Mibos_Case_Time__c>> caseTeamToCaseTimeMap = new Map<Case_Team__c, List<Mibos_Case_Time__c>>();
    global Map<Case_Team__c, List<Case>> caseTeamToCasesOpenedMap = new Map<Case_Team__c, List<Case>>(); 
    global Map<Case_Team__c, List<Case>> caseTeamToEngineeringCasesOpenedMap = new Map<Case_Team__c, List<Case>>(); 
    global Map<Case_Team__c, List<Case>> caseTeamToCasesClosedMap = new Map<Case_Team__c, List<Case>>(); 
    global Map<Case_Team__c, List<Survey__c>> caseTeamToSurveyMap = new Map<Case_Team__c, List<Survey__c>>();
    global Map<Case_Team__c, List<CaseArticle>> caseTeamToCaseARticleMap = new Map<Case_Team__c, List<CaseArticle>>();
    global Map<Case_Team__c, List<Solution__ka>> caseTeamToSolutionARticleMap = new Map<Case_Team__c, List<Solution__ka>>();
    
    global Map<Case_Team__c, List<Case>> caseTeamToCasesOpenedMap_CaseEvent = new Map<Case_Team__c, List<Case>>();
    global Map<Case_Team__c, List<Case_Event__C>> mapOfCaseTeamCaseEventList = new Map<Case_Team__c, List<Case_Event__C>>();
    
global final Date batchRunningDate;

            global batchEmployeeProdCreate (Date runningDate)
            {
               batchRunningDate = runningDate;
            }  

global Database.QueryLocator start(Database.BatchableContext BC) {

String query = 'select id, business_Unit__c, group_Name__c, user__c, user__r.name from Case_Team__c';
return Database.getQueryLocator(query);

}
global void execute(Database.BatchableContext BC, List<Case_Team__c> scope) {
        
    try{
        set<Id> setId = new set<Id>();
        Date todaysDate = batchRunningDate;
      
        DateTime todaysDateUpperBound = dateTime.newInstance(todaysDate.year(), todaysDate.Month(), TodaysDate.Day(), 23, 59, 59);//this should be today date and time should 23.99.98
        DAteTime todaysDateLowerBound =  datetime.newInstance(todaysDate.year(), todaysDate.Month(), TodaysDate.Day(), 0, 0, 0); //  12:00am
        Date weekBegin = todaysDate.toStartOfWeek();
        
        system.debug('todaysDate: ' + todaysDAte  + ' weekBegin: ' + weekBegin + ' todaysDateLowerBound: ' + todaysDateLowerBound + ' todaysDateUpperBound: ' + todaysDateUpperBound);
       
        String checkDate = '%'+string.valueof(WeekBegin.Month()) + string.valueof(weekBegin.Day()) + string.valueof(WeekBegin.year())+'%';
        
        for( Time_Card_Details__c TcdData : [select id,Hours_Worked__c, Date__c from Time_Card_Details__c where name like : checkDate limit 50000 ])
        {
            if(TcdData.Date__c.Day() == TodaysDate.Day()){
                setId.add(TcdData.id);
                }
        }
        
        if(!setId.isEmpty()){        
        List<Employee_Productivity__c> chkEPListToBedeleted = [Select name, id, Time_Card_Detail__c from Employee_Productivity__c where Time_Card_Detail__c = :setId limit 50000];
        if(!chkEPListToBedeleted.IsEmpty())
           delete  chkEPListToBedeleted ;
        }           
        
//-Abhishek Code End        
                
        //  next we need to query records from the jump before we start making ep records
        //  query all case teams
        List<Case_Team__c> allCaseTeams = scope;
        util.debug('num case teams queried: ' + (allCaseTeams == null ? 0 : allCaseTeams.size()) );
        Set<id> caseTeamUserIds = new set<id>();
        for (Case_Team__c ct : allCaseTeams)
        {
            if (!caseTeamUserIds.contains(ct.user__c))
            {
                caseTeamUserIds.add(ct.user__c);
            }
        }
        
        //  it would benefit us greatly to query the case times records en masse right now,
        List<Mibos_Case_Time__c> allCaseTimes = [select id, name, work_effort__c, Start_Time_Form__c,Case__c,Case__r.CaseNumber, Case_Event__r.name, Owner__c 
            from Mibos_Case_Time__c 
            where 
            //(Case__r.RecordType.Name = 'Call Center' or  Case__r.recordtype.name = 'Engineering Case') and ...John wanted for all Cases. Change came in UAT
            (CreatedDate >=: todaysDateLowerBound AND CreatedDate <=: todaysDateUpperBound) AND
            Owner__c in: caseTeamUserIds];
            
        util.debug('allCaseTimes size = ' + (allCaseTimes == null ? 0 : allCaseTimes.size()));
        //  create the mapping of caes times to user
        createCaseTeamCaseTimeMap(allCaseTeams, allCaseTimes);
        
        //  query the timce cards of all case team members
        List<Time_Card__c> allTimeCards = [Select t.Week_Begin__c, t.User__c,  t.Submitted_By__c, t.Submit_Status__c, t.Submit_Date__c, t.Rejection_Reason__c, t.Rejected_By__c, 
            t.Reject_Date__c, t.OwnerId, t.Name, t.LastModifiedDate, t.LastModifiedById, t.Id,  t.CreatedDate, t.CreatedById,t.Approved_By__c,
            
            //  time card details inner query
            (Select Type__c, Training_Time_Spent__c, Total_Time_Spent__c, Time_Spent__c, Time_Card__c, Project_Time_Spent__c, Name, Meeting_Time_Spent__c, 
            LastModifiedById, Id, Date__c, non_absence_time__c, CreatedDate, CreatedById, Consulting_Time_Spent__c, Comments__c, Administrative_Time_Spent__c, 
            Bereavement_Time_Spent__c, Holiday_Time_Spent__c, In_Lieu_Days_Time_Spent__c, Jury_Duty_Time_Spent__c,Hours_Worked__c,
            Personal_Time_Spent__c, Professional_Services_Work_Time_Spent__c, Sick_Time_Spent__c, Vacation_Time_Spent__c,
             Admin_Time_Spent__c, Absence_Time_Spent__c From Time_Card_Details__r),
             
             
            t.Approval_Date__c
            From Time_Card__c t where user__c =: caseTeamUserIds and 
            week_begin__c =: weekBegin];
            
            util.debug('time cards queried: ' + (allTimeCards == null ? 0 : allTimeCards.size()));
        
          List<Case> casesOpened = [select id, casenumber, recordtype.name, (select id, Assisting_Technician__c, CreatedById from Case_Events__r), ownerid,createdById from case where createdbyid in: caseTeamUserIds AND
           // (recordtype.name = 'Call Center' OR RecordType.Name = 'Engineering Case') AND
            CreatedDate <=: todaysDateUpperBound and CreatedDate >=: todaysDateLowerBound];
        system.debug('cases opened queried: ' + (casesOpened == null ? 0 : casesOpened.size()) );
        createCaseTeamToCasesOpenedMap(allCaseTeams, casesOpened);
        
      
        //The change would be to calculate the number of case events created for the selected date range. It will not be dependent on the case creation date.
        createCaseTeamToCasesOpenedMap_CaseEvent(allCaseTeams,todaysDateUpperBound, todaysDateLowerBound);
       
        
      //Abhishek Change End..  
        
        List<Case> casesClosed = [select id, caseNumber, ownerid,createdById,Closed_By__c from case where Closed_By__c in: caseTeamUserIds and
            ( ClosedDate >=: todaysDateLowerBound and closedDate <=: todaysDateUpperBound)
             //and (RecordType.Name = 'Call Center' OR RecordType.Name = 'Engineering Case') 
            ];
        util.debug('finished querying cases closed: ' + (casesClosed == null ? 0 : casesClosed.size()) );
        createCaseTeamToCasesClosedMap(allCaseTeams, casesClosed);
        
      
        
        List<CaseArticle> caseArticles = [select id,KnowledgeArticleId, case.ownerid from CaseArticle where
            case.ownerid in: caseTeamUserIds AND
            //(case.recordtype.name = 'Call Center' OR Case.RecordType.name = 'Engineering Case') AND
            Createddate <=: todaysDateUpperBound and createdDAte >=: todaysDateLowerBound];
        createCaseTeamToCaseArticleMap(allCaseTeams, caseArticles);
        
        List<Solution__ka> solutionArticles = [select id, createdbyid from Solution__ka  where
            createdbyid in: caseTeamUserIds AND
            Createddate <=: todaysDateUpperBound and createdDAte >=: todaysDateLowerBound];
        createCaseTeamToSolutionArticleMap(allCaseTeams, solutionArticles);
        
        
       List<Employee_Productivity__c> empProdCreate = new list<Employee_Productivity__c>();
       Savepoint sp1 = Database.setSavepoint();
        
        for (Case_Team__c ct : allCaseTeams)
        {
            util.debug('begining to create ep for case team: ' + ct.user__c);
            Employee_Productivity__c ep = new Employee_Productivity__c();
            //  grab these two records now so we dont have to query and scroll thru the lists for each compuattion method
            Time_Card__c timeCardOfUser = findTimeCard(ct, allTimeCards);
            
            //  a lot of calculations depends on the time card being found
            //  so if it does not exist or for some reason was not created, we need to skip this case team and move onto the next
            if (timeCardOfUser == null)
            {
                util.debug('TimeCard could not be found for: ' + ct);
            }
            else
            {
                Time_Card_Details__c timeCardDetailOfToday = findTimeCardDetail(todaysDate, ct, timeCardOfUser);
                
                /*if(ct.user__c == '00550000003yYKc')
                {
                     system.debug('timeCardOfUser'+ timeCardOfUser.id);
                }*/
                
                if (timeCardDetailOfToday == null)
                {
                    
                    util.debug('timeCardDetailOfToday is null for '+ todaysDate);
                    system.debug('timeCardDetailOfToday is null for '+ todaysDate);
                    //  this is for bug fix in the live, the findTimeCArdDetail was throwing exception when
                    //  tcd could not be found.  insted of throwing it, lets continue on the next case team
                    continue;   
                }
                else
                {
                    //  format should be user name and date concatenated with no seperators
                        
                        if(ct.user__c == '00550000003yYKc')
                        {
                            system.debug('********** timeCardDetailOfToday '+ timeCardDetailOfToday.id);
                        }
                        try
                            { 
                            empProdCreate.addAll(createEmployeeProdRecord(ep,ct,weekBegin,timeCardDetailOfToday,todaysDate));
                            }
                        catch(Exception e)
                            {
                                System.debug('***************EXCEPTION EMPPRODCREATE ROLLBACK**********');
                                Database.rollback(sp1);
                            }  
                }
            }
        }
        
        
        if(!empProdCreate.isEmpty())
        {
           insert empProdCreate;
        }
     }
     catch(Exception e)
     {
         system.debug(e.getMessage());
     }
        
     }
    
//Methods start..


   public List<Employee_Productivity__c> createEmployeeProdRecord(Employee_Productivity__c ep, Case_Team__c ct, Date weekBegin , Time_Card_Details__c timeCardDetailOfToday, Date todaysDate )
                    {
                        
                        List<Employee_Productivity__c> employeeProdRecordsToCreate = new List<Employee_Productivity__c>();
                        
                        ep.name = 'EP - ' + ct.User__r.Name + ' - ' + weekBegin.Month() + weekBegin.Day() + weekBegin.Year();
                        ep.Case_Team__c = ct.id;
                        ep.week_begin__c = weekBegin;
                        ep.Time_Card_Detail__c = timeCardDetailOfToday.id;
                        ep.Day__c = todaysDate;
                        
                        ep.Case_Work_Time__c = computeActualWorkMinutes(ct, caseTeamToCaseTimeMap);//  this is the Case Time (sum of sfdc times).It is used to calculate Utilization Rate
                        ep.Non_Case_Time_TC_Subtractors__c = computeNonCaseTime(timeCardDetailOfToday); // Added Hours Worked
                        ep.Hours_Worked__c = computeHoursWorked(timeCardDetailOfToday);
                        ep.Absence_Time_Sum_All__c = computeSumAllAbsenceTime(timeCardDetailOfToday);
                        ep.Employee_Time_in_office__c = computeEmpTimeInOffice(timeCardDetailOfToday);
                        ep.Available_Work_Minutes_Time_Card__c = computeAvaiableWorkMinutesTimeCard(timeCardDetailOfToday);
                       
                        ep.Cases_Opened__c = computeCasesOpened(ct, caseTeamToCasesOPenedMap);
                        ep.Cases_Closed__c = computeCasesClosed(ct, caseTeamToCasesClosedMap);
                        
                        // This signifies the total unique cases work on
                        ep.total_cases_worked_on__c = computeTotalCasesWorkedOn(ct, caseTeamToCaseTimeMap);
                        
                        ep.Case_Events__c = computeCaseEvents(ct, mapOfCaseTeamCaseEventList);
                        
                                            
                        ep.Engineering_Cases_Opened__c = computeEngineeringCasesOpened(ct, caseTeamToEngineeringCasesOpenedMap);
                        ep.articles_linked__c = computeArticlesLinked(ct, caseTeamToCaseARticleMap);
                        ep.articles_created__c = computeArticlesCreated(ct, caseTeamToSolutionArticleMap);
                        
                        //Abhishek Modified
                        //case activity is defined as count of unique cases where there is a case time associated to that employee.
                        // So it has nothing to do with who owns the case or case events but if an employee logs case time for a case, that case is counted
                        
                        //So , ideally it is the same with total unique cases worked on by Individual. One emp prod gets created/day.Kept the field as it was already present.
                        ep.Case_Activity_By_Day__c = ep.total_cases_worked_on__c;
                        
                        //Abhishek Modified
                        // Ideally it should be the same as closed date as One emp prod gets created/day.
                        ep.closed_cases_by_day__c = ep.Cases_Closed__c ;
                        
                        employeeProdRecordsToCreate.add(ep);
                        
                        if (employeeProdRecordsToCreate != null && employeeProdRecordsToCreate.size() > 0)
                            {
                                return employeeProdRecordsToCreate;
                            }
                       return null;     
                    }


  global void createCaseTeamToCasesOpenedMap_CaseEvent(List<Case_Team__c> caseTeams , DateTime todaysDateUpperBound , DateTime todaysDateLowerBound)
            {
                List<Case> casesOfCaseTeam_CaseEvent = new List<Case>();
                map<Case_Team__c,Set<Id>> caseteamListCaseMap = new Map<Case_Team__c,Set<Id>>();
                
                 map<Id,List<Case_Event__c>> mapCaseTeamUserCaseEvent = new map<Id,List<Case_Event__c>>();
                
                Set<id> caseTeamUserIds = new set<id>();
                for (Case_Team__c ct : caseTeams)
                {
                    if (!caseTeamUserIds.contains(ct.user__c))
                    {
                        caseTeamUserIds.add(ct.user__c);
                    }
                }
                
                for(Case_Event__c caseEvent : [select case__c,id,case__r.Ownerid,createdById  from Case_Event__c where createdById = : caseTeamUserIds  AND CreatedDate <=: todaysDateUpperBound and CreatedDate >=: todaysDateLowerBound limit 50000 ])
                    {
                    
                        if(mapCaseTeamUserCaseEvent.containsKey(caseEvent.createdById))
                        {    
                            mapCaseTeamUserCaseEvent.get(caseEvent.createdById).add(caseEvent);
                        }
                        else
                        {
                            mapCaseTeamUserCaseEvent.put(caseEvent.createdById, new List<Case_Event__c>{caseEvent});
                        }
                    }
                
                for (Case_Team__c ct : caseTeams)
                {
                    set<id> caseId = new set<id>();
                    
                    if(mapCaseTeamUserCaseEvent.containsKey(ct.user__c))
                    {
                      mapOfCaseTeamCaseEventList.put(ct,mapCaseTeamUserCaseEvent.get(ct.user__c));
                    }
                    
                 }  
           }
          
    global void createCaseTeamCaseTimeMap(List<Case_Team__c> caseTeams, List<Mibos_Case_Time__c> caseTimes)
    {
        //  scroll thru the case teams, creating a new map
        for (Case_Team__c ct : caseTeams)
        {
            List<Mibos_Case_Time__c> caseTimesOfCaseTeam = new List<Mibos_Case_Time__c>();
            for (Mibos_Case_Time__c caseTime : caseTimes)
            {
                if (caseTime.Owner__c == ct.User__c)
                {
                    caseTimesOfCaseTeam.add(caseTime);
                }
            }
            
            caseTeamToCaseTimeMap.put(ct, caseTimesOfCaseTeam);
        }
        util.debug('finished creating the caseTeamToCaseTimeMap.  size: ' + caseTeamToCaseTimeMap.size());
    }
   
   
    global void createCaseTeamToCasesOpenedMap(List<Case_Team__c> caseTeams, List<Case> casesOpened)
    {
        //  scroll thru the case teams, creating a new map
        for (Case_Team__c ct : caseTeams)
        {
            List<Case> casesOfCaseTeam = new List<Case>();
            List<Case> engineeringCasesOfCaseTeam = new List<Case>();
            for (Case singleCase: casesOPened)
            {
               // if(singleCase.Ownerid == ct.User__c) John does not want the cases to be filtered by Owner. Change came in UAT Phase.
               if(singleCase.createdById == ct.User__c)
                {
                    casesOfCaseTeam.add(singleCase);
                
                }
                
            }
            
             caseTeamToCasesOpenedMap.put(ct, casesOfCaseTeam);
            
            // Abhishek Modified.Following Logic will only for Enginerring Cases.count of Engineering cases opened by employee regardless who owns it.
            
            for (Case singleCase: casesOPened)
            {
                if(singleCase.createdById == ct.User__c)
                {
                    engineeringCasesOfCaseTeam.add(singleCase);
                
                }
                
            }
            
            caseTeamToEngineeringCasesOpenedMap.put(ct,engineeringCasesOfCaseTeam);
          
        }
            
    }
    global void createCaseTeamToCasesClosedMap(List<Case_TEam__c> caseTeams, List<Case> casesClosed)
    {
                //  scroll thru the case teams, creating a new map
        for (Case_Team__c ct : caseTeams)
        {
            List<Case> casesOfCaseTeam = new List<Case>();
            for (Case singleCase: casesClosed)
            {
                // if(singleCase.Ownerid == ct.User__c) John does not want the cases to be filtered by Owner. Change came in UAT Phase.
               if(singleCase.Closed_By__c == ct.User__c)
                {
                    casesOfCaseTeam.add(singleCase);
                }
            }
            CaseTeamToCasesClosedMap.put(ct, casesOfCaseTeam);
        }
        util.debug('finished creating the CaseTeamToCasesClosedMap.  size: ' + CaseTeamToCasesClosedMap.size());
    }
    
    global void createCaseTeamToCaseArticleMap(List<Case_Team__c> caseTeams, List<CaseArticle> articles)
    {
        for (Case_Team__c ct : caseTeams)
        {
            List<CaseArticle> caseTeamsArticles = new List<CaseArticle>();
            for (CaseArticle ca : articles)
            {
                if (ca.case.OwnerId == ct.User__c)
                  {
                    caseTeamsArticles.add(ca);
                  }
            }
            caseTeamToCaseARticleMap.put(ct, caseTeamsArticles);
        }
        
    }
    
    global void createCaseTeamToSolutionArticleMap(List<Case_Team__c> caseTeams, List<Solution__ka> articles)
    {
        for (Case_Team__c ct : caseTeams)
        {
            List<Solution__ka> caseTeamsArticles = new List<Solution__ka>();
            for (Solution__ka art : articles)
            {
                if (art.createdbyid == ct.User__c)
                  {
                    caseTeamsArticles.add(art);
                  }
            }
            caseTeamToSolutionARticleMap.put(ct, caseTeamsArticles);
        }
    }
    
    
    private static Time_Card__c findTimeCard(Case_Team__c ct, List<Time_Card__c> allTimeCards)
    {
        for (Time_Card__c tc : allTimeCards)
        {
            if (ct.User__c == tc.User__c)
            {
                return tc;
            }
        }
        return null;
    }
    private static decimal computeNonCaseTime(Time_Card_Details__c tcd)
    {
         //  johns description of this stat is: Non Case Time (Sum of Timecard subtractors)
         //  so this would be... umm in office but not case time stuff so thats
         //  adminiratstifve, meetings, training, pro serves, 
         //  that means we need only the tcd record as it contains that info
         decimal sum = 0.0;
         sum += nullToZero(tcd.Administrative_Time_Spent__c) + 
           nullToZero(tcd.Meeting_Time_Spent__c) + 
           nullToZero(tcd.training_Time_Spent__c) + nullToZero(tcd.Project_Time_Spent__c) +
           nullToZero(tcd.Professional_Services_Work_Time_Spent__c);
         return sum;
         
    }
     private static decimal computeHoursWorked(Time_Card_Details__c tcd)
    {
         
         decimal sum = 0.0;
         sum += nullToZero(tcd.Hours_Worked__c) ;
         return sum;
         
    }
    private static decimal computeSumAllAbsenceTime(Time_Card_Details__c tcd)
    {
        decimal sum = 0.0;
        //  johns description of this is to sum up all absecd time that does not invole work or out of office time offf
        sum += nullToZero(tcd.Absence_Time_Spent__c) + 
           nullToZero(tcd.Bereavement_Time_Spent__c) +
           nullToZero(tcd.Holiday_Time_Spent__c) +
           nullToZero(tcd.In_Lieu_Days_Time_Spent__c) +
           nullToZero(tcd.jury_Duty_Time_Spent__c) +
           nullToZero(tcd.personal_Time_Spent__c) +
           nullToZero(tcd.sick_time_Spent__c) +
           nullToZero(tcd.vacation_time_Spent__c);
           return sum;
    }
    
    
    private static decimal computeActualWorkMinutes(Case_Team__c caseTeam, Map<Case_Team__c, List<Mibos_Case_Time__c>> caseTeamToCaseTimeMap)
    {
        //  pull out the case times out of the map using the passed caseTeam
        //  scroll thru them an sum them up and return the summation
        List<Mibos_Case_Time__c> caseTimes = caseTeamToCaseTimeMap.get(caseTeam);
        
        decimal sum = 0.0;
        for (Mibos_Case_Time__c ct : caseTimes)
        {
            util.debug('caseTeam**'+ caseTeam.user__c);
            util.debug('caseTime name**'+ ct.name);
            util.debug('Case Time**'+ ct.Work_Effort__c);
            sum += nullToZero(ct.Work_Effort__c);
            
        }
        
        return sum;
    }

    private static decimal computeCasesOpened(Case_Team__c caseTeam, Map<Case_Team__c, List<Case>> caseTeamToCasesOpened)
    {
        List<Case> casesOpened = caseTeamToCasesOpened.get(caseTeam);
        integer numCasesOpened = (casesOpened == null ? 0 : casesOpened.size());
        util.debug('num of cases opened for caseteam: ' + caseTeam + ' = ' + numCasesOpened);
        return numCasesOpened;
    }
    private static decimal computeCasesClosed(Case_Team__c caseTeam, Map<Case_Team__c, List<Case>> caseTeamToCasesClosed)
    {
        List<Case> casesClosed = caseTeamToCasesClosed.get(caseTeam);
        integer numCasesclosed = (casesClosed == null ? 0 : casesClosed.size());
        return numCasesClosed;
    }
    
    public static decimal computeCaseEvents(Case_Team__c caseTeam, Map<Case_Team__c, List<Case_event__c>> caseTeamToCasesEvent)
    {
        if(caseTeamToCasesEvent.get(caseTeam)!= null)
                return caseTeamToCasesEvent.get(caseTeam).size();
        else
                return 0;        
    }

    private static decimal nullToZero(decimal d)
    {
        return (d == null ? 0 : d);
    }
    private static Time_Card__c timeCardOfUser(Case_Team__c ct, List<Time_Card__c> allTimeCards)
    {
        for (Time_Card__c tc : allTimeCards)
        {
            if (tc.User__c == ct.user__c)
            {
                return tc;
            }
        }
        return null;
    }
    
    private static Time_Card_Details__c findTimeCardDetail(Date todaysDate, Case_Team__c caseTeam, Time_Card__c timeCard)
    {
        //  now we have the users time card, we now need to get the specific day's time card details, the time card details should be a related list of the time card record
        List<Time_Card_Details__c> timeCardDetails = timeCard.Time_Card_Details__r;
        system.assertNotEquals(null, timeCardDetails);
        if (timeCardDetails == null)
        {
            return null;
        }
        Time_Card_Details__c todaysTimeCardDetail;
        for (Time_Card_Details__c tcd : timeCardDetails)
        {
            if (tcd.date__c == todaysDate)
            {
                return tcd;
            }
        }
        
        util.debug('ERROR: problem occured in findTimeCardDetail method.  could not find time card detail for ' + todaysDate + ' time card: ' + timeCard);
        return null;
    }
    
    private static decimal computeAbsenceAndBreakTime(decimal absenceMinutes)
    {
        decimal valueToReturn = 0;
        if (absenceMinutes != null)
        {
            //  if 0 < x < 240 then subtract 30 minute break + absence minutes, user was only gone for parital day so they'll still take 30 minuters
            if (absenceMinutes > 0 && absenceMinutes < 240)
            {
                valueToReturn = (absenceMinutes + 30);
            }
            else if (absenceMinutes >= 240)//  person is gone for half or whole day, john doesnt want us to take out the break data
            {
                valueToReturn = (absenceMinutes);
            }
            else
            {
                //  absence = 0 so just subtract the 30
                valueToReturn = 30;
            }
        }
        else
        {
            valueToReturn = 30;
        }
        return valueToReturn;
    }
   
   private static decimal computeAvaiableWorkMinutesTimeCard(Time_Card_Details__c tcd)
   {
        //  not sure i understand the logic on this one, but the old ep creator would check to see if the Absence_minutes_AnyDay >= 480 minutes
        //  which means that person was off, then we subtract from their toal availabe minutes that value, otherwise, we subtract ffrom that value
        //  + 30 minutes 
        //  
        decimal totalAvailableMinutes = 480;
        
        decimal absenceTimeSpent = nullToZero(tcd.Absence_Time_Spent__c);
        if (absenceTimeSpent >= 480)
        {
            totalAvailableMinutes -= absenceTimeSpent;
        }
        else
        {
            totalAvailableMinutes -= absenceTimeSpent + 30;
        }
        
        return totalAvailableMinutes;
        
   }
   
   private static decimal computeTotalCasesWorkedOn(Case_Team__c ct, Map<Case_Team__c, List<MIbos_Case_Time__c>> caseTeamToCaseTimesMap)
   { 
        Set<id> uniqueCaseIds = new Set<Id>();
        List<MIbos_Case_Time__c> caseTimes = caseTeamtoCaseTimesMap.get(ct);
        util.debug('num of case times found: ' + (caseTimes == null ? 0 : caseTimes.size())  );
        
        for (Mibos_Case_Time__c mct : caseTimes)
        {
            if (!uniqueCaseIds.Contains(mct.Case__c))
            {
                uniqueCaseIds.add(mct.Case__c);
            }
        }
        
        return uniqueCaseids.size();
   }
   private static decimal computeEngineeringCasesOpened(Case_Team__c ct, Map<Case_Team__c, List<Case>> caseTeamToCaseMap)
   {
        List<Case> casesOpened = caseTeamToCaseMap.get(ct);
        integer countEngCases = 0;
        if (casesOpened != null)
        {
            for (Case c : casesOpened)
            {
                if (c.recordtype.name == 'Engineering Case')
                {
                    countEngCases++;
                }
            }
        }
        return countEngCases;
   }
   
   private static decimal computeArticlesLinked(Case_Team__c caseTeam, Map<Case_Team__c, List<CaseArticle>> caseTeamToCaseArticleMap)
   {
        List<CaseArticle> articles = caseTeamToCaseArticleMap.get(caseTeam);
        if (articles == null)
        {
            return 0;
        }
        else
        {
            return articles.size();
        }
   }
   
   private static decimal computeArticlesCreated(Case_Team__c caseTeam, Map<Case_Team__c, List<Solution__ka>> caseTeamToSolutionArticleMap)
   {
        List<Solution__ka> solutionsOfCaseTeam = caseTeamToSolutionArticleMap.get(caseTeam);
        return (solutionsOfCaseTeam == null ? 0 : solutionsOfCaseTeam.size());
   }
    private static decimal computeEmpTimeInOffice(Time_Card_Details__c tcd)
    {
        if (tcd == null)
        {
            return 0;
        }
        else
        {
            decimal totalMinutesInOffice = 480;
            totalMinutesInOffice -= computeAbsenceAndBreakTime(tcd.Absence_Time_Spent__c);
            return totalMinutesInOffice;
            
        }
        
    }
// Methods End..
global void finish(Database.BatchableContext BC) {
}

}