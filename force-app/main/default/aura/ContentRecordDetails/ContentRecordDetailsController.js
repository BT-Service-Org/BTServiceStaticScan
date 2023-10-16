({
    getContent: function(cmp, event, helper) { // init function
        var scId = cmp.get("v.contentpiece.Id");
        var getscgroupAction = cmp.get("c.getSCGroupNames");
        getscgroupAction.setParams({
            ContentId : scId
        });
        getscgroupAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var scGroupList = response.getReturnValue();
                if (scGroupList != null){
                    var listlen= scGroupList.length;
                    for (var i=0; i<listlen;i++){
                        if (i<=2){
                        document.getElementById('Station-group-list'+scId).innerHTML += '<li>' + scGroupList[i].Name + '</li>';
                        }
                        else {
                            document.getElementById('Station-group-more'+scId).innerHTML += '<li>' + scGroupList[i].Name + '</li>';
                        }
                    }
                    if (listlen>3){
                        var remainingsize = listlen - 3;
                        cmp.set("v.moreBtnStr",remainingsize);
                        cmp.set("v.isButtonShown","true");
                    }
                }
            }
        });
        $A.enqueueAction(getscgroupAction);

        var reviewValue = cmp.get("v.contentpiece.Review_Status__c");
        if (reviewValue=="Past Due"){
            cmp.set("v.reviewTextcolor","1");
        }
        else if (reviewValue=="Approaching"){
            cmp.set("v.reviewTextcolor","2");
        }
        else if (reviewValue=="Due Today"){
            cmp.set("v.reviewTextcolor","3");
        }
        var url = window.location.href;
        cmp.set("v.navUrl",url);

        var Hidefromall = cmp.get("v.contentpiece.Exclude_from_Sharing_Rule__c");
        cmp.set("v.isDisablebutton",Hidefromall);
        
    },
    contentUpdateclick : function(cmp, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";

        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : eventCategory,
            eventAction : 'User: Update Content',
            eventLabel : event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();

        var UrlAction = cmp.get("c.getDomainOriginUrl");
        var ctarget = event.currentTarget;
        var scid = ctarget.dataset.scid;
        UrlAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var recordurl = response.getReturnValue();
                
                recordurl = recordurl+"/lightning/r/Station_Content__c/"+scid+"/view";
                window.open(recordurl);
            }
        });
        $A.enqueueAction(UrlAction);

    },
    onmorebtnClick : function(cmp, event, helper) {
        var listDisplay = cmp.get("v.isExtendedList");
        if (!listDisplay){
            cmp.set("v.isExtendedList", !listDisplay);
             cmp.find("moreBtn").getElement().innerHTML="Less";
        }
        else if (listDisplay){
            var moregroups = cmp.get("v.moreBtnStr");
            cmp.set("v.isExtendedList", !listDisplay);            
            cmp.find("moreBtn").getElement().innerHTML="More("+moregroups+")";
        }
    },
    contentGroupDelete : function(cmp, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";

        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : eventCategory,
            eventAction : 'User: Delete Content',
            eventLabel : event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();

        // var eventtype = event.currentTarget.getAttribute('data-flowtype');
        // var scid = event.currentTarget.getAttribute('data-scid');
        // var contentname = event.currentTarget.getAttribute('data-name');
        var ctarget = event.currentTarget;
        var scid = ctarget.dataset.scid;
        var eventtype = ctarget.dataset.flowtype;
        var contentname = ctarget.dataset.name;
        if($A.util.isEmpty(scid)) {        
            helper.showToast(cmp,'error','ERROR','No Record Found', 'dismiss');
        } else {
        var modalBody;
                    $A.createComponent("c:TheStation_UserContentEditFlow", 
                        {
                            contentId: scid,
                            contentName: contentname,
                            contentEvent: eventtype,
                            refreshValue:cmp.getReference('v.refreshValue')
                        }, 
                        function(content, status) {
                            if (status === "SUCCESS") {
                                modalBody = content;
                                cmp.find('overlayLib').showCustomModal({
                                    header: "Archive Content",
                                    body: modalBody, 
                                    showCloseButton: true,
                                    closeCallback: function() {
                                        if (refreshValue){
                                            refreshValue = !(refreshValue);
                                            window.location.reload();
                                        }
                                        
                                    }
                                })
                            }                               
                        });
                    }
                    cmp.set("v.isDisablebutton", "true");

    },
    reviewDateUpdate : function(cmp, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";

        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : eventCategory,
            eventAction : 'User: Update Review Date',
            eventLabel : event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();

        // var eventtype = event.currentTarget.getAttribute('data-flowtype');
        // var scid = event.currentTarget.getAttribute('data-scid');
        var ctarget = event.currentTarget;
        var scid = ctarget.dataset.scid;
        var eventtype = ctarget.dataset.flowtype;
        var contentname = ctarget.dataset.name;
        if($A.util.isEmpty(scid)) {        
            helper.showToast(cmp,'error','ERROR','No Record Found', 'dismiss');
        } else {
        var modalBody;
                    $A.createComponent("c:TheStation_UserContentEditFlow", 
                        {
                            contentId: scid,
                            contentName: contentname,
                            contentEvent: eventtype,
                            refreshValue:cmp.getReference('v.refreshValue')
                        }, 
                        function(content, status) {
                            if (status === "SUCCESS") {
                                modalBody = content;
                                cmp.find('overlayLib').showCustomModal({
                                    header: "Please set a Next Review Date",
                                    body: modalBody, 
                                    showCloseButton: true,
                                    closeCallback: function() {
                                        var refreshValue = cmp.get('v.refreshValue');
                                   
                                        if (refreshValue){
                                            refreshValue = !(refreshValue);
                                            window.location.reload();
                                            
                                        }
                                        
                                    }
                                })
                            }                               
                        });
                    }
    }    
})