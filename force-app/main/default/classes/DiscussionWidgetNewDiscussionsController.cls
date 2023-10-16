public class DiscussionWidgetNewDiscussionsController {


	public class Topics {
		String id;
 		String subject;
	
		public String getId () {
        	return id;
        }  
        
        public String getSubject () {
        	return subject;
        }  
              
        public void setSubject(String subject) {
        	Integer subjectLength; 

        	if(subject != null && subject != '' ){
        		subjectLength = subject.length();
        		if(subjectLength > 20) {
        			this.subject = subject.substring(0, 19) + '...' ;
        		}
        		else {
        			this.subject = subject;
        		}
        	}
        	else {
        		this.subject = null;
        	} 	
        } 
     
        
        public void setId (String Id) {
        	this.id = Id;
        }
	}
	
	public List<Topics> getNewDiscussionTopics() {
		
    	List<DiscussionTopic__c> newDiscussionTopics = new List<DiscussionTopic__c>();

		newDiscussionTopics = [SELECT Subject__c, Id
			   			  FROM DiscussionTopic__c
			   			  ORDER BY PostedDate__c DESC
			              LIMIT 5];	
			              
		List<Topics> topicsRes = new List<Topics>();
		
		for(DiscussionTopic__c item : newDiscussionTopics){
				
			Topics myTopic = new Topics();
			myTopic.setId(item.Id);	
			myTopic.setSubject(item.Subject__c);
			topicsRes.add(myTopic);
				 		
			}
			
		return topicsRes;
		
		
		
		
	}
	
}