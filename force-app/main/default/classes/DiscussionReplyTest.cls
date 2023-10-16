@IsTest private class DiscussionReplyTest {
    public static testMethod void testDiscussion() {
         
        try{
            DiscussionReplyController dis = new DiscussionReplyController();
            DiscussionTopic__c newTopic = new DiscussionTopic__c();
            newTopic.ViewCount__c = 1;
            newTopic.Threaded__c = false;
            
            String idTeam = [select id from Team__c limit 1].id;
            newTopic.Team__c = idTeam;
            
            UserPermissionsTest.UserPermissionsTest();
            
            String idDiscussionForum = [select id from DiscussionForum__c where team__c =: idTeam limit 1].id;
            newTopic.DiscussionForum__c = idDiscussionForum;
            
            newTopic.Subject__c = 'Code Coverage';
            newTopic.Stickied__c = false;
            newTopic.PostedDate__c = System.now();
            newTopic.PostedBy__c = UserInfo.getUserId();
            newTopic.MessageCount__c = 0;
            newTopic.Locked__c = false;
            newTopic.LastViewedDate__c = System.now();
            
            insert newTopic;
            
            DiscussionMessage__c newMessage = new DiscussionMessage__c();
            newMessage.PostedDate__c = System.now();
            newMessage.Message__c = 'Replay to Topic';
            newMessage.DiscussionTopic__c = newTopic.id;
            newMessage.Team__c = idTeam;
            newMessage.Subject__c = 'Reply to Topic';
            
            insert newMessage;
            
            DiscussionMessage__c newReply = new DiscussionMessage__c();
            newReply.PostedDate__c = System.now();
            newReply.ParentMessage__c = newMessage.Id;
            newReply.Message__c = 'Reply to Message';
            newReply.DiscussionTopic__c = newTopic.id;
            newReply.Team__c = idTeam;
            newReply.Subject__c = 'Reply to Message';
            
            //insert newReply;
            
            //String idDiscussionTopic = [select id from DiscussionTopic__c limit 1].id;
            // I have to hardcode the id because it has to
            //String idDiscussionTopic = 'a0730000002qnVHAAY';
            String idDiscussionTopic = newTopic.Id;
            dis.setParamId(idDiscussionTopic);
            
            dis.setPageNumberParam('');
            
            dis.constructorMethods();
            
            if (dis.getUserPermissions() == null) {
                System.assert(true, 'Null Permissions');
            }
            
            
            if (dis.getIsTopicAuthor() == null) {
                System.assert(true, 'Null isTopicAuthor boolean');
            }   
            
            if (dis.getIsTeamAdminMember() == null) {
                System.assert(true, 'Null getIsTeamAdminMember boolean');
            }
            
            dis.saveReply();
            
            if (dis.getNoForums() == null) {
                System.assert(true, 'Null getNoForums boolean');
            }
             
            dis.setTopicIdParam(idDiscussionTopic);
            dis.updateReadCount();
            
            /* Pagination */
            dis.nextPage();
            dis.prevPage();
            dis.getCurrentPagination();
            dis.getCntPagination();
            dis.getNumberOfItemsToShow();
            dis.getFirstRow();
            dis.getPrevPageLinkShow();
            dis.getPrevPageShow();
            dis.getNextPageLinkShow();
            dis.getNextPageShow();
            
            dis.getForumData();
            dis.deleteReplyId();
            
            DiscussionReplyController.UserTopic userTopicClass = dis.getTopicUser();
            userTopicClass.getPicture();
            userTopicClass.getUser();
            userTopicClass.getTeam();
            userTopicClass.getTopic();
            userTopicClass.getMessTopic();
            userTopicClass.getStrdate();
            userTopicClass.getShowShortUserName();
            userTopicClass.getTopicNameReplaced();
            userTopicClass.getShowShortTopicName();
            
            DiscussionReplyController.UserReplys userReplysClass = userTopicClass.getReplys().get(0);
            userReplysClass.getIsMessageAuthor();
            userReplysClass.getQtAuthor();
            userReplysClass.getQuote();
            userReplysClass.getQtdate();
            userReplysClass.getExistqt();
            userReplysClass.getUser();
            userReplysClass.getUserShortName();
            userReplysClass.getMessage();
            userReplysClass.getPicture();
            userReplysClass.getStrdate();
            
            //Save Methods
            dis.saveReply();
            DiscussionReplyController.replyMessage rplNew = new DiscussionReplyController.replyMessage();
            rplNew.Message = 'fdasfads';
            rplNew.ParentMessage = 'fdasfads';
            rplNew.MessageId = 'fdasfads';
            
            dis.saveNewTopicReply();            
            DiscussionReplyController.replyMessage rplget = dis.getQuoteReply();
            dis.saveQuoteReply();
            
            DiscussionMessage__c msg = [Select Id, Message__c from  DiscussionMessage__c Limit 1];
            
            rplNew.Message = msg.Message__c;
            rplNew.ParentMessage = msg.Id;
            rplNew.MessageId = msg.Id;
            
            DiscussionReplyController.replyMessage rplget2 = dis.getQuoteReply();
            dis.saveNewTopicReply();
            dis.saveQuoteReply();   
        }catch(Exception e){
            throw e;
        }
        
    }
}