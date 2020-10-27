@isTest(SeeAlldata=true)
private class TestLeadRejectionController{

static testmethod void testRejectLead()
{
  Lead testlead= new Lead();
  testlead.FirstName='testFirstName';
  testlead.LastName='testLastName';
  testlead.Company='testComapany';
  testlead.Phone='342323';
  testlead.City='San Diego';
  testlead.State='CA';
  testlead.Country='US';
 
  insert testlead;
  
  ApexPages.currentPage().getParameters().put('Id',testlead.Id); 
  LeadRejectionController testobject= new LeadRejectionController();
  testobject.description  = 'test body';
  testobject.rejectLead();
 

}


}