public with sharing class MTH_GenericMsgHandler implements Queueable, Database.AllowsCallouts{

    @testVisible
    public List<MTH_MessagePayload> payloads;

    @testVisible
    private static UserDAI userDA = new UserDataAccessor();

    public MTH_GenericMsgHandler(List<MTH_MessagePayload> payloads) {
        this.payloads = payloads;
    }

    public void execute(QueueableContext context) {

        Set<String> emailIds = new Set<String>();
        
        for(MTH_MessagePayload payload : payloads){
            if(String.isNotBlank(payload.notify)){
                emailIds.add(payload.notify);
            }
        }

        Map<String, User> usersByEmailId = new Map<String, User>();
        List<User> users = userDA.getSlackUserInfoFromEmailIds(emailIds);

        for(User usr : users){
            usersByEmailId.put(usr.email, usr);
        }
        
        for(MTH_MessagePayload payload : payloads){
            String detailsStr = null;
            Map<String, String> viewMap = new Map<String, String> ();
            if(String.isNotBlank(payload.header)){
                viewMap.put('header', payload.header);
            }
            if(String.isNotBlank(payload.messageBody)){
                viewMap.put('body', payload.messageBody);
            }
            
            if(payload.details != null && !payload.details.isEmpty()){
                detailsStr=JSON.serializePretty(payload.details, true); 
                viewMap.put('details', '```'+detailsStr+'```');
            }
            if(String.isNotBlank(payload.footer)){
                viewMap.put('footer', payload.footer);
            }

            // add action button to retry on smartsheet creation error
            // TODO: temporarily commented out until final solution is in place
            // if (isSmartsheetsCreationError(payload) == true) {
            //     // viewMap.put('includeActionButton', 'true');
            //     // viewMap.put('actionLabel', 'Retry Smartsheets Creation');
            //     // temporarily commented out
            //     // viewMap.put('actionValue', 'retry-smartsheets-creation-' + Id.valueOf(getProjectIdForSmartsheet(payload)));
            //     viewMap.put('actionValue', 'retry-smartsheets-creation-0');
            // }

            User usr = usersByEmailId.get(payload.notify);
            if(usr !=null){
                sendMessage(usr, viewMap);
            }else{
                throw new UserNotFoundException('Either user with given email id is not available or slack user id is not populated for the user.');
            }
        }
    }
    
    private Boolean isSmartsheetsCreationError(MTH_MessagePayload payload) {
        // TODO: determine if smartsheet creation error from message payload
        String msgBody = payload?.messageBody?.toLowerCase();
        if(String.isNotBlank(msgBody)){
            return msgBody.contains('smartsheet') && msgBody.contains('error');
        }
       return null;
    }


    private Id getProjectIdForSmartsheet(MTH_MessagePayload payload) {
        // TODO: get project id from message payload
        List<PSA_Project__c> projList = new List<PSA_Project__c>([
            SELECT Id, Project_Setup_Status__c, SmartSheet_Link__c, Smartsheet_Creation_Error__c
            from PSA_Project__c
        ]);
        return projList.get(0).Id;
    }

    private void sendMessage(
        User user, 
        Map<String, String> viewMap
    ) {
        Slack.ViewReference view = Slack.view.mth_generic_msg.get();
        Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
        view.setParameter('methodologiesChannelId', settings.General_Information_Slack_Channel_Id__c);
        view.setParameter('header', viewMap.get('header'));
        view.setParameter('body', viewMap.get('body'));
        view.setParameter('details', viewMap.get('details'));
        view.setParameter('footer', viewMap.get('footer'));
        
        if (viewMap.containsKey('includeActionButton')) {
            view.setParameter('includeActionButton', true);
            view.setParameter('actionLabel', viewMap.get('actionLabel'));
            view.setParameter('actionValue', viewMap.get('actionValue'));
        } else {
            view.setParameter('includeActionButton', false);
        }

        MTH_SlackMessageSender.sendMessageToUser(
            user,
            view
        );
    }

    public class UserNotFoundException extends Exception {
    }

}