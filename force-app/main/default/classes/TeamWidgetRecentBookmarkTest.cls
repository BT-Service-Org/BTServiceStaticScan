@IsTest private class TeamWidgetRecentBookmarkTest {
	public static testMethod void testTeam() {
		try{	
			TeamWidgetRecentBookmarkController team = new TeamWidgetRecentBookmarkController();
			List<Bookmark__c> listBookmarks= team.getBookmarks();
		    Boolean privilege = team.getnewPrivileges();
		}catch(Exception e){
			throw e;
		}
	}
}