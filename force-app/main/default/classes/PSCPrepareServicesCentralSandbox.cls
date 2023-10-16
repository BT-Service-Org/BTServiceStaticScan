global class PSCPrepareServicesCentralSandbox implements SandboxPostCopy {
    public PSCPrepareServicesCentralSandbox() {

    }
    global void runApexClass(SandboxContext context) {
        List<User> userList =new List<User> ();
        userList=[select id,ProfileId,federationidentifier,email from User where federationidentifier in ('a.sohail@salesforce.com', 'ayunkin@salesforce.com', 'anurag.suman@salesforce.com', 'atul.chhabra@salesforce.com', 'daniel.furry@salesforce.com', 'michelle.long@salesforce.com', 'mverma@salesforce.com', 'pkommera@salesforce.com', 'sratliff@salesforce.com', 'sunil.singhal@salesforce.com')];
        Id userProfileId=[Select id from Profile where name='System Administrator'][0].id;
        for (User usr:userList) {
            usr.ProfileId=userProfileId;
            usr.email=usr.federationidentifier ;
            }
        update userList;
        for(User usr:userList){
            System.resetPassword(usr.Id, true);
            }
    }
}