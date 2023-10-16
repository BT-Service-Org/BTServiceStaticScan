public class DiscussionWidgetSubTeamsController {
	
	public String teamId = '';
	public String url = System.currentPageReference().getUrl();	
	public String idUrl = System.currentPageReference().getParameters().get('id');
	
	
	public boolean noSubTeams;
	
	public void setTeamId (String teamId) {
		this.teamId = teamId;
	}
	
	/*
	*@construct
	*/
	public DiscussionWidgetSubTeamsController(){
		
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
	
	/*
	*@void
	*/
	public List<subTeams> getSubTeams(){
		return getSubTeam(teamId);
	}

 	public class subTeams {
 		String name;
 		Integer count;
 		String id;
        public String getName () {
        	return name;
        } 
        public String getId () {
        	return id;
        }        
        public Integer getCount () {
        	return count;
        } 
        public void setName (String name) {
        	this.name = name;
        }
        public void setId (String id) {
        	this.id = id;
        }        
        public void setCount (Integer intCount) {
        	//Integer intCount = Integer.valueOf(String.valueOf(Math.roundToLong(countDouble)));
        	this.count = intCount;
        }                              		
 	
 	}
	
	public Integer getCountSubTeams () {
		return 	[Select Id From Team__c where parentTeam__c =: teamId].size();
	}
	
	public List<subTeams> getSubTeam(String teamId){
			
 		List<subTeams> subTeamsCount = new List<subTeams>();
 		
 		for (Team__c item: [Select Name,Id From Team__c where parentTeam__c =: teamId order by CreatedDate desc limit 4]) {
 			subTeams subTeam = new subTeams();
 			Integer count;
 			List<DiscussionTopic__c> msjCount = [SELECT 
						Id, 
						ViewCount__c, 
						Team__c, 
						Team__r.Name,
						Subject__c, 
						Name, 
						MessageCount__c, 
						CreatedBy.Name,
						CreatedBy.Id,
						LastPostedMessage__c, 
						DiscussionForum__c 
						From DiscussionTopic__c where Team__c =: item.Id];
 			subTeam.setCount(msjCount.size());
 			subTeam.setName(item.Name);
 			subTeam.setId(item.Id);
 			subTeamsCount.add(subTeam);		
 		}
 		return subTeamsCount;	
	}
	
}