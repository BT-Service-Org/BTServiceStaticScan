({
    loadTabs: function (cmp, event) {
        var tab = event.getSource();
        switch (tab.get('v.id')) {
            case 'accounts' :
                //this.injectComponent('c:myAccountComponent', tab);
                break;
            case 'cases' :
                this.injectComponent('c:The_Station_RecTypeCaseList', tab);
                break;
        }
    },
    injectComponent: function (name, target) {
        $A.createComponent(name, {
        }, function (contentComponent, status, error) {
            if (status === "SUCCESS") {
                target.set('v.body', contentComponent);
            } else {
                throw new Error(error);
            }
        });
    }
});