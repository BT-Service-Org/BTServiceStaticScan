/**
* @author: Rohan Saxena
* @description: This class will be used to insert best answer from mulesoft 
*/
@RestResource(urlMapping='/cop-answer/*')
global class PSCCOPAnswersAPI extends ParentAPIRequest{
    
    public string res_by_fedid {get;set;}
    public Boolean best_Answer {get;set;}
    public string question_slackid {get;set;}
    public string ans_body {get;set;}
    public string type {get;set;}
    public string response_by {get;set;}
    
    @HttpPost
    global static String  insertAnswer(string res_by_fedid, Boolean best_Answer, String question_slackid, String ans_body) {
        PSCCOPAnswersAPI PSCThis = new PSCCOPAnswersAPI();
        PSCResponse apiRes = new PSCResponse();
        PSCThis.res_by_fedid= res_by_fedid!=null ?  res_by_fedid : '';
        PSCThis.best_Answer = best_Answer ? best_Answer : false;
        PSCThis.ans_body= ans_body!=null ? ans_body : '';
        PSCThis.question_slackid = question_slackid!=null ?  question_slackid : '';
        PSCThis.validate();
        List<User> lstUser = [SELECT Id FROM User WHERE FederationIdentifier=: PSCThis.res_by_fedid WITH USER_MODE LIMIT 1];
        List<Question__c> lstQuestion = [SELECT Id FROM Question__c WHERE Thread_Id__c=:PSCThis.question_slackid WITH USER_MODE LIMIT 1];
        if(!lstQuestion.isEmpty()){
            PSCThis.question_slackid=lstQuestion[0].Id;
        }
        else{
            apiRes.status=201;
            apiRes.response='Error! Unable to find question using slackid';
            return JSON.serialize(apiRes);
        }
        if(!lstUser.isEmpty()){
            PSCThis.response_by=lstUser[0].Id;
        }
        else{
            apiRes.status=201;
            apiRes.response='Error! Unable to find response by user';
            return JSON.serialize(apiRes);
        }
        PSCThis.type= 'Answer';
        try{
            insert(PSCThis.getAnswer());
            apiRes.status=200;
            apiRes.response='Success! Answer inserted';
            return JSON.serialize(apiRes);
            
        }
        catch(Exception ex){
            throw new PSCException(ex.getMessage());
        }
        
    }
    
    public Answer__c getAnswer(){
        Answer__c objAnswer =  new Answer__c();
        objAnswer.Best_Answer__c = this.best_Answer;
        objAnswer.Question__c=this.question_slackid;
        objAnswer.Response__c=this.ans_body;
        objAnswer.Response_By__c=this.response_by;
        objAnswer.Type__c=this.type;
        return objAnswer;
    }
    public override boolean validate(){
        if(this.res_by_fedid == null || String.isBlank(this.res_by_fedid)){
            throw new PSCException('Please provide valid res_by_fedid');
        }
        if(this.best_Answer == null){
            throw new PSCException('Please provide valid best_Answer');
        }
        if(this.question_slackid == null || String.isBlank(this.question_slackid)){
            throw new PSCException('Please provide valid question_slackid');
        }
        if(this.ans_body == null || String.isBlank(this.ans_body)){
            throw new PSCException('Please provide valid ans_body');
        }
        return true;
    }
}