public with sharing class PSCUserMenuCtrl {
    @AuraEnabled(Cacheable=true)
    public static String getUserMenuItems() {
        return PSCSettingService.getValue('User_Menu_Items');
    }
}