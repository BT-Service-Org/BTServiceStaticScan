public class PeopleProfileDisplayController {
	
	//to show
	boolean vShowAboutMe;
	
	// Send current time 	
	public String getCurrentTime(){
		Datetime now = (System.now()).addHours(7);
		String s1 = now.format('yyyy-MM-dd');
		String s2 = now.format('HH:mm:ss.SSS');
		String dateString = s1 + 'T' + s2 + 'Z';
		return dateString; 
	}
	
	// Manager Obj
	PeopleProfile__c Manager = new PeopleProfile__c();
	public boolean displayManager;
	
	// Direct Reports List 
	List<PeopleProfile__c> directReports = new List<PeopleProfile__c>();
	
	// Profile Row
	PeopleProfile__c p = new PeopleProfile__c();
	
	// User Id (to show all data)
	Id USERID;
	
	public void setProfileUserId(string sUserid){
		USERID = sUserid;
	}
	
	
	//Status Object
	Status status = new Status();
	
	public Id getProfileUserId(){
		return USERID;
	}
	
	// Is current user bool
	boolean isCurrentUser;
	
	public boolean getIsCurrentUser(){
		return isCurrentUser;
	}
	
	//check if not my profile and the profile is public
	public boolean displayInfo
	{
		get;
		set
		{
			List<Team__c> commonTeams = [Select t.Name, (Select id, User__c, Team__c From TeamMembers__r where User__c =:UserInfo.getUserId() or User__c =: USERID) From Team__c t];
			System.debug('\n\n////////////////////////////////////////////\n COMMON TEAMS: '+ commonTeams + '\n//////////////////////////////\n\n');
			Boolean findJoinTeam = false;
			Integer countTeam = 0;
			while (!findJoinTeam && countTeam < commonTeams.size()) {
				System.debug('\n\n////////////////////////////////////////////\n COMMON TEAMS - CURRENT MEMBERS : '+ commonTeams[countTeam].TeamMembers__r + '\n//////////////////////////////\n\n');
				if (commonTeams[countTeam].TeamMembers__r.size() > 1) {
					findJoinTeam = true;
				}
				else {
					countTeam++;
				}
			}
			System.debug('\n\n////////////////////////////////////////////\n COMMON TEAMS BOOLEANS: \nFind Join Team: '+ findJoinTeam + '\nIs Owner Profile: ' + (USERID == UserInfo.getUserId()) + '\nIs Private Profile: ' + value + '\n//////////////////////////////\n\n');
			// Only my Profile or isPrivate = false show info
			if(USERID == UserInfo.getUserId() || findJoinTeam || !value)
			{
				displayInfo = true;
			}
			else if (!value)
			{
				displayInfo = false;
			}

		}
	}
	
	//Reports Count 
	Boolean hasDirectReportsExpand = false;
	
	public Boolean getHasDirectReportsExpand(){
		return hasDirectReportsExpand;
	}
	
	// Constructor
	public PeopleProfileDisplayController() {
		
		// Check if the user id is provided, if not, the current userid is used as default.
		if(System.currentPageReference().getParameters().get('id') == null){
			USERID = UserInfo.getUserId();			
		} else {
			USERID = System.currentPageReference().getParameters().get('id');
		}
		
		//check it is the current user
		if(USERID == UserInfo.getUserId()){
			isCurrentUser = true;
		} else {
			isCurrentUser = false;
		}		
		
		// Get Profile
		try {
			p = [SELECT Id,
	 						User__c,
	 						User__r.Name,
	                        User__r.FirstName,
	                        User__r.LastName,
	                        User__r.Title,
	                        User__r.Division,
	                        User__r.Department,
	                        User__r.Phone,
	                        User__r.MobilePhone,
	                        User__r.Fax,
	                        User__r.Street,
	                        User__r.State,
	                        User__r.PostalCode,
	                        User__r.Country,
	                        User__r.City,
	                        User__r.Email,
	                        Picture__c,                                               
	                        AboutMe__c,
	                        Linkedin__c, 
	                        Facebook__c, 
	                        Delicious__c,
	                        Status__c,
	                        Aol__c,
	                        YahooIM__c,
	                        Skype__c,
	                        Gtalk__c,
	                        isPrivate__c,
	                        StatusLastModifiedDate__c,                                                
	                        CreatedDate                                                
	                        FROM PeopleProfile__c
	                        WHERE User__c =: USERID];
		}catch (Exception e){
		
		} 
         // Get visibles fields 
         if(p.AboutMe__c != null){
         	vShowAboutMe = true;
         }
        //set isPrivate Value 
        displayInfo = p.isPrivate__c;
         
         
         // Get Status 
         if((p.Status__c != null) && (p.Status__c != '')){
         	showStatus = true;     
         } else {
         	showStatus = false;	
         }
         
         	
		// Direct Reports query
		try{
			directReports = [ SELECT Id,
		                        User__r.Name,
		                        User__r.Division,
		                        User__r.ManagerId, 
		                        Picture__c,
		                        CreatedDate,
		                        (SELECT Id FROM NotesAndAttachments)
		                        FROM PeopleProfile__c WHERE User__r.ManagerId =: USERID];
			if(directReports.size() > 3)
				hasDirectReportsExpand = true;
		} catch (Exception e ){}
		
		// Manager
		List<User> temp = new List<User>();
		try{		
			temp = [ SELECT ManagerId, Id from User WHERE Id =: USERID];
					
			if(temp[0].ManagerId != null){
				Manager = [SELECT Id,
		                        User__r.Name,
		                        User__r.Division,
		                        User__r.Title,
		                        Status__c,
		                        Picture__c,
		                        CreatedDate,
		                        (SELECT Id FROM NotesAndAttachments)
		                        FROM PeopleProfile__c WHERE User__c = :temp[0].ManagerId ];
		       displayManager = true;
			} else {
				displayManager = false;
			}
		} catch(Exception e){}
		
		
		// Competencies 
		try{
		compList = [SELECT Id,
                        Competency__r.Name,
                        Rating__c,                   
                        User__c
                FROM UserCompetencies__c
                WHERE User__c =: USERID];
		} catch (Exception e) {}       
        competenciesNumber = compList.size();
        
        subscriptionCounts();
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
    	
    	subscriptionInfo = [Select p.Id, p.Subscriber__c, p.Person__c From PeopleSubscription__c p where p.Subscriber__c =: USERID];
    	
    	countImSubscribedTo = subscriptionInfo.size();
    	
    	subscriptionInfo = [Select p.Id, p.Subscriber__c, p.Person__c From PeopleSubscription__c p where p.Person__c =: USERID];
    	
    	countSubscribedToMe = subscriptionInfo.size();
    	
    	if((countImSubscribedTo + countSubscribedToMe) != 0)
    		showSubscribedPeople = true;
    	
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
    
    //####################################//
	// Methods to show or not the modules
	//####################################//
    
    public boolean getShowAboutMe(){
    	return vShowAboutMe;
    }
    
    public boolean getShowDirectRepots(){
    	if(directReports.size() > 0){
    		return true;
    	}
    	return false;	
    }	
    
    public boolean getShowMiniFeeds(){
    	if(getMiniFeeds().size() > 0){
    		return true;	
    	}
    	return false;
    }
    
    public boolean getShowEmploymentHistories(){
    	if(getEmploymentHistories().size() > 0){
    		return true;
    	}
    	return false;
    }
    
    public boolean getShowEducationHistories(){
    	if(getEducationHistories().size() > 0){
    		return true;
    	}
    	return false;
    }	
    
    public boolean getShowOtherNetworks(){
    	if(getOtherNetworks().size() > 0){
    		return true;
    	}
    	return false;	
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
	// Profile 
	//####################################//
	
	// Booleans to display or not sections
	public boolean displayAboutMe;
	
	public String getPicture(){
		
		String PictureId;
		
		List<PeopleProfile__c> picture = new List<PeopleProfile__c>(); 
		
		try{
				picture = [SELECT   
				                Picture__c                                                
		                        FROM PeopleProfile__c
		                        WHERE User__c =: USERID];
		} catch (Exception e) {}
		
		if(picture.size() > 0){
	        if(picture[0].Picture__c == '' || picture[0].Picture__c == null){                	                                          	 
		     	PictureId = null;
			} else{
				PictureId = '/servlet/servlet.FileDownload?file='+ picture[0].Picture__c;
			} 
		}
			
		return PictureId;
	}
	
	public Profile getProfile(){
	
				Profile profileObj = new Profile();
			 	
			 	profileObj.setId(p.Id);
			 	profileObj.setName(p.User__r.Name);
			 	profileObj.setFirstName(p.User__r.FirstName);
			 	profileObj.setLastName(p.User__r.LastName);
			 	profileObj.setTitle(p.User__r.Title);
			 	profileObj.setDivision(p.User__r.Division);
			 	profileObj.setDepartment(p.User__r.Department);
			 	profileObj.setMobilePhone(p.User__r.MobilePhone);
			 	profileObj.setPhone(p.User__r.Phone);
			 	profileObj.setFax(p.User__r.Fax);
			 	profileObj.setYahooIM(p.YahooIM__c);
			 	profileObj.setAol(p.Aol__c);
			 	profileObj.setStatus(p.Status__c);
			 	profileObj.setSkype(p.Skype__c);
			 	profileObj.setGtalk(p.Gtalk__c);
			 	profileObj.setEmail(p.User__r.Email);
			 	profileObj.setAboutMe(p.AboutMe__c);
			 	profileObj.setBussinessAddress(p.User__r.Street,
	                        					p.User__r.State,
						                        p.User__r.PostalCode,
						                        p.User__r.Country,
						                        p.User__r.City);
			 	
			 	profileObj.setUserId(p.User__c);
			 	
			 	
			 	System.debug('about meeee ' + p.AboutMe__c);
			 return profileObj;
	}
	
	public class Profile {
    	Id Id;
    	// IM
    	String YahooIM;
	 	String Skype;
	 	String Gtalk;
	 	String Aol;
    	// Userdata 
    	String Name;
    	String currentStatus = null;
    	String FirstName;
    	String LastName;
    	String Title;
    	String Division;
    	String Department;
    	String MobilePhone;    	
    	String Phone;
    	String Fax;
    	String Email;
    	String AboutMe;
    	String UserId;
    	// Bussiness Address
    	String BussinessAddress;  	
    	
    	public void setBussinessAddress(String Street, String State, String PostalCode, String Country, String City ) {		
    		BussinessAddress = '';  		
    	  	if((Street != '') && (Street != null))
    	  		BussinessAddress += Street+'<br/> ';	
    	  	if((State != '') && (State != null))
    	  		BussinessAddress += State+', ';	
    	  	if((PostalCode != '') && (PostalCode != null))
    	  		BussinessAddress += PostalCode+', ';    	  	
    	  	if((City != '') && (City != null))
    	  		BussinessAddress += City+', ';	
    	  	if((Country != '')  && (Country != null))
    	  		BussinessAddress += Country+'.';	
    	}
    	
    	public String getStatus(){
    		return currentStatus;
    	}
    	
    	public void setStatus(String s){
    		currentStatus = s;
    	}
    	
    	
    	public String getBussinessAddress(){
    		return BussinessAddress;
    	}
    	
    	public void setYahooIM(String sYahoo){
    		YahooIM = sYahoo;
    	}
    	
    	public void setSkype(String sSkype){
    		Skype = sSkype;
    	}
    	
    	public void setGtalk(String sGtalk){
    		Gtalk = sGtalk;
    	}
    	
    	public void setAol(String sAol){
    		Aol = sAol;
    	}
    	
    	public String getAol(){
    		return Aol;
    	}
    	
    	public String getYahooIM(){
    		return YahooIM;
    	}
    	
    	public String getSkype(){
    		return Skype;
    	}
    	
    	public String getGtalk(){
    		return Gtalk;
    	}
    	
    	public void setUserId(Id sUserId){
                UserId = sUserId;
        }
        
        public String getUserId() {
	                return UserId;
		}
    	public void setId(Id sId){
                Id = sId;
        }
        
        public String getId() {
	                return Id;
		}
		
		public void setName(String sName){
                Name = sName;
        }
        
        public String getName() {
	                return Name;
		}
		
		public void setFirstName(String sFirstName){
                FirstName = sFirstName;
        }
        
        public String getFirstName() {
	                return FirstName;
		}
		
		public void setLastName(String sLastName){
                LastName = sLastName;
        }
        
        public String getLastName() {
	                return LastName;
		}
		
		public void setTitle(String sTitle){
                Title = sTitle;
        }
        
        public String getTitle() {
	                return Title;
		}
		
		public void setDivision(String sDivision){
                Division = sDivision;
        }
        
        public String getDivision() {
	                return Division;
		}		
		
		public void setDepartment(String sDepartment){
                Department = sDepartment;
        }
        
        public String getDepartment() {
	                return Department;
		}	
		
		public void setMobilePhone(String sMobilePhone){
                MobilePhone = sMobilePhone;
        }
        
        public String getMobilePhone() {
	                return MobilePhone;
		}
			
		public void setPhone(String sPhone){
                Phone = sPhone;
        }
        
        public String getPhone() {
	                return Phone;
		}	
		
		public void setFax(String sFax){
                Fax = sFax;
        }
        
        public String getFax() {
	                return Fax;
		}	
		
		public void setEmail(String sEmail){
                Email = sEmail;
        }
        
        public String getEmail() {
	                return Email;
		}		
		
		public void setAboutMe(String sAboutMe){
                AboutMe = sAboutMe;
        }
        
        public String getAboutMe() {
	                return AboutMe;
		}
		
    }
	
	//####################################//
	// My Status
	//####################################//
	
	// boolean to control showing or not the status
	boolean showStatus;	
	
		public boolean getShowStatus(){
			return showStatus;
		}
		
	
	/**
	* Get Status
	*@return Status
	*/
	public Status getStatus() {
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

	//********************************************************************************
	//******************* Most Connected People *****************************
	
	public List<Connection> getMostConnectedUsers(){
			
		Map<Id, Connection> tempMap = new Map<Id, Connection>();
		List<Connection> mostConnected = new List<Connection>();
		List<Id> t = new List<Id>();
		Integer i;
		
		
		for(TeamMember__c tm : [Select Team__c From TeamMember__c WHERE User__c =: USERID] ) { 
			t.add(tm.Team__c);
		}			
		
		for(TeamMember__c teamMember: [SELECT User__c, User__r.Name  from TeamMember__c Where Team__c in: t] )
		{
			if(teamMember.User__c == USERID) continue; 
			
			if(tempmap.containsKey(teamMember.User__c))
			{
				// increment the count
				Connection c = tempMap.get(teamMember.User__c);
				Integer tempCount = c.getMatches() + 1;
				c.setMatches(tempCount); 
				tempMap.put(teamMember.User__c, c);
			}
			else
			{
				// add a new one
				Connection c = new Connection();
				c.setMatches(1);
				c.setId (teamMember.User__c);
				c.setName(teamMember.User__r.Name);
				//c.setUserPicture(teamMember.User__c);
				//c.setStatus(teamMember.User__c);
				tempMap.put(teamMember.User__c, c);
			}
		}	
					
		List<Connection> tempList = tempMap.values();
		List<Id> mostConnectedUserId = new List<Id>();		 				
		this.sortConnections(tempList);
		for(i = 0; i <= 10; i++ ){
			if(i < tempList.size()){
				mostConnected.add(tempList[i]);
				mostConnectedUserId.add(tempList[i].getId());
			}
		}	
		
		// Iterate through them to get the picture and status
		Map<Id, PeopleProfile__c> profileMap = new Map<Id, PeopleProfile__c>(); 
		for(PeopleProfile__c profile: [select Picture__c, Status__c, User__c from PeopleProfile__c where User__c in: mostConnectedUserId]) {
			profileMap.put(profile.User__c, profile);
		}
		
		for(Connection c: mostConnected) {
			
			PeopleProfile__c profile = profileMap.get(c.getId());
			
			if(profile == null) continue;
			
			c.setUserPicture(profile.Picture__c);
			c.setStatus(profile.Status__c);	
		}
		
		return mostConnected;
	}
	
	public List<Connection> sortConnections(List<Connection> result) {
 		Integer n;
 		Integer i;
 		Integer j;
 		n = result.size() - 1;	
 		for (i = 1; i <= n; i++) {	
 			for (j = n; j >= i ; j--) {
 				if (result.get(j).getMatches() >= result.get(j - 1).getMatches()) {
 					Connection tempActiveUser;
 					tempActiveUser = result.get(j - 1);
 					result.set(j - 1, result.get(j));
 					result.set(j, tempActiveUser); 	
 				}	
 			}
 		}
 		System.debug('\n\n\n------------------>'+ result +'<----------------------\n\n\n');
 		return result;
 		
 	}	
 	
	
	public class Connection{
		
		//******************* Attributes ***************************************
		
		public String userPicture = '';
		public Integer matches;
		public String name;
		public String id;
		public String status = '';
		//*********************************************************************
		//******************* Constructor *************************************
		
		public Connection(){}
		public Connection(String id){}
		
		
		//*********************************************************************
		//******************* Getters *****************************************
		
	 	public String getStatus(){
	 		
	 		return status;
	 	}
		
		public Integer getMatches(){
						
				return 	matches;
		}	
		
		public String getName(){
		
				return 	name;
		}	
		
		public String getId(){
		
				return 	id;
		}	
		
		
		public String getUserPicture(){
		
			return this.userPicture;
		
		}
		
		
		//********************************************************************
		//******************* Seters *****************************************
		public void setStatus(String s){
			
			if(s != null)
				status = s;
		}
		
		public void setMatches(Integer match){
				
			matches = match;
		}
		
		public void setName(String sName){
				
			name = sName;
		}
		public void setId(String id){
				
			this.id = id;
		}
		
		public void setUserPicture(String picture) {
	
		    if(picture != '' && picture != null) {                	                                          	 
				this.userPicture = picture;
			} 
   		}
		//*******************************************************************
	}
	
	//####################################//
	// Return a list with education history for this user
    //####################################//
    public List<educationHistories> getEducationHistories() {

	  List<EducationHistory__c> aux = new List<EducationHistory__c>();
	  
        aux = [SELECT Id,
                        School__r.Name,
                        Degree__c,
                        FieldsOfStudy__c,
                        DateAttendedFrom__c,
                        DateAttendedTo__c
		                FROM EducationHistory__c
		                WHERE User__c =: USERID
		                order by DateAttendedFrom__c DESC];
		                
   		 List<educationHistories> educationHistory = new List<educationHistories>();
		 
		 for(EducationHistory__c educationHistories:aux){
		 	
		 	educationHistories educationHistoriesObj = new educationHistories();
		 	educationHistoriesObj.setId(educationHistories.Id);
		 	educationHistoriesObj.setSchool(educationHistories.School__r.Name);
		 	educationHistoriesObj.setDegree(educationHistories.Degree__c);
		 	educationHistoriesObj.setFieldsOfStudy(educationHistories.FieldsOfStudy__c);
		  	educationHistoriesObj.setDateAttendedFrom(educationHistories.DateAttendedFrom__c);
		 	educationHistoriesObj.setDateAttendedTo(educationHistories.DateAttendedTo__c);
		 	educationHistory.add(educationHistoriesObj);		 	
		 
		 }
		 
		 return educationHistory;
    }
    
     public class educationHistories {
    	
    	Id Id;
    	String Name;
    	String School;
    	String Degree;
    	String FieldsOfStudy;
    	Double DateAttendedFrom;
    	Double DateAttendedTo;
     	Integer DateAttendedFromInt;
     	Integer DateAttendedToInt;
    	
    	public void setId(Id sId){
                Id = sId;
        }
        
        public String getId() {
	                return Id;
		}
		
		public void setName(String sName){
                Name = sName;
        }
        
        public String getName() {
	                return Name;
		}
		
		public void setSchool(String sSchool){
                School = sSchool;
        }
        
        public String getSchool() {
	                return School;
		}
		
		public void setDegree(String sDegree){
                Degree = sDegree;
        }
        
        public String getDegree() {
	                return Degree;
		}
		
		public void setFieldsOfStudy(String sFieldsOfStudy){
                FieldsOfStudy = sFieldsOfStudy;
        }
        
        public String getFieldsOfStudy() {
	                return FieldsOfStudy;
		}
		
		public void setDateAttendedFrom(Double sDateAttendedFrom){  
			    
			    
			 DateAttendedFromInt = sDateAttendedFrom.intValue();
        }
        
        public Integer getDateAttendedFrom() {
	            return DateAttendedFromInt;
		}
		
		public void setDateAttendedTo(Double DateAttendedTo){
			
			DateAttendedToInt = DateAttendedTo.intValue();
        }
                
        public Integer getDateAttendedTo() {
	             return DateAttendedToInt;
		}
    
    }
    
    //####################################//
    // Return a list of employment history for user
    //####################################//
    
    public List<employmentHistory> getEmploymentHistories() {
        
        List<EmploymentHistory__c> aux = new List<EmploymentHistory__c>();
        
        aux = [SELECT  Id,
                        Employer__r.Name,
                        Position__c,
                        Description__c,
                        EmployerCityTown__c,
                        WorkedFrom__c,
                        IsCurrentJob__c,
                        WorkedTo__c
		                FROM EmploymentHistory__c
		                WHERE User__c =: USERID
		                order by WorkedFrom__c DESC];
		 
		 List<employmentHistory> employmentHistories = new List<employmentHistory>();
		 
		 for(EmploymentHistory__c employmentHistory:aux){
		 	
		 	employmentHistory employmentHistoryObj = new employmentHistory();
		 	employmentHistoryObj.setId(employmentHistory.Id);
		 	employmentHistoryObj.setName(employmentHistory.Employer__r.Name);
		 	employmentHistoryObj.setPosition(employmentHistory.Position__c);
		 	employmentHistoryObj.setDescription(employmentHistory.Description__c);
		 	employmentHistoryObj.setEmployerCityTown(employmentHistory.EmployerCityTown__c);
		 	employmentHistoryObj.setCurrentJob(employmentHistory.IsCurrentJob__c);
		 	employmentHistoryObj.setWorkedFrom(employmentHistory.WorkedFrom__c);
		 	employmentHistoryObj.setWorkedTo(employmentHistory.WorkedTo__c);
		 	employmentHistories.add(employmentHistoryObj);		 	
		 
		 }
		 
		 return employmentHistories;
		
    }
    
    
    
    
    public class employmentHistory {
    	
    	Id Id;
    	String Name;
    	String Position;
    	String Description;
    	String EmployerCityTown;
    	String WorkedFrom;
    	String WorkedTo;
    	String monthStringFrom;
    	String monthStringTo;
    	Boolean CurrentJob;
    	
    	public void setId(Id sId){
                Id = sId;
        }
        
        public String getId() {
	                return Id;
		}
		
		public void setName(String sName){
                Name = sName;
        }
        
        public String getName() {
	                return Name;
		}
		
		public void setPosition(String sPosition){
                Position = sPosition;
        }
        
        public String getPosition() {
	                return Position;
		}
		
		public void setDescription(String sDescription){
                Description = sDescription;
        }
        
        public String getDescription() {
	                return Description;
		}
		
		public void setEmployerCityTown(String sEmployerCityTown){
                EmployerCityTown = sEmployerCityTown;
        }
        
        public String getEmployerCityTown() {
	                return EmployerCityTown;
		}
		
		public void setCurrentJob(boolean sCurrentJob){                
                CurrentJob = sCurrentJob;                
        }
        
        public boolean getCurrentJob() {
	            return CurrentJob;
		}
		
		public void setWorkedFrom(Date sWorkedFrom){
				Integer day = sWorkedFrom.day();
			 	Integer month = sWorkedFrom.month();
			 	Integer year = sWorkedFrom.year();
			 	 
			 	if (month == 1){
			 			monthStringFrom = 'January';
			 	}
			 	if (month == 2){
			 			monthStringFrom = 'February';
			 	}
			 	if (month == 3){
			 			monthStringFrom = 'March';
			 	}
			 	if (month == 4){ 
			 			monthStringFrom = 'April';
			 	}	
			 	if (month == 5){
			 			monthStringFrom = 'May';
			 	}	
			 	if (month == 6){
			 			monthStringFrom = 'June';
			 	}	
			 	if (month == 7){
			 			monthStringFrom = 'July';
			 	}	
			 	if (month == 8){
			 			monthStringFrom = 'August';
			 	}	
			 	if (month == 9){
			 			monthStringFrom = 'September';
			 	}	
			 	if (month == 10){
			 			monthStringFrom = 'October';
			 	}	
			 	if (month == 11){
			 			monthStringFrom = 'November';
			 	}	
			 	if (month == 12){
			 			monthStringFrom = 'December';
			 	}	
			 				 	
			 	WorkedFrom =  monthStringFrom + ' ' + year;
        }
        
        public String getWorkedFrom() {
	                return WorkedFrom;
		}
		
		public void setWorkedTo(Date sWorkedTo){
				Integer day = sWorkedTo.day();
			 	Integer month = sWorkedTo.month();
			 	Integer year = sWorkedTo.year();
			 	
			 	if (month == 1){
			 			monthStringTo = 'January';
			 	}
			 	if (month == 2){
			 			monthStringTo = 'February';
			 	}
			 	if (month == 3){
			 			monthStringTo = 'March';
			 	}
			 	if (month == 4){ 
			 			monthStringTo = 'April';
			 	}	
			 	if (month == 5){
			 			monthStringTo = 'May';
			 	}	
			 	if (month == 6){
			 			monthStringTo = 'June';
			 	}	
			 	if (month == 7){
			 			monthStringTo = 'July';
			 	}	
			 	if (month == 8){
			 			monthStringTo = 'August';
			 	}	
			 	if (month == 9){
			 			monthStringTo = 'September';
			 	}	
			 	if (month == 10){
			 			monthStringTo = 'October';
			 	}	
			 	if (month == 11){
			 			monthStringTo = 'November';
			 	}	
			 	if (month == 12){
			 			monthStringTo = 'December';
			 	}	
			 	
			 	if (getCurrentJob()){
			 		WorkedTo = 'present';  
			 	}else{
			 		WorkedTo = monthStringTo + ' ' + year;  
			 	}
			 	
        }
        
        public String getWorkedTo() {
	                return WorkedTo;
		}
    
    }
	
	
	
        
	//####################################//
	// Reporting Manager
	//####################################//
	
	public PersonProfile getManager() {
		PersonProfile profile = new PersonProfile(Manager);		
		return profile;
	}	
	
	public boolean getDisplayManager(){
		return displayManager;
	}
	
	//####################################//
	// Direct reports
	// People who reports to me (i am the manager of)
	//####################################//
	
	public Integer numberOfDirectReports;
	
	public Integer getNumberOfDirectReports(){
		numberOfDirectReports = directReports.size();
		return numberOfDirectReports;
	}	
	
	public List<PersonProfile> getDirectReports() {                     
                         
            			List<PersonProfile> profiles = new List<PersonProfile>();
						
                        for(PeopleProfile__c p: directReports) {
                            profiles.add(new PersonProfile(p));
                        }
                
                        return profiles;
     }    
	
	
	public class PersonProfile {

		        PeopleProfile__c person;
		
		        public PersonProfile(PeopleProfile__c p) {
		            person = p;
		        }

		        public PeopleProfile__c getPerson() {
		            return person;
		        }
		
		        public String getImage() {
		        	String image;
					/*
		            List<Attachment> album = [SELECT Id 
		                                      FROM Attachment
		                                      WHERE ParentId =: person.Id];
		            
		            if(album.size() == 0) return '01530000000VO5s';
		            else                  return album[0].Id;
		            */
		            if(person.Picture__c == '' || person.Picture__c == null){
		            	return null;
		            }else {	
		            	image = person.Picture__c;	            	
		            	return '/servlet/servlet.FileDownload?file=' + image;
		            }
		        }

    	}
	
	//####################################//
	// Mini Feeds
	//####################################//
	   
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
								WHERE m.User__c =: USERID
								ORDER BY m.CreatedDate DESC LIMIT 5];
				
				
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
	
	//####################################//
	// Return competencies
	//####################################//  
	
	public Integer competenciesNumber;
	
	List<UserCompetencies__c> compList = new List<UserCompetencies__c>();
	
	public Integer getCompetenciesNumber() {
		return competenciesNumber;
	}
	
    public List<UserCompetencies__c> getCompetencies() {
		
		return compList;
    }
    
    
    //####################################//
	// Return list of external nets (if set)
    //####################################//
    
    public List<ExternalNetworks> getOtherNetworks(){
    	
    	List<ExternalNetworks> nets = new List<ExternalNetworks>();
    	
    	if (p.Linkedin__c != '' && p.Linkedin__c != null){ 
    		ExternalNetworks netItem = new ExternalNetworks();
    		netItem.setLink(p.Linkedin__c);
    		netItem.setNetName('linkedin');
    		nets.add(netItem);
    		}
    		
    	if (p.Facebook__c != '' && p.Facebook__c != null){ 
    		ExternalNetworks netItem = new ExternalNetworks();
    		netItem.setLink(p.Facebook__c);
    		netItem.setNetName('facebook');
    		nets.add(netItem);
    		}
    		
    	if (p.Delicious__c != '' && p.Delicious__c != null){ 
    		ExternalNetworks netItem = new ExternalNetworks();
    		netItem.setLink(p.Delicious__c);
    		netItem.setNetName('delicious');
    		nets.add(netItem);
    		}
    	
    	return nets;
    	
    }
    
    public class ExternalNetworks {
    	String Link;
    	String NetName;
    	
    	public String getLink(){
    		return Link;
    	}
    	
    	public void setLink(String sLink){
    		Link = sLink;
    	}
    	
    	public String getNetName(){
    		return NetName;
    	}
    	
    	public void setNetName(String sNetName){
    		NetName = sNetName;
    	}
    
    }
        
}