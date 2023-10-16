public class FINSOU_SlackAPI_UserInfo {
    public final FINSOU_Slack_User User{get;set;}
    
    /**
    * @author Narendra Yarlagadda
    * @date 11/07/2022
    * @description  
    *          This Wrapper class is to provide slack 
    *          user id and real name from the API response.
    */
    public class FINSOU_Slack_User{
        public final String real_name{get;set;}
        public final String id{get;set;}        
    }
}