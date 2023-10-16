public with sharing class RecentTeamsMemberJoinedController {

	
	public RecentTeamsMemberJoinedController(){
		getRecentTeamsMemberJoined();
	}

	public List<RecentlyTeams> recentTeams = new List<RecentlyTeams>();
	
	public Set<String> uniqueTeams = new Set<String>();
	
	public List<RecentlyTeams> getRecentTeams(){
		return recentTeams;
	}

	/**
	* Get Recent teams members joined by my teams members
	*@void
	*/
	public void getRecentTeamsMemberJoined(){
    	List<TeamMember__c> members = new List<TeamMember__c>();
    	members = [SELECT s.Team__r.Id, 
    					  s.Team__r.Name, 
    					  User__c
	               FROM TeamMember__c s
    			   WHERE s.User__c =: UserInfo.getUserId()
    			   AND Team__c != null];
    				
    				
    	System.debug('1 members.size()' + members.size());
    	
    	if(members.size() > 0){
	    	Set<Id> myTeams = new Set<Id>();
	    	for(TeamMember__c tm : members){
	    		myTeams.add(tm.Team__c);
	    	}
 					
			members.clear();
		
			members = [select User__c 
						from TeamMember__c 
						where Team__c IN : myTeams];
						
			System.debug('2 members.size()' + members.size());
    	    
    	    // Collect each user
    	    Set<Id> users = new Set<Id>();
    	    for(TeamMember__c tm: members) {
    	    	users.add(tm.User__c);
    	    }
    				    				
    		members.clear();
		
			members = [select Team__c, Team__r.Id, Team__r.Name, Team__r.TeamCreatedBy__c, Team__r.Picture__c, User__c 
						from TeamMember__c 
						where User__c IN : users
						AND User__c !=:UserInfo.getUserId() 
						order by CreatedDate DESC];
						
			Integer count = 0;
						
			for(TeamMember__c tm : members){
				if(!uniqueTeams.contains(tm.Team__r.Id)){
					recentTeams.add(new RecentlyTeams(tm.Team__r));
					uniqueTeams.add(tm.Team__r.Id);
					count++;
				}
				if(count == 5) break;
			}
			System.debug('count' + count);

			uniqueTeams = null;
		}
		
	}
	
	/**
	*@class
	*/
	public class RecentlyTeams{
		
		Team__c team;
		String picture = null;
		User createdby = null;
		
		/**
		* Inner class constructor
		*@param Team__c t
		*/
		public RecentlyTeams (Team__c t){
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
		*@return String s
		*/
		public User getCreatedby(){
			return createdby;
		}
		
		/**
		* Get picture for current team
		*@void
		*/
		public void getTeamPicture (){
			/*List<Attachment> at = new List<Attachment>();
			if(team != null)
			{
				at = [select Id, parentId from Attachment where parentId =: team.Id limit 1];
				if(at.size() > 0) picture = '/servlet/servlet.FileDownload?file=' + at[0].Id;
			}*/
			if(team.Picture__c != null) picture = '/servlet/servlet.FileDownload?file=' + team.Picture__c;
		}
		
		/**
		* Get team creator
		*@void
		*/
		public void getCreator(){
			List<User> u = new List<User>();
			if(team != null && team.TeamCreatedBy__c != null)
			{
				u = [select u.Id, u.Name from User u where u.Id =: team.TeamCreatedBy__c];
				if (u.size() > 0) createdby = u[0];
			}
		}
	
	}	

}