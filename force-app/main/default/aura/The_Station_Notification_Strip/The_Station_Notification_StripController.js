({
	doInit : function(cmp, event, helper) {
        
        // FETCH CONTENT
        var contentId = cmp.get("v.contentGroupId");
        var nameAction = cmp.get("c.getNotificationStripRecord");
        nameAction.setParams({
            stationId : contentId
        });
        nameAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var group = response.getReturnValue();
                cmp.set("v.mainTitle", group.notif_Title__c);
                cmp.set("v.subTitle", group.notif_SubTitle__c);
                cmp.set("v.callAction1Title", group.notif_Call_to_Action_1_Title__c);
                cmp.set("v.callAction1URL", group.notif_Call_to_Action_1_URL__c);
                cmp.set("v.callAction1Image", group.notif_Call_to_Action_1_Image__c); 
                if(group.notif_Call_to_Action_2_Title__c != undefined && 
                    group.notif_Call_to_Action_2_URL__c != undefined && 
                    group.notif_Call_to_Action_2_Image__c != undefined ){
                        cmp.set("v.showAction2", true);
                    }
                cmp.set("v.callAction2Title", group.notif_Call_to_Action_2_Title__c);
                cmp.set("v.callAction2URL", group.notif_Call_to_Action_2_URL__c);
                cmp.set("v.callAction2Image", group.notif_Call_to_Action_2_Image__c);
                helper.configureTheme(cmp);    
            }
        });
        $A.enqueueAction(nameAction);
    }
})