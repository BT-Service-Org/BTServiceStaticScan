/**
* @author Narendra Yarlagadda
* @date 11/07/2022
* @description  - ******************************************************
*          FINS OU - Initiative - team-fun-with-fins-engagement
*                 ******************************************************
*         This Mock Class respond fake response to the slack API for test coverage.
*/
global class FINSOU_SlackPublisherMock implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        if('callout:FINSOU_SLACK_BOT_NC?email=vijay.hari@salesforce.com'.equals(req.getEndpoint())){
            System.assertEquals('callout:FINSOU_SLACK_BOT_NC?email=vijay.hari@salesforce.com', req.getEndpoint());
            
            // Create a fake response
            res.setBody('{"ok":true,"user":{"id":"U03KZV4F5JS","team_id":"T01PY724468","name":"casey.wells","deleted":false,"color":"d1707d","real_name":"casey.wells","tz":"America/Los_Angeles","tz_label":"Pacific Daylight Time","tz_offset":-25200,"profile":{"title":"","phone":"","skype":"","real_name":"casey.wells","real_name_normalized":"casey.wells","display_name":"casey.wells","display_name_normalized":"casey.wells","fields":null,"status_text":"","status_emoji":"","status_emoji_display_info":[],"status_expiration":0,"avatar_hash":"g55a8549d93b","email":"casey.wells@salesforce.com","first_name":"casey.wells","last_name":"","image_24":"https://secure.gravatar.com/avatar/55a8549d93b3593e853085f4f3cfa2f2.jpg?s=24&d=https%3A%2F%2Fa.slack-edge.com%2Fdf10d%2Fimg%2Favatars%2Fava_0019-24.png","image_32":"https://secure.gravatar.com/avatar/55a8549d93b3593e853085f4f3cfa2f2.jpg?s=32&d=https%3A%2F%2Fa.slack-edge.com%2Fdf10d%2Fimg%2Favatars%2Fava_0019-32.png","image_48":"https://secure.gravatar.com/avatar/55a8549d93b3593e853085f4f3cfa2f2.jpg?s=48&d=https%3A%2F%2Fa.slack-edge.com%2Fdf10d%2Fimg%2Favatars%2Fava_0019-48.png","image_72":"https://secure.gravatar.com/avatar/55a8549d93b3593e853085f4f3cfa2f2.jpg?s=72&d=https%3A%2F%2Fa.slack-edge.com%2Fdf10d%2Fimg%2Favatars%2Fava_0019-72.png","image_192":"https://secure.gravatar.com/avatar/55a8549d93b3593e853085f4f3cfa2f2.jpg?s=192&d=https%3A%2F%2Fa.slack-edge.com%2Fdf10d%2Fimg%2Favatars%2Fava_0019-192.png","image_512":"https://secure.gravatar.com/avatar/55a8549d93b3593e853085f4f3cfa2f2.jpg?s=512&d=https%3A%2F%2Fa.slack-edge.com%2Fdf10d%2Fimg%2Favatars%2Fava_0019-512.png","status_text_canonical":"","team":"T01PY724468"},"is_admin":false,"is_owner":false,"is_primary_owner":false,"is_restricted":false,"is_ultra_restricted":false,"is_bot":false,"is_app_user":false,"updated":1663362693,"is_email_confirmed":true,"who_can_share_contact_card":"EVERYONE","enterprise_user":{"id":"U03KZV4F5JS","enterprise_id":"E013GKFQQTB","enterprise_name":"SFDC Sandbox","is_admin":false,"is_owner":false,"is_primary_owner":false,"teams":["T01PY724468"]}}}');
            res.setStatusCode(200);
        }
        
        return res;
    }
}