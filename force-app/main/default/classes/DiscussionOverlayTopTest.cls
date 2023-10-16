@IsTest private class DiscussionOverlayTopTest {
    
    
    public static String TEAMID =null;
    
    public static testMethod void testDiscussion() {
            
        DiscussionForum__c team = new DiscussionForum__c();
        
        if(TEAMID != null){
             try {
                team = [SELECT
                        Team__r.Name, 
                        Team__c,
                        Id 
                        FROM DiscussionForum__c WHERE Team__c =: TEAMID LIMIT 1];
                        
             } catch (Exception e) {
                
                System.Debug('\n ///////////////////////////// \n Error , no team assigned \n //////////////////////////// \n The Forum ID is :' + TEAMID + '\n //////////////////////////// \n');
                
             }
                             
        } else {
            System.assert(TEAMID==null,'No existe Team ID');
            team = null;
        }
    }
}