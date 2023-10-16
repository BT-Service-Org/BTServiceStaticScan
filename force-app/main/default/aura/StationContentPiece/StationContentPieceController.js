({
    doInit: function (cmp, event, helper) {
        var contentType = cmp.get('v.contentpiece.content.Content_Type__c');

        // Tag As New/Updated!
        var CreatedDate = new Date(cmp.get('v.contentpiece.content.CreatedDate'));
        var LastModifiedDate = new Date(cmp.get('v.contentpiece.content.LastModifiedDate'));
        var twoWeeksBeforeDate = new Date(Date.now() - 12096e5);
        if (CreatedDate > twoWeeksBeforeDate || LastModifiedDate > twoWeeksBeforeDate) {
            cmp.set("v.freshContent", true);
        }

        if (contentType == 'Content Version') {
            var fileType = cmp.get('v.contentpiece.contentPiece.FileType__c');
            //console.log('contentType: ' + contentType + ', fileType: ' + fileType);
            if (fileType == 'LINK' || fileType == 'QUIPDOC' || fileType == 'QUIPSHEET' || fileType == 'GOOGLE_DOCUMENT' || fileType == 'GOOGLE_SPREADSHEET' || fileType == 'GOOGLE_PRESENTATION') {
                cmp.set('v.downloadHidden', true);
            }
        } else if (contentType == 'URL') {
            var fileType = cmp.get('v.contentpiece.content.File_Type__c');
            console.log('contentType: ' + contentType + ', fileType: ' + fileType);
            cmp.set('v.downloadHidden', true); // default to hidden
            if (fileType == 'WORD' || fileType == 'EXCEL' || fileType == 'POWERPOINT' || fileType == 'MP4' || fileType == 'PDF') {
                cmp.set('v.downloadHidden', false);
            }
        }

        /*console.log('Test 2 An : ' + JSON.stringify(cmp.get('v.contentpiece')));*/
        var paramString = window.location.href;

        var PieceIdAction = cmp.get("c.getParamsValuesfromURl");
        PieceIdAction.setParams({
            Url: paramString,
            Param: "piece"
        });
        PieceIdAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnString = response.getReturnValue();

                if (returnString != null) {
                    cmp.set("v.contentIdtoOpen", returnString);
                }
            }
        });
        $A.enqueueAction(PieceIdAction);

        var uuid = helper.generateUUID();
        cmp.set('v.componentUUID', uuid);

        var newColor = cmp.get("v.backgroundTheme");
        var enabledButton = cmp.find("enabled-button");
        var disabledButton = cmp.find("disabled-button");

        var enabledSPButton = cmp.find("enabled-sp-button");
        var disabledSPButton = cmp.find("disabled-sp-button");

        var newEnabledStyle = '';
        var newDisabledStyle = '';
        var newEnabledSPStyle = '';
        var newDisabledSPStyle = '';
        var newShareStyle = '';
        switch (newColor) {
            case "Light 1":
                newEnabledStyle = 'buttonTheme-light1';
                newDisabledStyle = 'buttonTheme-light1-disabled';
                newEnabledSPStyle = 'square-button-light';
                newDisabledSPStyle = 'square-button-light-disabled';
                newShareStyle = 'buttonMenuTheme-light1';
                cmp.set("v.hrefColorStyle", 'color: #0070D2');
                cmp.set("v.languageColor", '#000000');
                cmp.set("v.buttonBorder", '0px;');
                cmp.set("v.buttonBackground", '#018EDA !important;');
                cmp.set("v.buttonHeight", '32px;');
                break;
            case "Light 2":
                newEnabledStyle = 'buttonTheme-light2';
                newDisabledStyle = 'buttonTheme-light2-disabled';
                newEnabledSPStyle = 'square-button-light';
                newDisabledSPStyle = 'square-button-light-disabled';
                newShareStyle = 'buttonMenuTheme-light2';
                cmp.set("v.hrefColorStyle", 'color: #0070D2');
                cmp.set("v.languageColor", '#000000');
                cmp.set("v.buttonBorder", '0px;');
                cmp.set("v.buttonBackground", '#018EDA !important;');
                cmp.set("v.buttonHeight", '32px;');
                break;
            case "Dark 1":
                newEnabledStyle = 'buttonTheme-dark1';
                newDisabledStyle = 'buttonTheme-dark1-disabled';
                newEnabledSPStyle = 'square-button-dark';
                newDisabledSPStyle = 'square-button-dark-disabled';
                newShareStyle = 'buttonMenuTheme-dark1';
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF');
                cmp.set("v.languageColor", '#FFFFFF');
                cmp.set("v.buttonBorder", '2px solid #FFFFFF;');
                cmp.set("v.buttonBackground", '#54698D !important;');
                cmp.set("v.buttonHeight", '34px;');
                break;
            case "Dark 2":
                newEnabledStyle = 'buttonTheme-dark2';
                newDisabledStyle = 'buttonTheme-dark2-disabled';
                newEnabledSPStyle = 'square-button-dark';
                newDisabledSPStyle = 'square-button-dark-disabled';
                newShareStyle = 'buttonMenuTheme-dark2';
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF');
                cmp.set("v.languageColor", '#FFFFFF');
                cmp.set("v.buttonBorder", '2px solid #FFFFFF;');
                cmp.set("v.buttonBackground", '#21466F !important;');
                cmp.set("v.buttonHeight", '34px;');
                break;
        }
        if (Array.isArray(enabledButton)) {
            for (const x of enabledButton) {
                $A.util.removeClass(x, 'buttonTheme-light1');
                $A.util.removeClass(x, 'buttonTheme-light2');
                $A.util.removeClass(x, 'buttonTheme-dark1');
                $A.util.removeClass(x, 'buttonTheme-dark2');
                $A.util.addClass(x, newEnabledStyle);
            }
        } else {
            $A.util.removeClass(enabledButton, 'buttonTheme-light1');
            $A.util.removeClass(enabledButton, 'buttonTheme-light2');
            $A.util.removeClass(enabledButton, 'buttonTheme-dark1');
            $A.util.removeClass(enabledButton, 'buttonTheme-dark2');
            $A.util.addClass(enabledButton, newEnabledStyle);
        }

        if (Array.isArray(disabledButton)) {
            for (const x of disabledButton) {
                $A.util.removeClass(x, 'buttonTheme-light1-disabled');
                $A.util.removeClass(x, 'buttonTheme-light2-disabled');
                $A.util.removeClass(x, 'buttonTheme-dark1-disabled');
                $A.util.removeClass(x, 'buttonTheme-dark2-disabled');
                $A.util.addClass(x, newDisabledStyle);
            }
        } else {
            $A.util.removeClass(disabledButton, 'buttonTheme-light1-disabled');
            $A.util.removeClass(disabledButton, 'buttonTheme-light2-disabled');
            $A.util.removeClass(disabledButton, 'buttonTheme-dark1-disabled');
            $A.util.removeClass(disabledButton, 'buttonTheme-dark2-disabled');
            $A.util.addClass(disabledButton, newDisabledStyle);
        }
        if (Array.isArray(enabledSPButton)) {
            for (const x of enabledSPButton) {
                $A.util.removeClass(x, 'square-button-light');
                $A.util.removeClass(x, 'square-button-dark');
                $A.util.addClass(x, newEnabledSPStyle);
            }
        } else {
            $A.util.removeClass(enabledSPButton, 'square-button-light');
            $A.util.removeClass(enabledSPButton, 'square-button-dark');
            $A.util.addClass(enabledSPButton, newEnabledSPStyle);
        }

        if (Array.isArray(disabledSPButton)) {
            for (const x of disabledSPButton) {
                $A.util.removeClass(x, 'square-button-light-disabled');
                $A.util.removeClass(x, 'square-button-dark-disabled');
                $A.util.addClass(x, newDisabledSPStyle);
            }
        } else {
            $A.util.removeClass(disabledSPButton, 'square-button-light-disabled');
            $A.util.removeClass(disabledSPButton, 'square-button-dark-disabled');
            $A.util.addClass(disabledSPButton, newDisabledSPStyle);
        }
        cmp.set("v.buttonTheme", newEnabledStyle);
        cmp.set("v.buttonThemeDisabled", newDisabledStyle);
        cmp.set("v.buttonMenuTheme", newShareStyle);
    },
    onRender: function (cmp, event) {
        var uuid = cmp.get('v.componentUUID');
        var asAccordion = cmp.get('v.asAccordion');
        var asAccordionIsOpen = cmp.get('v.asAccordionIsOpen');

        var newColor = cmp.get("v.backgroundTheme");

        if (asAccordion) {
            var sectionArrowRightLight = document.getElementById("section_arrow_right_light" + uuid);
            var sectionArrowDownLight = document.getElementById("section_arrow_down_light" + uuid);
            var sectionArrowRightDark = document.getElementById("section_arrow_right_dark" + uuid);
            var sectionArrowDownDark = document.getElementById("section_arrow_down_dark" + uuid);

            $A.util.removeClass(sectionArrowRightLight, 'slds-show');
            $A.util.removeClass(sectionArrowDownLight, 'slds-show');
            $A.util.removeClass(sectionArrowRightDark, 'slds-show');
            $A.util.removeClass(sectionArrowDownDark, 'slds-show');

            $A.util.removeClass(sectionArrowRightLight, 'slds-hide');
            $A.util.removeClass(sectionArrowDownLight, 'slds-hide');
            $A.util.removeClass(sectionArrowRightDark, 'slds-hide');
            $A.util.removeClass(sectionArrowDownDark, 'slds-hide');

            switch (newColor) {
                case "Light 1":
                    if (asAccordionIsOpen) {
                        $A.util.addClass(sectionArrowDownLight, 'slds-show');
                        $A.util.addClass(sectionArrowRightLight, 'slds-hide');
                        $A.util.addClass(sectionArrowRightDark, 'slds-hide');
                        $A.util.addClass(sectionArrowDownDark, 'slds-hide');
                    } else {
                        $A.util.addClass(sectionArrowRightLight, 'slds-show');
                        $A.util.addClass(sectionArrowDownLight, 'slds-hide');
                        $A.util.addClass(sectionArrowRightDark, 'slds-hide');
                        $A.util.addClass(sectionArrowDownDark, 'slds-hide');
                    }
                    break;
                case "Light 2":
                    if (asAccordionIsOpen) {
                        $A.util.addClass(sectionArrowDownLight, 'slds-show');
                        $A.util.addClass(sectionArrowRightLight, 'slds-hide');
                        $A.util.addClass(sectionArrowRightDark, 'slds-hide');
                        $A.util.addClass(sectionArrowDownDark, 'slds-hide');
                    } else {
                        $A.util.addClass(sectionArrowRightLight, 'slds-show');
                        $A.util.addClass(sectionArrowDownLight, 'slds-hide');
                        $A.util.addClass(sectionArrowRightDark, 'slds-hide');
                        $A.util.addClass(sectionArrowDownDark, 'slds-hide');
                    }
                    break;
                case "Dark 1":
                    if (asAccordionIsOpen) {
                        $A.util.addClass(sectionArrowDownDark, 'slds-show');
                        $A.util.addClass(sectionArrowRightLight, 'slds-hide');
                        $A.util.addClass(sectionArrowDownLight, 'slds-hide');
                        $A.util.addClass(sectionArrowRightDark, 'slds-hide');
                    } else {
                        $A.util.addClass(sectionArrowRightDark, 'slds-show');
                        $A.util.addClass(sectionArrowRightLight, 'slds-hide');
                        $A.util.addClass(sectionArrowDownLight, 'slds-hide');
                        $A.util.addClass(sectionArrowDownDark, 'slds-hide');
                    }
                    break;
                case "Dark 2":
                    if (asAccordionIsOpen) {
                        $A.util.addClass(sectionArrowDownDark, 'slds-show');
                        $A.util.addClass(sectionArrowRightLight, 'slds-hide');
                        $A.util.addClass(sectionArrowDownLight, 'slds-hide');
                        $A.util.addClass(sectionArrowRightDark, 'slds-hide');
                    } else {
                        $A.util.addClass(sectionArrowRightDark, 'slds-show');
                        $A.util.addClass(sectionArrowRightLight, 'slds-hide');
                        $A.util.addClass(sectionArrowDownLight, 'slds-hide');
                        $A.util.addClass(sectionArrowDownDark, 'slds-hide');
                    }
                    break;
            }
            var ComponentPieceId = cmp.get('v.contentIdtoOpen');
            var openToggle = cmp.get('v.openToggle');

            if (ComponentPieceId != null && openToggle) {
                var uuid = cmp.get('v.componentUUID');
                var scid = cmp.get('v.contentpiece.content.Id');
                if (scid == ComponentPieceId) {
                    cmp.set("v.asAccordionIsOpen", true);
                    var sectionElem = document.getElementById("station-sp-record-section" + uuid);
                    $A.util.toggleClass(sectionElem, 'slds-show');
                    $A.util.toggleClass(sectionElem, 'slds-hide');
                    cmp.set('v.openToggle', false);
                }
            }
        }
    },
    onSectionClick: function (cmp, event, helper) {
        var asAccordion = cmp.get('v.asAccordion');
        var asAccordionIsOpen = cmp.get('v.asAccordionIsOpen');
        asAccordionIsOpen = !asAccordionIsOpen
        cmp.set("v.asAccordionIsOpen", asAccordionIsOpen);

        if (asAccordion) {
            var uuid = cmp.get('v.componentUUID');
            var sectionElem = document.getElementById("station-sp-record-section" + uuid);
            $A.util.toggleClass(sectionElem, 'slds-show');
            $A.util.toggleClass(sectionElem, 'slds-hide');
        }
        if (asAccordionIsOpen) {
            var userId = $A.get("$SObjectType.CurrentUser.Id");
            var eventCategory = userId + " : Button";

            var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
            analyticsInteraction.setParams({
                hitType: 'event',
                eventCategory: eventCategory,
                eventAction: 'Quick View',
                eventLabel: event.target.name,
                eventValue: 1
            });
            analyticsInteraction.fire();
        }
    },
    handleOpenFiles: function (cmp, event, helper) {
        alert('Opening files: ' + event.getParam('recordIds').join(', ')
            + ', selected file is ' + event.getParam('selectedRecordId'));
    },/*
    onViewInternalDocumentDetailsClick: function(cmp, event) {
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
        cmp.set("v.selectedDocumentId" , '0680M000004KASUQA4');
        $A.get('e.lightning:openFiles').fire({
		    recordIds: ['069L0000000Sr9LIAS']
		});
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
        analyticsInteraction.fire();
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

    onFeedbackButton:function(cmp, event, helper) {
        cmp.set("v.feedbackReason", '');
        cmp.set("v.feedbackObjId", '');
        cmp.set("v.feedbackType", '');
        cmp.set("v.feedbackDescription", '');

        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : 'Button',
            eventAction : 'View',
            eventLabel : 'Feedback',
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
	onFeedbackButtonFlow:function(cmp, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";

        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : eventCategory,
            eventAction : 'Give Feedback',
            eventLabel : event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();

        var cpID = event.currentTarget.getAttribute('data-cpID');
        var cpName = event.currentTarget.getAttribute('data-cpName');
        var cpOwner = event.currentTarget.getAttribute('data-cpOwner');
        var cpOwnerID = event.currentTarget.getAttribute('data-cpOwnerID');
        var cpPrimary = event.currentTarget.getAttribute('data-cpPrimary');
        var cpPrimaryID = event.currentTarget.getAttribute('data-cpPrimaryID');
        var orgInstanceUrl = event.currentTarget.getAttribute('data-orgInstanceUrl');

		if($A.util.isEmpty(cpID)) {
            helper.showToast(cmp,'error','ERROR','No Success Program Record ID Defined', 'dismiss');
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
				function(content, status) {
					if (status === "SUCCESS") {
						modalBody = content;
						cmp.find('overlayLib').showCustomModal({
							header: "The Station - Submit Content Feedback",
							body: modalBody,
							showCloseButton: true,
							cssClass: "modalBackgroundColor",
							closeCallback: function() {
								// DO NOTHING JUST CLOSE THE WINDOW
								// alert('You closed the alert!');
							}
						})
					}
				});
        }
    },   */
    onSPDetails: function (cmp, event) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";

        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType: 'event',
            eventCategory: eventCategory,
            eventAction: 'View Details',
            eventLabel: event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    },
    onEnablementDocs: function (cmp, event) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";

        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType: 'event',
            eventCategory: eventCategory,
            eventAction: 'Enablement Docs',
            eventLabel: event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    },
    onKnowledgeArticle: function (cmp, event) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";

        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType: 'event',
            eventCategory: eventCategory,
            eventAction: 'Knowledge Article',
            eventLabel: event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    },
    closeContentPreviewModel: function (cmp, event) {
        cmp.set("v.showFileCardModal", false);
    }
})