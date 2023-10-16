public with sharing class TeamSearchResultController {

	public TeamSearchResultController(){
		criteria = System.currentPageReference().getParameters().get('key');
	}	
	
	public String teamId = System.currentPageReference().getParameters().get('teamId');
	public LeaveJoinTeam leaveJoinTeam = new LeaveJoinTeam();
	
	public void setTeamId (String team){
		teamId = team;
	}		
	
	public String criteria;
	
	public String getCriteria () {
		return criteria;
	}
	
	public void setCriteria (String criteria) {
		this.criteria = criteria;
	}
	
	
	public class sr{
		String teamName;
		String matches;
		String url;
		String teamId = System.currentPageReference().getParameters().get('teamId');
		Boolean isMember;
		Boolean closeTeam;
		Id idTeamMember;
		
		/* ************************ */
		/*		  Setters			*/
		/* ************************ */			
		public void setIdTeamMember (Id idTeamMember) {
			this.idTeamMember = idTeamMember;	
		}
	
		public void setCloseTeam (Id newNenberProf) {
			if (newNenberProf == null) {
				this.closeTeam = true;
			}
			else {
				this.closeTeam = false;
			}
		}
		
		public void setIsMember (Boolean isMember) {
			this.isMember = isMember;
		}
		
		public void setTeamId (String teamId) {
			this.teamId = teamId;
		} 
	
		public void setTeamName (String name, String criteria) {
			String highlight = '';
			if (name != null) {
			
				String nameLow = name.toLowerCase();
				String criteriaLow = criteria.toLowerCase();
				
				if (criteria != null && criteria != '' && nameLow.indexOf(criteriaLow) != -1) {
					highlight = name.replaceAll('(?i)' + criteria, '<span class="highlight">$0</span>');
				}else{
					highlight = name;
				}
			}
			
			System.debug('\n /////////////////////////// \n highlight: ' + highlight);
			this.teamName = highlight;	
		}	
		
		
		public void setMatches (String matches, String criteria) {
			String highlight = '';
			Integer maxLength = 50;
			if (matches != null) {
				String matchesLow = matches.toLowerCase();
				String criteriaLow = criteria.toLowerCase();
				matches = matches.replaceAll('(?i)<[^>]*>', '');
				if (criteria != null && criteria != '' && matchesLow.indexOf(criteriaLow) != -1) {
					Integer msjLength = matches.length();
					Integer iniHighLight = matchesLow.indexOf(criteriaLow) - 50;
					Integer criteriaLength = criteria.length();
					Integer endHighLight = matchesLow.indexOf(criteriaLow) + criteriaLength + 50;
					if (iniHighLight < 0) {
						if (endHighLight > msjLength) {
							highlight = matches.substring(0,msjLength);	
						}
						else {
							highlight = matches.substring(0,endHighLight) + '...';	
						}
					}
					else {
						if (endHighLight > msjLength) {
							highlight = '...' + matches.substring(iniHighLight,msjLength);	
						}
						else {
							highlight = '...' + matches.substring(iniHighLight,endHighLight) + '...';	
						}		
					}
					
					highlight = highlight.replaceAll('(?i)' + criteria, '<span class="highlight">$0</span>');
				}
				else {
					if(matches.length() <= maxLength*2) {
						highlight = matches;	
					}
					else {
						//highlight = matches;
						highlight = matches.substring(0,maxLength*2) + '...';	
					}	
				}
			}
			this.matches = highlight;
		}
			
		
		/* ************************ */
		/*		  Getters			*/
		/* ************************ */			
		public Id getIdTeamMember () {
			return idTeamMember;
		}
		
		public Boolean getCloseTeam () {
			return closeTeam;
		}
		
		public Boolean getIsMember () {
			return isMember;
		}
		
		public String getTeamId () {
			return teamId;
		}
		
		public String getMatches () {
			return matches;
		}
		
		public String getUrl () {
			return url;
		}		
		
		public String getTeamName () {
			return teamName; 
		}		
			
	}
	
	public Integer totalItemsNumber= 0;
	
	public Integer getTotalItemsNumber () {
		return totalItemsNumber;
	}
	
	public Boolean noMatches;
	
	public Boolean getNoMatches () {
		return noMatches;	
	}	
	
	public List<sr> srList = new List<sr>();	
	
	public List<sr> getsrList () {
		return srList;
	}
	
	public List<Team__c> results = new List<Team__c>();
	
	public List<Team__c> getResults () {
		return results; 
	}

	public void search () {
		
		List<sr> srList2 = new List<sr>();	
		
		List<TeamMember__c> allMembers = [select id, Team__c , User__c from TeamMember__c];
		
		if (criteria == null || criteria == '') {
			results = [select Name, Description__c, Id, NewMemberProfile__c from Team__c where PublicProfile__c != null and NewMemberProfile__c != null order by Name];
		}else{
			System.debug('HERE:' + criteria);
			results = (List<Team__c>)[FIND :(criteria + '*') IN ALL FIELDS RETURNING Team__c (Id, NewMemberProfile__c, Name, Description__c where PublicProfile__c != null or NewMemberProfile__c != null)][0];
		}

		for(Team__c l: results){
			sr searchResult = new sr();
			searchResult.setTeamName(l.Name, criteria);
			searchResult.setTeamId(l.Id);
			searchResult.setMatches(l.Description__c, criteria);
			
			Boolean findM = false;
			Integer posList = 0;
			Id idTeamMember;
			while (!findM && (posList < allMembers.size())) {
				if ((allMembers.get(posList).User__c == UserInfo.getUserId()) && (allMembers.get(posList).Team__c == l.Id)) {
					findM = true;
					idTeamMember = allMembers.get(posList).Id;
				}
				else {
					posList++;
				}		
			}
			
			searchResult.setIsMember(findM);
			searchResult.setIdTeamMember(idTeamMember);
			searchResult.setCloseTeam(l.NewMemberProfile__c);
			srList2.add(searchResult);
		}	
		
		srList = srList2;
		totalItemsNumber = srList.size();
		if (totalItemsNumber == 0 ) {
			noMatches = true;
			cntPagination = 0;	
			firstRow = 0;
			currentPagination = 1;
			jumpPage = 1;
		}
		else {
			noMatches = false;
			firstRow = 0;
			currentPagination = 1;
			jumpPage = 1;
			genCntPagination();	
		}
		
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
   		jumpPage = currentPagination;
   		firstRow = firstRow + numberOfItemsToShow;   		
   	}
   	
   	public void prevPage () {
   		currentPagination--;
   		jumpPage = currentPagination;
   		firstRow = firstRow - numberOfItemsToShow;	
   	}

	/* Last Page */
   	public void lastPage () {
   		currentPagination = cntPagination;
		jumpPage = cntPagination;
		firstRow = (jumpPage - 1)* numberOfItemsToShow;		
   	}
   	
   	/* First Page */
   	public void firstPage () {
   		currentPagination = 1;
   		jumpPage = 1;
   		firstRow = (jumpPage - 1)* numberOfItemsToShow;	
   	}

   	public void refreshPages () {
   		
   	}
   	/**
   	* Pagination Integer Getters
   	*/
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
   		if((currentPagination == cntPagination) || (cntPagination == 0)){ 
   			nextPageShow = true; 
		} else { 
			nextPageShow = false;
		} 
   		return nextPageShow;
   	}	
   	
	/* ************************ */
	/*		  Jump to Page		*/
	/* ************************ */
	
	public Integer jumpPage = 1;
	
	public Integer getJumpPage () {
		return jumpPage;
	}
	
	public void setJumpPage (Integer jumpPage) {
		this.jumpPage = jumpPage;
	}
	
	public void JumpToPage () {
		if (jumpPage > cntPagination) {
			currentPagination = cntPagination;
			jumpPage = cntPagination;
		}
		else {
			if (jumpPage < 1) {
				currentPagination = 1;
				jumpPage = 1;
			}
			else {	
				currentPagination = jumpPage;
			}
		}
		firstRow = (jumpPage - 1)* numberOfItemsToShow;
	}
	
	/**
	* Inner without sharing class
	*/
	public without sharing class LeaveJoinTeam{
		
		/**
		* Join Team w/o sharing
		*/
		public PageReference joinTeam(String teamId){
			Team__c t = [select Id, NewMemberProfile__c from Team__c where Id =: teamId];
			TeamMember__c newUserJoin = new TeamMember__c();
			newUserJoin.User__c = UserInfo.getUserId();
			newUserJoin.TeamProfile__c = t.NewMemberProfile__c;
			newUserJoin.Team__c = teamId;
			insert newUserJoin;
			//search();	
			Team__c teamT = [SELECT TeamType__c, TeamType__r.Id FROM Team__c WHERE id =: teamId];
			String teamTypeId;
			if (teamT.TeamType__c != null) {
				teamTypeId = teamT.TeamType__r.Id;
			}
	 		PageReference pageRef = new PageReference('/apex/TeamsDetail' + teamTypeId + '?id=' + teamId + '&j=true');
			pageRef.setRedirect(true);
			return pageRef;
		}
		
		/**
		* Leave Team w/o sharing
		*/
		public void leaveTeam(String teamId){
			 TeamMember__c userRow = new TeamMember__c();
			 try {
			 	userRow = [Select Id, User__c, Team__c from TeamMember__c where User__c =: UserInfo.getUserId() and Team__c =: teamId];
			 	delete userRow; 
			 }catch(Exception e){ 
			 	throw e;
			 }
		}			
	
	}
	
	
	/* ************************ */
	/*		  Join Team 		*/
	/* ************************ */	
	public PageReference joinTeam(){
		if(System.currentPageReference().getParameters().get('teamId') != null)
	 		teamId = System.currentPageReference().getParameters().get('teamId');		
		PageReference pr = leaveJoinTeam.joinTeam(teamId);
		return pr;
	}
	
	/* ************************ */
	/*		  Leave Team 		*/
	/* ************************ */	
	public void leaveTeam(){
		if(System.currentPageReference().getParameters().get('teamId') != null)
	 		teamId = System.currentPageReference().getParameters().get('teamId');		
		leaveJoinTeam.leaveTeam(teamId);
		search();	
	}
	
	public String getCurrentUser () {
		return UserInfo.getUserId();
	}
	
	public String leaveTeamId;
	
	public String getLeaveTeamId () {
		return leaveTeamId;
	}
	
	public String leaveTeamName;
	
	public String getLeaveTeamName () {
		return leaveTeamName;
	}
	
	public Integer leaveTeamCnt;
	
	public Integer getLeaveTeamCnt () {
		return leaveTeamCnt;
	}
	
	public void assignLeaveTeamId () {
		teamId = System.currentPageReference().getParameters().get('teamId');
		if (teamId != null) {
			leaveTeamCnt = [select count() from TeamMember__c where team__c =:teamId];
			leaveTeamName = [select Name from Team__c where Id =:teamId].Name;
			leaveTeamId = teamId;
		}
	}
	
	
}