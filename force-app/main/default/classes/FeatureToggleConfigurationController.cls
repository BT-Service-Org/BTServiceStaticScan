public class FeatureToggleConfigurationController {
    
    public List<Feature_Toggle__mdt> featureToggles {get;set;}
    public List<String> featureToggleFields {get;set;}
    public List<String> childFeatureToggleFields {get;set;}
    public Boolean isCacheEnabled {get;set;}
    private FeatureToggleQueryService featureToggleQueryService;

    public FeatureToggleConfigurationController() {
        this.featureToggleQueryService = new FeatureToggleQueryService();
        isCacheEnabled = FeatureToggleService.isCacheEnabled;
        featureToggles = FeatureToggleService.getFeatureToggleRecords(null, null);
        featureToggleFields = FeatureToggleQueryService.getMetadataFieldDescribe().get('Feature_Toggle__mdt');
        childFeatureToggleFields = FeatureToggleQueryService.getMetadataFieldDescribe().get('Child_Feature_Toggle__mdt'); 
    }
    public PageReference cleanupTheCache() {
        FeatureToggleCacheService.cleanupTheCache();
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Cached Settings were cleaned up'));
        return null;
    }
 }