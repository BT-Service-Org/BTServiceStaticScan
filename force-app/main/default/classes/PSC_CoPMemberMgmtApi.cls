/*
* Class: PSC_CoPMemberMgmtApi
* Description: REST API used to add or remove members of Communities of Practice (CoP) teams.
* Author: Scott Ratliff (sratliff@salesforce.com)
*/
@RestResource(urlMapping='/cop-members/*')
global class PSC_CoPMemberMgmtApi {
	private final static String JOIN_ACTION = 'join';
	private final static String REMOVE_ACTION = 'leave';
	private static String copTeamRecordType = null;

	@HttpPost
    global static String addMember(String channelId, String memberEmail, String slackUserId, String action) {
		ApiResponse response = new ApiResponse();

		try {
			validate(channelId,memberEmail,slackUserId,action);
			Id communityId = getCommunityId(channelId);
			Id sfdcUserId = getSfdcUserId(memberEmail,slackUserId);
		
			String returnMessage = null;
			List<Contribution_Team__c> userAssociations = [SELECT Id,Community__c,psc_Team_Member__c FROM Contribution_Team__c WHERE Community__c = :communityId AND psc_Team_Member__c = :sfdcUserId];
	
			if (action == JOIN_ACTION) {
				if (userAssociations.size() > 0) {
					returnMessage = 'User is already a member of this CoP.';
				} else {
					if (copTeamRecordType == null) {
						copTeamRecordType = getCommunityTeamRecordType();
					}
		
					Contribution_Team__c newMember = new Contribution_Team__c();
					newMember.recordTypeId = copTeamRecordType;
					newMember.put(Contribution_Team__c.psc_Role__c, 'Member');
					newMember.psc_Team_Member__c = sfdcUserId;
					newMember.Community__c = communityId;
		
					if (Schema.SObjectType.Contribution_Team__c.isCreateable()) {
						insert newMember;
						returnMessage = 'Member added successfully';
					} else {
						throw new PSCException('API User does not have create authority');
					}
				}
			} else {
				if (userAssociations.size() > 0) {
					if (Schema.SObjectType.Contribution_Team__c.isDeletable()) {
						delete userAssociations;
						returnMessage = 'Member removed successfully';
					} else {
						throw new PSCException('API User does not have delete authority');
					}
				} else {
					returnMessage = 'User was not a member';
				}
			}

			response.status = 200;
			response.message = returnMessage;

		} catch (PSCException psce) {
			response.status = 500;
			response.message = psce.getMessage();
		}

		return JSON.serialize(response);
	}

	/*
	* Gets the corresponding community Id based on the incoming Slack channel Id
	*/
	private static Id getCommunityId(String channelId) {
		List<PSC_Page__c> copChannels = [SELECT Id, Channel_Id__c,Type__c FROM PSC_Page__c WHERE Type__c = 'Community Page' AND Channel_Id__c = :channelId LIMIT 1];

		if (copChannels.size() == 0) {
			throw new PSCException('Not a Communities of Practice Channel');
		} 
		return copChannels[0].Id;
	}

	/*
	* Gets the corresponding salesforce Id based on the input email address
	*/
	private static Id getSfdcUserId(String memberEmail, String slackUserId) {
		List<User> users = [SELECT Id, Slack_User_Id__c FROM User WHERE FederationIdentifier = :memberEmail LIMIT 1];

		if (users.size() == 0) {
			throw new PSCException('User is not a valid salesforce user.');
		}

		return users[0].Id;
    }

	/*
	* Gets the communityTream record type.   This is needed because of the values in member type picklist vary by record type.
	*/
	private static String getCommunityTeamRecordType() {
		RecordType copTeamType = [SELECT Id FROM RecordType WHERE SobjectType = 'Contribution_Team__c' AND Name = 'Community of Practice' LIMIT 1];

		if (copTeamType != null) {
			return copTeamType.Id;
		} else {
			return null;
		}
	}

	/*
	* Validate the API Payload 
	*/
	public static boolean validate(String channelId, String memberEmail, String slackUserId, String action) {
		if (channelId == null || String.isBlank(channelId)) {
			throw new PSCException('Please provide a valid channel Id.');
		}
		if (memberEmail == null || String.isBlank(memberEmail)) {
			throw new PSCException('Please provide a valid email address.');
		}
		if (slackUserId == null || String.isBlank(slackUserId)) {
			throw new PSCException('Please provide a valid slack userid.');
		}
		if (action == null || (action != JOIN_ACTION && action != REMOVE_ACTION)) {
			throw new PSCException('Please provide a valid action.');
		}
		
		return true;
	}

	private class ApiResponse {
		private Integer status {get;set;}
		private string message {get;set;}
	}
	
}