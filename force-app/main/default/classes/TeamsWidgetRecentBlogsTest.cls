@IsTest private class TeamsWidgetRecentBlogsTest {
    public static testMethod void testTeam() {
        try{
            TeamsWidgetRecentBlogsController team= new TeamsWidgetRecentBlogsController();
            List<BlogEntry__c> blogs =  team.getBlogs();
            Boolean previlege = team.getnewPrivileges();
            String teamId = team.getTeamIdBlog();
            Integer n = team.getblogCount();
            team.setblogCount(1);
        }catch(Exception e){
            throw e;
        }
    }
}