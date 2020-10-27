public class CaseInfoMesageExtension 
{
    public class myException extends Exception{}
    
    private map<string,string> myMap = new Map<string,string>();
    private string infoMessage;
    private string infoMessageDetail;
    public string returnURL;
    public string ifClauseSelector;
    private string severity;//  determines what type of icon and color the vf page will use, availble options are error, info, warning
    
    public CaseInfoMesageExtension(Apexpages.standardcontroller stdcontroller)
    {
        PageReference mypageref = apexpages.currentpage();
        myMap = mypageref.getparameters();//  grab the url paramters
        returnURL = myMap.get('retURL');//  return url for the back function
        ifClauseSelector = myMap.get('enum');//  this should be in the url paramter, it tells the init function what message to display
        
        //  somehow, this class is being called from somewhere, but its not having an enum set
        //  i've checked code and cannt find the culprit, so instead, we are going to have it display an error message to help me 
        //  boil it down.  if i still cant find it, we just dont have the page blow up
        if (ifClauseSelector == null)
        {
            util.breakpoint('Failed to find enum value.  Url parameters are: ' + myMap);
        }
        //system.assertNotEquals(null, ifClauseSelector);//  if ifClauseSelector is null, we don't know what error message to display
           
        showCloseWindowButton = false;
        initInfoMessage();//  initilize the error/info messages
    }
    
    public string getInfoMessage(){return infoMessage;}
    public string getInfoMessageDetail(){return infoMessageDetail;}
    public string getSeverity(){return severity;}
    public boolean showCloseWindowButton{get;set;}
    
    public PageReference back()
    {
        PageReference pr;
        
        if (returnURL != null)//  return user to whatever the return url is
        {
            pr = new PageReference(returnURL+'?inline=0');
            pr.setRedirect(true);
            return pr;
        }
        else//  if the url is not specified, return user to their home page
        {
            pr = new PageReference('/home/home.jsp');
            pr.setRedirect(true);
            return pr;
        }
    }
    public boolean showGotoCaseButton
    {
        get
        {
           if (ifClauseSelector == Null)
           {
               return false;
           }
           else
           {
              return (ifClauseSelector == '17');
           }
        }
    }
    public PageReference goToCaseButton()
    {
        // teh reutrn url passed here will take us to the edit of the case but 
        //  we need to pass in a new return url there that will take the user back to the case view page if the decide to hit cancel
        Map<string, string> tempMap = apexpages.currentpage().getParameters(); 
        Id caseId = tempMap.get('caseId');
        
        PageReference pr = new PageReference('/' + caseId + '/e?retURL=/' + caseid);
        pr.setRedirect(true);
        return pr;
    }
    public void initInfoMessage()
    {
        system.assertNotEquals(null, ifClauseSelector);
        
        if (ifClauseSelector == '1')//  error message for a case is already open
        {
            infoMessage = 'This case is already open.';
            infoMessageDetail = 'You cannot re-open a case that is alreay open.';
            severity = 'Error';     
        }
        else if (ifClauseSelector == '2')//  error message for if a case has been reopened already
        {
            infoMessage = 'This case is already re-opened.';
            infoMessageDetail = 'You cannot re-open a case that has already been re-opened.';
            severity = 'Error'; 
        }
        else if (ifClauseSelector == '3')//  error message for if a user is trying to edit case and it is closed
        {
            infoMessage = 'Cannot edit a closed case.';
            infoMessageDetail = 'You cannot edit a closed case.';
            severity = 'Error'; 
        }
        else if (ifClauseSelector == '4')//  error message for if a user is trying to edit case and it is reopened
        {
            infoMessage = 'This case is RE-OPENED.';
            infoMessageDetail = 'You cannot edit a re-opened case.  You can add new case events however.';
            severity = 'Warning'; 
        }
        else if (ifClauseSelector == '5')//  error message for if a user is trying to ad/edit a case event to a close case
        {
            infoMessage = 'The case is closed.';
            infoMessageDetail = 'You cannot edit/create case events to closed case.';
            severity = 'Error'; 
        }
        else if (ifClauseSelector == '6')//  error message for if an account is prospect
        {
            infoMessage = 'The account is a Prospect Customer';
            infoMessageDetail = 'You cannot create a case for a prospect customer.  Please contact your manager for more information.';
            severity = 'Warning'; 
        }
        else if (ifClauseSelector == '7')//  error message for account has no products
        {
            infoMessage = 'This account has no active products';
            infoMessageDetail = 'You cannot create a domestic support case for an account with no active products.  Please contact your manager for more information.';
            severity = 'Error'; 
        }
        else if (ifClauseSelector == '8')//  error message for var trying to convert case to contract
        {
            infoMessage = 'Insufficient privleges';
            infoMessageDetail = 'You cannot convert this case to a contract. Please contact your manager for more information.';
            severity = 'Error'; 
        }         
        else if (ifClauseSelector == '9')//  error message for var trying to create new change request
        {
            infoMessage = 'Insufficient privleges';
            infoMessageDetail = 'You cannot create a Change Request.  Please contact your manager for more information.';
            severity = 'Error'; 
        }
        else if (ifClauseSelector == '10')//  error message for var creating case for inactive contact
        {
            infoMessage = 'This contact is inactive in the system.';
            infoMessageDetail = 'You cannot create a case for an inactive contact.  Please contact your manager for more information.';
            severity = 'Error'; 
        }
        else if (ifClauseSelector == '11')//  error message for portal user using the re-open button
        {
            infoMessage = 'Insufficnet privlieges';
            infoMessageDetail = 'Portal users are not allowed to re-open cases.';
            severity = 'Error'; 
        }
        else if (ifClauseSelector == '12')
        {
            infoMessage = 'Email Sent Successfully';
            infoMessageDetail = 'Press back to go back to the original record.';
            severity = 'Confirm';
            showCloseWindowButton = true;
        }
        else if (ifClauseSelector == '13')
        {
            infoMessage = 'Opportunity Order Created Already.';
            infoMessageDetail = 'Cannot create another order for this opportunity';
            severity = 'Error';
        }
        else if (ifClauseSelector == '14')
        {
            infoMessage = 'Opportunity Stage is not \"Likely\".';
            infoMessageDetail = 'Opportunity Order can only be created for opportuinties whose stage is \"Likely\"';
            severity = 'Error';
        }
        else if (ifClauseSelector == '15')
        {
            infoMessage = 'Opportunity\'s Telematics Provider is \"Other\".';
            infoMessageDetail = 'You must specify the exact provider of telematics before converting this opportunity.' ;
            severity = 'Error';
        }
        else if (ifClauseSelector == '16')
        {
            infoMessage = 'The Opportunity\'s Stage must be Closed' +
            '  before you can convert to a contract.';
            infoMessageDetail = 'Please press the back button.';
            severity = 'Error';
        }
        else if (ifClauseSelector == '17')
        {
            infoMessage = 'This case needs to have it\'s product and case reason set before it can be closed.';
            infoMessageDetail = 'Press the edit button to go the case to supply these values.';
            severity = 'Error';
        }
        else if (ifClauseSelector == '18')
        {
            infoMessage = 'Account is Buying Group/Sales Referral Account';
            infoMessageDetail = 'Support cases cannot be created for Buying Group/Sales Refferal Accounts';
            severity = 'Error';
        }
        else if (ifClauseSelector == '19')
        {
            infoMessage = 'Change Request product family is Apex and cannot be cloned to a Apex-Future CR';
            infoMessageDetail = '';
            severity = 'Error';
        }
        else if (ifClauseSelector == '20')
        {
            infoMessage = 'Cannot Create Another License Restriction Unlock';
            infoMessageDetail = 'The account has already had a License Restriction Unlock created for it.  Please see Product Support Management for assistance';
            severity = 'Error';
        }   
        else if (ifClauseSelector == '21')
        {
            infoMessage = 'Opportunity already created for this case.  You can only convert a case to opportunity once.';
            infoMessageDetail =  'Press back button to refresh the case page.';
            severity = 'Error';
        }
    }
    
    public static ApexPages.StandardController generateController(string returnURL, string theEnum )
    {
        system.assertNOtEquals(null, theEnum);
        
        Case theCase = new Case();//  this function needs an object to genberate a standard controller
        pagereference pageRef=new pagereference('Page.CaseTypeSupportPage');
        test.setcurrentpage(pageRef);
        
        if (returnURL == null)// make returnURL default if it hasn't been specifeid already
        {
            returnURL = '%2fhome%2fhome.jsp';
        }
        
        ApexPages.currentPage().getParameters().put('retURL', returnURL);
        ApexPages.currentPage().getParameters().put('enum', theEnum);
           
        return new ApexPages.standardController(theCase);
    }
    

}