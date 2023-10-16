({
    init : function(component, event, helper) {
        /**Clearing the session storage that we use to store the previous screen values */
        var created = sessionStorage.getItem('created')
        if( created !== undefined || created !== null) sessionStorage.removeItem('created');

        /**Clearing the session storage that we use to store the deliverables- FLOW: Create_Method */
        var deliverables = sessionStorage.getItem('deliverables')
        if( deliverables !== undefined || deliverables !== null) sessionStorage.removeItem('deliverables');

        /**Clearing the session storage that we use to store the artifacts- FLOW: Create_Method */
        var artifacts = sessionStorage.getItem('artifacts')
        if( artifacts !== undefined || artifacts !== null) sessionStorage.removeItem('artifacts');
        
        /**Clearing the session storage that we use to store the remaining deliverables after deletion from UI- FLOW: Create_Method */
        var remainingDeliverables = sessionStorage.getItem('remainingDeliverables')
        if( remainingDeliverables !== undefined || remainingDeliverables !== null) sessionStorage.removeItem('remainingDeliverables');

        var remainingTemplates = sessionStorage.getItem('remainingTemplates');
        if(remainingTemplates !== undefined || remainingTemplates !== null) sessionStorage.removeItem('remainingTemplates');

        var remainingFiles = sessionStorage.getItem('remainingFiles');
        if(remainingFiles !== undefined || remainingFiles !== null) sessionStorage.removeItem('remainingFiles');
        
        /**If there is any error during method creation, else navigating to the record detail page! */
        if ( component.get("v.recId") === undefined ) {
            component.set("v.loader", false);
            component.set("v.hasError", true);
            component.set("v.errorMessage", "Something went wrong, Please try again later!");
        }else {
            var origin = window.location.origin;
            var url = origin + '/' + component.get("v.recId");
        	window.open(url, '_top');
        }
    }
})