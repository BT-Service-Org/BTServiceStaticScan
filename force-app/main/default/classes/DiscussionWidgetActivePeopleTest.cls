@IsTest private class DiscussionWidgetActivePeopleTest {

    public static testMethod void testDiscussion() {
        try{
            DiscussionWidgetActivePeopleController dis = new DiscussionWidgetActivePeopleController(); 
            
            DiscussionWidgetActivePeopleController.Actives actives = new  DiscussionWidgetActivePeopleController.Actives();
            List<DiscussionWidgetActivePeopleController.Actives> listActives = dis.getActivePeople();

            String aName = actives.getName();
            String aId = actives.getId();
            String pic = actives.getPicture();
            String userId = actives.getUserId();
            actives.setUserId('');
            actives.setSubject('Subject');
            
            Integer sizeList = dis.getActivePeopleSizeList();
        
        }catch(Exception e){
            throw e;            
        }
    }
}