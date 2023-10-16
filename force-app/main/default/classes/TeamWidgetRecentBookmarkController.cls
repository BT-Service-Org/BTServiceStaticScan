public class TeamWidgetRecentBookmarkController {
	// Get Team Id Attribute
	
	String teamIdBook;
	
	// Setter method for Team Id variable
	public void setTeamIdBook(String tID) {
		teamIdBook = tID;		
	}
	
	public String getTeamIdBook(){
		return teamIdBook;
	}
  
  	 Integer BookmarksCount;
  	 String userId = UserInfo.getUserId();
  
     public List<Bookmark__c> getBookmarks() {
	    List<Bookmark__c> myBookmarks = new List<Bookmark__c>();	
		myBookmarks =  [Select  b.Title__c, 
								b.PostedDate__c, 
								b.CreatedBy.Name, 
								b.CreatedBy.Id, 
								b.CreatedById ,
								b.Team__c
						From 
								Bookmark__c b
						where 	b.Team__c =: teamIdBook
						order by b.PostedDate__c desc
						limit 8
						];
						
						
		
		
		BookmarksCount = myBookmarks.size();
    	return myBookmarks;
    } 
    
     public Integer getBookmarksCount(){
	        return BookmarksCount;
    }
    
    public void setblogCount(Integer count){
    	BookmarksCount = count;
    	
    }
	
	//Boolean for previlieges to create
	  public Boolean getnewPrivileges() {
    	List<TeamMember__c> tm = new List<TeamMember__c>();	
    	tm  = [Select 
    					t.User__c, 
    					t.Team__c, 
    					t.TeamProfile__r.CreateBookmarks__c, 
    					t.TeamProfile__c From TeamMember__c t 
    					where t.Team__c =: teamIdBook and t.User__c =: userId ];
		Boolean result;
		if(tm == null){
			result = false;
			return result;
		}
		else {
			result = tm[0].TeamProfile__r.CreateBookmarks__c;
			return result;
		}
    }       
    					
}