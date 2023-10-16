public class OverlayNewDiscussionController {
	
	public OverlayNewDiscussionController () {
		genPermissions();
	}
	
	public String TEAMID = System.currentPageReference().getParameters().get('id');
	
	public String getTeamId () {
		return TEAMID;
	}
	
	public DiscussionForum__c getForumData(){
   		
   		DiscussionForum__c team = new DiscussionForum__c();
   		
   		if(TEAMID != null){
   			 try {
   			 	team = [SELECT
   						Team__r.Name, 
   						Team__c,
   						Id 
   						FROM DiscussionForum__c WHERE Team__c =: TEAMID LIMIT 1];
   						
   			 } catch (Exception e) {
   			 	
   			 	System.Debug('\n ///////////////////////////// \n Error , no team assigned \n //////////////////////////// \n The Forum ID is :' + TEAMID + '\n //////////////////////////// \n');
   			 	
   			 }
   			    			 
   		} else {
   			team = null;
   		}
   		return team;
   	}  
   	
   	/* Save the new Topic */
   	public class Topic {
   		public String content = '';
	   	public String id = '';
	   	public String subject = '';
	   	public String forum = '';
	   	
	   	public String getForum () {
	   		return forum;
	   	}
	   	
	   	public void setForum (String forum) {
	   		this.forum = forum;
	   	}
	   		
	   	public String getId() {
	   		return id;
	   	}
	   	
	   	public void setId (String id) {
	   		this.id = id;
	   	}
	   	
	   	public String getContent () {
	   		return content;
	   	}
	   	
	   	public void setContent (String content) {
	   		this.content = content;
	   	}
	   	
	   	public String getSubject () {
	   		return subject;
	   	}
	   	
	   	public void setSubject (String subject) {
	   		this.subject = subject;
	   	}
   	}
   	
   	public Topic newTopic = new Topic();
   	
   	public Topic getNewTopic () {
   		return newTopic;	
   	}
   	
    /* ---------------------------- */
   	/*   	 SHARING RULES			*/
   	/* ---------------------------- */	
	public UserPermissions userPermissions = null;
	
	public void genPermissions () {
		userPermissions = new UserPermissions();
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setTeam(TEAMID);
		userPermissions.setObjectType('Discussion');
		userPermissions.setPermissions();		
	}

	/* ---------------------------- */	
	
   	public void saveNewTopic () {
   		
   		System.debug('\n\n //////////////////////// \n SAVE THIS NEW TOPIC VARS: \n' + newTopic + '\n //////////////////////// \n\n');
   		
   		if(!userPermissions.getCanCreate())
        	throw new CustomException('Insufficient Privileges');
        	
   		if (newTopic.subject != '' && newTopic.forum != '' && newTopic.content != '' && newTopic.content != '<p><br></p>' && newTopic.content != '<p></p>' && newTopic.content != '<p>&nbsp;</p> ') {
	   		DiscussionTopic__c newT = new DiscussionTopic__c();
	   		newT.Subject__c = newTopic.subject;
	   		newT.Team__c = TEAMID;
	   		newT.DiscussionForum__c = newTopic.forum;
	   		
	   		insert newT;
	   		
	   		DiscussionMessage__c firstMessageObj = new DiscussionMessage__c();
	   		firstMessageObj.Discussiontopic__c = newT.Id;
	   		firstMessageObj.Team__c = teamID;
	   		firstMessageObj.Message__c = newTopic.content;
	   		
	   		insert firstMessageObj;
	   		
	   		newT.LastPostedMessage__c = firstMessageObj.id;
	   		update newT;
	   		
	   		newTopic.subject = '';
	   		newTopic.id = '';
	   		newTopic.content = '';
	   		newTopic.forum = '';
   		}
   	}
}