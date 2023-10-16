public with sharing class MTH_SlackApiErrors {
    public abstract class SlackApiException extends Exception{}
    
    public class UserLookupByEmailException extends SlackApiException {}
    public class ChatPostException extends SlackApiException{}
    public class ChatUpdateException extends SlackApiException{}

    public virtual class ChannelCreateException extends SlackApiException{
        private String error;
        private String channelName;
        public ChannelCreateException(String error, String channelName){
            this.error = error;
            this.channelName = channelName;
        }

        public String getError(){
            return this.error;
        }

        public String getChannelName(){
            return this.channelName;
        }
    }
}