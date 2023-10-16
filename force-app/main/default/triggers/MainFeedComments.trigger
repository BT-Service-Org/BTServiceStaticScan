trigger MainFeedComments on Comment__c bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {			
			
			/**
			* This happens after insert
			*/	
			List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
			List<String> idsWiki = new List<String>();
			List<String> idsBlog = new List<String>();
			
			for (Comment__c iterComment : Trigger.new) {
				if (iterComment.BlogEntry__c != null) {
					idsBlog.add(iterComment.BlogEntry__c);	
				}
				if (iterComment.ParentWikiPage__c != null) {
					idsWiki.add(iterComment.ParentWikiPage__c);	
				}	
			}
			
			List<WikiPage__c> wikiList = [select id, Name, team__c, team__r.Name from WikiPage__c where id in:idsWiki];
			List<BlogEntry__c> blogList = [select id, Name, team__c, team__r.Name from BlogEntry__c where id in:idsBlog];
			
		    for(Integer i = 0; i < Trigger.new.size(); i++) {
		        Comment__c n = Trigger.new[i];
		        // Blurb:
		        if(n.BlogEntry__c != null){
			        BlogEntry__c blog;
			        Boolean findBlog = false;
			        Integer countBlog = 0;
			        while (!findBlog && countBlog < blogList.size()) {
			        	if (blogList[countBlog].Id == n.BlogEntry__c) {
			        		findBlog = true;
			        		blog = blogList[countBlog];	
			        	}
			        	countBlog++;	
			        }
			        
			        minifeed.add( new MiniFeed__c( Type__c='BlogNewComment',
			                                           	User__c=n.CreatedById,
			                                           	FeedDate__c=System.now(),
		                                           		Team__c=blog.team__c,
			                                           	Message__c='commented on blog <a href="/apex/BlogDetails?id=' + n.BlogEntry__c + '">' + blog.Name + '</a> in <a href="/apex/TeamsRedirect?id=' + blog.team__c + '">' + blog.team__r.Name + '</a>' ));
			    }
		        if(n.ParentWikiPage__c != null){
		        	WikiPage__c wiki;
		        	Boolean findWiki = false;
		        	Integer countWiki = 0;
		        	while (!findWiki && countWiki < wikiList.size()) {
		        		if (wikiList[countWiki].Id == n.ParentWikiPage__c) {
		        			findWiki = true;	
		        			wiki = wikiList[countWiki];
		        		}		        			
		        		countWiki++;	
		        	}
					
			        minifeed.add( new MiniFeed__c( Type__c='WikiNewComment',
			        									FeedDate__c=System.now(),
		                                           		Team__c=wiki.team__c,
			                                           	User__c=n.CreatedById,
			                                           	Message__c='commented on wiki page <a href="/apex/WikiPage?idWP=' + n.ParentWikiPage__c + '">' + wiki.Name + '</a> in <a href="/apex/TeamsRedirect?id=' + wiki.Team__c + '">' + wiki.team__r.Name + '</a>' ));
		        }  	   
			}
			insert minifeed;
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}				
}