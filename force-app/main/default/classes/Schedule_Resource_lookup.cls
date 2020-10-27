public without sharing class Schedule_Resource_lookup
{
   
    public List<Contact> results {get;set;} // search results
    public string searchString {get;set;} // search keyword
    
      // used by the visualforce page to send the link to the right dom element
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }
    
    // used by the visualforce page to send the link to the right dom element for the text box
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }
    
    public Schedule_Resource_lookup() {
        
        // get the current search string
        searchString = System.currentPageReference().getParameters().get('lksrch');
        runSearch();  
      }
   // performs the keyword search
    public PageReference search() {
        runSearch();
        return null;
    }
       // prepare the query and issue the search command
    private void runSearch() {
        // TODO prepare query string for complex serarches & prevent injections
        results = performSearch(searchString);               
    } 
       // run the search and return the records found. 
    private List<Contact> performSearch(string searchString) {
        String soql = 'select id, name, Email, Accountid, Account.Name,pse__Practice__c,pse__Practice__r.name,pse__Group__r.name,pse__Resource_Role__c,recordtype.Name from Contact';
        String filter = ' where';
        if(searchString != '' && searchString != null)
        {    
            soql = soql +  ' where (name LIKE \'%' + searchString +'%\')';
            filter = ' AND';
        }    
        soql = soql + filter + ' pse__Is_Resource__c = true AND pse__Is_Resource_Active__c = true AND recordtype.Name=\'Resource\' and (pse__Practice__r.name = \'Professional Services\' OR pse__Practice__r.name = \'Technical Solutions\') AND (pse__Group__r.name = \'XRS\' OR pse__Group__r.name = \'Omnitracs US\') AND (pse__Resource_Role__c = \'Trainer\' OR pse__Resource_Role__c = \'Software Engineer\' OR pse__Resource_Role__c = \'Project Manager\')';  
        soql = soql + ' order by name limit 25';
        System.debug('soql'+soql);
        return database.query(soql); 
    }

}