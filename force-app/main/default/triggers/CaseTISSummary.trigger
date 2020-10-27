/*********************************************************************************** 
Date: 03/01/2010 
Author: Shruti Karn, Salesforce.com Developer 
Tata Consultancy Services Limited 

Overview: When a Case is Created or Edited, the trigger "CaseTISDetail" tracks and captures the changes in the following Case fields: 
1) Status 
2) Queue 

This trigger "CaseTISSummary" consolidates the detailed TIS from TISdetail and create/update records in TISSummary 
************************************************************************************/ 
trigger CaseTISSummary on TIS_Detail__c (after insert, after update) 
{ 

if (Trigger.isAfter) 
{ 
System.debug('-- Case Trigger "CaseTISSummary" initiated because of Update operation--'); 
for (TIS_Detail__c TISDetail :Trigger.new) 
{ 
if (TISDetail.Case__c != null && TISDetail.Date_Time_Out__c != null) 
{ 
Boolean TISHasRecords = false; 
for (TIS_Summary__c TISSum :[Select Id, Contract_Request__c, Name, Last_Date_Time_Out__c, Days__c,Hrs__c, Mins__c
 from TIS_Summary__c where Case__c = :TISDetail.Case__c and Name = :TISDetail.Name and state__c = :TISDetail.state__c]) 
{ 
TISHasRecords = true; 
system.debug(TISSum.Hrs__c); 
system.debug(TISSum.Mins__c); 
System.debug('Records exists in TIS_Summary__c for Case Id:"'+ TISDetail.Case__c +'" and Field Name :"' + TISDetail.Name +'" and Field Value :"' + TISDetail.state__c +'"'); 

if (((TISSum.Mins__c + TISDetail.Mins__c) >= 60 )&& ((TISSum.Mins__c + TISDetail.Mins__c) < 120) ) 
{ 
TISSum.Hrs__c = (TISSum.Hrs__c + TISDetail.Hours__c) + 1; 
TISSum.Mins__c = (TISSum.Mins__c + TISDetail.Mins__c) - 60; 
}else if ((TISSum.Mins__c + TISDetail.Mins__c) == 120) 
{ 
TISSum.Hrs__c = (TISSum.Hrs__c + TISDetail.Hours__c) + 2; 
TISSum.Mins__c = 0 ; 
}else if ((TISSum.Mins__c + TISDetail.Mins__c) < 60 ) 
{ 
TISSum.Hrs__c = TISSum.Hrs__c + TISDetail.Hours__c; 
TISSum.Mins__c = TISSum.Mins__c + TISDetail.Mins__c; 
} 
if(TISDetail.state__c== 'Closed')
                    {
                        TISSum.Hrs__c = 0;
                        TISSum.Mins__c  = 0;
                        TISSum.Days__c = 0;
                    }    
TISSum.Last_Date_Time_Out__c = TISDetail.Date_Time_Out__c; 

//Remove Aging Info 

update TISSum; 
System.debug('**Updated TIS_Summary__c record with SID: "'+ TISSum.Id +'" **'); 

}//end of for loop 

if (TISHasRecords == false ) 
{ 
Try 
{ 
System.debug('No records exists in TIS_Summary__c'); 
System.debug('Create New record in TIS_Summary__c for Case Id:"'+ TISDetail.Case__c +'" and Field Name :"' + TISDetail.Name +'" and Field Value :"' + TISDetail.state__c +'"'); 

TIS_Summary__c TISNew = new TIS_Summary__c(); 
TISNew.Case__c = TISDetail.Case__c; 
TISNew.Name = TISDetail.Name ; 
TISNew.state__c = TISDetail.state__c ; 
TISNew.Last_Date_Time_Out__c = TISDetail.Date_Time_Out__c; 
TISNew.Hrs__c = TISDetail.Hours__c; 
TISNew.Mins__c = TISDetail.Mins__c; 

insert TISNew; 
System.debug('**New record created in TIS_Summary__c with SID:"'+TISNew.Id+'"**'); 

}catch (exception e) 
{ 
system.debug('@@Error@@ ' + e.getMessage()); 
} 
}//End of if (TISHasRecords == false ) clause 
} //End of if (TISDetail.Case__c != null) clause 
}//End of for loop 

System.debug('-- End of Trigger "CaseTISSummary" on TIS_Detail__c--'); 
} 

}