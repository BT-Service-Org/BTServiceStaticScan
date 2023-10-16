public with sharing class TeamsWidgetWikiDirectoryController {

	
	// Get Team Id Attribute
	String teamId;
	
    // Setter method for Team Id variable
	public void setTeamId(String tID) {
		teamId = tID;	
		genPermissions();	
	}
	
	public String getTeamId(){
		return teamId;
	}
	
	Integer wikiPagesCount;
    
    	
	/* ---------------------------- */
   	/*   	 SHARING RULES			*/
   	/* ---------------------------- */	
	public UserPermissions userPermissions = new UserPermissions();
		
	public void genPermissions () {
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setTeam(teamId);
		userPermissions.setObjectType('Wiki');
		userPermissions.setPermissions();		
	}
	
	public UserPermissions getUserPermissions () {
		System.debug('\n //////////////////////// \n USER PERMISSIONS: \n' + userPermissions + '\n //////////////////////////////// \n');
		return userPermissions;
	}
	/* ---------------------------- */	

	public class Wikis {
	
		WikiPage__c wikiPage;
		String name;
		String createdByName;
		
		public Wikis (WikiPage__c wiki) {
			wikiPage = wiki;
		}
		
		public WikiPage__c getWikiPage () {
			return wikiPage;
		}
		
		public String getName () {
			String trunkName = wikiPage.Name;
			if(wikiPage.Name.length() > 17) {
				trunkName = wikiPage.Name.substring(0,17) + '..';
			}
			return trunkName; 
		}
		
		public String getCreatedByName () {
			String trunkCreatedByName = '';
			if (wikiPage.CreatedBy != null) {
				trunkCreatedByName = wikiPage.CreatedBy.Name;
				if(wikiPage.CreatedBy.Name.length() > 17) {
					trunkCreatedByName = wikiPage.CreatedBy.Name.substring(0,17) + '..';
				}
			}
			return trunkCreatedByName; 
		}
	}

    
    
    public List<Wikis> getWikis() {
		List<WikiPage__c> wikis = new List<WikiPage__c>();
	   	wikis =  [Select Team__c,
					 LastModifiedDate ,
					 Name, Id, 
					 CreatedBy.Name, 
					 CreatedBy.Id, 
					 CreatedById
					 From WikiPage__c  
					 Where Team__c =: teamId and Parent__c = ''
					 ORDER BY Name ASC limit 100];
 		
 		List<Wikis> resultWikis = new List<Wikis>();
 		
 		for (WikiPage__c item: wikis) {
 			Wikis itemWiki = new Wikis(item);
 			resultWikis.add(itemWiki);
 		}
 		
 		//wikiPagesCount = wikis.size();
 		setWikiPagesCount(wikis.size());
 		
 		return resultWikis;
    } 
    
    public Integer getWikiPagesCount(){
    	return wikiPagesCount;
    }
    
    public void setWikiPagesCount(Integer count){
    	wikiPagesCount = count;
    }
    
    public void refresh() {
    	System.debug('\n ////////////////////////////////////// \n REFRESH \n //////////////////////////////// \n');
    }
    	
}