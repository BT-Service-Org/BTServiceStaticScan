public with sharing class PSCPageViewService {
   
   @AuraEnabled(Cacheable=true)
   public static PSC_Page__c getPageAttributes(String key) {
       List<PSC_Page__c> pageList=new List<PSC_Page__c> ();
       pageList=[SELECT Id,Page_Title__c,Page_Description__c,Title_Background_URL__c,Type__c ,Channel_Id__c, Slack_Channel_Link__c,
                       (SELECT Id,psc_Role__c
                       FROM Contribution_Teams__r
                       WHERE psc_Team_Member__c = :UserInfo.getUserId()
                       LIMIT 1)
                   FROM PSC_Page__c 
                   WHERE URLName__c=:key];
       if (pageList!=null && pageList.size()>0){
               return pageList[0];
       }
       return null;
   }
   @AuraEnabled(Cacheable=true)
   public static List<PSC_Page_Section__c> getPageSections(String key) {
       List<PSC_Page_Section__c> pageSectionList=new List<PSC_Page_Section__c> ();
       pageSectionList=[SELECT Id,Name,Page__c,	Type__c, Page_Section_title__c,Section_Body__c,VideoUrl__c,imageUrl__c,Align_Image__c,Sequence__c,
                       section_width__c, Image_Width__c,Page__r.Type__c, Page__r.Last_Published__c,Page__r.Author__r.FirstName, 
                       Page__r.Author__r.LastName
                           FROM PSC_Page_Section__c where page__r.urlname__c=:key 
                           AND Type__c!='Featured Content'
                           ORDER BY Sequence__c];
       if (pageSectionList!=null && pageSectionList.size()>0){
               return pageSectionList;
       }
       return null;
   }

   @AuraEnabled(Cacheable=true)
   public static List<PSC_Page_Section__c> getFeatureContent(String key, Integer resultCount) {
       List<PSC_Page_Section__c> pageSectionList=new List<PSC_Page_Section__c> ();
       pageSectionList=[SELECT Id,Name,Page__c, Type__c, Page_Section_title__c,Section_Body__c,imageUrl__c,Sequence__c, section_width__c,
                           Image_Width__c, Featured_Content_URL__c
                           FROM PSC_Page_Section__c 
                           WHERE page__r.urlname__c=:key 
                           AND Type__c='Featured Content'
                           ORDER BY Sequence__c
                           LIMIT :resultCount];
       if (pageSectionList!=null && pageSectionList.size()>0){
               return pageSectionList;
       }
       return null;
   }

   @AuraEnabled(Cacheable=true)
   public static List<PSC_Page__c> getAllPageAttributes() {
       List<PSC_Page__c> pageList=new List<PSC_Page__c> ();
       pageList=[SELECT Id,Page_Title__c,Page_Description__c,Services_Central_Link__c,Type__c ,
                       (SELECT Id,psc_Role__c
                       FROM Contribution_Teams__r
                       WHERE psc_Team_Member__c = :UserInfo.getUserId()
                       LIMIT 1)
                   FROM PSC_Page__c
                   WHERE Type__c = 'Community Page'
                   AND Status__c = 'Published'
                   ORDER BY CreatedDate DESC];
       
       return pageList;
   }

   @AuraEnabled(Cacheable=true)
   public static List<PSC_Page_Section__c> getAllFeatureContent() {
       List<PSC_Page_Section__c> pageSectionList=new List<PSC_Page_Section__c> ();
       pageSectionList=[SELECT Id, Page_Section_title__c,Section_Body__c,imageUrl__c, Featured_Content_URL__c, page__r.Page_Title__c
                           FROM PSC_Page_Section__c
                           WHERE Type__c='Featured Content'
                           AND page__r.Type__c = 'Community Page'
                            AND page__r.Status__c = 'Published'
                           ORDER BY CreatedDate DESC
                           LIMIT 9];
       return pageSectionList;
   }

   /**
    * 
    * @param userId 
    * @param pageSlackId 
    */
   @auraEnabled
   public static void becomeMemberSlack(String userId, String pageSlackId){
       MTH_SlackApiHandlerInterface slackApi = new MTH_SlackApiHandler();

       String slackUserId = getSlackUserId(userId);

       Slack.ViewReference viewRef = Slack.View.simple_notification.get();
       viewRef.setParameter('messageText', 'Welcome <@'+slackUserId +'> to the <#'+pageSlackId+'>. Please click Join to receive notifications for this community');
       slackApi.postMessage(viewRef, slackUserId);
   }

   private static String getSlackUserId(String userId){
       User user = [SELECT Id, Name, FederationIdentifier, Slack_User_Id__c 
                   FROM User 
                   WHERE Id = :userId LIMIT 1];
       return MTH_SlackUserIdHandler.getSlackUserIdFromSFUser(user);
   }

  //  this code is working , but not required at the moment.
   /*@AuraEnabled
   public static void leaveChannel(String userId, String pageSlackId){
       MTH_SlackApiHandlerInterface slackApi = new MTH_SlackApiHandler();

       String slackUserId = getSlackUserId(userId);
       leaveChannelCall(slackUserId, pageSlackId);
       System.debug('channelId->'+slackUserId);
   }

   private static void leaveChannelCall(String userId, String pageSlackId){
       Slack.ConversationsKickRequest kickReq= Slack.ConversationsKickRequest.builder()
                                           .user(userId)
                                           .channel(pageSlackId)
                                           .build();
       Slack.ConversationsKickResponse kickRes =getBotClient().conversationsKick(kickReq);
   }

   private static Slack.BotClient getBotClient() {
       String teamId = Methodologies_Slack_App_Settings__c.getInstance().Team_Id__c;
       Slack.App app = Slack.App.Methodologies.get();
       return app.getBotClientForTeam(teamId);
   }*/
}