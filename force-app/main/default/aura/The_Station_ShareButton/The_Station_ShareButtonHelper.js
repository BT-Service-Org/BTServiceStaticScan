({
    showToast : function(component,type,title,message, mode){
        
        var toastEvent = $A.get("e.force:showToast");
        
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : type,
            "mode" : mode,
            "duration" : 8000
            
        });
        toastEvent.fire();        
    },
    showSendEmailPopup: function (cmp) {
        const sendEmailPopup = cmp.find("sendEmailPopup");
        const backdrop = cmp.find("backdrop");
        $A.util.addClass(sendEmailPopup, "slds-fade-in-open");
        $A.util.addClass(backdrop, "slds-backdrop_open");
    },
    hideSendEmailPopup: function (cmp) {
        const sendEmailPopup = cmp.find("sendEmailPopup");
        const backdrop = cmp.find("backdrop");
        $A.util.removeClass(sendEmailPopup, "slds-fade-in-open");
        $A.util.removeClass(backdrop, "slds-backdrop_open");
    },
    resetEmailAttributes: function (cmp) {
        cmp.set("v.emailSubject", null);
        cmp.set("v.emailBody", null);
        cmp.set("v.emailRecipient", null);
    },
    showShareToast: function (type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    }

})