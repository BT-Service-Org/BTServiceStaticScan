@IsTest private class DiscussionWidgetNewDiscussionsTest {

    public static testMethod void testDiscussion() {
        try{
            DiscussionWidgetNewDiscussionsController dis = new DiscussionWidgetNewDiscussionsController();
            List<DiscussionWidgetNewDiscussionsController.Topics> topics = dis.getNewDiscussionTopics();
            DiscussionWidgetNewDiscussionsController.Topics topic = new DiscussionWidgetNewDiscussionsController.Topics();
            String id = topic.getId();
            String subject = topic.getSubject();
        }catch(Exception e){
            throw e;
        }
    }   
}