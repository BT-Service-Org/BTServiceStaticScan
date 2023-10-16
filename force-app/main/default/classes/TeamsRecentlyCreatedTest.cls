@IsTest private class TeamsRecentlyCreatedTest {
    public static testMethod void TeamsRecentlyCreated (){
        try{
            TeamsRecentlyCreated team = new TeamsRecentlyCreated();
            team.getRecentTeamsList();
            Team__c t = [select Id, TeamCreatedBy__c from Team__c limit 1];
            TeamsRecentlyCreated.RecentTeams rt = new TeamsRecentlyCreated.RecentTeams(t);
            rt.getCreator();
            rt.getTeamPicture();
            User u = rt.getCreatedBy();
            String pic = rt.getPicture();
            t = rt.getTeam();
            List<TeamsRecentlyCreated.RecentTeams> rtList = team.getRecentTeams();
        }catch(Exception e){
            throw e;
        }
    }
}