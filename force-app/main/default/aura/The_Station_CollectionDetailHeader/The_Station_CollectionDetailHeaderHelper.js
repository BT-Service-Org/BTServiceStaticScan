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

        var otherSize = cmp.get("v.otherFontSize");
        if (otherSize >= 10 && otherSize <= 24) {
            cmp.set("v.intOtherFontSize", 'font-size: ' + otherSize + 'px;');
        } else {
            cmp.set("v.intOtherFontSize", 'font-size: ' + 14 + 'px;');
        }

        var otherAlign = cmp.get("v.otherAlignment");
        cmp.set("v.intOtherAlignment", 'text-align: ' + otherAlign + ';');

        var newColor = cmp.get("v.backgroundColor");
        
        var parent = cmp.find("parent");
        
        $A.util.removeClass(parent, 'backgroundColor-light1');
        $A.util.removeClass(parent, 'backgroundColor-light2');
        $A.util.removeClass(parent, 'backgroundColor-dark1');
        $A.util.removeClass(parent, 'backgroundColor-dark2');

        switch(newColor) {
            case "Light 1":
                $A.util.addClass(parent, 'backgroundColor-light1');
                cmp.set("v.hrefColorStyle", 'color: #0070D2')
                break;
            case "Light 2":
                $A.util.addClass(parent, 'backgroundColor-light2');
                cmp.set("v.hrefColorStyle", 'color: #0070D2')
                break;
            case "Dark 1":
                $A.util.addClass(parent, 'backgroundColor-dark1');
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF')
                break;
            case "Dark 2":
                $A.util.addClass(parent, 'backgroundColor-dark2');
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF')
                break;
        }
    }
})