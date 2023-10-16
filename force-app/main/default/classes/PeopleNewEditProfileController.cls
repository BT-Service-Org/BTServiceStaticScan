public class PeopleNewEditProfileController {

	public static String PAGE_PROFILE = '/apex/PeopleProfileDisplay';

	public String param = System.currentPageReference().getParameters().get('id');
	
	public void setParam (String s){
		param = s;
	}
	
	public PeopleNewEditProfileController(ApexPages.StandardController controller){
    	// Get Status		
		p = [SELECT Id,  Status__c, StatusLastModifiedDate__c
                                        		FROM PeopleProfile__c
                                         		WHERE User__c =: UserInfo.getUserId()];
          
         if((p.Status__c != null) && (p.Status__c != '')){
         	showStatus = true;     
         } else {
         	showStatus = false;	
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
	
	// Profile Row
	PeopleProfile__c p = new PeopleProfile__c();
	
	// Send current time (aprox)	
	public String getCurrentTime(){
		Datetime now = (System.now()).addHours(7);
		String s1 = now.format('yyyy-MM-dd');
		String s2 = now.format('HH:mm:ss.SSS');
		String dateString = s1 + 'T' + s2 + 'Z';
		return dateString;
	}
	
	//####################################//
	// My Profile At Sidebar
	//####################################//
	
		public String getMyPicture(){
		
		String MyPictureId;
		PeopleProfile__c temp = new PeopleProfile__c();
		
		try{
			temp = [SELECT Picture__c                                              
	                                             FROM PeopleProfile__c
	                                         	 WHERE User__c =: UserInfo.getUserId()];
			                             	                                          	 
		     if((temp.Picture__c == '') ||( temp.Picture__c == null )){ 
					MyPictureId = '01530000000VO5s';
				} else{
					MyPictureId = temp.Picture__c;
				} 
		} catch(Exception e) {
			MyPictureId = '01530000000VO5s';
		}
			
		return MyPictureId;
	}
	
	
	public PeopleProfile__c getMySidebarProfile(){
	
			PeopleProfile__c mySidebarProfile = [SELECT Id,
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
        	
        	// Status Obj
        	Status sObj = new Status();
        	
        	if((p.Status__c != null) && (p.StatusLastModifiedDate__c != null)){
	          	sObj.setMessage(p.Status__c);
				sObj.setModified(p.StatusLastModifiedDate__c);
        	}
			return sObj;       
		}
	
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
							updateMessage = 'Updated ' + temp + ' seconds ago';
						} else {								
							if(temp == 1){
								updateMessage = 'Updated ' + temp + ' minute ago';
							} else {
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
	
 	// Error string to show the mistake.
    public String error = '';
    
    // Error getter
    public String getError(){
        return error;
    }
    
     //############################################//   
  	//   PEOPLE PROFILE
   	//############################################//  
    
    PeopleProfile__c pProfile = null;
    
    public PeopleProfile__c getPProfile(){
    	
    	if((pProfile.Facebook__c == null) || (pProfile.Facebook__c == ' ')){
    		pProfile.Facebook__c = 'http://www.new.facebook.com/profile.php?id=';
    	}
    	
    	if((pProfile.Delicious__c == null) || (pProfile.Delicious__c == ' ')){
    		pProfile.Delicious__c = 'http://delicious.com';
    	}
    	
    	if((pProfile.Linkedin__c == null) || (pProfile.Linkedin__c == ' ')){
    		pProfile.Linkedin__c = 'http://www.linkedin.com/in/';
    	}
    	
    	return pProfile;
    }
      
        // Edit People Profile
    /////////////////////////////////  
    public void getPeopleProfile() {
    		
	        newUser = [Select Id, 
	        					Name,
	        					Street,
	        					State, 
	        					PostalCode, 
	        					Phone,
	        					MobilePhone, 
	        					LastName,
	        					Title,
	 							FirstName, 
	 							Fax,  
	 							Email, 
	 							Division, 
	 							Department, 
	 							Country,
	 							City,		(SELECT Id,
						                        Name,
						                        YahooIM__c,
						                        Skype__c,
						                      	Messages__c,
						                        HomePageUrl__c,
						                        Gtalk__c,
						                        Facebook__c,
								  				Delicious__c,
								  				Aol__c,
								  				AboutMe__c,
								  				Linkedin__c,
								  				changeHistory__c,
								  				changeHistoryDate__c
	                FROM People__r) From User u
	                WHERE u.Id =: param];
	    			pProfile = newUser.People__r[0];               
	       }  
	        
	   // Save the new Profile
    /////////////////////////////////              
     public PageReference savePeopleProfile() {
    	    	
    	 if (UserInfo.getUserId() == newUser.Id){
    	    	
			upsert pProfile;						
			return forwardTo(PAGE_PROFILE);
    	 }
    	 else{
    	 	getPeopleProfile();   
			error = 'You do not have permission to modify the data of Profile'; 
			return null;    	 	
    	 }	    		
    }

    // Cancel the new Profile
    /////////////////////////////////  
    public PageReference cancelProfile() {
					       
     	getPeopleProfile();     	 
        return null;
    }


    
    // User
    //////////////////////////////////////  
 	User newUser;
 	 	
        
   	public void init() {
                newUser = [
                        SELECT Id,
                        Name, Email,
                        LastName, FirstName,
                        Title, CompanyName,
                        Department, Division,
                        Street, State, Phone,
                        City, MobilePhone,
                        Country, PostalCode
                        FROM User
                        WHERE Id =:param];                           
        }
                
	// Return the user for show details
    /////////////////////////////////////////////
    public User getNewUser() {
        return newUser;
    }
    
    //FUNCTIONS
    
    public PageReference forwardTo (String url) {
		PageReference page = new pageReference(url);
		page.setRedirect(true);
		return page;
	}
    
}