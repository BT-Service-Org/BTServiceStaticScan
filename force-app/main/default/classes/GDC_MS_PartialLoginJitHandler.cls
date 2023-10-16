//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class GDC_MS_PartialLoginJitHandler implements Auth.SamlJitHandler {

	private class JitException extends Exception{}

	global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
		User u = new User();
		return u;
	}

	global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
		User u = [SELECT Id, Name, ContactId FROM User WHERE Id=:userId WITH SECURITY_ENFORCED];
		system.debug('User Detail 		:::::  ' + u);
		handleJit(false, u, samlSsoProviderId, communityId, portalId,federationIdentifier, attributes, assertion);
	}

       private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
		if (!create) {
			String permissionSetNames = System.Label.GDC_MS_PermissionSet;
			String permissionSetNameForManagers = System.Label.GDC_MS_WorkIntake_Admin_PermissionSet;

			List<String> neededPermissionForUser 	= new List<String>();
			List<String> availablePermissionSets 	= new List<String>();
			List<String> missingPermissionSets 		= new List<String>();

			Integer count = [Select COUNT() from gdc_ms_TeamMember__c where gdc_ms_Manager__r.gdc_ms_MappedUser__c =:u.Id WITH SECURITY_ENFORCED];

			if (permissionSetNames.contains(',') && permissionSetNames.split(',').size() > 0) {
				neededPermissionForUser = permissionSetNames.deleteWhitespace().split(',');
			} else {
				neededPermissionForUser.add(permissionSetNames.deleteWhitespace());
			}

			if(count>0){
                            neededPermissionForUser.add(permissionSetNameForManagers);
			}

			for (PermissionSetAssignment psa : [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =: u.Id WITH SECURITY_ENFORCED]) {
				availablePermissionSets.add(psa.PermissionSet.Name);
			}

			if (!availablePermissionSets.isEmpty()) {
				for (String np : neededPermissionForUser) {
					if (!availablePermissionSets.contains(np)) {
						missingPermissionSets.add(np);
					}
				}
			} else {
				missingPermissionSets = neededPermissionForUser;
			}

			if (!missingPermissionSets.isEmpty()) {
				updatePermissionSets(u, missingPermissionSets);
			}
		}
    }

	private void updatePermissionSets(User u, List<String> missingPermissionSets) {

		if (u != null && !missingPermissionSets.isEmpty()) {

			List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();

			for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name =: missingPermissionSets WITH SECURITY_ENFORCED]) {
				PermissionSetAssignment psa = new PermissionSetAssignment();
				psa.PermissionSetId = ps.Id;
				psa.AssigneeId		= u.Id;
				psaList.add(psa);
			}

			if (!psaList.isEmpty()) {
				try {
					Database.insert(psaList);
				} catch (Exception ex) {
					System.debug('Error updating the permission set assignement ::: ' + ex.getMessage());
				}
			}
		}
	}
}