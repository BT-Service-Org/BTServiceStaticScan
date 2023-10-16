/**
 * @author piyush.jindal@salesforce.com
 * @since August 2023
 * @description Controller class for pscFeaturedSlackComments component
 * @group Services Central
 */
public with sharing class PSCFeaturedSlackCommentsCtrl {
    /**
     * @param  communityPageNameStr `String`
     * @return  `List<Featured_Comments__c>`
     */
    @AuraEnabled(Cacheable = true)
    public static List<Featured_Comments__c> getFeaturedComments(String communityPageNameStr,String urlPageName){
        String communityPageNameStrEscaped = String.escapeSingleQuotes(communityPageNameStr);
        String query = 'SELECT Id, Slack_Comment__c, Slack_Link__c, Channel_Id__c, Thread_TS__c, Commenter__r.Name, Commenter__r.Email, Commenter__r.MediumPhotoUrl, CreatedDate, Community__r.Page_Title__c FROM Featured_Comments__c  WHERE Community__r.Type__c = \'Community Page\' ';
        if(urlPageName == 'Community_Page__c' || urlPageName == 'Community__c'){
            query += ' AND Community__r.URLName__c =:communityPageNameStrEscaped ';
        }
        else if(urlPageName == 'Community_Home__c'){
            query += ' AND Community__r.Status__c = \'Published\' ';
        }
        query += ' ORDER BY CreatedDate DESC LIMIT 30';
        List<Featured_Comments__c> featuredCommentList = Database.query(query);

        if(featuredCommentList!=null && featuredCommentList.size()>0) {
            return featuredCommentList;
        }

        return null;
        
    }
}