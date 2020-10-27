public class LessonsLearnedEvents
{
    //capture the LL id
   public Id thisLLId {get;set;}
   //a list to hold this year's gifts
   //public List<Lessons_Learned__c> thisLessonsLearned = new List<Lessons_Learned__c>();
   //get the gifts into the list

   public List<Task> getTask()
      {
       Lessons_Learned__c LL=[Select Id,closeTask__c,OpenTask__c From Lessons_Learned__c  where Id = :thisLLId limit 1];
       List<Task> task =[Select Subject,Status,Description,OwnerId,ActivityDate ,What.Id,WhatId From Task  where What.Id= :LL.Id];
       return task;
      }

   public List<Event> getEvent()
      {
       Lessons_Learned__c LL=[Select Id,closeTask__c,OpenTask__c From Lessons_Learned__c  where Id = :thisLLId limit 1];
       List<Event> event=[Select Subject,OwnerId,ActivityDate ,What.Id,WhatId From Event where What.Id= :LL.Id];
       return event;
      }
   

}