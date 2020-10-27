trigger SerializedUnitSummaryUpdate on Serialized_Units__c (after insert,before update, after update, after delete,after undelete) {
/*
Map<string,Double> mpId = new Map<string,Double>();
string idString = '';


//-----------------------HANDLE INSERTS--------------------------//
if(Trigger.isInsert) 
{
  for(Serialized_Units__c serializedUnit :Trigger.New) 
  {
    if(serializedUnit.Account__c != null)
    {
        System.debug('-----------------------serializedUnit-------------'+ serializedUnit);
        idString = SerializedUnitSummaryUtils.GetIDString(serializedUnit);
        //long keyValue = Long.valueOf(serializedUnit.NMC_System__c);
    
        System.debug('after Insert'+idString);
        System.debug('Insert ---mpId'+mpId);
    
        if(mpId.containsKey(idString)) 
        {
            System.debug('inside If ----Insert ');
            Double tempValue = mpId.get(idString);
            mpId.remove(idString);
            mpId.put(idString,tempValue +1);
        }else 
        {
            System.debug('inside else ----Insert ');
            mpId.put(idString,1);
        }
    }
  }
}

//-----------------------HANDLE undelete--------------------------//
if(Trigger.isUndelete) 
{
  for(Serialized_Units__c serializedUnit :Trigger.new) 
  {
    if(serializedUnit.Account__c != null)
    {
        System.debug('-----------------------serializedUnit-------------'+ serializedUnit);
        idString = SerializedUnitSummaryUtils.GetIDString(serializedUnit);
        System.debug('after unDelete'+idString);
        System.debug('undelete ---mpId'+mpId);
        if(mpId.containsKey(idString)) 
        {
            System.debug('inside If ----unDelete ');
            Double tempValue = mpId.get(idString);
            mpId.remove(idString);
            mpId.put(idString,tempValue +1);
        }else 
        {
            System.debug('inside else ----unDelete ');
            mpId.put(idString,1);
        }
    }
  }
}


//-----------------------HANDLE DELETES----------------------------//
if(Trigger.isDelete) 
{
  for(Serialized_Units__c serializedUnit :Trigger.Old) 
  {
    if(serializedUnit.Account__c != null)
    {
        System.debug('-----------------------serializedUnit-------------'+ serializedUnit);
        idString = SerializedUnitSummaryUtils.GetIDString(serializedUnit);
        System.debug('after delete'+idString);
        System.debug('mpId'+mpId);
    
        if(mpId.containsKey(idString)) 
        {
            System.debug('inside If ----delete ');
            Double tempValue = mpId.get(idString);
            mpId.remove(idString);
            mpId.put(idString,tempValue - 1);
        } else 
        {
            System.debug('inside else ----delete ');
            mpId.put(idString,-1);
        }
    }
  }
}




//--------------------HANDLE UPDATES--------------------------//
Serialized_Units__c oldSerializedUnit = null;
if(Trigger.isUpdate) 
{
  System.debug('Trigger update');
  for(Serialized_Units__c serializedUnit : Trigger.New) 
  {
    if(serializedUnit.Account__c != null)
    {
        System.debug('-----------------------serializedUnit-------------'+ serializedUnit);
        system.debug('serializedUnit.Account__c==>'+ serializedUnit.Account__c);
        system.debug('serializedUnit.NMC_Account_Id__c==>'+ serializedUnit.NMC_Account_Id__c);
        if(trigger.isBefore && serializedUnit.NMC_Account__c != null)
        {
            if(serializedUnit.Account__c != serializedUnit.NMC_Account_Id__c)
            {
                serializedUnit.Account__c = serializedUnit.NMC_Account_Id__c;
                system.debug('CHANGED==>'+ serializedUnit.Account__c);
            }
            
        }
        else if(trigger.isAfter)
        {
            System.debug('Trigger update--inside FOR....');
            idString = SerializedUnitSummaryUtils.GetIDString(serializedUnit);
        
            System.debug('Trigger idString'+idString);
            oldSerializedUnit = Trigger.oldMap.get(serializedUnit.Id);
            System.debug('Trigger oldSerializedUnit'+oldSerializedUnit);
            string oldIDString = SerializedUnitSummaryUtils.GetIDString(oldSerializedUnit);
            System.debug('Trigger oldIDString.'+oldIDString);
        
            if(oldIDString != idString) 
            {
                if(mpId.containsKey(idString)) 
                {
                  System.debug('iNSIDE IF mpId.containsKey(idString+1)');
                  Double tempValue = mpId.get(idString);
                  mpId.remove(idString);
                  mpId.put(idString,tempValue + 1);
                }else 
                {
                  System.debug('iNSIDE else mpId.containsKey(idString)');
                  mpId.put(idString,1);
                }
            
                if(mpId.containsKey(oldIDString)) 
                {
                  System.debug('iNSIDE if  mpId.containsKey(oldIDString)');
                  Double tempValue = mpId.get(oldIDString);
                  mpId.remove(oldIDString);
                  mpId.put(oldIDString,tempValue - 1);
                }else 
                {
                  mpId.put(oldIDString,-1);
                  System.debug('iNSIDE else  mpId.containsKey(oldIDString-1)');
                }
           }
       }
    }
  }
}

System.debug('********************************');
System.debug(mpId);
System.debug('********************************');

if(mpId.size() > 0) SerializedUnitSummaryUtils.UpsertSummaryUnits(mpId);
*/
}