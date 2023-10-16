({
    showToast: function (component, type, title, message, mode) {

        var toastEvent = $A.get("e.force:showToast");

        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": mode,
            "duration": 8000

        });
        toastEvent.fire();
    },
    fireUrlEvent: function (cmp, url) {
        var event = cmp.getEvent("urlEvent");
        event.setParams({
            "url": url
        });
        event.fire();
    },
    generateUUID: function () {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    },
    generateUserString: function (cmp) {
        var runningUser = cmp.get('v.runningUser');
        return "Name:" + runningUser.Name + ",Email:" + runningUser.Email + ",Title:" + runningUser.Title + ",Department:" + runningUser.Department + ",Business_Unit__c:" + runningUser.Business_Unit__c + ",BU__c:" + runningUser.BU__c + ",JobCode__c:" + runningUser.JobCode__c + ",JobFamily__c:" + runningUser.JobFamily__c + ",JobProfile__c:" + runningUser.JobProfile__c + ",Community__c:" + runningUser.Community__c + ",CSG_Role__c:" + runningUser.CSG_Role__c + ",Geo__c:" + runningUser.Geo__c + ",LanguageLocaleKey:" + runningUser.LanguageLocaleKey;
    }
})