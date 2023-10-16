({
    doInit : function(component, event, helper) {
        let opendate = component.get("v.supportforce_Case.Date_Time_Opened__c");
        let lastcommentdate = component.get("v.v.supportforce_Case.Last_Case_Owner_Comment_Time__c");
        console.log('Concierge Item > opendate: '+opendate);
        if(opendate){
            component.set("v.opendate", new Date(opendate));
        }
        if(lastcommentdate){
            component.set("v.lastcommentdate", new Date(lastcommentdate));
        }
    },
})