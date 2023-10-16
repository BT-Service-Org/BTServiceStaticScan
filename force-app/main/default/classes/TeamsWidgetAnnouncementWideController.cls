public class TeamsWidgetAnnouncementWideController {
	
	Team__c teamspace;
	public String teamId = System.currentPageReference().getParameters().get('id');
	
	public void setTeamId(String s){
		teamId = s;
	}
	
	public TeamsWidgetAnnouncementWideController() {
		if(teamId != null)
			getTeam();
	}
	
	public void getTeam(){
		teamspace = [select Name from Team__c where Id =: teamId];	
	}
	
	public Team__c getTeamspace() { 
		return teamspace;
	}
	
	public List<AnnouncementWrapper> getRecentAnnouncements() {
				
		List<AnnouncementWrapper> announcements = new List<AnnouncementWrapper>();
		
		// get list
		for(BlogEntry__c a: [SELECT Title__c,
									   Team__c,
									   Message__c,
							  		   CreatedDate,
							  		   CreatedById							  									  			
					   			 FROM BlogEntry__c
					   			 WHERE Team__c =: teamspace.Id
					   			 ORDER BY CreatedDate DESC
					             LIMIT 5]) {
			announcements.add(new AnnouncementWrapper(a)); 	
		}
				

		return announcements;
	}
	
	public class AnnouncementWrapper {
		
		BlogEntry__c announcement;
		
		public AnnouncementWrapper (BlogEntry__c a) {
			announcement = a;
		}
		
		public String getFormatedPostDate() {
			return announcement.CreatedDate.format('MMMM dd, yyyy');
		}
		
		public String getFormatedPostTime() {
			return announcement.CreatedDate.format('hh:mm aaa');
		}
		
		public BlogEntry__c getDetail() {
			return announcement;
		}
	}
}