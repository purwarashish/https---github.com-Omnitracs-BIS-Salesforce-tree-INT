/**********************************************************************************************
* @author  Ataullah Khan       
* @date     09.APR.14      
* @description: Class to handle different operations invoked by the 
                NeedsFieldCalculation trigger.
* @Revision(s):  
**********************************************************************************************/
public with sharing class VCG_CPQ_NeedsFieldsTrigHandler {
    
    /**********************************************************************************************
     * @author  Ataullah Khan       
     * @date     09.APR.14      
     * @description: Method to handle After insert event on  VCG_CPQ_Pricing_Sequence_Condition__c and 
     *               VCG_CPQ_Pricing_Procedure_Sequence__c Object.
     * @Revision(s):  
     **********************************************************************************************/
    public void afterInsert(List<sObject> sobjLst) {
        // Local Variable Declaration
        String ObjectName;                     // Stores name of the object which will be processed.
        List<ID> ObjIdLst = new List<ID>();    // Stores list of IDs of the Object for which the trigger is invoked.
        Set<ID> PrntIdst = new Set<ID>();      // Stores list of IDs of the parent Object(VCG_CPQ_Pricing_Access_Sequence__c)
        Set<ID> GprntIDst = new Set<ID>();     // Stores list of IDs of the Garndparent Object(VCG_CPQ_Pricing_Procedure__c)
        Set<ID> ChdIdst = new Set<ID>();       // Stores list of IDs of the Child Object(VCG_CPQ_Pricing_Condition__c)
        
        // Checking the Object Type
        if (sobjLst[0].getsObjectType() == VCG_CPQ_Pricing_Sequence_Condition__c.sObjectType) {
            ObjectName = 'VCG_CPQ_Pricing_Sequence_Condition__c';
        }   
        else if (sobjLst[0].getsObjectType() == VCG_CPQ_Pricing_Procedure_Sequence__c.sObjectType) {
            ObjectName = 'VCG_CPQ_Pricing_Procedure_Sequence__c';
        }
    
        // populating related IDs
        for (sobject ob : sObjLst) {
            ObjIdLst.add((ID)ob.get('Id'));
        }
        
        // Populating the parent and child Id list
        if (ObjectName == 'VCG_CPQ_Pricing_Sequence_Condition__c') {
            for (sobject psc : sobjLst) {
                PrntIdst.add((ID)psc.get('Access_Sequence__c'));
                ChdIdst.add((ID)psc.get('Condition__c'));
            }
        }
        // Populating the Garndparent and child Id list
        if (ObjectName == 'VCG_CPQ_Pricing_Procedure_Sequence__c') {
            for (sobject ps : sobjLst) {
                GprntIdst.add((ID)ps.get('Pricing_Procedure__c'));  
                ChdIdst.add((ID)ps.get('Access_Sequence__c'));
            }
        }
     
      
        if (ObjectName == 'VCG_CPQ_Pricing_Sequence_Condition__c') {
            // Retriving all Child records related to the middle Object
            Map<ID,VCG_CPQ_Pricing_Condition__c> PriCondMap = new Map<ID,VCG_CPQ_Pricing_Condition__c>([Select ID,Needs_Fields__c from VCG_CPQ_Pricing_Condition__c where ID IN: ChdIdst]);
            // Retrieving all parent records related to the middle object 
            MAP<ID,VCG_CPQ_Pricing_Access_Sequence__c> PrAcsSeq = new MAP<ID,VCG_CPQ_Pricing_Access_Sequence__c>([Select Needs_Fields__c,id from VCG_CPQ_Pricing_Access_Sequence__c where ID IN: prntIdst]);
            // Looping over each middle object record and populating the needs field on parent by summing up all needs field value on the child record
            for (sobject s: sObjLst ) {
                Set<String> uniqNames = new Set<String>();
                if (PriCondMap.get((ID)s.get('Condition__c')).Needs_Fields__c != null && PriCondMap.get((ID)s.get('Condition__c')).Needs_Fields__c != '') {
                    List<string> fldName = PriCondMap.get((ID)s.get('Condition__c')).Needs_Fields__c.split(';');
                    uniqNames.addall(fldName);
                    VCG_CPQ_Pricing_Access_Sequence__c Squenc =  PrAcsSeq.get((ID)s.get('Access_Sequence__c'));
                    
                    if (Squenc.Needs_Fields__c == NULL || Squenc.Needs_Fields__c == '') {
                        Squenc.Needs_Fields__c ='';
                    }
                                
                    for (String i: uniqNames) {
                        Squenc.Needs_Fields__c += ((Squenc.Needs_Fields__c == '' || Squenc.Needs_Fields__c == NULL) ?'':';') + i;
                    }   
                    PrAcsSeq.put(Squenc.id,Squenc);               
                }
                        
            }
            
            update PrAcsSeq.values();
        }
        
      if (ObjectName == 'VCG_CPQ_Pricing_Procedure_Sequence__c') {
            // Retriving all parent records related to the middle Object
        MAP<ID,VCG_CPQ_Pricing_Access_Sequence__c> PrAcsSeq = new MAP<ID,VCG_CPQ_Pricing_Access_Sequence__c>([Select Needs_Fields__c,id from VCG_CPQ_Pricing_Access_Sequence__c where ID IN: ChdIdst]);
            // Retriving all Grand parent records related to the middle Object
        MAP<ID,VCG_CPQ_Pricing_Procedure__c> PriProc = new MAP<ID,VCG_CPQ_Pricing_Procedure__c>([Select Needs_Fields__c,id from VCG_CPQ_Pricing_Procedure__c where ID IN: GprntIdst]);
            // Looping over each middle object record and populating the needs field on grandparent by summing up all needs field value on the parent record
        for (sobject s: sObjLst ) {
            Set<String> uniqNames = new Set<String>();
                if (PrAcsSeq.get((ID)s.get('Access_Sequence__c')).Needs_Fields__c != null && PrAcsSeq.get((ID)s.get('Access_Sequence__c')).Needs_Fields__c != '') {
                List<string> fldName = PrAcsSeq.get((ID)s.get('Access_Sequence__c')).Needs_Fields__c.split(';');
                uniqNames.addall(fldName);
                VCG_CPQ_Pricing_Procedure__c Procdr =  PriProc.get((ID)s.get('Pricing_Procedure__c'));
                    
                if (Procdr.Needs_Fields__c == NULL || Procdr.Needs_Fields__c == '') {
                Procdr.Needs_Fields__c ='';
                }
                
                    for (String i: uniqNames) {
                 Procdr.Needs_Fields__c += ((Procdr.Needs_Fields__c == '' || Procdr.Needs_Fields__c == NULL) ?'':';') + i;
                    }
                 
                PriProc.put(Procdr.id,Procdr);                
                }
                        
        }   
        update PriProc.values();
     }   
   }
   
/**********************************************************************************************
* @author  Ataullah Khan       
* @date     09.APR.14      
* @description: Method to handle After Update event on  VCG_CPQ_Pricing_Condition__c and 
                VCG_CPQ_Pricing_Access_Sequence__c Object.
* @Revision(s):  
**********************************************************************************************/  
  public void afterupdate(MAP<ID , sObject> OldsobjMap , MAP<ID , sObject> NewsobjMap) {
    
        String ObjectName;                                                  // Stores name of the object which will be processed.
        Set<ID> ObjIdLst = new Set<ID>();                                   // Stores list of IDs of the Object for which the trigger is invoked.
        Set<ID> PrntIdst = new Set<ID>();                                   // Stores list of IDs of the parent Object(VCG_CPQ_Pricing_Access_Sequence__c)
        Set<ID> GprntIDst = new Set<ID>();                                  // Stores list of IDs of the Garndparent Object(VCG_CPQ_Pricing_Procedure__c)
        Map<id,id> CondnToAcsSeqMap = new Map<id,id>();                     // Map to store Pricing condition to Access sequence ID.
        Map<id,Set<id>> AccsSeqToCondnIDLstMap = new Map<id,Set<id>>();     // Map to store acees seuence IDs and list of all related Pricing Condition record's IDs.
    List<VCG_CPQ_Pricing_Procedure__c> ProcdrLst = new List<VCG_CPQ_Pricing_Procedure__c>();
    List<VCG_CPQ_Pricing_Access_Sequence__c> SeqLst = new List<VCG_CPQ_Pricing_Access_Sequence__c>();
        
        // Checking the Object Type 
        if (OldsobjMap.values()[0].getsObjectType() == VCG_CPQ_Pricing_Condition__c.sObjectType) {
       ObjectName = 'VCG_CPQ_Pricing_Condition__c';
        }   
        else if (OldsobjMap.Values()[0].getsObjectType() == VCG_CPQ_Pricing_Access_Sequence__c.sObjectType) {
       ObjectName = 'VCG_CPQ_Pricing_Access_Sequence__c';
        }
    // find all the records whose Needs Field has been changed   
    for (Sobject s : NewsobjMap.values()) {
         if (((String)s.get('Needs_Fields__c')) != ((String)OldsobjMap.get((ID)s.get('id')).get('Needs_Fields__c')))
            ObjIdLst.add((ID)s.get('id'));
    }  
    
     if (ObjectName == 'VCG_CPQ_Pricing_Condition__c') {
        
        // Query all Middle object Data which is associated with the VCG_CPQ_Pricing_Condition__c record IDs.
        List<VCG_CPQ_Pricing_Sequence_Condition__c> seqCondtn = [SELECT Access_Sequence__c,Condition__c,Id FROM VCG_CPQ_Pricing_Sequence_Condition__c where  Condition__c IN: ObjIdLst];    
        
            // Finding all Parent and their related childs and putting then in a map to keep track of this parent child relationship
        for (VCG_CPQ_Pricing_Sequence_Condition__c psc : seqCondtn) {
            
            if (AccsSeqToCondnIDLstMap.containskey(psc.Access_Sequence__c)) {
                Set<ID> condIDLst = AccsSeqToCondnIDLstMap.get(psc.Access_Sequence__c);
                condIDLst.add(psc.Condition__c);
                AccsSeqToCondnIDLstMap.put(psc.Access_Sequence__c,condIDLst);
            }
           else{
                Set<ID> condIDLst = new Set<ID>();
                condIDLst.add(psc.Condition__c);
                AccsSeqToCondnIDLstMap.put(psc.Access_Sequence__c,condIDLst);
           } 
           PrntIdst.add(psc.Access_Sequence__c); 
           ObjIdLst.add(psc.Condition__c);             
         }
      // Query the Superset List of records Associated with parent ID
      List<VCG_CPQ_Pricing_Sequence_Condition__c> seqCondtnLSt2 = [SELECT Access_Sequence__c,Condition__c,Id FROM VCG_CPQ_Pricing_Sequence_Condition__c where  Access_Sequence__c IN: PrntIdst]; 
        
         // Finding all Parent and their related childs and putting then in a map to keep track of this parent child relationship           
        for (VCG_CPQ_Pricing_Sequence_Condition__c psc1 : seqCondtnLSt2) {
            
            if (AccsSeqToCondnIDLstMap.containsKey(psc1.Access_Sequence__c)) {
                set<ID> condIDLst = AccsSeqToCondnIDLstMap.get(psc1.Access_Sequence__c);
                condIDLst.add(psc1.Condition__c);
                AccsSeqToCondnIDLstMap.put(psc1.Access_Sequence__c,condIDLst);
            }
                /*else{
                set<ID> condIDLst = new set<ID>();
                condIDLst.add(psc1.Condition__c);
                AccsSeqToCondnIDLstMap.put(psc1.Access_Sequence__c,condIDLst);
                }*/           
          ObjIdLst.add(psc1.Condition__c);  
        }
            //Quering all the records associated with parent from the base object
      Map<Id,VCG_CPQ_Pricing_Condition__c> pricCondnMap = new Map<Id,VCG_CPQ_Pricing_Condition__c>([Select Id,Needs_Fields__c from VCG_CPQ_Pricing_Condition__c where ID IN: ObjIdLst]);
           // Quering all the Parent records
     Map<ID,VCG_CPQ_Pricing_Access_Sequence__c> accseqMap = new Map<id,VCG_CPQ_Pricing_Access_Sequence__c>([Select id,Needs_Fields__c from VCG_CPQ_Pricing_Access_Sequence__c where ID IN: PrntIdst]);   
            // Looping over each Access Sequence record and populating the needs field on parent by summing up all needs field value on the child record               
        for (VCG_CPQ_Pricing_Access_Sequence__c i : accseqMap.values()) {
            Set<String> NeedsSet = new Set<String>();
            for (ID id1 : AccsSeqToCondnIDLstMap.get(i.id)) {
             if (pricCondnMap.get(id1).Needs_Fields__c != NULL) {
                List<string> needsLst = pricCondnMap.get(id1).Needs_Fields__c.split(';');
                NeedsSet.addall(needsLst);
                }
             else
               pricCondnMap.get(id1).Needs_Fields__c ='';            
            }
            String NewNeedsValue ='';
            for (String s: NeedsSet)
               NewNeedsValue += (NewNeedsValue == '' ?'':';') + s;
            i.Needs_Fields__c = NewNeedsValue;
            SeqLst.add(i);    
        }
         update SeqLst;
      } 
       

       //for VCG_CPQ_Pricing_Access_Sequence__c Object...
       Map<id,List<id>> PricProcToAscSeqIDLstMap = new Map<id,List<id>>(); // Stores the Id of grand parent and its related parent's Ids

        if (ObjectName == 'VCG_CPQ_Pricing_Access_Sequence__c') {
        List<VCG_CPQ_Pricing_Procedure_Sequence__c> Procseq = [SELECT Access_Sequence__c,Pricing_Procedure__c,Id FROM VCG_CPQ_Pricing_Procedure_Sequence__c where  Access_Sequence__c IN: ObjIdLst];    
            //populating map of Id of pricing  procedure and its related Access Sequence IDs
        for (VCG_CPQ_Pricing_Procedure_Sequence__c psc : Procseq) {
            
            if (PricProcToAscSeqIDLstMap.containskey(psc.Pricing_Procedure__c)) {
                list<ID> procIDLst = PricProcToAscSeqIDLstMap.get(psc.Pricing_Procedure__c);
                procIDLst.add(psc.Access_Sequence__c);
                PricProcToAscSeqIDLstMap.put(psc.Pricing_Procedure__c,procIDLst);
            }
           else{
                list<ID> procIDLst = new List<ID>();
                procIDLst.add(psc.Access_Sequence__c);
                PricProcToAscSeqIDLstMap.put(psc.Pricing_Procedure__c,procIDLst);
           } 
           PrntIdst.add(psc.Pricing_Procedure__c); 
           ObjIdLst.add(psc.Access_Sequence__c);           
         }
      List<VCG_CPQ_Pricing_Procedure_Sequence__c> seqCondtnLSt2 = [SELECT Access_Sequence__c,Pricing_Procedure__c,Id FROM VCG_CPQ_Pricing_Procedure_Sequence__c where  Pricing_Procedure__c IN: PrntIdst]; 
            //populating map of Id of pricing  procedure and its related Access Sequence IDs
        for (VCG_CPQ_Pricing_Procedure_Sequence__c psc1 : seqCondtnLSt2) {
            
            if (PricProcToAscSeqIDLstMap.containsKey(psc1.Pricing_Procedure__c)) {
                list<ID> procIDLst = PricProcToAscSeqIDLstMap.get(psc1.Pricing_Procedure__c);
                procIDLst.add(psc1.Access_Sequence__c);
                PricProcToAscSeqIDLstMap.put(psc1.Pricing_Procedure__c,procIDLst);
            }
                /*else{
                list<ID> procIDLst = new List<ID>();
                procIDLst.add(psc1.Access_Sequence__c);
                PricProcToAscSeqIDLstMap.put(psc1.Pricing_Procedure__c,procIDLst);
                }*/           
          ObjIdLst.add(psc1.Access_Sequence__c);    
        }
            
      Map<Id,VCG_CPQ_Pricing_Access_Sequence__c> pricCondnMap = new Map<Id,VCG_CPQ_Pricing_Access_Sequence__c>([Select Id,Needs_Fields__c from VCG_CPQ_Pricing_Access_Sequence__c where ID IN: ObjIdLst]);
     
     Map<ID,VCG_CPQ_Pricing_Procedure__c> PPMap = new Map<id,VCG_CPQ_Pricing_Procedure__c>([Select id,Needs_Fields__c from VCG_CPQ_Pricing_Procedure__c where ID IN: PrntIdst]);  
            // Populating Pricing Procedure's Needs Field with the values from its related Access Sequence Record's Needs Field
        for (VCG_CPQ_Pricing_Procedure__c i : PPMap.values()) {
            Set<String> NeedsSet = new Set<String>();
            for (ID id1 : PricProcToAscSeqIDLstMap.get(i.id)) {
               if (pricCondnMap.get(id1).Needs_Fields__c != NULL) {
                List<string> needsLst = pricCondnMap.get(id1).Needs_Fields__c.split(';');
                NeedsSet.addall(needsLst);
            }
            else
            pricCondnMap.get(id1).Needs_Fields__c = '';
            }

            String NewNeedsValue ='';
            for (String s: NeedsSet)
               NewNeedsValue += (NewNeedsValue == '' ?'':';') + s;
            i.Needs_Fields__c = NewNeedsValue;
            ProcdrLst.add(i);    
        } 
        update ProcdrLst;
      }     

// End of this part        
  } 
/**********************************************************************************************
* @author  Ataullah Khan       
* @date     09.APR.14      
* @description: Method to handle Before Delete event on  VCG_CPQ_Pricing_Condition__c and 
                VCG_CPQ_Pricing_Access_Sequence__c Object.
* @Revision(s):  
**********************************************************************************************/    
   public void beforedelete(MAP<ID,sObject> OldsobjMap) {
    
        // Local variable store---------------------------------------------------------------------------------------------------
        Map<id,id> CondnToAcsSeqMap = new Map<id,id>();                                         // Variable to hold Pricing condition to related Access Sequence one on one IDs
        Map<id,Set<id>> AccsSeqToCondnIDLstMap = new Map<id,Set<id>>();                         // Variable to hold Map of Access Sequence ID to Set of related Pricing Condition IDs
        List<VCG_CPQ_Pricing_Procedure__c> ProcdrLst = new List<VCG_CPQ_Pricing_Procedure__c>();// Variable to hold List of Pricing Procedure records
        List<VCG_CPQ_Pricing_Access_Sequence__c> SeqLst = new List<VCG_CPQ_Pricing_Access_Sequence__c>();//Variable to hold list of Access Sequence records
        String ObjectName;                                                                      // Variable to hold name of the object for which trigger handler is being called.
        Set<ID> ObjIdSet = new Set<ID>();                                                       // Variable to hold set of all IDs for which the trigger is called.
        Set<ID> PrntIdst = new Set<ID>();                                                       // Variable to store Set of parent IDs for which the trigger is being called.
        Map<id,List<id>> PricProcToAscSeqIDLstMap = new Map<id,List<id>>();                     // Variable to store map of pricing procedure IDs to list of related Access Sequence recird's IDs.
    
        ObjIDSet.addall(oldsobjMap.keyset());
        // Identifying the Object type-------------------------------------------------------------
        if (OldsobjMap.values()[0].getsObjectType() == VCG_CPQ_Pricing_Condition__c.sObjectType) {
         ObjectName = 'VCG_CPQ_Pricing_Condition__c';
        }        
        else if (OldsobjMap.Values()[0].getsObjectType() == VCG_CPQ_Pricing_Access_Sequence__c.sObjectType) {
         ObjectName = 'VCG_CPQ_Pricing_Access_Sequence__c';
        }
        
    
     if (ObjectName == 'VCG_CPQ_Pricing_Condition__c') {
        // Query all Middle object Data which is associated with the VCG_CPQ_Pricing_Condition__c record IDs.
        List<VCG_CPQ_Pricing_Sequence_Condition__c> seqCondtn = [SELECT Access_Sequence__c,Condition__c,Id FROM VCG_CPQ_Pricing_Sequence_Condition__c where  Condition__c IN: ObjIdSet];    
            // populating a list of all related parent and child IDs for further processing 
        for (VCG_CPQ_Pricing_Sequence_Condition__c psc : seqCondtn) {
            
           PrntIdst.add(psc.Access_Sequence__c); 
           ObjIdSet.add(psc.Condition__c);             
         }
            // Retrieving the Sequence condition middle object to get all the related Pricing comdition records IDs related to Access Sequence IDs in "PrntIdst" Set
       List<VCG_CPQ_Pricing_Sequence_Condition__c> seqCondtnLSt2 = [SELECT Access_Sequence__c,Condition__c,Id FROM VCG_CPQ_Pricing_Sequence_Condition__c where  Access_Sequence__c IN: PrntIdst]; 
        
            // Populating the 'AccsSeqToCondnIDLstMap' Map with Access Sequence IDs to the Set of all relates pricing Condition record's IDs
        for (VCG_CPQ_Pricing_Sequence_Condition__c psc1 : seqCondtnLSt2) {
            if (AccsSeqToCondnIDLstMap.containsKey(psc1.Access_Sequence__c)) {
                set<ID> condIDLst = AccsSeqToCondnIDLstMap.get(psc1.Access_Sequence__c);
                condIDLst.add(psc1.Condition__c);
                AccsSeqToCondnIDLstMap.put(psc1.Access_Sequence__c,condIDLst);
            }
            else{
                set<ID> condIDLst = new set<ID>();
                condIDLst.add(psc1.Condition__c);
                AccsSeqToCondnIDLstMap.put(psc1.Access_Sequence__c,condIDLst);
            }           
          ObjIdSet.add(psc1.Condition__c);  
        }
        
            // Removing all unwanted IDs from the Master ID set
      ObjIdSet.removeall(oldsobjMap.keyset());
       
     Map<Id,VCG_CPQ_Pricing_Condition__c> pricCondnMap = new Map<Id,VCG_CPQ_Pricing_Condition__c>([Select Id,Needs_Fields__c from VCG_CPQ_Pricing_Condition__c where ID IN: ObjIdSet]);
     
     Map<ID,VCG_CPQ_Pricing_Access_Sequence__c> accseqMap = new Map<id,VCG_CPQ_Pricing_Access_Sequence__c>([Select id,Needs_Fields__c from VCG_CPQ_Pricing_Access_Sequence__c where ID IN: PrntIdst]);   
     
           // Calculating Needs fields value related to each Access Sequence record and populating it.
        for (VCG_CPQ_Pricing_Access_Sequence__c i : accseqMap.values()) {
            Set<String> NeedsSet = new Set<String>();
            for (ID id1 : AccsSeqToCondnIDLstMap.get(i.id)) {
                if (pricCondnMap.get(id1) != Null) {
                List<string> needsLst = pricCondnMap.get(id1).Needs_Fields__c.split(';');
                NeedsSet.addall(needsLst);
                    }
                }
            String NewNeedsValue ='';
            for (String s: NeedsSet)
               NewNeedsValue += (NewNeedsValue == '' ?'':';') + s;
                   
               i.Needs_Fields__c =NewNeedsValue;
            SeqLst.add(i);    
        }
         update SeqLst;
     }
    

        if (ObjectName == 'VCG_CPQ_Pricing_Access_Sequence__c') {
           // Query all Middle object Data which is associated with the VCG_CPQ_Pricing_Procedure_Sequence__c record IDs.
        List<VCG_CPQ_Pricing_Procedure_Sequence__c> Procseq = [SELECT Access_Sequence__c,Pricing_Procedure__c,Id FROM VCG_CPQ_Pricing_Procedure_Sequence__c where  Access_Sequence__c IN: ObjIdSet];    
           // populating a list of all related parent and child IDs for further processing  
        for (VCG_CPQ_Pricing_Procedure_Sequence__c psc : Procseq) {
           PrntIdst.add(psc.Pricing_Procedure__c); 
           ObjIdSet.add(psc.Access_Sequence__c);           
         }
      
           // Retrieving the Procedure Sequence middle object to get all the related Access Sequence records IDs related to Pricing Procedure IDs in "PrntIdst" Set
      List<VCG_CPQ_Pricing_Procedure_Sequence__c> seqCondtnLSt2 = [SELECT Access_Sequence__c,Pricing_Procedure__c,Id FROM VCG_CPQ_Pricing_Procedure_Sequence__c where  Pricing_Procedure__c IN: PrntIdst]; 
        
          // Populating the 'PricProcToAscSeqIDLstMap' Map with Pricing Procedure IDs to the Set of all relates Access Sequence record's IDs
        for (VCG_CPQ_Pricing_Procedure_Sequence__c psc1 : seqCondtnLSt2) {
            
            if (PricProcToAscSeqIDLstMap.containsKey(psc1.Pricing_Procedure__c)) {
                list<ID> procIDLst = PricProcToAscSeqIDLstMap.get(psc1.Pricing_Procedure__c);
                procIDLst.add(psc1.Access_Sequence__c);
                PricProcToAscSeqIDLstMap.put(psc1.Pricing_Procedure__c,procIDLst);
            }
            else{
                list<ID> procIDLst = new List<ID>();
                procIDLst.add(psc1.Access_Sequence__c);
                PricProcToAscSeqIDLstMap.put(psc1.Pricing_Procedure__c,procIDLst);
            }           
          ObjIdSet.add(psc1.Access_Sequence__c);    
        }
            // removing unwanted IDs from the Set.
     ObjIdSet.removeall(oldsobjmap.keyset());   
            // Retriving all Access sequence as well as Prining procedure records for needs calculation 
     Map<Id,VCG_CPQ_Pricing_Access_Sequence__c> pricCondnMap = new Map<Id,VCG_CPQ_Pricing_Access_Sequence__c>([Select Id,Needs_Fields__c from VCG_CPQ_Pricing_Access_Sequence__c where ID IN: ObjIdSet]);
     Map<ID,VCG_CPQ_Pricing_Procedure__c> PPMap = new Map<id,VCG_CPQ_Pricing_Procedure__c>([Select id,Needs_Fields__c from VCG_CPQ_Pricing_Procedure__c where ID IN: PrntIdst]);  

            // Populating needs field value based on Access sequence
        for (VCG_CPQ_Pricing_Procedure__c i : PPMap.values()) {
            Set<String> NeedsSet = new Set<String>();
            for (ID id1 : PricProcToAscSeqIDLstMap.keyset()) {
                if (pricCondnMap.get(id1) != NULL) {
                List<string> needsLst = pricCondnMap.get(id1).Needs_Fields__c.split(';');
                NeedsSet.addall(needsLst);
                    }
                }
            String NewNeedsValue ='';
            for (String s: NeedsSet)
               NewNeedsValue += (NewNeedsValue == '' ?'':';') + s;
            
            i.Needs_Fields__c = NewNeedsValue;
            ProcdrLst.add(i);    
        } 
        update ProcdrLst;
      } 
   }
     
/**********************************************************************************************
* @author  Ataullah Khan       
* @date     09.APR.14      
* @description: Method to handle Reparenting on  VCG_CPQ_Pricing_Procedure_Sequence__c and 
                VCG_CPQ_Pricing_Sequence_Condition__c Object.
* @Revision(s):  
**********************************************************************************************/      
   public void reparenting (Map<ID,sObject> oldsobjMap , Map<ID,sObject> newsobjMap) {
    
        // Local variable store---------------------------------------------------------------------------------------------------
        List<VCG_CPQ_Pricing_Access_Sequence__c> SeqLst = new List<VCG_CPQ_Pricing_Access_Sequence__c>(); // Variable to store List of Access Sequence records.
        List<VCG_CPQ_Pricing_Procedure__c> ProcLst = new List<VCG_CPQ_Pricing_Procedure__c>(); // Variable to store List of Pricing Procedure records.
        String ObjectName;                                                                     // Variable to hold name of the object for which trigger handler is being called.
        Set<ID> ProcIdSet = new Set<ID>();                                                     // Variable to hold Set of Pricing Procedure IDs
        Set<ID> ConIdSet = new Set<ID>();                                                      // Variable to store set of Pricing Condition IDs
        Set<ID> AcsIdSet = new Set<ID>();                                                      // Variable to store set of Access Sequence IDs
        Map<Id,Set<Id>> AccsSeqToCondnIDLstMap = new Map<Id,Set<Id>>();                        // Variable to store Access Sequence to set of Pricing Condition Ids Map
        Map<Id,Set<Id>> ProcToAccsSeqIDLstMap = new Map<Id,Set<Id>>();                         // Variable to store Pricing Procedure IDs to Set of Access Sequence IDs Map
    
        // Identifying the type of Object
        if (OldsobjMap.values()[0].getsObjectType() == VCG_CPQ_Pricing_Procedure_Sequence__c.sObjectType) {
       ObjectName = 'VCG_CPQ_Pricing_Procedure_Sequence__c';
        }
        else if (OldsobjMap.Values()[0].getsObjectType() == VCG_CPQ_Pricing_Sequence_Condition__c.sObjectType) {
       ObjectName = 'VCG_CPQ_Pricing_Sequence_Condition__c';
        }
    
        // Collecting Ids of all the records involved in reparenting
    if (ObjectName == 'VCG_CPQ_Pricing_Sequence_Condition__c') {   
     for (Sobject s : NewsobjMap.values()) {
         if ((((String)s.get('Condition__c')) != ((String)OldsobjMap.get((ID)s.get('id')).get('Condition__c')))
               || (((String)s.get('Access_Sequence__c')) != ((String)OldsobjMap.get((ID)s.get('id')).get('Access_Sequence__c')))) {
            
            ConIdSet.add((ID)s.get('Condition__c'));
            AcsIdSet.add((ID)s.get('Access_Sequence__c'));
            ConIdSet.add((ID)OldsobjMap.get((ID)s.get('id')).get('Condition__c'));
            AcsIdSet.add((ID)OldsobjMap.get((ID)s.get('id')).get('Access_Sequence__c'));
            }
     }
            // Querying all the middle object record related to the Access sequence Ids or pricing Condition Ids
     List<VCG_CPQ_Pricing_Sequence_Condition__c> seqCondtn = [Select id,Access_Sequence__c,Condition__c from VCG_CPQ_Pricing_Sequence_Condition__c where Access_Sequence__c IN: AcsIdSet OR Condition__c IN: ConIdSet];
            
            // Populating the 'AccsSeqToCondnIDLstMap' Map with Access Sequence IDs to the Set of all relates pricing Condition record's IDs
            for (VCG_CPQ_Pricing_Sequence_Condition__c psc : seqCondtn) { 
            if (AccsSeqToCondnIDLstMap.containskey(psc.Access_Sequence__c)) {
                Set<ID> condIDLst = AccsSeqToCondnIDLstMap.get(psc.Access_Sequence__c);
                condIDLst.add(psc.Condition__c);
                AccsSeqToCondnIDLstMap.put(psc.Access_Sequence__c,condIDLst);
            }
           else{
                Set<ID> condIDLst = new Set<ID>();
                condIDLst.add(psc.Condition__c);
                AccsSeqToCondnIDLstMap.put(psc.Access_Sequence__c,condIDLst);
           }
             ConIdSet.add(psc.Condition__c);           
        }
          
      Map<Id,VCG_CPQ_Pricing_Condition__c> pricCondnMap = new Map<Id,VCG_CPQ_Pricing_Condition__c>([Select Id,Needs_Fields__c from VCG_CPQ_Pricing_Condition__c where ID IN: ConIdSet]);
      Map<ID,VCG_CPQ_Pricing_Access_Sequence__c> accseqMap = new Map<id,VCG_CPQ_Pricing_Access_Sequence__c>([Select id,Needs_Fields__c from VCG_CPQ_Pricing_Access_Sequence__c where ID IN: AcsIdSet]);   
      
      for (VCG_CPQ_Pricing_Access_Sequence__c pas:accseqMap.values()) {
         if (!AccsSeqToCondnIDLstMap.containsKey(pas.id)) {
            Set<ID> condIDLst = new Set<ID>();
            AccsSeqToCondnIDLstMap.put(pas.id,condIDLst);
         }          
      }
      
            // Calculating Needs fields value related to each Access Sequence record and populating it.
      for (VCG_CPQ_Pricing_Access_Sequence__c s : accseqMap.values()) {
         Set<String> needsSet = new Set<String>();
               // needs new values to be added
               //List<String> needs = pricCondnMap.get(s.id).get('Needs_Fields__c').split(';');
               //but first remove the old values
                for (Id i : AccsSeqToCondnIDLstMap.get(s.id)) {
                  if (i != NULL && pricCondnMap.get(i) != NULL && pricCondnMap.get(i).Needs_Fields__c != null ) {
                   List<String> needslst = pricCondnMap.get(i).Needs_Fields__c.split(';');
                   needsSet.addall(needsLst);
                    }
                }
                 /*List<string> needsLst = s.Needs_Fields__c.split(';');
                 NeedsSet.addall(needsLst);*/
                 String NewNeedsValue = '';
                 for (String str: NeedsSet)
                    NewNeedsValue += (NewNeedsValue == '' ?'':';') + str;
                 
                 s.Needs_Fields__c = NewNeedsValue;
                 SeqLst.add(s);    
        }
        update SeqLst;
    }   
    // second Part.........................................................................................................................................
    
    if (ObjectName == 'VCG_CPQ_Pricing_Procedure_Sequence__c') {   
            // Collecting Ids of all the records involved in reparenting 
     for (Sobject s : NewsobjMap.values()) {
         if (((String)s.get('Pricing_Procedure__c')) != ((String)OldsobjMap.get((ID)s.get('id')).get('Pricing_Procedure__c'))) {
            
            ProcIdSet.add((ID)s.get('Pricing_Procedure__c'));
            AcsIdSet.add((ID)s.get('Access_Sequence__c'));
            ProcIdSet.add((ID)OldsobjMap.get((ID)s.get('id')).get('Pricing_Procedure__c'));
            //AcsIdSet.add((ID)OldsobjMap.get((ID)s.get('id')).get('Access_Sequence__c'));
            }
     }
           // Querying all the middle object record related to the Access sequence Ids or pricing Condition Ids
      List<VCG_CPQ_Pricing_Procedure_Sequence__c> Procseq = [Select id,Access_Sequence__c,Pricing_Procedure__c from VCG_CPQ_Pricing_Procedure_Sequence__c where Pricing_Procedure__c IN: ProcIdSet];

           // Populating the 'AccsSeqToCondnIDLstMap' Map with Access Sequence IDs to the Set of all relates pricing Condition record's IDs
         for (VCG_CPQ_Pricing_Procedure_Sequence__c psc : Procseq) {
            
            if (ProcToAccsSeqIDLstMap.containskey(psc.Pricing_Procedure__c)) { 
                Set<ID> AccsIDLst = ProcToAccsSeqIDLstMap.get(psc.Pricing_Procedure__c); 
                AccsIDLst.add(psc.Access_Sequence__c);
                ProcToAccsSeqIDLstMap.put(psc.Pricing_Procedure__c,AccsIDLst); 
            }
           else{
                Set<ID> AccsIDLst = new Set<ID>();
                AccsIDLst.add(psc.Access_Sequence__c);
                ProcToAccsSeqIDLstMap.put(psc.Pricing_Procedure__c,AccsIDLst); 
           } 
           AcsIdSet.add(psc.Access_Sequence__c);           
        }
        
        Map<Id,VCG_CPQ_Pricing_Procedure__c> pricProcMap = new Map<Id,VCG_CPQ_Pricing_Procedure__c>([Select Id,Needs_Fields__c from VCG_CPQ_Pricing_Procedure__c where ID IN: ProcIdSet]);
        Map<ID,VCG_CPQ_Pricing_Access_Sequence__c> accseqMap = new Map<id,VCG_CPQ_Pricing_Access_Sequence__c>([Select id,Needs_Fields__c from VCG_CPQ_Pricing_Access_Sequence__c where ID IN: AcsIdSet]);   
        
        for (VCG_CPQ_Pricing_Procedure__c priceProcdr : pricProcMap.values())
            {
                 if (!ProcToAccsSeqIDLstMap.containsKey(priceProcdr.id)) {
                    Set<ID> AccsIDLst = new Set<ID>();
                    ProcToAccsSeqIDLstMap.put(priceProcdr.id,AccsIDLst);
                 }
            }
    
           // Calculating Needs fields value related to each Access Sequence record and populating it.
      for (VCG_CPQ_Pricing_Procedure__c s : pricProcMap.values()) {
         Set<String> needsSet = new Set<String>();
                for (Id i : ProcToAccsSeqIDLstMap.get(s.id)) { 
                  if (i != Null && accseqMap.get(i) != NULL && accseqMap.get(i).Needs_Fields__c != null ) {
                   List<String> needslst = accseqMap.get(i).Needs_Fields__c.split(';');
                   needsSet.addall(needsLst);
                    }
                }
                 String NewNeedsValue = '';
                 for (String str: NeedsSet)
                    NewNeedsValue += (NewNeedsValue == '' ?'':';') + str;
                 s.Needs_Fields__c = NewNeedsValue;
                 ProcLst.add(s);   
        }
        update ProcLst;
    }   
 } 
/**********************************************************************************************
* @author  Ataullah Khan       
* @date     09.APR.14      
* @description: Method to handle Detetion of middle Objects namely  VCG_CPQ_Pricing_Sequence_Condition__c and 
                VCG_CPQ_Pricing_Procedure_Sequence__c Object.
* @Revision(s):  
**********************************************************************************************/  
   public void beforeDeleteMiddleObject(Map<id,sobject> oldsobjMap) {
    
        Map<ID,Set<id>> AccsSeqToCondnIDLstMap = new Map<id,Set<ID>>();       // Variable to hold Map of Access Sequence ID to Set of related Pricing Condition IDs
        String ObjectName;                                                    // Variable to hold name of the object for which trigger handler is being called.
        Set<ID> parentIDst = new Set<ID>();                                   // Variable to store Set of parent IDs for which the trigger is being called.
        Set<ID> ChildIDst = new Set<ID>();                                    // Variable to hold set of child IDs for which the trigger is called.
        Set<ID> ObjIdSet =  new Set<ID>();                                    // Variable to hold set of all IDs for which the trigger is called.
        List<VCG_CPQ_Pricing_Access_Sequence__c> SeqLst = new List<VCG_CPQ_Pricing_Access_Sequence__c>();  // Variable to store List of Access Sequence records used for updation purpose 
        Map<ID,Set<id>> ProcedureToAccsSeqIDLstMap = new Map<ID,Set<id>>();   // Variable to hold Map of Pricing Procedure ID to Set of related Access Sequence IDs 
        List<VCG_CPQ_Pricing_Procedure__c> ProcedureLst = new List<VCG_CPQ_Pricing_Procedure__c>(); // Variable to store List of Pricing procedure records
    
        // Identifying the type of Object
        if (OldsobjMap.values()[0].getsObjectType() == VCG_CPQ_Pricing_Sequence_Condition__c.sObjectType) {
       ObjectName = 'VCG_CPQ_Pricing_Sequence_Condition__c';
        }   
        else if (OldsobjMap.Values()[0].getsObjectType() == VCG_CPQ_Pricing_Procedure_Sequence__c.sObjectType) {
       ObjectName = 'VCG_CPQ_Pricing_Procedure_Sequence__c';
        }
    
    if (ObjectName == 'VCG_CPQ_Pricing_Sequence_Condition__c') { 
        for (sobject s : oldsobjMap.values()) {
            parentIDst.add((ID)s.get('Access_Sequence__c'));
            ChildIDst.add((ID)s.get('Condition__c'));
        }
            // Finding all the sequence Condition records related to the parent Ids
    Map<id,VCG_CPQ_Pricing_Sequence_Condition__c> SequenceCondtnMap = new Map<id,VCG_CPQ_Pricing_Sequence_Condition__c>([Select id,Access_Sequence__c,Condition__c from VCG_CPQ_Pricing_Sequence_Condition__c where Access_Sequence__c IN: parentIDst]);
     
            // populating 'AccsSeqToCondnIDLstMap' with access sequence Ids and set of related pricing condition record Ids. 
    for (VCG_CPQ_Pricing_Sequence_Condition__c psc1 : SequenceCondtnMap.values()) {
            if (AccsSeqToCondnIDLstMap.containsKey(psc1.Access_Sequence__c)) {
                set<ID> condIDLst = AccsSeqToCondnIDLstMap.get(psc1.Access_Sequence__c);
                condIDLst.add(psc1.Condition__c);
                AccsSeqToCondnIDLstMap.put(psc1.Access_Sequence__c,condIDLst);
            }
            else{
                set<ID> condIDLst = new set<ID>();
                condIDLst.add(psc1.Condition__c);
                AccsSeqToCondnIDLstMap.put(psc1.Access_Sequence__c,condIDLst);
            }           
          ObjIdSet.add(psc1.Condition__c);  
        }
            // removing unwanted IDs of child record.    
      ObjIdSet.removeall(ChildIDst); 
      
     Map<Id,VCG_CPQ_Pricing_Condition__c> pricCondnMap = new Map<Id,VCG_CPQ_Pricing_Condition__c>([Select Id,Needs_Fields__c from VCG_CPQ_Pricing_Condition__c where ID IN: ObjIdSet]);
     
     Map<ID,VCG_CPQ_Pricing_Access_Sequence__c> accseqMap = new Map<id,VCG_CPQ_Pricing_Access_Sequence__c>([Select id,Needs_Fields__c from VCG_CPQ_Pricing_Access_Sequence__c where ID IN: ParentIdst ]);   
     
            // Calculating Needs fields value related to each Access Sequence record and populating it.
     for (VCG_CPQ_Pricing_Access_Sequence__c i : accseqMap.values()) {
            Set<String> NeedsSet = new Set<String>();
            for (ID id1 : AccsSeqToCondnIDLstMap.get(i.id)) {
                if (pricCondnMap.get(id1) != null && pricCondnMap.get(id1).Needs_Fields__c != null) {
                List<string> needsLst = pricCondnMap.get(id1).Needs_Fields__c.split(';');
                NeedsSet.addall(needsLst);
                    }
                }
            /*List<string> needsLst = i.Needs_Fields__c.split(';');
            NeedsSet.addall(needsLst);*/
            String NewNeedsValue ='';
            for (String s: NeedsSet)
               NewNeedsValue += (NewNeedsValue == '' ?'':';') + s;
               i.Needs_Fields__c =NewNeedsValue;
            SeqLst.add(i);    
        }
            
         update SeqLst;     
     }
     
     if (ObjectName == 'VCG_CPQ_Pricing_Procedure_Sequence__c') {
            // Collecting parent and child Ids
        for (sobject s: oldsobjMap.values()) {
            parentIDst.add((ID)s.get('Pricing_Procedure__c'));
            ChildIDst.add((ID)s.get('Access_Sequence__c'));
        }
            // Finding all the sequence Condition records related to the parent Ids
    Map<id,VCG_CPQ_Pricing_Procedure_Sequence__c> SequenceCondtnMap = new Map<id,VCG_CPQ_Pricing_Procedure_Sequence__c>([Select id,Access_Sequence__c,Pricing_Procedure__c from VCG_CPQ_Pricing_Procedure_Sequence__c where Pricing_Procedure__c IN: parentIDst]);
     
            // populating 'AccsSeqToCondnIDLstMap' with access sequence Ids and set of related pricing condition record Ids.
    for (VCG_CPQ_Pricing_Procedure_Sequence__c psc1 : SequenceCondtnMap.values()) {
            
            if (ProcedureToAccsSeqIDLstMap.containsKey(psc1.Pricing_Procedure__c)) {
                set<ID> condIDLst = ProcedureToAccsSeqIDLstMap.get(psc1.Pricing_Procedure__c);
                condIDLst.add(psc1.Access_Sequence__c);
                ProcedureToAccsSeqIDLstMap.put(psc1.Pricing_Procedure__c,condIDLst);
            }
            else{
                set<ID> condIDLst = new set<ID>();
                condIDLst.add(psc1.Access_Sequence__c);
                ProcedureToAccsSeqIDLstMap.put(psc1.Pricing_Procedure__c,condIDLst);
            }           
          ObjIdSet.add(psc1.Access_Sequence__c);    
        }
            // removing unwanted IDs of child record.
      ObjIdSet.removeall(ChildIDst); 
      
     
            Map<Id,VCG_CPQ_Pricing_Procedure__c> pricCondnMap = new Map<Id,VCG_CPQ_Pricing_Procedure__c>([Select Id,Needs_Fields__c from VCG_CPQ_Pricing_Procedure__c where ID IN: ParentIdst]);         
            Map<ID,VCG_CPQ_Pricing_Access_Sequence__c> accseqMap = new Map<id,VCG_CPQ_Pricing_Access_Sequence__c>([Select id,Needs_Fields__c from VCG_CPQ_Pricing_Access_Sequence__c where ID IN: ObjIdSet]);
               
            // Calculating Needs fields value related to each Access Sequence record and populating it.
            for (VCG_CPQ_Pricing_Procedure__c i : pricCondnMap.values()) {
                Set<String> NeedsSet = new Set<String>();
                for (ID id1 : ProcedureToAccsSeqIDLstMap.get(i.id))
                {
                    if (accseqMap.get(id1) != Null && accseqMap.get(id1).Needs_Fields__c != null)
                    {
                        List<string> needsLst = accseqMap.get(id1).Needs_Fields__c.split(';');
                        NeedsSet.addall(needsLst);
                    }
                }
                /*List<string> needsLst = i.Needs_Fields__c.split(';');
                NeedsSet.addall(needsLst);*/
                
                String NewNeedsValue ='';
                for (String s: NeedsSet)
                {
                    NewNeedsValue += (NewNeedsValue == '' ?'':';') + s;
                }
                
                i.Needs_Fields__c = NewNeedsValue;
                
                ProcedureLst.add(i);    
            }
            
            update ProcedureLst;     
        }
    }   
}