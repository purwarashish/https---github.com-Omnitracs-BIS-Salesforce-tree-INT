public class LogInviteEmailsAsTask {
    
    public static String COLLEAGUE_INVITE = 'Email: Colleague Invite';
    public static String SALES_INVITE = 'Email: Sales Invite'; 
    public static String COLLEAGUE_INVITE_TEMPLATEID = '00X50000001MHT6';
    public static String SALES_INVITE_TEMPLATEID = '00X50000001MHT7';
    
    public static String ACCOUNT_NAME = '{!Account.Name}';
    public static String CONTACT_NAME = '{!Contact.Name}';
    public static String CONTACT_UNITY_INVITE_TOKEN = '{!Contact.UnityInviteToken__c}';
    public static String CONTACT_UNITY_INVITOR = '{!Contact.Unity_Invitor__c}';
    public static String CONTACT_UNITY_INVITOR_TITLE = '{!Contact.Unity_Invitor_Title__c}';
    public static String CONTACT_UNITY_INVITOR_EMAIL = '{!Contact.Unity_Invitor_Email__c}';
    public static String CONTACT_UNITY_INVITOR_ACCOUNT = '{!Contact.Unity_Invitor_Account__c}';
    public static String ORGANIZATION_NAME = '{!Organization.Name}';
    public static String OMNITRACS_INC = 'Omnitracs, Inc.';
    
    
    public static void logEmails (List<Task> listOfTasks)
    {
        List<Id> listOfContactId = new List<Id>();
        
        //Iterate through the tasks
        for(Task t: listOfTasks)
        {
            //Check if the task is being created to log an email
            if(checkIfEmailToBeLogged(t.whoId, t.subject))
            {
                listOfContactId.add(t.WhoId);
            }
        }
        
        if(!listOfContactId.isEmpty())
        {
            Map<Id,Contact> mapOfContacts = new Map <Id,Contact>([select id, name, email, AccountId,Unity_Invitor_User__c, Account.Name, UnityInviteToken__c,Unity_Invitor__c,Unity_Invitor_Title__c,Unity_Invitor_Email__c,Unity_Invitor_Account__r.Name from Contact where id IN: listOfContactId]);          
            for(Task task: listOfTasks)
            {
             if(mapOfContacts.containsKey(task.whoId))  
             {
                if(task.subject == COLLEAGUE_INVITE)
                {
                    populateInviteEmail(mapOfContacts.get(task.whoId),COLLEAGUE_INVITE_TEMPLATEID,task);
                }
                if(task.subject == SALES_INVITE)
                {
                    populateInviteEmail(mapOfContacts.get(task.whoId),SALES_INVITE_TEMPLATEID,task);
                }
                Id AcctId = mapOfContacts.get(task.whoId).AccountId;
                
                task.WhatId = AcctId;
                Id invitorId = mapOfContacts.get(task.whoId).Unity_Invitor_User__c;
                if( invitorId != null)
                {
                    task.ownerId = invitorId;
                }
                
             }
            }
        }
        
    }
    
    public static boolean checkIfEmailToBeLogged(String whoId, String sub)
    {
        if((whoId+'').startsWith('003') && (sub == COLLEAGUE_INVITE || sub == SALES_INVITE))
        {
                return true;
        }
        return false;
    }
    
    
    public static void populateInviteEmail(Contact con, String templateId, Task task)
    {
        List<EmailTemplate> emailTemp = new List<EmailTemplate>();
        emailTemp = [Select e.Id, e.subject, e.Body From EmailTemplate e where id =:templateId limit 1];
        String taskDesc = 'To: ' + con.Unity_Invitor_Email__c+ ';' + con.email + '\n';
         
        if(!emailTemp.isEmpty())
        {
            taskDesc =  taskDesc + 'Subject: ' + replaceFieldsWithValue(emailTemp[0].subject,con) + '\n';
            taskDesc =  taskDesc + 'Body: \n' + replaceFieldsWithValue(emailTemp[0].body,con);
            task.description =  taskDesc;
            task.Subject =  'Email: ' + replaceFieldsWithValue(emailTemp[0].subject,con);
        }
        
    }
    
    public static String replaceFieldsWithValue(String email, Contact con)
    {
        
        if(email.indexof(ACCOUNT_NAME) != -1)
        {
            email = email.replace(ACCOUNT_NAME,con.Account.Name);           
        }
        if(email.indexof(CONTACT_NAME) != -1)
        {
            email = email.replace(CONTACT_NAME,con.Name);           
        }
        if(email.indexof(CONTACT_UNITY_INVITE_TOKEN) != -1)
        {
            if(con.UnityInviteToken__c != null)
            email = email.replace(CONTACT_UNITY_INVITE_TOKEN,con.UnityInviteToken__c);
        }
        if(email.indexof(CONTACT_UNITY_INVITOR) != -1)
        {
            if(con.Unity_Invitor__c != null)
            email = email.replace(CONTACT_UNITY_INVITOR,con.Unity_Invitor__c);
        }
        if(email.indexof(CONTACT_UNITY_INVITOR_TITLE) != -1)
        {
            if(con.Unity_Invitor_Title__c != null)
            email = email.replace(CONTACT_UNITY_INVITOR_TITLE,con.Unity_Invitor_Title__c);
        }
        if(email.indexof(CONTACT_UNITY_INVITOR_EMAIL) != -1)
        {
            if(con.Unity_Invitor_Email__c != null)
            email = email.replace(CONTACT_UNITY_INVITOR_EMAIL,con.Unity_Invitor_Email__c);
        }
        if(email.indexof(CONTACT_UNITY_INVITOR_ACCOUNT) != -1)
        {
            if(con.Unity_Invitor_Account__r.Name != null)
            email = email.replace(CONTACT_UNITY_INVITOR_ACCOUNT,con.Unity_Invitor_Account__r.Name );
        }
        if(email.indexof(ORGANIZATION_NAME) != -1)
        {
            email = email.replace(ORGANIZATION_NAME,OMNITRACS_INC);
        }
        
        return email;
        
    }
    
    

}