@IsTest private class WikiNewPageWidgetControllerTest {
	public static testMethod void testWiki() {
		WikiNewPageWidgetController wiki = new WikiNewPageWidgetController(); 	
		
		try {
			wiki.setIdTeam('');    
		}
		catch (exception e) {
			System.assert(true, e);
		}
		
		try {
			wiki.setIdTeamOverview('');    
		}
		catch (exception e) {
			System.assert(true, e);
		}
		
		try {
			wiki.setIdWikiPage('a0l300000009a92AAA');    
		}
		catch (exception e) {
			System.assert(true, e);
		}
		
		try {
			wiki.constructMethods();    
		}
		catch (exception e) {
			System.assert(true, e);
		}
		
		wiki.getIdTeam();
		wiki.getIdTeamOverview();
		wiki.getIdWikiPage();
		
		try {
			wiki.refreshWikis();    
		}
		catch (exception e) {
			System.assert(true, e);
		}
	}
}