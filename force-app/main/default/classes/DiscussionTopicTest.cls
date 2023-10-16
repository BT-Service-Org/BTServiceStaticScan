@IsTest private class DiscussionTopicTest {
    
    public static testMethod void testDiscussion() {
        try{

            DiscussionTopicsController dis= new DiscussionTopicsController();
            
            DiscussionTopic__c dt = [select d.Team__c from DiscussionTopic__c d limit 1];
            dis.setTEAMID('');
            dis.refreshList();
            Boolean b = dis.getNoTopics();
            List<DiscussionTopicsController.TopicList> topics = dis.getTopicList();

            DiscussionTopicsController.updateviewCount upd = new DiscussionTopicsController.updateviewCount();
            String topicId = upd.getTopicId();
            upd.updateviewCountRedirect();
            PageReference pr = upd.getTopicPage();
            
            PageReference pr2 = dis.openTopic();
            
            DiscussionTopicsController.TopicList topicList = new DiscussionTopicsController.TopicList();
            topicList.setId('Some Id');
            topicList.setAuthorId('Some Id');
            topicList.setAuthorName('Some Name');
            topicList.setName('Some Name');
            topicList.setTeamName('Team Name');
            topicList.setTeamId('Some team');
            topicList.setNumberOfMessages(1);
            topicList.setNumberOfViews(1);

            DiscussionMessage__c dsMessage = [select Id from DiscussionMessage__c limit 1];
            topicList.setLastPostMessage(dsMessage.Id);
            topicList.setFirstMessageCreated(dsMessage);
            topicList.setAuthorPicture('Some Author');
            topicList.setEnableActions('Some Id', true);
            
            Boolean b2 = topicList.getEnableActions();
            String pic = topicList.getAuthorPicture();
            
            //String message = topicList.getFirstMessageCreated();
            //String firstId = topicList.getFirstMessageId();
            
            String id = topicList.getId();
            String author = topicList.getAuthorId();
            String fuulAuthor = topicList.getFullAuthorName();
            String authorName = topicList.getAuthorName();
            String name = topicList.getName();
            String shortName = topicList.getShortName();
            String teamName = topicList.getTeamName();
            String teamId = topicList.getTeamId();
            Integer nMessage = topicList.getNumberOfMessages();
            Integer nView = topicList.getNumberOfViews();
            String lastPost = topicList.getLastPostMessage();
            Boolean isAuthor = topicList.getIsAuthor();
            
            dis.nextPage();
            dis.prevPage();
            dis.genCntPagination();
            Integer nAux = dis.getCurrentPagination();
            nAux = dis.getNumberOfItemsToShow();
            nAux = dis.getFirstRow();
            Boolean bAux = dis.getPrevPageLinkShow();
            bAux = dis.getPrevPageShow();
            bAux = dis.getNextPageLinkShow();
            bAux = dis.getNextPageShow();
            
            dis.setTEAMID(dt.Team__c);
            dis.saveTopic();            
            dis.updateReadCount();
            DiscussionForum__c forum = dis.getForumData();
            dis.fillTopicList();
            dis.getMostRead();
            dis.genPermissions();
            dis.getUserPermissions();
            dis.saveTopic();            
            
            String sortBy = null;
            
            dis.setSortBy('Name');
            dis.setSortByDesc(false);
            dis.sortList();
            
            dis.setSortByDesc(true);
            dis.sortList();
            sortBy = dis.getSortBy();
            
            dis.setSortBy('PostedBy__r.Name');
            dis.setSortByDesc(false);
            dis.sortList();
            
            dis.setSortByDesc(true);
            dis.sortList();         
            sortBy = dis.getSortBy();
            
            dis.setSortBy('ViewCount__c');
            dis.sortList();
            sortBy = dis.getSortBy();
            
            dis.setSortBy('MessageCount__c');
            dis.setSortByDesc(false);
            dis.sortList();
            
            dis.setSortByDesc(true);
            dis.sortList();                                     
            sortBy = dis.getSortBy();
            
            dis.setSortBy('LastPostedMessage__c');
            dis.setSortByDesc(false);
            dis.sortList();
            
            dis.setSortByDesc(true);
            dis.sortList();     
            sortBy = dis.getSortBy();
            
        }catch(Exception e){
            throw e;
        }
    }   
}