public class FeatureToggleCacheService {
    private static Boolean cacheEnabled;
    private static final String CACHE_KEY = 'local.Help.FeatureFlagValues';
        
    static {
        cacheEnabled = true;
        try {
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Help');
        } catch (Exception e) {
            cacheEnabled = false;
        }
    }
    
    public static Boolean toggleEnabled() { // Use for testing misses
        cacheEnabled = !cacheEnabled;
        return cacheEnabled;
    }
    public static void cleanupTheCache() { // Use for testing misses
        Cache.Org.remove(FeatureToggleCache.class, CACHE_KEY);
    }

    public static List<Feature_Toggle__mdt> getFromCache() {
        if (!cacheEnabled) return null;
        // we don't need retrieve cached values based on some criterion since we are takin all the data at the same time. Key will be generic.
        List<Feature_Toggle__mdt> featureToggles = (List<Feature_Toggle__mdt>) Cache.Org.get(FeatureToggleCache.class, CACHE_KEY);
        return featureToggles;
    }

    class FeatureToggleCache implements Cache.CacheBuilder {
        public Object doLoad(String key) {
            // querying unparameterized method, key is only used to store values in cache, not tor retrieve something
            List<Feature_Toggle__mdt> featureToggleRecords = FeatureToggleService.getFeatureToggleRecords(null, null);
            System.debug('FROM DB');
            return featureToggleRecords;
        }
    }
}