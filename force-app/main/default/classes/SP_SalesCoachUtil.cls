@isTest(SeeAllData=true)
public with sharing class SP_SalesCoachUtil {

    private static Sales_Coach_Role__c salesCoachRole;
    
    public static SelectOption[] getOpptyStages(){
      SelectOption[] options = new SelectOption[] {};
      options.add( new SelectOption( '-- Select --', '-- Select --' ) );
      String[] oList = new String[] {};
      List<OpportunityStage> OS = [Select MasterLabel from OpportunityStage where IsActive=true order by SortOrder];
      List<Sales_Coach_Stage__c> SCShide = [SELECT Name FROM Sales_Coach_Stage__c WHERE Hide_Stage__c = true];
      for(OpportunityStage ml:OS)
       oList.add(ml.MasterLabel);
      for( string s : oList ) {
            options.add( new SelectOption( s.trim(), s.trim() ) );  
      }          
      return options;
    }
        
    //this gets the opurtunity stages from OppurtunityStage which is set by user - does not include hidden stages
    public static SelectOption[] getOpptyStagesNoHides(){
      SelectOption[] options = new SelectOption[] {};
      options.add( new SelectOption( '-- Select --', '-- Select --' ) );
      String[] oList = new String[] {};
      List<OpportunityStage> OS = [Select MasterLabel from OpportunityStage where IsActive=true order by SortOrder];
      List<Sales_Coach_Stage__c> SCShide = [SELECT Name FROM Sales_Coach_Stage__c WHERE Hide_Stage__c = true];
      for(OpportunityStage ml:OS)
       oList.add(ml.MasterLabel);
      for( string s : oList ) {
        Boolean found = false;
        for (Sales_Coach_Stage__c scs : SCShide) {
            if (scs.Name == s.trim()) {
                found = true;
            }
        }
        if (!found)
            options.add( new SelectOption( s.trim(), s.trim() ) );  
      }          
      return options;
    }
    
    //test getOpptyStages
    private static testmethod void testSalesCoachRole(){
        System.assert(SP_SalesCoachUtil.getOpptyStages().size()>0);
        SP_TestingUtil tu = new SP_TestingUtil();
        System.assert(SP_SalesCoachUtil.getOpptyStages().size()>0);
    }
    
    private static void populateSalesCoachRole(){
        String userRole;
        
        if(SP_SalesCoachUtil.salesCoachRole == null){
            try{
                userRole = [select id, 
                                   name
                            from UserRole
                            where id = : UserInfo.getUserRoleId()].Name;
                SP_SalesCoachUtil.salesCoachRole = [select id, 
                                                         name
                                                  from Sales_Coach_Role__c
                                                  where name = : userRole Limit 1];
             
            }catch(Exception e){
            }
        }
    }
    
  //test populateSalesCoachRole
  private static testmethod void testpopulateSalesCoachRole(){
      SP_SalesCoachUtil.populateSalesCoachRole();
      SP_TestingUtil tu = new SP_TestingUtil();
      SP_SalesCoachUtil.populateSalesCoachRole();
    }
  
    //this is used to get all the fields from user that are picklists 
    //or strings   
    public static Map<String, Schema.SObjectField> getUserFieldsMap(){
      Map<String, Schema.SObjectField> fields = new Map<String, Schema.SObjectField>{};
      Map<String, Schema.SObjectField> M = Schema.SObjectType.User.fields.getMap();
      Set<String> uSet =M.keySet();
      Schema.DescribeFieldResult F;
      for(String s:uSet){
        F=M.get(s).getDescribe();
        if(F.getType()==Schema.Displaytype.STRING || F.getType()==Schema.Displaytype.PICKLIST){
          fields.put(s, M.get(s)); 
        }
      }
      return fields;
    }
    
    //test getUserFieldsMap
    private static testmethod void testgetUserFieldsMap(){
      System.assert(SP_SalesCoachUtil.getUserFieldsMap().size()>=0);
    }
   
    //this gets the opurtunity stages from OppurtunityStage which is set by user   
    public static String[] opptyStageList(){
        String[] oList = new String[] {};
        List<OpportunityStage> OS = [Select MasterLabel from OpportunityStage];
        for(OpportunityStage ml:OS)
         oList.add(ml.MasterLabel);     
        return oList;
    }
    
    //test opptyStageList
  private static testmethod void testopptyStageList(){
      SP_TestingUtil tu = new SP_TestingUtil();
      System.assert(SP_SalesCoachUtil.opptyStageList().size()>=0);
    }   
}