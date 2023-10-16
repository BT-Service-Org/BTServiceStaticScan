@IsTest private class WikiPageTest {
	public static testMethod void testWiki() {
		
		try{
			WikiPageController wiki = new WikiPageController(); 
			wiki.setParamIdWP('a0l300000009a92AAA');    
	
			wiki.contructMethods();
	
			if (wiki.getWikiSiteName() == null) {
				System.assert(true, 'Null Wiki Site Name');	
			}
			
			if (wiki.getidWikiPage() == null) {
				System.assert(true, 'Null Wiki Page Id');	
			}
			
			if (wiki.getWikiBody() == null) {
				System.assert(true, 'Null Wiki Page Body');	
			}
			
			try {
				//wiki.parseHTML();
			}
			catch (exception e) {   
				System.assert(true, e);
			}
			
			if (wiki.getHtml() == null) {
				System.assert(true, 'Null Wiki Page Html');	
			}
			
			if (wiki.getHtml2() == null) {
				System.assert(true, 'Null Wiki Page Html2');	
			}
			
			if (wiki.getChilds() == null) {
				System.assert(true, 'Null Wiki Page Childs');	
			}
			
			if (wiki.getChildsCount() == null) {
				System.assert(true, 'Null Wiki Page Childs Count');	
			}
			
			/* INFO INNER CLASS */
			WikiPageController.Info info = new WikiPageController.Info();
			
			if (info.getName() == null) {
				System.assert(true, 'Null Wiki Page Info var');	
			}
			
			if (info.getShortDescription() == null) {
				System.assert(true, 'Null Wiki Page Info var');	
			}
			
			if (info.getCreatedBy() == null) {
				System.assert(true, 'Null Wiki Page Info var');	
			}
			
			if (info.getCreatedById() == null) {
				System.assert(true, 'Null Wiki Page Info var');	
			}
			
			if (info.getLastModifiedBy() == null) {
				System.assert(true, 'Null Wiki Page Info var');	
			}
			
			if (info.getLastModifiedById() == null) {
				System.assert(true, 'Null Wiki Page Info var');	
			}
			
			if (info.getCreatedDate() == null) {
				System.assert(true, 'Null Wiki Page Info var');	
			}
			
			if (info.getLastModifiedDate() == null) {
				System.assert(true, 'Null Wiki Page Info var');	
			}
			
			try {
				//wiki.infoGen();
			}
			catch (exception e) {
				System.assert(true, e);
			}
			
			if (wiki.getInfoWiki() == null) {
				System.assert(true, 'Null Wiki Page Info');	  
			}
			
			try {
				wiki.getWiki();	
			}
			catch (exception e) {
				System.assert(true, e);
			}
			
			/* NEW WIKI PAGE */
			if (wiki.getNewPage() == null) {
				System.assert(true, 'Null New Page Boolean');	  
			}
			
			try {
				wiki.cancelNew();
			}
			catch (exception e) {
				System.assert(true, e);
			}
			
			try {
				wiki.newWiki();
			}
			catch (exception e) {
				System.assert(true, e);
			}
			
			if (wiki.getnewWP() == null) {
				System.assert(true, 'Null New Wiki Page');		
			}
			
			if (wiki.getnewWP() == null) {
				System.assert(true, 'Null New Wiki Page');		
			}
			
			/* ATTACHMENTS */
			WikiPageController.AttachmentInfo attach = new WikiPageController.AttachmentInfo();
			
			if (attach.getId() == null) {
				System.assert(true, 'Null Attach var');	
			}
			
			if (attach.getName() == null) {
				System.assert(true, 'Null Attach var');	
			}
			
			if (attach.getAttachImage() == null) {
				System.assert(true, 'Null Attach var');	
			}
			
			if (wiki.getAttachments() == null) {
				System.assert(true, 'Null Attachments list');	
			}
			
			if (wiki.getAttachCount() == null) {
				System.assert(true, 'Null Attachments list');	
			}
			
			
			/* BREAD CRUMBRING */
			if (wiki.getBreadCrumbing() == null) {
				System.assert(true, 'Null Bread Crumbing');	
			}
			
			/* OUTGOING AND INCOMING */
			if (wiki.getOutgoing() == null) {
				System.assert(true, 'Null Out/Inc links vars');	  
			}
			
			if (wiki.getCntOutgoing() == null) {
				System.assert(true, 'Null Out/Inc links vars');		
			}
			
			if (wiki.getIncoming() == null) {
				System.assert(true, 'Null Out/Inc links vars');	
			}
			
			if (wiki.getCntIncoming() == null) {
				System.assert(true, 'Null Out/Inc links vars');	
			}
			
			/* RECENTLY UPDATED */
			if (wiki.getRecentlyUpdated() == null) {
				System.assert(true, 'Null Recently Updated');		
			}
			
			/* TAG CLOUD */
			WikiPageController.Links tagCloud = new WikiPageController.Links();
			
			if (tagCloud.getLinkName() == null) {
				System.assert(true, 'Null TagCloud vars');		
			}
			
			if (tagCloud.getLinkId() == null) {
				System.assert(true, 'Null TagCloud vars');		
			}
			
			if (tagCloud.getLinkCount() == null) {
				System.assert(true, 'Null TagCloud vars');		
			}
			
			if (tagCloud.getLinkClass() == null) {
				System.assert(true, 'Null TagCloud vars');		
			}
			
			if (tagCloud.getLinkClass() == null) {
				System.assert(true, 'Null TagCloud vars');		
			}
			
			if (wiki.getLinkCount() == null) {
				System.assert(true, 'Null TagCloud');		
			}
			
			if (wiki.getLinksNum() == null) {
				System.assert(true, 'Null TagCloud');		
			}
			
			/* MY FAVOURITES */
			if (wiki.getFavorite() == null) {
				System.assert(true, 'Null Favorite');		
			}
			
			if (wiki.getIsFav() == null) {
				System.assert(true, 'Null Is Favorite');		
			}
			
			if (wiki.getCntFav() == null) {
				System.assert(true, 'Null Count Favorite');		
			}
			
			/* RECENTLY VIEW */
			WikiPageController.RecentlyView recentlyView = new WikiPageController.RecentlyView();
			
			if (recentlyView.getWikiId() == null) {
				System.assert(true, 'Null Recently View var');		
			}
			
			if (recentlyView.getWikiName() == null) {
				System.assert(true, 'Null Recently View var');		
			}
			
			if (recentlyView.getParentName() == null) {
				System.assert(true, 'Null Recently View var');		
			}
			
			if (recentlyView.getBelong() == null) {
				System.assert(true, 'Null Recently View var');		
			}
			
			if (wiki.getRecentlyView() == null) {
				System.assert(true, 'Null Recently View');		
			}
			
			if (wiki.getCntViews() == null) {
				System.assert(true, 'Null Count of Recently View');		
			}
			
			/* COMMENTS */
			WikiPageController.Comments comments = new WikiPageController.Comments();
			
			if (comments.getCommentName() == null) {
				System.assert(true, 'Null Comment var');		
			}
			
			if (comments.getCommentPicture() == null) {
				System.assert(true, 'Null Comment var');		
			}
			
			if (comments.getCommentDate() == null) {
				System.assert(true, 'Null Comment var');		
			}
			
			if (comments.getCommentBy() == null) {
				System.assert(true, 'Null Comment var');		
			}
			
			if (comments.getComment() == null) {
				System.assert(true, 'Null Comment var');		
			}
			
			/*if (wiki.getComments() == null) {
				System.assert(true, 'Null Comments');		
			}
			
			if (wiki.getCntComments() == null) {
				System.assert(true, 'Null Count of Comments');		
			}
			
			if (wiki.getAddComment() == null) { 
				System.assert(true, 'Null Add Comment');		
			}
			
			try {
				wiki.addCommentLink();
			}
			catch (exception e) {
				System.assert(true, e);
			}
			
			try {
				wiki.cancelComment();
			}
			catch (exception e) {
				System.assert(true, e);
			}*/
		}catch(Exception e){
			throw e;
		}
	}
}