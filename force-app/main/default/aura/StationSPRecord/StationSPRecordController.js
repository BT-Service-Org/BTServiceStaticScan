({
    onsectiontoggle: function (cmp, event) {
        var val = cmp.find("accordion").get('v.activeSectionName');
        var open = event.getParam("openSections");
        cmp.set("v.openSections", open);

        for (var i = 0; i < val.length; i++) {
            var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
            analyticsInteraction.setParams({
                hitType: 'event',
                eventCategory: 'Accordion',
                eventAction: 'open',
                eventLabel: val[i],
                eventValue: 1
            });
            analyticsInteraction.fire();
        }
    },
    onSectionClick: function (cmp, event, helper) {
        var sectionId = event.currentTarget.getAttribute('data-sectionid');
        var contentId = event.currentTarget.getAttribute('data-contentid');

        var sectionElem = document.getElementById("station-sp-record-section" + contentId + sectionId);
        $A.util.toggleClass(sectionElem, 'slds-show');
        $A.util.toggleClass(sectionElem, 'slds-hide');

        var sectionArrowRight = document.getElementById("section_arrow_right" + sectionId);
        $A.util.toggleClass(sectionArrowRight, 'slds-show');
        $A.util.toggleClass(sectionArrowRight, 'slds-hide');

        var sectionArrowDown = document.getElementById("section_arrow_down" + sectionId);
        $A.util.toggleClass(sectionArrowDown, 'slds-show');
        $A.util.toggleClass(sectionArrowDown, 'slds-hide');
    },
    getContent: function (cmp, event, helper) { // init function
        var prog1 = cmp.get("v.contentLink1");

        var userAction = cmp.get("c.getRunningUserInfo");
        userAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var user = response.getReturnValue();
                cmp.set('v.runningUser', user);
            }
        });
        $A.enqueueAction(userAction);
        var originAction = cmp.get("c.getLexOriginUrl");
        originAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var origin = response.getReturnValue();
                cmp.set("v.originUrl", origin);
                var nameAction = cmp.get("c.getGroupName");
                nameAction.setParams({
                    groupId: prog1
                });
                nameAction.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var group = response.getReturnValue();
                        cmp.set("v.title", group.Name);
                        helper.configureTheme(cmp);
                        var action = cmp.get("c.getGroups");
                        action.setParams({
                            groupingList: prog1
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
                                        cmp.set("v.groupList", contentRecords);
                                        helper.configureTheme(cmp);
                                        setTimeout($A.getCallback(function () {
                                            var open = cmp.get("v.openSections");
                                            cmp.set("v.activeSections", open);

                                        }));
                                        cmp.set("v.isLoading", false);
                                    } else {
                                        cmp.set("v.isLoading", false);
                                    }
                                });
                                $A.enqueueAction(contentAction);
                            } else {
                                cmp.set("v.isLoading", false);
                            }
                        });

                        $A.enqueueAction(action);
                    } else {
                        cmp.set("v.isLoading", false);
                    }
                });
                $A.enqueueAction(nameAction);
            } else {
                cmp.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(originAction);
    },
    handleUrlEvent: function (cmp, event) {
        var url = event.getParam("url");
        window.open(url);
    },
    onContentDetailsClick: function (cmp, event) {
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType: 'event',
            eventCategory: 'Button',
            eventAction: 'Content Details',
            eventLabel: event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
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
    onDownloadClick: function (cmp, event) {
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType: 'event',
            eventCategory: 'Button',
            eventAction: 'Download',
            eventLabel: event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    },
    onViewDocument: function (cmp, event) {
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType: 'event',
            eventCategory: 'Button',
            eventAction: 'View',
            eventLabel: event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    },
    onFeedbackButton: function (cmp, event, helper) {
        cmp.set("v.feedbackReason", '');
        cmp.set("v.feedbackObjId", '');
        cmp.set("v.feedbackType", '');
        cmp.set("v.feedbackDescription", '');

        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType: 'event',
            eventCategory: 'Button',
            eventAction: 'View',
            eventLabel: 'Feedback',
            eventValue: 1
        });
        analyticsInteraction.fire();

        let objid = event.target.getAttribute('objid');
        let type = event.target.getAttribute('type');

        cmp.set("v.feedbackObjId", objid);
        cmp.set("v.feedbackType", type);

        helper.showFeedbackModal(cmp, 'modaldialog', 'slds-fade-in-');
        helper.showFeedbackModal(cmp, 'backdrop', 'slds-backdrop--');
    },
    onFeedbackButtonFlow: function (cmp, event, helper) {
        var cpID = event.currentTarget.getAttribute('data-cpID');
        var cpName = event.currentTarget.getAttribute('data-cpName');
        var cpOwner = event.currentTarget.getAttribute('data-cpOwner');

        var msg = 'UNDER CONSTRUCTION\n\n' + cpID + ' : ' + cpName + '\n\nOwner : ' + cpOwner;

        var inputVariables = [
            {
                name: "currRecordId", type: "String", value: cpID
            },
            {
                name: "currRecordName", type: "String", value: cpName
            },
            {
                name: "currRecordOwner", type: "String", value: cpOwner
            }
        ];
        var modalBody;
        $A.createComponent("c:TheStation_SubmitFeedbackFlow",
            function (content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    component.find('overlayLib').showCustomModal({
                        header: "The Station - Submit Success Program Content Feedback",
                        body: modalBody,
                        showCloseButton: true,
                        cssClass: "modalBackgroundColor",
                        closeCallback: function () {
                            alert('You closed the alert!');
                        }
                    })
                }
            });
    },
    onSPDetails: function (cmp, event) {
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType: 'event',
            eventCategory: 'Button',
            eventAction: 'View Details',
            eventLabel: event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    },
    onEnablementDocs: function (cmp, event) {
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType: 'event',
            eventCategory: 'Button',
            eventAction: 'Enablement Docs',
            eventLabel: event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    },
    onKnowledgeArticle: function (cmp, event) {
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType: 'event',
            eventCategory: 'Button',
            eventAction: 'Knowledge Article',
            eventLabel: event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    },
    onContentLocation: function (cmp, event) {
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType: 'event',
            eventCategory: 'Button',
            eventAction: 'Content Location',
            eventLabel: event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    },
    hideFeedbackModal: function (cmp, event, helper) {
        helper.hideFeedbackModal(cmp, 'modaldialog', 'slds-fade-in-');
        helper.hideFeedbackModal(cmp, 'backdrop', 'slds-backdrop--');
    },
    submitFeedbackModal: function (cmp, event, helper) {
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType: 'event',
            eventCategory: 'Button',
            eventAction: 'Submit',
            eventLabel: 'Feedback',
            eventValue: 1
        });
        analyticsInteraction.fire();
        var type = cmp.get("v.feedbackType");
        var objId = cmp.get("v.feedbackObjId");
        var reason = cmp.get("v.feedbackReason");
        var text = cmp.get("v.feedbackDescription");
        var title = type + ' - ' + reason + ' - ' + objId

        var save = cmp.get("c.submitFeedbackCase");
        save.setParams({
            "reason": title,
            "descr": text
        });
        save.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var c = response.getReturnValue();
                helper.hideFeedbackModal(cmp, 'modaldialog', 'slds-fade-in-');
                helper.hideFeedbackModal(cmp, 'backdrop', 'slds-backdrop--');
            }
        });
        $A.enqueueAction(save);
    },
    handleFeedbackReasonChange: function (cmp, event) {
        var selectedOption = event.getParam("value");
        cmp.set("v.feedbackReason", selectedOption);
    }
})