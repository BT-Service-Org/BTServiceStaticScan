({
        closeModal: function (component, event, helper) {
                console.log('@@test::');
                $A.get("e.force:closeQuickAction").fire();
        }
})