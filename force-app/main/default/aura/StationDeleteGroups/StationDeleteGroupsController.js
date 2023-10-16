({
    init : function(component, event, helper) {      
        component.set('v.mycolumns', [
            {label: 'Group Name', fieldName: 'Name', type: 'text'}, 
            {label: 'Cloud Product', fieldName: 'Cloud_Product__c', type: 'text'}
        ]);
        helper.fetchGroups(component, event);
    },
    
    handleSelect : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows'); 
        component.set("v.selectedGroups", selectedRows);
    }
})