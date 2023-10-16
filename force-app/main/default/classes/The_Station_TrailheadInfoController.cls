public class The_Station_TrailheadInfoController {
    
    private final static Integer MAX_BADGES_PROGRESS = 50;
    private final static Map<String, String> STATUS_MAP = new Map<String, String> {
        'InProgress' => 'In-Progress',
		'Completed' => 'Completed',
		'Assigned' => 'Assigned'
    };
    
    @AuraEnabled(cacheable=true)
    public static List<BadgeProgressWrapper> getBadgesProgress() {
        
        String baseQuery = 'SELECT trailheadapp__Status__c, trailheadapp__Badge__r.trailheadapp__Type__c, trailheadapp__Badge__r.trailheadapp__Icon__c, trailheadapp__Badge__r.Name, trailheadapp__Badge__r.trailheadapp__Description__c, trailheadapp__Badge__r.trailheadapp__Tags__c, trailheadapp__Badge__r.trailheadapp__URL__c FROM trailheadapp__User_Badge__c WHERE trailheadapp__User__c = \'' + UserInfo.getUserId() + '\'';
        
        List<trailheadapp__User_Badge__c> inProgressBadges = Database.query(baseQuery + ' AND trailheadapp__Status__c = \'' + STATUS_MAP.get('InProgress') + '\' LIMIT ' + MAX_BADGES_PROGRESS);
        List<BadgeProgressWrapper> badgesProgress = new List<BadgeProgressWrapper>();
        for(trailheadapp__User_Badge__c userBadge : inProgressBadges) {
            BadgeProgressWrapper badgeProgress = new BadgeProgressWrapper(userBadge.trailheadapp__Status__c, userBadge.trailheadapp__Badge__r.trailheadapp__Type__c, userBadge.trailheadapp__Badge__r.trailheadapp__Icon__c, userBadge.trailheadapp__Badge__r.Name, userBadge.trailheadapp__Badge__r.trailheadapp__Description__c, userBadge.trailheadapp__Badge__r.trailheadapp__Tags__c, userBadge.trailheadapp__Badge__r.trailheadapp__URL__c);
            badgesProgress.add(badgeProgress);
        }
        
        List<trailheadapp__User_Badge__c> completedBadges = Database.query(baseQuery + ' AND trailheadapp__Status__c = \'' + STATUS_MAP.get('Completed') + '\' LIMIT ' + (MAX_BADGES_PROGRESS - inProgressBadges.size()));
        for(trailheadapp__User_Badge__c userBadge : completedBadges) {
            BadgeProgressWrapper badgeProgress = new BadgeProgressWrapper(userBadge.trailheadapp__Status__c, userBadge.trailheadapp__Badge__r.trailheadapp__Type__c, userBadge.trailheadapp__Badge__r.trailheadapp__Icon__c, userBadge.trailheadapp__Badge__r.Name, userBadge.trailheadapp__Badge__r.trailheadapp__Description__c, userBadge.trailheadapp__Badge__r.trailheadapp__Tags__c, userBadge.trailheadapp__Badge__r.trailheadapp__URL__c);
            badgesProgress.add(badgeProgress);
        }
        
        return badgesProgress;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getProfileUrl() {
        List<trailheadapp__Trailhead_User_Data__c> userData = [SELECT trailheadapp__Profile_URL__c FROM trailheadapp__Trailhead_User_Data__c WHERE trailheadapp__User__c =: UserInfo.getUserId()];
        if(!userData.isEmpty()) {
            return userData[0].trailheadapp__Profile_URL__c;
        }
        return '';
    }
    
    public class BadgeProgressWrapper {
        @AuraEnabled public String progress;
        @AuraEnabled public String type;
        @AuraEnabled public String icon;
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public String tags;
        @AuraEnabled public String url;
        
        BadgeProgressWrapper(String progress, String type, String icon, String name, String description, String tags, String url) {
            this.progress = progress;
            this.type = type;
            this.icon = icon;
            this.name = name;
            this.description =  description;
            this.tags = tags;
            this.url = url;
        }
    }
}