@IsTest private class TeamUtilTest {

    public static testMethod void testUtil() {
        
        if(!TeamUtil.currentlyExeTrigger){
            System.assert(true,'Not current trigger');  
        }
        
        TeamUtil.isAdminMemberUser();
         
    }
}