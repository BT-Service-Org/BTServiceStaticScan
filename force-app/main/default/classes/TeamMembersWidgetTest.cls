@IsTest private class TeamMembersWidgetTest {
    public static testMethod void testTeam() {
        try{ 
            TeamMembersWidgetController team = new TeamMembersWidgetController();
            Team__c t = [select Id from Team__c limit 1];
            team.setIdTeam(t.Id);
            team.setTeam(t.Id);
            team.setTypeList('adminList');
            String result = team.getComponentHeader ();
            Boolean render = team.getRenderLinkAction ();
            String teamName = team.getTeam();
            String teamId = team.getTeamId();
            team.getIsTeamAdmin();
            String typeList = team.getTypeList();
            
            TeamMember__c m = new TeamMember__c();
            TeamMembersWidgetController.TeamMember teamMember= new TeamMembersWidgetController.TeamMember(m, null);
            m = teamMember.getMember();
            String userName = teamMember.getUsername();
            String yahoo = teamMember.getYahoo();
            String skype = teamMember.getSkype();
            String status = teamMember.getStatus();
            PeopleProfile__c profile = teamMember.getProfile();
            String pic = teamMember.getImage(); 
            
            TeamMembersWidgetController.Member member = new TeamMembersWidgetController.Member();
            member = team.getNewMemberVars();
            
            List<User> users = [select Id, Name from User where isActive = true limit 3];
            String names = null;
            for (User u : users){
                names += u.Name + ',';  
            }
            member.setColleagueNames(names);
            team.setNewMemberVars(member);
            team.getTeamspaceMembers();
            
            List<SelectOption> options = team.getProfilesOptions();
            List<TeamMember__c> members = team.getMemberListToolkit();
            Integer cnt = team.getMemberListToolkitCount();
            
            
            team.saveMembersNew();
            team.saveMembers();
            User user = [select Name, Email from User limit 1];
            team.SendMail(user, 'Message');

        }catch(Exception e){
            throw e;
        }
    }
}