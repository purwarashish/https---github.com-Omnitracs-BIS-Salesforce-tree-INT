/***********************************************************************************
Author: Bhanushree, Salesforce.com Developer
Tata Consultancy Services Limited
Description : This class is called from Resource Planner vf page.
************************************************************************************/

public class ExportToExcelControllerAttachment
{
    public static List<SelectOption> lstResourceType {get;set;}                        //List used to select resources
    public static List<SelectOption> lstDuration{get;set;}                            //List used to select duration
    Public static List<date> lstWeekKey;                                             //List used to store weekly date
    
    public static Set < Id > SetScheduleId;                                         //set used to store schedule Id's
    
    public static Date fromDate{get;set;}                                          //Used in Vf page to select From date
    public static Date toDate{get;set;}                                            //Used in Vf page to select To date
    public static Date startDate{get;set;}                                         //Stores User entered from date
    public static Date endDate{get;set;}                                          //Stores user entered end date
    public static Date tempDate;
    
    public static Map<Date,Double> mapDaysValue{get;set;}                             //Stores the date and corresponding value of the day
    public static Map<String,list<String>>MapUserName;                               //Stores the Username and corresponding list of schedule Id's
    public static Map<Id,Map<date,Double>> mapSchedule{get;set;}                     //Stores the schedule Id's and corresponding day map with date and value
    public static Map<String,Map<date,double>> MapFinalData {get;set;}              //Stores the Username and corresponding day map with date and value
    public static Map<date,Double> mapWeeklyValue{get;set;}                         //Stores the week date and default value of the week
    public static Map<String,Map<date,double>> MapFinalWeek{get;set;}               //Stores the Username and corresponding weekly map with date and value
    public static  Map<String,Map<String,double>> MapFinalMonthly{get;set;}          //Stores the Username and corresponding monthly map with month name and value
    public static Map<String,Map<String,double>> MapFinalQuarters{get;set;}         //Stores the Username and corresponding week map with date and value
    public static Map < String, double > mapOfMonth{get;set;}                     //Stores the month name and default value for the month
    public static Map < String, double > mapOfQuarters{get;set;}                  //Stores the quarter name and default value for the quarter
    
    
    public pse__Assignment__c objPseAssignment{get;set;}                      //Used to fetch values from vf page
    
    public static String selectedResourceType{get;set;}                             //Stores selected Resource Type
    public static String selectedDuration{get;set;}                                 //Stores selected Duration
    public static String strResourceName{get;set;}                                  //Stores selected Resource Name
    public static String StrQuery = '';                                             //Used to construct query
    public static String soqlQuery = 'Select Id,pse__Schedule__r.pse__Start_Date__c,pse__Schedule__r.pse__End_Date__c,Name,pse__Start_Date__c,pse__End_Date__c,pse__Resource__r.Name,pse__Resource__c,pse__Resource__r.pse__Is_Resource__c,pse__Resource__r.pse__Is_Resource_Active__c,pse__Schedule__r.Id,pse__Schedule__r.pse__Sunday_Hours__c, pse__Schedule__r.pse__Monday_Hours__c,pse__Schedule__r.pse__Tuesday_Hours__c,pse__Schedule__r.pse__Wednesday_Hours__c,pse__Schedule__r.pse__Thursday_Hours__c,pse__Schedule__r.pse__Friday_Hours__c, pse__Schedule__r.pse__Saturday_Hours__c from pse__Assignment__c ';
    public String strBlue{get;set;}
    public String strBluryWood{get;set;}
    public String strRed{get;set;}
    public String strChoclate{get;set;}
    public String strWhite{get;set;}
    
    Public Boolean blnStaticRes{get;set;}
    
    Public List<PSE_Color_Code__c> lstColorCode{get;set;}
    Public static List<string> lstMonthKey{get;set;}
    Public static List<string> lstQuarterKey{get;set;}
     
    public static set<string>setMonthKey{get;set;}
    public static set<string> setQuarterKey{get;set;}
    
    public static map < String, double > tempMapMonthValue =new map < String, double >();
    public static map < String, double > tempMapQuarterValue=new map < String, double >();
    public static map < date, double > tempMapDaysValue = new map < date, double >();
    public static map < date, double > tempMapWeekValue =new map < date, double >();
   //Constructor used to construct picklist values
    public ExportToExcelControllerAttachment()
    {
       
        objPseAssignment = new pse__Assignment__c();
        
        lstColorCode= PSE_Color_Code__c.getall().values();
        
        for(Integer i=0;i<lstColorCode.size();i++)
        {
            if(lstColorCode[i].name=='30-41 Hours')
            {
                strWhite=lstColorCode[i].Color__c;
            }
            else if(lstColorCode[i].name=='10-19 Hours')
            {
                strChoclate=lstColorCode[i].Color__c;
            }
            else if(lstColorCode[i].name=='42 hours or more')
            {
                strBlue=lstColorCode[i].Color__c;
            }
            else if(lstColorCode[i].name=='Less than 10 hours')
            {    
                strRed=lstColorCode[i].Color__c;
            }
            else 
            {
                strBluryWood=lstColorCode[i].Color__c;
            }
        } 
        fromDate=Date.valueOf(apexpages.currentpage().getparameters().get('fromDate'));
        toDate=Date.valueOf(apexpages.currentpage().getparameters().get('toDate'));
        selectedDuration=apexpages.currentpage().getparameters().get('selectedDuration');
        strResourceName=apexpages.currentpage().getparameters().get('strResourceName');
        selectedResourceType=apexpages.currentpage().getparameters().get('selectedResourceType');
        system.debug('fromDate'+fromDate);
       system.debug('toDate'+toDate);
        exportToExcelAttachment(fromDate,toDate,selectedDuration,strResourceName,selectedResourceType);
        
       
       // return pageRef;
    }

public void exportToExcelAttachment(Date fromDate1,Date toDate1,string selectedDurations,string strResourceNames,String strselectedResourceType)
{
      fromDate=fromDate1;
      toDate=toDate1;
      selectedDuration=selectedDurations;
      strResourceName=strResourceNames;
      selectedResourceType= strselectedResourceType;
      if(selectedDuration=='Weekly' || selectedDuration=='Daily')
       {
      startDate=convertStartDateofWeek(fromDate);
      endDate=convertEndDateOftheWeek(toDate);
      }
      else
      {
          startDate=fromDate;
          endDate=toDate;
      }
      system.debug('startDate'+startDate);
      system.debug('endDate'+endDate);
       getAssignments() ;
     
        if(selectedDuration=='Daily')
        {
            mapWeeklyValue.clear();
            mapOfMonth.clear();
            mapOfQuarters.clear();
            MapFinalQuarters.clear();
            MapFinalMonthly.clear();
            MapFinalWeek.clear();
        }
        else if(selectedDuration=='Weekly')
        {
            mapOfMonth.clear();
            mapOfQuarters.clear();
            MapFinalQuarters.clear();
            MapFinalMonthly.clear();
            MapFinalData.clear();
            mapDaysValue.clear();
        }
        else if(selectedDuration=='Monthly')
        {
            mapOfQuarters.clear();
            MapFinalQuarters.clear();
            MapFinalData.clear();
            mapDaysValue.clear();
            MapFinalWeek.clear();
            MapFinalData.clear();
            mapDaysValue.clear();
        }
        else
        {
            mapOfMonth.clear();
            MapFinalMonthly.clear();
            MapFinalWeek.clear();
            MapFinalWeek.clear();
            MapFinalData.clear();
            mapDaysValue.clear();
        }
        
}
    
    //Fetch assignments and consrtuct a base map of username and its related schedule
    public static void getAssignments()
    {
      
        List < Id > scheduleIds = new List < Id > ();
        Set < Id > SetscheduleIds = new Set < Id > ();
        tempDate = startDate;
        map < date, double > mapDaysValues = createDaysMap();
        system.debug('mapOfMonth..................'+mapOfMonth);
        tempMapMonthValue=mapOfMonth.clone();
        tempMapQuarterValue=mapOfQuarters.clone();
        tempMapDaysValue=mapDaysValue.clone();
        tempMapWeekValue=mapWeeklyValue.clone();
        system.debug('tempMapMonthValue..................'+tempMapMonthValue);
        lstMonthKey=new list<string>(setMonthKey);
        lstQuarterKey=new list<string>(setQuarterKey);
        if ((selectedResourceType == 'singleResource') && (selectedResourceType != null && selectedResourceType != '')) 
        {
          
            StrQuery = 'where pse__Exclude_from_Planners__c=false and ((pse__Start_Date__c>=:startDate AND pse__End_Date__c<=:endDate) OR(pse__Start_Date__c<=:startDate AND pse__End_Date__c>=:endDate)OR(pse__Start_Date__c<=:endDate AND pse__End_Date__c>=:endDate)OR(pse__Start_Date__c<=:startDate AND pse__End_Date__c>=:startDate)) and pse__Resource__r.pse__Is_Resource__c=true and pse__Resource__r.pse__Is_Resource_Active__c=True and pse__Resource__r.recordtype.Name=\'Resource\' and pse__Resource__r.pse__Practice__r.Name in(\'Professional Services\',\'Technical Solutions\') and pse__Resource__r.pse__Resource_Role__c in(\'Trainer\',\'Software Engineer\',\'Project Manager\') and pse__Resource__r.pse__Group__r.name in(\'XRS\',\'Omnitracs US\') and pse__Resource__r.Name=:strResourceName';
        } 
        else 
        {
            StrQuery = 'where pse__Exclude_from_Planners__c=false  and ((pse__Start_Date__c>=:startDate AND pse__End_Date__c<=:endDate) OR(pse__Start_Date__c<=:startDate AND pse__End_Date__c>=:endDate)OR(pse__Start_Date__c<=:endDate AND pse__End_Date__c>=:endDate)OR(pse__Start_Date__c<=:startDate AND pse__End_Date__c>=:startDate)) and pse__Resource__r.pse__Is_Resource__c=true and pse__Resource__r.pse__Is_Resource_Active__c=True and pse__Resource__r.recordtype.Name=\'Resource\' and pse__Resource__r.pse__Practice__r.Name in(\'Professional Services\',\'Technical Solutions\') and pse__Resource__r.pse__Resource_Role__c in(\'Trainer\',\'Software Engineer\',\'Project Manager\') and pse__Resource__r.pse__Group__r.name in(\'XRS\',\'Omnitracs US\')';
         
        }
        soqlQuery = soqlQuery + StrQuery + ' limit 50000'; 
           
        List < pse__Assignment__c > lstAssignments = Database.query(soqlQuery); 
        
        
        mapSchedule = new Map <Id,Map<date,Double >> ();
        MapUserName = new Map < String, list < String >> ();
        for (pse__Assignment__c objAssignment: lstAssignments)
        {
            SetscheduleIds.add(objAssignment.pse__Schedule__c);
            if (!mapSchedule.containsKey(objAssignment.pse__Schedule__c))
            {
                mapSchedule.put(objAssignment.pse__Schedule__c, mapDaysValues );
            }
            list < String > lstSchduleId = new list < String > ();
            if (!MapUserName.containsKey(objAssignment.pse__Resource__r.Name))
            {
                lstSchduleId.add(objAssignment.pse__Schedule__r.Id);
                MapUserName.put(objAssignment.pse__Resource__r.Name, lstSchduleId);
            } 
            else
            {
                MapUserName.get(objAssignment.pse__Resource__r.Name).add(objAssignment.pse__Schedule__r.Id);
            }
        }
        constructMapWithValues(SetscheduleIds);
    }
    
    //Method to consrtuct map with actual values
    public static void constructMapWithValues(Set < Id > SetscheduleIds) 
    {
        Double dayValue=0.0;
        Double schDayVal=0.0;
        Double tempWeekVal=0.0;
        Date indexkey;
        Double tempMonthVal=0.0;
        Double tempQuarterVal=0.0;
        list < pse__Schedule__c > lstSchedule = [Select Id, pse__Start_Date__c, pse__End_Date__c, pse__Sunday_Hours__c, pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c, pse__Thursday_Hours__c, pse__Friday_Hours__c, pse__Saturday_Hours__c, (select id, pse__Schedule__r.id, pse__Exception_Hours__c, pse__End_Date__c, pse__Friday_Hours__c, pse__Monday_Hours__c, pse__Saturday_Hours__c, pse__Schedule__c, pse__Sunday_Hours__c, pse__Date__c, pse__Thursday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c from pse__Schedule_Exceptions__r), (Select Id, name, pse__Resource__r.Name, pse__Resource__c, pse__Resource__r.pse__Is_Resource__c, pse__Resource__r.pse__Is_Resource_Active__c, pse__Schedule__c from pse__Assignments__r where pse__Resource__r.pse__Is_Resource__c=true and pse__Resource__r.pse__Is_Resource_Active__c=True and pse__Resource__r.recordtype.Name='Resource' and pse__Resource__r.pse__Practice__r.Name in('Professional Services','Technical Solutions') and pse__Resource__r.pse__Resource_Role__c in('Trainer','Software Engineer','Project Manager') and pse__Resource__r.pse__Group__r.name in('XRS','Omnitracs US') and pse__Exclude_from_Planners__c=false  limit 1) from pse__Schedule__c where((pse__Start_Date__c>=:startDate AND pse__End_Date__c<=:endDate) OR(pse__Start_Date__c<=:startDate AND pse__End_Date__c>=:endDate)OR(pse__Start_Date__c<=:endDate AND pse__End_Date__c>=:endDate)OR(pse__Start_Date__c<=:startDate AND pse__End_Date__c>=:startDate)) and id = : SetscheduleIds limit 50000];
        list<String> lstUser = new list<String>();
        system.debug('tempMapMonthValue..................'+tempMapMonthValue);
        //map < String, double > tempMapMonthValue = tempMapMonthValue.clone();
        
        MapFinalWeek = new Map < String, Map < date, double >> ();
        MapFinalData=new Map < String, Map < date, double >> ();
        MapFinalMonthly=new Map < String, Map < String, double >> ();
        MapFinalQuarters=new Map < String, Map < String, double >> ();
        List < pse__Assignment__c > lstpseScheduleResName = new List < pse__Assignment__c >();
        system.debug('MapFinalMonthly'+MapFinalMonthly);
        for (Integer i = 0; i < lstSchedule.size(); i++)
        {           
        
            Date schStartDate;
            Date schEndDate;
            List < pse__Schedule_Exception__c > lstpseScheduleExcep = lstSchedule[i].pse__Schedule_Exceptions__r;          
         
            lstpseScheduleResName.clear();
            lstpseScheduleResName = lstSchedule[i].pse__Assignments__r;
            if(lstSchedule[i].pse__Start_Date__c < startDate)
            {
                schStartDate=startDate;
            }
            else
            {
                schStartDate=lstSchedule[i].pse__Start_Date__c;
            }
            if(lstSchedule[i].pse__End_Date__c>endDate )
            {
                schEndDate=endDate ;
            }
            else
            {
                schEndDate=lstSchedule[i].pse__End_Date__c;
            }
            Integer noOfDaysInSch=(schStartDate.daysBetween(schEndDate))+1;
            system.debug('schStartDate'+schStartDate);
            Date keyDate=schStartDate;
            system.debug('keyDate'+keyDate);
            if (MapFinalData != null && (lstpseScheduleResName.size()==1))
            {
            if (!MapFinalData.containskey(lstpseScheduleResName[0].pse__Resource__r.Name) && !MapFinalWeek.containskey(lstpseScheduleResName[0].pse__Resource__r.Name))
            {
                mapDaysValue = tempMapDaysValue.clone();
            }
            else
            {
             mapDaysValue = MapFinalData.get(lstpseScheduleResName[0].pse__Resource__r.Name);
            }
            }
            for(Integer j=0;j<noOfDaysInSch;j++)
            {
               
                if (MapFinalData.get(lstpseScheduleResName[0].pse__Resource__r.Name) != null && MapFinalData.get(lstpseScheduleResName[0].pse__Resource__r.Name).get(keyDate) != null)
                {
                   
                    dayValue = MapFinalData.get(lstpseScheduleResName[0].pse__Resource__r.Name).get(keyDate);
                                  
                    schDayVal = dayValue;
                }
                else
                {
                    dayValue = 0.0;
                    schDayVal = dayValue; // added by ragesh
                }
                Datetime keyDTVal = DateTime.newInstance(keyDate, Time.newInstance(0, 0, 0, 0));
                String dateOftheWeek =keyDTVal.format('EEEE');
                if (dateOftheWeek == 'Sunday')
                {
                    dayValue =dayValue + lstSchedule[i].pse__Sunday_Hours__c;
                }
                else if (dateOftheWeek == 'Monday')
                {
                    dayValue =dayValue + lstSchedule[i].pse__Monday_Hours__c; 
                }
                else if (dateOftheWeek == 'Tuesday')
                {
                    dayValue =dayValue + lstSchedule[i].pse__Tuesday_Hours__c;
                }
                else if (dateOftheWeek == 'Wednesday')
                {
                    dayValue =dayValue + lstSchedule[i].pse__Wednesday_Hours__c;
                }
                else if (dateOftheWeek == 'Thursday')
                {
                    dayValue = dayValue + lstSchedule[i].pse__Thursday_Hours__c;
                }
                else if (dateOftheWeek == 'Friday')
                {
                    dayValue =dayValue + lstSchedule[i].pse__Friday_Hours__c;
                } else if (dateOftheWeek == 'Saturday')
                {
                    dayValue = dayValue + lstSchedule[i].pse__Saturday_Hours__c;
                }
                for(Integer m=0;m<lstpseScheduleExcep.size();m++)
                {
                    //system.debug('lstpseScheduleExcep++Id'+lstpseScheduleExcep[m].id);  
                    Date schExceStartDate=lstpseScheduleExcep[m].pse__Date__c;
                    Date schExceEndDate=lstpseScheduleExcep[m].pse__End_Date__c;
                    if(keyDate>=schExceStartDate && keyDate<=schExceEndDate)
                    {
                        if (dateOftheWeek == 'Sunday')
                        {
                            dayValue=dayValue + lstpseScheduleExcep[m].pse__Saturday_Hours__c- lstSchedule[i].pse__Sunday_Hours__c;
                        }
                        else if (dateOftheWeek == 'Monday')
                        {
                            dayValue =dayValue+lstpseScheduleExcep[m].pse__Monday_Hours__c- lstSchedule[i].pse__Monday_Hours__c;
                        }
                        else if (dateOftheWeek == 'Tuesday')
                        {
                            dayValue =dayValue + lstpseScheduleExcep[m].pse__Tuesday_Hours__c - lstSchedule[i].pse__Tuesday_Hours__c;
                        }
                        else if (dateOftheWeek == 'Wednesday')
                        {
                            dayValue = dayValue +  lstpseScheduleExcep[m].pse__Wednesday_Hours__c - lstSchedule[i].pse__Wednesday_Hours__c;
                        }
                        else if (dateOftheWeek == 'Thursday')
                        {
                            dayValue =dayValue + lstpseScheduleExcep[m].pse__Thursday_Hours__c - lstSchedule[i].pse__Thursday_Hours__c;
                        }
                        else if (dateOftheWeek == 'Friday')
                        {
                            dayValue =dayValue + lstpseScheduleExcep[m].pse__Friday_Hours__c - lstSchedule[i].pse__Friday_Hours__c;
                        } else if (dateOftheWeek == 'Saturday')
                        {
                            dayValue =dayValue + lstpseScheduleExcep[m].pse__Saturday_Hours__c - lstSchedule[i].pse__Saturday_Hours__c;
                        }
                    }
                                 
                }
                 mapDaysValue.put(keyDate, dayValue);      
                
                if(selectedDuration=='Weekly')
                {
                    integer weekDays = startDate.daysBetween(keyDate);                   
                    system.debug('++++++keyDate'+keyDate);
                    
                    if (!mapWeeklyValue.isEmpty()) 
                    {                      
                        weekDays=weekDays/7;
                        
                        indexkey = lstWeekKey[weekDays];
                       
                    }
                    if (MapFinalWeek.containsKey(lstpseScheduleResName[0].pse__Resource__r.Name))
                    {
                        Map < date, Double > tempMapWeek = new Map < date, Double > ();
                        
                            tempWeekVal =0;
                            tempMapWeek.clear();
                            mapWeeklyValue=MapFinalWeek.get(lstpseScheduleResName[0].pse__Resource__r.Name);
                                if (mapWeeklyValue.containsKey(keyDate))
                                {
                                    tempWeekVal = MapFinalWeek.get(lstpseScheduleResName[0].pse__Resource__r.Name).get(keyDate);
                                    System.debug('tempWeekVal------------->'+tempWeekVal);
                                    tempWeekVal = tempWeekVal +dayValue - schDayVal;
                                     mapWeeklyValue.put(keyDate, tempWeekVal);
                                    tempMapWeek = mapWeeklyValue.clone();
                                    MapFinalWeek.put(lstpseScheduleResName[0].pse__Resource__r.Name, mapWeeklyValue);
                                } 
                                else
                                {
                                    tempWeekVal = MapFinalWeek.get(lstpseScheduleResName[0].pse__Resource__r.Name).get(indexkey);
                                    if(tempWeekVal==null){tempWeekVal =0.0;}
                                   
                                    tempWeekVal = tempWeekVal +dayValue - schDayVal;
                                    system.debug('*****tempWeekVal*****'+tempWeekVal);
                                    mapWeeklyValue.put(indexkey, tempWeekVal);
                                    tempMapWeek = mapWeeklyValue.clone();
                                    MapFinalWeek.put(lstpseScheduleResName[0].pse__Resource__r.Name, mapWeeklyValue);
                                }
                            
                    }
                    else
                    {
                        mapWeeklyValue=tempMapWeekValue.clone();
                        tempWeekVal =dayValue;
                        Map < date, Double > tempWeekMap = new Map < date, Double > ();
                        
                        mapWeeklyValue.put(indexkey, tempWeekVal);
                        tempWeekMap = mapWeeklyValue.clone();
                        MapFinalWeek.put(lstpseScheduleResName[0].pse__Resource__r.Name, tempWeekMap);
                    }
                }
                if (MapFinalData.containsKey(lstpseScheduleResName[0].pse__Resource__r.Name))
                {
                    Map < date, Double > tempMap = new Map < date, Double > ();
                    tempMap = mapDaysValue.clone();
                    MapFinalData.put(lstpseScheduleResName[0].pse__Resource__r.Name, tempMap);
                }
                else
                {
                    Map < date, Double > tempMap = new Map < date, Double > ();
                    tempMap = mapDaysValue.clone();
                    MapFinalData.put(lstpseScheduleResName[0].pse__Resource__r.Name, tempMap);
                }
                
                if(selectedDuration=='Monthly' && keyDate>=fromDate && keyDate<=toDate)
                {
               
                    Map < String, Double > tempMap = new Map <String, Double > ();
                    system.debug('mapOfMonth........'+mapOfMonth);
                    system.debug('keyDate........'+keyDate);
                    if(MapFinalMonthly.containsKey(lstpseScheduleResName[0].pse__Resource__r.Name))
                    {
                        tempMonthVal =0.0;
                        string strMonthName=getMonthNameOftheDate(keyDate);
                        mapOfMonth=MapFinalMonthly.get(lstpseScheduleResName[0].pse__Resource__r.Name);
                        if (mapOfMonth.containsKey(strMonthName))
                        {
                            tempMonthVal = MapFinalMonthly.get(lstpseScheduleResName[0].pse__Resource__r.Name).get(strMonthName);
                            tempMonthVal = tempMonthVal +dayValue - schDayVal;
                            mapOfMonth.put(strMonthName, tempMonthVal );
                            tempMap = mapOfMonth.clone();
                            MapFinalMonthly.put(lstpseScheduleResName[0].pse__Resource__r.Name, tempMap);
                        } 
                        else
                        {
                            
                            if(MapFinalMonthly.get(lstpseScheduleResName[0].pse__Resource__r.Name).get(strMonthName)!=null)
                             {  tempMonthVal = MapFinalMonthly.get(lstpseScheduleResName[0].pse__Resource__r.Name).get(strMonthName);
                                tempMonthVal = tempMonthVal +dayValue - schDayVal;
                            }
                            mapOfMonth.put(strMonthName, tempMonthVal );
                            tempMap = mapOfMonth.clone();
                            MapFinalMonthly.put(lstpseScheduleResName[0].pse__Resource__r.Name, tempMap);
                        }
                    }
                    else
                    {
                        system.debug('tempMapMonthValue'+tempMapMonthValue);
                        mapOfMonth=tempMapMonthValue.clone();
                        string strMonthName=getMonthNameOftheDate(keyDate);
                        system.debug('step 1'+strMonthName+'keyDate'+keyDate);
                         system.debug('step 1'+mapOfMonth);
                        mapOfMonth.put(strMonthName,dayValue);
                        tempMap = mapOfMonth.clone();
                        MapFinalMonthly.put(lstpseScheduleResName[0].pse__Resource__r.Name,tempMap );
                    }
                    
                    
                }
                if(selectedDuration=='Quarterly')
                {
                    
                    Map < String, Double > tempMap = new Map <String, Double > ();
                    if(MapFinalQuarters.containsKey(lstpseScheduleResName[0].pse__Resource__r.Name))
                    {
                        tempQuarterVal =0.0;
                        string strQuarterName=getQuarterNameOftheDate(keyDate);
                        mapOfQuarters=MapFinalQuarters.get(lstpseScheduleResName[0].pse__Resource__r.Name);
                        if (mapOfQuarters.containsKey(strQuarterName))
                        {
                            tempMap =MapFinalQuarters.get(lstpseScheduleResName[0].pse__Resource__r.Name);
                            tempQuarterVal = tempMap.get(strQuarterName);
                            if(tempQuarterVal ==null)tempQuarterVal =0.0;
                            tempQuarterVal = tempQuarterVal +dayValue- schDayVal;
                            mapOfQuarters=tempMap;
                            mapOfQuarters.put(strQuarterName, tempQuarterVal );
                            tempMap = mapOfQuarters.clone();
                            MapFinalQuarters.put(lstpseScheduleResName[0].pse__Resource__r.Name, tempMap);
                        } 
                        else
                        {
                            tempMap =MapFinalQuarters.get(lstpseScheduleResName[0].pse__Resource__r.Name);
                            tempQuarterVal = tempMonthVal +dayValue- schDayVal;
                            tempMap.put(strQuarterName, tempQuarterVal );
                            MapFinalQuarters.put(lstpseScheduleResName[0].pse__Resource__r.Name, tempMap);
                        }
                    }
                    else
                    {
                        mapOfQuarters=tempMapQuarterValue.clone();
                        string strQuarterName=getQuarterNameOftheDate(keyDate);
                        mapOfQuarters.put(strQuarterName,dayValue);
                        tempMap = mapOfQuarters.clone();
                        MapFinalQuarters.put(lstpseScheduleResName[0].pse__Resource__r.Name,tempMap );
                    }
                }
                keyDate=keyDate.addDays(1);
            }
        }
        
    }
    
    //Method to fetch start date of the week
    public static Date convertStartDateofWeek(Date fromDate1) 
    {
        startDate = fromDate1.toStartofWeek();
        return startDate;
    }
    
    //Method to fetch end date of the week
    public static Date convertEndDateOftheWeek(Date toDte) 
   {
       Datetime dt = DateTime.newInstance(toDte, Time.newInstance(0, 0, 0, 0));
        String dayOfWeek = dt.format('EEEE');
        if (dayOfWeek == 'Sunday') 
        {
            Datetime newDateTime = dt.addDays(-1);
            endDate = date.newinstance(newDateTime.year(), newDateTime.month(), newDateTime.day());
        } 
        else 
        {
        
            Date startsDateOfEndWeek = toDate.toStartofWeek();
            endDate = startsDateOfEndWeek.addDays(6);
        }
        return endDate;
    }
    
    //Method to fetch day of the date
    public static Integer getdayOftheMonth(Date tempDte) 
    {
        Integer day = tempDte.day();
        return day;
    }
    
    //Method to fetch year of the date
    public static Integer getYearOftheDate(Date tempDte) 
    {
        Integer year = tempDte.year();
        return year;
    }
    
    //Method to fetch month of the date
    public static Integer getMonthOftheDate(Date tempDte) 
    {
        Integer Month = tempDte.Month();
        return Month;
    }
    
    //Method to fetch month name of the date
    public static string getMonthNameOftheDate(Date tempDte)
    {
        Integer Month = tempDte.Month();
        Integer Year=tempDte.Year();
        string monthName;
        if(Month==1)
        {
            monthName='Jan'+Year;
        }
        else if(Month ==2)
        {
            monthName='Feb'+Year;
        }
        else if(Month ==3)
        {
            monthName='March'+Year;
        }
        else if(Month ==4)
        {
            monthName='April'+Year;
        }
        else if(Month ==5)
        {
            monthName='May'+Year;
        }
        else if(Month ==6)
        {
            monthName='June'+Year;
        }
        else if(Month ==7)
        {
            monthName='July'+Year;
        }
        else if(Month ==8)
        {
            monthName='Aug'+Year;
        }
        else if(Month ==9)
        {
            monthName='Sep'+Year;
        }
        else if(Month ==10)
        {
            monthName='Oct'+Year;
        }
        else if(Month ==11)
        {
            monthName='Nov'+Year;
        }
        else if(Month ==12)
        {
            monthName='Dec'+Year;
        }
        return monthName;
    }
    
    //Method to fetch quarter name of the date
    public static string getQuarterNameOftheDate(Date tempDte)
    {
        Integer Month = tempDte.Month();
        Integer Year=tempDte.Year();
        string QuarName;
        if(Month>=1 && Month<=3)
        {
            QuarName='Jan-March'+Year;
        }
        else if(Month>=4 && Month<=6)
        {
            QuarName='Apr-Jun'+Year;
        }
        else if(Month>=7 && Month<=9)
        {
            QuarName='July-Sep'+Year;
        }
        else
        {
          QuarName='Oct-Dec'+Year;
        }
        return QuarName;
    }
    
    //Method to create map with key and default value 
    public static map < date, double > createDaysMap() 
    {
        Date tempstartDate = startDate;
        Date tempWeekDate = startDate;
        Date tempMonthDate = startDate;
        Date tempQuatDate = startDate;
        Date date1;
        Date dateWeek;
        Date dateMonth;
        Date dateQuar;
        String key;
        String weeklyKey;
        String monthlykey;
        String quarterkey;
        integer weekCount;
        Integer noOfDays = (startDate.daysBetween(endDate)) + 1;
        integer j = 6;
        mapDaysValue = new Map < date, Double > ();
        mapWeeklyValue = new Map < date, Double > ();
        mapOfQuarters= new Map < string, Double > ();
        lstWeekKey = new List<date>();
        setMonthKey=new set<string>();
        setQuarterKey=new set<string>();
        mapOfMonth=new map<String,double>();
        for (Integer i = 1; i <= noOfDays; i++)
        {
            
            mapDaysValue.put(tempDate, 0.0d);
            if(tempDate >=fromDate && tempDate <=toDate)
            {
             String strMonth=getMonthNameOftheDate(tempDate );
             system.debug('strMonth'+strMonth);
             setMonthKey.add(strMonth);
             mapOfMonth.put(strMonth,0.0d);
            }
            if(tempDate >=fromDate && tempDate <=toDate)
            {
            String strQuarter=getQuarterNameOftheDate(tempDate );
            setQuarterKey.add(strQuarter);
            mapOfQuarters.put(strQuarter,0.0d);
            }
            date1 = tempDate.addDays(1);
            tempDate = date1;
            if(selectedDuration=='Weekly')
            {
                weekCount = noOfDays / 7;
                if ((j <= noOfDays) && (weekCount != 0))
                {
                    dateWeek = tempWeekDate.addDays(j);
                    tempWeekDate = dateWeek;
                    mapWeeklyValue.put(tempWeekDate , 0.0d);
                    //system.debug('tempWeekDate'+tempWeekDate);
                    lstWeekKey.add(tempWeekDate);
                    tempWeekDate = startDate;
                    j = j + 7;
                    weekCount = weekCount - 7;
                }
            }
        }
         system.debug('mapOfMonth******'+mapOfMonth);
        return mapDaysValue;
    }
}