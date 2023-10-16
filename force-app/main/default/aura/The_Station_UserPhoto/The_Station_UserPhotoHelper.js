({
    
    retrieveUserObject : function(component, event, helper) {//fetchUserDetail
    
        var action = component.get("c.fetchUserDetail");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                component.set('v.oUser', res);
                const img = new Image();
                img.onload = function() {
                    var profilePhoto = component.find("ProfilePhoto").getElement();
                    var coef;
                    if (this.height > this.width) {
                        coef = 180 / this.width;
                        profilePhoto.style.height = ( coef * this.height ) + 'px';
                        profilePhoto.style.width = ( coef * this.width ) + 'px';
                    }else if (this.width > this.height) {
                        coef = 180 / this.height;
                        profilePhoto.style.height = ( coef * this.height ) + 'px';
                        profilePhoto.style.width = ( coef * this.width ) + 'px';
                    }else {
                        // Equal => square set to 180px
                        profilePhoto.style.height = 180 + 'px';
                        profilePhoto.style.width = 180 + 'px';
                    }
                }
                img.src = res.FullPhotoUrl;
            }
            else if (state === "INCOMPLETE") {/*do something*/}
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        //console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    }
})