/*******************************************************************************
 * File:  CRTesterHomePageController.cls
 * Date:  Sep 14, 2009  
 * Author:  Charlie Heaps
 *
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 * *******************************************************************************/
 
public class CRTesterHomePageController 
{
    // Constructor
    public CRTesterHomePageController()
    {
        defaultTab = ApexPages.currentPage().getParameters().get('tab');
        if(defaultTab == null)
        {
            defaultTab = 'groupScores';
        }
        
        // Determine if current user is a PD Group Lead.
        
        ID userID = UserInfo.getUserId();
        
        showTesterPicklist = false;
        showContent = true;
        
        List<CR_Version_Task_Group__c> myGroup = 
           [select Id, Primary_Function__c
            from CR_Version_Task_Group__c 
            where Group_Lead__c = :userId limit 1];
          
        UserRole role = [select Name from UserRole where Id = :UserInfo.getUserRoleId()];
            
        if (myGroup.isEmpty() && role.Name != 'Director of Product Development')
        {
            // Current user is not a group lead.
            // Check if the current user is in a testing group.
            List<CR_Version_Task_Group_Member__c> tester = 
               [select Member__r.Id, Member__r.Name
                from CR_Version_Task_Group_Member__c 
                where Member__c = :userId and 
                      CR_Version_Task_Group__r.Primary_Function__c = 'Testing'];
            
            if (tester.isEmpty())
            {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.INFO, 
                        'The content of this page is not available because you are not a tester in a Testing group.'));
                
                showContent = false;
            }
            else
            {
                pdLeadId = [select CR_Version_Task_Group__r.Group_Lead__c from CR_Version_Task_Group_Member__c where Member__c = :userId and CR_Version_Task_Group__r.Primary_Function__c = 'Testing' limit 1].CR_Version_Task_Group__r.Group_Lead__c;
            }   
            testerId = userId;
        }
        else
        {
            // User is a PD group lead. Allowed to see all members of all testing groups.
            
            List<CR_Version_Task_Group__c> groups = 
               [select 
                    Id, 
                    Name,
                    Group_Lead__c,
                    Group_Lead__r.Name, 
                    Description__c
                from CR_Version_Task_Group__c 
                where Primary_Function__c = 'Testing'
                order by Group_Lead__r.LastName asc];
            
            pdLeadItems = new List<SelectOption>();

            CR_Version_Task_Group__c defaultGroup = null;
            
            for (CR_Version_Task_Group__c pdGroup : groups)
            {
                pdLeadItems.add(new SelectOption(pdGroup.Group_Lead__c, pdGroup.Group_Lead__r.Name));
            }
            
            showTesterPicklist = true;
            
            if(ApexPages.currentPage().getParameters().get('pdLeadId') != null)
            {
                pdLeadId = ApexPages.currentPage().getParameters().get('pdLeadId');
            }
            else if (myGroup.size() > 0 && myGroup.get(0).Primary_Function__c == 'Testing')
            {
                pdLeadId = userId;
            }
            else
            {
                // Current user is lead of a non-testing group. Must set the pdLeadId to the
                // lead of the first testing group.
                pdLeadId = groups.get(0).Group_Lead__c;
            }

            String userIdParam = ApexPages.currentPage().getParameters().get('user_id');
            if (userIdParam != null)
            {
                testerId = userIdParam;
            }
            else
            {
                testerId = groupMemberItems.get(0).getValue();
            }
        }
    }
    
    public PageReference pageActionMethod()
    {
        m_tester = null;
        return null;
    }
    
    public String defaultTab {get; set;}

    public Boolean showTesterPicklist {get; set;}
    
    public Id testerId
    {
        get;
        
        set
        {
            testerId = value;
            
            List<CR_Version_Task_Group_Member__c> groupMembers = 
              [select CR_Version_Task_Group__c 
               from CR_Version_Task_Group_Member__c 
               where member__c = :testerId limit 1];
               
            if (!groupMembers.isEmpty())
            {
                groupId = groupMembers.get(0).CR_Version_Task_Group__c;
            }

            m_tester = null;
        }
    }
    
    private User m_tester = null;
    
    public User tester 
    {
        get
        {
            if (m_tester == null)
            {
                m_tester = [select Id, Name from User where Id = :testerId];
            }
            return m_tester;
        }
    }
    
    public Id pdLeadId
    {
        get;
        
        set
        {
            pdLeadId = value;
            m_pdLead = null;
            m_groupMembers = null;
            m_groupMemberItems = null;
            
            testerId = groupMembers.get(0).Member__c;
        }
    }
    
    private User m_pdLead = null;
    
    public User pdLead 
    {
        get
        {
            if (m_pdLead == null)
            {
                List<User> leads =
                    [select Id, Name from User where Id = :pdLeadId limit 1];
                    
                if (!leads.isEmpty())
                {
                    m_pdLead = leads.get(0);
                }
            }
            return m_pdLead;
        }
    }

    public ID groupId 
    {
        get; 
    
        set
        {
            groupId = value;
            m_pdGroup = null;
        }
    }
    
    
    private CR_Version_Task_Group__c m_pdGroup = null;
    
    public CR_Version_Task_Group__c pdGroup
    {
        get
        {
            if (m_pdGroup == null)
            {
               List<CR_Version_Task_Group__c> groups = 
                   [select 
                       Id, 
                       Name, 
                       Description__c
                    from CR_Version_Task_Group__c 
                    where Id = :groupId limit 1];       
                   
               if (!groups.isEmpty())
               {
                  m_pdGroup = groups.get(0);                
               }
            }
            
            return m_pdGroup;
        }
    }
    
    public List<SelectOption> pdLeadItems {get; set;}
        
    private List<CR_Version_Task_Group_Member__c> m_groupMembers; 
    
    public List<CR_Version_Task_Group_Member__c> groupMembers 
    {
        get
        {
            if (m_groupMembers == null)
            {
                m_groupMembers = 
                   [select Member__r.Id, Member__r.Name 
                    from CR_Version_Task_Group_Member__c 
                    where CR_Version_Task_Group__r.Group_Lead__c = :pdLeadId];
            }
            return m_groupMembers;            
        }
    }

    private List<SelectOption> m_groupMemberItems = null;
    
    public List<SelectOption> groupMemberItems
    {
        get
        {
            if (m_groupMemberItems == null)
            {       
                m_groupMemberItems = new List<SelectOption>();
                
                SelectOption leadSelectOption = null;
                
                for (CR_Version_Task_Group_Member__c member : groupMembers)
                {
                    if (member.member__r.Id != pdLeadId)
                    {
                        m_groupMemberItems.add(new SelectOption(member.member__r.Id, member.member__r.Name));
                    }
                    else
                    {
                        leadSelectOption = new SelectOption(member.member__r.Id, member.member__r.Name);        
                    }
                }
                
                m_groupMemberItems.add(leadSelectOption);
            }
            
            return m_groupMemberItems;
        }
    }
    
    public Boolean showContent {get; set;}
    
    // Page event handlers

    public Pagereference onTesterChange()
    {
        return new PageReference('/apex/CRTesterHomePage?user_id=' + testerId);
    }
    
    public Pagereference onRefresh()
    {
        m_tester = null;
        PageReference refreshedPage = new PageReference('/apex/CRTesterHomePage?user_id=' + testerId + '&pdLeadId=' + pdLeadId);
        refreshedPage.setRedirect(true);
        return refreshedPage;
    }

    // inner classes    
    public class myException extends Exception
    {
    }
}