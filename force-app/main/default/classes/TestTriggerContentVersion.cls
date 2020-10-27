@isTest
private class TestTriggerContentVersion 
{
    static testMethod void testContentTrigger() 
    {
        list<ContentDocument> lstContentDocument = new list<ContentDocument>();
        lstContentDocument = [select title from ContentDocument limit 1];
        ContentVersion testContentVersion = new ContentVersion();
        if(!(lstContentDocument.isEmpty())&& lstContentDocument[0].id != null)
        {
            testContentVersion.ContentDocument = lstContentDocument[0];
            testContentVersion.title = 'testTitle';
            testContentVersion.ContentUrl = 'http://www.google.com';
        }
        try
        {
            insert testContentVersion;
        }
        catch(Exception e)
        {
system.debug('Excepiton in inserting Content'+e);
        }
        
    }
}