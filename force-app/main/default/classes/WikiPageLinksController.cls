public class WikiPageLinksController {
	
	/* ---------------------------- */
   	/*   	TEAM ID and WIKI ID		*/
   	/* ---------------------------- */	
    
    public String idWikiPage = System.currentPageReference().getParameters().get('idWP');
    
    public String teamId = '';
    
    public void genTeamId () {
   		teamId = [select id, team__c from WikiPage__c where id=: idWikiPage].team__c;
    }
    
    /* ---------------------------- */
   	/*   	  	CONSTRUCTOR			*/
   	/* ---------------------------- */	
	
	public WikiPageLinksController () {
		genTeamId();
	}
	
   	/* ---------------------------- */
   	/*   	  ATTACH WIKI PAGE		*/
   	/* ---------------------------- */	 	 
	public class AttachmentInfo {
        
        String name;
        String attachImage;
		String id;
        
        public String getId () {
        	return id;
        }
        
        public void setId (String id) {
        	this.id = id;
        }
        
        public String getName() {
                return name;
        }

        public void setName(String name) {
                this.name = name;
        }  
        
        public String getAttachImage() {
                return attachImage;
        }

        public void setAttachImage (String attachImage) {
                this.attachImage = attachImage;
        }          
                                        
	}
	
    public List<AttachmentInfo> getAttachments() {
    	List<Attachment> Attachments = new List<Attachment>();
    	if (idWikiPage == '{!idWikiPage}') {
    		Attachments = [select name, id, parentid, ContentType from attachment order by name];
    	}
    	else {
    		Attachments = [select name, id, parentid, ContentType from attachment where parentid=:idWikiPage order by name];
    	}
    	
		List<AttachmentInfo> infos = new List<AttachmentInfo>();

		for (Attachment item: Attachments){	
            AttachmentInfo info = new AttachmentInfo();
            info.setId(item.Id);
            info.setName(item.Name);
            infos.add(info);
        }	
		return infos;   	    									
    }     
    
    public Integer getCntAttachments () {
    	return [select count() from attachment where parentid=:idWikiPage];
    }
    
    /* ---------------------------- */
   	/*   	  WIKI PAGES TEAM		*/
   	/* ---------------------------- */	
   
   	public List<WikiPage__c> getWikiPagesTeam () {
   		List<WikiPage__c> wikis = new List<WikiPage__c>();
   		wikis = [select id, Name, team__r.Name from WikiPage__c where team__c =: teamId and Parent__c !=:idWikiPage  and id !=: idWikiPage order by Name];
   		return wikis;
   	}
   	 
   	public Integer getCntTeamWikis () {
   		return [SELECT count() FROM WikiPage__c WHERE team__c =: teamId and Parent__c !=:idWikiPage and id !=: idWikiPage]; 
   	}
   	
    /* ---------------------------- */
   	/*   	  WIKI PAGES ALL		*/
   	/* ---------------------------- */	
   	
   	public List<WikiPage__c> getWikiPagesAll () {
   		List<WikiPage__c> wikis = new List<WikiPage__c>();
   		wikis = [select id, Name, team__r.Name from WikiPage__c where team__c !=: teamId and team__c != null order by Name];
   		return wikis;
   	}
   	
   	public Integer getCntAllWikis () {
   		return [SELECT count() FROM WikiPage__c WHERE team__c !=: teamId and team__c != null]; 
   	}
   	 
    /* ---------------------------- */
   	/*   	  	WIKI CHILDS			*/
   	/* ---------------------------- */	  	 
	
	public List<WikiPage__c> getWikiChilds () {
   		List<WikiPage__c> childs = new List<WikiPage__c>();
	   	childs = [SELECT Id, Name, ShortDescription__c, Body__c, Parent__c FROM WikiPage__c WHERE Parent__c = :idWikiPage order by Name];
		return childs;
   	}  
   	
   	public Integer getCntWikiChilds () {
   		return [SELECT count() FROM WikiPage__c WHERE Parent__c = :idWikiPage]; 
   	}
}