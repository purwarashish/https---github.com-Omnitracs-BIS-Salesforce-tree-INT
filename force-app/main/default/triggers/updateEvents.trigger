/*******************************************************************************************************
Date: 19 August 2009

Author: Shruti Karn
Overview: This trigger finds the Lessons Learned record corresponding to the event 
          and updates their "eventOpen__c" and "eventClose__c".

Modified By : Shruti Karn on 22 December 2010 to handle bulk operation.

Case# 28117
*******************************************************************************************************/

trigger updateEvents on Event(after insert,after update,after delete)
{

     BypassTriggerUtility u = new BypassTriggerUtility();  
     if (u.isTriggerBypassed()) {
         return;
     }

Integer eventOpen=0;
Integer eventClose=0;
map<Id,Event> mapIdEvent= new map<Id,Event>(); // Map to hold WhatId and coresponding Event
    if(Trigger.isInsert || Trigger.isUpdate)
      {
        for(Event new_event:trigger.new)
        {
         if(new_event.WhatId != null)
         {
             mapIdEvent.put(new_event.WhatId , new_event);
         }
        }
        // to find all the lessons learned records.
        List<Lessons_Learned__c> LL = new list<Lessons_Learned__c>();
        LL=[Select Id,eventClose__c,eventOpen__c From Lessons_Learned__c  where Id in : mapIdEvent.keySet() limit 1000];
        If((!LL.isEmpty())){
            for(integer i=0;i<LL.size();i++)
            {
                system.debug('LL.size():'+LL.size()+'LL[i].eventClose__c:'+LL[i].eventClose__c);
                if((mapIdEvent.get(LL[i].ID)).EndDateTime > Datetime.Valueof(System.now()))
                {
                    if(LL[i].eventOpen__c != null )
                        LL[i].eventOpen__c = LL[i].eventOpen__c+1;
                    else
                        LL[i].eventOpen__c = 1;
                }
                else
                {
                     if(LL[i].eventClose__c != null )
                         LL[i].eventClose__c = LL[i].eventClose__c+1;
                     else
                         LL[i].eventClose__c =1 ;
                     
                }
            }
        }
        update LL;
      }  
        
// enters in else for delete operation         
else
 {
   for(Event old_event:trigger.old)
   {
     if(old_event.WhatId != null)
     {
         mapIdEvent.put(old_event.WhatId , old_event);
     }
     List<Lessons_Learned__c> LL = new list<Lessons_Learned__c>();
     LL=[Select Id,eventClose__c,eventOpen__c From Lessons_Learned__c  where Id in : mapIdEvent.keySet() limit 1000];
     If((!LL.isEmpty())){
         for(integer i=0;i<LL.size();i++)
         {
             if((mapIdEvent.get(LL[i].ID)).EndDateTime > Datetime.Valueof(System.now()))
             {
                 if(LL[i].eventOpen__c != null )
                     LL[i].eventOpen__c = LL[i].eventOpen__c+1;
                 else
                      LL[i].eventOpen__c = 1;
             }
             else
             {
                 if(LL[i].eventClose__c != null )
                     LL[i].eventClose__c = LL[i].eventClose__c+1;
                 else
                     LL[i].eventClose__c =1;
              }
            }
        }
        update LL;
      }  
}
}