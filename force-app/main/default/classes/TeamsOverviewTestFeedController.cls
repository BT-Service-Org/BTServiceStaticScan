/*public class TeamsOverviewTestFeedController {

}*/
public class TeamsOverviewTestFeedController {

    List<TeamMember__c> teams = new List<TeamMember__c>();
    List<MiniFeeds> minifeeds = new List<MiniFeeds>();    
    
    /*
    * Construct
    */
    public TeamsOverviewTestFeedController(){
    	teams = getMyTeams();
    	if(teams.size() > 0)
    		getFeeds();
    }
    
    /*
    * Getters
    */
    public List<TeamMember__c> getTeams(){
    	return teams;
    }
    
    public List<MiniFeeds> getMinifeeds(){
    	return minifeeds;
    }    
    
    /*
    *@retrun List<TeamMember__c>
    */    
    public List<TeamMember__c> getMyTeams(){
    	return  [Select s.Team__c, s.Team__r.Id, s.Team__r.Name,
	    			Team__r.Description__c, Team__r.CreatedDate 
	                From TeamMember__c s
    				where s.User__c =: UserInfo.getUserId()
    				order by s.CreatedDate desc
    				limit 15
    			];
    }
    
    /**
    *
    */
    public String getTeamspaceImage() {
    	/*List<Attachment> attach = [select Id 
        							from Attachment 
        							where ParentId =:System.currentPageReference().getParameters().get('id')];
        	if(attach.size() == 0) return '';					
        	return '/servlet/servlet.FileDownload?file=' + attach[0].Id;*/
        	List<Team__c> teamAvatar = [select Picture__c
        								from Team__c
        								where Id =:System.currentPageReference().getParameters().get('id')];
        	if(teamAvatar.size() == 0) return '';
        	return '/servlet/servlet.FileDownload?file=' + teamAvatar[0].Picture__c;
    }
    
    
    /*
    *@void
    */
    public void getFeeds(){
    	List<MiniFeed__c> mf = new List<MiniFeed__c>();    	
    	String allFeeds = System.currentPageReference().getParameters().get('isAllFeeds');
    	if(allFeeds != 'true'){
	    	List<String> myTeams = new List<String>();
	    	for(TeamMember__c tm : teams){
	    		if(tm.Team__r.Id != null)
	    			myTeams.add(tm.Team__r.Id); 
	    	}
	
	    	mf = [Select 
	    				m.User__c,
	    				m.User__r.Name, 
	    				m.Type__c, 
	    				m.Message__c, 
	    				m.Id, 
	    				m.CreatedDate 
	    				from MiniFeed__c m
	    				where Team__c in:myTeams
	    				order by m.FeedDate__c desc
	    				limit 25];
    	}else{
	    	mf = [Select 
	    				m.User__c,
	    				m.User__r.Name, 
	    				m.Type__c, 
	    				m.Message__c, 
	    				m.Id, 
	    				m.CreatedDate 
	    				from MiniFeed__c m
	    				order by m.FeedDate__c desc
	    				limit 25];    		
    	}
    	
    	minifeeds.clear();
    	for(MiniFeed__c m : mf){
    		MiniFeeds minif = new MiniFeeds(m);
    		minifeeds.add(minif);
    	}
    }


    /*
    *@class
    */
    public class MiniFeeds {
    	
    	MiniFeed__c feed = null;
    	String formatedDate = null;
    	//nuevo
    	public String TypeOfFeed;
    	public String User;
    	public String Name;
    	public String Message;
    	
    	public String getTypeOfFeed() {
        		return TypeOfFeed;
		}
		
		public String getUser() {
                return User;
        }
    	
    	public String getName() {
                return Name;
        }
        
        public String getMessage() {		
                return Message;
        }
    	//
    	/**
    	*@param MiniFeed__c
    	*/
    	public MiniFeeds(MiniFeed__c m){
    		//nuevo
    		Name = m.User__r.Name;
    		User = m.User__c;
    		TypeOfFeed = m.Type__c;
    		Message = m.Message__c;
    		//
    		feed = m;
    	}
    	
    	public MiniFeed__c getFeed(){
    		return feed;
    	}
    	
    	public String getFormatedDate(){
    		return feed.CreatedDate.format('MMMM dd, yyyy HH:mm');
    	}		
    }
}