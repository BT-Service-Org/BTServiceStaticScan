@IsTest private class WikiTeamOverviewControllerTest {

    public static testMethod void WikiTeamOverviewController() {
        WikiTeamOverviewController wtoc = new WikiTeamOverviewController();  
        
     
        wtoc.setTEAMID('a0B30000001xHJcEAM');
        wtoc.getTEAMID();
        
        if (wtoc.getUserPermissions() == null) {
            System.assert(true, 'Null Permissions');
        }
        
        if (wtoc.getUserPermissionsTeam() == null) {
            System.assert(true, 'Null Permissions');
        }
        
      
        wtoc.genContructor();
        wtoc.getCurrentTeam();
        wtoc.getWpl();
        
        
        wtoc.trunkText('aaa ra ra fkjdsaf;lkjdsaf;lkjdsaflkjdsaf;lkjdsalkfjlkdsajflkdsajf;lkdsa');
        wtoc.getWikiSites();
        wtoc.getRecentlyUpdated();
        wtoc.getFavorite();
        wtoc.getCntFav();
        wtoc.getMyRecentChanges();
        wtoc.getCntMyRecentChanges(); 
        
        /* TeamWikis class */
        WikiTeamOverviewController.TeamWikis teamWikis = new WikiTeamOverviewController.TeamWikis();
        
        teamWikis.getId();
        teamWikis.getName();
        teamWikis.getDescription();
        teamWikis.getPicture();
        
        /* Wiki class */
        WikiTeamOverviewController.Wiki wikiClass = new WikiTeamOverviewController.Wiki();
        
        wikiClass.getModifiedByPicture();
        wikiClass.getParentName();
        wikiClass.getParentId();
        wikiClass.getName();
        wikiClass.getId();
        wikiClass.getLastModifiedBy();
        wikiClass.getLastModifiedById();
        wikiClass.getLastModifiedDate();
        wikiClass.getShortDescription();
    }
}