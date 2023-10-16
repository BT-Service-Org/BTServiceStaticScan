@isTest
public class The_Station_TrailheadInfoControllerTest {
    
    @TestSetup
    private static void testSetup() {
        
        // Insert user data
        trailheadapp__Trailhead_User_Data__c userData = new trailheadapp__Trailhead_User_Data__c();
		userData.trailheadapp__Profile_URL__c = 'https://trailblazer.me/id/zakariasemri';
        userData.trailheadapp__User__c = UserInfo.getUserId();
        userData.trailheadapp__External_Id__c = '1827628746';
        insert userData;
        
        // Insert badges
        List<trailheadapp__Badge__c> badges = new List<trailheadapp__Badge__c>();
        
        trailheadapp__Badge__c badge1 = new trailheadapp__Badge__c();
        badge1.Name = 'Advanced Apex Specialist';
        badge1.trailheadapp__API_Name__c = 'superbadge_aap';
        badge1.trailheadapp__Namespace__c = 'learn';
        badge1.trailheadapp__URL__c = 'https://developer.salesforce.com/trailhead/super_badges/superbadge_aap/';
        badge1.trailheadapp__Type__c = 'Superbadge';
        badge1.trailheadapp__Icon__c = 'https://res.cloudinary.com/hy4kyit2a/f_auto,fl_lossy,q_70/learn/superbadges/superbadge_aap/586e2b06a57853f49ed1678026faf2f5_badge.png';
    	badge1.trailheadapp__Description__c = 'Build complex business logic using advanced Apex and Visualforce programming techniques.'; 
        badges.add(badge1);
        
        trailheadapp__Badge__c badge2 = new trailheadapp__Badge__c();
        badge2.Name = 'Accessibility Basics';
        badge2.trailheadapp__API_Name__c = 'accessibility-basics';
        badge2.trailheadapp__Namespace__c = 'learn';
        badge2.trailheadapp__URL__c = 'https://developer.salesforce.com/trailhead/module/accessibility-basics/';
        badge2.trailheadapp__Type__c = 'Module';
        badge2.trailheadapp__Icon__c = 'https://res.cloudinary.com/hy4kyit2a/f_auto,fl_lossy,q_70/learn/modules/accessibility-basics/9cb082ff8941482adea328d195ad6ca0_badge.png';
    	badge2.trailheadapp__Description__c = 'Learn why it’s important to make technology accessible to everyone.'; 
        badges.add(badge2);
        
        insert badges;
        
        // Insert badges progress
        List<trailheadapp__User_Badge__c> userBadges = new List<trailheadapp__User_Badge__c>();
        
        trailheadapp__User_Badge__c userBadge1 = new trailheadapp__User_Badge__c();
        userBadge1.trailheadapp__Badge__c = badge1.Id;
        userBadge1.trailheadapp__Status__c = 'In-Progress';
        userBadge1.trailheadapp__User__c = UserInfo.getUserId();
        userBadges.add(userBadge1);
        
        trailheadapp__User_Badge__c userBadge2 = new trailheadapp__User_Badge__c();
        userBadge2.trailheadapp__Badge__c = badge2.Id;
        userBadge2.trailheadapp__Status__c = 'Completed';
        userBadge2.trailheadapp__User__c = UserInfo.getUserId();
        userBadges.add(userBadge2);
        
        insert userBadges;
    }
    
    @isTest
    private static void getBadgesProgressTest() {
        Test.startTest();
        List<The_Station_TrailheadInfoController.BadgeProgressWrapper> badgesProgress = The_Station_TrailheadInfoController.getBadgesProgress();
        Test.stopTest();
        System.assertEquals(2, badgesProgress.size(), 'There should be 2 badges returned');
    }
    
    @isTest
    private static void getProfileUrlTest() {
        Test.startTest();
        String profileUrl = The_Station_TrailheadInfoController.getProfileUrl();
        Test.stopTest();
        System.assertEquals('https://trailblazer.me/id/zakariasemri', profileUrl, 'The returned profile url is incorrect');
    }

}