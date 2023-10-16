public with sharing class DiscussionTopicsController {
	
   /* ---------------------------- */
   /*        SHARING RULES         */
   /* ---------------------------- */   
    public UserPermissions userPermissions = new UserPermissions();
   	
   	public void refreshList() {
   		if(TEAMID != null){
			topicList = fillTopicList();
			totalItemsNumber = topicList.size();		
			if (topicList.size() == 0){
				cntPagination = 0;
				noTopics = true;
			} else {
				noTopics = false;
				genCntPagination();
			}			
		}
   	}
   
    public void genPermissions () {
        userPermissions.setId(UserInfo.getUserId());
        userPermissions.setTeam(TEAMID);
        userPermissions.setObjectType('Discussion');
        userPermissions.setPermissions();       
    }
   
    public UserPermissions getUserPermissions () {
        System.debug('\n //////////////////////// \n USER PERMISSIONS: \n' + userPermissions + '\n //////////////////////////////// \n');
        return userPermissions;
    }
    
    public boolean isManager;
    
    /* ---------------------------- */  
    
	/**
	* forum Id
	*/
	
	public String TEAMID = System.currentPageReference().getParameters().get('id');
	
	public List<TopicList> topicList = new List<TopicList>();
	
	public String breadCrumb;
	
	public boolean noTopics = true;
	
	public void setTEAMID (String s){
		TEAMID = s;
	}
	
	public boolean getNoTopics(){
		System.debug('\n ////////////////////////// \n GUARDE ESTE NOTOPIC: \n' + noTopics + '\n ////////////////////////// \n');
		return noTopics;
	}
	
	/**
	* Constructor
	*/
	public DiscussionTopicsController (){
		genPermissions();
		isManager = userPermissions.getcanManage();
		if(TEAMID != null){
			topicList = fillTopicList();
			totalItemsNumber = topicList.size();		
			if (topicList.size() == 0){
				cntPagination = 0;
				noTopics = true;
			} else {
				noTopics = false;
				genCntPagination();
			}			
		} else {			
			System.Debug('/n \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ /n No forum id ');
		}	

	}
	
	public List<TopicList> getTopicList(){
		
		System.debug('topicList ' + topicList);
		System.debug('sizee ' + topicList.size());
		return topicList;
	}
	
	public List<TopicList> fillTopicList(){
		List<DiscussionTopic__c> discussionTopicList = new List<DiscussionTopic__c>();
		List<TopicList> topicListAux = new List<TopicList>();
		List<PeopleProfile__c> peopleProfiles = new List<PeopleProfile__c>();
		discussionTopicList = [Select   Id,	ViewCount__c, 
										Team__c, Team__r.Name,
										Subject__c, Name, 
										MessageCount__c, PostedBy__r.Name,
										PostedBy__r.Id, LastPostedMessage__c, 
										DiscussionForum__c, 
										(Select	Id,PostedDate__c,DiscussionTopic__c,Subject__c,PostedBy__c,Message__c,ParentMessage__c,Team__c 
										 From DiscussionTopic__r  
										 order by PostedDate__c asc
										 limit 1)
								From DiscussionTopic__c d
								where Team__c =: TEAMID
								order by PostedDate__c desc];
								
		peopleProfiles = [Select Id, Picture__c, User__c From PeopleProfile__c];
		
		for(DiscussionTopic__c t : discussionTopicList){	
			
				TopicList topic = new TopicList();
				for(PeopleProfile__c p : peopleProfiles){
					if(p.User__c == t.PostedBy__r.Id){
						topic.setAuthorPicture(p.Picture__c);
					}
				}				
				topic.setAuthorId(t.PostedBy__r.Id);
				topic.setNumberOfViews(t.ViewCount__c);
				topic.setId(t.Id);	
				topic.setName(t.Subject__c);						
				topic.setTeamId(t.Team__c);
				topic.setAuthorName(t.PostedBy__r.Name);
				topic.setTeamName(t.Team__r.Name);
				topic.setNumberOfMessages(t.MessageCount__c);				
				topic.setLastPostMessage(t.LastPostedMessage__c);
				
				if(t.DiscussionTopic__r.size() > 0)
					topic.setFirstMessageCreated(t.DiscussionTopic__r.get(0));
				
				topic.setEnableActions(t.PostedBy__r.Id, isManager);
				System.debug('\n\n---------------------o-o-o-\n\n' + t.PostedBy__r.Id +'-----p-p-p-----'+ isManager );
				topicListAux.add(topic); 	
		}
		
		return topicListAux;							
	}
	
	/**
	* Inner Class to Update Topic Count.
	*/
	public without sharing class updateviewCount {
		
		public String topicId;
		
		public void setTopicId(String sTopic){
			topicId = sTopic;
		}
		
		public String getTopicId(){
			return topicId;
		}
				
		public void updateviewCountRedirect(){
			
			List<DiscussionTopic__c> topic = [select Id, ViewCount__c, LastViewedDate__c from DiscussionTopic__c where id =: topicId];
			if (topic.size() > 0) {
				topic[0].ViewCount__c = topic[0].ViewCount__c + 1;
				topic[0].LastViewedDate__c = System.now();
				upsert topic;
			}
			
		}
		
		public PageReference getTopicPage(){
			updateviewCountRedirect();
			PageReference dd = new PageReference('/apex/DiscussionDetail?id=' + topicId);
			dd.setRedirect(true);
			return dd;
		}
	}
	
	public PageReference openTopic(){
		updateviewCount upd = new updateviewCount();
		upd.setTopicId(System.currentPageReference().getParameters().get('topicID'));
		return upd.getTopicPage();		
	} 
	
	
	/**
	* Inner Class to show Discussion Topics.
	* @return String TeamName 
	* @return Integer NumberOfMessages 
	* @return Integer NumberOfViews
	* @return String LastPostMessage 
	*/
	public class TopicList {
		
		String AuthorPicture;
		String AuthorId;
		String AuthorName;
		String Name;
		String TeamName;
		String TeamId;
		String Id;
		Integer NumberOfMessages;
		Integer NumberOfViews;
		String LastPostMessage;	
		DiscussionMessage__c firstMessageCreated;	
		String userImg;
		boolean enableActions = false;
		
		/**
		* Setters 
		*/
		
		public void setId(String sId){
       		Id = sId;
        }
		
		public void setAuthorId(String sAuthorId){
       		AuthorId = sAuthorId;
        }
		
		public void setAuthorName(String sAuthorName){
           	AuthorName = sAuthorName;
        }
        
		public void setName(String sName){
			       	Name = sName;
        }
        
    	public void setTeamName(String sTeamName){
        	TeamName = sTeamName;
        }
        
        public void setTeamId(String sTeamId){
           	TeamId = sTeamId;
        }
                
        public void setNumberOfMessages(Double sNumberOfMessages){
        	NumberOfMessages = sNumberOfMessages.intValue() - 1;
        }

        public void setNumberOfViews(Double sNumberOfViews){
            NumberOfViews = sNumberOfViews.intValue();
        }
        
        public void setLastPostMessage(Id sLastPostMessage){
            LastPostMessage = lastPostInfoString(sLastPostMessage);
        }
        
        public void setFirstMessageCreated(DiscussionMessage__c msg){  
        	firstMessageCreated = msg;
        }
        
        public void setAuthorPicture(String img){
        	userImg = img;
        }
        
        public void setEnableActions(String sAuthorId, boolean isManager){        	
       		if(isManager){
				enableActions = true;
			} else {
				if(sAuthorId == UserInfo.getUserId()){
					enableActions = true;
				}
			}
        }
        /**
		* Getters 
		*/
		
		
		public boolean getEnableActions() {
			return enableActions;
		}
		
		public String getAuthorPicture(){
			return userImg;
		}        
        
        public String getFirstMessageCreated(){
			return firstMessageCreated.Message__c;
		}
		
		public String getFirstMessageId(){
			return firstMessageCreated.Id;
		}
		
		public String getId() {					
            return Id;
		}
		
		public String getAuthorId() {					
            return AuthorId;
		}
		
		public String getFullAuthorName(){
			return AuthorName;
		}
		
		public String getAuthorName() {
            if(AuthorName != null){
	            Integer len = AuthorName.length();
				if (len > 20){
					return AuthorName.substring(0,20) + '...';
				}	
				else{
					return AuthorName.substring(0,len);
				} 	
			} else {
				return '';
			}			
		}
		
		public String getName(){	
			return Name;
		}
		
		public String getShortName() {
			
			if(Name != null){
				Integer len = Name.length();
				if (len > 25){
					
					return Name.substring(0,25) + '...';
				}	
				else{
					return Name.substring(0,len);
				}
			}
			return ''; 		
		}	
		
        public String getTeamName() {
            return TeamName;
		}	
		
		public String getTeamId() {
            return TeamId;
		}	
		
		public Integer getNumberOfMessages() {
            return NumberOfMessages;
		}
		
		public Integer getNumberOfViews() {
            return NumberOfViews;
		}	
		
		public String getLastPostMessage() {
			return LastPostMessage;
		}
		
		public boolean getIsAuthor(){
			if(AuthorId == userInfo.getUserId()){
				return true;
			}
			return false;
		}
		
		/**
		* Method to convert dates.
		* @return String datestring The string of the lastest reply. 
		*/
		public String lastPostInfoString(Id dm){
			String lastPostString;
			if (dm != null){				
				DiscussionMessage__c d = [ Select 
											LastModifiedDate, 
											DiscussionTopic__r.Subject__c, 
											DiscussionTopic__c,
											PostedBy__r.Name, 
											PostedBy__r.Id,
											PostedBy__c From DiscussionMessage__c where id =: dm];
				
				Integer today = (System.now()).day();
				String dateInfo;
				
				if(today == (d.LastModifiedDate).day()){
					dateInfo = 'Today, at ' + (d.LastModifiedDate).format('HH:mm') + ' ' + (d.LastModifiedDate).format('aa');	
				} else {
					dateInfo = '' + (d.LastModifiedDate).day() + ' of '+ (d.LastModifiedDate).format('MMMM') + ' at ' +(d.LastModifiedDate).format('HH:mm') + ' ' + (d.LastModifiedDate).format('aa');
				}	
		 		lastPostString = ' ' + dateInfo + ' by ' + d.PostedBy__r.Name;
			} else {
				lastPostString = 'This Forum has no messages yet.';
			}
			return lastPostString;
		}	
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
   	
   	public void refreshPages () {
   		
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
   	*	BreadCrumb
   	*/
   	
   	public DiscussionForum__c getForumData(){
   		
   		DiscussionForum__c team = new DiscussionForum__c();
   		
   		if(TEAMID != null){
   			 try {
   			 	team = [SELECT
   						Team__r.Name, 
   						Team__c,
   						Id 
   						FROM DiscussionForum__c WHERE Team__c =: TEAMID LIMIT 1];
   						
   			 } catch (Exception e) {
   			 	
   			 	System.Debug('\n ///////////////////////////// \n Error , no team assigned \n //////////////////////////// \n The Forum ID is :' + TEAMID + '\n //////////////////////////// \n');
   			 	
   			 }
   			    			 
   		} else {
   			team = null;
   		}
   		return team;
   	}   	
	
	/*
	/** Save Topic
	/**
	*/
	public void saveTopic (){

		topicList = fillTopicList();
		totalItemsNumber = topicList.size();
		
		System.debug('topicListtt ' + topicList + ' size ' + topicList.size());		
		if (topicList.size() == 0){
			cntPagination = 0;
			noTopics = true;
			System.debug('estoy en el size = 0');	
		} else {
			noTopics = false;
			genCntPagination();
			System.debug('estoy en el size > 0');	
		}	
	}	
	
	public void updateReadCount () {
		String topicId = System.currentPageReference().getParameters().get('id');
		List<DiscussionTopic__c> topic = [select Id, ViewCount__c, LastViewedDate__c from DiscussionTopic__c where id =: topicId];
		if (topic.size() > 0) {
			topic[0].ViewCount__c = topic[0].ViewCount__c + 1;
			topic[0].LastViewedDate__c = System.now();
			upsert topic;
		}
	}
	
	public List<DiscussionTopic__c> getMostRead () {
		String topicId = System.currentPageReference().getParameters().get('id');
		List<DiscussionTopic__c> mostRead = new List<DiscussionTopic__c>();
		mostRead = [select Id, Subject__c, ViewCount__c, LastViewedDate__c from DiscussionTopic__c order by LastViewedDate__c desc limit 5];
		return mostRead;
	}
	
	public boolean getPermissionAuthorApex(){
		User user = [Select u.Profile.Name, u.Profile.PermissionsAuthorApex, u.ProfileId, u.Name, u.Id From User u Where Id =: UserInfo.getUserId()];
		return user.Profile.PermissionsAuthorApex;
	}	
	

	public boolean getIsTeamAdminMember(){
		List<User> teamAdmin = [Select id, Profile.PermissionsModifyAllData, ProfileId, Name From User where id =:UserInfo.getUserId() limit 1];
                                        
        if(getPermissionAuthorApex() && teamAdmin[0].Profile.PermissionsModifyAllData){
        	return true;
        }
		return false;
	}
	
	
	
	
	/* ---------------------------- */
   	/*       	 ORDER BY		    */
   	/* ---------------------------- */
	public Boolean sortByDesc = false;
	
	public String sortBy = 'PostedDate__c';
	
	public Boolean getSortByDesc () {
		return !sortByDesc;
	}
	
	public void setSortByDesc(Boolean b){
		sortByDesc = b;
	}
	
	public void setSortBy(String s){
		sortBy = s;
	}
	
	//columna tablas para img flecha
	
	public String getSortBy () {
		String sbCol = '';
		if (sortBy == null || sortBy == 'Name') {
			sbCol = 'topic';	
		}
		if (sortBy == 'PostedBy__r.Name') {
			sbCol = 'author';	
		}	
		if (sortBy == 'ViewCount__c') {
			sbCol = 'view';	
		}
		if (sortBy == 'MessageCount__c') {
			sbCol = 'replies';	
		}
		if (sortBy == 'LastPostedMessage__c') {
			sbCol = 'lastReplies';	
		}
		return sbCol; 
	}
	
	/*
	 * This is a temporary method to cover us until dynamic apex is back.  This will use hard coded
	 * SOQL statements in place of the dynamic statements
	 */
	public void sortList () {
		List<TopicList> topicsList = new List<TopicList>();
		
		//esto es para cambiar flecha,  si cliquee 2 veces el mismo
		
		if (sortBy == System.currentPageReference().getParameters().get('sb')) {
			sortByDesc = !sortByDesc;
		}
		else {
			sortByDesc = false;
		}
		
		if(System.currentPageReference().getParameters().get('sb') != null)
			sortBy = System.currentPageReference().getParameters().get('sb');
		
		List<DiscussionTopic__c> topicResultList = new List<DiscussionTopic__c>();
		List<PeopleProfile__c> peopleProfiles = new List<PeopleProfile__c>();
	
		if (sortByDesc) {
			
			if (sortBy == 'Name') {

				topicResultList = [Select Id, 
										  ViewCount__c,
										  Team__c, 
										  Team__r.Name,
										  Subject__c,
										  Name, 
										  MessageCount__c, 
										  PostedBy__r.Name,
										  PostedBy__r.Id, 
										  LastPostedMessage__c,
										  DiscussionForum__c, 
										  (Select Id,
										  		  PostedDate__c,
										  		  DiscussionTopic__c,
										  		  Subject__c,
										  		  PostedBy__c,
										  		  Message__c,
										  		  ParentMessage__c,
										  		  Team__c From DiscussionTopic__r 
										  		  order by PostedDate__c asc limit 1)
										   From DiscussionTopic__c d	
										   where Team__c =: TEAMID
										   Order by Subject__c desc];
					
			}
			if (sortBy == 'PostedBy__r.Name') {

				topicResultList = [Select Id, 
										  ViewCount__c,
										  Team__c, 
										  Team__r.Name,
										  Subject__c,
										  Name, 
										  MessageCount__c, 
										  PostedBy__r.Name,
										  PostedBy__r.Id, 
										  LastPostedMessage__c,
										  DiscussionForum__c, 
										  (Select Id,
										  		  PostedDate__c,
										  		  DiscussionTopic__c,
										  		  Subject__c,
										  		  PostedBy__c,
										  		  Message__c,
										  		  ParentMessage__c,
										  		  Team__c From DiscussionTopic__r 
										  		  order by PostedDate__c asc limit 1)
										   From DiscussionTopic__c d	
										   where Team__c =: TEAMID
										   Order by PostedBy__r.Name desc];					
			}	
			if (sortBy == 'ViewCount__c') {

				topicResultList = [Select Id, 
										  ViewCount__c,
										  Team__c, 
										  Team__r.Name,
										  Subject__c,
										  Name, 
										  MessageCount__c, 
										  PostedBy__r.Name,
										  PostedBy__r.Id, 
										  LastPostedMessage__c,
										  DiscussionForum__c, 
										  (Select Id,
										  		  PostedDate__c,
										  		  DiscussionTopic__c,
										  		  Subject__c,
										  		  PostedBy__c,
										  		  Message__c,
										  		  ParentMessage__c,
										  		  Team__c From DiscussionTopic__r 
										  		  order by PostedDate__c asc limit 1)
										   From DiscussionTopic__c d	
										   where Team__c =: TEAMID
										   Order by ViewCount__c desc];
										   					
			}
			if (sortBy == 'MessageCount__c') {
				
				topicResultList = [Select Id, 
										  ViewCount__c,
										  Team__c, 
										  Team__r.Name,
										  Subject__c,
										  Name, 
										  MessageCount__c, 
										  PostedBy__r.Name,
										  PostedBy__r.Id, 
										  LastPostedMessage__c,
										  DiscussionForum__c, 
										  (Select Id,
										  		  PostedDate__c,
										  		  DiscussionTopic__c,
										  		  Subject__c,
										  		  PostedBy__c,
										  		  Message__c,
										  		  ParentMessage__c,
										  		  Team__c From DiscussionTopic__r 
										  		  order by PostedDate__c asc limit 1)
										   From DiscussionTopic__c d	
										   where Team__c =: TEAMID
										   Order by MessageCount__c desc];
			}
			if (sortBy == 'LastPostedMessage__c') {
					
				topicResultList = [Select Id, 
										  ViewCount__c,
										  Team__c, 
										  Team__r.Name,
										  Subject__c,
										  Name, 
										  MessageCount__c, 
										  PostedBy__r.Name,
										  PostedBy__r.Id, 
										  LastPostedMessage__c,
										  DiscussionForum__c, 
										  (Select Id,
										  		  PostedDate__c,
										  		  DiscussionTopic__c,
										  		  Subject__c,
										  		  PostedBy__c,
										  		  Message__c,
										  		  ParentMessage__c,
										  		  Team__c From DiscussionTopic__r 
										  		  order by PostedDate__c asc limit 1)
										   From DiscussionTopic__c d	
										   where Team__c =: TEAMID
										   Order by LastPostedMessage__c desc];					
			}			
			
		} else {
			
			if (sortBy == 'Name') {

				topicResultList = [Select Id, 
										  ViewCount__c,
										  Team__c, 
										  Team__r.Name,
										  Subject__c,
										  Name, 
										  MessageCount__c, 
										  PostedBy__r.Name,
										  PostedBy__r.Id, 
										  LastPostedMessage__c,
										  DiscussionForum__c, 
										  (Select Id,
										  		  PostedDate__c,
										  		  DiscussionTopic__c,
										  		  Subject__c,
										  		  PostedBy__c,
										  		  Message__c,
										  		  ParentMessage__c,
										  		  Team__c From DiscussionTopic__r 
										  		  order by PostedDate__c asc limit 1)
										   From DiscussionTopic__c d	
										   where Team__c =: TEAMID
										   Order by Subject__c];
					
			}
			if (sortBy == 'PostedBy__r.Name') {

				topicResultList = [Select Id, 
										  ViewCount__c,
										  Team__c, 
										  Team__r.Name,
										  Subject__c,
										  Name, 
										  MessageCount__c, 
										  PostedBy__r.Name,
										  PostedBy__r.Id, 
										  LastPostedMessage__c,
										  DiscussionForum__c, 
										  (Select Id,
										  		  PostedDate__c,
										  		  DiscussionTopic__c,
										  		  Subject__c,
										  		  PostedBy__c,
										  		  Message__c,
										  		  ParentMessage__c,
										  		  Team__c From DiscussionTopic__r 
										  		  order by PostedDate__c asc limit 1)
										   From DiscussionTopic__c d	
										   where Team__c =: TEAMID
										   Order by PostedBy__r.Name];					
			}	
			if (sortBy == 'ViewCount__c') {

				topicResultList = [Select Id, 
										  ViewCount__c,
										  Team__c, 
										  Team__r.Name,
										  Subject__c,
										  Name, 
										  MessageCount__c, 
										  PostedBy__r.Name,
										  PostedBy__r.Id, 
										  LastPostedMessage__c,
										  DiscussionForum__c, 
										  (Select Id,
										  		  PostedDate__c,
										  		  DiscussionTopic__c,
										  		  Subject__c,
										  		  PostedBy__c,
										  		  Message__c,
										  		  ParentMessage__c,
										  		  Team__c From DiscussionTopic__r 
										  		  order by PostedDate__c asc limit 1)
										   From DiscussionTopic__c d	
										   where Team__c =: TEAMID
										   Order by ViewCount__c];
										   					
			}
			if (sortBy == 'MessageCount__c') {
				
				topicResultList = [Select Id, 
										  ViewCount__c,
										  Team__c, 
										  Team__r.Name,
										  Subject__c,
										  Name, 
										  MessageCount__c, 
										  PostedBy__r.Name,
										  PostedBy__r.Id, 
										  LastPostedMessage__c,
										  DiscussionForum__c, 
										  (Select Id,
										  		  PostedDate__c,
										  		  DiscussionTopic__c,
										  		  Subject__c,
										  		  PostedBy__c,
										  		  Message__c,
										  		  ParentMessage__c,
										  		  Team__c From DiscussionTopic__r 
										  		  order by PostedDate__c asc limit 1)
										   From DiscussionTopic__c d	
										   where Team__c =: TEAMID
										   Order by MessageCount__c];
			}
			if (sortBy == 'LastPostedMessage__c') {
					
				topicResultList = [Select Id, 
										  ViewCount__c,
										  Team__c, 
										  Team__r.Name,
										  Subject__c,
										  Name, 
										  MessageCount__c, 
										  PostedBy__r.Name,
										  PostedBy__r.Id, 
										  LastPostedMessage__c,
										  DiscussionForum__c, 
										  (Select Id,
										  		  PostedDate__c,
										  		  DiscussionTopic__c,
										  		  Subject__c,
										  		  PostedBy__c,
										  		  Message__c,
										  		  ParentMessage__c,
										  		  Team__c From DiscussionTopic__r 
										  		  order by PostedDate__c asc limit 1)
										   From DiscussionTopic__c d	
										   where Team__c =: TEAMID
										   Order by LastPostedMessage__c];					
			}			
			
		}
				
		peopleProfiles = [Select Id, Picture__c, User__c From PeopleProfile__c];
		
		for (DiscussionTopic__c t: topicResultList) {
			TopicList topicItem = new TopicList();
			
			for(PeopleProfile__c p : peopleProfiles){
				if(p.User__c == t.PostedBy__r.Id){
					topicItem.setAuthorPicture(p.Picture__c);
				}
			}
			topicItem.setAuthorId(t.PostedBy__r.Id);
			topicItem.setNumberOfViews(t.ViewCount__c);
			topicItem.setId(t.Id);	
			topicItem.setName(t.Subject__c);						
			topicItem.setTeamId(t.Team__c);
			topicItem.setAuthorName(t.PostedBy__r.Name);
			topicItem.setTeamName(t.Team__r.Name);
			topicItem.setNumberOfMessages(t.MessageCount__c);				
			topicItem.setLastPostMessage(t.LastPostedMessage__c);
			if(t.DiscussionTopic__r.size() > 0)
				topicItem.setFirstMessageCreated(t.DiscussionTopic__r.get(0));
			topicItem.setEnableActions(t.PostedBy__r.Id, isManager);
			
				System.debug('\n\n---------------------o-o-o-\n\n' + t.PostedBy__r.Id +'-----p-p-p-----'+ isManager );
			topicsList.add(topicItem);
			
		}
			
		totalItemsNumber = topicsList.size();
		if (totalItemsNumber == 0 ) {
			cntPagination = 0;	
			firstRow = 0;
			currentPagination = 1;
		}
		else {
			firstRow = 0;
			currentPagination = 1;
			genCntPagination();	
		}
		topicList = topicsList;	
	}
		
	/*
	 * We have to remove all elements of dynamic apex in order to put this application in the
	 * 62 org.  This code will be added back in once dynamic apex is released GA
	 * 
	public void sortList () {
		List<TopicList> topicsList = new List<TopicList>();
		
		//esto es para cambiar flecha,  si cliquee 2 veces el mismo
		
		if (sortBy == System.currentPageReference().getParameters().get('sb')) {
			sortByDesc = !sortByDesc;
		}
		else {
			sortByDesc = false;
		}
		sortBy = System.currentPageReference().getParameters().get('sb');
		List<DiscussionTopic__c> topicResultList = new List<DiscussionTopic__c>();
		List<PeopleProfile__c> peopleProfiles = new List<PeopleProfile__c>();
		String queryStr;
				
		queryStr = 'Select Id, ViewCount__c,Team__c, Team__r.Name,Subject__c, Name, MessageCount__c, PostedBy__r.Name,PostedBy__r.Id, LastPostedMessage__c,DiscussionForum__c, (Select	Id,PostedDate__c,DiscussionTopic__c,Subject__c,PostedBy__c,Message__c,ParentMessage__c,Team__c From DiscussionTopic__r order by PostedDate__c asc limit 1)From DiscussionTopic__c d	where Team__c = \'' + TEAMID + '\' order by ' + sortBy;
		
		if (sortByDesc) {
			queryStr += ' desc';
		}
		
		//Query
		
		topicResultList = Database.query(queryStr); 
		peopleProfiles = [Select Id, Picture__c, User__c From PeopleProfile__c];
		
		for (DiscussionTopic__c t: topicResultList) {
			TopicList topicItem = new TopicList();
			
			for(PeopleProfile__c p : peopleProfiles){
				if(p.User__c == t.PostedBy__r.Id){
					topicItem.setAuthorPicture(p.Picture__c);
				}
			}
			topicItem.setAuthorId(t.PostedBy__r.Id);
			topicItem.setNumberOfViews(t.ViewCount__c);
			topicItem.setId(t.Id);	
			topicItem.setName(t.Subject__c);						
			topicItem.setTeamId(t.Team__c);
			topicItem.setAuthorName(t.PostedBy__r.Name);
			topicItem.setTeamName(t.Team__r.Name);
			topicItem.setNumberOfMessages(t.MessageCount__c);				
			topicItem.setLastPostMessage(t.LastPostedMessage__c);
			topicItem.setFirstMessageCreated(t.DiscussionTopic__r.get(0));
			
			topicsList.add(topicItem);
			
		}
			
		totalItemsNumber = topicsList.size();
		if (totalItemsNumber == 0 ) {
			cntPagination = 0;	
			firstRow = 0;
			currentPagination = 1;
		}
		else {
			firstRow = 0;
			currentPagination = 1;
			genCntPagination();	
		}
		topicList = topicsList;	
	}*/

}