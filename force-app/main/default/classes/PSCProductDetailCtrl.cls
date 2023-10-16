public with sharing class PSCProductDetailCtrl {
    @AuraEnabled(Cacheable=true)
    public static String getProductTypeValues(String key) {
        return PSCSettingService.getValue(key);
    }
}