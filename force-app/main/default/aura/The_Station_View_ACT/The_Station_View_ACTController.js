({ 
	doInit : function(component, event, helper) {
        let userAction = component.get("c.getMyLearnerProfileId");
        userAction.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                var userIdResp = response.getReturnValue();

                let myCoursesAction = component.get("c.getMyAssignedCourses");
                myCoursesAction.setParams({
                    userId : userIdResp
                });
                myCoursesAction.setCallback(this, function(response) {
                    let state = response.getState();
                    if (state === "SUCCESS") {
                        var assignedCourses = response.getReturnValue();
                        component.set("v.assignedCourses", assignedCourses);
                    }
                });
                $A.enqueueAction(myCoursesAction);
            }
        });

        $A.enqueueAction(userAction);
     
        /*let action = component.get("c.getCourses");
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log(response)
                component.set("v.courses", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
        */
    },
})