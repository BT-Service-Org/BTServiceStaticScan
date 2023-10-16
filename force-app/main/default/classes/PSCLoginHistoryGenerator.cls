/*  * ********************************************************************************************** 
    *  Purpose    :     Transfers Standard Login History Object records to PSC_Login_History__c where unique Services Central logins are only considered.  
    *  Update Log :     27th June 2023 - Initial Draft 
    *                     
    * ************************************************************************************************ */
global with sharing class PSCLoginHistoryGenerator implements Schedulable,Database.Batchable<sObject> {
    /* runForAllData set to true if all time LoginHistory data need to be considered else set to default false to run on one day scope.
     */
    public Boolean runForAllData=false;
    public PSCLoginHistoryGenerator( Boolean runningFlag) {
        this.runForAllData   =runningFlag; 
        }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String samlSsoConfigId='' ;
        List<SamlSsoConfig> sscList =new List<SamlSsoConfig> ();
        sscList=[Select id from SamlSsoConfig where DeveloperName = :PSCSettingService.getValue('PSCOktaAppDevName')];
        if(sscList!=null && sscList.size()>0){
            SamlSsoConfigId=sscList[0].id;
            }
        /*  AuthenticationServiceId filter used to only consider LoginHistory records coming from Services Central Okta app.
         */    
        String query ;
        query='SELECT UserId,LoginTime FROM LoginHistory WHERE ' ;
        query+='AuthenticationServiceId=\''+SamlSsoConfigId+'\' ';
        if(runForAllData==false){
            query+='and logintime>=YESTERDAY';
            }
        List<sObject> lst=Database.query(query);
        return Database.getQueryLocator(query);
        }

    global void execute(Database.BatchableContext BC, List<LoginHistory> scope){
        List<Id> userIds=new List<Id> ();
        for(LoginHistory lh:scope){
            userIds.add(lh.UserId)  ;  
            }
        List<PSC_Login_History__c> existingRecords =[Select user__c,LoginDate__c from PSC_Login_History__c where User__c in :userIds ];
        Map<Id,Set<Date>> existingUseridToLoginDatesMap =new Map<Id,Set<Date>> ();
         for(PSC_Login_History__c pscLH:existingRecords){
            Set<Date> dateSet =new Set<Date>();
            if(existingUseridToLoginDatesMap.containskey(pscLH.user__c)){
                dateSet= existingUseridToLoginDatesMap.get(pscLH.user__c);
                 }
            dateSet.add(pscLH.LoginDate__c);
            existingUseridToLoginDatesMap.put(pscLH.user__c,dateSet);
            }

        Map<Id,Set<Date>> useridToLoginDatesMap =new Map<Id,Set<Date>> ();
        for(LoginHistory lh:scope){
            Set<Date> dateSet =new Set<Date>();
            if(useridToLoginDatesMap.containskey(lh.userId)){
                dateSet= useridToLoginDatesMap.get(lh.userId);
                 }
            dateSet.add(date.newinstance(lh.LoginTime.year(), lh.LoginTime.month(), lh.LoginTime.day()));
            useridToLoginDatesMap.put(lh.userId,dateSet);
            }
        List<PSC_Login_History__c> psLHList =new  List<PSC_Login_History__c> () ;
        for(Id userid :useridToLoginDatesMap.keyset()){
            for(Date dt:useridToLoginDatesMap.get(userid) ){
                if(existingUseridToLoginDatesMap.get(userid)!=null &&  existingUseridToLoginDatesMap.get(userid).size()>0) {
                    if(!existingUseridToLoginDatesMap.get(userid).contains(dt)){
                         psLHList.add(new PSC_Login_History__c (User__c=userid,LoginDate__c=dt));
                        }
                    }
                else{
                    psLHList.add(new PSC_Login_History__c (User__c=userid,LoginDate__c=dt));
                    } 
                }
                }
        Database.insert(psLHList);
        }
    global void execute(SchedulableContext scon) {
        Database.executeBatch(new PSCLoginHistoryGenerator(false));
        }
    global void finish(Database.BatchableContext BC){ 
        
        }    

}