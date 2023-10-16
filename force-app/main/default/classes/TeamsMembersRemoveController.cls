public without sharing class TeamsMembersRemoveController {
	
	public String idTeam = System.currentPageReference().getParameters().get('id');
	public String removeMemberId = System.currentPageReference().getParameters().get('delId');
	
	/*
	public String teamName = [select Name from Team__c where id=: idTeam].Name;
	
	public String getTeamName () {
		return teamName;	
	}
	
	public String getTeamId () {
		return idTeam;	
	}
	
	
	public String getDelName () {
		String delName = '';
		if (removeMemberId != null && removeMemberId != '') {
			delName = [select User__r.Name from TeamMember__c where User__c =: removeMemberId and team__c =: idTeam].User__r.Name;
		}
		return delName;
	}
	*/
	
	//public PageReference removeMember () {
	public void assignRemoveId () {
		removeMemberId = System.currentPageReference().getParameters().get('delId');
	}
		
	
	public void removeMember () {
		System.debug('\n //////////////// \n MEMBER TO REMOVE ID: \n ' + removeMemberId + '\n ////////////////// \n');
		System.debug('\n //////////////// \n TEAM ID: \n ' + idTeam + '\n ////////////////// \n');
		//TeamMember__c delMember = [select User__r.Name from TeamMember__c where User__c =: removeMemberId and team__c =: idTeam];
		//System.debug('\n //////////////// \n MEMBER TO REMOVE: \n ' + delMember.User__r.Name + '\n ////////////////// \n');
		//delete delMember;
		
		//PageReference pageRef = new PageReference('https://na1.salesforce.com/apex/TeamsMembersList?id=' + idTeam);
		//pageRef.setRedirect(true);
		//return pageRef;	
	}
}