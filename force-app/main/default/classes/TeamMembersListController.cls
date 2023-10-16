public without sharing class TeamMembersListController {

	public String idTeam = System.currentPageReference().getParameters().get('id');
	public String removeMemberId = System.currentPageReference().getParameters().get('delId');
	public String delName;
		 
	public void setIdTeam(String team){
		idTeam = team;
	}
	
	public void setRemoveMemberId (String mamberId){
		removeMemberId = mamberId; 
	}
	
	
	public TeamMembersListController () {
		genPermissions();
		genMembers();
	}
	
	public void refresh() {genMembers();}
	
    /* ---------------------------- */
   	/*   	 SHARING RULES			*/
   	/* ---------------------------- */	
	public UserPermissions userPermissions = new UserPermissions();
	
	public void genPermissions() {
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setTeam(idTeam);
		userPermissions.setObjectType('Team');
		userPermissions.setPermissions();		
	}

	public UserPermissions getUserPermissions () {
		return userPermissions;
	}	
	/* ---------------------------- */	
	
	public String getTeamName () {
		Team__c currentTeam = [select Name from Team__c where id=: idTeam];
		return currentTeam.Name;	 
	}
	
	public String getTeamId () {
		return idTeam;	
	}
	
	public Integer getAdminCount () {
		Integer countAdmin = [select count() from TeamMember__c where team__c = :idTeam and TeamProfile__r.ManageTeams__c = true];
		return countAdmin;	
	}
	
	public String getUserMemberId () {
		List<TeamMember__c> userMember = new List<TeamMember__c>();
		userMember = [select id from TeamMember__c where team__c =:idTeam and User__c =:UserInfo.getUserId() limit 1];
		String userMemberId = '';
		if (userMember.size() > 0) {
			userMemberId = userMember[0].Id;	
		}
		return userMemberId;
	}
	
	public String getCurrentUser () {
		return UserInfo.getUserId();
	}
	/* ************************ */
	/*		 REMOVE MEMBERS		*/
	/* ************************ */
	
	public Boolean getRemoveMessage () {
		String removeParam = System.currentPageReference().getParameters().get('remMsg');
		return (removeParam == 'true');
	}
	
	public void assignRemoveId () {
		if (System.currentPageReference().getParameters().get('delId') != null) {
			removeMemberId = System.currentPageReference().getParameters().get('delId');	
		}
		
		delName = [select User__r.Name from TeamMember__c where User__c =: removeMemberId and team__c =: idTeam].User__r.Name;
	}
	
	public String getDelName () {
		return delName;
	}
		
	public PageReference removeMember () {
		if (removeMemberId != UserInfo.getUserId()) {
			TeamMember__c delMember = [select User__r.Name from TeamMember__c where User__c =: removeMemberId and Team__c =: idTeam];
			delete delMember;
		}
		PageReference pageRef = new PageReference('/apex/TeamsMembersList?remMsg=true&id=' + idTeam);
		pageRef.setRedirect(true);
		return pageRef;	
	}
	

	/* ************************ */
	/*		 EDIT MEMBERS		*/
	/* ************************ */
	public String editMemberId = System.currentPageReference().getParameters().get('editId');
	public TeamMember__c editMember;
	public String imgEditMember = '';
	public Boolean itsLastAdmin = false;
	
	public Boolean getItsLastAdmin () {
		return itsLastAdmin;	
	}
	
	public void setEditMemberId (String s){
		editMemberId = s;	
	}
	
	public void assignEditId () {
		if (System.currentPageReference().getParameters().get('editId') != null) {
			editMemberId = 	System.currentPageReference().getParameters().get('editId');
		}
		System.debug('\n\n //////////////////////// \n HERE:' + editMemberId + ' - ' + idTeam + '\n/////////////////////////\n\n');
		editMember = [select id, User__r.name, TeamRole__c, TeamProfile__c, User__r.companyName, User__r.Title  from TeamMember__c where User__c =: editMemberId and Team__c =: idTeam];
		PeopleProfile__c img = [SELECT Picture__c from PeopleProfile__c WHERE User__c =: editMemberId LIMIT 1];
		if (img == null) {
			imgEditMember = '';
		}
		else {
			imgEditMember = img.Picture__c;
		}
		
		Integer countAdmin = [select count() from TeamMember__c where team__c = :idTeam];
		Boolean isAdmin = [select TeamProfile__r.ManageTeams__c from TeamMember__c where team__c =:idTeam and User__c=:editMemberId].TeamProfile__r.ManageTeams__c;
		if (editMemberId == UserInfo.getUserId() && isAdmin) {
			itsLastAdmin = true;
		}	
		else {
			itsLastAdmin = false;
		}	
		
		editMemberRole = editmember.TeamRole__c;
		editMemberProfile = editmember.TeamProfile__c;
	}
	
	public String editMemberRole;
	
	public String getEditMemberRole () {
		return editMemberRole;
	}
	
	public void setEditMemberRole (String role) {
		this.editMemberRole = role;
	}

	public String editMemberProfile;
	
	public String getEditMemberProfile () {
		return editMemberProfile;
	}
	
	public void setEditMemberProfile (String profile) {
		this.editMemberProfile = profile;
	}
	
	public TeamMember__c getEditMember () {
		return editMember;
	}
	
	public String getImgEditMember () {
		return imgEditMember;
	}
		
	public PageReference editMemberAction () {	
		editMember.TeamProfile__c = editMemberProfile;
		editMember.TeamRole__c = editMemberRole;
		update editMember;
		PageReference pageRef = new PageReference('/apex/TeamsMembersList?id=' + idTeam);
		pageRef.setRedirect(true);
		return pageRef;
	}

	public List<SelectOption> getProfilesOptions () {
		List<SelectOption> options = new List<SelectOption>();
		for (TeamProfile__c item: [select id, Name from TeamProfile__c order by Name]) {
			options.add(new SelectOption(item.id,item.Name));
		}
		return options;
	}
	
	public List<SelectOption> getProfilesOptionsFilter () {
		List<SelectOption> options = new List<SelectOption>();
		for (TeamProfile__c item: [select id, Name from TeamProfile__c where ManageTeams__c = true order by Name]) {
			options.add(new SelectOption(item.id,item.Name));
		}
		return options;
	}
	
	public List<TeamProfile__c> getTeamEditProfiles () {
		return [select Name, id from TeamProfile__c order by Name];
	}
	
	/* ************************ */
	/*		  SHOW MEMBERS		*/
	/* ************************ */
	
	public List<Member> members = new List<Member>();
	
	public List<Member> getMembers () {
		return members;
	}
	
	public class Member {
		String memberImg;
		String company;
		String title;
		String profile;
		String role;
		String name;
		String userId;
		String teamMemberId;
		Boolean admin;
		String yahoo;
		String skype;
		
		public String getYahoo () {
			return yahoo;
		}
		
		public String getSkype () {
			return skype;	
		}
		
		public String getUserId (){
			return userId;
		}
		
		public String getTeamMemberId (){
			return teamMemberId;
		}
		
		public void setTeamMemberId (String teamMemberId){
			this.teamMemberId = teamMemberId;
		}
		
		public String getName () {
			return name;
		}
		
		public String getMemberImg () {
			return memberImg;
		}
		
		public String getCompany () {
			return company;
		}
		
		public String getTitle () {
			return title;
		}
		
		public String getProfile () {
			return profile;
		}
		
		public String getRole () {
			return role;
		}
		
		public void setUserId (String userId) {
			this.userId = userId;
		}
		
		public void setCompany (String company) {
			this.company = company;
		}
		
		public void setName (String name) {
			this.name = name;
		}
		
		public void setMemberImg (String memberId) {
			
			List<PeopleProfile__c> imgs = new List<PeopleProfile__c>();
			try {
				imgs = [SELECT Id, YahooIM__c, Skype__c, Picture__c from PeopleProfile__c WHERE User__c =: memberId LIMIT 1];
			} catch(Exception e){
				System.debug(e);
			}
			PeopleProfile__c img = new PeopleProfile__c();
			if(imgs.size() > 0){
				img = imgs[0];
			} 
			
			if (img == null) {
				this.memberImg = '';
				this.yahoo = '';
				this.skype = '';
			}
			else {
				this.memberImg = img.Picture__c;
				if(img.YahooIM__c != null){
	            	this.yahoo = img.YahooIM__c;
	            }
	            else {
	            	this.yahoo = '';
	            }
	            if(img.Skype__c != null){
	            	this.skype = img.Skype__c;
	            } 
	            else {
	            	this.skype = '';
	            }
			}
		}
		
		public void setProfile (String profile) {
			this.profile = profile;
		}
		
		public void setRole (String role) {
			this.role = role;
		}
		
		public void setTitle (String title) {
			this.title = title;
		}
		
		public void setAdmin (Boolean admin) {
			this.admin = admin;	
		}
		
		public Boolean getAdmin () {
			return admin;
		}
	}
	
	public String letter = System.currentPageReference().getParameters().get('ltr');
	
	public void setLetter(String s){
		letter = s;	
	}
	
	public void genMembers () {
		List<Member> membersList = new List<Member>();
		
		sortByDesc = false;
		sortBy = 'User__r.Name';
		
		if(System.currentPageReference().getParameters().get('ltr') != null)
			letter = System.currentPageReference().getParameters().get('ltr');
				
		if (letter == null || letter == '' || letter== 'ALL') {
			for (TeamMember__c item: [select id, Name, TeamRole__c, TeamProfile__r.Name, TeamProfile__r.ManageTeams__c, TeamProfile__r.Description__c, User__r.Name, User__r.Title, User__r.Id, User__r.CompanyName from TeamMember__c where team__c =:idTeam order by User__r.Name]) {
				Member memberItem = new Member();
				memberItem.setName(item.User__r.Name);
				memberItem.setRole(item.TeamRole__c);
				memberItem.setProfile(item.TeamProfile__r.Name);
				memberItem.setTitle(item.User__r.Title);
				memberItem.setUserId(item.User__r.Id);
				memberItem.setTeamMemberId(item.id);
				memberItem.setMemberImg(item.User__r.Id);
				memberItem.setAdmin(item.TeamProfile__r.ManageTeams__c);
				memberItem.setCompany(item.User__r.CompanyName);
				membersList.add(memberItem);
			}
		}
		else {
			for (TeamMember__c item: [select id, Name, TeamRole__c, TeamProfile__r.Name, TeamProfile__r.ManageTeams__c, TeamProfile__r.Description__c, User__r.Name, User__r.Title, User__r.Id, User__r.CompanyName from TeamMember__c where User__r.Name like :(letter + '%') and team__c =:idTeam order by User__r.Name]) {
				Member memberItem = new Member();
				memberItem.setName(item.User__r.Name);
				memberItem.setRole(item.TeamRole__c);
				memberItem.setProfile(item.TeamProfile__r.Name);
				memberItem.setTitle(item.User__r.Title);
				memberItem.setUserId(item.User__r.Id);
				memberItem.setTeamMemberId(item.id);	
				memberItem.setMemberImg(item.User__r.Id);
				memberItem.setAdmin(item.TeamProfile__r.ManageTeams__c);
				memberItem.setCompany(item.User__r.CompanyName);
				membersList.add(memberItem);
			}
		}	
		totalItemsNumber = membersList.size();
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
		members = membersList;
	}

	/* ************************ */
	/*		  Pagination		*/
	/* ************************ */
   	
    /**
   	* Set of Integers to control pagination
   	*/
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
 
	public Integer totalItemsNumber= 0;
	
	public Integer getTotalItemsNumber () {
		return totalItemsNumber;
	}
	 
   	public Integer getFirstItem () {
		return (firstRow + 1);
	}
	
	public Integer getLastItem () {
		Integer lastItem;
		if ((currentPagination == cntPagination) || (currentPagination == 1 && (totalItemsNumber < numberOfItemsToShow))) {
			lastItem = firstRow + Math.mod(totalItemsNumber, numberOfItemsToShow);
		}
		else {
			lastItem = firstRow + 10;
		}
		return lastItem;
	}
   	
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


   	/* ---------------------------- */
   	/*        LETTER FILTER		    */
   	/* ---------------------------- */
	public List<String> lettersList = new List<String>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};	

	public class Letters {
		String letter;
		Boolean containMembers;
		
		public void setLetter (String letter) {
			this.letter = letter;
		}
		public String getLetter () {
			return letter;
		}
		public void setContainMembers (Integer cntMembers) {
			if (cntMembers == 0) {
				this.containMembers = false;
			}
			else {
				this.containMembers = true;
			}
		}
		public Boolean getContainMembers () {
			return containMembers;
		}
	}
	
	public List<Letters> getLetterFilter () {
		List<Letters> letterFilter = new List<Letters>();
   		for (String item : lettersList) {
   			Letters currentLetter = new Letters();
   			Integer cntMembers = [select count() from TeamMember__c where User__r.Name like :(item + '%') and team__c =:idTeam];
   			currentLetter.setLetter(item);
   			currentLetter.setContainMembers(cntMembers);
   			letterFilter.add(currentLetter);
   		}
   		return letterFilter;		
	}

   	/* ---------------------------- */
   	/*        ADMIN MEMBER		    */
   	/* ---------------------------- */
	
	public Boolean getIsTeamAdmin () {
		List<TeamMember__c> currentUser = new List<TeamMember__c>();
		currentUser = [select TeamProfile__r.ManageTeams__c from TeamMember__c where team__c =:idTeam and User__c =:UserInfo.getUserId()];
		Boolean isTeamAdmin = false;
		if (currentUser.size() > 0) {
			isTeamAdmin = (currentUser[0].TeamProfile__r.ManageTeams__c);
		} 
		return isTeamAdmin;		
	}

   	/* ---------------------------- */
   	/*       	 ORDER BY		    */
   	/* ---------------------------- */
	public Boolean sortByDesc = false;
	
	public String sortBy = 'User__r.Name';
	
	public Boolean getSortByDesc () {
		return !sortByDesc;
	}
	
	public void setSortBy (String s){
		sortBy = s;	
	}
	
	public String getSortBy () {
		String sbCol = '';
		if (sortBy == null || sortBy == 'User__r.Name') {
			sbCol = 'name';	
		}
		if (sortBy == 'User__r.CompanyName') {
			sbCol = 'company';	
		}	
		if (sortBy == 'User__r.Title') {
			sbCol = 'title';	
		}
		if (sortBy == 'TeamProfile__r.Name') {
			sbCol = 'profile';	
		}
		if (sortBy == 'TeamRole__c') {
			sbCol = 'role';	
		}
		return sbCol;
	}
	
	/*
	 * This is a temporary method to cover us until dynamic apex is back.  This will use hard coded
	 * SOQL statements in place of the dynamic statements
	 */
	public void sortList () {
		List<Member> membersList = new List<Member>();
		if (sortBy == System.currentPageReference().getParameters().get('sb')) {
			sortByDesc = !sortByDesc;
		}
		else {
			sortByDesc = false;
		}
		
		//Sort param
		if(System.currentPageReference().getParameters().get('sb') != null)
			sortBy = System.currentPageReference().getParameters().get('sb');
		
		List<TeamMember__c> memberResultList = new List<TeamMember__c>();

		if (sortByDesc) {
			if (letter == null || letter == '' || letter== 'ALL') {
				if (sortBy == 'User__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where team__c =: idTeam
										order by User__r.Name desc];
				}
				if (sortBy == 'User__r.CompanyName') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where team__c =: idTeam
										order by User__r.CompanyName desc];						
				}	
				if (sortBy == 'User__r.Title') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where team__c =: idTeam
										order by User__r.Title desc];							
				}
				if (sortBy == 'TeamProfile__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where team__c =: idTeam
										order by TeamProfile__r.Name desc];						
				}
				if (sortBy == 'TeamRole__c') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where team__c =: idTeam
										order by TeamRole__c desc];						
				}		
			} 
			else {
				if (sortBy == 'User__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where User__r.Name like: (letter + '%') 
										and team__c =: idTeam
										order by User__r.Name desc];					
				}
				if (sortBy == 'User__r.CompanyName') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where User__r.Name like: (letter + '%') 
										and team__c =: idTeam
										order by User__r.CompanyName desc];							
				}	
				if (sortBy == 'User__r.Title') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where User__r.Name like: (letter + '%') 
										and team__c =: idTeam
										order by User__r.Title desc];							
				}
				if (sortBy == 'TeamProfile__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where User__r.Name like: (letter + '%') 
										and team__c =: idTeam
										order by TeamProfile__r.Name desc];						
				}
				if (sortBy == 'TeamRole__c') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where User__r.Name like: (letter + '%') 
										and team__c =: idTeam
										order by TeamRole__c desc];						
				}		
			}
		} else {
			if (letter == null || letter == '' || letter== 'ALL') {
				if (sortBy == 'User__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where team__c =: idTeam
										order by User__r.Name];
				}
				if (sortBy == 'User__r.CompanyName') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where team__c =: idTeam
										order by User__r.CompanyName asc];						
				}	
				if (sortBy == 'User__r.Title') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where team__c =: idTeam
										order by User__r.Title];							
				}
				if (sortBy == 'TeamProfile__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where team__c =: idTeam
										order by TeamProfile__r.Name];						
				}
				if (sortBy == 'TeamRole__c') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where team__c =: idTeam
										order by TeamRole__c];						
				}		
			} 
			else {
				if (sortBy == 'User__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where User__r.Name like: (letter + '%') 
										and team__c =: idTeam
										order by User__r.Name];					
				}
				if (sortBy == 'User__r.CompanyName') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where User__r.Name like: (letter + '%') 
										and team__c =: idTeam
										order by User__r.CompanyName];							
				}	
				if (sortBy == 'User__r.Title') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where User__r.Name like: (letter + '%') 
										and team__c =: idTeam
										order by User__r.Title];							
				}
				if (sortBy == 'TeamProfile__r.Name') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where User__r.Name like: (letter + '%') 
										and team__c =: idTeam
										order by TeamProfile__r.Name];						
				}
				if (sortBy == 'TeamRole__c') {
					memberResultList = [select id, 
											   Name, 
											   TeamRole__c, 
											   TeamProfile__r.Name, 
											   TeamProfile__r.Description__c, 
											   User__r.Name, 
											   User__r.Title, 
											   User__r.Id, 
											   User__r.CompanyName 
										from TeamMember__c 
										where User__r.Name like: (letter + '%') 
										and team__c =: idTeam
										order by TeamRole__c];						
				}		
			}			
		}
				 
		for (TeamMember__c item: memberResultList) {
			Member memberItem = new Member();
			memberItem.setName(item.User__r.Name);
			memberItem.setRole(item.TeamRole__c);
			memberItem.setProfile(item.TeamProfile__r.Name);
			memberItem.setTitle(item.User__r.Title);
			memberItem.setUserId(item.User__r.Id);	
			memberItem.setMemberImg(item.User__r.Id);
			memberItem.setCompany(item.User__r.CompanyName);
			membersList.add(memberItem);
		}
			
		totalItemsNumber = membersList.size();
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
		members = membersList;	
		
	}
	
	 /*
	  * We have to remove all elements of dynamic apex in order to put this application in the
	  * 62 org.  This code will be added back in once dynamic apex is released GA
	  *
	 public void sortList () {
		List<Member> membersList = new List<Member>();
		if (sortBy == System.currentPageReference().getParameters().get('sb')) {
			sortByDesc = !sortByDesc;
		}
		else {
			sortByDesc = false;
		}
		sortBy = System.currentPageReference().getParameters().get('sb');
		List<TeamMember__c> memberResultList = new List<TeamMember__c>();
		String queryStr;
		
		if (letter == null || letter == '' || letter== 'ALL') {
			queryStr = 'select id, Name, TeamRole__c, TeamProfile__r.Name, TeamProfile__r.Description__c, User__r.Name, User__r.Title, User__r.Id, User__r.CompanyName from TeamMember__c where team__c = \'' + idTeam + '\' order by ' + sortBy;
		} 
		else {
			queryStr = 'select id, Name, TeamRole__c, TeamProfile__r.Name, TeamProfile__r.Description__c, User__r.Name, User__r.Title, User__r.Id, User__r.CompanyName from TeamMember__c where User__r.Name like \'' + letter + '%\' and team__c = \'' + idTeam + '\' order by ' + sortBy;
		}
		if (sortByDesc) {
			queryStr += ' desc';
		}
		memberResultList = Database.query(queryStr); 
		for (TeamMember__c item: memberResultList) {
			Member memberItem = new Member();
			memberItem.setName(item.User__r.Name);
			memberItem.setRole(item.TeamRole__c);
			memberItem.setProfile(item.TeamProfile__r.Name);
			memberItem.setTitle(item.User__r.Title);
			memberItem.setUserId(item.User__r.Id);	
			memberItem.setMemberImg(item.User__r.Id);
			memberItem.setCompany(item.User__r.CompanyName);
			membersList.add(memberItem);
		}
			
		totalItemsNumber = membersList.size();
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
		members = membersList;	
		
	}*/
}