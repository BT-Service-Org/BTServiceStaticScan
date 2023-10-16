({
    handleActive: function (cmp, event, helper) {
        helper.handleActive(cmp, event);
    },
    addTab: function(component, event) {
        $A.createComponent("lightning:tab", {
            "label": "New Tab",
            "id": "new",
            "onactive": component.getReference("c.addContent")
        }, function (newTab, status, error) {
            if (status === "SUCCESS") {
                var body = component.get("v.moretabs");
                component.set("v.moretabs", newTab);
            } else {
                throw new Error(error);
            }
        });
    },
    addContent : function(component, event) {
        var tab = event.getSource();
        switch (tab.get('v.id')){
            case 'new':
                // Display a badge in the tab content.
                // You can replace lightning:badge with a custom component.
                $A.createComponent("lightning:badge", {
                    "label": "NEW"
                }, function (newContent, status, error) {
                    if (status === "SUCCESS") {
                        tab.set('v.body', newContent);
                    } else {
                        throw new Error(error);
                    }
                });
                break;
        }
    },
    handleActive: function (cmp, event, helper) {
        helper.loadTabs(cmp, event);
    }





});