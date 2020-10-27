/*********************************************************************************
Program:                BatchTimeCardEntry
Programmer:             Abhishek Dey - Tata Consultancy Services
Date:                   Jan 26 , 2016
**********************************************************************************/    

global class  BatchTimeCardEntry  implements Database.Batchable<sObject>
  {
   
   global List<Time_Card_Details__c> m_timeCardDetails;
   global Map<id,Time_Card__c> mapCaseTeamUserTimeCard = new Map<id,Time_Card__c>();
   global list<Time_Card_Details__c> lstTCDetails = new list<Time_Card_Details__c>();
   
   public Date todaysDate;
   public Date weekBegin;
   public List<Time_Card__c> allTimeCards;
   
   global final Date batchRunningDate;

   global BatchTimeCardEntry(Date runningDate)
     {
       todaysDate = runningDate;
       weekBegin = todaysDate.toStartOfWeek(); // Ideally both weekBegin & todaysDate will be same as we will batch job on Sunday
     }  
   
   global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'select id, business_Unit__c, group_Name__c, user__c,Hours_Worked__c, user__r.name from Case_Team__c limit 50000';
        return Database.getQueryLocator(query);
        
        }
   global void execute(Database.BatchableContext BC, List<Case_Team__c> scope) {
    
       List<Case_Team__c> allCaseTeams = scope;
       Set<id> caseTeamUserIds = new set<id>();
       List<Case_Team__c> excludedCaseTeams = new List<Case_Team__c>();
       
        for (Case_Team__c ct : allCaseTeams)
        {
            if (!caseTeamUserIds.contains(ct.user__c))
            {
                caseTeamUserIds.add(ct.user__c);
            }
        }
        
         allTimeCards = [Select t.id, t.name , t.User__c, t.Week_Begin__c
                                                  From Time_Card__c t
                                                  where user__c =: caseTeamUserIds and week_begin__c =: weekBegin
                                                  Limit 50000
                                          ];
                                          
        
        for (Time_Card__c tcard : allTimeCards )
        {
            if (!mapCaseTeamUserTimeCard.containsKey(tcard.user__c))
            {
                mapCaseTeamUserTimeCard.put(tcard.user__c, tcard );
            }
        }
        if(allTimeCards != null && allTimeCards.size()>0) // This section will filter out the users for whom Time Card is present..
        {
            lstTCDetails = new list<Time_Card_Details__c>();
            for (Case_Team__c ct : allCaseTeams)
            {
                m_timeCardDetails =  new List<Time_Card_Details__c>();
               
                if(mapCaseTeamUserTimeCard.containsKey(ct.user__c)) // those who have time card during the time frame
                {
                 list<Time_Card_Details__c> tempData = searchAndCreateTimeCardDetails(mapCaseTeamUserTimeCard.get(ct.user__c), true , ct.Hours_Worked__c);
                 if( tempData  != null)
                  {
                  lstTCDetails.addAll(tempData);
                  }
                }
                else
                {
                    excludedCaseTeams.add(ct); // Those who do not have time card
                }
            }
         }  
           
        if((!excludedCaseTeams.isEmpty())||(lstTCDetails.isEmpty())) 
        { 
         if(!excludedCaseTeams.isEmpty()) // This part will be executed only when few users will have time card and Time Card details and few not
            {
                lstTCDetails = new list<Time_Card_Details__c>();
                for (Case_Team__c ct : excludedCaseTeams)
                {
                     m_timeCardDetails =  new List<Time_Card_Details__c>();
                     
                     lstTCDetails.addAll(createNewTimeCardDetail(ct.user__c, false, ct.Hours_Worked__c));
                }
            }
            
            if(lstTCDetails.isEmpty()) // This part will be executed when no one will have time card during the time frame
            { 
                lstTCDetails = new list<Time_Card_Details__c>();
                for (Case_Team__c ct : allCaseTeams)
                {
                     m_timeCardDetails =  new List<Time_Card_Details__c>();
                     
                     lstTCDetails.addAll(createNewTimeCardDetail(ct.user__c, false , ct.Hours_Worked__c));
                }
            }
            
         }   
            try{
                    if(!lstTCDetails.isEmpty())
                    {
                        insert lstTCDetails;
                    }
                }
            catch(Exception e)
            {
                System.debug(e.getMessage());
            }
   }
   
   global void finish(Database.BatchableContext BC) {
   }
   
   public list<Time_Card_Details__c> createNewTimeCardDetail(id userId, Boolean flag , decimal workHours)
    {
           Time_Card__c timeCard = new Time_Card__C();
           
           User tempUserRecord = [select id, name from User where id =: userId];
           timeCard.User__c = userId ;
           timeCard.name = 'TC - ' + tempUserRecord.Name + ' - ' + WeekBegin.Month() + weekBegin.Day() + WeekBegin.year();
           
           timeCard.Week_Begin__c = weekBegin;
           
           insert timecard;
           
           if(timecard!= null)
           return searchAndCreateTimeCardDetails(timeCard, flag , workHours );
           
           
         return null ;
    }
    
   
   private list<Time_Card_Details__c> searchAndCreateTimeCardDetails(Time_Card__c TimeCard, Boolean flag , decimal workHours)
    {
        if(flag == true){
        m_timeCardDetails = [Select Type__c From Time_Card_Details__c where Time_Card__c =: timeCard.id order by date__c asc];
        }
        
        if (m_timeCardDetails != null && m_timeCardDetails.size() > 0)
        {
            System.debug('Cannot create new week of time card detail records.  Records already exist for the time card.  Size of list: ' + m_timeCardDetails.size());
            return null;
        }
        if (m_timeCardDetails == null || m_timeCardDetails.size() == 0)
        {
            m_timeCardDetails = new List<Time_Card_Details__c>();
            m_timeCardDetails.add(createTimeCardDetail(timeCard, 'Sunday' , 0));
            m_timeCardDetails.add(createTimeCardDetail(timeCard, 'Monday' , workHours));
            m_timeCardDetails.add(createTimeCardDetail(timeCard, 'Tuesday' , workHours));
            m_timeCardDetails.add(createTimeCardDetail(timeCard, 'Wednesday' , workHours));
            m_timeCardDetails.add(createTimeCardDetail(timeCard, 'Thursday' , workHours));
            m_timeCardDetails.add(createTimeCardDetail(timeCard, 'Friday' , workHours));
            m_timeCardDetails.add(createTimeCardDetail(timeCard, 'Saturday' , 0));
        }
         return  m_timeCardDetails;   
        
    }
    
    private static Time_Card_Details__c createTimeCardDetail(Time_Card__c tc, string dayOfWeek , decimal workHours)
    {
        Time_Card_Details__c tcd = new Time_Card_Details__c();
        tcd.time_card__c = tc.id;
        tcd.name = tc.name + ' - ' + dayOfWeek; //  format is name of time card - day
        tcd.day_of_week_name__c = DayofWEek;
        tcd.Hours_Worked__c = workHours;
      
        if (dayOfWeek == 'Sunday')
        {
            tcd.Date__c = tc.Week_Begin__c;
        }
        if (dayOfWeek == 'Monday')
        {
            tcd.Date__c = tc.Week_Begin__c.addDays(1);
        }
        if (dayOfWeek == 'Tuesday')
        {
            tcd.Date__c = tc.Week_Begin__c.addDays(2);
        }
        if (dayOfWeek == 'Wednesday')
        {
            tcd.Date__c = tc.Week_Begin__c.addDays(3);
        }
        if (dayOfWeek == 'Thursday')
        {
            tcd.Date__c = tc.Week_Begin__c.addDays(4);
        }
        if (dayOfWeek == 'Friday')
        {
            tcd.Date__c = tc.Week_Begin__c.addDays(5);
        }
        if (dayOfWeek == 'Saturday')
        {
            tcd.Date__c = tc.Week_Begin__c.addDays(6);
        }
       return tcd;
    }

    
}