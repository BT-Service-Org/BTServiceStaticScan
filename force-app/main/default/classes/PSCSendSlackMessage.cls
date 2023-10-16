global with sharing class PSCSendSlackMessage {
   @InvocableMethod(label='PSC Send Simple Message')
   global static void sendMessage(List<SlackMessage> slackMessages) {
    PSCSendSlackMessage.callSendMessage(JSON.serialize(slackMessages));

   }
   @future(callout=true)
   public static void callSendMessage(String strSlackMessages){
    List<SlackMessage> messageList = (List<SlackMessage>)JSON.deserialize(strSlackMessages, List<SlackMessage>.class);
    List<slack_FlowMessageSender.SlackMessage> lstslackmsg = new List<slack_FlowMessageSender.SlackMessage>();
    for(SlackMessage slackmsg: messageList){
        slack_FlowMessageSender.SlackMessage flowMsgSender= new slack_FlowMessageSender.SlackMessage();
        flowMsgSender.channel= slackmsg.channel;
        flowMsgSender.messageText= slackmsg.messageText;
        lstslackmsg.add(flowMsgSender);
    }
    slack_FlowMessageSender.sendMessage(lstslackmsg);
   }
      global class SlackMessage {
        @InvocableVariable(label='Channel (user id can also be specified)' required=true)
        global String channel;

        @InvocableVariable(label='Message to send' required=true)
        global String messageText;
      }
    }