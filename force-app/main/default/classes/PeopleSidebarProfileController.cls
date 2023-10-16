public class PeopleSidebarProfileController {
	
	PeopleProfile__c p = new PeopleProfile__c();
	Status status = new Status();
	
	public PeopleSidebarProfileController(){
		
		List<PeopleProfile__c> peopleListMatch = new List<PeopleProfile__c>();
		peopleListMatch = getPeopleProfile();
		if (peopleListMatch.size() > 0){
			p = peopleListMatch[0]; 
			if((p.Status__c != null) && (p.Status__c != '')){
				showStatus = true;     
			}else{
				showStatus = false;	
			}
		}
		
		subscriptionCounts();
		
		p = [SELECT Id,
 						User__c,
 						Status__c,
 						StatusLastModifiedDate__c,
 						User__r.Name,
                    	User__r.FirstName,
                    	User__r.LastName,
                        User__r.Title,
                        (Select Id From Attachments),
                        CreatedDate                                                
                        FROM PeopleProfile__c
                        WHERE User__c =: UserInfo.getUserId()];
	}
	//####################################//
	// My Profile At Sidebar
	//####################################//
	
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
		
	// Send current time (aprox)
	//  	
	public String getCurrentTime(){
		Datetime now = (System.now()).addHours(7);
		String s1 = now.format('yyyy-MM-dd');
		String s2 = now.format('HH:mm:ss.SSS');
		String dateString = s1 + 'T' + s2 + 'Z';
		return dateString;
	}
	
	
	public String getMyPicture(){
		String MyPictureId;
		List<PeopleProfile__c> profiles = new List<PeopleProfile__c>();
		PeopleProfile__c temp = new PeopleProfile__c();
		try{
			profiles = getPeopleProfile();
			if(profiles.size() > 0){
			    temp = profiles[0];
			    if((temp.Picture__c == '') ||( temp.Picture__c == null )){ 
						MyPictureId = null;
				} else{
						MyPictureId = temp.Picture__c;
				} 
			}
		} catch(Exception e) {
			MyPictureId = null;
		}
		return MyPictureId;
	}
	
	public PeopleProfile__c getMySidebarProfile(){
		PeopleProfile__c mySidebarProfile = new PeopleProfile__c();

     	if(p.Id != null){
     		mySidebarProfile = p;  
     	}
        return mySidebarProfile;      
	}
	
	//####################################//
	// My Sidebar Status
	//####################################//
	
	// boolean to control showing or not the status
	boolean showStatus;	
	
	public boolean getShowStatus(){
			return showStatus;
	}
		
	public Status getStatus() {
    	// Status status
      	if((p.Status__c != null) && (p.StatusLastModifiedDate__c != null)){
          	status.setMessage(p.Status__c);
			status.setModified(p.StatusLastModifiedDate__c);
    	}
		return status;       
	}
	
	/**
	* Edit Status
	*@void
	*/
	public void EditStatus()
	{
		p.Status__c = status.Message;
		p.StatusLastModifiedDate__c = System.now();
		update p;
	}	
	
	/**
	* Status
	*@class
	*/
	public class Status {
		
		String Message;
		String Modified = '';		
		
		public void setMessage(String sMessage){                
                Message = sMessage;                
        }
        
        public String getMessage() {
	            return Message;
		}
		
		public void setModified(Datetime sModified){
				
				// Get the current time
				DateTime now = System.now();
				
				String todayDateString = '' + now.day() + now.month() + now.year();
				
				Integer today = now.dayOfYear();
				Integer modifiedDay = sModified.dayOfYear();
				Integer temp = 0;
				String updateMessage = '';
				
				// Check if the update was today
				if(sModified.isSameDay(now)){
					// Check how many hours ago
					temp = now.hour() - sModified.hour();
					// Check if the timelapse is small than one hour
					// if that , get the minutes ago  
					If (temp <= 1 ){
						temp = now.minute() - sModified.minute();
						if(temp == 0){
							temp = now.second() - sModified.second();
							if(temp < 60)
							{
								updateMessage = 'Updated right now';
							}													
							
						} else {			
							System.debug('\n\n-----\n\n Now.Minute -->'+now.minute()+'\n\n sModified.Minute -->'+sModified.minute()+'\n\n temp -->'+temp+'\n\n-----\n\n');					
							if(temp == 1)
							{
								updateMessage = 'Updated ' + temp + ' minute ago';
							} 
							else if(temp < 0)
							{
								updateMessage = 'Updated ' + (60 - (temp*-1)) + ' minutes ago';
							}
							else 
							{
								updateMessage = 'Updated ' + temp + ' minutes ago';
							}
						}
					} else {						
							updateMessage = 'Updated ' + temp + ' hours ago';
					}				
				} else {
					Integer rest = today - modifiedDay;
					// if the update was in the last week
					if(rest <= 7){
						updateMessage = 'Updated on ' + sModified.format('EEEEEE');
					} else {
						updateMessage = 'expired';
					}
				}
				
						
                Modified = updateMessage;
        }
        
        public String getModified() {
        			return Modified;
		}
	}
	
	// Get people subscriptions Info 
         
    public Integer countImSubscribedTo = 0;
    public Integer countSubscribedToMe = 0;
    public boolean showSubscribedPeople = false;
    
    public boolean getShowSubscribedPeople(){
    	return showSubscribedPeople;
    }    
    
    public Integer getCountSubscribedToMe(){
    	return countSubscribedToMe;
    }
    
    public Integer getCountImSubscribedTo(){
    	return countImSubscribedTo;
    }
    
    public void subscriptionCounts(){
    	List<PeopleSubscription__c> subscriptionInfo = new List<PeopleSubscription__c>();
    	
    	subscriptionInfo = [Select p.Id, p.Subscriber__c, p.Person__c From PeopleSubscription__c p where p.Subscriber__c =: UserInfo.getUserId()];
    	
    	countImSubscribedTo = subscriptionInfo.size();
    	
    	subscriptionInfo = [Select p.Id, p.Subscriber__c, p.Person__c From PeopleSubscription__c p where p.Person__c =: UserInfo.getUserId()];
    	
    	countSubscribedToMe = subscriptionInfo.size();
    	
    	if((countImSubscribedTo + countSubscribedToMe) != 0)
    		showSubscribedPeople = true;
    	
    }
	
	
}