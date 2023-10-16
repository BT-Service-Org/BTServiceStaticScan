({
    myAction : function(component, event, helper) {

    },
    handleDeleteContent: function(cmp, event) {
        var modalBody;
        var groupRecordId = cmp.get("v.recordId");
        var scId = cmp.get("v.section.content.Id");
        var isDeletedold = cmp.get("v.isDeleted");
        $A.createComponent("c:The_Station_CollectionRemoveContent", 
        { collectionId: groupRecordId,
        contentId:scId,
        isDeleted: cmp.getReference('v.isDeleted') }, 
        function(content, status, errorMessage) {
            if (status === "SUCCESS") {
                modalBody = content;
                cmp.find('overlayLib').showCustomModal({
                    header: "The Station - Remove Content From Collection",
                    body: modalBody, 
                    showCloseButton: true,
                    cssClass: "modalBackgroundColor",
                    closeCallback: function() {
                        var isDeletednew = cmp.get("v.isDeleted");
                        if (isDeletedold != isDeletednew){
                            var content = cmp.get("v.section");
                            var contentId = content.content.Id;
                            var delEvent = $A.get("e.c:The_Station_CollectionDeleteEvent");
                            delEvent.setParams({
                            "deletecontentId" : contentId });
                            delEvent.fire();
                        }                           
                    }
                })
            } 
            else if (status==="ERROR"){
                console.log("Error: " + errorMessage);
            }                              
        });
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
    },
    handleTitleClick : function(cmp, event) {
        var scId= cmp.get("v.section.content.Id");
        var ownerId= cmp.get("v.section.content.OwnerId");
        var runningUser = cmp.get("v.runningUser");
        var originUrl = cmp.get("v.originUrl");
        var recordId = cmp.get("v.recordId");
        var collectionNumber;
        var contentOwner;
        var recordAction = cmp.get("c.getCollectionNumber");
            recordAction.setParams({
                recordId : scId
            });
            recordAction.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    collectionNumber = response.getReturnValue();
                    //cmp.set('v.collectionNumber',collectionNumber);
    
                    var userAction = cmp.get("c.getUserName");
                    userAction.setParams({
                        userId : ownerId
                    });
                    userAction.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            contentOwner = response.getReturnValue();
                            //cmp.set('v.contentOwner',contentOwner);
    
                            var modalBody;
                            //collectionNumber = cmp.get("v.collectionNumber");
                            //contentOwner = cmp.get ("v.contentOwner");
                            $A.createComponent("c:The_Station_CollectionModalItem", 
                            { 
                                recordId: recordId,
                                contentId : scId,
                                contentOwner : contentOwner,
                                collectionNumber : collectionNumber,
                                runningUser : runningUser,
                                originUrl : originUrl
                            }, 
                            function(content, status, errorMessage) {
                                if (status === "SUCCESS") {
                                    modalBody = content;
                                    cmp.find('overlayLib').showCustomModal({
                                        body: modalBody, 
                                        showCloseButton: true,
                                        cssClass: "slds-modal_large",
                                        closeCallback: function() {                           
                                        }
                                })
                            } 
                            else if (status==="ERROR"){
                                console.log("Error: " + errorMessage);
                            }                              
                        });    
    
    
                        }
                    });
                    $A.enqueueAction(userAction);
    
    
                }
            });
            $A.enqueueAction(recordAction);  
            
    
    }
})