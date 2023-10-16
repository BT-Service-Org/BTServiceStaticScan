public class PeopleEditEducationHistoryController {
	
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
		
        if(p.Picture__c == '' || p.Picture__c == null){                	                                          	 
	     			MyPictureId = '01530000000VO5s';
		} else{
			MyPictureId = p.Picture__c;
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
	
	//####################################//
	// EDIT EDUCATION HISTORY
    //####################################// 
    
    // Error display    
    String error = '';
    
    public String getError(){
    	return error;
    } 
    
    // Get id from work experience item
    String param = System.currentPageReference().getParameters().get('id');
    
    /**
    *@param String param
    */
    public void setParam(String p){
    	param = p;
    }
    
    // employer Row
    School__c School;
    
    // Employment History Item row
    EducationHistory__c educationItem = new EducationHistory__c();
    
    // Custom object 
    EducationItemObj ed;
    
    public EducationItemObj getEd(){
    	return ed;
    }
    
    public void setEd(EducationItemObj e){
    	ed = e;
    } 
    
    public void setEducationItem(EducationHistory__c eh){
    	educationItem = eh;
    }
    
    // Boolean to look if the record is new    
    public boolean isNewRecord;
    
    public boolean getIsNewRecord(){
    	return isNewRecord;
    }
    
    public void setIsNewRecord(Boolean b){
    	isNewRecord = b;
    } 
    
    // Employer 
    public School__c getSchool(){
    	return School;
    }
    
	
	// Constructor	
	public PeopleEditEducationHistoryController(){
		
		// If id is not empty
    	if (param != null){
    		isNewRecord = false;
    		getEducationHistory(param);
    	} else {
    		isNewRecord = true;    		
    		ed = new EducationItemObj();
    		School = new School__c();
    		    	
    	}
    	
	}
	
	public void getEducationHistory(String p){
    	  	educationItem = [Select 
    	  						Id,
	    	  					School__c, 
	    	  					School__r.Name,
	    	  					School__r.Count__c,
	    	  					FieldsOfStudy__c, 
	    	  					Degree__c, 
	    	  					DateAttendedTo__c, 
	    	  					DateAttendedFrom__c, 
	    	  					AdditionalNotes__c, 
	    	  					User__c,
	    	  					Activities__c From EducationHistory__c Where Id =: p];
	        
	        School = [select Name, Count__c,
									Id from School__c 
									where Id =: educationItem.School__c];
			
			ed = new EducationItemObj();
			ed.setSchool(educationItem.School__r.Name);
	   		ed.setFieldsOfStudy(educationItem.FieldsOfStudy__c);
	   		ed.setDegree(educationItem.Degree__c);
	   		ed.setAdditionalNotes(educationItem.AdditionalNotes__c);
	   		ed.setActivities(educationItem.Activities__c);
	   		ed.setAttendedTo(educationItem.DateAttendedTo__c);
	   		ed.setAttendedFrom(educationItem.DateAttendedFrom__c);	
	}
	
	
	// Do all the magic to set count and things like these
	/////////////////////////////////////////////////////
	public boolean getDbOperation() {
		
		School__c auxSchool;	
		
		// Check if the School exists exists
		if(ed.School != educationItem.School__r.Name){
			
			// Get the list of matching Employers 
			List<School__c> el = [select Name, Count__c,
									Id from School__c 
									where Name =: ed.School];
			
			if(el.size() == 0){
				
				// Create new School and set first count
				auxSchool = new School__c();
				auxSchool.Name = ed.School;
				auxSchool.City__c = ed.SchoolLocationCity;
				auxSchool.State__c = ed.SchoolLocationState;
				auxSchool.Count__c = 1;
				insert auxSchool;
				
				//Check if is new kid on the block
				if(!isNewRecord){
					// Decrease the count of the other employer 
					School__c oldSchool = [select Name, Count__c,
										Id from School__c 
										where Id =: School.Id];
										
					Double oldCount = oldSchool.Count__c;
					oldSchool.Count__c = oldCount - 1;
					upsert oldSchool;
				}
								
			} else {
				// If the record is new, and the school exists , increase the count
				if(isNewRecord){
					auxSchool = [select Name, Count__c,
									Id from School__c 
									where Id =: el[0].Id];
					
					Double auxCount = auxSchool.Count__c;
					auxSchool.Count__c = auxCount + 1;
					upsert auxSchool; 
				}			
			}
			
		} else {
			// Set the aux with the old record		
			auxSchool = School;
		}
		
		String fakeDateTo = String.valueOf(ed.AttendedTo)+ '.0';
		String fakeDateFrom = String.valueOf(ed.AttendedFrom)+ '.0';
		
		// set te new values
		educationItem.School__c = auxSchool.Id;
		educationItem.FieldsOfStudy__c = ed.FieldsOfStudy;
		educationItem.Degree__c = ed.Degree;
		educationItem.AdditionalNotes__c = ed.AdditionalNotes;
		educationItem.Activities__c = ed.Activities;
		educationItem.DateAttendedTo__c = Double.valueOf(fakeDateTo);
		educationItem.DateAttendedFrom__c = Double.valueOf(fakeDateFrom);
		// educationItem.User__c = UserInfo.getUserId();
		
		return true;
	
	}
	
	
	//Save command
	//////////////////
	public PageReference save() {	
		
		// Check if the user are the owner of the record
		boolean isCurrentUser;
		
		if(isNewRecord){	
			educationItem.User__c = UserInfo.getUserId();
			isCurrentUser = true;
		} else {
			if(educationItem.User__c == UserInfo.getUserId()){
				educationItem.User__c = UserInfo.getUserId();
				isCurrentUser = true;
			} else {				
				isCurrentUser = false;
			}
		}
		
		String URL;
		
		PageReference pageRef = new PageReference('/apex/PeopleProfileDisplay');
		pageRef.setRedirect(true);
		
		if(isCurrentUser){
			getDbOperation();
			
			if(isNewRecord){			
				insert educationItem;
			} else {
				upsert educationItem;
			}
			return pageRef;
		} else {
			error = 'You are not the owner of this Education History Item '; 
			return null;
		}
				
	}
	
	// Remove
	///////////////////////////
	
	public PageReference remove(){		
			
		boolean isCurrentUser;
		
		
		if(educationItem.User__c == UserInfo.getUserId()){
			educationItem.User__c = UserInfo.getUserId();
			isCurrentUser = true;
		} else {				
			isCurrentUser = false;
		}
	
		
		if(isCurrentUser){
		
			delete educationItem;
			
			Double oldCount = School.Count__c;
			School.Count__c = oldCount - 1;
			
			upsert School;
			
			String URL = '/apex/PeopleProfileDisplay';
					
			return forwardTo(URL);
			
		} else {
			error = 'You are not the owner of this Education History Item '; 
			return null;
		}		
	}
	
	// Save and add Another
	//////////////////////////////	
	public PageReference saveAndAddAnother() {
		
		// Check if the user are the owner of the record
		boolean isCurrentUser;
		
		if(isNewRecord){	
			educationItem.User__c = UserInfo.getUserId();
			isCurrentUser = true;
		} else {
			if(educationItem.User__c == UserInfo.getUserId()){
				educationItem.User__c = UserInfo.getUserId();
				isCurrentUser = true;
			} else {				
				isCurrentUser = false;
			}
		}		
		
		PageReference pageRef = new PageReference('/apex/PeopleEditEducationHistory');
		pageRef.setRedirect(true);
		
		if(isCurrentUser){
			
			getDbOperation();
			
			if(isNewRecord){			
				insert educationItem;
			} else {
				upsert educationItem;
			}			
			return pageRef;
		} else {
			error = 'You are not the owner of this Education History Item '; 
			return null;
		}				
		
	}	
	
	// Cancel Link
	/////////////////////////////
    public PageReference cancel(){
		PageReference page = new pageReference('/apex/PeopleProfileDisplay');
		page.setRedirect(true);		
		return page;
	}
	
	// Inner Class
	//////////////////////////////	
    public class EducationItemObj {
    	
    	String FieldsOfStudy;
    	String Degree;
    	String AdditionalNotes;
    	String Activities;
    	// School Data
    	String School;
    	String SchoolLocationCity;
    	String SchoolLocationState;
    	// dates
    	Integer AttendedTo;
    	Integer AttendedFrom;
     
	 	// Getters / setters 
	 	
	 	public String getSchoolLocationState() {
	  		return SchoolLocationState;
	  	}
	  	
	  	public void setSchoolLocationState(String SchoolLocationState) {
	  	 	this.SchoolLocationState = SchoolLocationState;
	  	} 	
	  	
	 	public String getSchoolLocationCity() {
	  		return SchoolLocationCity;
	  	}
	  	
	  	public void setSchoolLocationCity(String SchoolLocationCity) {
	  	 	this.SchoolLocationCity = SchoolLocationCity;
	  	} 	
	 	
	 	public String getSchool() {
	  		return School;
	  	}
	  	
	  	public void setSchool(String School) {
	  	 	this.School = School;
	  	} 	  	
	  	
	 	public String getFieldsOfStudy() {
	  		return FieldsOfStudy;
	  	}
	  	
	  	public void setFieldsOfStudy(String FieldsOfStudy) {
	  	 	this.FieldsOfStudy = FieldsOfStudy;
	  	} 
	  	
	  	public String getDegree() {
	  		return Degree;
	  	}
	  	
	  	public void setDegree(String Degree) {
	  	 	this.Degree = Degree;
	  	} 
	  	
	  	public String getAdditionalNotes() {
	  		return AdditionalNotes;
	  	}
	  	
	  	public void setAdditionalNotes(String AdditionalNotes) {
	  	 	this.AdditionalNotes = AdditionalNotes;
	  	} 
	  	
	  	public String getActivities() {
	  		return Activities;
	  	}
	  	
	  	public void setActivities(String Activities) {
	  	 	this.Activities = Activities;
	  	} 
	  	
	  	public Integer getAttendedTo() {
	  		return AttendedTo;
	  	}
	  	
	  	public void setAttendedTo(Double AttendedTo) {
	  	 	this.AttendedTo = AttendedTo.intValue();
	  	} 
	  	
	  	public Integer getAttendedFrom() {
	  		return AttendedFrom;
	  	}
	  	
	  	public void setAttendedFrom(Double AttendedFrom) {
	  	 	this.AttendedFrom = AttendedFrom.intValue();
	  	}    	
    }
    
    // Utilities
    
    public List<SelectOption> getStates() {
  	 	List<SelectOption> options = new List<SelectOption>();
  	 	options.add(new SelectOption('ST','ST'));
  	 	options.add(new SelectOption('NY','NY'));
  	 	options.add(new SelectOption('DC','DC'));
  	 	options.add(new SelectOption('OK','OK'));
  	 	options.add(new SelectOption('EC','EC'));
  	 	options.add(new SelectOption('RC','RC'));  	 	
  	 	return options;
   	}	
    
    public PageReference forwardTo (String url) {
		PageReference page = new pageReference(url);
		page.setRedirect(true);
		return page;
	}
	
}