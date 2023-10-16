global class SEP_CreateAssessmentAndPersonas {
    @InvocableMethod(label='Create Assessments and Personas' description='Creates assessment and persona records for discovery')
    global static List<List<MAPPersona__c>> createAssessmentAndPersonas(List<CreateAsssesmentRequest> requests) {
        CreateAsssesmentRequest req = requests[0];
        Opportunity oppty = [select Name,Id,AccountId,Account.Name from Opportunity where Id = :req.opportunityId];
        List<MAPAssessment__c> assessmentsToCreate = new List<MAPAssessment__c>();
        List<MAPPersona__c> personasToCreate = new List<MAPPersona__c>();
        List<MAPDomain__c> nonFunctional = [select Id from MapDomain__c where Name='SEP-Overall Engagement Discovery' limit 1];
        MAPDomain__c nfrDomain = nonFunctional[0];
        req.domainIds.add(nfrDomain.Id);
        List<MapDomain__c> domains = [select Id,Name from MapDomain__c where Id in :req.domainIds];
        Contact ct;
        if(Test.isRunningTest()){
            ct = [  select Id,Email from Contact 
                        where Email = :UserInfo.getUserEmail() 
                    limit 1];

        } else{
            ct = [  select Id,Email from Contact 
                        where Email = :UserInfo.getUserEmail() 
                        and Account.Name='Salesforce.com - DO NOT TOUCH' limit 1];
        }
        Map<String,Id> domainToAssessment = new Map<String,Id>();
        Map<Id,Id> domainToPersona = new Map<Id,Id>();
        for(MAPDomain__c domain: domains){
            assessmentsToCreate.add(new MAPAssessment__c(ExternalId__c = oppty.Id+'-'+domain.Id+'-'+domain.Name,
                                                         Assessed_Date__c = System.today(),
                                                         Opportunity__c = oppty.Id,
                                                         Customer__c = oppty.AccountId,
                                                         Summary__c = 'Discovery assessment for '+domain.Name
            ));
            personasToCreate.add(new MAPPersona__c( Contact__c=ct.Id,
                                                    Customer__c=oppty.AccountId,
                                                    Domain__c = domain.Id,
                                                    ExternalId__c=ct.id+'-'+oppty.Id+'-'+domain.Id));
        }

        upsert assessmentsToCreate ExternalId__c;
        upsert personasToCreate ExternalId__c;

        for(MAPPersona__c persona: personasToCreate){
            domainToPersona.put(persona.Domain__c,persona.Id);
        }
        for(MAPAssessment__c assessment: assessmentsToCreate){
            domainToAssessment.put(assessment.ExternalId__c,assessment.Id);
        }
        List<MAPInterview__c> interviewsToCreate = new List<MAPInterview__c>();
        Map<String,String> domainsCreated = new Map<String,String>();
        for(MAPDomain__c domain: domains){
            Id assessmentId = domainToAssessment.get(oppty.Id+'-'+domain.Id+'-'+domain.Name);
            Id personaId = domainToPersona.get(domain.Id);
            interviewsToCreate.add(new MAPInterview__c(Assessment__c=assessmentId,Persona__c=personaId,ExternalId__c=assessmentId+'-'+personaId, Interview_Date__c=System.today()));
        }
        System.debug('>>>>>>>> interviewsToCreate :'+interviewsToCreate);
        upsert interviewsToCreate ExternalId__c;

        return new List<List<MAPPersona__c>>{personasToCreate};
    }

}