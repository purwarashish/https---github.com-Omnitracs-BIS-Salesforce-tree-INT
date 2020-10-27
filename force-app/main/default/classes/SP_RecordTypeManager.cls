public class SP_RecordTypeManager{

    private static map<String,list<sObject>> rtsByObject = SP_sCollection.stringListMap([select Id, Name, DeveloperName, sObjectType, Description, BusinessProcessId 
                                                    from RecordType 
                                                    where isActive = true],RecordType.sObjectType);

    public static RecordType getByName(String rtName,String sObj){
        map<String,sObject> rtsByName = SP_sCollection.stringMap(rtsByObject.get(sObj),RecordType.DeveloperName);
        return (RecordType) rtsByName.get(rtName);
    }
    
    public static Id getIdByName(String rtName,String sObj){
        return getByName(rtName,sObj).Id;
    }
    
    public static String getNameById(String rtId, String sObj) {
    	map<String,sObject> rtsById = SP_sCollection.stringMap(rtsByObject.get(sObj), RecordType.Id);
    	RecordType rt = (RecordType)rtsById.get((Id)rtId);
    	System.debug(rt.Name);
    	return rt.Name;
    }

}