@IsTest private class TeamsNewMemberTest {
    public static testMethod void testTeam() {
        try{
            TeamsNewMemberController team = new TeamsNewMemberController();
            List<SelectOption> option = team.getProfilesOptions ();
            
            Team__c t = [select Id, NewMemberProfile__c from Team__c where NewMemberProfile__c != '' limit 1];
            team.setTeamId(t.Id);
            team.getTeamName();
            
            TeamsNewMemberController.Member member = new TeamsNewMemberController.Member();
            member.setProfileId(t.NewMemberProfile__c);
            member.getMessage();
            member.setMessage('Some Message');
            member.getTeamRole();
            member.setTeamRole('Some Role');
            member.getColleagueNames();
            
            List<User> users = [select Id, Name, Email from User where isActive = true limit 6];
            String names = null;
            for (Integer it = 0; it <= 2; it++){
                names += users[it].Name + ',';  
            }           
            member.setColleagueNames(names);
            
            team.setNewMemberVars(member);
            PageReference page = team.saveMembers ();
            
            names = '';
            for (Integer it = 3; it <= 5; it++){
                names += users[it].Name + ',';  
            }   
            member.setColleagueNames(names);            
            
            team.saveMembersNew();
            team.SendMail(users[0],'Hola mundo');   
            
            
        }catch(Exception e){
            throw e;
        }
    }
}