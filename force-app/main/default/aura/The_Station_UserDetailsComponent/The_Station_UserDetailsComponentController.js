({
    doInit : function(component, event, helper) {       
        helper.doInit(component);        
    },
    handleSelect: function(component, event, helper) {
        switch(event.getParam('value')) {
          case "1":   component.set("v.isModalOpen", true);
                      component.set("v.modalTitle", 'View Photo');
                      helper.routeModal(component,true,false,false);
                      break;
  
          case "2":   component.set("v.isModalOpen", true);
                      component.set("v.modalTitle", 'Update Photo');
                      helper.routeModal(component,false,true,false);
                      break;
                    
          case "3":   component.set("v.isModalOpen", true);
                      component.set("v.modalTitle", 'Delete Photo');
                      helper.routeModal(component,false,false,true);
                      break;
        }
      },
      refreshMainPhoto : function(component, event, helper) {
          var userPhotoInTheModal = component.find('userPhoto');
          userPhotoInTheModal.refreshPhoto();
      },
    
        openCommunityBuilder : function (component, event, helper) {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({ "url": component.get("v.builderUrl") });   // Pass your community URL
            urlEvent.fire(); },
  
 
})