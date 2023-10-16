({
    doInit: function (component, event, helper) {
        let action = component.get("c.getProductRelationship");
        action.setCallback(this, function (response) {
            const state = response.getState();
            if(state === "SUCCESS") {
                let productRelationshipMap = response.getReturnValue();
                localStorage.setItem("CoveoV2__ProductDetails",productRelationshipMap);
                document.addEventListener('coveoFacetIntialised', function(e){
                document.dispatchEvent(new CustomEvent('coveoProductDetails', {
                        detail : {
                            'requestContentModal' : component.find("requestcontentmodal"),
                            'productRelationship' : productRelationshipMap[0],
                            'userData' : productRelationshipMap[1]
                        }
                    }));
                });  
            }
        });
        $A.enqueueAction(action);
    }
})