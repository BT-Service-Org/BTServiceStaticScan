/**
* @author: Rohan Saxena
* @description: This class will be used to insert Featured Comment from mulesoft 
*/
@RestResource(urlMapping='/cop-featured-comment/*')
global with sharing class PSCCOPFeaturedCommentAPI extends ParentAPIRequest{
    public string Channel_Id {get;set;}
    public string Thread_TS {get;set;}
    public string Slack_Comment {get;set;}
    public string Commenter_fed_id {get;set;}
    public string Community_Id {get;set;}
    public string Commener_Id {get;set;}
    @HttpPost
    global static String  insertFeatureComments(String Channel_Id, String Thread_TS, String Slack_Comment, String Commenter_fed_id){
        PSCCOPFeaturedCommentAPI PSCThis = new PSCCOPFeaturedCommentAPI();
        List<User> lstUser = new List<User>();
        PSCResponse apiRes =new PSCResponse();
        PSCThis.Channel_Id= Channel_Id;
        PSCThis.Thread_TS= Thread_TS;
        PSCThis.Slack_Comment= Slack_Comment.UnescapeHTML4();
        PSCThis.Commenter_fed_id= Commenter_fed_id;
        PSCThis.validate();
        List<PSC_Page__c> lstPage= [SELECT Id FROM PSC_Page__c WHERE Channel_Id__c =: PSCThis.Channel_Id WITH USER_MODE LIMIT 1];
        if(String.isNotBlank(PSCThis.Commenter_fed_id)){
            lstUser = [SELECT Id FROM User WHERE FederationIdentifier=: PSCThis.Commenter_fed_id WITH USER_MODE LIMIT 1];
        }
        else{
            lstUser = [SELECT Id FROM User WHERE Name=:PSCSettingService.getValue('COP_Community_Bot_User_Name') WITH USER_MODE LIMIT 1];
        }
        List<Featured_Comments__c> lstExistingFeatureComment = [SELECT Id FROM Featured_Comments__c WHERE Thread_TS__c=: PSCThis.Thread_TS WITH USER_MODE];
        if(!lstPage.isEmpty()){
        PSCThis.Community_Id = lstPage[0].Id;
        }
        else{
            apiRes.status=201;
            apiRes.response='Error! Unable to find Community_Id using Channel_Id';
            return JSON.serialize(apiRes);
        }
        if(!lstUser.isEmpty()){
            PSCThis.Commener_Id=lstUser[0].Id;
        }
        else{
            apiRes.status=201;
            apiRes.response='Error! Unable to find Commener_Id using Commenter_fed_id';
            return JSON.serialize(apiRes);
        }
        if(!lstExistingFeatureComment.isEmpty()){
            apiRes.status=200;
            apiRes.response='Error! Duplicate Featured Slack Comments Found';
            return JSON.serialize(apiRes);
        }
        try{
            insert as user (PSCThis.getFeaturedCommentInstance());
            apiRes.status=200;
            apiRes.response='Success! Featured Comment inserted';
            return JSON.serialize(apiRes);
            
        }
        catch(Exception ex){
            throw new PSCException(ex.getMessage());
        }
    } 
    public Featured_Comments__c getFeaturedCommentInstance(){
        Featured_Comments__c objFeaturedComment =  new Featured_Comments__c();
        objFeaturedComment.Community__c = this.Community_Id;
        objFeaturedComment.Channel_Id__c=this.Channel_Id;
        objFeaturedComment.Thread_TS__c=this.Thread_TS;
        objFeaturedComment.Commenter__c=this.Commener_Id;
        objFeaturedComment.Slack_Comment__c=this.Slack_Comment;
        return objFeaturedComment;
    }
    public override boolean validate(){
        if(this.Channel_Id == null || String.isBlank(this.Channel_Id)){
            throw new PSCException('Please provide valid Channel_Id');
        }
        if(this.Thread_TS == null || String.isBlank(this.Thread_TS)){
            throw new PSCException('Please provide valid Thread_TS');
        }
        if(this.Slack_Comment == null || String.isBlank(this.Slack_Comment)){
            throw new PSCException('Please provide valid Slack_Comment');
        }
        return true;
    }
}