public class PeopleEditEmploymentHistoryController {
	
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
	// WORK EXPERIENCE 
    //####################################//  
    
    
    String error = '';
    
    public String getError(){
    	return error;
    }
    
    // Get id from work experience item
    String param = System.currentPageReference().getParameters().get('id');
    
    public void setParam(String p){
    	param = p;
    }
    
    // employer Row
    Employer__c Employer;
    
    // Employment History Item row
    EmploymentHistory__c employmentItem = new EmploymentHistory__c();
    
    // Custom object 
    EmploymentItemObj em;
    
    public EmploymentItemObj getEm(){
    	return em;
    }
    
    public void setEmploymentItem(EmploymentHistory__c e){
    	employmentItem = e;
    } 
    
    // Boolean to look if the record is new
    
    public boolean isNewRecord;
    
    public boolean getIsNewRecord(){
    	return isNewRecord;
    }
    // Employer 
    public Employer__c getEmployer(){
    	return Employer;
    }
    
   	// Months	
	/////////////////
	// Get Month Name
	public String getMonthName(Integer monthNumber){
		
		String m;
			
		if(monthNumber == 1){ m = 'Jan';}
		if(monthNumber == 2){ m = 'Feb';}
		if(monthNumber == 3){ m = 'Mar';}
		if(monthNumber == 4){ m = 'Apr';}
		if(monthNumber == 5){ m = 'May';}
		if(monthNumber == 6){ m = 'Jun';}
		if(monthNumber == 7){ m = 'Jul';}
		if(monthNumber == 8){ m = 'Aug';}
		if(monthNumber == 9){ m = 'Sep';}
		if(monthNumber == 10){ m = 'Oct';}
		if(monthNumber == 11){ m = 'Nov';}
		if(monthNumber == 12){ m = 'Dec';}
		
		return m;
	}
	
	// Get Month Number
	public Integer getMonthNumber(String monthName){
		
		Integer m;
			
		if(monthName == 'Jan'){ m = 01;}
		if(monthName == 'Feb'){ m = 02;}
		if(monthName == 'Mar'){ m = 03;}
		if(monthName == 'Apr'){ m = 04;}
		if(monthName == 'May'){ m = 05;}
		if(monthName == 'Jun'){ m = 06;}
		if(monthName == 'Jul'){ m = 07;}
		if(monthName == 'Aug'){ m = 08;}
		if(monthName == 'Sep'){ m = 09;}
		if(monthName == 'Oct'){ m = 10;}
		if(monthName == 'Nov'){ m = 11;}
		if(monthName == 'Dec'){ m = 12;}
		
		return m;
	}
	
	// Constructor	
	public PeopleEditEmploymentHistoryController(){
		
		// If id is not empty
    	if (param != null){
    		isNewRecord = false;
			getEmploymentHistory(param);
    	
    	} else {
    		isNewRecord = true;
    		em = new EmploymentItemObj();
    		Employer = new Employer__c();
    	}
    	
	}
	
	public void getEmploymentHistory(String p){
	  	employmentItem = [Select 
  							Id,
	  						WorkedTo__c, 
	  						WorkedFrom__c, 
	  						User__c, 
	  						Position__c, 
	  						IsCurrentJob__c, 
	  						Employer__c,
	  						Employer__r.Name,
	  						Description__c 
	  						From EmploymentHistory__c 
							WHERE Id =: p];
        
        Employer = [select Name, Count__c,
								Id from Employer__c 
								where Id =: employmentItem.Employer__c];
		
		em = new EmploymentItemObj();
   		em.setEmployer(EmploymentItem.Employer__r.Name);
    	em.setTitle(EmploymentItem.Position__c);
    	em.setCurrentJob(EmploymentItem.IsCurrentJob__c); 
    	em.setDescription(EmploymentItem.Description__c);
    	em.setYearFrom((employmentItem.WorkedFrom__c).year());
    	em.setYearTo((employmentItem.WorkedTo__c).year());
    	em.setWorkedFromMonth(getMonthName((employmentItem.WorkedFrom__c).month()));
    	em.setWorkedToMonth(getMonthName((employmentItem.WorkedTo__c).month()));
	}
	
	//cancel command
	public PageReference cancel(){
		PageReference page = new pageReference('/apex/PeopleProfileDisplay');
		page.setRedirect(true);		
		return page;
	}
	
	// Save and add Another
	
	public boolean addAnother = false;
	
	public PageReference remove(){
		boolean isCurrentUser;

		if(employmentItem.User__c == UserInfo.getUserId()){
			employmentItem.User__c = UserInfo.getUserId();
			isCurrentUser = true;
		} else {				
			isCurrentUser = false;
		}
	
		if(isCurrentUser){
			delete employmentItem;
			Double oldCount = Employer.Count__c;
			Employer.Count__c = oldCount - 1;
			upsert Employer;
			String URL = '/apex/PeopleProfileDisplay';
			return forwardTo(URL);
		} else {
			error = 'You are not the owner of this Employment History Item '; 
			return null;
		}		
	}
	
	public boolean getDbOperation(){
		Employer__c auxEmp;	
		
		// Check if the employer exists
		if(em.Employer != EmploymentItem.Employer__r.Name){
			// Get the list of matching Employers 
			List<Employer__c> el = [select Name, Count__c,
									Id from Employer__c 
									where Name =: em.Employer];
			
			if(el.size() == 0){
				// Create new employer and set first count
				auxEmp = new Employer__c();
				auxEmp.City__c = em.EmployerLocationCity;
    			auxEmp.State__c = em.EmployerLocationState;
				auxEmp.Name = em.Employer;
				auxEmp.Count__c = 1;
				insert auxEmp;
				
				//Check if is new kid on the block
				if(!isNewRecord){
					// Decrease the count of the other employer 
					Employer__c oldEmp = [select Name, Count__c,
										Id from Employer__c 
										where Id =: Employer.Id];
										
					Double oldCount = oldEmp.Count__c;
					oldEmp.Count__c = oldCount - 1;
					upsert oldEmp;
				}
								
			} else {
				// If the record is new, and the employer exists , increase the count
				auxEmp = [select Name, Count__c,
									Id from Employer__c 
									where Id =: el[0].Id];
					
				if(isNewRecord){
					Double auxCount = auxEmp.Count__c;
					auxEmp.Count__c = auxCount + 1;
					upsert auxEmp; 
				}			
			}
			
		} else {
			// Set the aux with the old record		
			auxEmp = Employer;
		}
			
		// Build dates to insert
		String wfs = em.YearFrom + '-' + getMonthNumber(em.WorkedFromMonth) + '-01 12:00:00';
		String wts = em.YearTo + '-' + getMonthNumber(em.WorkedToMonth) + '-01 12:00:00';
		
		// String to date
		Date workedFrom = Date.valueOf(wfs);
		Date workedTo = Date.valueOf(wts);
		
		// Check the Current Job
		
		if(em.CurrentJob){
			// first clean all the other checkboxes
			List<EmploymentHistory__c> employerChecks = [Select Id, IsCurrentJob__c From EmploymentHistory__c 
									WHERE IsCurrentJob__c = true];
			
			if(employerChecks.size() != 0 ){
				for(EmploymentHistory__c bool: employerChecks){
					bool.IsCurrentJob__c = false;
					upsert bool;
				}
			}
			
			User companySet = [Select CompanyName From User where Id =: UserInfo.getUserId()];
			companySet.CompanyName = em.Employer;
			// upsert companySet;
		}
		
		// set te new values
		//search me
		employmentItem.Position__c = em.Title;
		employmentItem.IsCurrentJob__c = em.CurrentJob;		
		employmentItem.Employer__c = auxEmp.Id;
		employmentItem.Description__c = em.Description;
		employmentItem.WorkedFrom__c = workedFrom;
		employmentItem.WorkedTo__c = workedTo;
		
		return true;
		
	}
	
	
	public PageReference saveAndAddAnother() {
		
		// Check if the user are the owner of the record
		boolean isCurrentUser;
		
		if(isNewRecord){	
			employmentItem.User__c = UserInfo.getUserId();
			isCurrentUser = true;
		} else {
			if(employmentItem.User__c == UserInfo.getUserId()){
				employmentItem.User__c = UserInfo.getUserId();
				isCurrentUser = true;
			} else {				
				isCurrentUser = false;
			}
		}
		
		
		
		String URL = '/apex/PeopleEditEmploymentHistory';
		
		if(isCurrentUser){
			
			getDbOperation();
			
			if(isNewRecord){			
				insert employmentItem;
			} else {
				upsert employmentItem;
			}			
			return forwardTo(URL);
		} else {
			error = 'You are not the owner of this Employment History Item '; 
			return null;
		}
				
		
	}	
	
	//Save command
	public PageReference save() {	
		
		// Check if the user are the owner of the record
		boolean isCurrentUser;
		
		if(isNewRecord){	
			employmentItem.User__c = UserInfo.getUserId();
			isCurrentUser = true;
		} else {
			if(employmentItem.User__c == UserInfo.getUserId()){
				employmentItem.User__c = UserInfo.getUserId();
				isCurrentUser = true;
			} else {				
				isCurrentUser = false;
			}
		}
		
		String URL;
		
		URL = '/apex/PeopleProfileDisplay';
		
		if(isCurrentUser){
			
			getDbOperation();
			
			if(isNewRecord){			
				insert employmentItem;
			} else {
				upsert employmentItem;
			}
			
			return forwardTo(URL);
		} else {
			error = 'You are not the owner of this Employment History Item '; 
			return null;
		}
				
	}
	
	//FUNCTIONS
    
    public PageReference forwardTo (String url) {
		PageReference page = new pageReference(url);
		page.setRedirect(true);
		return page;
	}
	
	// Months List to combo box
	public List<SelectOption> getMonths() {
  	 	List<SelectOption> options = new List<SelectOption>();
  	 	options.add(new SelectOption('Jan','Jan'));
  	 	options.add(new SelectOption('Feb','Feb'));
  	 	options.add(new SelectOption('Mar','Mar'));
  	 	options.add(new SelectOption('Apr','Apr'));
  	 	options.add(new SelectOption('May','May'));
  	 	options.add(new SelectOption('Jun','Jun'));
  	 	options.add(new SelectOption('Jul','Jul'));
  	 	options.add(new SelectOption('Aug','Aug'));
  	 	options.add(new SelectOption('Sep','Sep'));
  	 	options.add(new SelectOption('Oct','Oct'));
  	 	options.add(new SelectOption('Nov','Nov'));
  	 	options.add(new SelectOption('Dec','Dec'));
  	 	return options;
   	}	
    
    public class EmploymentItemObj {
    	
    	
    	String Title;
    	Boolean CurrentJob; 
    	String Description;
    	Date workedTo;
    	Date workedFrom;
    	// Employer Data
    	String Employer;
    	String EmployerLocationCity;
    	String EmployerLocationState;
    	// Months
    	String WorkedFromMonth;
    	String WorkedToMonth;
    	// Year 
    	Integer YearFrom;
    	Integer YearTo;
	 
	 	// Getters / setters 
	 	public String getEmployerLocationCity() {
	  		return EmployerLocationCity;
	  	}
	  	
	  	public void setEmployerLocationCity(String EmployerLocationCity) {
	  	 	this.EmployerLocationCity = EmployerLocationCity;
	  	} 
	 	
	 	public String getEmployerLocationState() {
	  		return EmployerLocationState;
	  	}
	  	
	  	public void setEmployerLocationState(String EmployerLocationState) {
	  	 	this.EmployerLocationState = EmployerLocationState;
	  	} 
	 	
	 	public Integer getYearFrom() {
	  		return YearFrom;
	  	}
	  	
	  	public void setYearFrom(Integer YearFrom) {
	  	 	this.YearFrom = YearFrom;
	  	} 
	  	
	  	public Integer getYearTo() {
	  		return YearTo;
	  	}
	  	
	  	public void setYearTo(Integer YearTo) {
	  	 	this.YearTo = YearTo;
	  	} 
	 	
	  	public String getWorkedFromMonth() {
	  		return WorkedFromMonth;
	  	}
	  	
	  	public void setWorkedFromMonth(String WorkedFromMonth) {
	  	 	this.WorkedFromMonth = WorkedFromMonth;
	  	} 	
	  	
	  	public String getWorkedToMonth() {
	  		return WorkedToMonth;
	  	}
	  		  	
	  	public void setWorkedToMonth(String WorkedToMonth) {
	  	 	this.WorkedToMonth = WorkedToMonth;
	  	}  	
    	
    	public void setworkedTo(Date sworkedTo){ 
                workedTo = sworkedTo;                
        }
        
        public Date getworkedTo() {
	            return workedTo;
		}
		
		public void setworkedFrom(Date sworkedFrom){                
                workedFrom = sworkedFrom;                
        }
        
        public Date getworkedFrom() {
	            return workedFrom;
		}
		
    	
    	public void setDescription(String sDescription){                
                Description = sDescription;                
        }
        
        public String getDescription() {
	            return Description;
		}
		
		public void setEmployer(String sEmployer){                
                Employer = sEmployer;                
        }
        
        public String getEmployer() {
	            return Employer;
		}
		
		public void setTitle(String sTitle){                
                Title = sTitle;                
        }
        
        public String getTitle() {
	            return Title;
		}
		
		public void setCurrentJob(boolean sCurrentJob){                
                CurrentJob = sCurrentJob;                
        }
        
        public boolean getCurrentJob() {
	            return CurrentJob;
		}
    	
    }
    
    // utilities
    
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
}