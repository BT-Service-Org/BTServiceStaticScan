({
    showMoreClickHandler : function(component, event, helper) {
        const showMoreUrl = component.get('v.showMoreURL');
        console.log('showMoreUrl: '+showMoreUrl);
        if(showMoreUrl) {
            window.open(showMoreUrl, '_blank');
        }
    }
})