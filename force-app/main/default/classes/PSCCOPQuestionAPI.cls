/**
* @author: Rohan Saxena
* @description: This class will be used to update question from mulesoft
*/
@RestResource(urlMapping='/cop-question/*')
global with sharing class PSCCOPQuestionAPI extends ParentAPIRequest{
    public string question_slackid {get;set;}
    public string question_id {get;set;}
    public string closed_by_fedid {get;set;}
    public string closed_by_id {get;set;}
    public string status {get;set;}
    @HttpPut
    global static String  updateQuestion(String question_slackid, String closed_by_fedid) {
        PSCCOPQuestionAPI PSCThis = new PSCCOPQuestionAPI();
        PSCResponse apiRes = new PSCResponse();
        PSCThis.question_slackid = question_slackid!=null ?  question_slackid : '';
        PSCThis.closed_by_fedid = closed_by_fedid!=null ?  closed_by_fedid : '';
        PSCThis.status = 'Closed';
        PSCThis.validate();
        List<Question__c> lstQuestion = [SELECT Id FROM Question__c WHERE Thread_Id__c=:PSCThis.question_slackid WITH USER_MODE LIMIT 1];
        List<User> lstUser = [SELECT Id FROM User WHERE FederationIdentifier=: PSCThis.closed_by_fedid WITH USER_MODE LIMIT 1];
        if(!lstQuestion.isEmpty()){
            PSCThis.question_id=lstQuestion[0].Id;
        }
        else{
            apiRes.status=201;
            apiRes.response='Error! Unable to find question using question_slackid';
            return JSON.serialize(apiRes);
        }
        if(!lstUser.isEmpty()){
            PSCThis.closed_by_id=lstUser[0].Id;
        }
        else{
            apiRes.status=201;
            apiRes.response='Error! Unable to find User using closed_by_fedid';
            return JSON.serialize(apiRes);
        }
        try{
            update as user (PSCThis.getQuestiontInstance());
            apiRes.status=200;
            apiRes.response='Success! Question Updated';
            return JSON.serialize(apiRes);
            
        }
        catch(Exception ex){
            throw new PSCException(ex.getMessage());
        }
    }

    public Question__c getQuestiontInstance(){
        Question__c objQuestion =  new Question__c();
        objQuestion.Id = this.question_id;
        objQuestion.Closed_By__c= this.closed_by_id;
        objQuestion.Status__c= this.status;
        return objQuestion;
    }

    public override boolean validate(){
        if(this.question_slackid == null || String.isBlank(this.question_slackid)){
            throw new PSCException('Please provide valid question_slackid');
        }
        if(this.closed_by_fedid == null || String.isBlank(this.closed_by_fedid)){
            throw new PSCException('Please provide valid closed_by_fedid');
        }
        return true;
    }
}