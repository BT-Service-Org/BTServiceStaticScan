({
	getContent: function(cmp){
        
        var action = cmp.get("c.getContentVersionList");
        
        action.setParams({
            pContentVersionIdList : cmp.get("v.ContentIdList")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
                cmp.set("v.ContentVersionList", response.getReturnValue());
            }
        });
        
     	$A.enqueueAction(action);
    },
    onsectiontoggle: function (cmp ,event){
        var val = cmp.find("accordion").get('v.activeSectionName') ;
        
        for (var i = 0; i < val.length; i++) {
            
        	var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
            analyticsInteraction.setParams({
                hitType : 'event',
                eventCategory : 'Accordion',
                eventAction : 'open',
                eventLabel : val[i],
                eventValue: 1
            });
            analyticsInteraction.fire();
            console.log(val[i]);
        }
    },
    onContentDetailsClick: function(cmp, event){
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : 'Button',
            eventAction : 'Content Details',
            eventLabel : event.target.name,
            eventValue: 1
        });
        
        console.log( event.target.name );
        analyticsInteraction.fire();
    },
    onGiveFeedbackClick: function(cmp, event){
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : 'Button',
            eventAction : 'Give Feedback',
            eventLabel : event.target.name,
            eventValue: 1
        });
        
        console.log( event.target.name );
        analyticsInteraction.fire();
    },
    onDownloadClick: function(cmp, event){
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : 'Button',
            eventAction : 'Download',
            eventLabel : event.target.name,
            eventValue: 1
        });
        
        console.log( event.target.name );
        analyticsInteraction.fire();
    },
    onViewDocument: function(cmp, event){
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : 'Button',
            eventAction : 'View',
            eventLabel : event.target.name,
            eventValue: 1
        });
        
        console.log( event.target.name );
        analyticsInteraction.fire();
    }
})