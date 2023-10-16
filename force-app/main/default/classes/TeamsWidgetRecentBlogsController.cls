public class TeamsWidgetRecentBlogsController {
  // Get Team Id Attribute
	
	String teamIdBlog;
	
	// Setter method for Team Id variable
	public void setTeamIdBlog(String tID) {
		teamIdBlog = tID;		
	}
	
	public String getTeamIdBlog(){
		return teamIdBlog;
	}
  
  	 Integer blogCount;
  	 String userId = UserInfo.getUserId();
  
     public List<BlogEntry__c> getBlogs() {
	    List<BlogEntry__c> myBlogs = new List<BlogEntry__c>();	
		myBlogs =  [Select  b.Title__c, 
					b.Team__c, 
					b.Id,
					b.PublishedDate__c, 
					b.PostedBy__r.Name, 
					b.PostedBy__r.Id,
					b.PostedBy__c, 
					b.CommentCount__c 
					From 
					BlogEntry__c b where b.PublishedDate__c != null and b.Team__c =: teamIdBlog
					order by b.PublishedDate__c  
					desc limit 8
						];
						
		
		blogCount = myBlogs.size();
		
    	return myBlogs;
    } 
    
    public Boolean getnewPrivileges() {
    	List<TeamMember__c> tm = new List<TeamMember__c>();	
    	tm  = [Select 
    					t.User__c, 
    					t.Team__c, 
    					t.TeamProfile__r.CreateBlogs__c, 
    					t.TeamProfile__c From TeamMember__c t 
    					where t.Team__c =: teamIdBlog and t.User__c =: userId ];
		Boolean result;
		if(tm.size() > 0){
			result = tm[0].TeamProfile__r.CreateBlogs__c;
			return result;
		} else {
			return false;
		}
    }
    
     public Integer getblogCount(){
	        return blogCount;
    }
    
    public void setblogCount(Integer count){
    	blogCount = count;
    	
    }
	       
    					
}