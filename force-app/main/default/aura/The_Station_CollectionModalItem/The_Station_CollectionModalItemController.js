({
    doInit : function(cmp, event, helper) {
        var contentId= cmp.get("v.contentId");
        var recordAction = cmp.get("c.getContentRecord");
        recordAction.setParams({
            recordId : contentId
        });
        recordAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var contentrecord = response.getReturnValue();
                cmp.set('v.section',contentrecord);
            }
        });
        $A.enqueueAction(recordAction);
        
    },
    handleCloseModal: function(cmp, event, helper) {
        //Close the Modal Window
        cmp.find("overlayLib").notifyClose();
    },
    onDownloadClick: function(cmp, event, helper){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";
        
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : eventCategory,
            eventAction : 'Download',
            eventLabel : event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    },
    onContentDetailsClick: function(cmp, event, helper){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";
    
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : eventCategory,
            eventAction : 'Content Details',
            eventLabel : event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    },
    onSPDetails:function(cmp, event){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";
        
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : eventCategory,
            eventAction : 'View Details',
            eventLabel : event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    },
    onEnablementDocs:function(cmp, event){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";
        
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : eventCategory,
            eventAction : 'Enablement Docs',
            eventLabel : event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    },
    onKnowledgeArticle:function(cmp, event){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";
        
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : eventCategory,
            eventAction : 'Knowledge Article',
            eventLabel : event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    },
    onViewDocument: function(cmp, event, helper){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";
        
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : eventCategory,
            eventAction : 'View Document',
            eventLabel : event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
        
        // var contentID = event.currentTarget.dataset.key;
        // if (contentID) {
        //     var url = "https://org62.lightning.force.com/contenthub/openintarget?ref_id=" + contentID + "&amp;operationContext=S1"
        //     var urlEvent = cmp.getEvent("urlEvent");
        //     urlEvent.setParams({
        //         "url" : url
        //     });
        //     urlEvent.fire();
        // }
    }
})