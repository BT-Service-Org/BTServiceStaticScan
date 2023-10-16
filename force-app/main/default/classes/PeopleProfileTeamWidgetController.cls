public with sharing class PeopleProfileTeamWidgetController {
	// User Id (to show all data)
	Id USERID;
	
	public void setProfileUserId(string sUserid){
		USERID = sUserid;
	}
	
	public Id getProfileUserId(){
		return USERID;
	}
	
	public PeopleProfileTeamWidgetController(){
		if(System.currentPageReference().getParameters().get('id') == null){
			USERID = UserInfo.getUserId();			
		} else {
			USERID = System.currentPageReference().getParameters().get('id');
		}
	}
	
	//####################################//
	// Return list of teamspaces of this user
    //####################################//
    
    public String teamsBullet = '';
    
    public String getTeamsBullet(){
        return teamsBullet;
    }
    
    public List<TeamMember> getTeamspaces() {
    	
    	List<TeamMember__c> temp = new List<TeamMember__c>(); 
    	List<TeamMember> TeamspaceMembers = new List<TeamMember>();
    	
    	try{
    	
	    	temp =  [Select s.Team__r.Id, s.Team__r.Name,
	    			Team__r.Description__c, Team__r.CreatedDate 
	                From TeamMember__c s
	                WHERE s.User__c =: USERID and s.Team__r.Name != '' LIMIT 5];
    	
    		for(TeamMember__c TeamspaceMember : temp){
	    		TeamMember TeamspaceMemberObj = new TeamMember();
	    		TeamspaceMemberObj.setId(TeamspaceMember.Team__r.Id);
			 	TeamspaceMemberObj.setName(TeamspaceMember.Team__r.Name);			 
			 	TeamspaceMemberObj.setDescription(TeamspaceMember.Team__r.Description__c);
			 	TeamspaceMemberObj.setCreatedDate(TeamspaceMember.Team__r.CreatedDate);
			 	TeamspaceMembers.add(TeamspaceMemberObj);		
    		 }
    		 
        
	        if(temp.size() > 1){        	
	        	teamsBullet = ' - ';
	        	return TeamspaceMembers;
	        }else{ 
	         	return TeamspaceMembers; 
	        }
	        
    	} catch(Exception e){
    		System.debug(e.getMessage());
    		return null;
    	}
    }
    
    public class TeamMember {
    	
    	Id Id;
    	String Name;
    	String Description;
    	DateTime CreatedDate;
       	String CreatedDateCorrectFormat;
       	String monthString;
        	
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
			
		public void setDescription(String sDescription){
                Description = sDescription;
        }
        
        public String getDescription() {
	                return Description;
		}
			
		public void setCreatedDate(DateTime sCreatedDate){
				Integer day = sCreatedDate.day();
			 	Integer month = sCreatedDate.month();
			 	Integer year = sCreatedDate.year();
			 	
			 	 if (month == 1){
			 			monthString = 'Jan';
			 	}
			 	if (month == 2){
			 			monthString = 'Feb';
			 	}
			 	if (month == 3){
			 			monthString = 'Mar';
			 	}
			 	if (month == 4){ 
			 			monthString = 'Apr';
			 	}	
			 	if (month == 5){
			 			monthString = 'May';
			 	}	
			 	if (month == 6){
			 			monthString = 'Jun';
			 	}	
			 	if (month == 7){
			 			monthString = 'Jul';
			 	}	
			 	if (month == 8){
			 			monthString = 'Aug';
			 	}	
			 	if (month == 9){
			 			monthString = 'Sep';
			 	}	
			 	if (month == 10){
			 			monthString = 'Oct';
			 	}	
			 	if (month == 11){
			 			monthString = 'Nov';
			 	}	
			 	if (month == 12){
			 			monthString = 'Dec';
			 	}	
			 	
			 	CreatedDateCorrectFormat = '' + monthString + ' ' + year;			 	
   		}
   		
   		public String getCreatedDate() {
	                return CreatedDateCorrectFormat;
		}
     
    }
	
}