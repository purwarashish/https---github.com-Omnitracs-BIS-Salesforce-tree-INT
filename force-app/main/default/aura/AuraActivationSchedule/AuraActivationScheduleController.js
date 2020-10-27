({
    navigateToeDiscoverySearchCmp : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        var pageReference = component.get("v.pageReference");
        component.set("v.pageReference", pageReference);
        //component.set("v.recordId", pageReference.state.recordId);
        var recordId = component.get("v.recordId");
        if(pageReference != null)
        {
        var passRecordId = component.get("v.pageReference").state.c__recordId;    
        }
        
        
        //console.log('Check ID ',component.get("v.recordId"));
        //console.log('Check ID 2',component.get("v.pageReference").state.c__recordId);
        if(recordId != null)
        {
            evt.setParams({
                componentDef : "c:activationSchedule",
                componentAttributes: {
                recordIds : component.get("v.recordId")
            }
            });
            evt.fire();
        }
        if(passRecordId != null)
        {
            evt.setParams({
                componentDef : "c:activationSchedule",
                componentAttributes: {
                recordIds : component.get("v.pageReference").state.c__recordId
            }
            });
            evt.fire();
        }
        
       //evt.fire();
    } 
})