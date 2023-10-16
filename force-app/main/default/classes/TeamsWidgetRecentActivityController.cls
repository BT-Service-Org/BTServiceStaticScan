public class TeamsWidgetRecentActivityController {

	Set<Id> users;
	
	public TeamsWidgetRecentActivityController() {
	
		users = new Set<Id>();
		
		for(TeamMember__c t: [SELECT User__c
								   FROM TeamMember__c
								   WHERE Team__c =: System.currentPageReference().getParameters().get('id')] ) {
			users.add(t.User__c);		   	
		}								   								   
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
			
			feeds =  [Select
								m.User__c,
								m.User__r.Name, 
								m.Type__c, 
								m.Message__c,
								m.CreatedDate 
								From MiniFeed__c m 	
								WHERE User__c IN: users			
								ORDER BY m.CreatedDate DESC LIMIT 10];
				
				
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
		        					String tempDate = Month + FeedDateIterator.day();
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
        		if (TypeOfFeed == 'TeamMember__c')  { TypeOfFeed = 'teamspace'; }
        		
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