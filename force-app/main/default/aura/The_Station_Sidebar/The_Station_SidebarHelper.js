({
    configureTheme: function (cmp) {
        // SET THEME AND DESIGN ATTRIBUTE
        var titleAlign = cmp.get("v.titleAlignment");
        cmp.set("v.intTitleAlignment", 'text-align: ' + titleAlign + ';');

        var newColor = cmp.get("v.backgroundColor");

        var parent = cmp.find("parent");

        $A.util.removeClass(parent, 'backgroundColor-light1');
        $A.util.removeClass(parent, 'backgroundColor-light2');
        $A.util.removeClass(parent, 'backgroundColor-dark1');
        $A.util.removeClass(parent, 'backgroundColor-dark2');

        switch (newColor) {
            case "Light 1":
                $A.util.addClass(parent, 'backgroundColor-light1');
                cmp.set("v.mainTitleColorStyle", 'color: #032E61');
                cmp.set("v.hrefColorStyle", 'color: #0070D2');
                cmp.set("v.textColorStyle", 'color: #222222');
                cmp.set("v.dateColorStyle", 'color: #706E6B');
                break;
            case "Light 2":
                $A.util.addClass(parent, 'backgroundColor-light2');
                cmp.set("v.mainTitleColorStyle", 'color: #032E61');
                cmp.set("v.hrefColorStyle", 'color: #0070D2');
                cmp.set("v.textColorStyle", 'color: #222222');
                cmp.set("v.dateColorStyle", 'color: #706E6B');
                break;
            case "Dark 1":
                $A.util.addClass(parent, 'backgroundColor-dark1');
                cmp.set("v.mainTitleColorStyle", 'color: #FFFFFF');
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF');
                cmp.set("v.textColorStyle", 'color: #FFFFFF');
                cmp.set("v.dateColorStyle", 'color: #FFFFFF');
                break;
            case "Dark 2":
                $A.util.addClass(parent, 'backgroundColor-dark2');
                cmp.set("v.mainTitleColorStyle", 'color: #FFFFFF');
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF');
                cmp.set("v.textColorStyle", 'color: #FFFFFF');
                cmp.set("v.dateColorStyle", 'color: #FFFFFF');
                break;
        }

        var itemsLayout = cmp.get("v.itemsLayout");
        var showItemsImage = true;
        var showItemsDate = true;
        var showItemsAuthor = true;
        var itemsImgClass = 'slds-size_12-of-12';
        var itemsContentClass = 'slds-size_12-of-12';
        var itemsContainerClass = 'slds-wrap';
        switch (itemsLayout) {
            case 'Left image':
                itemsImgClass = 'img-left';
                itemsContentClass = 'content-img-left';
                showItemsDate = false;
                showItemsAuthor = false;
                itemsContainerClass = ''
                break;
            case 'Image hidden':
                showItemsImage = false;
                itemsContainerClass = 'slds-wrap item-img-hidden'
                break;
            case 'Full image':
                itemsContainerClass = 'slds-wrap item-full-img'
                break;
            default:
                break;
        }

        cmp.set("v.showItemsImage", showItemsImage);
        cmp.set("v.showItemsDate", showItemsDate);
        cmp.set("v.showItemsAuthor", showItemsAuthor);
        cmp.set("v.itemsImgClass", itemsImgClass);
        cmp.set("v.itemsContentClass", itemsContentClass);
        cmp.set("v.itemsContainerClass", itemsContainerClass);
    }
})