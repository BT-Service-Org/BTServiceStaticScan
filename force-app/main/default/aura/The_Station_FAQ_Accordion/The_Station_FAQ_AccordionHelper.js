({
	configureTheme : function(cmp) {
        // SET THEME AND DESIGN ATTRIBUTE
        var titleSize = cmp.get("v.titleFontSize");
        if (titleSize >= 16 && titleSize <= 60) {
            cmp.set("v.intTitleFontSize", 'font-size: ' + titleSize + 'px;');
        } else {
            cmp.set("v.intTitleFontSize", 'font-size: ' + 42 + 'px;');
        }

        var titleAlign = cmp.get("v.titleAlignment");
        cmp.set("v.intTitleAlignment", 'text-align: ' + titleAlign + ';');

        var newColor = cmp.get("v.backgroundColor");
        
        var parent = cmp.find("parent");
        var feedbackButton = cmp.find("feedback-button");
        var shareButton = cmp.find("share-button");

        
        $A.util.removeClass(parent, 'backgroundColor-light1');
        $A.util.removeClass(parent, 'backgroundColor-light2');
        $A.util.removeClass(parent, 'backgroundColor-dark1');
        $A.util.removeClass(parent, 'backgroundColor-dark2');
        
        var newFeedbackStyle = '';
        var newShareStyle = '';
        switch(newColor) {
            case "Light 1":
                $A.util.addClass(parent, 'backgroundColor-light1');
                newFeedbackStyle = 'buttonTheme-light1';
                newShareStyle = 'buttonMenuTheme-light1';
                cmp.set("v.hrefColorStyle", 'color: #0070D2');
                cmp.set("v.accordionIconColor", '#6B6D70');
                cmp.set("v.accordionTitleColor", '#0070d2');
                cmp.set("v.buttonBorder", '0px;');
                cmp.set("v.buttonBackground", '#018EDA !important;');
                cmp.set("v.buttonHeight", '32px;');
                break;
            case "Light 2":
                $A.util.addClass(parent, 'backgroundColor-light2');
                newFeedbackStyle = 'buttonTheme-light2';
                newShareStyle = 'buttonMenuTheme-light2';
                cmp.set("v.hrefColorStyle", 'color: #0070D2');
                cmp.set("v.accordionIconColor", '#6B6D70');
                cmp.set("v.accordionTitleColor", '#0070d2');
                cmp.set("v.buttonBorder", '0px;');
                cmp.set("v.buttonBackground", '#018EDA !important;');
                cmp.set("v.buttonHeight", '32px;');
                break;
            case "Dark 1":
                $A.util.addClass(parent, 'backgroundColor-dark1');
                newFeedbackStyle = 'buttonTheme-dark1';
                newShareStyle = 'buttonMenuTheme-dark1';
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF');
                cmp.set("v.accordionIconColor", '#FFFFFF');
                cmp.set("v.accordionTitleColor", '#FFFFFF');
                cmp.set("v.buttonBorder", '2px solid #FFFFFF;');
                cmp.set("v.buttonBackground", '#54698D !important;');
                cmp.set("v.buttonHeight", '34px;');
                break;
            case "Dark 2":
                $A.util.addClass(parent, 'backgroundColor-dark2');
                newFeedbackStyle = 'buttonTheme-dark2';
                newShareStyle = 'buttonMenuTheme-dark2';
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF');
                cmp.set("v.accordionIconColor", '#FFFFFF');
                cmp.set("v.accordionTitleColor", '#FFFFFF');
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
        if (Array.isArray(shareButton)) {
            for (const x of shareButton) {
                $A.util.removeClass(x, 'buttonMenuTheme-light1');
                $A.util.removeClass(x, 'buttonMenuTheme-light2');
                $A.util.removeClass(x, 'buttonMenuTheme-dark1');
                $A.util.removeClass(x, 'buttonMenuTheme-dark2');
                $A.util.addClass(x, newShareStyle);
            }
        } else {
            $A.util.removeClass(shareButton, 'buttonMenuTheme-light1');
            $A.util.removeClass(shareButton, 'buttonMenuTheme-light2');
            $A.util.removeClass(shareButton, 'buttonMenuTheme-dark1');
            $A.util.removeClass(shareButton, 'buttonMenuTheme-dark2');
            $A.util.addClass(shareButton, newShareStyle);
        }
        // Added for the embedded Feedback Button
        cmp.set("v.buttonTheme", newFeedbackStyle);
        cmp.set("v.buttonMenuTheme",newShareStyle);
    },
    showShareToast: function (type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    }
})