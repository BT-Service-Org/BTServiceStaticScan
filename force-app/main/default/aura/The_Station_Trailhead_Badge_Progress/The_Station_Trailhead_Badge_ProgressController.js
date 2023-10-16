({
	doInit : function(component, event, helper) {
        // Init the list of tags
		const tags = component.get('v.tags');
        if(tags) {
            const tagsList = [];
            tags.split(',').forEach(tag => {
                tag.trim();
                tagsList.push(tag);
            });
            component.set('v.tagsList', tagsList);
        }                
        
        // Init the progress CSS class
        const progress = component.get('v.progress');
        component.set('v.progressCssClass', progress.toLowerCase());
	}
})