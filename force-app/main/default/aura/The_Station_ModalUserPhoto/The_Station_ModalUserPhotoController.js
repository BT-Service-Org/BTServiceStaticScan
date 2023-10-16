({

    fireRefreshMainPhoto : function(component, event, helper) {
      helper.fireRefreshMainPhoto(component, event, helper);
    },

    openModel: function(component, event, helper) {
        component.set("v.isModalOpen", true);
     },

    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
        
     },

    submitDetails: function(component, event, helper) {    
      try {
        if (component.get("v.updateMode")){

          if(component.get("v.isPhotoUpdated")){
            helper.updatePhoto(component, event, helper);
            component.set("v.isPhotoUpdated",false);
          }
            }else if (component.get("v.deleteMode")){
              helper.deletePhoto(component, event, helper);
            }
        component.set("v.isModalOpen", false);
      } catch (error) {
        alert("error while sending request from modal to parent : " + JSON.stringify(error.message));
      }
     },
     
    handleUploadFinished: function (component, event,helper) {
      component.set("v.isPhotoUpdated",true);
      component.set("v.tempFiles",event.getParam("files"));
      //console.log(JSON.stringify(event));
      try {
        helper.getPhotoUrl(component, event.getParam("files")[0].documentId );
      } catch (error) {
        alert("Error modifying user object photo : " + error.message);
      }
    },
 })