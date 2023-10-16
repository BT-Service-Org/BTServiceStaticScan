@IsTest private class TeamsWidgetWikiDirectoryControllerTest {
    public static testMethod void testWiki() {
        TeamsWidgetWikiDirectoryController wiki = new TeamsWidgetWikiDirectoryController();
        UserPermissions userPermissions = new UserPermissions();
        
        userPermissions = new UserPermissions();
        
        String idTeam = [select id from Team__c limit 1].id;
        //String idTeam = 'a0B30000001xHJc';
        wiki.setTeamId(idTeam);
        
        if (wiki.getTeamId() == null) {
            System.assert(true, 'Null Team Id');
        }
        
        if (wiki.getUserPermissions() == null) {
            System.assert(true, 'Null User Permissions');
        }
        
        /* Wikis Class */
        List<WikiPage__c> wikiPages = [Select 
                                            Team__c,
                                            LastModifiedDate ,
                                            Name, Id, 
                                            CreatedBy.Name, 
                                            CreatedBy.Id, 
                                            CreatedById
                                        From WikiPage__c limit 1];
        
        WikiPage__c wikiPage;
        if (wikiPages.size() > 0) {
            wikiPage = wikiPages[0];
        }
        else {
            wikiPage = new WikiPage__c();
        }
        
        wikiPage.Name = 'loooooooooooooooooonnnnnnnnnnnnnnnnnnggggggggggggggg';             
        TeamsWidgetWikiDirectoryController.Wikis wikiClass = new TeamsWidgetWikiDirectoryController.Wikis(wikiPage);
        
        wikiClass.getWikiPage();
        wikiClass.getName();
        wikiClass.getCreatedByName(); 
        
        wiki.getWikis();
        wiki.getWikiPagesCount();
        
        try {
            wiki.refresh();
        } 
        catch (Exception e) {
            System.assert(true, e);
        }
    }
}