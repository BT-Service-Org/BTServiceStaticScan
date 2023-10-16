public class PeopleNewEditCompetencyController {
	
	
	public  PeopleNewEditCompetencyController(ApexPages.StandardController controller){
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
	
    public static String PAGE_PROFILE = '/apex/PeopleProfileDisplay';
    	
 	// Error string to show the mistake.
    public String error = '';
    
    // Error getter
    public String getError(){
        return error;
    }
    
	// User
    //////////////////////////////////////  
 	String userId = System.currentPageReference().getParameters().get('id');
 	public void setUserId(String s){
 		userId = s;
 	}
 	
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
                        WHERE id =: userId];                           
        }
                
	// Return the user for show details
    /////////////////////////////////////////////
    public User getNewUser() {
        return newUser;
    }
    
    //############################################//   
  	//   USER COMPETENCIES
   	//############################################//
   	
   	// Boolean to look if the record is new
    
    public boolean isNewRecord;
    
    public boolean getIsNewRecord(){
    	return isNewRecord;
    }
        
    Competency__c newCompetency;
    
    // Create a new competency for user
    /////////////////////////////////////   
    
    public Competency__c getNewCompetency() {
   		if(newCompetency == null) 
   			newCompetency = new Competency__c();
    	return newCompetency;      
    }
    
    /**
    *@param Competency__c
    *@void
    */
    public void setNewCompetency(Competency__c c){
    	newCompetency = c;
    }    
   	
    public String nameCompetency = '';
    
    // nameCompetency getter
    public String getNameCompetency(){
        return nameCompetency;
    }
    
    /**
    *@void
    *@param String
    */
    public void setNameCompetency(String s){
    	nameCompetency = s;
    }
    
    public String returnRating = '';
    
    public String getReturnRating(){
        return returnRating;
    }
    
   
    //////////////////////////////////////    
    UserCompetencies__c newUserCompetency;
    
  	// Return the user competency for show details
    /////////////////////////////////////////////
    public UserCompetencies__c getNewUserCompetency() {
    	
       if(newUserCompetency == null) newUserCompetency = new UserCompetencies__c();       
		return newUserCompetency;
    }
    
    /**
    *@void
    *@param UserCompetencies__c
    */    
    public void setNewUserCompetency(UserCompetencies__c uc){
    	newUserCompetency = uc;	
    }
    
	// Edit a competency
    /////////////////////////////////  
    public void getCompetency() {
    	
    	String param = System.currentPageReference().getParameters().get('id');
	    	if (param == null){
	    		newUserCompetency = null;
	    		newCompetency = null;
	    		nameCompetency = '';
	    		isNewRecord = true;
	    		returnRating = '5';	    		
	    	}
	    	else{
	    		isNewRecord = false;
	    		
	    	  	newUserCompetency = [Select Name, Competency__c, Id, Rating__c,User__c, 
	    	  						InterestedInProvidingAssistance__c, InterestedInLearning__c
									From UserCompetencies__c c
									WHERE c.Id =: param];
    	        
    	        returnRating = String.valueOf(newUserCompetency.Rating__c);
    	                    
				newCompetency = [select Name, Count__c, 
										Id from Competency__c 
										where Id =: newUserCompetency.Competency__c];
										
				nameCompetency = newCompetency.Name;
					
	    	}
    }
    
    public static String EDIT_COMPETENCY = '/apex/PeopleEditCompetency';
    
    public PageReference saveAndNewCompetency() {
		PAGE_PROFILE = EDIT_COMPETENCY;
		saveCompetency();
		return forwardTo(EDIT_COMPETENCY);
	}
    
      
	// Save the new competency
    ////////////////////////////////////     
   	
    public PageReference saveCompetency() {
    	
    		Savepoint sp = Database.setSavepoint();
		// try catch		
		try {	
									
			// check if exist a competency whith the name edited
			List<Competency__c>  auxCompetency ;
			auxCompetency  =  [Select c.SystemModstamp, 
									c.Scale__c, 
									c.OwnerId, 
									c.Name,									
									c.LastModifiedDate, 
									c.LastModifiedById,									
									c.IsDeleted, 
									c.CreatedDate, 
									c.CreatedById, 
									c.Count__c From Competency__c c
									 where Name =: newCompetency.Name];
			 
			 // if not exist
			
			if (auxCompetency.size() == 0){
				
				//create a new competency whith the new name
				Competency__c newComp = new Competency__c() ;
				newComp.Name = newCompetency.Name;			
				newComp.Count__c = 1;
				insert newComp;
				
					if(nameCompetency != ''){
												
						if (UserInfo.getUserId() == newUserCompetency.User__c){
							// -1 count old competency
							newCompetency.Count__c = newCompetency.Count__c - 1;
							newCompetency.Name = nameCompetency; 
							upsert newCompetency;	
						}
					}
					
				//set the id of the new competency			
				newUserCompetency.Competency__c = newComp.Id;
				newUserCompetency.User__c = UserInfo.getUserId();
				upsert newUserCompetency;	
					
			}else{
								
					if(nameCompetency != ''){
							
						if (UserInfo.getUserId() == newUserCompetency.User__c){							
							// if the id of the competencies are the same just upsert
							if(auxCompetency[0].Id == newCompetency.Id){
								upsert newUserCompetency;	
										
							}		
							// if the id of the competencies are differents
							else{
								// -1 count old competency
								newCompetency.Count__c = newCompetency.Count__c - 1;		
								newCompetency.Name = nameCompetency;							
								upsert newCompetency;		
							
								//set the count + 1 of the new competency
								auxCompetency[0].Count__c = auxCompetency[0].Count__c + 1;
								upsert auxCompetency[0];	
								
								// check if exist a UserCompetency of the User whith the same Competency
								List<UserCompetencies__c>  auxUserCompetency ;
								auxUserCompetency  =   [Select Name, Competency__c, Id, Rating__c
										From UserCompetencies__c c
										WHERE User__c =: UserInfo.getUserId() and Competency__c =: auxCompetency[0].Id];
														 
									 // if not exist				
									if (auxUserCompetency.size() == 0){
								
										newUserCompetency.Competency__c = auxCompetency[0].Id;
										upsert newUserCompetency;	
									}
									else
									{
										Database.rollback(sp);	
										error = ' The User already have a competency with that name '; 
										return null;
									}				
								}
							} 
						else{
							Database.rollback(sp);	
						 	error = 'You do not have permission to modify the data of competency'; 
						 	return null;
							}	
							
												
					}
					else{
							//set the count + 1 of the new competency
							auxCompetency[0].Count__c = auxCompetency[0].Count__c + 1;
							upsert auxCompetency[0];	
							
								// check if exist a UserCompetency of the User whith the same Competency
									List<UserCompetencies__c>  auxUserCompetency ;
									auxUserCompetency  =   [Select Name, Competency__c, Id, Rating__c
											From UserCompetencies__c c
											WHERE User__c =: UserInfo.getUserId() and Competency__c =: auxCompetency[0].Id];
															 
									 // if not exist	
									 								
									if (auxUserCompetency.size() == 0){
										//create a newuserCompetency						
										UserCompetencies__c newUserComp = new UserCompetencies__c() ;
										newUserComp.Rating__c = newUserCompetency.Rating__c;
										newUserComp.Competency__c = auxCompetency[0].Id; 
										newUserComp.User__c = UserInfo.getUserId();
										newUserComp.InterestedInProvidingAssistance__c = newUserCompetency.InterestedInProvidingAssistance__c;										
										newUserComp.InterestedInLearning__c = newUserCompetency.InterestedInLearning__c;										
										insert newUserComp;	
									}
									else{ 
										 	Database.rollback(sp);	
										 	error = ' The User already have a competency with that name '; 
										 	return null;
									}														
							}
				}
				  return forwardTo(PAGE_PROFILE);
       	
		}catch (Exception e){	
		   	Database.rollback(sp);	
		    getCompetency();	
		 	error = ' Rating must be a number between 0 and 10'; 
			return null;			
		}		
    }

    // Cancel the new competency
    /////////////////////////////////  
    public PageReference cancelCompetency() {
		error = '';       
 	  	getCompetency();      
        return null;
    }


	// Delete competency
    ////////////////////////////////  
	String userCompId = System.currentPageReference().getParameters().get('id');
	public void setUserCompId(String s){
		userCompId = s;
	}
	
    public PageReference deleteCompetency() {
    	
    	// try catch		
		try {	
	   			
	   		if (UserInfo.getUserId() == newUserCompetency.User__c){
				String idComp;
		        UserCompetencies__c temp = [SELECT Id ,Competency__c
		                                                FROM UserCompetencies__c
		                                                WHERE Id =: userCompId];
		        idComp = temp.Competency__c;
		        delete temp;   
		          
		       	//the count of the competency -1
		       	Competency__c newTempCompetency = [select Name, Count__c, 
											Id from Competency__c 
											where Id =: idComp];
											
				newTempCompetency.Count__c = newTempCompetency.Count__c - 1;
				upsert newTempCompetency;
							 				
		       return forwardTo(PAGE_PROFILE);
	   		}
	   		else{
	   				error = 'You do not have permission to modify the data of competency'; 
					return null;
	   		}	   		
	       
	    } catch (Exception e) {
				
			error = ' The Competency cannot  be deleted'; 
			return null;
				
		}
		
    }	
    
    //cancel command
	public PageReference cancel(){
		PageReference page = new pageReference('/apex/PeopleProfileDisplay');
		page.setRedirect(true);		
		return page;
	}
    
    //FUNCTIONS
    
    public PageReference forwardTo (String url) {
		PageReference page = new pageReference(url);
		page.setRedirect(true);
		return page;
	}
}