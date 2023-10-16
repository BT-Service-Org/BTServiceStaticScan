({
    initHomePageUrl: function(component) {
        const urlString = window.location.href;
        const baseUrl = urlString.substring(0, urlString.indexOf("/s/"));
        component.set("v.communityHomeUrl", baseUrl + '/s');
    },
    showSearch : function(component) {
        const themeHeader = document.querySelector('.themeHeader');
        const navigationMenu = document.querySelector('.themeNav');
        const themeProfileMenu = document.querySelector('.themeProfileMenu');
        const searchTrigger = document.querySelector('.search-trigger');
        const searchRegion = document.querySelector('.search-region');
        
        if (themeHeader) {
            themeHeader.classList.add('search-expanded');
        }
        if (navigationMenu) {
            navigationMenu.classList.add('comm-hide');
        }
        if (themeProfileMenu) {
            themeProfileMenu.classList.add('comm-hide');
        }
        if (searchTrigger) {
            searchTrigger.classList.add('comm-hide');
        }
        if (searchRegion) {
            searchRegion.classList.remove('comm-hide');
        }
    },
    hideSearch : function(component) {
        const themeHeader = document.querySelector('.themeHeader');
        const navigationMenu = document.querySelector('.themeNav');
        const themeProfileMenu = document.querySelector('.themeProfileMenu');
        const searchTrigger = document.querySelector('.search-trigger');
        const searchRegion = document.querySelector('.search-region');
        
        if (themeHeader) {
            themeHeader.classList.remove('search-expanded');
        }
        if (navigationMenu) {
            navigationMenu.classList.remove('comm-hide');
        }
        if (themeProfileMenu) {
            themeProfileMenu.classList.remove('comm-hide');
        }
        if (searchTrigger) {
            searchTrigger.classList.remove('comm-hide');
        }
        if (searchRegion) {
            searchRegion.classList.add('comm-hide');
        }
    }
})