({
    handleShowModal: function(component, event, helper) {
        var modalBody;
            $A.createComponent("c:TheStation_SubmitFeedbackFlow", 
                               {
                                   
                               },
                               function(content, status) {
                                   if (status === "SUCCESS") {
                                       modalBody = content;
                                       component.find('overlayLib').showCustomModal({
                                           header: "The Station - Submit Feedback",
                                           body: modalBody, 
                                           showCloseButton: true,
                                           cssClass: "",
                                           closeCallback: function() {
                                               //alert('You closed the alert!');
                                           }
                                       })
                                   }                               
                               });
        
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