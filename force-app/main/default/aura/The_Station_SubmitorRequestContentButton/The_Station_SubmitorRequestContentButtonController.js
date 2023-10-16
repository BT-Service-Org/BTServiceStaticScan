({
    handleShowModal: function(component, event, helper) {
    var modalBody;
    var UserorQueueId = component.get("v.UserorQueueId");
    console.log("UserId:"+UserorQueueId);
    $A.createComponent("c:The_Station_SubmitContentCaseFlow", 
                        {
                            UserorQueueId : UserorQueueId
                        },
                        function(content, status) {
                            if (status === "SUCCESS") {
                                modalBody = content;
                                component.find('overlayLib').showCustomModal({
                                    header: "The Station - Submit Content Case",
                                    body: modalBody, 
                                    showCloseButton: true,
                                    cssClass: "",
                                    closeCallback: function() {
                                        //alert('You closed the alert!');
                                    }
                                })
                            }                               
                        });
        
    }
    
})