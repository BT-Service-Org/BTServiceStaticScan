({
    configureTheme: function (cmp) {
        // SET THEME AND DESIGN ATTRIBUTE
        var titleSize = cmp.get("v.titleFontSize");
        if (titleSize >= 16 && titleSize <= 60) {
            cmp.set("v.intTitleFontSize", 'font-size: ' + titleSize + 'px;');
        } else {
            cmp.set("v.intTitleFontSize", 'font-size: ' + 42 + 'px;');
        }

        var titleAlign = cmp.get("v.titleAlignment");
        cmp.set("v.intTitleAlignment", 'text-align: ' + titleAlign + ';');

        var subTitleSize = cmp.get("v.subTitleFontSize");
        if (subTitleSize >= 16 && subTitleSize <= 40) {
            cmp.set("v.intSubTitleFontSize", 'font-size: ' + subTitleSize + 'px;');
        } else {
            cmp.set("v.intSubTitleFontSize", 'font-size: ' + 30 + 'px;');
        }

        var subTitleAlign = cmp.get("v.subTitleAlignment");
        cmp.set("v.intSubTitleAlignment", 'text-align: ' + subTitleAlign + ';');

        var newColor = cmp.get("v.backgroundColor");

        var parent = cmp.find("parent");
        var feedbackButton = cmp.find("feedback-button");

        $A.util.removeClass(parent, 'backgroundColor-light1');
        $A.util.removeClass(parent, 'backgroundColor-light2');
        $A.util.removeClass(parent, 'backgroundColor-dark1');
        $A.util.removeClass(parent, 'backgroundColor-dark2');

        var isFullWidth = cmp.get("v.isFullScreenWidth");
        $A.util.removeClass(parent, 'container-full-width');
        if (isFullWidth == true) {
            $A.util.addClass(parent, 'container-full-width');
        }

        var newFeedbackStyle = '';
        switch (newColor) {
            case "Light 1":
                $A.util.addClass(parent, 'backgroundColor-light1');
                newFeedbackStyle = 'buttonTheme-light1';
                cmp.set("v.hrefColorStyle", 'color: #222222');
                cmp.set("v.carouselNavigationColor", "#0070d2");
                cmp.set("v.buttonBorder", '0px;');
                cmp.set("v.buttonBackground", '#018EDA !important;');
                cmp.set("v.buttonHeight", '32px;');
                break;
            case "Light 2":
                $A.util.addClass(parent, 'backgroundColor-light2');
                newFeedbackStyle = 'buttonTheme-light2';
                cmp.set("v.hrefColorStyle", 'color: #222222');
                cmp.set("v.carouselNavigationColor", "#0070d2");
                cmp.set("v.buttonBorder", '0px;');
                cmp.set("v.buttonBackground", '#018EDA !important;');
                cmp.set("v.buttonHeight", '32px;');
                break;
            case "Dark 1":
                $A.util.addClass(parent, 'backgroundColor-dark1');
                newFeedbackStyle = 'buttonTheme-dark1';
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF');
                cmp.set("v.carouselNavigationColor", "#FFFFFF");
                cmp.set("v.buttonBorder", '2px solid #FFFFFF;');
                cmp.set("v.buttonBackground", '#54698D !important;');
                cmp.set("v.buttonHeight", '34px;');
                break;
            case "Dark 2":
                $A.util.addClass(parent, 'backgroundColor-dark2');
                newFeedbackStyle = 'buttonTheme-dark2';
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF');
                cmp.set("v.carouselNavigationColor", "#FFFFFF");
                cmp.set("v.buttonBorder", '2px solid #FFFFFF;');
                cmp.set("v.buttonBackground", '#21466F !important;');
                cmp.set("v.buttonHeight", '34px;');
                break;
        }
        if (Array.isArray(feedbackButton)) {
            for (const x of feedbackButton) {
                $A.util.removeClass(x, 'buttonTheme-light1');
                $A.util.removeClass(x, 'buttonTheme-light2');
                $A.util.removeClass(x, 'buttonTheme-dark1');
                $A.util.removeClass(x, 'buttonTheme-dark2');
                $A.util.addClass(x, newFeedbackStyle);
            }
        } else {
            $A.util.removeClass(feedbackButton, 'buttonTheme-light1');
            $A.util.removeClass(feedbackButton, 'buttonTheme-light2');
            $A.util.removeClass(feedbackButton, 'buttonTheme-dark1');
            $A.util.removeClass(feedbackButton, 'buttonTheme-dark2');
            $A.util.addClass(feedbackButton, newFeedbackStyle);
        }

        cmp.getElement().style.setProperty("--carouselNavigationColor", cmp.get("v.carouselNavigationColor"));

    },
    initSlick: function (cmp) {
        $(document).ready(function () {
            let carouselId = '#carousel-' + cmp.get('v.globalId');
            $(carouselId).slick({
                centerMode: true,
                slidesToShow: 1,
                variableWidth:true,
                dots: true,
                adaptiveHeight: true,
                infinite: false
            });
            cmp.set("v.isSlickInitialized", true);
        });
    },
    showSendEmailPopup: function (cmp) {
        const sendEmailPopup = cmp.find("sendEmailPopup");
        const backdrop = cmp.find("backdrop");
        $A.util.addClass(sendEmailPopup, "slds-fade-in-open");
        $A.util.addClass(backdrop, "slds-backdrop_open");
    },
    hideSendEmailPopup: function (cmp) {
        const sendEmailPopup = cmp.find("sendEmailPopup");
        const backdrop = cmp.find("backdrop");
        $A.util.removeClass(sendEmailPopup, "slds-fade-in-open");
        $A.util.removeClass(backdrop, "slds-backdrop_open");
    },
    resetEmailAttributes: function (cmp) {
        cmp.set("v.emailSubject", null);
        cmp.set("v.emailBody", null);
        cmp.set("v.emailRecipient", null);
    },
    showToast: function (type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    }
})