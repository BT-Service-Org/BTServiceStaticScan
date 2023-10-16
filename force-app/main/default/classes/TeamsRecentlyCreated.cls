public with sharing class TeamsRecentlyCreated {

	public TeamsRecentlyCreated(){
		getRecentTeamsList();		
	}	
	
	public List<RecentTeams> recentTeams = new List<RecentTeams>();
	
	public List<RecentTeams> getRecentTeams(){
		return recentTeams;
	} 
	
	/**
	* Get list of recently created teams
	*@void
	*/
	public void getRecentTeamsList (){
		List<Team__c> teams = new List<Team__c>();		
		teams = [select t.Id, t.Name, t.Picture__c, t.TeamCreatedBy__c from Team__c t where TeamCreatedDate__c != null order by t.TeamCreatedDate__c desc limit 5];
		for(Team__c t : teams){
			recentTeams.add(new RecentTeams(t));
		}
	}
	
	public class RecentTeams{
		
		Team__c team;
		String picture = null;
		User createdBy = null;
		
		/**
		* Inner class constructor
		*@param Team__c t
		*/
		public RecentTeams (Team__c t){
			team = t;
			getTeamPicture();
			getCreator();
		}
		
		/**
		*@return Team__c t
		*/
		public Team__c getTeam(){
			return team;
		}
		
		/**
		*@return String s
		*/
		public String getPicture(){
			return picture;
		}
		
		/**
		*@return User s
		*/
		public User getCreatedBy(){
			return createdBy;
		}
		

		/**
		* Get picture for current team
		*@void
		*/
		public void getTeamPicture (){
			/*List<Attachment> at = new List<Attachment>();
			at = [select Id, parentId from Attachment where parentId =: team.Id limit 1];
			if(at.size() > 0)
				picture = '/servlet/servlet.FileDownload?file=' + at[0].Id;*/
			if(team.Picture__c != null) picture = '/servlet/servlet.FileDownload?file=' + team.Picture__c;
		}	
		
		public void getCreator(){
			List<User> u = new List<User>();
			u = [select u.Id, u.Name from User u where u.Id =: team.TeamCreatedBy__c];
			if (u.size() > 0)
				createdby = u[0];
		}
	
	}
}