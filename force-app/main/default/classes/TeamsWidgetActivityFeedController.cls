public with sharing class TeamsWidgetActivityFeedController {
	
	
	public TeamsWidgetActivityFeedController(){
		getFeeds();
	}
	List<MiniFeeds> minifeeds = new List<MiniFeeds>(); 
	
	 public List<MiniFeeds> getMinifeeds(){
    	return minifeeds;
    }   
    
    /*
    *@void
    */
    public void getFeeds(){
    	List<MiniFeed__c> mf = new List<MiniFeed__c>();    	
    	mf = [Select 
    				m.User__c,
    				m.User__r.Name, 
    				m.Type__c, 
    				m.Message__c, 
    				m.Id, 
    				m.CreatedDate 
    				from MiniFeed__c m
    				order by m.FeedDate__c desc
    				limit 7];    		
    	
    	
    	minifeeds.clear();
    	for(MiniFeed__c m : mf){
    		MiniFeeds minif = new MiniFeeds(m);
    		minifeeds.add(minif);
    	}
    }
    
    /*
    *@class
    */
    public class MiniFeeds {
    	
    	MiniFeed__c feed = null;
    	String formatedDate = null;
    	
    	/**
    	*@param MiniFeed__c
    	*/
    	public MiniFeeds(MiniFeed__c m){
    		feed = m;
    	}
    	
    	public MiniFeed__c getFeed(){
    		return feed;
    	}
    	
    	public String getFormatedDate(){
    		return feed.CreatedDate.format('MMMM dd, yyyy HH:mm');
    	}		
    }
	
}