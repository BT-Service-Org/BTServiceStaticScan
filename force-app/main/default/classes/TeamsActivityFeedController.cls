public with sharing class TeamsActivityFeedController {

    public TeamsActivityFeedController(){
    	getMiniFeeds();
    }
     
    public Integer miniFeedCount = 0;
	public String[] listFilter = new String[]{};
     
    //Filters 
	Boolean filterStatus = false;
    public void setFilterStatus (Boolean b){
    	filterStatus = b;
    }
    public Boolean getFilterStatus (){
    	return filterStatus;
    }
    
   	Boolean filterFollow = false; 
    public void setFilterFollow (Boolean b){
    	filterFollow = b;
    }
    public Boolean getFilterFollow (){
    	return filterFollow;
    }
    
    Boolean filterEducation = false; 
    public void setFilterEducation (Boolean b){
    	filterEducation = b;
    }
    public Boolean getFilterEducation (){
    	return filterEducation;
    }  

	Boolean filterCompetencies = false; 
    public void setFilterCompetencies (Boolean b){
    	filterCompetencies = b;
    }
    public Boolean getFilterCompetencies (){
    	return filterCompetencies;
    }
    
    Boolean filterMember = false; 
    public void setFilterMember (Boolean b){
    	filterMember = b;
    }
    public Boolean getFilterMember (){
    	return filterMember;
    }

    Boolean filterDiscussion = false; 
    public void setFilterDiscussion (Boolean b){
    	filterDiscussion = b;
    }
    public Boolean getFilterDiscussion (){
    	return filterDiscussion;
    }
    
    //4
    Boolean filterAnnoncements = false; 
    public void setFilterAnnoncements (Boolean b){
    	filterAnnoncements = b;
    }
    public Boolean getFilterAnnoncements (){
    	return filterAnnoncements;
    }
    
    //5
    Boolean filterProject = false; 
    public void setFilterProject (Boolean b){
    	filterProject = b;
    }
    public Boolean getFilterProject (){
    	return filterProject;
    }    
     
    //End Filters
    
   
    List<miniFeed> feedsList = new List<miniFeed>();
    public List<miniFeed> getFeedsList (){
    	return feedsList;
    }
    
    //Get minifeeds list
    public void getMiniFeeds() {
       	// Feed Dates 
		boolean TodayShow = false;
	   	boolean YesterdayShow = false ;
	    boolean monthShow = false ;
	    DateTime now = System.now();
	    String dateAlreadyShown = '';
	    String FeedParsedDate = '';
	    Datetime FeedDateIterator;
	    
	    String typeFilterObj = System.currentPageReference().getParameters().get('mfTypeObj');
	    String typeFilterStr = System.currentPageReference().getParameters().get('mfTypeStr');
	    
     	feedsList.clear();
     	if (feedsList.size() < 1) {

			List<MiniFeed__c> feeds;
			List<String> filters = new List<String>();
			
			Boolean hasWhere = false;
			
			//Status filter
			if(filterStatus){
				filters.add('PeopleChangeStatus');
				hasWhere = true;
			}
			
			//People Follow filter
			if(filterFollow){				
				filters.add('PeopleFollow');
				hasWhere = true;				
			}
			
			//People Competency filter
			if(filterCompetencies){
				filters.add('PeopleCompetencyChange');
				hasWhere = true;				
			}
			
			//FilterMember filter
			if(filterMember){				
				filters.add('TeamMemberAdd');
				filters.add('TeamMemberLeave'); 
				filters.add('TeamMemberJoin');
				hasWhere = true;				
			}
			
			//FilterDiscussion filter
			if(filterDiscussion){				
				filters.add('DiscussionNewTopic');
				filters.add('DiscussionNewReply');			
				hasWhere = true;				
			}
			
			//FilterAnnoncements filter
			if(filterAnnoncements){				
				filters.add('BlogPublished');
				filters.add('BlogNewComment');			
				hasWhere = true;				
			}
			
			//FilterProject filter
			System.debug('filterProject' + filterProject);
			if(filterProject){
				filters.add('TaskNew');
				filters.add('TaskAssigned'); 
				filters.add('TaskEdited');
				filters.add('TaskCompleted');				
				hasWhere = true;
				
			}										
				
		    if(hasWhere)
				feeds = [Select m.User__c, 
								m.User__r.Name, 
								m.Type__c, 
								m.Message__c, 
								m.CreatedDate 
						 from MiniFeed__c m
						 WHERE Type__c IN: filters
						 ORDER BY m.CreatedDate DESC LIMIT 30];
			else
				feeds = [Select m.User__c, 
								m.User__r.Name, 
								m.Type__c, 
								m.Message__c, 
								m.CreatedDate 
						 from MiniFeed__c m
						 ORDER BY m.CreatedDate DESC LIMIT 30];
				
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
	        					System.debug('dateAlreadyShown' + dateAlreadyShown);
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
                feedsList.add(miniFeed);    					
			}    					
 		}
    }
    
    public Integer getMiniFeedCount(){
		return miniFeedCount;
	}
	        
    public void setMiniFeedCount(Integer count){
    	miniFeedCount = count;
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