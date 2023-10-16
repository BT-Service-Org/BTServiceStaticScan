@IsTest private class TeamsWidgetAnnouncementWideTest {
	public static testMethod void testTeam() {
		try{
			TeamsWidgetAnnouncementWideController team = new TeamsWidgetAnnouncementWideController();
			
			Team__c t = [select Id from Team__c limit 1];
			team.setTeamId(t.Id);
			team.getTeam();
			t = team.getTeamspace();
			
			BlogEntry__c announcement = [select Id, CreatedDate from BlogEntry__c limit 1];
			TeamsWidgetAnnouncementWideController.AnnouncementWrapper annou = new TeamsWidgetAnnouncementWideController.AnnouncementWrapper(announcement);
	    	annou.getFormatedPostDate();
	    	annou.getFormatedPostTime();
	    	annou.getDetail();
	    	team.getRecentAnnouncements();
	    	
		}catch(Exception e){
			throw e;
		}		
	}		
}