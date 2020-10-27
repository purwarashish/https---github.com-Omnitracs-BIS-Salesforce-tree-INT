public class LeadConvertRedirectExtension {
  
private Lead leadToBeConv {get;set;}
public LeadConvertRedirectExtension(ApexPages.StandardController sc)
{
  leadToBeConv = (Lead)(sc.getRecord());
}

public pageReference urlRedirect()
{
  pageReference pg;
  try
  {
  	  
      /*leadToBeConv.Identify_Converted_Opp__c = true;  
      update leadToBeConv;*/
      
      Lead_Convert_Status__c convertStat = Lead_Convert_Status__c.getInstance(leadToBeConv.RecordTypeId);
      String convertStatusNum;
      
      //  per case no 01798376, shannon wants all business units to use the customizaed lead page, so we will no longer populate
      //  the convertstat and redirect the user to the leadconvert.jsp, instead we redirect the user to the Page.LeadConversionPage
      //  and will still populate the url parameter convertStat
      pg = Page.LeadConversionPage;
          
      if(convertStat != null) 
      { 
        convertStatusNum = convertStat.Status_Number__c ;
        pg.getParameters().put('cstatus', convertStatusNum);
        //  commented out by joseph hutchins 3/27/2015 to fix case no 01813687 
        //pg = new PageReference('/lead/leadconvert.jsp?retURL=' + leadToBeConv.id +'&id='+ leadToBeConv.id + '&cstatus='+convertStatusNum +'&saveURL=/apex/LeadConvertAccountEdit&nooverride=1'); 
        // commetned out by joseph 6/4/2014 in favor of the LeadConversionPage per case no 01798376 pg = new PageReference('/lead/leadconvert.jsp?retURL=' + leadToBeConv.id +'&id='+ leadToBeConv.id + '&cstatus='+convertStatusNum + '&nooverride=1');
      }
      else//  leaving the else here just in case we need to uncomment and bring back old logic
      {
        //  commented out by joseph hutchins 3/27/2015 to fix case no 01813687 
        //pg = new PageReference('/lead/leadconvert.jsp?retURL=' + leadToBeConv.id +'&id='+ leadToBeConv.id + '&saveURL=/apex/LeadConvertAccountEdit&nooverride=1' ); 
        // commetned out by joseph 6/4/2014 in favor of the LeadConversionPage per case no 01798376  pg = new PageReference('/lead/leadconvert.jsp?retURL=' + leadToBeConv.id +'&id='+ leadToBeConv.id + '&nooverride=1' );
      }
      pg.getParameters().put('id', leadtoBeconv.id);
      pg.getParameters().put('retUrl', leadToBeConv.id);
      pg.getParameters().put('nooverride', string.valueof(1));//  i am not sure if this parameter is needed since i am redirecting to my visual foce page

  }
  catch(exception e)
  {
    System.debug('*************** exception: ' + e.getMessage());
    pg = new PageReference('/lead/leadconvert.jsp?retURL=' + leadToBeConv.id +'&id='+ leadToBeConv.id + '&nooverride=1' );
  }
  return pg;
}
  
}