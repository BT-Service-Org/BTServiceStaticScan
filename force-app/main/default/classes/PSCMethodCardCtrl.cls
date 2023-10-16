public with sharing class PSCMethodCardCtrl {
    @AuraEnabled(Cacheable=true)
    public static List<Method__C> getMethodCardData(List<String> key) {
        return PSCMethodCardService.getValue(key);
    }
}