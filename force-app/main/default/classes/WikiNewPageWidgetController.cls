public with sharing class WikiNewPageWidgetController {
	public String idTeam = System.currentPageReference().getParameters().get('id');
	public String idWikiPage = System.currentPageReference().getParameters().get('idWP');
	public String idTeamOverview = System.currentPageReference().getParameters().get('tid');
	
	public void setIdTeam (String idTeam) {
		this.idTeam = idTeam;
	}
	
	public void setIdWikiPage (String idWikiPage) {
		this.idWikiPage = idWikiPage;
	}
	
	public void setIdTeamOverview (String idTeamOverview) {
		this.idTeamOverview = idTeamOverview;
	}
	
	public WikiNewPageWidgetController () {
		constructMethods();
	}
	
	public void constructMethods () {
		if (idTeam != null || idWikiPage != null || idTeamOverview != null) {
			if (idTeamOverview != null && idTeamOverview != '') {
				idTeam = idTeamOverview;
			}
			
			if (idWikiPage != '' && idWikiPage != null) {
				List<WikiPage__c> wikiShareList = [SELECT Team__c From WikiPage__c WHERE id =:idWikiPage];
				if (wikiShareList.size() > 0) {
					idTeam = wikiShareList[0].Team__c;
				}
				else {
					throw new CustomException('Insufficient Privileges');	
				}
			}
		}
	}

	public String getIdTeam () {
		return idTeam;
	}
	
	public String getIdTeamOverview () {
		return idTeamOverview;
	}
	
	public String getIdWikiPage () {
		return idWikiPage;	
	}
	
	public void refreshWikis () {
		System.debug('\n //////////////////// \n \n Refresh!!! \n /////////////// \n');
	}
	
	
	/* Save new Wiki Page */
	public WikiPage__c newWikiPage = new WikiPage__c();
	
	public WikiPage__c getNewWikiPage () {
		return newWikiPage;
	}
		
	public PageReference saveWiki () {
		if (idWikiPage != null && idWikiPage != '') {
			newWikiPage.Parent__c = idWikiPage;
		}
		newWikiPage.Team__c = idTeam;
		newWikiPage.Body__c = '=== Congratulations! === \n You created a new wiki page for your team. Begin by clicking the "Edit" button above to modify this page.';
		
		System.debug('\n\n ////////////////////////////// \n SAVE THIS NEW WIKI: \n' + newWikiPage + '\n /////////////////////// \n\n');
		insert newWikiPage;
		
		if (idWikiPage == null && idTeamOverview == null) {
			TeamsWidgetWikiDirectoryController directory = new TeamsWidgetWikiDirectoryController();
			if (directory.getWikiPagesCount() == 0) {
				directory.setWikiPagesCount(1);
			}	
		}
		newWikiPage = new WikiPage__c();
		return null;
	}
	
	public PageReference saveWikiAndEdit () {
		if (idWikiPage != null && idWikiPage != '') {
			newWikiPage.Parent__c = idWikiPage;
		}
		newWikiPage.Team__c = idTeam;
		newWikiPage.Body__c = '=== Congratulations! === \n You created a new wiki page for your team. Begin by clicking the "Edit" button above to modify this page.';
		
		System.debug('\n\n ////////////////////////////// \n SAVE THIS NEW WIKI: \n' + newWikiPage + '\n /////////////////////// \n\n');
		insert newWikiPage;
		
		PageReference pageRef = new PageReference('/apex/WikiPageEdit?id=' + newWikiPage.Id);
		pageRef.setRedirect(true);
		return pageRef;
	}
		
}