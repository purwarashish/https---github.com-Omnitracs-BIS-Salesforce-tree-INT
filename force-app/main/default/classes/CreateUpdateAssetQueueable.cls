/*********************************************************************
Modified Date: 03/28/2016
Modified By  : Ram Majji
Reason       : Case # 02246752 - 1. Change the time when contracted assets are created/updated to: Opportunity Stage = Sales Complete 
                and Opportunity Legal Review = Contract Data Entry Process and Finance Review = Approved. 
                In addition, there is a field called Asset (lookup to the Contracted Asset) on the Opportunity Product that is not being populated currently. 
                They would like this to be populated so that there is a link between the Opportunity Product and the Contracted Asset.
                2. When the opportunity goes to Closed Won, if the Opportunity Product’s Line Type = New, update the set fields 
                from the Opportunity Product to Contracted Asset.
*********************************************************************/
public class CreateUpdateAssetQueueable implements Queueable{

private List<OpportunityLineItem> lstqualifiedOLI;
private map<Id, Opportunity> assetizedOpps;
private set<Id> setaccountId;
private Boolean isClosedOppSet;

/*public CreateUpdateAssetQueueable(List<OpportunityLineItem> lstqualifiedOLI, map<Id, Opportunity> assetizedOpps, set<Id> setaccountId, Boolean isClosedSet)
{
    this.lstqualifiedOLI = lstqualifiedOLI;
    this.assetizedOpps = assetizedOpps;
    this.setaccountId = setaccountId;
    this.isClosedOppSet = isClosedSet;
}

public void execute(QueueableContext context)
{
    //Control the method invokation using the boolean parameter passed from calling function
    if(isClosedOppSet)
        opportunityUtils.oliAssetSync(lstqualifiedOLI);
    else
        OpportunityUtils.CreateUpdateAssetsAsync(lstqualifiedOLI, assetizedOpps, setaccountId);
}*/
public CreateUpdateAssetQueueable(List<OpportunityLineItem> lstqualifiedOLI, map<Id, Opportunity> assetizedOpps, set<Id> setaccountId)
{
    this.lstqualifiedOLI = lstqualifiedOLI;
    this.assetizedOpps = assetizedOpps;
    this.setaccountId = setaccountId;
}

public void execute(QueueableContext context)
{
    //OpportunityUtils.CreateUpdateAssetsAsync(lstqualifiedOLI, assetizedOpps, setaccountId);
}

}