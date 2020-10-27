/***********************************************************************************
Date: 7/06/2009
Author: Rajkumari Nagarajan, Salesforce.com Administrator
        Tata Consultancy Services Limited

Overview: When a Contract Request record is created or edited, the trigger "ContractRequestTISDetail" tracks
          and captures the changes in the "Request Status" field in  Contract Request.

This trigger "ContractRequestTISSummary" consolidates the detailed TIS from TISDetail
and create/update records in TISSummary
************************************************************************************/
trigger ContractRequestTISSummary on TIS_Detail__c (after insert, after update)
{

    if (Trigger.isInsert)
    {
        System.debug('-- TIS_Detail__c Trigger "ContractRequestTISSummary" initiated by Insert operation--');

           System.debug('For insert operation, there is no business logic as of now');

        System.debug('-- End of Trigger "ContractRequestTISSummary" on TIS_Detail__c--');
    }else if (Trigger.isUpdate)
    {
        System.debug('-- Contract Requesr  Trigger "ContractRequestTISSummary" initiated by Update operation--');
        for (TIS_Detail__c TISDetail :Trigger.new)
        {
            if (TISDetail.Contract_Request__c != null)
            {
                Boolean TISHasRecords = false;
                for (TIS_Summary__c TISSum :[Select Id, Contract_Request__c, Name, Last_Date_Time_Out__c, Days__c,Hrs__c, Mins__c
                                            from TIS_Summary__c where Contract_Request__c = :TISDetail.Contract_Request__c
                                            and Name = :TISDetail.Name and State__c = :TISDetail.State__c])
                {
                    TISHasRecords = true;
                    System.debug('Records exists in TIS_Summary__c for contract Request Id:"'+ TISDetail.Contract_Request__c +'" and Field Name :"' + TISDetail.Name +'" and Field Value :"' + TISDetail.State__c +'"');
                     if(((TISSum.Mins__c + TISDetail.Mins__c) >= 60 )&& ((TISSum.Mins__c + TISDetail.Mins__c) < 120) )   
                    {
                        TISSum.Hrs__c  =  (TISSum.Hrs__c + TISDetail.Hrs__c)  + 1;
                        TISSum.Mins__c = (TISSum.Mins__c + TISDetail.Mins__c) - 60;
                    }else if ((TISSum.Mins__c + TISDetail.Mins__c) == 120)
                    {
                        TISSum.Hrs__c  = (TISSum.Hrs__c + TISDetail.Hrs__c) + 2;
                        TISSum.Mins__c = 0 ;
                    }else if ((TISSum.Mins__c + TISDetail.Mins__c) < 60 )
                    {
                        
                        TISSum.Hrs__c  = TISSum.Hrs__c + TISDetail.Hrs__c;
                        TISSum.Mins__c = TISSum.Mins__c + TISDetail.Mins__c;   
                    }
                    if (((TISSum.Hrs__c) >= 24 )&& ((TISSum.Hrs__c) < 48) )
                    {                                       
                        TISSum.Days__c = (TISSum.Days__c + TISDetail.Days__c) + 1;
                        TISSum.Hrs__c  = TISSum.Hrs__c  - 24;
                    }else if ((TISSum.Hrs__c ) == 48)
                    {
                        TISSum.Days__c = (TISSum.Days__c + TISDetail.Days__c) + 2;
                        TISSum.Hrs__c  = 0;
                    }else if ((TISSum.Hrs__c) < 24 )
                    {
                        TISSum.Days__c = (TISSum.Days__c + TISDetail.Days__c);
                        TISSum.Hrs__c  = TISSum.Hrs__c ;
                    }
                        
                        
                    
                    if(TISDetail.State__c == 'Set-up Complete')
                    {
                        TISSum.Hrs__c = 0;
                        TISSum.Mins__c  = 0;
                        TISSum.Days__c = 0;
                    }             
                    TISSum.Last_Date_Time_Out__c = TISDetail.Date_Time_Out__c;

                    update TISSum;
                    System.debug('**Updated TIS_Summary__c record with SID: "'+ TISSum.Id +'" **');

                }//end of for loop

                if (TISHasRecords == false )
                {
                    Try
                    {
                        System.debug('No records exists in TIS_Summary__c');
                        System.debug('Create New record in TIS_Summary__c for  Contract Request Id:"'+ TISDetail.Contract_Request__c +'" and Field Name :"' + TISDetail.Name +'" and Field Value :"' + TISDetail.State__c +'"');

                        TIS_Summary__c TISNew = new TIS_Summary__c();
                        TISNew.Contract_Request__c = TISDetail.Contract_Request__c;
                        TISNew.Name = TISDetail.Name ;
                        TISNew.State__c = TISDetail.State__c ;
                        TISNew.Last_Date_Time_Out__c = TISDetail.Date_Time_Out__c;
                        TISNew.Hrs__c = TISDetail.Hrs__c;
                        TISNew.Mins__c = TISDetail.Mins__c;
                        TISNew.Days__c = TISDetail.Days__c;

                        insert TISNew;
                        System.debug('**New record created in TIS_Summary__c with SID:"'+TISNew.Id+'"**');

                    }catch (exception e)
                    {
                        system.debug('@@Error@@ ' + e.getMessage());
                    }
                }//End of if (TISHasRecords == false ) clause
           } //End of if (TISDetail.Contract_Request__c != null) clause
     }//End of for loop

    System.debug('-- End of Trigger "ContractRequestTISSummary" on TIS_Detail__c--');
    }

}