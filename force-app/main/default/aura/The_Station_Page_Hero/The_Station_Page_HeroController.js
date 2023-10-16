({
	doInit : function(cmp, event, helper) {
        
        // FETCH CONTENT
        var contentId = cmp.get("v.contentGroupId");
        var actionName = cmp.get("c.getStationContentFields");
        actionName.setParams({
            stcontentId : contentId
        });
        var isEmptytest1 = true;
        var isEmptytest2 = true;
        var isEmptytest3 = true;
        var isEmptytest4 = true;
        actionName.setCallback(this, function(response){
            var statContent = response.getState();
            if (statContent === "SUCCESS") {
                var stationcontent = response.getReturnValue();
                if(stationcontent.Page_Owner_1_Name__c==null && stationcontent.Page_Owner_1_Job_Title__c==null && stationcontent.Page_Owner_1_Page_Title__c==null ){
                    isEmptytest1=true;
                }else {
                    isEmptytest1=false;
                    cmp.set("v.isEmptyOwner1", false);
                }

                if(stationcontent.Page_Owner_2_Name__c==null && stationcontent.Page_Owner_2_Job_Title__c==null && stationcontent.Page_Owner_2_Page_Title__c==null ){
                    isEmptytest2=true;
                }else {
                    isEmptytest2=false;
                    cmp.set("v.isEmptyOwner2", false);
                }

                if(stationcontent.Page_Owner_3_Name__c==null && stationcontent.Page_Owner_3_Job_Title__c==null && stationcontent.Page_Owner_3_Page_Title__c==null ){
                    isEmptytest3=true;
                }else {
                    isEmptytest3=false;
                    cmp.set("v.isEmptyOwner3", false);
                }
                if(stationcontent.Page_Owner_4_Name__c==null && stationcontent.Page_Owner_4_Job_Title__c==null && stationcontent.Page_Owner_4_Page_Title__c==null ){
                    isEmptytest4=true;
                }else {
                    isEmptytest4=false;
                    cmp.set("v.isEmptyOwner4", false);
                }
                
                cmp.set("v.description", stationcontent.Description__c);
                cmp.set("v.pageTitle", stationcontent.notif_Title__c);
                cmp.set("v.pageOwnerFName", stationcontent.Page_Owner_1_Name__c);
                cmp.set("v.pageOwnerFJobTitle", stationcontent.Page_Owner_1_Job_Title__c);
                cmp.set("v.pageOwnerFPageTitle", stationcontent.Page_Owner_1_Page_Title__c);
                cmp.set("v.pageOwner2Name", stationcontent.Page_Owner_2_Name__c);
                cmp.set("v.pageOwner2JobTitle", stationcontent.Page_Owner_2_Job_Title__c);
                cmp.set("v.pageOwner2PageTitle", stationcontent.Page_Owner_2_Page_Title__c);
                cmp.set("v.pageOwner3Name", stationcontent.Page_Owner_3_Name__c);
                cmp.set("v.pageOwner3JobTitle", stationcontent.Page_Owner_3_Job_Title__c);
                cmp.set("v.pageOwner3PageTitle", stationcontent.Page_Owner_3_Page_Title__c);
                cmp.set("v.pageOwner4Name", stationcontent.Page_Owner_4_Name__c);
                cmp.set("v.pageOwner4JobTitle", stationcontent.Page_Owner_4_Job_Title__c);
                cmp.set("v.pageOwner4PageTitle", stationcontent.Page_Owner_4_Page_Title__c);
                cmp.set("v.orgUser1", stationcontent.Org62_User__c);
                cmp.set("v.orgUser2", stationcontent.Org62_User2__c);
                cmp.set("v.orgUser3", stationcontent.Org62_User3__c);
                cmp.set("v.orgUser4", stationcontent.Org62_User4__c);
            }    
        });
     $A.enqueueAction(actionName);
    
    },
    
})