/**
 * @author Avinash Kaltari, SF Developer, TCS
 * @date Sep 6, 2011
 * @description : This is a Controller to the PartnerScorecard VF Page (displayed within the Account Detail Page)& in PartnerProfile Page.
 */


public class PartnerScorecardController 
{

    public Account acc {get; set;} {acc = new Account();}
    public string partnerScoreId{get;set;}{partnerScoreId = '';}
    public List<Partner_Scorecard__c> lstPS = new List<Partner_Scorecard__c>();
    public Partner_Scorecard__c ps {get;set;} {ps= new Partner_Scorecard__c();}
    
    public PartnerScorecardController(ApexPages.StandardController controller) 
    {
//Get the current Account
        acc = (Account) controller.getRecord(); 
        
//Query to get the Current Partner Scorecard values for the current Account
        lstPS = [select name, Goal_Attainment__c, Account__c, Current_Scorecard__c, Current_Year_Units_Goal__c, Lead_Converion_Rate__c, Number_of_Leads_Active__c, Number_of_Leads_converted__c, Number_of_Leads_Total__c, Number_of_Qualcomm_provided_leads__c, Scorecard_End_Date__c, Scorecard_Start_Date__c, Total_Number_of_Accounts__c, Total_Number_of_Contracted_Customers__c, Units_Closed_Won_Opportunities__c, Value_Closed_Won_Opportunities__c, YTD_Customer_Activated_Units__c, YTD_Customer_Shipped_Units__c,LastModifiedDate,LastModifiedById from Partner_Scorecard__c where Account__c = :acc.id and Current_Scorecard__c = true limit 1];
        
//Assigning the Current Partner Scorecard(PS) record to a local variable (Used if the Page is being viewed on Detail Page)
        if(lstPS.size() > 0)
        {
            ps = lstPS[0];
            
        }
//Used if page is viewed in PartnerProfile page (which had Account ID in url)
        else if (Apexpages.CurrentPage().getParameters().containskey('id'))
        {
            lstPS = [select name, Goal_Attainment__c, Account__c, Current_Scorecard__c, Current_Year_Units_Goal__c, Lead_Converion_Rate__c, Number_of_Leads_Active__c, Number_of_Leads_converted__c, Number_of_Leads_Total__c, Number_of_Qualcomm_provided_leads__c, Scorecard_End_Date__c, Scorecard_Start_Date__c, Total_Number_of_Accounts__c, Total_Number_of_Contracted_Customers__c, Units_Closed_Won_Opportunities__c, Value_Closed_Won_Opportunities__c, YTD_Customer_Activated_Units__c, YTD_Customer_Shipped_Units__c,LastModifiedDate,LastModifiedById from Partner_Scorecard__c where Account__c = :Apexpages.CurrentPage().getParameters().get('id') and Current_Scorecard__c = true limit 1];
            if(lstPS.size() > 0)
            {
                ps = lstPS[0];
            }
        }
    }
    
    public pageReference updatePartnerScoreCard()
    {
       // system.debug('@@@@Current score card' + ps.id);
        string partnerScoreId = ps.id;
       // List<Partner_Scorecard__c> lstPS = new List<Partner_Scorecard__c>();
        if(partnerScoreId != null && partnerScoreId != '')
        {
            
          /*  lstPS = [SELECT 
                         Name
                     FROM
                         Partner_Scorecard__c
                     WHERE
                         id = :partnerScoreId
                     AND
                         Current_Scorecard__c = true 
                     LIMIT
                         50000];
            if(lstPS != null && lstPS.size() > 0) 
            {*/
                try{
                    update ps;
                    lstPS = [
                                select 
                                    name, 
                                    Goal_Attainment__c, 
                                    Account__c, 
                                    Current_Scorecard__c, 
                                    Current_Year_Units_Goal__c, 
                                    Lead_Converion_Rate__c, 
                                    Number_of_Leads_Active__c, 
                                    Number_of_Leads_converted__c, 
                                    Number_of_Leads_Total__c, 
                                    Number_of_Qualcomm_provided_leads__c, 
                                    Scorecard_End_Date__c, 
                                    Scorecard_Start_Date__c, 
                                    Total_Number_of_Accounts__c, 
                                    Total_Number_of_Contracted_Customers__c, 
                                    Units_Closed_Won_Opportunities__c, 
                                    Value_Closed_Won_Opportunities__c, 
                                    YTD_Customer_Activated_Units__c, 
                                    YTD_Customer_Shipped_Units__c,
                                    LastModifiedDate,
                                    LastModifiedById 
                                from 
                                    Partner_Scorecard__c 
                                where 
                                    ID = :ps.id 
                                limit 
                                    1
                            ];  
                    ps = lstPs[0];  
                }
                catch(Exception e)
                {
                    system.debug('Update failed......');    
                }
          // } 
            
        }
        return null;
    }
}