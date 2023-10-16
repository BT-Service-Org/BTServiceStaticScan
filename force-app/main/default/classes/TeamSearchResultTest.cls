@IsTest private class TeamSearchResultTest {

    public static testMethod void testTeam() {
        try{
            TeamSearchResultController team = new TeamSearchResultController();
            
            team.setCriteria('');
            team.search();
            String criteria = team.getCriteria();
            List<Team__c> results = team.getResults();
                        
            TeamMember__c tm = [select Id, Team__c from TeamMember__c where Team__c != '' limit 1];
            
            TeamSearchResultController.sr srch = new TeamSearchResultController.sr();
            List<TeamSearchResultController.sr> srchList = team.getsrList();
            srch.setTeamName('Team', 'Tea');
            srch.setMatches('Tea', 'Tea');
            srch.setIsMember(true);
            srch.setIdTeamMember(tm.Id);
            srch.setCloseTeam(tm.Id);           
            Id idMember = srch.getIdTeamMember();
            Boolean closeTeam = srch.getCloseTeam();
            Boolean isMember = srch.getIsMember();
            String teamId = srch.getTeamId();
            String matches = srch.getMatches();
            String url = srch.getUrl();
            String teamName = srch.getTeamName();
            
            team.setTeamId(tm.Team__c);
            srch.setIdTeamMember(tm.Id);
            srch.setTeamId(tm.Team__c);
            team.genCntPagination();
            team.nextPage();
            team.prevPage();
            team.lastPage();
            team.firstPage();
            
            Boolean b1 = team.getPrevPageLinkShow();
            Boolean b2 = team.getPrevPageShow();
            Boolean b3 = team.getNextPageLinkShow();
            Boolean b4 = team.getNextPageShow();
            Boolean b5 = team.getNoMatches();
            team.getLastItem();
            team.getFirstItem();
            Integer totalNumers = team.getTotalItemsNumber();
            Integer firstRow = team.getFirstRow();
            Integer leaveTeam = team.getLeaveTeamCnt();
            
            team.setJumpPage(1);
            team.JumpToPage();
            team.leaveTeam();
            team.assignLeaveTeamId();
            team.setTeamId(tm.Team__c);
            PageReference pr = team.joinTeam();         
        
        } catch (Exception e){
            throw e;
        }
    } 
}