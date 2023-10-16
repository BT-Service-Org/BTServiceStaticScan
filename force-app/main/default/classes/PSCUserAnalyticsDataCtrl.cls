public with sharing class PSCUserAnalyticsDataCtrl {
    
    //Generic Wrapper Class    
    public class dataWrapper{
        @auraEnabled
        public String description{get;set;}
        @auraEnabled
        public integer count{get;set;}
    }
    
    //Method to return number of users
    @AuraEnabled(cacheable=true)
    public static List<dataWrapper> getUserAnalyticsData(){
        List<dataWrapper> userData = new List<dataWrapper>();
        
        String permsetsname = PSCSettingService.getValue('Analytics_Permission_Sets');
        List<String> permissionSetList = permsetsname.split(',');
        String analyticsEmails = PSCSettingService.getValue('Analytics_Emails');
        List<String> analyticsEmailsList = analyticsEmails.split(',');
        Map<String,Integer> datamap = new Map<String,Integer>();

        
        Integer totalUsers = [SELECT count() FROM PermissionSetAssignment 
                              WHERE Assignee.isActive = true and 
                              PermissionSet.Name =:permissionSetList[0]];
        
        datamap.put(PSCConstants.TOTAL_USERS,totalUsers!=0?totalUsers:0);        
        
        Integer totalUsersMethodology = [SELECT count() FROM PermissionSetAssignment 
                                         WHERE Assignee.isActive = true and 
                                         PermissionSet.Name =:permissionSetList[1]];
        
        
        datamap.put(PSCConstants.USERS_OPTED_FOR_METHODOLOGY,totalUsersMethodology!=0?totalUsersMethodology:0); 
     
        
        List<AggregateResult> voteList = [SELECT count(ID)voteCount,Type voteType from vote where parent.type='Knowledge__ka' 
                                          GROUP BY Type limit 50000];
        
        for(AggregateResult ar:voteList){
            if(ar.get('voteType') == '5'){
                datamap.put(PSCConstants.ARTICLES_UPVOTES,Integer.valueOf(ar.get('voteCount')));
            }
            if(ar.get('voteType') == '1'){
                
                datamap.put(PSCConstants.ARTICLES_DOWNVOTES,Integer.valueOf(ar.get('voteCount')));
            }
            
        }
        
        for(String i:datamap.keyset()){
            dataWrapper userDataWrappers = new dataWrapper();
            userDataWrappers.description = i;
            userDataWrappers.count = datamap.get(i);
            userdata.add(userDataWrappers);
        }
        return userdata;
    }
    
    //Method to return number of Knowledge Articles
    @AuraEnabled(cacheable=true)
    public static List<dataWrapper> getKnowledgeData(){
        List<dataWrapper> knowledgeData = new List<dataWrapper>();
        
        List<AggregateResult> knowledgeArticles = [Select count(Id)articleCount,publishstatus status from Knowledge__kav 
                                                   where publishstatus='Online' or publishstatus = 'Draft'
                                                   group by publishstatus];
        
        
        Map<Integer,String> knowledgeMap = new Map<Integer,String>();
        for(AggregateResult ar:knowledgeArticles){
            if(ar.get('status') == 'Draft'){
                knowledgemap.put(Integer.ValueOf(ar.get('articleCount')),PSCConstants.TOTAL_DRAFT_ARTICLES);
            }
            if(ar.get('status') == 'Online'){
                knowledgemap.put(Integer.ValueOf(ar.get('articleCount')),PSCConstants.TOTAL_PUBLISHED_ARTICLES);
            }
  
        }
        Datetime goLiveDate = Datetime.newInstance(2023, 2, 27);
        Integer publishedArticlesGoLive = [SELECT count() 
                                           FROM Knowledge__kav 
                                           WHERE publishstatus='Online' 
                                           AND FirstPublishedDate  >=: goLiveDate];
        
        knowledgemap.put(publishedArticlesGoLive!=0?publishedArticlesGoLive:0,PSCConstants.PUBISHED_ARTICLES_GO_LIVE);
        
        
        
        for(Integer i:knowledgeMap.keyset()){
            dataWrapper knowledgeDataIns = new dataWrapper();
            knowledgeDataIns.count = i;
            knowledgeDataIns.description = knowledgeMap.get(i);
            knowledgeData.add(knowledgeDataIns);
        }
        return knowledgeData;
    }
    
}