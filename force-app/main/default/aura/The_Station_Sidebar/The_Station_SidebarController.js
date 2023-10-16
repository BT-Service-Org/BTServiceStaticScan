({
    doInit: function (cmp, event, helper) {
        // FETCH CONTENT
        var contentId = cmp.get("v.contentGroupId");
        var nameAction = cmp.get("c.getGroupName");
        nameAction.setParams({
            groupId: contentId
        });
        nameAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var group = response.getReturnValue();
                cmp.set("v.title", group.Name);
                cmp.set("v.subtitle", group.Group_Subtitle__c);
                helper.configureTheme(cmp);
                var action = cmp.get("c.getGroups");
                action.setParams({
                    groupingList: contentId
                });
                action.setStorable();
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var records = response.getReturnValue();
                        cmp.set("v.groupList", records);
                        helper.configureTheme(cmp);
                        var contentAction = cmp.get("c.getContentPieces");
                        contentAction.setParams({
                            contentJSON: JSON.stringify(records)
                        });
                        contentAction.setStorable();
                        contentAction.setCallback(this, function (contentResponse) {
                            if (state === "SUCCESS") {
                                var contentRecords = contentResponse.getReturnValue();

                                // For each element, calculate if its a fresh content based on creation date and last modification date
                                // Forced to calculate it here in the contrller due to date parsing limitations in the view
                                var twoWeeksBeforeDate = new Date(Date.now() - 12096e5);
                                for (var key in contentRecords) {
                                    if (contentRecords.hasOwnProperty(key)) {

                                        var createdDate = new Date(contentRecords[key].content.CreatedDate);
                                        var LastModifiedDate = new Date(contentRecords[key].content.LastModifiedDate);
                                        var freshContent = ( createdDate > twoWeeksBeforeDate || LastModifiedDate > twoWeeksBeforeDate );

                                        contentRecords[key].content.freshContent = freshContent;
                                    }
                                }
                                
                                cmp.set("v.groupList", contentRecords);
                                helper.configureTheme(cmp);
                                cmp.set("v.isLoading",false);
                            }else{
                                cmp.set("v.isLoading",false);
                            }
                        });
                        $A.enqueueAction(contentAction);
                    }else{
                        cmp.set("v.isLoading",false);
                    }
                });

                $A.enqueueAction(action);
            }else{
                cmp.set("v.isLoading",false);
            }
        });
        $A.enqueueAction(nameAction);
    },
    onGiveFeedbackClick: function (cmp, event) {
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType: 'event',
            eventCategory: 'Button',
            eventAction: 'Give Feedback',
            eventLabel: event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    },
    onFeedbackButtonFlow: function (cmp, event, helper) {
        var cpID = event.currentTarget.getAttribute('data-cpID');
        var cpName = event.currentTarget.getAttribute('data-cpName');
        var cpOwner = event.currentTarget.getAttribute('data-cpOwner');
        var cpOwnerID = event.currentTarget.getAttribute('data-cpOwnerID');
        var cpPrimaryID = event.currentTarget.getAttribute('data-cpPrimaryID');
        var orgInstanceUrl = event.currentTarget.getAttribute('data-orgInstanceUrl');

        if ($A.util.isEmpty(cpID)) {
            helper.showToast(cmp, 'error', 'ERROR', 'No Record ID Defined', 'dismiss');
        } else {
            var modalBody;
            $A.createComponent("c:TheStation_SPRecordFeedbackFlow",
                {
                    cspRecordId: cpID,
                    cspRecordOwnerID: cpOwnerID,
                    cspRecordPrimaryID: cpPrimaryID,
                    cspRecordTitle: cpName,
                    orgInstanceUrl: orgInstanceUrl
                },
                function (content, status) {
                    if (status === "SUCCESS") {
                        modalBody = content;
                        cmp.find('overlayLib').showCustomModal({
                            header: "The Station - Submit Content Feedback",
                            body: modalBody,
                            showCloseButton: true,
                            cssClass: "modalBackgroundColor",
                            closeCallback: function () {
                                // DO NOTHING JUST CLOSE THE WINDOW                                
                                // alert('You closed the alert!');
                            }
                        })
                    }
                });
        }
    }
})