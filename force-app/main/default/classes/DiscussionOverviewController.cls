public with sharing class DiscussionOverviewController {
	
	/** 
	* Current user id.
	*/
	public Id USERID = UserInfo.getUserId();
	
	public void setUserId(Id sID){
		USERID = sID;
	}
	
	/**
	* The forum list and the tab control.
	*/
	public List<TeamForums> discussionForumList = new List<TeamForums>();
	
	public boolean noForums;
	
	public boolean getNoForums(){
		return noForums;
	}
	
	String tabControl;	
	
	/**
	* Constructor
	*/
	
	public String paramAll = System.currentPageReference().getParameters().get('all'); 
	
	public void setParamAll (String paramAll) {
		this.paramAll = paramAll;
	}
	
	public DiscussionOverviewController (){ 
		constructorFunction();
	}
	
	public void constructorFunction () {
		/**
		* To show tabs, look at the param.
		*/
		if(paramAll == null || paramAll == 'myForums'){			
			discussionForumList = getDiscussionForums(USERID);
			
			tabControl = 'myForums';
		} else {
			
			discussionForumList = getDiscussionForums('');

			tabControl = 'allForums';	
		}
		
		totalItemsNumber = discussionForumList.size();
		if(totalItemsNumber == 0 ){
			noForums = true;
		} else {
			noForums = false;
		}
		
		genCntPagination();
	}
		
	
	public String getTabControl(){
		return tabControl;
	}
	
	public List<TeamForums> getForums(){		
		return discussionForumList;
	}

	/**
   	* Pagination
   	* ************
   	*/
   	
    /**
   	* Set of Integers to control pagination
   	*/
   	public Integer totalItemsNumber;
   	public Integer numberOfItemsToShow = 10;
   	public Integer cntPagination;
   	public Integer currentPagination = 1;
   	public Integer firstRow = 0;
   	
   	/**
   	* Set of Booleans to show or not prev / next links
   	*/
   	public boolean prevPageLinkShow = false;
   	public boolean prevPageShow  = false;
   	public boolean nextPageLinkShow  = false;
   	public boolean nextPageShow  = false;
   	   	
   	public void genCntPagination () {
   		
   		cntPagination = (totalItemsNumber - (Math.mod(totalItemsNumber, numberOfItemsToShow)))/ numberOfItemsToShow;	
   		if (Math.mod(totalItemsNumber, numberOfItemsToShow) != 0 ) {
   			cntPagination++;
   		} 	
   		
   	}
   	
   	public void nextPage () {
   		currentPagination++;
   		firstRow = firstRow + numberOfItemsToShow;   		
   	}
   	
   	public void prevPage () {
   		currentPagination--;
   		firstRow = firstRow - numberOfItemsToShow;	
   	}
   	
   	/**
   	* Pagination Integer Getters
   	*/
   	
   	public Integer getCurrentPagination () {
   		return currentPagination;
   	}
   	
   	public Integer getCntPagination () {
   		return cntPagination;
   	}
   	
   	public Integer getNumberOfItemsToShow () {
   		return numberOfItemsToShow;
   	}
   	
   	public Integer getFirstRow () {
   		return firstRow;
   	}
   	
   	/**
   	* Pagination Boolean Getters
   	*/
   	
	public boolean getPrevPageLinkShow () {
		
		if(currentPagination == 1){ prevPageLinkShow = false;		
		} else {prevPageLinkShow = true;}
		
   		return prevPageLinkShow;
   	}
   	
   	public boolean getPrevPageShow () {
   		
   		if(currentPagination == 1){	prevPageShow = true; 
   		} else {prevPageShow = false;}
   		
   		return prevPageShow;
   	}
   	
   	public boolean getNextPageLinkShow () {
   		
   		if((currentPagination == cntPagination) || (cntPagination == 0)){	nextPageLinkShow = false; 
		} else { nextPageLinkShow = true;}   		
   		
   		return nextPageLinkShow;
   	}
   	
   	public boolean getNextPageShow () {
   		
   		if((currentPagination == cntPagination) || (cntPagination == 0)){ nextPageShow = true; 
		} else { nextPageShow = false;} 
   		
   		return nextPageShow;
   	}

	/**
	* Inner Class to show Discussion Forum Info.
	* @param String userid The User Id, if not given , the method returns all the discussion forums available.
	* @return List<TeamForums> The list of Discussion Forums  
	*/	
	public List<TeamForums> getDiscussionForums(String userid) {
		
		List<TeamForums> discussionForumList = new List<TeamForums>();
		
		
		/**
		* If parameter is not empty, return the list of teams.
		*/
		if(userid != ''){
			/**
			* Get user team List with given ID
			*/
			
			List<TeamMember__c> teamMember = [SELECT Name, Team__c, User__c, Id FROM TeamMember__c WHERE User__c =:USERID and Team__c != null];

			List<Id> teamIds = new List<Id>();
			
			for(TeamMember__c temp:teamMember){ 
				teamIds.add(temp.Team__c);
			} 
			
			List<DiscussionForum__c> forumList = [Select 
														Name, 
														Team__c,						
														MessageCount__c, 
														TopicCount__c,
														LastPostedMessage__c, 
														Team__r.Name,
														Team__r.Description__c,
														Team__r.Picture__c 
														From DiscussionForum__c where Team__c IN :teamIds];				

			if(forumList.size() >= 1 ){	
							
					try{
					
						for(DiscussionForum__c d:forumList){
						
							if ((d.Team__c != null) || (d.Team__c != '')){
								TeamForums discussionForumListItem = new TeamForums();		
								discussionForumListItem.setTeamName(d.Team__r.Name);
								discussionForumListItem.setTeamId(d.Team__r.Id);
								discussionForumListItem.setTeamDescription(d.Team__r.Description__c);
								discussionForumListItem.setPicture(d.Team__r.Picture__c);
								discussionForumListItem.setNumberOfMessages(d.MessageCount__c);
								discussionForumListItem.setNumberOfThreads(d.TopicCount__c);	
								discussionForumListItem.setLastPostMessage(d.LastPostedMessage__c);
								discussionForumList.add(discussionForumListItem);
							}					
						}
						
					} catch (Exception e ){
						System.debug('\n //////////////////////////////////////////////// \n Exception Catch  : \n' + e );						
					}					
				}
			} else {
			/**
			* All teams
			*/
			
			List<DiscussionForum__c> d = new List<DiscussionForum__c>();
			
			d = [Select 
						Name, 
						Team__c,						
						MessageCount__c, 
						TopicCount__c,
						LastPostedMessage__c,
						Team__r.Name,
						Team__r.Description__c,
						Team__r.Picture__c 
						From DiscussionForum__c ];
						
			for(DiscussionForum__c team:d){	
				TeamForums discussionForumListItem = new TeamForums();		
				discussionForumListItem.setTeamName(team.Team__r.Name);
				discussionForumListItem.setTeamDescription(team.Team__r.Description__c);
				discussionForumListItem.setPicture(team.Team__r.Picture__c);
				discussionForumListItem.setTeamId(team.Team__c);
				discussionForumListItem.setNumberOfMessages(team.MessageCount__c);
				discussionForumListItem.setNumberOfThreads(team.TopicCount__c);	
				discussionForumListItem.setLastPostMessage(team.LastPostedMessage__c);
				discussionForumList.add(discussionForumListItem);	
			}						
		}
				
		return discussionForumList;
				
	}
	
	/**
	* Inner Class to show Discussion Forum Info.
	* @return String TeamName 
	* @return String TeamDescription 
	* @return Integer NumberOfMessages 
	* @return Integer NumberOfThreads
	* @return String LastPostMessage 
	*/
	public class TeamForums {
		
		String TeamId;
		String TeamName;
		String TeamDescription;
		Integer NumberOfMessages;
		Integer NumberOfThreads;
		String LastPostMessage;
		String Picture;
		
		/**
		* Setters 
		*/
		
		public void setTeamId(String sTeamId){
                TeamId = sTeamId;
        }
        
    	public void setTeamName(String sTeamName){
                TeamName = sTeamName;
        }
        
        public void setTeamDescription(String sTeamDescription){
                TeamDescription = sTeamDescription;
        }
        
        public void setNumberOfMessages(Double sNumberOfMessages){
                NumberOfMessages = sNumberOfMessages.intValue();
        }

        public void setNumberOfThreads(Double sNumberOfThreads){
                NumberOfThreads = sNumberOfThreads.intValue();
        }
        
        public void setLastPostMessage(Id sLastPostMessage){
                LastPostMessage = lastPostInfoString(sLastPostMessage);
        }
        
        public void setPicture(String teamAvatar){
        	Picture = teamAvatar;
        }
        
        /**
		* Getters 
		*/
		
		public String getTeamId() {
	                return TeamId;
		}
		
        public String getTeamName() {
	                return TeamName;
		}		
        
        public String getTeamDescription() {
	                return TeamDescription;
		}
		
		public Integer getNumberOfMessages() {
	                return NumberOfMessages;
		}
		
		public Integer getNumberOfThreads() {
	                return NumberOfThreads;
		}	
		
		public String getLastPostMessage() {
	        	return LastPostMessage;
		}
		
		public String getImage(){			
		  if(Picture == null)
		  	return '';
		  else
		  	return Picture;				
		}
		
		/**
		* Method to convert dates.
		* @return String datestring The string of the lastest reply. 
		*/
		public String lastPostInfoString(Id dm){
			
			String lastPostString = '';
			String message = '';
			if (dm != null){
				List<DiscussionMessage__c> dms = new List<DiscussionMessage__c>();
								
				dms = [ Select 
						LastModifiedDate, 
						DiscussionTopic__r.Subject__c, 
						DiscussionTopic__c,
						PostedBy__r.Name, 
						PostedBy__r.Id,
						PostedBy__c From DiscussionMessage__c where id =: dm];
						
				if(dms.size() > 0){
					
					DiscussionMessage__c d = dms[0];
					 
					Integer today = (System.now()).day();
					
					String dateInfo;
					
					if(today == (d.LastModifiedDate).day()){
						dateInfo = 'Today, at ' + (d.LastModifiedDate).format('HH:mm') + ' ' + (d.LastModifiedDate).format('aa');	
					} else {
						dateInfo = '' + (d.LastModifiedDate).day() + ' of '+ (d.LastModifiedDate).format('MMMM') + ' at ' +(d.LastModifiedDate).format('HH:mm') + ' ' + (d.LastModifiedDate).format('aa');
					}	
					
					message = d.DiscussionTopic__r.Subject__c;
					if(message != null && message.length() > 25){
						message = message.substring(0,25) + '...';
					}					
			 		lastPostString = ' ' + dateInfo + ' in ' + message + ' by ' + d.PostedBy__r.Name;
			 		
				} else {
					lastPostString = 'This Forum has no messages yet.';
				}
				
			} else {
				lastPostString = 'This Forum has no messages yet.';
			}
		 			
			return lastPostString;
		}	
	}
	
	 	//********************************************************************************
	//******************* BlogWidgets Most Active People *****************************
	
	public List<ActiveUser> getMostActiveUsers(){
	
		Date first = System.today().toStartOfWeek();
    	Datetime firstWeekDay = Datetime.newInstance(first.year(), first.month(), first.day(), 0, 0, 0);
    	Datetime lastWeekDay = firstWeekDay.addDays(7);
		Map<Id, ActiveUser> tempmap = new Map<Id, ActiveUser>();
		List<ActiveUser> mostActiveUsers = new List<ActiveUser>();
		Integer i;
		
							
		for(DiscussionForum__c disc : [Select  
										Name, 
										Team__c,						
										MessageCount__c, 
										TopicCount__c,
										LastPostedMessage__c,
										Team__r.Name,
										Team__r.Description__c,
										CreatedDate,
										CreatedBy.Name,
										CreatedById
										From DiscussionForum__c
								//Where PostedDate__c <: lastWeekDay 
					 			//AND PostedDate__c >: firstWeekDay
					 			
					 			]){
			
			if(tempmap.containsKey(disc.CreatedById)){
				ActiveUser activeUser = tempmap.get(disc.CreatedById);
				Integer tempCount = activeUser.getMostActive() + 1;
				activeUser.setMostActive(tempCount); 
				tempmap.put(disc.CreatedById, activeUser);
			}
			else
			{
				ActiveUser activeUser = new ActiveUser();
				activeUser.setMostActive(1);
				activeUser.setId (disc.CreatedById);
				activeUser.setName(disc.CreatedBy.Name);
				activeUser.setPicture (disc.CreatedById);
				tempmap.put(disc.CreatedById, activeUser);
			}
		}	
			
		List<ActiveUser> activeUserList = tempmap.values();		 				
		this.sortResult(activeUserList);
		
		for(i = 0; i <= 5; i++ ){
			if(i < activeUserList.size()){
				activeUserList[i].commentCount();
				mostActiveUsers.add(activeUserList[i]);
			}
		}	
		return mostActiveUsers;
	}
	
	public List<ActiveUser> sortResult (List<ActiveUser> result) {
 		Integer n;
 		Integer i;
 		Integer j;
 		n = result.size() - 1;	
 		for (i = 1; i <= n; i++) {	
 			for (j = n; j >= i ; j--) {
 				if (result.get(j).getMostActive() >= result.get(j - 1).getMostActive()) {
 					ActiveUser tempActiveUser;
 					tempActiveUser = result.get(j - 1);
 					result.set(j - 1, result.get(j));
 					result.set(j, tempActiveUser); 	
 				}	
 			}
 		}
 		return result;
 	}	
 	
	
	public class ActiveUser{
		
		//******************* Attributs ***************************************
		
		public String userPicture;
		public Integer mostActive;
		public String name;
		public Integer commentsCount;
		public String id;
		//*********************************************************************
		//******************* Constructor *************************************
		
		public ActiveUser(){
			
		}
		public ActiveUser(String id){
			
		}
		
			
		/**
		*@void
		*/
		public void commentCount(){
			this.commentsCount = [Select count() From DiscussionMessage__c where PostedBy__c =: id];	
		}
		
		//*********************************************************************
		//******************* Getters *****************************************
		
		public Integer getMostActive(){
						
				return 	mostActive;
		}	
		
		public String getName(){
		
				return 	name;
		}	
		
		public String getId(){
		
				return 	id;
		}	
		
		public Integer getCommentsCount(){
		
				return 	commentsCount;
		}
		
		public String getPicture(){
			return this.userPicture;
		}
		//********************************************************************
		//******************* Seters *****************************************
		
		public void setMostActive(Integer mActive){
				
			mostActive = mActive;
		}
		
		public void setName(String sName){
				
			name = sName;
		}
		public void setId(String id){
				
			this.id = id;
		}
		public void setCommentsCount(Integer countComments){
				
			commentsCount = countComments;
		}
		
		public void setPicture (String userId) {
			String PictureId;
			Integer cntPicture;
			
			cntPicture = [SELECT count() FROM PeopleProfile__c WHERE User__c =:userId];
			
			if (cntPicture != 0) {
				PeopleProfile__c picture = [SELECT Picture__c FROM PeopleProfile__c WHERE User__c =:userId limit 1];
		        if(picture.Picture__c == '' || picture.Picture__c == null) {                	                                          	 
			     	PictureId = '01530000000VO5s';
				} 
				else {
					PictureId = picture.Picture__c;
				} 
			}
			else {
				PictureId = '01530000000VO5s';
			}
   			this.userPicture = PictureId ;
   		}
		//*******************************************************************
	}
	
	
}