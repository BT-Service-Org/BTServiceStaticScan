public class WikiVersionsController {
	
	public String idRevL;
	public String idRevR;
	public String idWikiPage = System.currentPageReference().getParameters().get('idWP');
	public Boolean goLeft = false;
	public Boolean goRight = false;
	
	public void setIdWikiPage(String id){
		idWikiPage = id;	
	}
	
	public void setIdRevL (String s){
		idRevL = s;
	}
	
	public void setIdRevR (String s){
		idRevR = s;
	}
	
   	/* ---------------------------- */
   	/*   	 SHOW REVISIONS 		*/
   	/* ---------------------------- */		
	public class InfoRev {
        Double revisionCount;
        String name;
        String lastModifiedDate;
		String id;
		String body;
		String modifiedBy;
		
		public String getModifiedBy () {
		 	return modifiedBy;
		}
		
		public void setModifiedBy(String modBy) {
			this.modifiedBy = modBy;
		}
		
		public String getBody () {
			String convertBody;
			convertBody = body.replaceAll('\n',' <br> ');
			convertBody = convertBody.replace('\"','&quot');
			return convertBody;
		}
		
		public void setBody (String body) {
			this.body = body;
		}
        
        public Double getRevisionCount () {
        	return revisionCount;
        }
        
        public void setRevisionCount (Double revisionCount) {
        	this.revisionCount = revisionCount;
        }
        
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
                
        public String getLastModifiedDate() {
                return lastModifiedDate;
        }

        public void setLastModifiedDate(Datetime lastModifiedDate) {
                this.lastModifiedDate = lastModifiedDate.format();
        }                
                                        
	}

	public WikiPage__c getWikiInfo () {
		return [select Name, Team__r.Name from WikiPage__c where id =: idWikiPage];
	}

	public List<InfoRev> getRevisionsList () {
		List<WikiVersions__c> revisionList;
		revisionList = [select Id, Name, LastModifiedDate,revisionCount__c, LastModifiedBy.Name from WikiVersions__c where WikiPageId__c =: idWikiPage order by LastModifiedDate desc];	
		List<InfoRev> infosRev = new List<InfoRev>();
		for (WikiVersions__c item: revisionList){
                    InfoRev infoRev = new InfoRev();
                    infoRev.setId(item.Id);
                    infoRev.setName(item.Name);
                    infoRev.setLastModifiedDate(item.LastModifiedDate);
                    infoRev.setModifiedBy(item.LastModifiedBy.Name);
                    if (item.revisionCount__c == null) {
                    	infoRev.setRevisionCount(1);
                    }
                    else {
                    	infoRev.setRevisionCount(item.revisionCount__c);
                    }
                    infosRev.add(infoRev);
        }
        return infosRev;
	}
	
	public PageReference cancelRevision () {
		PageReference pageRef = new PageReference('https://na1.salesforce.com/apex/WikiHome?idWP=' + idWikiPage);
		pageRef.setRedirect(true);
		return pageRef;
	}		
	
	public Boolean getGoDiff () {
		return (goLeft && goRight);
	}	
	/* ---------- LEFT ----------- */
	
	public Boolean getGoLeft () {
		return goLeft;
	}
	 
	public void getWikiLeft () {
		goLeft = true;
	} 
	 
	public InfoRev getRevLeftBody () {
		InfoRev revLeftBody = new InfoRev();
		if (System.currentPageReference().getParameters().get('idRevL') != null && System.currentPageReference().getParameters().get('idRevL') != '') {
			idRevL =	System.currentPageReference().getParameters().get('idRevL');
			WikiVersions__c wikiVersionLeft = [select Name, Body__c, revisionCount__c from WikiVersions__c where Id =: idRevL];
			revLeftBody.setBody(wikiVersionLeft.Body__c);
			revLeftBody.setRevisionCount(wikiVersionLeft.revisionCount__c);
		}
		else {
			if (idRevL != null && idRevL != '') {
				WikiVersions__c wikiVersionLeft = [select Name, Body__c, revisionCount__c from WikiVersions__c where Id =: idRevL];
				revLeftBody.setBody(wikiVersionLeft.Body__c);
				revLeftBody.setRevisionCount(wikiVersionLeft.revisionCount__c);
			}
			else {
				revLeftBody.setBody('');
			}	
		}
		return revLeftBody;
	}	 
	
	public void hideLeftBody () {
		goLeft = false;
	}
	
	/* ---------- RIGHT ----------- */

	public Boolean getGoRight () {
		return goRight;
	}
	 
	public void getWikiRight () {
		goRight = true;
	} 
	 
	public InfoRev getRevRightBody () {
		InfoRev revRightBody = new InfoRev();
		if (System.currentPageReference().getParameters().get('idRevR') != null && System.currentPageReference().getParameters().get('idRevR') != '') {
			idRevR =	System.currentPageReference().getParameters().get('idRevR');
			WikiVersions__c wikiVersionRight = [select Name, Body__c, revisionCount__c from WikiVersions__c where Id =: idRevR];
			revRightBody.setBody(wikiVersionRight.Body__c);
			revRightBody.setRevisionCount(wikiVersionRight.revisionCount__c);
		}
		else {
			if (idRevR != null && idRevR != '') {
				WikiVersions__c wikiVersionRight = [select Name, Body__c, revisionCount__c from WikiVersions__c where Id =: idRevR];
				revRightBody.setBody(wikiVersionRight.Body__c);
				revRightBody.setRevisionCount(wikiVersionRight.revisionCount__c);
			}
			else {
				revRightBody.setBody('');
			}
		}
		return revRightBody;
	}
	
	public void hideRightBody () {
		goRight = false;
	}

   	/* ---------------------------- */
   	/*   	 SAVE AS CURRENT 		*/
   	/* ---------------------------- */	
   	
   	/* ---------- LEFT ----------- */
   	
   	public PageReference saveLeft () {
		WikiPage__c updateWiki = [select Body__c from WikiPage__c where id =:idWikiPage];
		WikiVersions__c currentRev = [select Name, revisionCount__c, Body__c from WikiVersions__c where Id =: idRevL];
		updateWiki.Body__c = currentRev.Body__c;
		update updateWiki;
				
		WikiVersions__c updateRev = new WikiVersions__c();
		updateRev.Name = currentRev.Name;
		updateRev.Body__c = currentRev.Body__c;
		updateRev.WikiPageId__c = idWikiPage;
		Integer resultCount = [select count() from WikiVersions__c where WikiPageId__c =:idWikiPage];
		if (resultCount != 0) {
			Double oldCount = [select revisionCount__c from WikiVersions__c where WikiPageId__c =:idWikiPage order by LastModifiedDate desc limit 1].revisionCount__c;
			if (oldCount == null) {
				updateRev.revisionCount__c = 1;
			}
			else {
				updateRev.revisionCount__c = oldCount + 1;
			}
		}
		else {
			updateRev.revisionCount__c = 1;
		}		
		
		insert updateRev;

		PageReference pageRef = new PageReference('https://na1.salesforce.com/apex/WikiHome?idWP=' + idWikiPage);
		pageRef.setRedirect(true);
		return pageRef;   		
   	}	
   	
   	/* ---------- RIGHT ----------- */
   	public PageReference saveRight () {
		WikiPage__c updateWiki = [select Body__c from WikiPage__c where id =:idWikiPage];
		WikiVersions__c currentRev = [select Name, revisionCount__c, Body__c from WikiVersions__c where Id =: idRevR];
		updateWiki.Body__c = currentRev.Body__c;
		update updateWiki;
				
		WikiVersions__c updateRev = new WikiVersions__c();
		updateRev.Name = currentRev.Name;
		updateRev.Body__c = currentRev.Body__c;
		updateRev.WikiPageId__c = idWikiPage;
		Integer resultCount = [select count() from WikiVersions__c where WikiPageId__c =:idWikiPage];
		if (resultCount != 0) {
			Double oldCount = [select revisionCount__c from WikiVersions__c where WikiPageId__c =:idWikiPage order by LastModifiedDate desc limit 1].revisionCount__c;
			if (oldCount == null) {
				updateRev.revisionCount__c = 1;
			}
			else {
				updateRev.revisionCount__c = oldCount + 1;
			}
		}
		else {
			updateRev.revisionCount__c = 1;
		}		
		
		insert updateRev;
		
		PageReference pageRef = new PageReference('https://na1.salesforce.com/apex/WikiHome?idWP=' + idWikiPage);
		pageRef.setRedirect(true);
		return pageRef;   		
   	}	
   	   	   		
}