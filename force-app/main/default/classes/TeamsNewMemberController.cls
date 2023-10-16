public with sharing class TeamsNewMemberController {
	
	public String idTeam = System.currentPageReference().getParameters().get('id');
	
	public String teamName = null;
	
	public String getTeamName () {
		return teamName;	
	}
	
	public void setTeamId(String s){
		idTeam = s;
	}
	
	public String getTeamId() { 
		return idTeam;	
	}
	
	public TeamsNewMemberController (){
		if(idTeam != null)
			teamName = [select Name from Team__c where id=: idTeam].Name;	
	}
	
	public List<SelectOption> getProfilesOptions () {
		List<SelectOption> options = new List<SelectOption>();
		for (TeamProfile__c item: [select id, Name from TeamProfile__c order by Name]) {
			options.add(new SelectOption(item.id,item.Name));
		}
		return options;
	}
	
	public Member newMemberVars = new Member();
	
	public Member getNewMemberVars () {
		return newMemberVars;	
	}
	
	public void setNewMemberVars (Member vars) {
		this.newMemberVars = vars;
	}
	
	public class Member {
		String profileId;
		String message;
		String teamRole;
		String colleagueNames;
	
		public String getColleagueNames () {
			return colleagueNames;
		}
		
		public void setColleagueNames (String names) {
			this.colleagueNames = names;
		}
		
		public String getProfileId () {
			return profileId;
		}
		
		public void setProfileId (String profile) {
			this.profileId = profile;
		}	
		
		public String getMessage () {
			return message;
		}
		
		public void setMessage (String msj) {
			this.message = msj;
		}
		
		public String getTeamRole () {
			return teamRole;
		}
		
		public void setTeamRole (String tRole) {
			this.teamRole = tRole;
		}	
		
	}
		
	public void saveMembersNew () {
		List<TeamMember__c> newMemberList = new List<TeamMember__c>();
		List<String> newMembers = newMemberVars.colleagueNames.split(',');
		List<User> userList = new List<User>();
		Boolean already = false;
		
		for(String item: newMembers) {
			List<User> userItem = new List<User>();
			String itemTrim = item.trim();
			userItem = [select id, Name, Email from User where Name =:itemTrim limit 1];
			if (userItem.size() > 0) {
				already = false;
				Integer listPos = 0;
				while (!already && listPos < userList.size()) {
					if(userList[listPos].Name == userItem[0].Name) {
						already = true;
					}
					listPos++;
				}
				if (!already) {
					userList.add(userItem[0]);	
				}
			}
		}
		
		//System.debug('\n //////////////// \n NEW MEMBERS LIST: \n Names: ' + newMemberVars.colleagueNames + '\n profileId: ' + newMemberVars.profileId + '\n teamRole: ' + newMemberVars.teamRole + '\n message: ' + newMemberVars.message + '\n userList: ' + userList + '\n ////////////////// \n');
		for (User user : userList) {
			Integer isMember = [select count() from TeamMember__c where team__c =:idTeam and user__c =: user.id];
			if (isMember == 0) {
				TeamMember__c newMember = new TeamMember__c();
				newMember.User__c = user.id;
				newMember.Name = user.Name;
				newMember.Team__c = idTeam;
				newMember.TeamProfile__c = newMemberVars.profileId;
				newMember.TeamRole__c = newMemberVars.teamRole;
				newMemberList.add(newMember); 
				SendMail(user,newMemberVars.message); 
				//System.debug('\n //////////////// \n NEW MEMBERS LIST: \n ' + newMemberList + '\n ////////////////// \n');
			}
		}
		//System.debug('\n //////////////// \n NEW MEMBERS LIST: \n ' + newMemberList + '\n ////////////////// \n');
		insert newMemberList;
		
		newMemberVars.colleagueNames = '';
		newMemberVars.teamRole = '';
		newMemberVars.profileId = '';
		newMemberVars.message = '';
	}

	public PageReference saveMembers () {
		List<TeamMember__c> newMemberList = new List<TeamMember__c>();
		List<String> newMembers = newMemberVars.colleagueNames.split(',');
		List<User> userList = new List<User>();
		Boolean already = false;
		
		for(String item: newMembers) {
			List<User> userItem = new List<User>();
			String itemTrim = item.trim();
			userItem = [select id, Name, Email from User where Name =:itemTrim limit 1];
			if (userItem.size() > 0) {
				already = false;
				Integer listPos = 0;
				while (!already && listPos < userList.size()) {
					if(userList[listPos].Name == userItem[0].Name) {
						already = true;
					}
					listPos++;
				}
				if (!already) {
					userList.add(userItem[0]);	
				}
			}
		}
		
		//System.debug('\n //////////////// \n NEW MEMBERS LIST: \n Names: ' + newMemberVars.colleagueNames + '\n profileId: ' + newMemberVars.profileId + '\n teamRole: ' + newMemberVars.teamRole + '\n message: ' + newMemberVars.message + '\n userList: ' + userList + '\n ////////////////// \n');
		for (User user : userList) {
			Integer isMember = [select count() from TeamMember__c where team__c =:idTeam and user__c =: user.id];
			if (isMember == 0) {
				TeamMember__c newMember = new TeamMember__c();
				newMember.User__c = user.id;
				newMember.Name = user.Name;
				newMember.Team__c = idTeam;
				newMember.TeamProfile__c = newMemberVars.profileId;
				newMember.TeamRole__c = newMemberVars.teamRole;
				newMemberList.add(newMember); 
				SendMail(user,newMemberVars.message); 
				//System.debug('\n //////////////// \n NEW MEMBERS LIST: \n ' + newMemberList + '\n ////////////////// \n');
			}
		}
		//System.debug('\n //////////////// \n NEW MEMBERS LIST: \n ' + newMemberList + '\n ////////////////// \n');
		insert newMemberList;
		
		newMemberVars.colleagueNames = '';
		newMemberVars.teamRole = '';
		newMemberVars.profileId = '';
		newMemberVars.message = '';
		
		PageReference pageRef = new PageReference('/apex/TeamsMembersList?id=' + idTeam);
		pageRef.setRedirect(true);
		return pageRef;	
	}
	
	public void SendMail(User user, String message) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       
        String[] toAddresses = new String[] {user.Email};
               
 		// Assign the addresses for the To and CC lists to the mail object.
		mail.setToAddresses(toAddresses);
           
           
		// Specify the address used when the recipients reply to the email.
		mail.setReplyTo('forwardtosfdc@gmail.com');
           
		// Specify the name used as the display name.
		mail.setSenderDisplayName(user.Name);
           
		// Specify the subject line for your email address.
		mail.setSubject('You Have Been Added to ' + teamName);
           
		// Set to True if you want to BCC yourself on the email.
		mail.setBccSender(false);
           
		// Optionally append the salesforce.com email signature to the email.
		// The email address of the user executing the Apex Code will be used.
		mail.setUseSignature(true);
   
		//mail.useSignature(false);
		// Specify the html version of the content as well.
		message = (message == null) ? '' : message;
		mail.setHtmlBody(message);
           
		// Send the email you have created.
            
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }	
}