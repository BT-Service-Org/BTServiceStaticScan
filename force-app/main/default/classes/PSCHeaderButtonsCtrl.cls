public with sharing class PSCHeaderButtonsCtrl {
    @AuraEnabled(Cacheable=true)
    public static String getHeaderButtonsInfo() {
        List<Object> result = new List<Object>();

        String userProfileName = [
                SELECT Name
                FROM Profile
                WHERE Id = :UserInfo.getProfileId()
        ].Name;

        String setting  =PSCSettingService.getValue('Header_Buttons');
        List<Object> buttonsInfo = (List<Object>) JSON.deserializeUntyped(setting);

        for (Object item : buttonsInfo) {
            Map<String,Object> buttonInfo = (Map<String,Object>) item;

            if ((Boolean) buttonInfo.get('active')) {
                Boolean accessPermission = false;

                if (buttonInfo.containsKey('profiles')) {
                    List<String> profileList = ((String) buttonInfo.get('profiles')).split(',');
                    accessPermission = profileList.contains(userProfileName);
                } else {
                    accessPermission = true;
                }

                if (accessPermission) {
                    result.add(new Map<String,Object> {
                            'label' => buttonInfo.get('label'),
                            'url' => buttonInfo.get('url')
                    });
                }
            }
        }

        return JSON.serialize(result);
    }
}