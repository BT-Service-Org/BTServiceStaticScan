public class TeamsWidgetRecentAnnouncementController {
	
	public Id teamspaceId;
	
	public TeamsWidgetRecentAnnouncementController() {
		teamspaceId = System.currentPageReference().getParameters().get('id');
	}
	
	public void setTeamspaceId(String s){
		teamspaceId = s;
	}
	
	public Id getTeamspaceId() {
		return teamspaceId;
	}
	
	public List<BlogEntry__c> getRecentAnnouncements() {
		if(teamspaceId == null) 
			return new List<BlogEntry__c>();
		List<BlogEntry__c> announcements = [select Title__c
									   		   from BlogEntry__c
									   		   where Team__c =: teamspaceId
									  		   order by CreatedDate desc
									   		   limit 5];
		return announcements;
	}

}