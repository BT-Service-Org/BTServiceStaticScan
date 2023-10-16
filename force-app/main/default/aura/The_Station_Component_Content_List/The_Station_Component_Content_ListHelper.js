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
        
        $A.util.removeClass(parent, 'backgroundColor-light1');
        $A.util.removeClass(parent, 'backgroundColor-light2');
        $A.util.removeClass(parent, 'backgroundColor-dark1');
        $A.util.removeClass(parent, 'backgroundColor-dark2');

        var newFeedbackStyle = '';        

        switch(newColor) {
            case "Light 1":
                $A.util.addClass(parent, 'backgroundColor-light1');
                newFeedbackStyle = 'buttonTheme-light1';
                cmp.set("v.hrefColorStyle", 'color: #000000')
                cmp.set("v.intPrimaryItemsColor", 'color: #1690D6')
                cmp.set("v.intSecondyItemsIconColor", 'light-mode-icon')
                break;
            case "Light 2":
                $A.util.addClass(parent, 'backgroundColor-light2');
                newFeedbackStyle = 'buttonTheme-light2';
                cmp.set("v.hrefColorStyle", 'color: #000000')
                cmp.set("v.intPrimaryItemsColor", 'color: #1690D6')
                cmp.set("v.intSecondyItemsIconColor", 'light-mode-icon')
                break;
            case "Dark 1":
                $A.util.addClass(parent, 'backgroundColor-dark1');
                newFeedbackStyle = 'buttonTheme-dark1';
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF')
                cmp.set("v.intPrimaryItemsColor", 'color: #FFFFFF')
                cmp.set("v.intSecondyItemsIconColor", 'dark-mode-icon')
                break;
            case "Dark 2":
                $A.util.addClass(parent, 'backgroundColor-dark2');
                newFeedbackStyle = 'buttonTheme-dark2';
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF')
                cmp.set("v.intPrimaryItemsColor", 'color: #FFFFFF')
                cmp.set("v.intSecondyItemsIconColor", 'dark-mode-icon')
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


        // SET THE PRIMARY ITEMS STYLE
        const primaryItemsFontSize = cmp.get("v.primaryItemsFontSize");
        cmp.set("v.intPrimaryItemsFontSize", 'font-size: ' + primaryItemsFontSize + 'px;');
        const primaryItemsAlignment = cmp.get("v.primaryItemsAlignment");
        cmp.set("v.intPrimaryItemsAlignment", 'text-align : ' + primaryItemsAlignment + ';');

    }
})