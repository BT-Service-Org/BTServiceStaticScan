public class TeamsWidgetRecentBookmarkController {

	public Id teamspaceId;
	
	public TeamsWidgetRecentBookmarkController() {
		teamspaceId = System.currentPageReference().getParameters().get('id');
	}
	
	public void setTeamspaceId(String s){
		teamspaceId = s;
	}
	
	public Id getTeamspaceId() {
		return teamspaceId;
	}
	
	public List<Bookmark__c> getRecentBookmarks() {
		if(teamspaceId == null) 
			return new List<Bookmark__c>();
		List<Bookmark__c> bookmarks = new List<Bookmark__c>();
		try { 
			bookmarks = [SELECT Title__c
										   FROM Bookmark__c
										   WHERE Team__c =: teamspaceId
										   ORDER BY CreatedDate DESC
										   LIMIT 5];
		} catch(Exception e){
			System.debug('\n ////////////////////////////////////////// \n ' + e);		
		}
		if(bookmarks.size() > 0){
			return bookmarks;
		} else {
			return new List<Bookmark__c>();
		}
	}

}