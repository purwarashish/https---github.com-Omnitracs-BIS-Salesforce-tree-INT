//Rest of the code, we moved into 'AllCaseTriggerUtils' class
public class CaseServices 
{ 
    public static Boolean createdCaseTrackersAndHistories
    {
        get
        {
            if(createdCaseTrackersAndHistories == null)
                createdCaseTrackersAndHistories = false;
            
            return createdCaseTrackersAndHistories;
        }
    }

}