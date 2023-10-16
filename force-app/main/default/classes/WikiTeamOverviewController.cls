public with sharing class WikiTeamOverviewController {
	
	// Team__c given in the url
	public String TEAMID = System.currentPageReference().getParameters().get('tid');
	
	public void setTEAMID(String sTeam){
		TEAMID = sTeam;		
	}
	
	
	// List of wiki pages
	List<wikiPageInfo> wikiPagesList = new List<wikiPageInfo>();
	// List of Wiki childs 
	List<wikiPageInfo> wikiPagesChildList = new List<wikiPageInfo>();
	
	public String getTEAMID (){
		return TEAMID;
	}
	
	// Constructor 
	public WikiTeamOverviewController () {
		genContructor();
	}
	
	public void genContructor () {
		if (TEAMID != null && TEAMID != '') {
			genWikiTree();
			genTeamData();
			genWikiSites();
			genPermissions();
			genPermissionsTeam();
			if(!userPermissionsTeam.getCanView()) {
				throw new CustomException('Insufficient Privileges');	
			}
		}
	}
	/* ---------------------------- */
   	/*   	 SHARING RULES			*/
   	/* ---------------------------- */	
	public UserPermissions userPermissions = new UserPermissions();
		
	public void genPermissions () {
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setTeam(TEAMID);
		userPermissions.setObjectType('Wiki');
		userPermissions.setPermissions();		
	}
	
	public UserPermissions getUserPermissions () {
		System.debug('\n //////////////////////// \n USER PERMISSIONS: \n' + userPermissions + '\n //////////////////////////////// \n');
		return userPermissions;
	}
	
	public UserPermissions userPermissionsTeam = new UserPermissions();
		
	public void genPermissionsTeam () {
		userPermissionsTeam.setId(UserInfo.getUserId());
		userPermissionsTeam.setTeam(TEAMID);
		userPermissionsTeam.setObjectType('Team');
		userPermissionsTeam.setPermissions();		
	}
	
	public UserPermissions getUserPermissionsTeam () {
		System.debug('\n //////////////////////// \n USER PERMISSIONS: \n' + userPermissionsTeam + '\n //////////////////////////////// \n');
		return userPermissionsTeam;
	}
	/* ---------------------------- */	

	
	Team__c currentTeam = new Team__c();
	
	public Team__c getCurrentTeam(){
		return currentTeam;
	}
	
	public void genTeamData(){
		if(TEAMID != null)
			currentTeam = [select Id, Name from Team__c where id =: TEAMID];
	}
	
   	/* ------------------------------------ */
   	/*   		WIKI Pages TREE				*/
   	/* ------------------------------------ */	
	
	public void genWikiTree(){
		wikiPagesList.clear();
		List<WikiPage__c> wpl = new List<WikiPage__c>();
		
		wpl = [ Select Id, Parent__c,  Name, (Select Parent__c , Name , Id From WikiPages__r) From WikiPage__c where Team__c =: TEAMID and Parent__c = ''];
		
		List <WikiPage__c> wpchildListSecondLevel = [ Select Id, Parent__c,  Name, (Select Parent__c , Name , Id From WikiPages__r) From WikiPage__c where Parent__c in :wpl];
		
		for(WikiPage__c wp: wpl){
			wikiPageInfo wpage = new wikiPageInfo();
			wpage.Id = wp.Id; 
			wpage.Parent = wp.Parent__c;
			wpage.Name = trunkText(wp.Name);
			if(wp.WikiPages__r.size() != 0 ){
				wpage.HasChilds = true;
				
				List<wikiPageChild> wikiChilds = new List<wikiPageChild>();
				
				for(WikiPage__c wpchild: wpchildListSecondLevel){
					
					if(wpchild.Parent__c == wp.Id){
											
						wikiPageChild wikiChildItem = new wikiPageChild();
						
						wikiChildItem.Id = wpchild.Id;
						wikiChildItem.Parent = wpchild.Parent__c;
						wikiChildItem.Name = trunkText(wpchild.Name);
												
						
						if(wpchild.WikiPages__r.size() != 0){
							wikiChildItem.HasChilds = true;
						} else {
							wikiChildItem.HasChilds = false;
						}					
						
						wikiChilds.add(wikiChildItem);
					}
				}			
				
				wpage.childs = wikiChilds;
				
			} else {
				wpage.HasChilds = false;
			}	
					
			wikiPagesList.add(wpage);
		}		
		
	}
	
	public String trunkText(String t){
		
		String text = '';
		
		if(t.length() > 30){
			text = t.substring(0, 30 );
			text = text + '...';
		} else {
			text = t;
		}
		
		return text;		
	}
	
	public class wikiPageInfo {
		public String Id {set; get;}
		public String Parent { set; get; }
		public String Name { set; get; }
		public Boolean HasChilds { set; get; }
		public List<wikiPageChild> childs { set; get; }
	}
	
	public class wikiPageChild {
		public String Id {set; get;}
		public String Parent { set; get; }
		public String Name { set; get; }
		public Boolean HasChilds { set; get; }
	}
	
	public List<wikiPageInfo> getWpl(){
		return wikiPagesList;
	}
   	
   	/* ---------------------------- */
   	/*   		WIKI SITES			*/
   	/* ---------------------------- */	
   	
	public List<TeamWikis> wikiSites;
	
	public List<TeamWikis> getWikiSites () {
		return wikiSites;
	}
	
	public void genWikiSites () {
		List<Team__c> sites;
		sites = [select Id, Name, Description__c from Team__c order by Name limit 10];
		
		List<TeamWikis> teamWikiList = new List<TeamWikis>();
		for (Team__c item : sites) {
			TeamWikis teamWikiItem = new TeamWikis();
			teamWikiItem.setId(item.Id);
			teamWikiItem.setName(item.Name);
			teamWikiItem.setDescription(item.Description__c);
			teamWikiItem.setPicture(item.Id);
			teamWikiList.add(teamWikiItem);
		}
		
		wikiSites = teamWikiList;
	}

    /* ---------------------------- */
   	/*        TEAM WIKIS CLASS	    */
   	/* ---------------------------- */  	
   	
   	public class TeamWikis  {
   		String id;
   		String name;
   		String description;
   		String picture;
   		
   		public String getId () {
   			return id;
   		}
   		
   		public String getName () {
   			return name;
   		}
   		
   		public String getDescription () {
   			return description;
   		}
   		
   		public String getPicture () {
   			return picture;
   		}
   		
   		public void setId (String id) {
   			this.id = id;
   		}
   		
   		public void setName (String name) {
   			this.name = name;
   		}
   		
   		public void setDescription (String description) {
   			this.description = description;
   		}
   		
   		public void setPicture (String picture) {
   			
   			List<Attachment> attach = new List<Attachment>();
	    	attach = [select Id from Attachment where ParentId =:picture limit 1];
	        if(attach.size() > 0) {	
	        	this.picture = attach[0].Id;
	        }
	        else {
	        	this.picture = '';
	        }
   		}  
   	}
   	
	
   	/* ---------------------------- */
   	/*   	RECENTLY UPDATED		*/
   	/* ---------------------------- */
   	public class Wiki {
   		String name; 
   		String id;
   		String lastModifiedBy;
   		String lastModifiedById;
   		String lastModifiedDate;
   		String parentName;
   		String parentId;
   		String shortDescription;
   		String modifiedByPicture;
   		
		public void setModifiedByPicture (String modById) {
			String PictureId = '';
			
			List<PeopleProfile__c> itemProfile = new List<PeopleProfile__c>();
			itemProfile = [SELECT Picture__c FROM PeopleProfile__c WHERE User__c =:modById];
			if (itemProfile != null) {
				if (itemProfile.size() > 0) {
					PeopleProfile__c picture = new PeopleProfile__c();
					picture = itemProfile.get(0);
			        if(picture.Picture__c == '' || picture.Picture__c == null) {                	                                          	 
				     	PictureId = '';
					} 
					else {
						PictureId = picture.Picture__c;
					} 
				}
				else {
					PictureId = '';
				}
			}
   			this.modifiedByPicture = PictureId ;
   		}
   		public String getModifiedByPicture () {
   			return modifiedByPicture;
   		}
   		
   		public void setParentName (String parentName) {
   			this.parentName = parentName;
   		}
   		public String getParentName () {
   			return parentName;
   		}
   		public void setParentId (String parentId) {
   			this.parentId = parentId;
   		}
   		public String getParentId () {
   			return parentId;
   		}
   		public void setName (String Name) {
   			this.name = Name;
   		}
   		public String getName () {
   			return name;
   		}
   		public void setId (String Id) {
   			this.id = Id;
   		}
   		public String getId () {
   			return id;
   		}
   		public void setLastModifiedBy (String modById) {
   			User modBy = [select Name from User where id=:modById];
   			this.lastModifiedBy = modBy.Name;
   		}
   		public String getLastModifiedBy () {
   			return lastModifiedBy;
   		}
   		public void setLastModifiedById (String modById) {
   			this.lastModifiedById = modById;
   		}
   		public String getLastModifiedById () {
   			return lastModifiedById;
   		}   		
   		public void setLastModifiedDate (DateTime dateMod) {
   			this.lastModifiedDate = dateMod.format();
   		}
   		public String getLastModifiedDate () {
   			return LastModifiedDate;
   		}
   		public void setShortDescription (String shortDescription) {
   			this.shortDescription = shortDescription;
   		}
   		public String getShortDescription () {
   			return shortDescription;
   		}   		
   	}	
   	
   	public List<Wiki> getRecentlyUpdated () {
   		List<Wiki> wikis = new List<Wiki>();
   		for (WikiPage__c item: [ SELECT Team__r.Name, Id, Name, ShortDescription__c, LastModifiedById, LastModifiedDate FROM WikiPage__c WHERE Team__c =: TEAMID ORDER BY LastModifiedDate desc limit 10]) {
   			Wiki wiki = new Wiki();
   			wiki.setId(item.Id);
   			wiki.setName(item.Name);
   			wiki.setLastModifiedBy(item.LastModifiedById);
   			wiki.setLastModifiedById(item.LastModifiedById);
   			wiki.setModifiedByPicture(item.LastModifiedById);
   			wiki.setLastModifiedDate(item.LastModifiedDate);
   			wiki.setParentName(item.Team__r.Name);
   			wiki.setParentId(item.Team__r.Id);
   			wiki.setShortDescription(item.ShortDescription__c);
   			wikis.add(wiki);
   		}
   		return wikis;
   	}

   	/* ---------------------------- */
   	/*   	   MY FAVOURITES		*/
   	/* ---------------------------- */
   	
   	public List<FavoriteWikis__c> getFavorite () {
   		return	[ SELECT WikiPage__r.Team__r.Id, WikiPage__r.Team__r.Name, WikiPage__r.Name, WikiPage__r.Id FROM FavoriteWikis__c WHERE User__c = :UserInfo.getUserId() order by WikiPage__r.Name LIMIT 5];
   	}    	
   	
   	public Integer getCntFav () {
   		return [select count() from FavoriteWikis__c where User__c = :UserInfo.getUserId()];
   	} 
  	
    /* ---------------------------- */
   	/*   	  MY RECENT CHANGES		*/
   	/* ---------------------------- */
   	 	
   	public List<Wiki> getMyRecentChanges () {
   		List<Wiki> wikis = new List<Wiki>();
   		for (WikiPage__c item: [ SELECT Team__r.Id , Team__r.Name, Id, Name, ShortDescription__c, LastModifiedById, LastModifiedDate FROM WikiPage__c WHERE LastModifiedById =:UserInfo.getUserId() ORDER BY LastModifiedDate desc limit 5]) {
   			Wiki wiki = new Wiki();
   			wiki.setId(item.Id);
   			wiki.setName(item.Name);
   			wiki.setLastModifiedBy(item.LastModifiedById);
   			wiki.setLastModifiedDate(item.LastModifiedDate);
   			wiki.setParentName(item.Team__r.Name);
   			wiki.setParentId(item.Team__r.Id);
   			wiki.setShortDescription(item.ShortDescription__c);
   			wikis.add(wiki);
   		}
   		return wikis;
   	}
   	
   	public Integer getCntMyRecentChanges () {
   		return [ SELECT count() FROM WikiPage__c WHERE LastModifiedById =:UserInfo.getUserId()];
   	}
 
}