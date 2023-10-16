public class TeamAdminQuickLinksController {

	/**
	*
	*/
	public boolean getPermissionAuthorApex(){
		User user = [Select u.Profile.Name, u.ProfileId, u.Name, u.Profile.PermissionsAuthorApex, u.Id From User u Where Id =: UserInfo.getUserId()];
		return user.Profile.PermissionsAuthorApex;
	}
	
	/**
	*
	*/
	public boolean getIsTeamAdmin(){
		List<User> teamAdmin = [Select id, Profile.PermissionsModifyAllData, ProfileId, Name From User where id =:UserInfo.getUserId() limit 1];
        if(getPermissionAuthorApex() && teamAdmin[0].Profile.PermissionsModifyAllData){
        	return true;
        }
        return false;
	}

}