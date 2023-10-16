({

    
    fireRefreshMainPhoto : function(component, event, helper) {
        var compEvents = component.getEvent("refreshMainPhoto");
        compEvents.fire();
      },

    retrieveUserObject : function(component, event, helper) {//fetchUserDetail
        var action = component.get("c.fetchUserDetail");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                component.set('v.userObject', res);
                setTimeout(() => {  component.set("v.Loading",false);}, 1000);
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        component.set("v.Loading",true);
        $A.enqueueAction(action);
    },

    updatePhoto : function(component, event, helper){//updateUserPhoto

        try {

            var uploadedFiles = component.get("v.tempFiles");
            var action = component.get("c.updateUserPhoto");
            /*var inputPhoto = {	cropSize : 120,
                cropX : 0,
                cropY : 0,
                fileId : '' + uploadedFiles[0].documentId
            }
            action.setParams({
                "inputPhoto": inputPhoto
            });*/

            action.setParams({
                "docId": uploadedFiles[0].documentId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //var res = response.getReturnValue();
                        this.showToast("Success!","success",3000,"The profil photo has been updated successfully.");
                        //setTimeout(function(){ a$A.get('e.force:refreshView').fire(); }, 1000);
                        // refresh PHOTO 1
                        setTimeout(() => {
                            this.fireRefreshMainPhoto(component, event, helper);
                        }, 1000);

                }
                else if (state === "INCOMPLETE") {
                    //console.log("INCOMPLETE");
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            });
            $A.enqueueAction(action);
        } catch (error) {
            alert("helper error : " + JSON.stringify(error.message));
        }

        
    },

    deletePhoto : function(component, event, helper){//deleteUserPhoto
        var action = component.get("c.deleteUserPhoto");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                    
                this.showToast("Deleted!",null,3000,"The profil photo has been deleted successfully.");
                setTimeout(() => {
                    this.fireRefreshMainPhoto(component, event, helper);
                }, 1000);
                
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE");
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },

    getPhotoUrl : function(component,docId){//getDocumentVersionId

        try {
        var action = component.get("c.getDocumentVersionId");

        action.setParams({
            "documentId": docId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                // TODO
                var photoUrl = "https://sfservices--bedrockuat--c.cs8.content.force.com/sfc/servlet.shepherd/version/renditionDownload"+
                "?rendition=ORIGINAL_Png&versionId="+res+"&operationContext=CHATTER&contentId="+docId;
                component.set("v.userObject.FullPhotoUrl",photoUrl);
                setTimeout(() => {  component.set("v.Loading",false);}, 1000);
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE");
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            
        });
        component.set("v.Loading",true);
        $A.enqueueAction(action);

        } catch (error) {
            alert("helper modal : " + error.message);
        }
        

    },

    showToast : function(title,type,duration,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type":type,
            "duration":duration,
            "message": message
        });
        toastEvent.fire();
    }


})