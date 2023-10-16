public with sharing class PSC_ReviewAction {
    @InvocableMethod
    public static List<Results> execute(List<Requests> requests) {
        List<Results> responseWrapper = new List<Results>();
        for (Requests curRequest : requests) {
            Results response = new Results();
            Approval.ProcessWorkitemRequest approvalWorkItem = new Approval.ProcessWorkitemRequest();
            approvalWorkItem.setComments(curRequest.comments);
            approvalWorkItem.setAction(curRequest.action);
            String approvalRequestId = getapprovalRequestID(curRequest.recordId, curRequest.objName);

            approvalWorkItem.setWorkitemId(approvalRequestId);
            
            system.debug('approvalWorkItem ' + approvalWorkItem);
            
            // Submit the request for approval
            Approval.ProcessResult approvalResult =  Approval.process(approvalWorkItem);

            system.debug('ApprovalResult ' + approvalResult);
            
            response.isSuccess = approvalResult.isSuccess();
            Database.Error[] errors = approvalResult.getErrors();
            response.errorString = getErrorInfo(errors); //warning. only hacking out the first error
            response.currentApprovalProcessStatus = approvalResult.getInstanceStatus();

            responseWrapper.add(response);
        }
        return responseWrapper;

    }

    public static String getErrorInfo(Database.Error[] errors) {
        String errorStrings = '';
        if (errors != null) {
            for(Database.Error error : errors) {
                errorStrings = errorStrings + ' ' + error.getMessage();
            }
        }
        return errorStrings;
    }

    public static String getapprovalRequestID (String recordId,String objName){
        Id workItemId;
        List<ProcessInstance> procInsList = [SELECT Id, ProcessDefinition.Type,ProcessDefinition.TableEnumOrId,
                                                (SELECT Id, ActorId, ProcessInstanceId 
                                                FROM Workitems
                                                LIMIT 1)
                                            FROM ProcessInstance
                                            WHERE TargetObjectId =:recordId
                                            AND Status ='Pending'];
        
        for(ProcessInstance each:procInsList){
            if(each.ProcessDefinition.Type == 'Approval' && each.ProcessDefinition.TableEnumOrId == objName){
                for(ProcessInstanceWorkitem piwi:each.Workitems){
                    workItemId = piwi.Id;
                }
            }
        }
       
        if (workItemId != null) {
            return workItemId;
        } else {
            return null;
        }
        
    }

    public class InvocableErrorException extends Exception {
    }


    public class Requests {

        @InvocableVariable
        public String recordId;
        
        @InvocableVariable
        public String objName;
        
        @InvocableVariable
        public String comments;

        @InvocableVariable
        public String action;
    
    }

    public class Results {

        @InvocableVariable
        public Boolean isSuccess;

        @InvocableVariable
        public String errorString;

        @InvocableVariable
        public String currentApprovalProcessStatus;  //Approved, Rejected, Removed or Pending.

    }
}