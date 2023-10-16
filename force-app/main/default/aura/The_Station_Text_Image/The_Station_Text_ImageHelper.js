({
    configureTheme: function (cmp) {
        // SET THEME AND DESIGN ATTRIBUTE
        var parent = cmp.find("parent");

        var isSplitMode = cmp.get("v.splitMode");
        $A.util.removeClass(parent, 'container-full-width');
        if (isSplitMode === false) {
            $A.util.addClass(parent, 'container-full-width');
        }

        var numColumns = cmp.get("v.numColumns");
        switch (numColumns) {
            case "Highlight":
                cmp.set("v.intNumColumns", 0);
                break;
            case "Small Highlight":
                cmp.set("v.intNumColumns", 1);
                break;
            case "2":
                cmp.set("v.intNumColumns", 2);
                cmp.set("v.columnClass", "slds-size_1-of-2");
                cmp.set("v.columnStyle", "padding-left:10%;padding-right:10%;"); // cheat - should use calc(8.33% + 4rem) instead
                break;
            case "3":
                cmp.set("v.intNumColumns", 3);
                cmp.set("v.columnClass", "slds-size_1-of-3");
                cmp.set("v.columnStyle", "");
                break;
            case "4":
                cmp.set("v.intNumColumns", 4);
                cmp.set("v.columnClass", "slds-size_1-of-4");
                cmp.set("v.columnStyle", "");
                break;
        }
        var titleSize = cmp.get("v.titleFontSize");
        if (titleSize >= 16 && titleSize <= 60) {
            cmp.set("v.intTitleFontSize", 'font-size: ' + titleSize + 'px;');
        } else {
            cmp.set("v.intTitleFontSize", 'font-size: ' + 42 + 'px;');
        }

        var titleAlign = cmp.get("v.titleAlignment");
        cmp.set("v.intTitleAlignment", 'text-align: ' + titleAlign + ';');

        var newColor = cmp.get("v.backgroundColor");

        var feedbackButton = cmp.find("feedback-button");
        var images = cmp.find("image-container");

        $A.util.removeClass(parent, 'backgroundColor-light1');
        $A.util.removeClass(parent, 'backgroundColor-light2');
        $A.util.removeClass(parent, 'backgroundColor-dark1');
        $A.util.removeClass(parent, 'backgroundColor-dark2');

        var newFeedbackStyle = '';
        var imageStyle = '';
        var newShareStyle = '';
        switch (newColor) {
            case "Light 1":
                $A.util.addClass(parent, 'backgroundColor-light1');
                newFeedbackStyle = 'buttonTheme-light1';
                newShareStyle = 'buttonMenuTheme-light1';
                imageStyle = 'item-image-light1';
                cmp.set("v.hrefColorStyle", 'color: #0070D2');
                cmp.set("v.buttonBorder", '0px;');
                cmp.set("v.buttonBackground", '#018EDA !important;');
                cmp.set("v.buttonHeight", '32px;');
                break;
            case "Light 2":
                $A.util.addClass(parent, 'backgroundColor-light2');
                newShareStyle = 'buttonMenuTheme-light2';
                newFeedbackStyle = 'buttonTheme-light2';
                cmp.set("v.hrefColorStyle", 'color: #0070D2');
                cmp.set("v.buttonBorder", '0px;');
                cmp.set("v.buttonBackground", '#018EDA !important;');
                cmp.set("v.buttonHeight", '32px;');
                break;
            case "Dark 1":
                $A.util.addClass(parent, 'backgroundColor-dark1');
                newFeedbackStyle = 'buttonTheme-dark1';
                newShareStyle = 'buttonMenuTheme-dark1';
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF');
                cmp.set("v.buttonBorder", '2px solid #FFFFFF;');
                cmp.set("v.buttonBackground", '#54698D !important;');
                cmp.set("v.buttonHeight", '34px;');
                break;
            case "Dark 2":
                $A.util.addClass(parent, 'backgroundColor-dark2');
                newFeedbackStyle = 'buttonTheme-dark2';
                newShareStyle = 'buttonMenuTheme-dark2';
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF');
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
        if (Array.isArray(images)) {
            for (const x of images) {
                $A.util.removeClass(x, 'item-image-light1');
                $A.util.addClass(x, imageStyle);
            }
        } else {
            $A.util.removeClass(images, 'item-image-light1');
            $A.util.addClass(images, imageStyle);
        }

        cmp.set("v.buttonTheme", newFeedbackStyle);
        cmp.set("v.buttonMenuTheme", newShareStyle);
        console.log('end of theme');
    }
})