/**({
    create : function(component, event, helper) {
        var content = component.get("v.content");
        var action = component.get("c.createRecord");
        action.setParams({
            content : content
        });
        action.setCallback(this,function(response){
            var content = response.getState();
            if(content == "SUCCESS"){
                //Reset Form
                var newcontent = {'sobjectType': 'Station_Content__c','Name':'',
                                  'Content_URL__c':'','Content_Type__c':'','Visibility__c': '','Description__c':'','Primary_Contact__c':'','Display_Image_URL__c':''
                                 };
                component.set("v.content",newcontent);
                
                alert('Record is Created Sucessfully');
                
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url":"/lightning/o/Station_Content__c/list?filterName=Recent&0.source=alohaHeader"
                });
                    console.log(urlEvent);
                    urlEvent.fire();                  
                } else if(content == "ERROR"){
                    let errors = response.getError();
                    let message;
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                    
                    alert(message);
                }
                });
                    //adds the server-side action to the queue
                    $A.enqueueAction(action);
                    
                }
})**/


({

    doInit: function(component, event, helper) {        
        helper.getVisibilityPicklist(component, event);
        helper.getContentTypePicklist(component,event);
    },
     

    create : function(component, event, helper) {
        helper.saveContent(component, event);
    },
     

    handleCompanyOnChange : function(component, event, helper) {
        var visibility = component.get("v.content.Visibility__c");
        alert(visibility);
    },
    
    
    handleUploadFinished: function (cmp, event) {
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
        alert("Files uploaded : " + uploadedFiles.length);
    }
})