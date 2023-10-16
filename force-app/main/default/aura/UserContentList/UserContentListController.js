({
    getContent: function(cmp, event, helper) { // init function
        var recordId= $A.get( "$SObjectType.CurrentUser.Id" );
        var action = cmp.get("c.getContentRecords");
       
                action.setParams({
                    OwnerRecordID : recordId
                });
                action.setStorable();
                action.setCallback(this, function(response){
                    var state = response.getState();
                  
                    if (state === "SUCCESS") {
                        var records = response.getReturnValue();
                        cmp.set("v.ContentList", records);
                    }
                });
                $A.enqueueAction(action);
            }
})