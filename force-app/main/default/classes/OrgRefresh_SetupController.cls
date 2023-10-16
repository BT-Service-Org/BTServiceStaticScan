public with sharing class OrgRefresh_SetupController {
    
    public boolean oauthDefined {get;set;}
    public boolean orgSettingsDefined {get;set;}
    public String userName {get;set;}
     
    public Boolean canFetchData{get;set;}
    public boolean modifyOauth {get;set;}
    
    public boolean modifyOrgInfo {get;set;}


    public boolean authFlowSelected{get;set;}
  
    public boolean refreshScheduled {get;set;}

    public String selectedOrg {get;set;}
    //variable to store the selected app within a given org
    public String selectedApp {get;set;}

    //variable to store the new org and new app name
    public String newOrgName {get;set;}
    public String newAppName {get;set;}

    //variable to store the selected schedule frequency 
    public String selectedSchedFreq {get;set;}

    public Org_Refresh_Profile__c refreshProfInstance{get;set;}

    public List<SelectOption> orgSelections {get;set;}

    public List<SelectOption> appSelections {get;set;}

    public PageReference createNewOrgProfile(){
        //build refresh profile values we know until this point.
        refreshProfInstance=new Org_Refresh_Profile__c();
        refreshProfInstance.Name=newOrgName;
        refreshProfInstance.Org__c=selectedOrg;
        //set the selected org value to the recently defined org name
        selectedOrg=newOrgName;
        //add the newly defined org name to the list of orgs defined.
        orgSelections.add(new SelectOption(selectedOrg,selectedOrg));
        //fetch default app for the selected org if any.
        setDefaultAppforSelectedOrg();
        //obviously no apps would be defined for the new org. initialize app list to empty.
        appSelections=new List<SelectOption>();

        //set the necessary flags.
        authFlowSelected=false;
        oauthDefined=false;
        orgSettingsDefined=false;
        
        return null;
    }

    private void setOrgAppName(){
        OrgRefresh_QueryUtils.setOrgAppName(selectedOrg +'_'+ selectedApp);
    }

    private void setDefaultAppforSelectedOrg(){
        //reset selected app value.
        selectedApp=null;
        for(Org_Refresh_Profile__c orgApp:[select Name, Org__c
                                          from Org_Refresh_Profile__c
                                          where Org__c=:selectedOrg
                                          limit 1]){
               if(orgApp!=null && orgApp.Name!=null){
                  selectedApp=OrgRefresh_QueryUtils.getAppName(orgApp.Name);
                  //set the org and app name based on selected org and selected app.
                  setOrgAppName();
                  refreshProfInstance=OrgRefresh_QueryUtils.getRefreshProfile();
               }
          System.debug('====orgApp in setDefaultAppforSelectedOrg===' + orgApp);

        }
       System.debug('====selectedApp in setDefaultAppforSelectedOrg===' + selectedApp);

    }
 
   
    public PageReference createAppForSelectedOrg(){
        //reset the refresh profile values for the new app.
        refreshProfInstance=new Org_Refresh_Profile__c();
        /**
         * copy over connection information from an existing app for the selected org.
         */
        for(Org_Refresh_Profile__c orgApp:[select  Consumer_Secret__c
                                                 , Consumer_Key__c
                                                 , Callback_URL__c 
                                                 , Endpoint__c
                                                 , Refresh_Token__c
                                          from Org_Refresh_Profile__c
                                          where org__c=:selectedOrg
                                          limit 1]){
               if(orgApp!=null){
                  refreshProfInstance.Name=selectedOrg + '_' + newAppName;
                  //prepopulate all connection information
                  refreshProfInstance.Consumer_Secret__c=orgApp.Consumer_Secret__c;
                  refreshProfInstance.Consumer_Key__c=orgApp.Consumer_Key__c;
                  refreshProfInstance.Callback_URL__c=orgApp.Callback_URL__c;
                  refreshProfInstance.Endpoint__c=orgApp.Endpoint__c;
                  refreshProfInstance.Refresh_Token__c=orgApp.Refresh_Token__c;

               }
        }
        
       appSelections.add(new SelectOption(newAppName,newAppName));

       String minute=string.valueOf(system.now().minute() + 1);
       String hour=string.valueOf(system.now().hour());

       refreshProfInstance.Cron_Expression__c=dailyCronExp(minute,hour);
       
       selectedApp=newAppName;
       
       return null;
    }

    public PageReference changeSchedFreq(){
        String minute=string.valueOf(system.now().minute() + 1);
        String hour=string.valueOf(system.now().hour());
        if('Hourly'.equalsIgnoreCase(selectedSchedFreq)){
            refreshProfInstance.Cron_Expression__c=hourlyCronExp(minute,hour);
        }
        else if('Daily'.equalsIgnoreCase(selectedSchedFreq)){
            refreshProfInstance.Cron_Expression__c=dailyCronExp(minute,hour);
        }
        else{
            refreshProfInstance.Cron_Expression__c='';
        }
        return null;
    }

    public List<SelectOption> getDefinedUserNames(){
        List<SelectOption> userNames=new List<SelectOption>();
        for(Org_Refresh_Creds__c orgCred:[select User_Name__c 
                                          from Org_Refresh_Creds__c
                                          where Name=: (selectedOrg + '_' + selectedApp)]){
               userNames.add(new SelectOption(orgCred.User_Name__c,orgCred.User_Name__c));
        }
        return userNames;
    }

    private void loadOrgsPicklist(){
        Set<String> uniqueOrgNames=new Set<String>();
        orgSelections=new List<SelectOption>();
        Map<String,Org_Refresh_Profile__c> orgRefreshProfMap=Org_Refresh_Profile__c.getAll();

        if(orgRefreshProfMap!=null){
         for(Org_Refresh_Profile__c refreshProfile:orgRefreshProfMap.values()){
            if(refreshProfile.Org__c!=null && !uniqueOrgNames.contains(refreshProfile.Org__c)){
                orgSelections.add(new SelectOption(refreshProfile.Org__c,refreshProfile.Org__c));
                uniqueOrgNames.add(refreshProfile.Org__c);
            }
            
         }
        }
    }

    private void loadAppsPicklist(){
        System.debug('====selectedOrg====' + selectedOrg);
        Set<String> uniqueAppNames=new Set<String>();
        appSelections=new List<SelectOption>();

        for(Org_Refresh_Profile__c orgApp:[select Name 
                                          from Org_Refresh_Profile__c
                                          where org__c=:selectedOrg]){
             System.debug('====orgApp====' + orgApp);
       
               if(orgApp!=null && orgApp.Name!=null){
                 String appName=OrgRefresh_QueryUtils.getAppName(orgApp.Name);
                 if(appName!=null){
                    appSelections.add(new SelectOption(appName,appName));
                 }
               }
        }
    }

    public boolean getHasMessages(){
        return ApexPages.hasMessages();
    }

    public PageReference modifyOauthDetails(){
        //set the modify oauth flag to true and return to the same page.
        modifyOauth=true;
        return null;
    }

    public PageReference modifyOrgDetails(){
        //set the modify org info flag to true and return to the same page.
        modifyOrgInfo=true;
        return null;
    }

    public PageReference authenticateUser(){
        //method to set the org and app name for the transaction based on the selections.
        setOrgAppName();

        PA_Onboarding_Property__c paOnboardingProperty= PA_Onboarding_Property__c.getInstance('Authenticating_OrgName__c');
        if(paOnboardingProperty!=null){
            paOnboardingProperty.Value__c=selectedOrg;
            paOnboardingProperty.Key__c=selectedApp;
        }
        else{
            paOnboardingProperty=new PA_Onboarding_Property__c();
            paOnboardingProperty.Name='Authenticating_OrgName__c';
            paOnboardingProperty.Key__c=selectedApp;
            paOnboardingProperty.Value__c=selectedOrg;
        }
        upsert paOnboardingProperty Name;
        return OrgRefresh_AuthUtils.redirectAuthScreen();
    }

    public PageReference save(){
        saveRefreshProfile();
        //reset modifying flags
        modifyOrgInfo=false;
        modifyOauth=false;
        return null;
    }

    private void saveRefreshProfile(){
        //update refreshInstance based on the user selected local variables.
        refreshProfInstance.Name=selectedOrg+'_' + selectedApp;
        refreshProfInstance.UserNamePwd_Flow__c=authFlowSelected;
        refreshProfInstance.Schedule_Frequency__c=selectedSchedFreq;
        refreshProfInstance.org__c=selectedOrg;
        refreshProfInstance.username__c=userName;
        upsert refreshProfInstance Name;

       
        validateRefreshProfileData(true);
        //if the end user can fetch data on demand for the selected org, set the org name.
        if(canFetchData!=null && canFetchData){
            setOrgAppName();
        }
    }

    public PageReference updateAuthFlowFields(){
        //no need to do anything. Just capture the authfieldValue as an actionFunction Param.
        return null;
    }

    public PageReference cancel(){
        //user clicked cancel. Reset modify flags.
        modifyOrgInfo=false;
        modifyOauth=false;

        validateRefreshProfileData(false);

        return null;
    }

    public List<SelectOption> getScheduleOptions(){
        List<SelectOption> scheduleOptions=new  List<SelectOption>();
        scheduleOptions.add(new SelectOption('Hourly','Hourly'));
        scheduleOptions.add(new SelectOption('Daily','Daily'));
        scheduleOptions.add(new SelectOption('Custom','Custom'));
        return scheduleOptions;
    }

    private string hourlyCronExp(String minute,String hour){
        return '0 ' + minute + ' ' + hour + '/1 ? * *';
    }

    private string dailyCronExp(String minute,String hour){
        return '0 ' + minute + ' ' + hour + ' ? * *';
    }

    public String startFetchJob(){
        
        //update the cron expression based on the time fired.      
        //if custom cron , do nothing
        if(!('Custom'.equalsIgnoreCase(selectedSchedFreq))){
            changeSchedFreq();
        }
        
        
        String strJobName = selectedOrg + '_'+ selectedApp + ' - Refresh';
        Schedulable b = new OrgRefresh_BatchFetcher(selectedOrg+'_'+selectedApp);
        System.debug('after instantiating b '+b);
        return System.schedule(strJobName, refreshProfInstance.Cron_Expression__c, b);
/* 
        if (refreshProfInstance.Batch_Class__c != null) {
            // dynamically execute schedule a batch class
            Type t = Type.forName(refreshProfInstance.Batch_Class__c);
            Schedulable b = (Schedulable) t.newInstance();          
            return System.schedule(strJobName, refreshProfInstance.Cron_Expression__c, b);

        }
        // otherwise use the poll scores job
        return System.schedule(strJobName, refreshProfInstance.Cron_Expression__c, new OrgRefresh_PollScores());
*/
    }

    public PageReference scheduleRefresh(){
        //update the selected org name to the PA onboarding property.
    /*  PA_Onboarding_Property__c paOnboardingProperty=PA_Onboarding_Property__c.getInstance('selectedOrg');
        if(paOnboardingProperty!=null){
            paOnboardingProperty.Value__c=selectedOrg;
            paOnboardingProperty.Key__c=selectedApp;
        } 
        else{
            paOnboardingProperty=new PA_Onboarding_Property__c();
            paOnboardingProperty.Name='selectedOrg';
            paOnboardingProperty.Key__c=selectedApp;
            paOnboardingProperty.Value__c=selectedOrg;
        }
        upsert paOnboardingProperty Name;*/
        system.debug('sriram before calling start fetch' + selectedOrg);    
        String jobId=startFetchJob();
        System.debug('after calling start fetch');

        refreshProfInstance.Job_Id__c=jobId;
        upsert refreshProfInstance Name;
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, selectedOrg + ' refresh scheduled successfully'));
        return null;
    }

    public PageReference onDemandRefresh(){
        String accessToken='';
        if(canFetchData){
            //set the org and app name for the transaction
            setOrgAppName();

            //authenticate using refresh token flow
            
            if(refreshProfInstance.UserNamePwd_Flow__c!=null && refreshProfInstance.UserNamePwd_Flow__c){
                accessToken=OrgRefresh_AuthUtils.authenticateUser(OrgRefresh_AuthFlows.USERNAME_PASSWORD,selectedOrg +'_'+ selectedApp,refreshProfInstance.username__c,true);
            }
            else{
                accessToken=OrgRefresh_AuthUtils.authenticateUser(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN,true);
            }
            Decimal batchSize = refreshProfInstance.Batch_Size__c;
            if (batchSize == null || batchSize==0) batchSize=50; // default to 50 just in case
            OrgRefresh_BatchFetcher b = new OrgRefresh_BatchFetcher(selectedOrg+'_'+selectedApp);              
            Database.executeBatch((Database.Batchable<sObject>)b, batchSize.intvalue());             
                       
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Data fetched from other org successfully'));
        }
        else{
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Oauth or Org details found to the target org. Please define one.'));
        }
        return null;
    }

    private void validateRefreshProfileData(Boolean saveFlow){
        System.debug('=====refreshProfInstance in validate====' + refreshProfInstance);

        if(refreshProfInstance==null 
            || selectedOrg ==null
            || selectedOrg ==''
            || (!refreshProfInstance.UserNamePwd_Flow__c && (refreshProfInstance.Consumer_Key__c==null || refreshProfInstance.Consumer_Key__c==''))
            || (refreshProfInstance.UserNamePwd_Flow__c && (refreshProfInstance.userName__c==null || refreshProfInstance.userName__c==''))
           ){
              oauthDefined=false;
              orgSettingsDefined=false;
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Oauth details found to the target org. Please define one.'));
              refreshProfInstance=new Org_Refresh_Profile__c();
              canFetchData=false;
        }
        else if(
                 // (!isQueryDefined())
                  selectedApp ==null
               || selectedApp ==''
                  )
               
        {
            oauthDefined=true;
            orgSettingsDefined=false;
            canFetchData=false;
            if(saveFlow)
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' No App is defined for the org '));
        }

        else if(
                  selectedApp ==null
               || selectedApp ==''
               || (refreshProfInstance.Auto_Refresh__c==false && 
                                 (refreshProfInstance.Start_Date__c==null || refreshProfInstance.End_Date__c==null)
                  )
               )
        {
            oauthDefined=true;
            orgSettingsDefined=false;
            canFetchData=false;
            if(saveFlow)
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Start Date & End Date is required when auto refresh is false.'));
        }

        else{
            oauthDefined=true;
            orgSettingsDefined=true;
            authFlowSelected=refreshProfInstance.UserNamePwd_Flow__c;
            userName=refreshProfInstance.username__c;
            if(    authFlowSelected!=null 
                && authFlowSelected 
                && userName!=null 
                && userName.length()>0){
                //set the flag as canFetchData
                canFetchData=true;
            } 

            else if(  authFlowSelected!=null 
                   && !authFlowSelected 
                   && refreshProfInstance.Refresh_Token__c!=null 
                   && refreshProfInstance.Refresh_Token__c.length()>0){
                //set the flag as canFetchData
                canFetchData=true;
            }
            else{
              canFetchData=false;   
            }
           
           //query cron trigger object
           String strJobName = selectedOrg + '_'+ selectedApp + ' - Refresh';
           List<CronJobDetail> cronJobs=[select Id, Name, JobType from CronJobDetail where Name=:strJobName];

           if(cronJobs!=null && cronJobs.size()==1){
             refreshScheduled=true;
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Refresh Job already scheduled.'));
           }
           else if(   'Custom'.equalsIgnoreCase(selectedSchedFreq) 
                   && (refreshProfInstance.Cron_Expression__c==null 
                       || refreshProfInstance.Cron_Expression__c=='')
                  ){
                refreshScheduled=true;
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cron Expression must be specified.'));
    
           }
           else{
             refreshScheduled=false;
           }


            if(saveFlow)
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Profile settings saved successfully'));
        }
    }

    public PageReference fetchAccessToken(){
        //check, if the constructor has an authorization code from another endpoint.
        String code=ApexPages.currentPage().getParameters().get('code');
        
        //valid authorization code exists.
        if (code!=null && code!='' && code.length()>0){
            //authenticate using webflow.
            OrgRefresh_AuthUtils.authenticateUser(OrgRefresh_AuthFlows.OAUTH_WEBFLOW,code,true);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Connection established to the other org successfully'));
        }
        validateRefreshProfileData(false);
        return null;
    }
     
     //no action needed. Just set the app name through param and return
     public PageReference changeApp(){
        //set the org and app name based on the selections.
        setOrgAppName();
        //fetch the refresh profile based on the selections.
        refreshProfInstance=OrgRefresh_QueryUtils.getRefreshProfile();
        //update the schedule frequency value.
        
        selectedSchedFreq=refreshProfInstance.Schedule_Frequency__c;
    
        return null;
     }

    public PageReference changeOrg(){
        //load apps for the selected org
        loadAppsPicklist();
       
        //org changed. Set a default selected app for the selected org
        setDefaultAppforSelectedOrg();
        //update the schedule frequency value.
        selectedSchedFreq=refreshProfInstance.Schedule_Frequency__c;
    
 
        authFlowSelected=refreshProfInstance.UserNamePwd_Flow__c;
        userName=refreshProfInstance.username__c;
        System.debug('====refreshProfInstance=====' + refreshProfInstance);
        System.debug('====selectedOrg=====' + selectedOrg);
        validateRefreshProfileData(false);
        return null;
    }


    public OrgRefresh_SetupController() {
        ApexPages.getMessages().clear();
        
        loadOrgsPicklist();
        

        if(orgSelections!=null && orgSelections.size()>0){
            selectedOrg=orgSelections.get(0).getValue();
        }

        
        PA_Onboarding_Property__c authOrgName=PA_Onboarding_Property__c.getInstance('Authenticating_OrgName__c');
        if(authOrgName!=null && authOrgName.Value__c!=null && authOrgName.Value__c!=''){
            selectedOrg=authOrgName.Value__c;
            selectedApp=authOrgName.key__c;
        }
     
        setDefaultAppforSelectedOrg();

         //load apps for the selected org
        loadAppsPicklist();
         
        if(refreshProfInstance!=null){
            selectedSchedFreq=refreshProfInstance.Schedule_Frequency__c;
        }
        validateRefreshProfileData(false);
    }
}