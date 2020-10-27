/*********************************************************************
Name    : CampaignTrigger
Author  : Joseph Hutchins
Date    : July 29, 2015

Usage   : Queries child oppts and updates two new fields
   
Modified By         : 
Modification Date   : 
Modification        : 
*********************************************************************/
trigger CampaignTrigger on Campaign (before update)
{
    //  per case no CampaignTrigger 02005052, when a campaign is updated
    //  need to query for any oppts that point to the campaign and update hte 
    //  Total_Value_Opportunities_MC__c and Total_Value_Won_Opportunities_MC__c
    if (Trigger.isBefore && Trigger.isUpdate)
    {
        updateTvOpptFields(Trigger.new);
    }
    public  void updateTvOpptFields(List<Campaign> triggerRecords)
    {
        //  very simply logic here, mass query the oppts of campaigns if any
        //  cursor thru each campagign summing all oppts and all closed oppts.opportunity amount mc
        Opportunity[] OpptsOfCampaigns;
        try
        {
            opptsOfCampaigns = [select id, stagename, campaignId, Opportunity_Amount_MC__c, isdeleted from Opportunity 
                     where CampaignId in: triggerRecords];
            util.debug('oppts of campaigns queried here are the results: ' + opptsOfCampaigns);
            if (opptsOfCampaigns != null)
            {
                for (opportunity o : opptsOfCampaigns)
                {
                    util.debug('o.id: ' + o.id + ' isDeleted: ' + o.isDeleted);
                }
            }
        }
        catch(Exception e)
        {
            //  expected if the campaigns dont have oppts pointing to them
        }
        //if (opptsOfCampaigns != null && opptsOfCampaigns.size() > 0)
        {
            for (Campaign c : triggerRecords)
            {
               decimal sumOfAllOppts = 0.0;
               decimal sumOfClosedWon = 0.0;
               List<Opportunity> oppts = findOppts(c.id, opptsOfCampaigns);
               if (oppts != null && oppts.size() > 0)
               {
                  
                  for (Opportunity o : oppts)
                  {
                        sumOfAllOppts += nullToZero(o.Opportunity_Amount_MC__c);
                        if (o.StageName == 'Closed Won')
                        {
                            sumOfClosedWon += nullToZero(o.Opportunity_Amount_MC__c);
                        }
                  }
               }
               c.Total_Value_Opportunities_MC__c = sumOfAllOppts;
               c.Total_Value_Won_Opportunities_MC__c = sumOfClosedWon;
            }
        }
    }
        private  List<opportunity> findOppts(id campaignId, List<Opportunity> oppts)
    {
        if (oppts == null)
        {
            return new List<Opportunity>();
        }
        List<opportunity> opptsToReturn = new List<Opportunity>();
        for (Opportunity o : oppts)
        {
            if (o.CampaignId == campaignId)
            {
                opptsToReturn.add(o);
            }
        }
        return opptsToReturn;
    }
    private static decimal nullToZero(decimal d)
    {
        return (d == null ? 0 : d);
    }

}