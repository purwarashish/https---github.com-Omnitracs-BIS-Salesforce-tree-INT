/*
Author : TCS Banglore offshore Team
Summary:This page act as a controller for the vf page,where in user can apply schedule exception for multiple assignment 
*/

public without sharing class MassScheduleExceptionController
{
    public pse__Assignment__c assignment {get;set;}
    public pse__Schedule__c datefilterScheduler {get;set;}        
    public Boolean flag {get ; set;}  // rendered  
    public List<assignmentwrapper> listActiveAssignmentWrapper {get ; set;}                 
    public boolean MoveEndDate { get; set; }
    public boolean autoAdjustOverlappingException { get; set; }
    public pse__Schedule_Exception__c scheduleException { get; set; }
    Public boolean issuccess { get; set; }
    Public boolean isnoresult { get; set; }
    list<pse__Schedule_Exception__c> lstScheduleException;
    Set<pse__Schedule_Exception__c> setScheduledExceptionDeleted;
    Set<pse__Schedule_Exception__c> setScheduledExceptionUpdated;
    public integer lstSize{get;set;}   
      
    public MassScheduleExceptionController() {
          
        assignment = new pse__Assignment__c();
        datefilterScheduler = new pse__Schedule__c();
        flag = False;
        listActiveAssignmentWrapper = new List<assignmentwrapper>();
        MoveEndDate = false;
        autoAdjustOverlappingException = false;
        scheduleException = new pse__Schedule_Exception__c();
        issuccess = true;
        isnoresult = false;
 
    }

    //Fetch the active assignments of resource and display in tabular form
    public void activeAssignments()
    {        
        system.debug('MoveEndDate inside assignment'+MoveEndDate);
        issuccess = true;
        isnoresult = true;
        listActiveAssignmentWrapper = new List<assignmentwrapper>();
        scheduleException.clear();
        flag = false;                            
           
        for(pse__Assignment__c singleassignment : [Select Id, Name, pse__Project__c, pse__Project__r.name, pse__Schedule__c, 
            pse__Schedule__r.pse__Start_Date__c, pse__Schedule__r.pse__End_Date__c 
            from pse__Assignment__c where pse__Status__c != 'Closed' AND 
            pse__Resource__c = :assignment.pse__Resource__c AND 
            ((pse__Schedule__r.pse__Start_Date__c>=:datefilterScheduler.pse__Start_Date__c AND pse__Schedule__r.pse__End_Date__c<=:datefilterScheduler.pse__End_Date__c) OR
            (pse__Schedule__r.pse__Start_Date__c<=:datefilterScheduler.pse__Start_Date__c AND pse__Schedule__r.pse__End_Date__c>=:datefilterScheduler.pse__End_Date__c)OR
            (pse__Schedule__r.pse__Start_Date__c<=:datefilterScheduler.pse__End_Date__c AND pse__Schedule__r.pse__End_Date__c>=:datefilterScheduler.pse__End_Date__c)OR
            (pse__Schedule__r.pse__Start_Date__c<=:datefilterScheduler.pse__Start_Date__c AND pse__Schedule__r.pse__End_Date__c>=:datefilterScheduler.pse__Start_Date__c))  
            ORDER BY pse__Schedule__r.pse__Start_Date__c desc limit 1000])
        {
            flag = True;
            MoveEndDate = false;
            autoAdjustOverlappingException = false;
            listActiveAssignmentWrapper.add(new assignmentwrapper(singleassignment));
        }
    
        lstSize= listActiveAssignmentWrapper.size();
    }   

    // wrapper class for assignments
    public class assignmentwrapper
    {
        public pse__Assignment__c assignmentWR{get; set;}
        public Boolean selectedWR{get; set;}
        public assignmentwrapper(pse__Assignment__c singleassignment)
        {
            assignmentWR = singleassignment;
            selectedWR = false;
        }
    }
   
   //Function which verify and create new schedule exception for selected assignments
    public PageReference verifySchedule() 
    { 
        system.debug('MoveEndDate inside verifySchedule'+MoveEndDate);
        system.debug('scheduleException inside verifySchedule'+scheduleException);
        System.debug('inside a verify schedule');
        issuccess = false;
        List<pse__Assignment__c> selectedAssignments = new List<pse__Assignment__c>();
        System.debug('listActiveAssignmentWrapper+++++'+listActiveAssignmentWrapper);
        for(assignmentwrapper assignwrapper : listActiveAssignmentWrapper)
        {
            if(assignwrapper.selectedWR == true)
                selectedAssignments.add(assignwrapper.assignmentWR);
        }
        system.debug('selectedAssignments size: '+selectedAssignments.size());
        
        if(selectedAssignments == null || selectedAssignments.size() == 0)
        {
            System.debug('inside a error1');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Select any Assignment before scheduling exception');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        if(scheduleException.pse__Date__c > scheduleException.pse__End_Date__c)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Start Date can not be greater than End Date');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        boolean isScheduleError = false;
        boolean isScheduleExceptionError = false;
        setScheduledExceptionDeleted = new Set<pse__Schedule_Exception__c>();
        setScheduledExceptionUpdated = new Set<pse__Schedule_Exception__c>();
        Map<id,list<pse__Schedule_Exception__c>> mapSchedulerScheduleException = new Map<id,list<pse__Schedule_Exception__c>>();
        List<Id> ScheduleIdlist = new List<Id>();
                      
        selectedAssignments = [Select Id, Name, pse__Project__c, pse__Project__r.name, pse__Project__r.pse__Start_Date__c, 
                               pse__Project__r.pse__End_Date__c, pse__Resource__r.pse__Work_Calendar__c , pse__Schedule__c, 
                               pse__Schedule__r.Name, pse__Schedule__r.pse__Start_Date__c, pse__Schedule__r.pse__End_Date__c, 
                               pse__Schedule__r.pse__Scheduled_Hours__c, pse__Schedule__r.pse__Sunday_Hours__c, 
                               pse__Schedule__r.pse__Monday_Hours__c, pse__Schedule__r.pse__Tuesday_Hours__c, pse__Schedule__r.pse__Wednesday_Hours__c,  
                               pse__Schedule__r.pse__Thursday_Hours__c, pse__Schedule__r.pse__Friday_Hours__c, pse__Schedule__r.pse__Saturday_Hours__c 
                               from pse__Assignment__c where id in :selectedAssignments limit 1000];
        
        System.debug('selected assignments+++++++++++'+selectedAssignments[0].pse__Schedule__r.pse__End_Date__c);
        //Get all holiday records of the selected resource
        Map<Date, pse__HolidayObj__c> mapassignedholiday = new Map<Date, pse__HolidayObj__c>();
        //Builds a holiday map                                           
        for(pse__HolidayObj__c assignedholiday : [select id, pse__Date__c, pse__Work_Calendar__c, pse__Work_Hours__c from pse__HolidayObj__c where
                                                  pse__Work_Calendar__c = :selectedAssignments[0].pse__Resource__r.pse__Work_Calendar__c])
        {
            mapassignedholiday.put(assignedholiday.pse__Date__c, assignedholiday);
        }
        
        //Iterate the selected assignment to validate and get schedule ID
        for(pse__Assignment__c singleAssignment :selectedAssignments)
        {
           System.debug('inside a selectd assignments');
            if(singleAssignment.pse__Schedule__c != null)
            {
                if(scheduleException.pse__Date__c < singleAssignment.pse__Schedule__r.pse__Start_Date__c || scheduleException.pse__Date__c > singleAssignment.pse__Schedule__r.pse__End_Date__c)
                { 
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Start Date does not fall within the start and end dates of the schedule <a target="_blank" href="/'+singleAssignment.pse__Schedule__c+'">'+singleAssignment.pse__Schedule__r.Name+'</a> for Assignment: '+singleAssignment.Name);
                    ApexPages.addMessage(myMsg);
                    //return null;
                    isScheduleError = true;
                }
                if(scheduleException.pse__End_Date__c < singleAssignment.pse__Schedule__r.pse__Start_Date__c || scheduleException.pse__End_Date__c > singleAssignment.pse__Schedule__r.pse__End_Date__c)
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'End Date does not fall within the start and end dates of the schedule <a target="_blank" href="/'+singleAssignment.pse__Schedule__c+'">'+singleAssignment.pse__Schedule__r.Name+'</a> for Assignment: '+singleAssignment.Name);
                    ApexPages.addMessage(myMsg);
                    //return null;
                    isScheduleError = true;
                }
                ScheduleIdlist.add(singleAssignment.pse__Schedule__c);
            }                
        }
        
        if(!isScheduleError)
        {
           List<pse__Schedule_Exception__c> lstScheduledException = [select Name, pse__Schedule__c, pse__Date__c, pse__End_Date__c, pse__Sunday_Hours__c, 
                                                                     pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c,  
                                                                     pse__Thursday_Hours__c, pse__Friday_Hours__c, pse__Saturday_Hours__c 
                                                                     from pse__Schedule_Exception__c 
                                                                     where pse__Schedule__c in :ScheduleIdlist];
                                                                                                                                            
           for(pse__Schedule_Exception__c singleScheduledException :lstScheduledException)
           {
               if(!mapSchedulerScheduleException.containskey(singleScheduledException.pse__Schedule__c))
               {
                   mapSchedulerScheduleException.put(singleScheduledException.pse__Schedule__c, new list<pse__Schedule_Exception__c>{singleScheduledException});
               }
               else
               {
                   mapSchedulerScheduleException.get(singleScheduledException.pse__Schedule__c).add(singleScheduledException);
               }
           }
           
           if(lstScheduledException != null && lstScheduledException.size() > 0)
           {              
               for(pse__Assignment__c singleAssignment :selectedAssignments)
               {                  
                   if(singleAssignment.pse__Schedule__c != null)
                   {
                       for(pse__Schedule_Exception__c singleScheduledException :lstScheduledException)
                       {
                           if(singleAssignment.pse__Schedule__c == singleScheduledException.pse__Schedule__c)
                           {
                               //Checks for an existing exception within the selected date range
                               if(autoAdjustOverlappingException == false)
                               {
                                   if(scheduleException.pse__Date__c == singleScheduledException.pse__Date__c ||
                                      scheduleException.pse__End_Date__c == singleScheduledException.pse__Date__c ||
                                      scheduleException.pse__Date__c == singleScheduledException.pse__End_Date__c ||
                                      scheduleException.pse__End_Date__c == singleScheduledException.pse__End_Date__c ||
                                      (scheduleException.pse__Date__c < singleScheduledException.pse__Date__c && 
                                       scheduleException.pse__End_Date__c > singleScheduledException.pse__Date__c) ||
                                      (scheduleException.pse__Date__c > singleScheduledException.pse__Date__c && 
                                       scheduleException.pse__End_Date__c < singleScheduledException.pse__End_Date__c) ||
                                      (scheduleException.pse__Date__c < singleScheduledException.pse__End_Date__c && 
                                       scheduleException.pse__End_Date__c > singleScheduledException.pse__End_Date__c))
                                    {
                                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Exception, scheduled for Assignment: <html><b>'+singleAssignment.Name+'</b></html> will overlap with <a target="_blank" href="/'+ singleScheduledException.id+'">'+ singleScheduledException.Name+'</a> Exception');
                                        ApexPages.addMessage(myMsg);
                                        //return null;
                                        isScheduleExceptionError = true;
                                    }
                                }
                                else 
                                {
                                    System.debug('scheduleException.pse__Date__c+++++++'+scheduleException.pse__Date__c);
                                    System.debug('singleScheduledException.pse__Date__c+++++++'+singleScheduledException.pse__Date__c);
                                    System.debug('end date'+ scheduleException.pse__End_Date__c); 
                                    System.debug('single'+singleScheduledException.pse__End_Date__c);                                  
                                    //Since overlaaping is ticked,need delete/split existing exception 
                                    if(scheduleException.pse__Date__c == singleScheduledException.pse__Date__c &&
                                       scheduleException.pse__End_Date__c == singleScheduledException.pse__End_Date__c)
                                    {
                                        setScheduledExceptionDeleted.add(singleScheduledException);
                                    }                                    
                                   
                                    else if(scheduleException.pse__Date__c >= singleScheduledException.pse__Date__c &&
                                       scheduleException.pse__End_Date__c <= singleScheduledException.pse__End_Date__c)
                                    {
                                        if(scheduleException.pse__Date__c == singleScheduledException.pse__Date__c)
                                        {
                                            pse__Schedule_Exception__c tempScheduleExcp = new pse__Schedule_Exception__c();
                                            tempScheduleExcp = singleScheduledException.clone();
                                            tempScheduleExcp.pse__Date__c = scheduleException.pse__End_Date__c.adddays(1);
                                            setScheduledExceptionUpdated.add(tempScheduleExcp);
                                        }
                                        else if(scheduleException.pse__End_Date__c == singleScheduledException.pse__End_Date__c)
                                        {
                                               System.debug('inside');
                                            pse__Schedule_Exception__c tempScheduleExcp = new pse__Schedule_Exception__c();
                                            tempScheduleExcp = singleScheduledException.clone();
                                            tempScheduleExcp.pse__End_Date__c = scheduleException.pse__Date__c.adddays(-1);
                                            setScheduledExceptionUpdated.add(tempScheduleExcp);
                                        }
                                        else
                                        {
                                            pse__Schedule_Exception__c tempScheduleExcp1 = new pse__Schedule_Exception__c();
                                            tempScheduleExcp1 = singleScheduledException.clone();
                                            tempScheduleExcp1.pse__End_Date__c = scheduleException.pse__Date__c.adddays(-1);
                                            setScheduledExceptionUpdated.add(tempScheduleExcp1);
                                            
                                            pse__Schedule_Exception__c tempScheduleExcp2 = new pse__Schedule_Exception__c();
                                            tempScheduleExcp2 = singleScheduledException.clone();
                                            tempScheduleExcp2.pse__Date__c = scheduleException.pse__End_Date__c.adddays(1);
                                            setScheduledExceptionUpdated.add(tempScheduleExcp2);
                                        }                                                                                   
                                        setScheduledExceptionDeleted.add(singleScheduledException);
                                    }
                                    else if(scheduleException.pse__Date__c >= singleScheduledException.pse__Date__c &&
                                            scheduleException.pse__End_Date__c > singleScheduledException.pse__End_Date__c &&
                                            scheduleException.pse__Date__c <= singleScheduledException.pse__End_Date__c
                                            )
                                    {
                                        if(scheduleException.pse__Date__c > singleScheduledException.pse__Date__c)
                                        {system.debug('inside 1005');
                                            pse__Schedule_Exception__c tempScheduleExcp = new pse__Schedule_Exception__c();
                                            tempScheduleExcp = singleScheduledException.clone();
                                            tempScheduleExcp.pse__End_Date__c = scheduleException.pse__Date__c.adddays(-1);
                                            setScheduledExceptionUpdated.add(tempScheduleExcp);
                                        }
                                        setScheduledExceptionDeleted.add(singleScheduledException);
                                    } 
                                    else if(scheduleException.pse__Date__c < singleScheduledException.pse__Date__c &&
                                            scheduleException.pse__End_Date__c <= singleScheduledException.pse__End_Date__c &&
                                            scheduleException.pse__End_Date__c >= singleScheduledException.pse__Date__c
                                            )
                                    {                                      
                                        if(scheduleException.pse__End_Date__c < singleScheduledException.pse__End_Date__c)
                                        {
                                            pse__Schedule_Exception__c tempScheduleExcp = new pse__Schedule_Exception__c();
                                            tempScheduleExcp = singleScheduledException.clone();
                                            tempScheduleExcp.pse__Date__c = scheduleException.pse__End_Date__c.adddays(1);
                                            setScheduledExceptionUpdated.add(tempScheduleExcp);   
                                        }
                                        setScheduledExceptionDeleted.add(singleScheduledException);
                                    }
                                    else if(scheduleException.pse__Date__c < singleScheduledException.pse__Date__c &&
                                            scheduleException.pse__End_Date__c > singleScheduledException.pse__End_Date__c)
                                    {
                                        setScheduledExceptionDeleted.add(singleScheduledException);
                                    }                          
                                }                                                                  
                            }
                        }
                    }    
               }
           }
       }
       
       if(!isScheduleError && !isScheduleExceptionError)
       {
           Set<pse__Schedule__c> setScheduleUpdate = new Set<pse__Schedule__c>();
           lstScheduleException = new list<pse__Schedule_Exception__c>();
           
           //Recalculating the total schedule hours and end date of the exception.
           for(pse__Assignment__c singleAssignment :selectedAssignments)
           {
               if(singleAssignment.pse__Schedule__c != null)
               {
                   if(!setScheduleUpdate.contains(singleAssignment.pse__Schedule__r))
                   {                       
                       Integer daysmoved = 0;
                       Decimal exceptionHour = 0.0;                       
                       Decimal newScheduledHour = schedulehourCalculation(singleAssignment, scheduleException, mapassignedholiday);                       
                       if(MoveEndDate == false)
                       {            
                           pse__Schedule__c ScheduleUpdateObj = new pse__Schedule__c();
                           ScheduleUpdateObj = singleAssignment.pse__Schedule__r;
                           ScheduleUpdateObj.pse__Scheduled_Hours__c = singleAssignment.pse__Schedule__r.pse__Scheduled_Hours__c - newScheduledHour;
                           setScheduleUpdate.add(ScheduleUpdateObj);
                       }
                       if(MoveEndDate == true)
                       {
                           Date EndDate = calculateDaystobeMoved(singleAssignment, newScheduledHour, mapassignedholiday, mapSchedulerScheduleException);
                           pse__Schedule__c ScheduleUpdateMoveDateObj = new pse__Schedule__c();
                           ScheduleUpdateMoveDateObj = singleAssignment.pse__Schedule__r;
                           ScheduleUpdateMoveDateObj.pse__End_Date__c = EndDate;
                           setScheduleUpdate.add(ScheduleUpdateMoveDateObj);
                       }        
                                                                   
                       pse__Schedule_Exception__c ScheduleExceptionObj = new pse__Schedule_Exception__c();
                       ScheduleExceptionObj = scheduleException.clone();
                       ScheduleExceptionObj.pse__Schedule__c = singleAssignment.pse__Schedule__c;
                       lstScheduleException.add(ScheduleExceptionObj);
                   }                   
               }                             
           }
           //Performing the final DML operation
           if(lstScheduleException.size() > 0 && setScheduleUpdate.size() > 0)
           {
               system.debug('inside DML operation');
               List<pse__Schedule__c> lstScheduleUpdate = new List<pse__Schedule__c>();
               lstScheduleUpdate.addAll(setScheduleUpdate);
               List<pse__Schedule_Exception__c> lstScheduledExceptionDeleted = new List<pse__Schedule_Exception__c>();        
               lstScheduledExceptionDeleted.addAll(setScheduledExceptionDeleted);
               List<pse__Schedule_Exception__c> lstScheduledExceptionUpdated = new List<pse__Schedule_Exception__c>();
               lstScheduledExceptionUpdated.addAll(setScheduledExceptionUpdated);              
               try{
               
                   if(MoveEndDate == true){                 
                       Update lstScheduleUpdate;
                   }                 
                   if(autoAdjustOverlappingException == true)
                   {
                       if(lstScheduledExceptionDeleted.size() > 0)
                       {                                 
                            delete lstScheduledExceptionDeleted;                   
                       }     
                       if(lstScheduledExceptionUpdated.size() > 0)
                       {
                           insert lstScheduledExceptionUpdated;                          
                       }    
                               
                    }
                    insert lstScheduleException;
                    if(MoveEndDate == true && autoAdjustOverlappingException == true)
                    {
                        UpdatePSAScheduleScheduler UpdatePSAsch = new UpdatePSAScheduleScheduler(lstScheduleUpdate);    
                        DateTime now  = DateTime.now();
                        DateTime nextRunTime = now.addMinutes(2);
                        System.debug('nextRunTime'+nextRunTime);
                        
                        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                        nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
                        System.debug('cronString'+cronString);
                        
                        String jobID1 = system.schedule('Schedule'+userinfo.getuserid()+':'+now, cronString, UpdatePSAsch);
                    }
                    issuccess = true;
                    MoveEndDate = false;
                    autoAdjustOverlappingException = false;
                    scheduleException.clear();
                    activeAssignments();
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'The schedule exception has been successfully applied to the selected assignment(s).');
                    ApexPages.addMessage(myMsg);
                }
                catch(Exception e)
                {
                   system.debug('Scheduler Updation failed due to: '+e.getmessage());
                }
           }
       }                  
       return null;                                                    
    }
    
    //calculating the schedule hours within the date range of newly created exception.
    private Decimal schedulehourCalculation(pse__Assignment__c singleAssignment, pse__Schedule_Exception__c scheduleException, Map<Date, pse__HolidayObj__c> mapassignedholiday)
    {
        Decimal schedulePattern = 0.0;
        Decimal exceptionPattern = 0.0;
        Decimal newScheduledHour;
       
        for(Date d=scheduleException.pse__Date__c; d <= scheduleException.pse__End_Date__c; d=d.adddays(1))
        {
           Datetime dt = DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0));
           String dayOfWeek = dt.format('EEEE');
           if(!mapassignedholiday.containskey(d))
           {
               if(dayOfWeek == 'Sunday')
               {    
                   schedulePattern = schedulePattern + singleAssignment.pse__Schedule__r.pse__Sunday_Hours__c;
                   exceptionPattern = exceptionPattern + scheduleException.pse__Sunday_Hours__c;
               }    
               else if(dayOfWeek == 'Monday')
               {
                   schedulePattern = schedulePattern + singleAssignment.pse__Schedule__r.pse__Monday_Hours__c;
                   exceptionPattern = exceptionPattern + scheduleException.pse__Monday_Hours__c;
               }    
               else if(dayOfWeek == 'Tuesday')
               {
                   schedulePattern = schedulePattern + singleAssignment.pse__Schedule__r.pse__Tuesday_Hours__c;
                   exceptionPattern = exceptionPattern + scheduleException.pse__Tuesday_Hours__c;
               }    
               else if(dayOfWeek == 'Wednesday')
               {
                   schedulePattern = schedulePattern + singleAssignment.pse__Schedule__r.pse__Wednesday_Hours__c;
                   exceptionPattern = exceptionPattern + scheduleException.pse__Wednesday_Hours__c;
               }
               else if(dayOfWeek == 'Thursday')
               {
                   schedulePattern = schedulePattern + singleAssignment.pse__Schedule__r.pse__Thursday_Hours__c;
                   exceptionPattern = exceptionPattern + scheduleException.pse__Thursday_Hours__c;
               }
               else if(dayOfWeek == 'Friday')
               {
                   schedulePattern = schedulePattern + singleAssignment.pse__Schedule__r.pse__Friday_Hours__c;
                   exceptionPattern = exceptionPattern + scheduleException.pse__Friday_Hours__c;
               }
               else
               {
                   schedulePattern = schedulePattern + singleAssignment.pse__Schedule__r.pse__Saturday_Hours__c;
                   exceptionPattern = exceptionPattern + scheduleException.pse__Saturday_Hours__c;
               }               
           }  
       }
       newScheduledHour = schedulePattern - exceptionPattern;
       
       return newScheduledHour;
    }
    //calculating the days to be moved based on the schedule hours.
    private Date calculateDaystobeMoved(pse__Assignment__c singleAssignment, Decimal newScheduledHour, Map<Date, pse__HolidayObj__c> mapassignedholiday, Map<id,list<pse__Schedule_Exception__c>> mapSchedulerScheduleException)
    {       
        Date endDate = singleAssignment.pse__Schedule__r.pse__End_Date__c;
        system.debug('initial enddate'+endDate);
        if(newScheduledHour == 0 || newScheduledHour == 0.0){
            return endDate;
        }
        
        Decimal ScheduleDaysPattern = 0.0;
        boolean dateShiftingFlag = (newScheduledHour >= 0? true: false);
        if(dateShiftingFlag){
            endDate = endDate.addDays(1);
        }
            
        while(newScheduledHour != 0)
        {
            system.debug('initial inside enddate'+endDate);
            Datetime dt = DateTime.newInstance(endDate, Time.newInstance(0, 0, 0, 0));
            String dayOfWeek = dt.format('EEEE');
            if(!mapassignedholiday.containskey(endDate))
            {                 
                if(dayOfWeek == 'Monday')
                {
                   if(newScheduledHour > 0)
                   {
                       newScheduledHour = newScheduledHour - singleAssignment.pse__Schedule__r.pse__Monday_Hours__c;                      
                   }
                   else
                   {
                       newScheduledHour = newScheduledHour + singleAssignment.pse__Schedule__r.pse__Monday_Hours__c;   
                   }
                   ScheduleDaysPattern = singleAssignment.pse__Schedule__r.pse__Monday_Hours__c;
                }    
                else if(dayOfWeek == 'Tuesday')
                {
                   if(newScheduledHour > 0)
                   {
                       newScheduledHour = newScheduledHour - singleAssignment.pse__Schedule__r.pse__Tuesday_Hours__c;                      
                   }
                   else
                   {
                       newScheduledHour = newScheduledHour + singleAssignment.pse__Schedule__r.pse__Tuesday_Hours__c;   
                   }
                   ScheduleDaysPattern = singleAssignment.pse__Schedule__r.pse__Tuesday_Hours__c;
                }    
                else if(dayOfWeek == 'Wednesday')
                {
                   if(newScheduledHour > 0)
                   {
                       newScheduledHour = newScheduledHour - singleAssignment.pse__Schedule__r.pse__Wednesday_Hours__c;                       
                   }
                   else
                   {
                       newScheduledHour = newScheduledHour + singleAssignment.pse__Schedule__r.pse__Wednesday_Hours__c;   
                   }
                   ScheduleDaysPattern = singleAssignment.pse__Schedule__r.pse__Wednesday_Hours__c;
                }
                else if(dayOfWeek == 'Thursday')
                {
                   if(newScheduledHour > 0)
                   {
                       newScheduledHour = newScheduledHour - singleAssignment.pse__Schedule__r.pse__Thursday_Hours__c;                      
                   }
                   else
                   {
                       newScheduledHour = newScheduledHour + singleAssignment.pse__Schedule__r.pse__Thursday_Hours__c;   
                   }
                   ScheduleDaysPattern = singleAssignment.pse__Schedule__r.pse__Thursday_Hours__c;
                }
                else if(dayOfWeek == 'Friday')
                {
                   if(newScheduledHour > 0)
                   {
                       newScheduledHour = newScheduledHour - singleAssignment.pse__Schedule__r.pse__Friday_Hours__c;                      
                   }
                   else
                   {
                       newScheduledHour = newScheduledHour + singleAssignment.pse__Schedule__r.pse__Friday_Hours__c;   
                   }
                   ScheduleDaysPattern = singleAssignment.pse__Schedule__r.pse__Friday_Hours__c;
                }
            }
            else if(dateShiftingFlag && (dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday'))
            {
                
                pse__Schedule_Exception__c ScheduleExceptionObjholiday = new pse__Schedule_Exception__c();
                ScheduleExceptionObjholiday.pse__Date__c = endDate;
                ScheduleExceptionObjholiday.pse__End_Date__c = endDate;
                ScheduleExceptionObjholiday.pse__Schedule__c = singleAssignment.pse__Schedule__c;
                lstScheduleException.add(ScheduleExceptionObjholiday);
            }            
            
            if((newScheduledHour < 0 && dateShiftingFlag) || (newScheduledHour > 0 && !dateShiftingFlag))
            {                               
                pse__Schedule_Exception__c ScheduleExceptionObjlastday = new pse__Schedule_Exception__c();
                ScheduleExceptionObjlastday.pse__Date__c = endDate;
                ScheduleExceptionObjlastday.pse__End_Date__c = endDate;
                ScheduleExceptionObjlastday.pse__Schedule__c = singleAssignment.pse__Schedule__c;
                if(newScheduledHour > 0 && !dateShiftingFlag)
                {
                    //newScheduledHour = ScheduleDaysPattern - newScheduledHour;
                    if(mapSchedulerScheduleException.containskey(singleAssignment.pse__Schedule__c))
                    {
                        for(pse__Schedule_Exception__c singleException :mapSchedulerScheduleException.get(singleAssignment.pse__Schedule__c))
                        {
                            if(singleException.pse__Date__c == endDate && singleException.pse__End_Date__c == endDate)
                            {
                                setScheduledExceptionDeleted.add(singleException);
                            }
                        }
                    }  
                    
                } 
                if((newScheduledHour < 0 && dateShiftingFlag))
                {
                    newScheduledHour = newScheduledHour + ScheduleDaysPattern;
                                  
                }
                ScheduleExceptionObjlastday.pse__Exception_Hours__c = newScheduledHour;
                lstScheduleException.add(ScheduleExceptionObjlastday);
                break; 
            }
            
            if(dateShiftingFlag && newScheduledHour != 0)
            {              
                endDate = endDate.addDays(1);
            }                     
            if(!dateShiftingFlag)
            {
                endDate = endDate.addDays(-1);
            }    
                              
        }
        
        //If no additional exception on last day
        boolean endDaterecalculate = false;
        while(!endDaterecalculate)
        {
            endDaterecalculate = true;
            if(newScheduledHour == 0 && !dateShiftingFlag)
            {
                Datetime dt = DateTime.newInstance(endDate, Time.newInstance(0, 0, 0, 0));
                String dayOfWeek = dt.format('EEEE');
                if(dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday' || mapassignedholiday.containskey(endDate))
                {              
                    endDate = endDate.addDays(-1);
                    endDaterecalculate = false;
                } 
            }
        }
            return endDate;
    }
}