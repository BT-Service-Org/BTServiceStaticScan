global class CreateAsssesmentRequest {
    @InvocableVariable(label='Selected Domain Ids' required=true)
    global List<String> domainIds;
    @InvocableVariable(label='Opportunity Id' required=true)
    global Id opportunityId;
}