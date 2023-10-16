({
    doInit : function(cmp, event, helper) {
        var baseUrl="";
        var urlAction = cmp.get("c.getBaseUrl");
        urlAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                baseUrl = response.getReturnValue();
            }
        });
        $A.enqueueAction(urlAction); 


        var paramString = window.location.href;
        var originurlAction = cmp.get("c.getParamsValuesfromURl");
        originurlAction.setParams({
            Url : paramString,
            Param: "originurl"
        });
        originurlAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnString = response.getReturnValue();
                if (returnString!=null){
                var totalUrl = baseUrl+"/thestation/s/"+returnString;
                }
                else{
                var totalUrl = baseUrl+"/thestation/s/";
                }
                cmp.set("v.SourceUrl", totalUrl);
            }
        });
        $A.enqueueAction(originurlAction);
        var scgroupId = cmp.get("v.recordId");
        var getscgroupAction = cmp.get("c.getGroupName");
        getscgroupAction.setParams({
            groupId : scgroupId
        });
        getscgroupAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnScGroup = response.getReturnValue();
                cmp.set("v.ButtonName", returnScGroup.Cloud_Product__c);

            }
        });
        $A.enqueueAction(getscgroupAction);
    },
    navigateToUrlClick : function(cmp, event, helper) {
        var navUrl = cmp.get("v.SourceUrl");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": navUrl
        });
    urlEvent.fire();
    }
})