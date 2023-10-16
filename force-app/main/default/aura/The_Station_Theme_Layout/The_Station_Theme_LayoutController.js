({
    doInit : function(component, event, helper) {
        helper.initHomePageUrl(component);
    },
    
    goToHomePage: function (component, event, helper) {
        window.location.href = component.get('v.communityHomeUrl');
    },

    handleShowSearchClick: function (component, event, helper) {
		helper.showSearch(component);
    },

    handleCloseSearchClick: function (component, event, helper) {
		helper.hideSearch(component);
    },
})