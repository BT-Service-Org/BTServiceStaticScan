@IsTest private class TeamsRedirectTest {
    
    public static testMethod void testTeam() {
        try{
            TeamsRedirectController team = new TeamsRedirectController();
            List<Team__c> t = [select Id from Team__c limit 70];
            team.setTeamId(t[10].Id);
            team.getTeam();
            PageReference page = team.redirect();   
        }catch(Exception e){
            throw e;
        }
    }   
}