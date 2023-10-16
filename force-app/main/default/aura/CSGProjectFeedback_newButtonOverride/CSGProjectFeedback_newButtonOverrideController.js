({
    init : function (component) {
        // Find the component whose aura:id is "flowId"
        var flow = component.find("flowId");
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("CSG_Request_Feedback_Flow");
    },
})