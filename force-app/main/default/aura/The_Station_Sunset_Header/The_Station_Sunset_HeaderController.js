({
	doInit: function(cmp, event, helper) {
        var hostname = window.location.hostname;
        if (!hostname.includes("livepreview")) {
            var redirect = cmp.get("v.redirectURL");
            if (redirect.length) {
                window.location.replace(redirect);
            }
        }
    }
})