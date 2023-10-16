public with sharing class TeamsWidgetActiveDiscussionsController {
	
		String teamId;
		
		// Setter method for Team Id variable
		public void setTeamId(String id) {
			teamId = id;			
		}
		
		// Get Team Id Attribute
		public String getTeamId(){
			return teamId;
		}

		Integer actdisSize;
		
		String userId = UserInfo.getUserId();
		
		
		
		public TeamsWidgetActiveDiscussionsController() {
		}

		/* ---------------------------- */
	   	/*   	 SHARING RULES			*/
	   	/* ---------------------------- */	
		public UserPermissions userPermissions;
		
		public void genPermissions () {
			userPermissions = new UserPermissions();
			userPermissions.setId(UserInfo.getUserId());
			userPermissions.setTeam(teamId);
			userPermissions.setObjectType('Discussion');
			userPermissions.setPermissions();					
		}
		
		public UserPermissions getUserPermissions () {
			
			// temp bug fix for now.  For some reason the teamId is coming through null when this is called from the contructor
			// This is strange b/c every other widget works this way.   Needs more research
			if(userPermissions == null ) genPermissions();
			
			return userPermissions;
		}
	
		/* ---------------------------- */	
		
		 List<DiscussionTopic__c> discussions = new List<DiscussionTopic__c>();
		
		public void refresh(){
			discussions = [ SELECT ViewCount__c, 
								   Subject__c, 
								   OwnerId, 
								   Name, 
								   MessageCount__c, 
								   PostedDate__c, 
								   PostedBy__r.Name,
								   LastPostedMessage__r.PostedDate__c,
								   LastPostedMessage__r.PostedBy__r.Name
							FROM DiscussionTopic__c d
							WHERE Team__c =: teamId
							ORDER BY d.CreatedDate desc LIMIT 4
							];
			
			actdisSize = discussions.size();
		}
		
	
		public List<Discussion> getDiscussions(){
			
		   

			discussions = [ SELECT ViewCount__c, 
								   Subject__c, 
								   OwnerId, 
								   Name, 
								   MessageCount__c, 
								   PostedDate__c, 
								   PostedBy__r.Name,
								   LastPostedMessage__r.PostedDate__c,
								   LastPostedMessage__r.PostedBy__r.Name
							FROM DiscussionTopic__c d
							WHERE Team__c =: teamId
							ORDER BY d.CreatedDate desc LIMIT 4
							];
			
			actdisSize = discussions.size();
											
			List<Discussion> retDisc = new List<Discussion>();
			if(discussions.size() > 0) {
				for(DiscussionTopic__c d: discussions) {
					Discussion di = new Discussion(d);
					retDisc.add(di);					
				}
			}
			return retDisc;
		}
		
		public Integer getActiveDiscussionsSize(){
			return discussions.size();
		}
		
		public class Discussion{
			DiscussionTopic__c discussion;
			String author;
			Id authorId;
			String authorPicture;
			String lastReply;
			Integer views;
			Integer replies;
			Id replierId;
			String replierName;
			String lastPostDate;
			
			public Discussion(DiscussionTopic__c dis){
				
				discussion = dis;
				
				Datetime aux;
				views = dis.ViewCount__c.intValue();
				replies = dis.MessageCount__c.intValue();
				authorId = dis.PostedBy__c;
				author = dis.PostedBy__r.Name;

				if(discussion.LastPostedMessage__r.PostedBy__c == null){
						lastReply += '';
						authorPicture = '';
				}
				else {
					aux = discussion.LastPostedMessage__r.PostedDate__c;
												
					lastPostDate = formatDateToText(aux) + ' at ' + aux.format('hh:mm a');
						
					replierId = discussion.LastPostedMessage__r.PostedBy__c;

					replierName = discussion.LastPostedMessage__r.PostedBy__r.Name;
				}					

			}
			
			public DiscussionTopic__c getDiscussion(){
				return discussion;
			}
			
			public String getAuthor(){
				return author;
			}
			
			public Id getAuthorId(){
				return authorId;	
			}
			
			public String getLastPostDate(){
				return lastPostDate;
			}
						
			public String getLastReply(){
				return lastReply;
			}
			
			public Id getLastReplyAuthorId(){
				return replierId;
			}
			
			public String getLastReplyAuthor(){
				return replierName;
			}
			
			public String getAuthorPicture(){
				return authorPicture;
			}
			
			public Integer getViews(){
				return views;
			}
			
			public Integer getReplies(){
				return replies;
			}
			
			public String formatDateToText(Datetime d){
				DateTime now = System.now();
				String res = '';
				
				if(d.day() == now.day()){
					res = 'Today ';
				}else if(d.day() == (now.day() - 1)){
					res = 'Yesterday';
				}else{
					res = d.format('EEEE');
				}
				return res;
			}
			
		}

}