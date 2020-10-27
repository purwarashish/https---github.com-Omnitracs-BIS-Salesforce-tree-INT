//-------------CALCULATES DATA QUALITY SCORE FOR ACCOUNT------------------/
public class CalculateDataQualityScore {
  
   //-------GENERIC METHOD TO RETRIEVE RECORDTYPEIDS --------------------/
   public static Map<string,string> retrieveRecordTypes(string sObjectName) {

    Map<string,string> nameIDMap = new Map<string,string>();
    for(RecordType record : [Select Id,Name from RecordType where SObjectType = 
                             :sObjectName ]) 
    {
      nameIDMap.put(record.Id,record.Name);
    }
    return nameIDMap; 
  }
 
  //-----------COMPUTES THE VALUE 0 is empty field and 1 for a filled----/
  public static Integer determineDataQualityScore(Integer totalNumFields, Integer numNotNullFields) {
    Double percentValue = (numNotNullFields * 100)/totalNumFields; 
    System.debug('@@@@@@..Got ' + percentValue + '%');
    return determineScaledScore(percentValue);
  }

  //--------------ASSIGN SCORE ACCORDING TO PERCENTAGE -------------/
  public static Integer determineScaledScore(Double percentScore) {
    if(percentScore < 20) 
       return 0;
    if(percentScore < 40)
       return 20;
    if(percentScore < 60)
       return 40;
    if(percentScore < 80)
       return 60;
    if(percentScore <= 99)
       return 80;

    return 100; 
  }
  
  //-----------Concatenates the strings in the list and returns----/
  public static String generateScoreDescription(List<string> missingFieldList) {
    String scoreDesc = '';
    Integer counter = 0;
    if(missingFieldList != null){
        for(String missingField: missingFieldList) {
            if(counter == 0) { 
                scoreDesc = 'Missing: ' + missingField; 
            } else {
                scoreDesc += ', ' + missingField; 
            }
            counter++;
        }
    }       

    return scoreDesc;
  }

  // -----------Checks for null and sets the values of the incoming parameters
  //    @param String incomingValue - value to check for null
  //    @param String fieldLabel - UI label for the field
  //    @param Integer countOfNonNullFields - count of not-null fields - we'll increment if not null
  //    @param List<string> missingFieldList - List of labels that have null values - we'll add the label to this list if the field is null
  //      
  public static integer checkFieldValue(String incomingValue, String fieldLabel, Integer countOfNonNullFields, List<string> missingFieldList) {
    if(incomingValue == null) {
      missingFieldList.Add(fieldLabel);
    } else {
      countOfNonNullFields++;    
    }
    return countOfNonNullFields;
  }  
  
} //end class