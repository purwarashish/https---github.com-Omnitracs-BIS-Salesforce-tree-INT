public class CaseTemplateListController{

        public list<Template__C> templateList {get;set;}
        Public List<SelectOption> options = new List<SelectOption>();
        public Boolean asce {get; set;}
        public String folder{get;set;}
        public String templateID{get;set;}
        String ActivatedURL;


        public void setoptions (List<SelectOption> options )
        {

            this.options = options ;
        }

        public List<SelectOption> getoptions ()
        {
            return options ;
        }



        public CaseTemplateListController()
        {
        }

        public CaseTemplateListController(ApexPages.StandardController controller)
        {

            asce = true;
            getTemplateList();
        }

        public void getTemplateList()
        {
            try
            {
                templateList = [Select Id,Name,Description__c,Folder__c from Template__C where IsActive__c = true order by Name limit 1000];
            }
            catch(Exception e)
            {
                system.debug('Exception in querying template List:'+e);
            }
            Schema.DescribeFieldResult fieldResult = Template__C.Folder__c.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry entry : picklistEntries)
            options.add(new SelectOption(entry.getLabel(), entry.getValue()));
        }

        public PageReference SelectedRecords()
        {

            if(folder == 'AllFolders')
            {
                try
                {
                    if(asce == false)
                    templateList = [Select Id,Name,Description__c,Folder__c from Template__C where IsActive__c = true order by Name desc limit 1000];
                    else
                    templateList = [Select Id,Name,Description__c,Folder__c from Template__C where IsActive__c = true order by Name asc limit 1000];
                }
                catch(Exception e)
                {
                    system.debug('Exception inn querying ALL Folders:'+e);
                }
            }
            else
            {
                templateList.clear();
                
                list<Template__C> temp = new list<Template__C>();
                try
                {
                    if(asce == false)
                    temp = [Select Id,Name,Description__c,folder__C from Template__C where IsActive__c = true order by Name desc limit 1000];
                    else
                    temp = [Select Id,Name,Description__c,folder__C from Template__C where IsActive__c = true order by Name asc limit 1000];
                }
                catch(Exception e)
                {
                    system.debug('Exception in querying date based on selected folder:'+e);
                }
                if(temp.size()>0)
                {
                    for(integer j=0;j<temp.size();j++)
                    {
                        
                        String[] list2 = new String[]{};
                        if(temp[j].folder__c !=null)
                        {
                            list2 = temp[j].folder__c.split(';');
                            
                        }
                        list<String> list1 = new list<string>();
                        for(integer k=0;k<list2.size();k++)
                        {
                            if(list2[k] == folder)
                            {
                                
                                templateList.add(temp[j]);
                                
                            }
                        }
                    }
                }
            }
            
            return null;
        }

        public PageReference CreateNewCase()
        {
            String arglist;
            Boolean Setaccount=false;
            String val;
            Id acct;
            Id con;
            Id nmcacct;
            String username='';
            String userId='';
            String Mycon='';
            list<Contact> ContactObject = new list<Contact>();
            list<NMC_Account__c> NMC_Acct = new list<NMC_Account__c>();
            Boolean IsRecordtypeId = false;
            

            list<Template__c> newtemplate = [select name,NumTotal__c from template__c where id=:templateID];
            
            list<TemplateDetail__c> templateDetailList = [Select Id,Name,Value__c from TemplateDetail__c Where TemplateId__c =:templateID];
            for(Integer e=0;e<templateDetailList.size();e++)
            {
                
            }

            try
            {

                String AccountId1 = ApexPages.currentPage().getParameters().get('AccountId');
                Account Account_Name;
                Contact Contact_Name;
                NMC_Account__c NMCAcctName;

                if(AccountId1 != '')
                {
                    
                    Account_Name = [Select name, id from Account where Id =: AccountId1 limit 1];
                    if(Account_Name != null)
                    acct = Account_Name.Id;
                    
                }

                String ContactId = ApexPages.currentPage().getParameters().get('ContactId');
                if(ContactId != '')
                {

                    
                    Contact_Name = [select Name,Id,AccountId from Contact where Id =: ContactId limit 1];
                    if(Contact_Name != null)
                    {
                        acct = Contact_Name.AccountId;
                        con = Contact_Name.Id;
                    }
                    
                }

                String NMCAcctId = ApexPages.currentPage().getParameters().get('NMCAcct');
                if(NMCAcctId != '')
                {
                    system.debug('NMCAcctID:'+NMCAcctId);
                    NMCAcctName = [Select Id from NMC_Account__c where NMC_Account__c.Id =:NMCAcctId limit 1];
                    if(NMCAcctName != null)
                    {
                        nmcacct = NMCAcctName.Id;
                    } 
                    
                }

                if(newtemplate.size()>0)
                {
                    if(newtemplate[0].NumTotal__c == null)
                    {
                        newtemplate[0].NumTotal__c = 0;
                    }
                    newtemplate[0].NumTotal__c = newtemplate[0].NumTotal__c + 1;
                    
                    update newtemplate[0];
                }

                

                if(templateDetailList.size()>0)
                {
                    integer j =0;
                    for(integer i=0;i<templateDetailList.size();i++)
                    {

                        
                        //templateDetailList[i].Value__c = EncodingUtil.urlEncode(templateDetailList[i].Value__c , 'UTF-8');
                        

                        if(templateDetailList[i].Name == 'AccountId')
                        {
                            
                            if(acct != null)
                            {
                                
                                templateDetailList[i].Value__c = acct;
                                acct = '';
                            }

                        }


                        if(templateDetailList[i].Name == 'ContactId')
                        {
                            if(con != null)
                            {
                                templateDetailList[i].Value__c = con;
                                con ='';
                                MyCon=templateDetailList[i].Value__c;


                            }

                        }


                        if(templateDetailList[i].Name == 'NMC_Account__c')
                        {
                            if(nmcacct != null)
                            {
                                templateDetailList[i].Value__c = nmcacct ;
                                nmcacct ='';
                            }

                        }

                    }//end of for loop
                    
                    if(acct != null)
                    {
                        
                        templateDetailList.add(new TemplateDetail__c(Name='AccountId',Value__c = acct));
                    }
                    if(con != null)
                    {
                        
                        templateDetailList.add(new TemplateDetail__c(Name='ContactId',Value__c = con));
                        //MyCon=con;
                    }
                    if(nmcacct != null)
                    {
                        
                        templateDetailList.add(new TemplateDetail__c(Name='NMC_Account__c',Value__c = nmcacct));
                    }
                    /*if(MyCon!='')
    {
    Contact FinalContactSelect = [select Name from Contact Where Id =: Mycon limit 1];
    username = EncodingUtil.urlEncode(FinalContactSelect.Name , 'UTF-8');
    userID=MyCon;

    }*/

                }// end of if(templatedetaillist.size()>0)

            }//end of try block
            catch(Exception e)
            {
                system.debug(e);
            }

                for(integer i=0;i<templateDetailList.size();i++)
                {
                    
                    templateDetailList[i].Value__c = EncodingUtil.urlEncode(templateDetailList[i].Value__c , 'UTF-8');

                    if(templateDetailList[i].Name == 'RecordTypeId')
                    {
                        IsRecordtypeId=true;
                        val = templateDetailList[i].Value__c;
                        
                        
                    }
                }
                arglist = findURL(templateDetailList,nmcacct);
           
            

            if(IsRecordtypeId == true)
            {
                if(arglist!=null && arglist.trim() != '')
                {
                    arglist = arglist.substring(4,arglist.length());
                } 
                ShowSupportAlertController newSuppalertObj = new ShowSupportAlertController();

                //DAR - 2 May 2011 - Removed to disable Support Alerts
                //if(!(newSuppalertObj.testTemplate(val)))
                    ActivatedURL = '/500/e?retURL=%2F500%2Fo&RecordType='+val+'&cancelURL=%2Fa0M%2Fo&ent=Case&nooverride=1' + arglist;
                //else
                //    ActivatedURL = '/apex/CallCenterCase?RecordType='+val+'&cancelURL=%2Fa0M%2Fo&ent=Case&nooverride=1&templateID='+templateID+'&acctId='+acct+'&contId='+con+'&nmc='+nmcacct ;
            }
            else
            {
                
                ActivatedURL = '/setup/ui/recordtypeselect.jsp?ent=Case&retURL=%2F500%2Fo&save_new_url=%2F500%2Fe%3FretURL%3D%252F500%252Fo'+arglist+'&templateID='+templateID+'&acctId='+acct+'&contId='+con+'&nmc='+nmcacct ;
            }

            PageReference pageRef = new PageReference(ActivatedURL);
            pageRef.setRedirect(true);
            return pageRef;


            return null;
        }

        public PageReference ChangeOrder()
        {


            if(asce == false)
            {
                
                asce =true;
                PageReference pageRef = SelectedRecords();
                return pageRef;
            }
            else if(asce == true)
            {
                
                asce = false;
                PageReference pageRef=SelectedRecords();
                return pageRef;
            }
            return null;
        }

        public PageReference createCase()
        {
            templateID = ApexPages.currentPage().getParameters().get('tempID');
            CreateNewCase();
            
            PageReference pageRef = new PageReference(ActivatedURL);
            pageRef.setRedirect(true);
            return pageRef;

        }
        
        
       
        public String findURL(list<TemplateDetail__c> templateDetailList, Id nmcacct)
        {
             String arglist='';
             String val;
             Boolean Setaccount=false;
             Boolean IsCallCenter = false;
             Boolean IsRecordtypeId = false;
             String username='';
              try{
                for(integer i=0;i<templateDetailList.size();i++)
                {
                    
                    //templateDetailList[i].Value__c = EncodingUtil.urlEncode(templateDetailList[i].Value__c , 'UTF-8');

                    if(templateDetailList[i].Name == 'RecordTypeId')
                    {
                        IsRecordtypeId=true;
                        val = templateDetailList[i].Value__c;
                        
                        
                    }
                    if(val != null)
                        if(!(val.contains(System.Label.Call_Center_RecordTypeId)))
                            IsCallCenter = true;
                    if(!IsCallCenter || IsRecordtypeId)
                    {
                    
                    if(templateDetailList[i].Name == 'Description')
                    {
                        
                        String description = templateDetailList[i].Value__c;

                        arglist+='&cas15='+description;
                    }
                   
                    if(templateDetailList[i].Name == 'Type')
                    {
                        String type1= templateDetailList[i].Value__c;
                        arglist+='&cas5='+type1;

                    }

                    if(templateDetailList[i].Name == 'Status')
                    {
                        String Status= templateDetailList[i].Value__c;
                        arglist+='&cas7='+Status; 
                    }

                    if(templateDetailList[i].Name == 'Reason')
                    {
                        String Reason= templateDetailList[i].Value__c;
                        arglist+='&cas6='+Reason;
                    }

                    if(templateDetailList[i].Name == 'Origin')
                    {
                        String Origin= templateDetailList[i].Value__c;
                        arglist+='&cas11='+Origin;
                    }

                    if(templateDetailList[i].Name == 'Subject')
                    {
                       
                        String Subject= templateDetailList[i].Value__c;
                        arglist+='&cas14='+Subject;
                    }

                    if(templateDetailList[i].Name == 'Priority')
                    {
                        String Priority= templateDetailList[i].Value__c;
                        arglist+='&cas8='+Priority;
                    }

                    if(templateDetailList[i].Name == 'Call_Back__c')
                    {
                        String CallBack= templateDetailList[i].Value__c;
                        arglist+='&00N50000001Kko5='+CallBack;
                    }

                    if(templateDetailList[i].Name == 'Queue__c')
                    {
                        String Queue= templateDetailList[i].Value__c;
                        arglist+='&00N50000001ccXr='+Queue;
                    }

                    if(templateDetailList[i].Name == 'Product__c')
                    {
                        String Product= templateDetailList[i].Value__c;
                        arglist+='&00N50000001Y6W8='+Product;
                    }

                    if(templateDetailList[i].Name == 'Category__c')
                    {
                        String Category= templateDetailList[i].Value__c;
                        arglist+='&00N50000001cXoi='+Category;
                    }

                    if(templateDetailList[i].Name == 'Type_Level_2__c')
                    {
                        String Type_Level_2= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001cXos='+Type_Level_2;
                    }

                    if(templateDetailList[i].Name == 'Area_Level_3__c')
                    {
                        String Area_Level_3= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001cXox='+Area_Level_3;
                    }

                    if(templateDetailList[i].Name == 'Technical_Tip__c')
                    {

                        if(templateDetailList[i].Value__c == 'true')
                        arglist = arglist +'&00N50000001cXod=1';
                    }

                    if(templateDetailList[i].Name == 'Customer_Complaint__c')
                    {
                        if(templateDetailList[i].Value__c == 'true')
                        arglist = arglist +'&00N50000001Kkoj=1';
                    }

                    if(templateDetailList[i].Name == 'Human_Interest__c')
                    {
                        if(templateDetailList[i].Value__c == 'true')
                        arglist = arglist +'&00N50000001Kkqb=1';
                    }

                    if(templateDetailList[i].Name == 'Engineering_Tracking__c')
                    {
                        String Engineering_Tracking= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001cXoJ='+Engineering_Tracking;
                    }

                    if(templateDetailList[i].Name == 'Substatus__c')
                    {
                        String Substatus= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001Kkos='+Substatus;
                    }

                    if(templateDetailList[i].Name == 'System__c')
                    {
                        arglist = arglist +'&00N50000001KkqM='+templateDetailList[i].Value__c;
                    }

                    if(templateDetailList[i].Name == 'RMA__c')
                    {
                        String RMA= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001KknF='+RMA;
                    }

                    if(templateDetailList[i].Name == 'Serial__c')
                    {
                        String Serial= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001Kkq2='+Serial;
                    }

                    if(templateDetailList[i].Name == 'Firmware__c')
                    {
                        String Firmware= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001KkoW='+Firmware;
                    }

                    if(templateDetailList[i].Name == 'SR_NUM__c')
                    {
                        String SR_NUM= templateDetailList[i].Value__c;
                        arglist = arglist +'&00NT0000000iTI4='+SR_NUM;
                    }

                    if(templateDetailList[i].Name == 'Siebel_ID__c')
                    {
                        String Siebel_ID= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001KlY9='+Siebel_ID;
                    }

                    if(templateDetailList[i].Name == 'Resolution__c')
                    {
                        String Resolution= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001cXoU='+Resolution;
                    }

                    if(templateDetailList[i].Name == 'Equipment_ID__c')
                    {
                        String Equipment_ID= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001cXoO='+Equipment_ID;
                    }

                    if(templateDetailList[i].Name == 'Created_by_Queue__c')
                    {
                        String Created_by_Queue= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001caH3='+Created_by_Queue;
                    }

                    if(templateDetailList[i].Name == 'Shift_Report__c')
                    {
                        String Shift_Report= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001Kkpz=1';
                    }

                    if(templateDetailList[i].Name == 'Add_Remove__c')
                    {
                        String Add_Remove= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001f7sm='+Add_Remove;
                    }

                    if(templateDetailList[i].Name == 'Aux_Sensor__c')
                    {
                        String Aux_Sensor= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001f7uO='+Aux_Sensor;
                    }

                    if(templateDetailList[i].Name == 'Cargo_Sensor__c')
                    {
                        String Cargo_Sensor= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001f7uT='+Cargo_Sensor;
                    }

                    if(templateDetailList[i].Name == 'Contract_Description__c')
                    {
                        String Contract_Description= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001f7ud='+Contract_Description;
                    }

                    if(templateDetailList[i].Name == 'Contract_Product__c')
                    {
                        String Contract_Product= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001f7un='+Contract_Product;
                    }

                    if(templateDetailList[i].Name == 'Cross_Street_Location__c')
                    {
                        String Cross_Street_Location= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001f7vM='+Cross_Street_Location;
                    }

                    if(templateDetailList[i].Name == 'Customer_Hosted__c')
                    {
                        String Customer_Hosted= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001f7vR='+Customer_Hosted;
                    }

                    if(templateDetailList[i].Name == 'Door_Sensor__c')
                    {
                        String Door_Sensor= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001f84B='+Door_Sensor;
                    }

                    if(templateDetailList[i].Name == 'End_of_Eval__c')
                    {
                        String End_of_Eval= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001f85q='+End_of_Eval;
                    }

                    if(templateDetailList[i].Name == 'Internal_Default_for_Status_Rpt_Interval__c')
                    {
                        String Internal= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001f85v='+Internal;
                    }

                    if(templateDetailList[i].Name == 'Qualcomm_Hosted__c')
                    {
                        String Qualcomm_Hosted= templateDetailList[i].Value__c;
                        arglist = arglist +'&00N50000001f86Z='+Qualcomm_Hosted;
                    }

                    if(templateDetailList[i].Name == 'Queued_Status_Report_Interval__c')
                    {
                        arglist = arglist +'&00N50000001f86B='+templateDetailList[i].Value__c;
                    }

                    if(templateDetailList[i].Name == 'Requested_Default_NMC_Acct_for_Unit_Type__c')
                    {
                        arglist = arglist +'&00N50000001f86e='+templateDetailList[i].Value__c;
                    }

                    if(templateDetailList[i].Name == 'Requested_NMC_Account_Status__c')
                    {
                        arglist = arglist +'&00N50000001f86f='+templateDetailList[i].Value__c;
                    }

                    if(templateDetailList[i].Name == 'Requested_Retention_Period__c')
                    {
                        arglist = arglist +'&00N50000001f8Aj='+templateDetailList[i].Value__c;
                    }

                    if(templateDetailList[i].Name == 'Services__c')
                    {
                        arglist = arglist +'&00N50000001f8Ay='+templateDetailList[i].Value__c;
                    }

                    if(templateDetailList[i].Name == 'Telecom_For_Customer_Hosted__c')
                    {
                        arglist = arglist +'&00N50000001f8BD='+templateDetailList[i].Value__c;
                    }

                    if(templateDetailList[i].Name == 'Telecom_For_Third_Party_Hosted__c')
                    {
                        arglist = arglist +'&00N50000001f8BS='+templateDetailList[i].Value__c;
                    }

                    if(templateDetailList[i].Name == 'Test_Account__c')
                    {
                        arglist = arglist +'&00N50000001f8BX='+templateDetailList[i].Value__c;
                    }

                    if(templateDetailList[i].Name == 'Third_Party_Hosted__c')
                    {
                        arglist = arglist +'&00N50000001f8Bc='+templateDetailList[i].Value__c;
                    }

                    if(templateDetailList[i].Name == 'Unit_Type__c')
                    {
                        arglist = arglist +'&00N50000001f8Bh='+templateDetailList[i].Value__c;
                    }


                    if(templateDetailList[i].Name == 'CI__c')
                    {
                        
                        
                        if(nmcacct == null)
                        {
                            
                            arglist = arglist +'&00N50000001KkqR='+templateDetailList[i].Value__c;
                        }
                    }

                    if(templateDetailList[i].Name == 'AccountId')
                    {
                        Account acc = [Select Id,name from Account where id =:templateDetailList[i].Value__c limit 1];
                        if(acc !=null)
                        {
                            String actname= EncodingUtil.urlEncode(acc.name, 'UTF-8');
                            String AccId = acc.Id;
                            AccId = AccId.Substring(0,15);
                            arglist+= '&cas4=' + actname + '&cas4_lkid='+ AccId ;
                            //arglist+= '&cas4='+actname;
                            Setaccount=true;
                        }

                    }

                    if(templateDetailList[i].Name == 'NMC_Account__c')
                    {
                        
                        list<NMC_Account__c> newNMC = [Select Id, Name, NMC_Account_Name__c, Customer_Interface__c, Account__c from NMC_Account__c where Id =:templateDetailList[i].Value__c limit 1] ;
                        if(newNMC.size()>0)
                        {
                            arglist+= '&CF00N50000001cc33='+EncodingUtil.urlEncode(newNMC[0].NMC_Account_Name__c, 'UTF-8');
                            arglist+= '&CF00N50000001cc33_lkid='+newNMC[0].Id;
                            if(newNMC[0].Customer_Interface__c != null)
                            {
                                arglist+= '&00N50000001KkqR='+newNMC[0].Customer_Interface__c;
                            } 
                            String acctIdOnNMC = newNMC[0].Account__c;
                            acctIdOnNMC =acctIdOnNMC.substring(0,15);
                            if(acctIdOnNMC!= null && Setaccount==false)
                            {
                                Account accname = [Select name from Account where Id=: acctIdOnNMC limit 1];
                                String name= accname.name;
                                arglist+= '&cas4='+EncodingUtil.urlEncode(name, 'UTF-8')+'&cas4_lkid='+acctIdOnNMC;
                            }
                        }
                    }

                   
                    //arglist+='&cas3_lkid='+userID;
                    //arglist+='&cas3='+username;
                    if(templateDetailList[i].Name == 'ContactId')
                    {
                        list<Contact> cnt = [select Id,Name,AccountId from Contact Where Id =:templateDetailList[i].Value__c limit 1];
                        if(cnt.size()>0)
                        {
                            username = EncodingUtil.urlEncode(cnt[0].Name , 'UTF-8');
                            arglist+='&cas3='+username+'&cas3_lkid='+cnt[0].Id;
                            String AccIdonCnt=cnt[0].AccountId;
                            
                            if(AccIdonCnt!=null && Setaccount==false)
                            {
                                Account accname = [Select name from Account where Id=:AccIdonCnt limit 1];
                                String aname=accname.name;
                                arglist+='&cas4='+EncodingUtil.urlEncode(aname,'UTF-8')+'&cas4_lkid='+AccIdonCnt;
                            }
                        } 
                    }

                } 
            }
            }

            catch(Exception e)
            {
                system.debug(e);
            }

            return arglist;
        }
        
            

    }