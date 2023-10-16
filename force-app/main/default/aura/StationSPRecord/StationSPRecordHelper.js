({
    configureTheme: function (cmp) {
        // SET THEME AND DESIGN ATTRIBUTE


        var parent = cmp.find("parent");

        var isSplitMode = cmp.get("v.splitMode");
        $A.util.removeClass(parent, 'container-full-width');
        if (isSplitMode === false) {
            $A.util.addClass(parent, 'container-full-width');
        }

        var newColor = cmp.get("v.backgroundColor");

        var feedbackButton = cmp.find("feedback-button");
        var arrowRight = cmp.find("arrow-right");
        var arrowDown = cmp.find("arrow-down");

        $A.util.removeClass(parent, 'backgroundColor-light1');
        $A.util.removeClass(parent, 'backgroundColor-light2');
        $A.util.removeClass(parent, 'backgroundColor-dark1');
        $A.util.removeClass(parent, 'backgroundColor-dark2');

        var newFeedbackStyle = 'buttonTheme-light1';
        var newArrowRightStyle = 'arrow-right--light';
        var newArrowDownStyle = 'arrow-down--light';
        switch (newColor) {
            case "Light 1":
                $A.util.addClass(parent, 'backgroundColor-light1');
                newFeedbackStyle = 'buttonTheme-light1';
                cmp.set("v.hrefColorStyle", 'color: #0070D2')
                break;
            case "Light 2":
                $A.util.addClass(parent, 'backgroundColor-light2');
                newFeedbackStyle = 'buttonTheme-light2';
                cmp.set("v.hrefColorStyle", 'color: #0070D2')
                break;
            case "Dark 1":
                $A.util.addClass(parent, 'backgroundColor-dark1');
                newFeedbackStyle = 'buttonTheme-dark1';
                newArrowRightStyle = 'arrow-right--dark';
                newArrowDownStyle = 'arrow-down--dark'
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF')
                break;
            case "Dark 2":
                $A.util.addClass(parent, 'backgroundColor-dark2');
                newFeedbackStyle = 'buttonTheme-dark2';
                newArrowRightStyle = 'arrow-right--dark';
                newArrowDownStyle = 'arrow-down--dark'
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF')
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

        if (Array.isArray(arrowRight)) {
            for (const x of arrowRight) {
                $A.util.removeClass(x, 'arrow-right--light');
                $A.util.removeClass(x, 'arrow-right--dark');
                $A.util.addClass(x, newArrowRightStyle);
            }
        } else {
            $A.util.removeClass(arrowRight, 'arrow-right--light');
            $A.util.removeClass(arrowRight, 'arrow-right--dark');
            $A.util.addClass(arrowRight, newArrowRightStyle);
        }

        if (Array.isArray(arrowDown)) {
            for (const x of arrowDown) {
                $A.util.removeClass(x, 'arrow-down--light');
                $A.util.removeClass(x, 'arrow-down--dark');
                $A.util.addClass(x, newArrowDownStyle);
            }
        } else {
            $A.util.removeClass(arrowDown, 'arrow-down--light');
            $A.util.removeClass(arrowDown, 'arrow-down--dark');
            $A.util.addClass(arrowDown, newArrowDownStyle);
        }
    },
    showFeedbackModal: function (component, componentId, className) {
        var modal = component.find(componentId);
        $A.util.removeClass(modal, className + 'hide');
        $A.util.addClass(modal, className + 'open');
    },

    hideFeedbackModal: function (component, componentId, className) {
        var modal = component.find(componentId);
        $A.util.addClass(modal, className + 'hide');
        $A.util.removeClass(modal, className + 'open');
        component.set("v.body", "");
    },

    showToast: function (component, type, title, message, mode) {

        var toastEvent = $A.get("e.force:showToast");

        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": mode,
            "duration": 8000

        });
        toastEvent.fire();
    }
})