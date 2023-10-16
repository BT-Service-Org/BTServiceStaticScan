public with sharing class PSCGetAssignedApprover {
    @InvocableMethod
    public static List<Results> execute(List<Requests> requests) {
        List<Results> responseWrapper       = new List<Results>();
        List<String> parentRecIds           = new List<String>();

        for (Requests curRequest : requests) {
            parentRecIds.add(curRequest.recordId);
        }

        List<ProcessInstance> piList = [SELECT Id, TargetObjectId,
                                            (SELECT Id ,Actorid, Actor.Type
                                            FROM StepsAndWorkitems 
                                            WHERE StepStatus= 'Pending'
                                            LIMIT 1)
                                        FROM ProcessInstance 
                                        WHERE  Status = 'Pending'
                                        AND TargetObjectId IN :parentRecIds];
        for(ProcessInstance each:piList){
            Results response = new Results();
            response.parentId = each.TargetObjectId;
            
            for(ProcessInstanceHistory pih:each.StepsAndWorkitems){
                if(pih.Actor.Type == 'User' ){
                    response.assignedUserId = pih.Actorid;
                }
                else if(pih.Actor.Type == 'Queue'){
                    response.groupId = pih.Actorid;
                }
            }
            responseWrapper.add(response);
        }

        return responseWrapper;
    }

    public class InvocableErrorException extends Exception {
    }


    public class Requests {

        @InvocableVariable
        public String recordId;
    
    }

    public class Results {

        @InvocableVariable
        public Id groupId;
        @InvocableVariable
        public Id assignedUserId;
        @InvocableVariable
        public Id parentId;

    }
}