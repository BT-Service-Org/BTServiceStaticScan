public class ProjectTimelineController {

    Team__c team = new Team__c();
    String param = System.currentPageReference().getParameters().get('id');
    
    public ProjectTimelineController(){
        getTeamAndProject(param);
    }
    
    /**
    * Get Team
    *@return Team__c
    */
    public Team__c getTeam(){
        return team;
    }
    
    
    /**
    * Get Project
    *@return Project2__c
    */
    public Project2__c getProject(){
        if(team.Projects__r.size() > 0)
            return team.Projects__r[0];
        return new Project2__c();
    }
    
    /**
    * Get Team and Project for current team id
    *@void
    *@param String param
    */
    public void getTeamAndProject(String param){
        if(param != null){
            team = [select Id, Name, (Select Id, Name From Projects__r) from Team__c t where t.Id =: param];    
        }
    }
    
}