@RestResource(urlMapping='/featureToggle/*')
global class FeatureToggleRestService {
    @HttpPost
    global static String getFlagState(RequestData rData) {
        RestResponse res = RestContext.response;
        return JSON.serialize(FeatureToggleService.getFeatureState(rData.parentToggleLabel,rData.childToggleLabel));
    }
    
    global class RequestData {
        global String parentToggleLabel;
        global String childToggleLabel;
    }
}