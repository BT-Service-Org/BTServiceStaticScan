@IsTest private class TeamMembersListTest {

    public static String idTeam = System.currentPageReference().getParameters().get('id');
    public static Boolean sortByDesc = false;
    
    public static String sortBy = 'User__r.Name';
    
    public static testMethod void testTeam() {
        try{
            TeamMembersListController team = new TeamMembersListController();
        
            List<TeamMember__c> tms = [select Id, User__c, Team__c from TeamMember__c where User__c !=: UserInfo.getUserId() limit 2];
            team.setIdTeam(tms[0].Team__c);
            team.setRemoveMemberId(tms[0].User__c);
            
            team.getRemoveMessage();
            PageReference page = team.removeMember();
            
            List<SelectOption> option = team.getProfilesOptions();
            List<SelectOption> option2 = team.getProfilesOptionsFilter();
            
            team.setEditMemberId(tms[1].User__c);
            team.setIdTeam(tms[1].Team__c);
            team.assignEditId();

            team.getTeamEditProfiles(); 
            team.assignRemoveId ();
            team.getAdminCount();
            team.getUserMemberId();
            team.getCurrentUser();
            team.getDelName();
            team.genCntPagination();
            team.nextPage();
            team.prevPage();
            team.getCurrentPagination();
            team.getNumberOfItemsToShow();
            team.getFirstRow();
            team.getLastItem();
            team.getTotalItemsNumber();
            
            Boolean b1 = team.getPrevPageLinkShow();
            Boolean b2 = team.getPrevPageShow();
            Boolean b3 = team.getNextPageLinkShow();
            Boolean b4 = team.getNextPageShow();
            
            team.getIsTeamAdmin();
            
            TeamMembersListController.Member member = new TeamMembersListController.Member();
            member.getYahoo();
            member.getSkype();
            member.getUserId();
            member.getTeamMemberId();
            member.setTeamMemberId(tms[1].Id);
            member.getName();
            member.getMemberImg();
            member.getCompany();
            member.getTitle();
            member.getProfile();
            member.getRole();
            member.setUserId(tms[1].User__c);
            member.setCompany('');
            member.setName('');
            member.setMemberImg(tms[1].User__c);
            member.setProfile('');
            member.setRole('');
            member.setTitle('');
            member.setAdmin(true);
            member.getAdmin();
                        
            team.setLetter('T');
            team.genMembers();
            
            team.setLetter('ALL');
            team.genMembers();
            
            TeamMembersListController.Letters letter = new TeamMembersListController.Letters();
            letter.setLetter('');
            letter.getLetter();
            letter.setContainMembers(0);
            letter.getContainMembers();
            
            List<TeamMembersListController.Letters> letterList = team.getLetterFilter();
            
            String sortBye =  team.getSortBy ();
            team.sortList();
            
            team.setSortBy('User__r.CompanyName');
            team.sortList();            
            
            team.setSortBy('User__r.Title');
            team.sortList();            
       
            PageReference pageEdit = team.editMemberAction();
        }
        catch(Exception e){
            throw e;
        }
    }
}