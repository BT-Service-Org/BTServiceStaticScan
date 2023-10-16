public class GDCMSUserSearch {

    @AuraEnabled(cacheable=true)
    public static List<User> searchUser(String searchKey){
        system.debug('searchKey :'+searchKey);
        List<User> lstUsers = new List<User>();
        String nameString = '%'+searchKey+'%';
       	if(string.isNotBlank(searchKey)){
            lstUsers = [Select id,Name,Title from User where Name like :nameString and isActive=true];
        }
        
        System.debug('lstUsers :'+lstUsers);
        return lstUsers;
    }
    
    @AuraEnabled
    public static Boolean assignPermissionSet(List<Id> userIdList){
        Set<id> userIdSet = new Set<Id>();
        userIdSet.addAll(userIdList);
        GDCMSAssignPermissionSet gaps = new GDCMSAssignPermissionSet(userIdSet);
        return gaps.assignpermissionSet();
    }
    
    public class userResult {
        @AuraEnabled
        public String userName;
        @AuraEnabled
        public string title;
        @AuraEnabled
        public Id userId;
        
        /*public userResult(String userName, Id userId) {
            this.userName = userName;
            this.userId = userId;
        }*/
    }
}