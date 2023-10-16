public class PeopleOverviewController {
	
	// Send current time (aprox)
	//  	
	public String getCurrentTime(){
		Datetime now = (System.now()).addHours(7);
		String s1 = now.format('yyyy-MM-dd');
		String s2 = now.format('HH:mm:ss.SSS');
		String dateString = s1 + 'T' + s2 + 'Z';
		return dateString;
	}
	
	// Constructor		 
	public PeopleOverviewController(){}
	
	/**
	* Check if people profile exist for current user
	*@return PageReference
	*/
	public PageReference profileExist(){
		PageReference pr = null;
		List<PeopleProfile__c> profiles = new List<PeopleProfile__c>();
		profiles = getPeopleProfile();
		if(profiles.size() == 0){
			PeopleProfile__c profile = new PeopleProfile__c();
			profile.User__c = UserInfo.getUserId();
			profile.Name = UserInfo.getName();
			insert profile;
		}
		return pr;
	}
	
	/**
	* Get people profile for current user
	*@return List<PeopleProfile__c>
	*/
	public List<PeopleProfile__c> getPeopleProfile(){
		List<PeopleProfile__c> profiles = new List<PeopleProfile__c>();			
		profiles = [SELECT Id,  Status__c, Picture__c, StatusLastModifiedDate__c
		     		FROM PeopleProfile__c
		     		WHERE User__c =: UserInfo.getUserId()];
		return profiles;	
	}
				
	//####################################//
	// New Faces
	//####################################//
	
	public List<People> getNewFaces(){
		
 		List<PeopleProfile__c> tempList = [SELECT Id,
 												User__c,
                                                User__r.Name,
                                                User__r.Division,
                                                User__r.Department,                                                
                                                User__r.Title,
                                                Picture__c,                                               
                                                CreatedDate                                                
                                        		FROM PeopleProfile__c
                                         		ORDER BY User__r.CreatedDate DESC LIMIT 5 ];
                                         		
        List<People> newPeopleList = new List<People>();
        
		for(PeopleProfile__c p: tempList){
			People person = new People();
			person.setUserId(p.User__c);
			person.setUsername(p.User__r.Name);
			person.setDivision(p.User__r.Division);
			person.setDepartment(p.User__r.Department);
			person.setTitle(p.User__r.Title);
			if((p.Picture__c == '') || (p.Picture__c == null)){
				person.setImageId('');
			} else{
				person.setImageId(p.Picture__c);
			}          
			newPeopleList.add(person);
		}
		
		return newPeopleList;
		
	}
	
	public class People {
		
		String UserId;
        String Username;
        String Division;
        String Department;
        String Title;
        String ImageId;	
		
		public String getUserId() {
            return UserId;
        }
        
        public void setUserId(String UserId) {
            this.UserId = UserId;
        }		
		
        public String getUsername() {
            return Username;
        }
        
        public void setUsername(String Username) {
            this.Username = Username;
        }
        
        
        public String getDivision() {
            return Division;
        }
        
        public void setDivision(String Division) {
            this.Division = Division;
        }
        
        public String getDepartment() {
            return Department;
        }
        
        public void setDepartment(String Department) {
            this.Department = Department;
        }
        
        public String getTitle() {
            return Title;
        }
        
        public void setTitle(String Title) {
            this.Title = Title;
        }
		
		public String getImageId() {
            return ImageId;
        }
        
        public void setImageId(String ImageId) {
            this.ImageId = ImageId;
        }
		
       
    }
	
	//####################################//
	// People Keyword Search 
	//####################################//
	
	//Search Result Page 
    private static String PEOPLE_SEARCH_RESULTS_PAGE = '/apex/PeopleKeywordSearchResults';
    
    //Search Object Initialization
    PeopleSearch peopleSearchObj = new PeopleSearch();    
    
    public PeopleSearch getPeopleSearchObj (){
                return peopleSearchObj;
   	}
        
    public PageReference findPeople() {
            PageReference pageRef = new PageReference(PEOPLE_SEARCH_RESULTS_PAGE
                          							+ '?keyword=' + peopleSearchObj.getKeyword());
            pageRef.setRedirect(true);
            return pageRef;
    }
          
	public class PeopleSearch {
	        
	        String Keyword;       
	
	        public String getKeyword() {
	                return Keyword;
	        }
	
	        public void setKeyword(String Keyword) {
	                this.Keyword = Keyword;
	        }        
	                       
	}
	
	//####################################//
	// Tag Clouds 
	//####################################//
	
	// Competencies Cloud
	public List<CloudItems> getCompetenciesCloud(){
		List<CloudItems> competencyCloud = generateCloud('Competency');
		return competencyCloud;		
		}
		
	// Former Companies Cloud
	public List<CloudItems> getFormerCompaniesCloud(){
		List<CloudItems> competencyCloud = generateCloud('Employer');
		return competencyCloud;		
		}
	
	// Colleges Cloud
	public List<CloudItems> getCollegesCloud(){
		List<CloudItems> competencyCloud = generateCloud('School');
		return competencyCloud;		
		}
	
	
	public List<CloudItems> generateCloud(String CloudType){
		
		// Build the list 
		List<CloudItems> queryResults = new List<CloudItems>(); 
		
		if(CloudType == 'Employer'){
			List<Employer__c> l = new List<Employer__c>();
			// Select the values from database
			l = [Select Name, Count__c From Employer__c ORDER BY Count__c DESC LIMIT 15];
			for(Employer__c e: l){
				CloudItems c = new CloudItems();
				c.setName(e.Name);
				c.setCount(e.Count__c);
				queryResults.add(c);
			}
		}
		
		if(CloudType == 'School'){
			List<School__c> l = new List<School__c>();
			// Select the values from database
			l = [Select Name, Count__c From School__c ORDER BY Count__c DESC LIMIT 15];
			for(School__c e: l){
				CloudItems c = new CloudItems();
				c.setName(e.Name);
				c.setCount(e.Count__c);
				queryResults.add(c);
			}
		}
		
		if(CloudType == 'Competency'){
			List<Competency__c> l = new List<Competency__c>();
			// Select the values from database
			l = [Select Name, Count__c From Competency__c ORDER BY Count__c DESC LIMIT 15];
			for(Competency__c e: l){
				CloudItems c = new CloudItems();
				c.setName(e.Name);
				c.setCount(e.Count__c);
				queryResults.add(c);
			}
		}
		
		if(queryResults.size() == 0) return queryResults;
				
		// Get the highest rated item     
		Double maxRating = queryResults[0].Count;
		
		// Get the fraction
		Double base = maxRating / 10;
		
		// Level build
		Double level_1 = base ;
		Double level_2 = base * 2;
		Double level_3 = base * 3;
		Double level_4 = base * 4;
		Double level_5 = base * 5;
		Double level_6 = base * 6;
		Double level_7 = base * 7;
		Double level_8 = base * 8;
		Double level_9 = base * 9;
		Double level_10 = base * 10;
		
		// Build list
		List<CloudItems> result = new List<CloudItems>(); 
		
		for(CloudItems e: queryResults){
				
				CloudItems item = new CloudItems();
		     	
		     	item.setName(e.Name);		     	
		     		
		     	if (e.Count < level_1) { item.setLevel(1);}
		     	if (e.Count >= level_1 && e.Count < level_2) { item.setLevel(2);}
		     	if (e.Count >= level_2 && e.Count < level_3) { item.setLevel(3);}
		     	if (e.Count >= level_3 && e.Count < level_4) { item.setLevel(4);}
		     	if (e.Count >= level_4 && e.Count < level_5) { item.setLevel(5);}
		     	if (e.Count >= level_5 && e.Count < level_6) { item.setLevel(6);}
		     	if (e.Count >= level_6 && e.Count < level_7) { item.setLevel(7);}
		     	if (e.Count >= level_7 && e.Count < level_8) { item.setLevel(8);}
		     	if (e.Count >= level_8 && e.Count < level_9) { item.setLevel(9);}
		     	if (e.Count >= level_9 && e.Count < level_10) { item.setLevel(10);}
		        	
		     	result.add(item);		     	
		}
		
		// Shuffle
		Integer resultSize = result.size() - 1;
	    Integer i;	    
	  
	    for (i = 0; i <= resultSize; i++) {
	        Integer alea = Integer.valueOf(String.valueOf(Math.roundToLong(Math.ceil(Math.random() * resultSize))));
	        CloudItems item;
	 		item = result.get(i);
	 		result.set(i, result.get(alea));
	 		result.set(alea, item); 
	    	}

		return result; 
		
	}
	
	public class CloudItems { 		
 		String Name;
 		Integer Level;
 		Double Count;

        public String getName () {
        	return Name;       	
        } 
                
        public void setName (String Name) {
        	this.Name = Name;
        }
        
        public Integer getLevel () {
        	return Level;
        }   
        
        public void setLevel (Integer Level) {
        	this.Level = Level;
        }       	
        
        public double getCount () {
        	return Count;
        }   
        
        public void setCount (double Count) {
        	this.Count = Count;
        }    
 	}
 	
 	
	//####################################//
	// Mini Feeds
	//####################################//
	// Show feeds ?
    boolean showFeeds = true;
	
	public boolean getShowFeeds(){
	    	return showFeeds;
	}
	   
     public List<miniFeed> getMiniFeeds() {
     	
     	
       	// Feed Dates 
		boolean TodayShow = false;
	   	boolean YesterdayShow = false ;
	    boolean monthShow = false ;
	    DateTime now = System.now();
	    String dateAlreadyShown = '';
	    String FeedParsedDate = '';
	    Datetime FeedDateIterator;
	    
	    
	    
     	List<miniFeed> miniFeeds = new List<miniFeed>();
     	
     	if (miniFeeds.size() < 1) {

			List<MiniFeed__c> feeds;
			
			List<String> subscribedList = new List<String>();
			
			List<PeopleSubscription__c> subsAux = new List<PeopleSubscription__c>();
			
			subsAux = [Select p.Subscriber__c, p.Person__c, p.Person__r.Id From PeopleSubscription__c p where p.Subscriber__c =: UserInfo.getUserId()];
			
			if(subsAux.size() > 0){
				showFeeds = true;
				for(PeopleSubscription__c ps: subsAux){
					subscribedList.add(ps.Person__r.Id);
				} 	
			} 
			
			if(subscribedList.size() > 0){
			
				feeds =  [Select
									m.User__c,
									m.User__r.Name, 
									m.Type__c, 
									m.Message__c,
									m.CreatedDate 
									From MiniFeed__c m  				
									WHERE User__c IN: subscribedList ORDER BY m.CreatedDate DESC LIMIT 10];
									
									
	
					
					
				for(Integer i = 0; i < feeds.size() ; i++){
						miniFeed miniFeed = new miniFeed();
						miniFeed.setUser(feeds[i].User__c);
	                    miniFeed.setName(feeds[i].User__r.Name);
	                    miniFeed.setMessage(feeds[i].Message__c);
	                    miniFeed.setTypeOfFeed(feeds[i].Type__c);
	                    miniFeed.setFeedDate(feeds[i].CreatedDate);
	             
	                    // Set the Date Message 
						FeedDateIterator = feeds[i].CreatedDate;
						FeedParsedDate = 'Date' + FeedDateIterator.day() + FeedDateIterator.month() + FeedDateIterator.year();	        		
	                   	
		        		// Check if today is the day
		        		if( ( FeedDateIterator.day() == now.day() ) && ( !TodayShow )){
		        			
		        			TodayShow = true;
		        			miniFeed.setFeedDateClass('miniFeedDate');
		        			miniFeed.setFeedDateString('Today');						        			       
		        						
		        		} else {
		        			// Yesterday 
		        			if ((FeedDateIterator.day() == ( now.day() - 1 )) && (!YesterdayShow )) {
		        				
		        				YesterdayShow = true;
		        				miniFeed.setFeedDateClass('miniFeedDate');
		        				miniFeed.setFeedDateString('Yesterday');	        				
		        				
		        			} else {
		        				if ( FeedDateIterator.day() == now.day()){
		        					miniFeed.setFeedDateClass('miniFeedDate_empty');
		        					miniFeed.setFeedDateString(' ');
		        				} else {					        			
		        				
			        				if ( dateAlreadyShown != FeedParsedDate ){      					
			        					
			        					
			        					String Month;
			        					if( FeedDateIterator.month() == 1)  { Month = 'January '; }
			        					if( FeedDateIterator.month() == 2)  { Month = 'February '; }
			        					if( FeedDateIterator.month() == 3)  { Month = 'March  '; }
			        					if( FeedDateIterator.month() == 4)  { Month = 'April '; }
			        					if( FeedDateIterator.month() == 5)  { Month = 'May '; }
			        					if( FeedDateIterator.month() == 6)  { Month = 'June '; }
			        					if( FeedDateIterator.month() == 7)  { Month = 'July '; }
			        					if( FeedDateIterator.month() == 8)  { Month = 'August '; }
			        					if( FeedDateIterator.month() == 9)  { Month = 'September '; }
			        					if( FeedDateIterator.month() == 10)  { Month = 'October '; }
			        					if( FeedDateIterator.month() == 11)  { Month = 'November '; }
			        					if( FeedDateIterator.month() == 12)  { Month = 'December '; }
			        					
			        					dateAlreadyShown = 'Date' + FeedDateIterator.day() + FeedDateIterator.month() + FeedDateIterator.year();
			        					String tempDate = Month + FeedDateIterator.day() + ', ' + FeedDateIterator.year();
			        					miniFeed.setFeedDateClass('miniFeedDate');
			        					miniFeed.setFeedDateString(tempDate);
			        					
			        				} else {
			        					miniFeed.setFeedDateClass('miniFeedDate_empty');
			        					miniFeed.setFeedDateString('');
			        				}
		        				}
		        			}  		
		        		}    
		        		                     
	                    miniFeeds.add(miniFeed);    
				}					
			}    					
		                                
 		}
    	return miniFeeds;
    } 
    					
	public class miniFeed {
		
		public String User;
		public String Name;
        public String TypeOfFeed;
        public String Message;
        public String FeedDateString;
        public String FeedDateClass;
        public Datetime FeedDate;        
        
      	public miniFeed(){	
      		
      	}
      	
      	// Icon of the current type 
        public String getTypeOfFeed() {
      		
    			if (TypeOfFeed == 'EducationHistory__c')  { TypeOfFeed = 'education'; } 
        		if (TypeOfFeed == 'UserCompetencies__c')  { TypeOfFeed = 'competency'; }
        		if (TypeOfFeed == 'DiscussionThread__c')  { TypeOfFeed = 'discussion'; }
        		if (TypeOfFeed == 'EmploymentHistory__c')  { TypeOfFeed = 'employment'; }
        		if (TypeOfFeed == 'Announcement__c')  { TypeOfFeed = 'announcement'; }
        		if (TypeOfFeed == 'TeamspaceMember__c')  { TypeOfFeed = 'teamspace'; }
        		
        		return TypeOfFeed;
        			
			}
			
			public void setTypeOfFeed(String sTypeOfFeed){
	                TypeOfFeed = sTypeOfFeed;
	        }
      
	      	public String getName() {
	                return Name;
	        }
	        public void setName(String sName){
	                Name = sName;
	        }
	        
	        public String getUser() {
	                return User;
	        }
	        public void setUser(String sUser){
	                User = sUser;
	        }
	        
	        public String getMessage() {
	        		
	                return Message;
	        }
	        public void setMessage(String sMessage){
	                Message = sMessage;
	        }
	       	
	        public Datetime getFeedDate() {
	        	return FeedDate;
		        		       
	        }
	        
	        public void setFeedDate(Datetime sFeedDate){
	                FeedDate = sFeedDate;
	        }  
	        
	       	public String getFeedDateString() {
	        	return FeedDateString;
		        		       
	        }
	        
	        public void setFeedDateString(String sFeedDateString){
	                FeedDateString = sFeedDateString;
	        }  
	        
	        public String getFeedDateClass() {
	        	return FeedDateClass;
		        		       
	        }
	        
	        public void setFeedDateClass(String sFeedDateClass){
	                FeedDateClass = sFeedDateClass;
	        }  
	       
	}	
 
}