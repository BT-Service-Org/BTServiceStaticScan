public with sharing class PSCThemeFooterCtrl {
    @AuraEnabled(Cacheable=true)
    public static String getFooterLinks() {
        return PSCSettingService.getValue('Footer_Links');
    }
}