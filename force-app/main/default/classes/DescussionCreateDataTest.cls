@IsTest private class DescussionCreateDataTest {
  
  public static testMethod void testDiscussion() {
    
    DiscussionCreatedDataController disc = new DiscussionCreatedDataController();
    disc.updateData();
    
    /*List<DiscussionMessage__c> messageList = [select Id, CreatedById, CreatedDate, PostedBy__c, PostedDate__c from DiscussionMessage__c limit 10];
        for (DiscussionMessage__c item: messageList) {
                item.PostedBy__c = item.CreatedById;
                item.PostedDate__c = item.CreatedDate;
        }
        try{
        update messageList;
        } catch (DmlException e) {
            System.assert(false,'No se pudo actualizar el mensaje') ;
        }
            
        List<DiscussionTopic__c> topicList = [select Id, CreatedById, CreatedDate, PostedBy__c, PostedDate__c from DiscussionTopic__c limit 10];
        for (DiscussionTopic__c item: topicList) {
                
                item.PostedBy__c = item.CreatedById;
                System.assert(item.CreatedById==null,'Error Posted by');
                item.PostedDate__c = item.CreatedDate; 
                System.assert(item.CreatedById==null,'Error PostedDate');
        }
        try{
        update topicList;
        }catch (DmlException e) {
        System.assert(false,'No se pudo actualizar los topics') ;
        }
        */
    }
  }