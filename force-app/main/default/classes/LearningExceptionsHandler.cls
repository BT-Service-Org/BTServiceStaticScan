public with sharing class LearningExceptionsHandler {

    //This method applies Learning Exceptions to the Activities associated with an Enablement Journey
    @InvocableMethod(label='Apply Learning Exceptions' description='Applies Learning Exceptions to the Activities associated with an Enablement Journey')
    public static List<FlowOutputForExceptions> applyLearningExceptions(List<FlowInputForExceptions> flowInputs) {

        Set<Id> domainIdsAssociatedToJourney = new Set<Id>();
        Map<Id, List<Enablement_Activity__c>> learningIdToActivitiesMap = new Map<Id, List<Enablement_Activity__c>>();
        Map<Id, List<Enablement_Exception__c>> learningIdToExceptionsMap = new Map<Id, List<Enablement_Exception__c>>();

        List<Enablement_Activity__c> activitiesToBeUpdated = new List<Enablement_Activity__c>();

        List<String> ignoreStatus = new List<String> {'In Progress', 'Completed'};

        Map<String, String> activityStatusMap = new Map<String, String>{'Restriction' => 'Restricted', 'Exemption' => 'Not Required'};

        //Get current onboarding record along with associated Journey Domain records
        Enablement_Journey__c enablementJourneyRec = [  SELECT  id, Contributor_Type__c, Hire_Type__c, Job_Level__c, Region__c, Worker_Type__c,
                                                    (SELECT id, Enablement_Domain__c FROM Journey_Domains__r)
                                                    FROM    Enablement_Journey__c
                                                    WHERE   id = :flowInputs[0].enablementJourneyId];
        
        //Create a set of Domain ids associated with Journey Domain records
        for(Enablement_Journey_Domain__c jd :enablementJourneyRec.Journey_Domains__r) {
            domainIdsAssociatedToJourney.add(jd.Enablement_Domain__c);
        }
        
        //Get Enablement Activities associated to the Journey 
        //and create a map of learning id to associated activities
        for(Enablement_Activity__c enAct :[ SELECT  id, Status__c, Learning__c 
                                            FROM    Enablement_Activity__c 
                                            WHERE   Activity_Group__r.Enablement_Journey__c = :enablementJourneyRec.Id 
                                                AND Status__c NOT IN :ignoreStatus
                                                AND IsClosed__c = false]){
            if(!learningIdToActivitiesMap.containsKey(enAct.Learning__c)) {
                learningIdToActivitiesMap.put(enAct.Learning__c, new List<Enablement_Activity__c>());
            }
            learningIdToActivitiesMap.get(enAct.Learning__c).add(enAct);                             
        }
        
        //Get Learning Exceptions associated to the Learnings
        //and create a map of learning id and associated exceptions
        for(Enablement_Exception__c le :[ SELECT  id, Basis__c, Learning_Domain__r.Learning__c, Learning_Domain__r.Onboarding_Domain__c, Type__c, Value__c 
                                        FROM    Enablement_Exception__c 
                                        WHERE   Learning_Domain__r.Learning__c IN :learningIdToActivitiesMap.keySet()]) {
            if(!learningIdToExceptionsMap.containsKey(le.Learning_Domain__r.Learning__c)){
                learningIdToExceptionsMap.put(le.Learning_Domain__r.Learning__c, new List< Enablement_Exception__c >());
            }
            learningIdToExceptionsMap.get(le.Learning_Domain__r.Learning__c).add(le);

        }

        String exceptionType;
        //Apply exceptions by iterating through exceptions and activities
        for(Id learningId :learningIdToActivitiesMap.keySet()){
            exceptionType = '';
            //check if exceptions exist for the learning
            if(learningIdToExceptionsMap.containsKey(learningId)){
                System.debug('learningIdToExceptionsMap.get(learningId)='+learningIdToExceptionsMap.get(learningId));
                //iterate over each exception and decide if the exception is applicable to the activities
                for(Enablement_Exception__c le :learningIdToExceptionsMap.get(learningId)) {
                    //check if the learning exception's domain is present in Journey Domains
                    if(domainIdsAssociatedToJourney.contains(le.Learning_Domain__r.Onboarding_Domain__c)) {
                        //check if the basis for learning exception meets journey criteria

                        if(le.Type__c == 'Restriction') {
                            if( (le.Basis__c == 'Contributor Type' && enablementJourneyRec.Contributor_Type__c != le.Value__c)
                                || (le.Basis__c == 'Hire Type' && enablementJourneyRec.Hire_Type__c != le.Value__c)
                                || (le.Basis__c == 'Job Level' && enablementJourneyRec.Job_Level__c != le.Value__c)
                                || (le.Basis__c == 'Region' && enablementJourneyRec.Region__c != le.Value__c) 
                                || (le.Basis__c == 'Worker Type' && enablementJourneyRec.Worker_Type__c != le.Value__c) ) {
                                    //Assign value to exceptionType only if current value if not Exemption
                                    //if current value is Exemption, ignore the exception
                                    if( exceptionType != 'Exemption') {
                                        exceptionType = le.Type__c;
                                    }

                            }

                        }

                        else if( (le.Basis__c == 'Contributor Type' && enablementJourneyRec.Contributor_Type__c == le.Value__c)
                            || (le.Basis__c == 'Hire Type' && enablementJourneyRec.Hire_Type__c == le.Value__c)
                            || (le.Basis__c == 'Job Level' && enablementJourneyRec.Job_Level__c == le.Value__c)
                            || (le.Basis__c == 'Region' && enablementJourneyRec.Region__c == le.Value__c) 
                            || (le.Basis__c == 'Worker Type' && enablementJourneyRec.Worker_Type__c == le.Value__c) ) {
                                
                                exceptionType = le.Type__c;
                                
                        }
                    }
                }
                System.debug('exceptionType='+exceptionType);
                //Assign the status value to Activities based on the exceptionType
                
                for(Enablement_Activity__c enAct :learningIdToActivitiesMap.get(learningId)){
                    if(String.isNotBlank(exceptionType)) {
                        enAct.Status__c = activityStatusMap.get(exceptionType);
                    } else if(enAct.Status__c != 'Not Required'){
                        enAct.Status__c = 'Not Started';
                    }
                    activitiesToBeUpdated.add(enAct);
                }
                
            }
        }
        
        //Output of the method
        List<FlowOutputForExceptions> flowOuputs = new List<FlowOutputForExceptions>();
        FlowOutputForExceptions fo = new FlowOutputForExceptions();
        
        if(activitiesToBeUpdated.size() > 0) {
            try {
                update activitiesToBeUpdated;
                fo.jobStatus = 'Success';
            } catch( Exception e) {
                fo.jobStatus = 'Fail';
            }
        }
        flowOuputs.add(fo);
        return flowOuputs;
    }



        //input details that comes to apex from flow
        public class FlowInputForExceptions{

            @InvocableVariable
            public String enablementJourneyId;
            
            
        }
    
        //flow output
        public class FlowOutputForExceptions{
    
            @InvocableVariable
            public String jobStatus;
            
            
        }
}