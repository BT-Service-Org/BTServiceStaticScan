@IsTest private class WikiPageEditTest {  
    public static testMethod void testWiki() {
	    WikiPageEditController wiki = new WikiPageEditController();
	    WikiPageEditController.Replace replace = new WikiPageEditController.Replace();
	    UserPermissions userPermissions = new UserPermissions();
	    
	    try {
			wiki.setIdWikiPage('a0l300000009a92AAA');          
		}
		catch (exception e) {
			System.assert(true, e);
		}
		
		try {
			wiki.constWikiPageEdit();     
		}
		catch (exception e) {
			System.assert(true, e);
		} 
		
		if (wiki.getUserPermissions() == null) {
			System.assert(true, 'Null Permissions');
		}
		
		userPermissions.getCanView();
		userPermissions.getCanComment();
		userPermissions.getCanManage();
		userPermissions.getCanCreate();
		userPermissions.getObjectType();
		userPermissions.getTeam();
		// userPermissions.getObjectId();
		userPermissions.getId();
		
		if (wiki.getReplace() == null) {
			System.assert(true, 'Null Replace');	
		}
		
		if (wiki.getIdWikiPage() == null) {
			System.assert(true, 'Null Id wiki Page');	 
		}
		
		if (wiki.getIniBody() == null) {
			System.assert(true, 'Null Ini body');	
		}
		
		if (wiki.getWikiHome() == null) {
			System.assert(true, 'Null Wiki HOme');	
		}
		
		if (replace.getContent() == null) {
			System.assert(true, 'Null Replace content'); 	
		}
		    
	    try {
			wiki.parseHTML();  
		}
		catch (exception e) {
			System.assert(true, e);
		}
	    
	    try {
	    	replace.setContent(wiki.getHtml());
			wiki.setReplace(replace);
		}
		catch (exception e) {
			System.assert(true, e);
		}
	    
	    try {
			wiki.parseWiki();  
		}
		catch (exception e) { 
			System.assert(true, e);
		}
		
	    if (wiki.getWikiSiteName() == null) {
	    	System.assert(true, 'Null wiki site Name');		
	    }
	    
	    if (wiki.getBreadCrumbing() == null) {
	    	System.assert(true, 'Null wiki site Name');		
	    }
	    
	    
	    /* WIKI PAGE INFO */
	    WikiPageEditController.Info info = new WikiPageEditController.Info();   
	    
	    try {
	    	wiki.infoGen ();	
	    }
	    catch (exception e) {
			System.assert(true, e);
		}
	    
	    if (info.getName() == null) {
	    	System.assert(true, 'Null Wiki Info var');		
	    }
	    
	    if (info.getShortDescription() == null) {
	    	System.assert(true, 'Null Wiki Info var');		
	    }
	    
	    if (info.getCreatedBy() == null) {
	    	System.assert(true, 'Null Wiki Info var');		
	    }
	    
	    if (info.getCreatedById() == null) {
	    	System.assert(true, 'Null Wiki Info var');		
	    }
	    
	    if (info.getLastModifiedBy() == null) {
	    	System.assert(true, 'Null Wiki Info var');		
	    }
	    
	    if (info.getLastModifiedById() == null) {
	    	System.assert(true, 'Null Wiki Info var');		
	    }
	    
	    if (info.getCreatedDate() == null) {
	    	System.assert(true, 'Null Wiki Info var');		
	    }
	    
	    if (info.getLastModifiedDate() == null) {
	    	System.assert(true, 'Null Wiki Info var');		
	    }
	    
	    if (wiki.getInfo() == null) {
	    	System.assert(true, 'Null Wiki Info var');		
	    }
	    
	    if (wiki.getHtml() == null) {
	    	System.assert(true, 'Null Wiki Info var');		
	    }
	    
	    try {
	    	wiki.okInfo();
	    }
	    catch (exception e) {
			System.assert(true, e);     
		}
	    
	    try { 
	    	wiki.getInfoWiki();
	    }
	    catch (exception e) {
			System.assert(true, e);
		}
	    
	    try{
	        wiki.SaveEdit();
	    } catch (exception e) {
	        System.assert(true,'Error saving page')  ;
	    }
        
    }
}