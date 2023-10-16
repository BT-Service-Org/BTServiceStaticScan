public without sharing class GDC_MS_ReminderNotifyToAssetDeveloper {
    public static Map<String, GDC_MS_Ignore_Status__c> ignoreStatusCustomSettingMap = GDC_MS_Ignore_Status__c.getAll();
    public static list<string> statusToBeIgnored = (ignoreStatusCustomSettingMap.get('Ignore Asset Status')?.GDC_MS_Status_Values__c != null)? ignoreStatusCustomSettingMap.get('Ignore Asset Status').GDC_MS_Status_Values__c.split(','): new List<String>();
    //Parked,Rejected,Ready for Team Demo,Delivered
    public static void notify() {
        set<id> assetIds = new Set<id>();
        list<gdc_ms_ReusableAsset__c> updateAssetRecord = new List<gdc_ms_ReusableAsset__c>();
        Map<string, list<gdc_ms_AssetMember__c>> assetMemberMap = new Map<string, list<gdc_ms_AssetMember__c>>();
        Map<string, list<Id>> assetIdMemberMap = new Map<string, list<Id>>();
        if (!statusToBeIgnored.isEmpty()) {
            list<gdc_ms_ReusableAsset__c> assets = [
                SELECT
                id,
                GDC_MS_Number_of_Reminder__c,
                GDC_MS_Last_Reminder_Trigger_Date__c,
                GDC_MS_Next_Reminder_Trigger_date__c
                FROM gdc_ms_ReusableAsset__c
                WHERE
                GDC_MS_Next_Reminder_Trigger_date__c = TODAY
                AND gdc_ms_Status__c NOT IN :statusToBeIgnored
            ];
            for (gdc_ms_ReusableAsset__c asset : assets) {
                assetIds.add(asset.Id);
                asset.GDC_MS_Next_Reminder_Trigger_date__c = Date.today().addDays(7);
                asset.GDC_MS_Last_Reminder_Trigger_Date__c = Date.today();
                asset.GDC_MS_Number_of_Reminder__c = asset.GDC_MS_Number_of_Reminder__c != null ? asset.GDC_MS_Number_of_Reminder__c + 1 : 1;
                updateAssetRecord.add(asset);
            }
            list<gdc_ms_AssetMember__c> memberList = [
                SELECT
                Id,
                gdc_ms_TeamMember__r.gdc_ms_MappedUser__r.Name,
                gdc_ms_ReusableAsset__r.gdc_ms_Title__c,
                gdc_ms_ReusableAsset__c,
                gdc_ms_TeamMember__r.gdc_ms_MappedUser__c,
                gdc_ms_Role__c,
                gdc_ms_TeamMember__r.Name
                FROM gdc_ms_AssetMember__c
                WHERE
                gdc_ms_ReusableAsset__c IN :assetIds
                AND gdc_ms_Role__c = 'Developer'
            ];
            for (gdc_ms_AssetMember__c member : memberList) {
                if (!assetMemberMap.containsKey(member.gdc_ms_ReusableAsset__r.gdc_ms_Title__c)) {
                    list<gdc_ms_AssetMember__c> memblist = new List<gdc_ms_AssetMember__c>();
                    list<id> idList = new List<id>();
                    idList.add(member.gdc_ms_TeamMember__r.gdc_ms_MappedUser__c);
                    memblist.add(member);
                    assetMemberMap.put(member.gdc_ms_ReusableAsset__r.gdc_ms_Title__c, memblist );
                    assetIdMemberMap.put( member.gdc_ms_ReusableAsset__r.gdc_ms_Title__c, idList );
                } else {
                    list<gdc_ms_AssetMember__c> templst = assetMemberMap.get( member.gdc_ms_ReusableAsset__r.gdc_ms_Title__c);
                    list<id> tempIdLst = assetIdMemberMap.get(member.gdc_ms_ReusableAsset__r.gdc_ms_Title__c);
                    templst.add(member);
                    tempIdLst.add(member.gdc_ms_TeamMember__r.gdc_ms_MappedUser__c);
                    assetMemberMap.put(member.gdc_ms_ReusableAsset__r.gdc_ms_Title__c,templst);
                    assetIdMemberMap.put(member.gdc_ms_ReusableAsset__r.gdc_ms_Title__c,tempIdLst);
                }
            }
        }
        if (!assetMemberMap.isEmpty()) {
            sendEmail(assetIdMemberMap, assetMemberMap);
        }
        
        if (!updateAssetRecord.isEmpty()) {
            update updateAssetRecord;
        }
    }
    
    public static void sendEmail(Map<string, list<id>> assetMemberIdMap,Map<string, list<gdc_ms_AssetMember__c>> assetMemberMap) {
        list<Messaging.SingleEmailMessage> emailLst = new List<Messaging.SingleEmailMessage>();
        Set<String> listAdminTeamEmails = getEmailForGroup('GDC_MS_Asset_Team');
        for (string key : assetMemberMap.keySet()) {
            String body = '';
            Messaging.SingleEmailMessage email;
            list<gdc_ms_AssetMember__c> assetMembers = assetMemberMap.get(key);
            for (gdc_ms_AssetMember__c member : assetMembers) {
                email = new messaging.SingleEmailMessage();
                List<String> salesforceBaseURL = GDC_MS_AssetCommentController.generatePortalURL();
                body =
                    '<p>Dear ' +
                    member.gdc_ms_TeamMember__r.gdc_ms_MappedUser__r.Name +
                    ',</p><p>You haven\'t made any update on the below-metioned Reusable Asset. <br><div style="border: 1px solid #dadce0;border-radius: 7px;margin-bottom: 7px; padding: 1rem;max-width: 50rem;">Reusable Asset Name: <a href="' +
                    salesforceBaseURL[0] +
                    member.gdc_ms_ReusableAsset__c +
                    '">' +
                    member.gdc_ms_ReusableAsset__r.gdc_ms_Title__c +
                    '</a></div><p>Thanks a lot for contributing to the Reusable Asset Library.</p><p>Thanks,<br>Reusable Asset Team</p>';
                email.setSubject(
                    'Action Required on assigned Reusable Asset: ' +
                    member.gdc_ms_ReusableAsset__r.gdc_ms_Title__c
                );
                email.setHtmlBody(body);
                list<id> toAddresses = new List<id>();
                toAddresses.add(member.gdc_ms_TeamMember__r.gdc_ms_MappedUser__c);
                email.setToAddresses(toAddresses);
                email.setReplyTo(Label.GDC_MS_asset_comment_email_ids);
                String reusableAssetTeamOrgEmailId = getResuableAssetEmail();
                if(String.isNotBlank(reusableAssetTeamOrgEmailId)){
                    email.setOrgWideEmailAddressId(reusableAssetTeamOrgEmailId);
                }
                if(!listAdminTeamEmails.isEmpty())
                    email.setCcAddresses(new List<String>(listAdminTeamEmails));
                emailLst.add(email);
            }
        }
        Messaging.sendEmail(emailLst);
    }
    public static Set<String> getEmailForGroup(String publicGroupName) {
        Set<String> emails = new Set<String>();
        if (String.isBlank(publicGroupName))
            return emails;
        else {
            List<String> listUserIds = new List<String>();
            for (GroupMember member : [
                SELECT UserOrGroupId
                FROM GroupMember
                WHERE Group.DeveloperName = :publicGroupName
            ]) {
                listUserIds.add(member.UserOrGroupId);
            }
            if (!listUserIds.isEmpty()) {
                for (User u : [SELECT Email FROM User WHERE Id IN :listUserIds]) {
                    emails.add(u.Email);
                }
            }
            return emails;
        }
    }
    
    @AuraEnabled
    public static void updateDownloadCount(string assetID){
        if(string.isNotBlank(assetID)){
         gdc_ms_ReusableAsset__c asset = [
                SELECT
                ID,
                gdc_ms_Download_Count__c
                FROM gdc_ms_ReusableAsset__c
                WHERE
                ID = :assetID
            ];
        if(asset!=null)
        	asset.gdc_ms_Download_Count__c = asset.gdc_ms_Download_Count__c!=null?asset.gdc_ms_Download_Count__c+1:1;
        
       try {
                UPDATE asset;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            } 
        }
    }
    
    private static String getResuableAssetEmail(){
        OrgWideEmailAddress[] reusableOrgEmailId = [SELECT Id from OrgWideEmailAddress
                                      WHERE Address =: Label.GDC_MS_asset_comment_email_ids];
        if (reusableOrgEmailId.size() > 0) {
            return reusableOrgEmailId.get(0).Id;
        }
        return null;
    }
}