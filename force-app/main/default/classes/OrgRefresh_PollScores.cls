global class OrgRefresh_PollScores implements Schedulable {
    /**
     * Method to fetch the org and app name combination given a job id.
     */
    private String determineOrgAppName(String jobId){
        System.debug('===jobIdin pollscores===' + jobId);
        //convert 18 digit id to 15 digits as that is what is stored in custom settings
        jobId=jobId.substring(0,15);
        System.debug('===15 digit jobIdin pollscores===' + jobId);
        
        //query custom settings to find the org app combination for this id.
        List<Org_Refresh_Profile__c> refreshProfInstances=[select Name from Org_Refresh_Profile__c where Job_Id__c=:jobId];
        System.debug('===refreshProfInstances in pollscores===' + refreshProfInstances);
        
        //there should be one and only entry for the intended job Id
        
        if(refreshProfInstances!=null && refreshProfInstances.size()==1){
           return refreshProfInstances[0].Name;
        }
        else{
            return null;
        }
    }

    private void authenticateandFetch(String orgAppName){
        System.debug('====orgAppName in authenticateandFetch ===' + orgAppName);

        //Get the refresh profile for the needed org.
        Org_Refresh_Profile__c refreshProfInstance=Org_Refresh_Profile__c.getInstance(orgAppName);
            
        System.debug('====refreshProfInstance in authenticateandFetch===' + refreshProfInstance);

        if(orgAppName!=null && refreshProfInstance!=null){
                //check if using username and password flow
                if(refreshProfInstance.UserNamePwd_Flow__c!=null && refreshProfInstance.UserNamePwd_Flow__c){
                    OrgRefresh_QueryUtils.authenticateandFetch( OrgRefresh_AuthFlows.USERNAME_PASSWORD.name() //auth flow name
                                                               , orgAppName//org app name combination
                                                               , refreshProfInstance.username__c //user name
                                                               );
                 }
                else{
                    OrgRefresh_QueryUtils.authenticateandFetch( OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN.name() //refresh token flow
                                                              , orgAppName // org app name
                                                              , null // pass null for username as the refresh doesn't need a username
                                                              );
                 
                }
            } //end refreshProfInstance!=null check
    }


    global void execute(SchedulableContext sc) {
        //fetch the job id
        String jobId=sc.getTriggerId();
        System.debug('===jobId====' + jobId);
        
        authenticateandFetch(determineOrgAppName(jobId));
        

   } //end execute
}// end OrgRefresh_PollScores