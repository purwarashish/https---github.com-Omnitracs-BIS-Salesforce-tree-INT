/*
 *  @Author:        Mark David De Chavez
 *  @Date-created:  October 14, 2014
 *  @Description:   Displays the CS Case Time Entry of the current user
 *  @Last-updated:
 */
global with sharing class CsCaseTimeSummaryController {

    public Date endDate { get; set; }
    public List<CsCaseTimeSummaryWrapper> timecardSummaryList { get; set; }
    public String dateCtrl { get; set; }
    public String sun { get; set; }
    public String mon { get; set; }
    public String tue { get; set; }
    public String wed { get; set; }
    public String thu { get; set; }
    public String fri { get; set; }
    public String sat { get; set; }   
    
    /*
     *  @Author:        Mark David De Chavez
     *  @Date-created:  Oct. 14, 2014
     *  @Description:   accepts the parameter enddate if there's any, defaults to week's enddate if there's none      
     */
    public CsCaseTimeSummaryController() {
        Date defaultStartDate = (Date.today().toStartofWeek());
        Date defaultEndDate = defaultStartDate.addDays(6);
        timecardSummaryList = new List<CsCaseTimeSummaryWrapper>();
        
        endDate = (ApexPages.currentPage().getParameters().get('EndDate') != null ?
                         Date.valueOf(ApexPages.currentPage().getParameters().get('EndDate')) :
                         defaultEndDate);
        
        caseTimeSummary();
    }
    
    /*
     *  @Author:        Mark David De Chavez
     *  @Date-created:  Oct. 14, 2014
     *  @Description:   Summarizes the case time entry of the current user
     *  @Param;         NONE
     */
    public void caseTimeSummary(){    
        
        SYstem.debug('xxxdateCtrl2: '+ endDate);
        
        sun = endDate.addDays(-6).month() + '/' + endDate.addDays(-6).day();
        mon = endDate.addDays(-5).month() + '/' + endDate.addDays(-5).day();
        tue = endDate.addDays(-4).month() + '/' + endDate.addDays(-4).day();
        wed = endDate.addDays(-3).month() + '/' + endDate.addDays(-3).day();
        thu = endDate.addDays(-2).month() + '/' + endDate.addDays(-2).day();
        fri = endDate.addDays(-1).month() + '/' + endDate.addDays(-1).day();
        sat = endDate.month() + '/' + endDate.day();
        
        CsCaseTimeSummaryWrapper timeCardCSupport = new CsCaseTimeSummaryWrapper();
        CsCaseTimeSummaryWrapper timeCardNonCSupport = new CsCaseTimeSummaryWrapper();
        CsCaseTimeSummaryWrapper timeCardTotal = new CsCaseTimeSummaryWrapper();
        
        timeCardCSupport.timeType = 'Customer Support Time';
        timeCardNonCSupport.timeType = 'Non-Customer Support Time';
        timeCardTotal.timeType  = 'Total';
        
                
        //Id testUserId = '005W0000001FO0O';
        
        //queries the timecard of the current user
        System.debug('**usrID22: '+ UserInfo.getUserId());
        System.debug('**data12312: '+ [SELECT Id, pse__Project__r.pse__Account__r.Id, pse__Resource__r.pse__Salesforce_User__c, pse__Project__r.pse__Project_Type__c,
                                               pse__Sunday_Hours__c, pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c, pse__Thursday_Hours__c, pse__Friday_Hours__c, pse__Saturday_Hours__c  
                                               FROM pse__Timecard_Header__c 
                                               WHERE (pse__Start_Date__c = : endDate.addDays(-6) AND pse__End_Date__c = : endDate) 
                                               AND pse__Resource__r.pse__Salesforce_User__c =: UserInfo.getUserId()]);
        for (pse__Timecard_Header__c tmCard : [SELECT Id, pse__Project__r.pse__Account__r.Id, pse__Resource__r.pse__Salesforce_User__c, pse__Project__r.pse__Project_Type__c,
                                               pse__Sunday_Hours__c, pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c, pse__Thursday_Hours__c, pse__Friday_Hours__c, pse__Saturday_Hours__c  
                                               FROM pse__Timecard_Header__c 
                                               WHERE (pse__Start_Date__c = : endDate.addDays(-6) AND pse__End_Date__c = : endDate) 
                                               AND pse__Resource__r.pse__Salesforce_User__c =: UserInfo.getUserId()]) {                                                               
                                                   
            //filter project type =  Customer Support                                                   
            if (tmCard.pse__Project__r.pse__Project_Type__c == 'Customer Support') {  
                timeCardCSupport.numTmCards = ( timeCardCSupport.numTmCardS != null ? timeCardCSupport.numTmCardS + 1 : 1 );
                timeCardCSupport.sunHours = ( timeCardCSupport.sunHours != null ? (timeCardCSupport.sunHours + tmCard.pse__Sunday_Hours__c) : tmCard.pse__Sunday_Hours__c);
                timeCardCSupport.monHours = ( timeCardCSupport.monHours != null ? (timeCardCSupport.monHours + tmCard.pse__Monday_Hours__c) : tmCard.pse__Monday_Hours__c);
                timeCardCSupport.tueHours = ( timeCardCSupport.tueHours != null ? (timeCardCSupport.tueHours + tmCard.pse__Tuesday_Hours__c) : tmCard.pse__Tuesday_Hours__c);
                timeCardCSupport.wedHours = ( timeCardCSupport.wedHours != null ? (timeCardCSupport.wedHours + tmCard.pse__Wednesday_Hours__c) : tmCard.pse__Wednesday_Hours__c);
                timeCardCSupport.thuHours = ( timeCardCSupport.thuHours != null ? (timeCardCSupport.thuHours + tmCard.pse__Thursday_Hours__c) : tmCard.pse__Thursday_Hours__c);
                timeCardCSupport.friHours = ( timeCardCSupport.friHours != null ? (timeCardCSupport.friHours + tmCard.pse__Friday_Hours__c) : tmCard.pse__Friday_Hours__c);
                timeCardCSupport.satHours = ( timeCardCSupport.satHours != null ? (timeCardCSupport.satHours + tmCard.pse__Saturday_Hours__c) : tmCard.pse__Saturday_Hours__c);
                timeCardCSupport.totalHours = ( timeCardCSupport.totalHours != null ? timeCardCSupport.totalHours + tmCard.pse__Sunday_Hours__c + tmCard.pse__Monday_Hours__c + tmCard.pse__Tuesday_Hours__c + tmCard.pse__Wednesday_Hours__c + tmCard.pse__Thursday_Hours__c + tmCard.pse__Friday_Hours__c + tmCard.pse__Saturday_Hours__c 
                                                                      : tmCard.pse__Sunday_Hours__c + tmCard.pse__Monday_Hours__c + tmCard.pse__Tuesday_Hours__c + tmCard.pse__Wednesday_Hours__c + tmCard.pse__Thursday_Hours__c + tmCard.pse__Friday_Hours__c + tmCard.pse__Saturday_Hours__c );
            }
            //filter project type != Customer Support                                                   
            else {
                timeCardNonCSupport.numTmCards = ( timeCardNonCSupport.numTmCardS != null ? timeCardNonCSupport.numTmCardS + 1 : 1 );
                timeCardNonCSupport.sunHours = ( timeCardNonCSupport.sunHours != null ? (timeCardNonCSupport.sunHours + tmCard.pse__Sunday_Hours__c) : tmCard.pse__Sunday_Hours__c);
                timeCardNonCSupport.monHours = ( timeCardNonCSupport.monHours != null ? (timeCardNonCSupport.monHours + tmCard.pse__Monday_Hours__c) : tmCard.pse__Monday_Hours__c);
                timeCardNonCSupport.tueHours = ( timeCardNonCSupport.tueHours != null ? (timeCardNonCSupport.tueHours + tmCard.pse__Tuesday_Hours__c) : tmCard.pse__Tuesday_Hours__c);
                timeCardNonCSupport.wedHours = ( timeCardNonCSupport.wedHours != null ? (timeCardNonCSupport.wedHours + tmCard.pse__Wednesday_Hours__c) : tmCard.pse__Wednesday_Hours__c);
                timeCardNonCSupport.thuHours = ( timeCardNonCSupport.thuHours != null ? (timeCardNonCSupport.thuHours + tmCard.pse__Thursday_Hours__c) : tmCard.pse__Thursday_Hours__c);
                timeCardNonCSupport.friHours = ( timeCardNonCSupport.friHours != null ? (timeCardNonCSupport.friHours + tmCard.pse__Friday_Hours__c) : tmCard.pse__Friday_Hours__c);
                timeCardNonCSupport.satHours = ( timeCardNonCSupport.satHours != null ? (timeCardNonCSupport.satHours + tmCard.pse__Saturday_Hours__c) : tmCard.pse__Saturday_Hours__c);
                timeCardNonCSupport.totalHours = ( timeCardNonCSupport.totalHours != null ? timeCardNonCSupport.totalHours + tmCard.pse__Sunday_Hours__c + tmCard.pse__Monday_Hours__c + tmCard.pse__Tuesday_Hours__c + tmCard.pse__Wednesday_Hours__c + tmCard.pse__Thursday_Hours__c + tmCard.pse__Friday_Hours__c + tmCard.pse__Saturday_Hours__c 
                                                                      : tmCard.pse__Sunday_Hours__c + tmCard.pse__Monday_Hours__c + tmCard.pse__Tuesday_Hours__c + tmCard.pse__Wednesday_Hours__c + tmCard.pse__Thursday_Hours__c + tmCard.pse__Friday_Hours__c + tmCard.pse__Saturday_Hours__c );
            }
                                                   
            //Compute the total                                      
            timeCardTotal.numTmCards = ( timeCardTotal.numTmCardS != null ? timeCardTotal.numTmCardS + 1 : 1 );
            timeCardTotal.sunHours = ( timeCardTotal.sunHours != null ? (timeCardTotal.sunHours + tmCard.pse__Sunday_Hours__c) : tmCard.pse__Sunday_Hours__c);
            timeCardTotal.monHours = ( timeCardTotal.monHours != null ? (timeCardTotal.monHours + tmCard.pse__Monday_Hours__c) : tmCard.pse__Monday_Hours__c);
            timeCardTotal.tueHours = ( timeCardTotal.tueHours != null ? (timeCardTotal.tueHours + tmCard.pse__Tuesday_Hours__c) : tmCard.pse__Tuesday_Hours__c);
            timeCardTotal.wedHours = ( timeCardTotal.wedHours != null ? (timeCardTotal.wedHours + tmCard.pse__Wednesday_Hours__c) : tmCard.pse__Wednesday_Hours__c);
            timeCardTotal.thuHours = ( timeCardTotal.thuHours != null ? (timeCardTotal.thuHours + tmCard.pse__Thursday_Hours__c) : tmCard.pse__Thursday_Hours__c);
            timeCardTotal.friHours = ( timeCardTotal.friHours != null ? (timeCardTotal.friHours + tmCard.pse__Friday_Hours__c) : tmCard.pse__Friday_Hours__c);
            timeCardTotal.satHours = ( timeCardTotal.satHours != null ? (timeCardTotal.satHours + tmCard.pse__Saturday_Hours__c) : tmCard.pse__Saturday_Hours__c);
            timeCardTotal.totalHours = ( timeCardTotal.totalHours != null ? timeCardTotal.totalHours + tmCard.pse__Sunday_Hours__c + tmCard.pse__Monday_Hours__c + tmCard.pse__Tuesday_Hours__c + tmCard.pse__Wednesday_Hours__c + tmCard.pse__Thursday_Hours__c + tmCard.pse__Friday_Hours__c + tmCard.pse__Saturday_Hours__c 
                                                                           : tmCard.pse__Sunday_Hours__c + tmCard.pse__Monday_Hours__c + tmCard.pse__Tuesday_Hours__c + tmCard.pse__Wednesday_Hours__c + tmCard.pse__Thursday_Hours__c + tmCard.pse__Friday_Hours__c + tmCard.pse__Saturday_Hours__c );
        }
        
        //Add to final list
        timecardSummaryList.add(timeCardCSupport);
        timecardSummaryList.add(timeCardNonCSupport);   
        timecardSummaryList.add(timeCardTotal);
    }
    
    public void mapEndingDate() {
        SYstem.debug('xxxdateCtrl: '+ dateCtrl);
        endDate = (dateCtrl == 'prev' ? endDate.addDays(-7) : endDate.addDays(7));
        SYstem.debug('xxxdateCtrl1: '+ endDate);
        timecardSummaryList.clear();
        caseTimeSummary(); 
    }
    
    
    
    /*
     *  @Author:        Mark David De Chavez
     *  @Date-created:  Oct. 14, 2014
     *  @Description:   Class needed to be able to summarize case time entry
     */
    public class CsCaseTimeSummaryWrapper {
        public String timeType { get; set; }
        public Decimal numTmCards { get; set; }
        public Decimal sunHours { get; set; }
        public Decimal monHours { get; set; }
        public Decimal tueHours { get; set; }
        public Decimal wedHours { get; set; }
        public Decimal thuHours { get; set; }
        public Decimal friHours { get; set; }
        public Decimal satHours { get; set; }
        public Decimal totalHours { get; set;}        
    }
    
}