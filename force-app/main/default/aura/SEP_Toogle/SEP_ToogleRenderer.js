({
    afterRender: function(cmp, helper){
        $A.enqueueAction(cmp.get("c.doInit"));
    }
})