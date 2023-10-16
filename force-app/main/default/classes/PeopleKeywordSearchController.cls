public class PeopleKeywordSearchController{	

	//Generate Instance of PaginatorController Class
	protected PaginatorController paginator = new PaginatorController();
	protected String title;
	protected boolean myPeople = false;
	
	//User Id 
	protected String userId = Userinfo.getUserId();
	
	public void setUserId(String sUserid){
		userId = sUserid;
	}
	
	public Integer SizeList = 0;
	
	// Primary Set to store result values
	public Set<String> results = new Set<String>();
	
	//@@ Get Parameters      
	public String getParam(String nameParam){
		return System.currentPageReference().getParameters().get(nameParam);
	}
        
    //@@ Like Parameters 
    public String likeParam(String nameParam){
                    return '%' + nameParam + '%';
    }
       
    //@@ Parameter is empty        
    public boolean paramIsEmpty(String parameterName) {

		String parameterValue = getParam(parameterName);

		boolean emptyParam = false;
        	if (parameterValue == null) {
            	emptyParam = true;
        	} else {
            	if (parameterValue.equals('')) {
                	emptyParam = true;
                	}
        	}
        	return emptyParam;
    }
    
	
	/* -------- */
   	/*  SETTERS */
   	/* -------- */
	
	
	//Set Size of List
	public Void setSizeList(Integer size)
	{
		SizeList = size;
	}


	
	//GET Generic List of Pepole Profile
	
	List<PeopleSearchResultItem> searchResultsItems = new List<PeopleSearchResultItem>();
	
	public List<PeopleSearchResultItem> getPeople()
	{
		return searchResultsItems;
	}
	
	//GET Instance of Class PaginatorController
	public PaginatorController getPaginator()
	{
		return paginator;
	}
	
	//GET Size of List
	public Integer getSizeList()
	{
		return SizeList;
	}
	
	
	//Constructor Default
	public PeopleKeywordSearchController() {
		ResultCore('Search');	
	}
	
	/* ---------------------------- */
   	/*  Public Atributes for Layout */
   	/* ---------------------------- */
   	// Get Tilte for page.
   	public String getTitle () 
   	{
   		return title;
   	}
   	
   	
   	public static final String KEYWORD = 'keyword';	
	
	public String getKeyword(){
		return getParam(KEYWORD);
	}
	
	public String typeAction = 'Search';
	
	public String getTypeAction(){
		return typeAction;
	}
	
   	/* ------------ */
   	/*  Result Core */
   	/* ------------ */
	//List of Users 
	List<User> result = new List<User>();
	
	String keywordString = '';
	
	public void setKeywordString (String sKey){ 
		keywordString = sKey;
	} 
	
	//ResultCore()
	// @String type { result binding} 
	public void ResultCore(String TypeA)
	{
			
		if(!(paramIsEmpty(KEYWORD))){
			keywordString = System.currentPageReference().getParameters().get('keyword');
		}
		TypeA = 'Search';
		if(userId == null)
		{
			userId = Userinfo.getUserId();
			myPeople = true;
		}
	 	
 		// Declarations
       	List<User> nameSearch = new List<User>();
       	List<User> allUsers = new List<User>();
    	List<EmploymentHistory__c> formerJobSearch = new List<EmploymentHistory__c>(); 
    	List<EducationHistory__c> collegeSearch = new List<EducationHistory__c>();
    	List<UserCompetencies__c> competencySearch = new List<UserCompetencies__c>();
    	List<TeamMember__c> teamspaceSearch = new List<TeamMember__c>();		
			
		// Search lists
		if(keywordString != ''){
			
			nameSearch = [select id from User WHERE Name LIKE :likeParam(keywordString)];		        	
	    	formerJobSearch = [select User__c from EmploymentHistory__c WHERE Employer__r.Name LIKE :likeParam(keywordString) ];
	    	collegeSearch = [select User__c from EducationHistory__c WHERE School__r.Name LIKE :likeParam(keywordString) ];
	    	competencySearch = [select User__c from UserCompetencies__c WHERE Competency__r.Name LIKE :likeParam(keywordString) ];
	    	teamspaceSearch = [select User__c from TeamMember__c WHERE Team__r.Name LIKE :likeParam(keywordString) ];
			
			
			if(nameSearch.size() > 0 ) {
	        	for(User userId:nameSearch){
	        		results.add(userId.id);
	        	}
        	}
        
			/// Former Job List ////
	        	       		
			if(formerJobSearch.size() > 0){
	        	for(EmploymentHistory__c userId:formerJobSearch){        		
	        			results.add(userId.User__c);        		 		
	        	}        	 			
			}	        		

	    	/// College List ///
	    	
       		if(collegeSearch.size() > 0){    			
        		for(EducationHistory__c userId:collegeSearch){	        		
	        			results.add(userId.User__c);	        		  		
	        	} 	        
    		}

	    	/// Competency List ///
    		if(competencySearch.size() > 0){    		
	        	for(UserCompetencies__c userId:competencySearch){	        		
	        			results.add(userId.User__c);	        				
	        	} 	        	
    		}
	    	    	
	    	/// Teamspace List ///
			if(teamspaceSearch.size() > 0){			
	    		for(TeamMember__c userId:teamspaceSearch){        	
	        			results.add(userId.User__c);        		 		
	        	}         	
			}

		} else {
			
			// Get all users, no keyword given
			allusers = [SELECT Id FROM User];
			
			for(User userId:allusers){        	
	        		results.add(userId.Id);        		 		
	        	}
		
		}
			
		List<Id> users = new List<Id>();
		// Convert the Set to a list for Pagination	
		for(String r:results){
			users.add(r);			
		}	
				
		result = [Select u.Title, 
						u.Phone, 
						u.Name, 
						u.Id, 
						u.Email, 
						u.Division, 
						u.Department, 
						u.CompanyName, 
						(Select AboutMe__c, Aol__c, Picture__c, Skype__c, YahooIM__c, isPrivate__c From People__r) 
						From User u where u.Id in : users and u.IsActive = true order by u.Name asc];
		 
		List<Team__c> commonTeams = [Select t.Name, (Select id, User__c, Team__c From TeamMembers__r where User__c =:UserInfo.getUserId() or User__c in: result) From Team__c t];
		// Add the values to the list
		for(User u:result){
			PeopleSearchResultItem item = new PeopleSearchResultItem();
			item.Id = u.Id;
			item.Name = u.Name;
			item.Title = u.Title;
			item.Phone = u.Phone;
			item.Email = u.Email;
			item.Division = u.Division;
			item.Department = u.Department;
			item.CompanyName = u.CompanyName;
			if(u.People__r.size() > 0){
				// Display Profile Information
				Boolean findJoinTeam = false;
				Integer countTeam = 0;
				if (u.People__r[0].isPrivate__c && u.Id != UserInfo.getUserId()) {
					while (!findJoinTeam && countTeam < commonTeams.size()) {
						System.debug('\n\n////////////////////////////////////////////\n COMMON TEAMS - CURRENT MEMBERS : '+ commonTeams[countTeam].TeamMembers__r + '\n//////////////////////////////\n\n');
						Integer countTeamMembers = 0;
						for (TeamMember__c iterTeamMember : commonTeams[countTeam].TeamMembers__r) {
							if (iterTeamMember.User__c == u.Id || iterTeamMember.User__c == UserInfo.getUserId()) {
								countTeamMembers++;
							}
						}
						System.debug('\n\n////////////////////////////////////////////\n COMMON TEAMS - CURRENT MEMBERS COUNT: '+ countTeamMembers + '\n//////////////////////////////\n\n');
						if (countTeamMembers > 1) {
							findJoinTeam = true;	
						}
						else {
							countTeam++;
						}
					}
				}
				System.debug('\n\n////////////////////////////////////////////\n COMMON TEAMS BOOLEANS: \nFind Join Team: '+ findJoinTeam + '\nIs Owner Profile: ' + (u.Id == UserInfo.getUserId()) + '\nIs Private Profile: ' + u.People__r[0].isPrivate__c  + '\n//////////////////////////////\n\n');
				if (!u.People__r[0].isPrivate__c || findJoinTeam || u.Id == UserInfo.getUserId()) {
					item.isPrivate = false;
				}
				else {
					if (!u.People__r[0].isPrivate__c) {
						item.isPrivate = false;	
					}
					else {
						item.isPrivate = true;		
					}
				}
				
				item.AboutMe = u.People__r[0].Aboutme__c;
				item.Aol = u.People__r[0].Aol__c;
				item.Skype = u.People__r[0].Skype__c;
				item.Yahoo = u.People__r[0].YahooIM__c;
				item.Picture = u.People__r[0].Picture__c;
			}
			searchResultsItems.add(item);	
		}
							
		 	//Set the Values of Paginator
		 	setSizeList(result.size());
		 	paginator.serTotalItemsNumber(result.size());
		 	paginator.genCntPagination();
		 	
		 	title = 'Search Results from People';	 	
	   		
	 	}
	 	
	 	/**
	 	* inner class to store user profile data
	 	* @return String Id
	 	* @return String Title
	 	* @return String Phone
	 	* @return String Name
	 	* @return String Email
	 	* @return String Division
	 	* @return String Department
	 	* @return String CompanyName
	 	* @return String AboutMe
	 	* @return String Aol
	 	* @return String Picture
	 	* @return String Skype
	 	* @return String Yahoo
	 	*/	 	
	 	public class PeopleSearchResultItem {	 		
	 		public String Id { get; set; }
	 		public Boolean isPrivate { get; set; }
			public String Title { get; set; }
			public String Phone { get; set; }
			public String Name { get; set; }
			public String Email { get; set; }
			public String Division { get; set; }
			public String Department { get; set; }
			public String CompanyName { get; set; }
			public String AboutMe { get; set; }
			public String Aol { get; set; }
			public String Picture { get; set; }
			public String Skype { get; set; }
			public String Yahoo { get; set; }		   	
	 	}
	 	
}