({
    doInit: function(component, event, helper) {
        var recType = component.get('v.recType');
        if (recType == 'The Station SI Case') {
            helper.siCaseList(component);
        } 
        else if(recType == 'SI Case and Content Request')
        {
            helper.siAndRequestCaseList(component);
        }
        else {
            helper.CasesList(component);
        }
    },
    handleToggleChanged : function(component, event, helper) {
        var checked = component.get("v.checked");
        // console.log("checked is now = " + checked);
        var recType = component.get('v.recType');
        if (recType == 'The Station SI Case') {
            helper.siCaseList(component);
        } 
        else if(recType == 'SI Case and Content Request')
        {
            helper.siAndRequestCaseList(component);
        }
        else {
            helper.CasesList(component);
        }
    }
    
})