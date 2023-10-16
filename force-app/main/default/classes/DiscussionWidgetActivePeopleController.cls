public class DiscussionWidgetActivePeopleController {
	
	public String teamId = '';
	public String url = System.currentPageReference().getUrl();	
	public String idUrl = System.currentPageReference().getParameters().get('id');

	
	/*
	*@construct Default
	*/
	public DiscussionWidgetActivePeopleController(){
		if(url.split('DiscussionDetail').size() < 2)
		{
			teamId = idUrl;
		}
		else 
		{
			DiscussionTopic__c topicTeam = [SELECT Id,	Team__c From DiscussionTopic__c where Id =: idUrl  limit 1];
			teamId = topicTeam.Team__c;
		}
	}
	
	public class Actives {
 		String id;
 		String subject;
 		String name;
 		String picture;
 		String userId;
 		
        public String getName () {
        	return name;
        } 
        
        public String getId () {
        	return id;
        }  
              
        public String getSubject () {
        	return subject;
        } 
        
        public String getPicture () {
        	return picture;
        } 
        
        public String getUserId () {
        	return userId;
        } 
        
        public void setUserId (String userId) {
        	this.userId = userId;
        }
        
        public void setName (String name) {
        	this.name = name;
        }
        public void setId (String id) {
        	this.id = id;
        }   
        public void setSubject (String subject) {
        	Integer subjectLength; 
        	if(subject != null ){
        		subjectLength = subject.length();
        		if(subjectLength > 20) {
        			this.subject = subject.substring(0, 19) + '...' ;
        		}
        		else {
        			this.subject = subject;
        		}
        	}
        	else {
        		this.subject = subject;
        	}
        }
                
        public void setPicture (String userId) {
			String PictureId;
			Integer cntPicture;
			
			cntPicture = [SELECT count() FROM PeopleProfile__c WHERE User__c =:userId];
			
			if (cntPicture != 0) {
				PeopleProfile__c picture = [SELECT Picture__c FROM PeopleProfile__c WHERE User__c =:userId limit 1];
		        if(picture.Picture__c == null || picture.Picture__c == '') {                	                                          	 
			     	PictureId = '';
				} 
				else {
					PictureId = picture.Picture__c;
				} 
			}
			else {
				PictureId = '';
			}
   			this.picture = PictureId ;
   		}    
                                  		
 	
 	}
	
	/*
	*@void
	*/
	public List<Actives> getActivePeople(){
		List<Actives> topics = new List<Actives>();
		// Primary Set to store result values
		Set<String> results = new Set<String>();
		List<DiscussionMessage__c> discussionList = new List<DiscussionMessage__c>();
		System.debug('Param: "' + teamId + '"');
		if(teamId == null || teamId == '' || teamId.length() < 16){
			discussionList = [Select d.PostedDate__c,
								d.PostedBy__c,  
								d.Id, 
								d.DiscussionTopic__r.Subject__c,
								d.DiscussionTopic__r.id,
								d.PostedBy__r.Name,
								d.PostedBy__r.id
								From DiscussionMessage__c d order by PostedDate__c desc limit 5];
		}else{
			discussionList = [Select d.PostedDate__c,
								d.PostedBy__c, 
								d.Id, 
								d.DiscussionTopic__r.Subject__c,
								d.DiscussionTopic__r.id,
								d.PostedBy__r.Name,
								d.PostedBy__r.id
								From DiscussionMessage__c d
								where Team__c =:  teamId
							 	order by PostedDate__c desc limit 5 ];
			
		}
		
		if(discussionList.size() > 0){
			for(DiscussionMessage__c item : discussionList){
				if(!results.contains(item.PostedBy__c)){
					Actives active = new Actives();
					active.setId(item.DiscussionTopic__r.id);	
					active.setName(item.PostedBy__r.Name);
					active.setSubject(item.DiscussionTopic__r.Subject__c);
					active.setPicture(item.PostedBy__c);
					active.setUserId(item.PostedBy__c);
					topics.add(active);
					results.add(item.PostedBy__c);
				} 		
			}
		}				
 		return topics; 	
	}
	
	public Integer getActivePeopleSizeList(){
		Integer size = 0;
		if(getActivePeople() != null){
			size = getActivePeople().size();
		}	
		
		return size;
	}
	
}