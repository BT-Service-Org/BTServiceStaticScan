({
    handleShowModal: function(component, event, helper) {
        if($A.util.isEmpty(component.get("v.sprdSimpleRecord.OwnerId")))
        {
            helper.showToast(component,'error','ERROR','No Case Owner Defined', 'dismiss');
        }
        else
        {
            var modalBody;
            $A.createComponent("c:TheStation_SubmitContentCase", 
                               {
                                   sprdRecordId: component.get("v.recordId"),
                                   newCaseNumber: component.getReference("v.newCaseNumber")
                               },
                               function(content, status) {
                                   if (status === "SUCCESS") {
                                       modalBody = content;
                                       component.find('overlayLib').showCustomModal({
                                           header: "The Station - Request Form",
                                           body: modalBody, 
                                           showCloseButton: true,
                                           cssClass: "modalBackgroundColor",
                                           closeCallback: function() {
                                               //alert('You closed the alert!');
                                           }
                                       })
                                   }                               
                               });
        }
    },
    
    handleNewCaseNumberChange: function(component, event, helper){
        var newCaseNumber = component.get("v.newCaseNumber");
        if(!$A.util.isEmpty(newCaseNumber))
        {
            helper.showToast(component,'success','SUCCESS','Case ' + newCaseNumber + ' created successfully!', 'dismiss');
            component.set("v.newCaseNumber", null);
        }
    }
    
})