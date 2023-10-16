public class WikiPageHistoryController {
	
	public Info infoWP = new Info();
	public String idWikiSite;
	public String idWikiPage = System.currentPageReference().getParameters().get('id'); 
	
	public WikiPageHistoryController () {
		idWikiSite = [SELECT Team__r.Id From WikiPage__c WHERE id =:idWikiPage].Team__r.Id;
		infoGen();
	}
	
   	/* ---------------------------- */
   	/*   	  BREADCRUMBING			*/
   	/* ---------------------------- */ 

	public String getWikiHome () {
		return [select Id from WikiPage__c where Name = 'Home' and Team__c =:idWikiSite].Id;
	} 
	
	public String getWikiSiteName () {
		return [select Name from Team__c where id=:idWikiSite].Name;
	}
	  	
	public String getBreadCrumbing () {
	   	WikiPage__c wikiBC;
	   	String breadCrumbing = '';
	   	String parentBC = null;
		Integer crumbingLength = 1;
		Integer crumbingMaxLength = 2;
		
		if (idWikiPage == null) {
			idWikiPage = getWikiHome();
		}
   		wikiBC = [SELECT Id, Name, ShortDescription__c, Body__c, Parent__c, LastModifiedDate FROM WikiPage__c WHERE id = : idWikiPage ];
   		//breadCrumbing += wikiBC.Name;
   		parentBC = wikiBC.Parent__c;
	   	while (parentBC != null) {
	   		
	   		wikiBC = [select Name, Id, Parent__c from WikiPage__c where id =:parentBC];
	   		parentBC = wikiBC.Parent__c;
	   		if (crumbingLength < crumbingMaxLength) {
	   			breadCrumbing = '<a onclick=\"location.href=\'https://na1.salesforce.com/apex/WikiPage?idWP=' + wikiBC.Id + '\';" style="text-decoration:underline; cursor:pointer;" >' + wikiBC.Name + '</a> > ' + breadCrumbing;
	   		}
	   		else {
	   			if (parentBC == null) {
	   				breadCrumbing = '<a onclick=\"location.href=\'https://na1.salesforce.com/apex/WikiPage?idWP=' + wikiBC.Id + '\';"style="text-decoration:underline; cursor:pointer;" >' + wikiBC.Name + '</a> > ' + breadCrumbing;
	   			}
	   			else {
	   				if (crumbingLength == crumbingMaxLength) {
	   					breadCrumbing = ' .. > ' + breadCrumbing;
	   				}
	   			}
	   		}
	   		crumbingLength++;
	   	} 
	   	return breadCrumbing;
	}
	
   	/* ---------------------------- */
   	/*   	  INFO WIKI PAGE		*/
   	/* ---------------------------- */	
	public class Info {
        
        String name;
        String createdBy;
        String createdDate;
        String lastModifiedBy;
        String lastModifiedDate;
        String shortDescription;
        
        public String getName() {
                return name;
        }

        public void setName(String name) {
                this.name = name;
        }  
        
        public String getShortDescription() {
                return shortDescription;
        }

        public void setShortDescription (String shortDescription) {
                this.shortDescription = shortDescription;
        }
        
        public String getCreatedBy() {
                return createdBy;
        }

        public void setCreatedBy(Id id) {
                User user;
                user = [select Name from User where id = :id];
                this.createdBy = user.Name;
        }  
        
        public String getLastModifiedBy() {
                return lastModifiedBy;
        }

        public void setLastModifiedBy (Id id) {
                User user;
                user = [select Name from User where id = :id];
                this.lastModifiedBy = user.Name;
        } 

        public String getCreatedDate() {
                return createdDate;
        }

        public void setCreatedDate(Datetime createdDate) {
                this.createdDate = createdDate.format();
        } 
        
        public String getLastModifiedDate() {
                return lastModifiedDate;
        }

        public void setLastModifiedDate(Datetime lastModifiedDate) {
                this.lastModifiedDate = lastModifiedDate.format();
        }                
                                        
	} // end of the class	
  	
   	public void infoGen () {
   		
   		WikiPage__c wiki;
		String idInfo = idWikiPage;	
    	if (idInfo == '0' || idInfo == null) {
    		wiki = [SELECT Name, ShortDescription__c, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate  From WikiPage__c WHERE Name = 'Home' AND Team__c =: idWikiSite  ];	
    	}
    	else {
    		wiki = [SELECT Name, ShortDescription__c, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate From WikiPage__c WHERE id = : idInfo ];
    	}
	
		infoWP.setName(wiki.Name);
		infoWP.setCreatedBy(wiki.CreatedById);
		infoWP.setCreatedDate(wiki.CreatedDate);
		infoWP.setLastModifiedBy(wiki.LastModifiedById);
		infoWP.setLastModifiedDate(wiki.LastModifiedDate);
		infoWP.setShortDescription(wiki.ShortDescription__c);  

	}    		
   		
 	public Info getInfoWiki () {
 		return infoWP;
 	}	
 	
    /* ---------------------------- */
   	/*   	  SORT BY ...			*/
   	/* ---------------------------- */		
   	
   	public String sortBy = 'V_down';
   	
   	public String getSortBy () {
   		return sortBy;
   	} 

   	
   	public void sortBy () {
   		String sortByField = System.currentPageReference().getParameters().get('sb'); 
   		if (sortByField == 'LUB') {
   			if (sortBy == 'LUB_down') {
	   			sortBy = 'LUB_up';
	   		}
	   		else {
	   			sortBy = 'LUB_down';	
	   		}
   		}	
   		if (sortByField == 'U') {
   			if (sortBy == 'U_down') {
	   			sortBy = 'U_up';
	   		}
	   		else {
	   			sortBy = 'U_down';	
	   		}
   		}
   		if (sortByField == 'V') {
   			if (sortBy == 'V_down') {
	   			sortBy = 'V_up';
	   		}
	   		else {
	   			sortBy = 'V_down';	
	   		}
   		}
   	}
   		 			
}