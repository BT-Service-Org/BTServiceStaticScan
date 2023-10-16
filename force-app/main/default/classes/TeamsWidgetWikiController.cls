public class TeamsWidgetWikiController {


	Id teamspaceId = System.currentPageReference().getParameters().get('id');
	
	public void setTeamspaceId (Id teamspaceId) {
		this.teamspaceId = teamspaceId;	
	}
	
	public Id getTeamspaceId() {
		return teamspaceId;
	}
	
	public List<WikiPage__c> getWikiPages() {
		List<WikiPage__c> pages = new List<WikiPage__c>();
		if(teamspaceId !=null) {
			pages = [SELECT Name
									   FROM WikiPage__c
									   WHERE Team__c =: teamspaceId
									   ORDER BY LastModifiedDate DESC
									   LIMIT 5];
		}
		return pages;
	}
	
	
	public Integer getWikiPagesSize(){
		List<WikiPage__c> wikis = getWikiPages();
		
		return wikis.size();		
	}

}