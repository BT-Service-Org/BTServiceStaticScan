/**
@description		: This class updates the Last_Profile_Skills_Update__c field on onboarding records with the latest last modified date time stamp. Test class is CSG_UpdateOnboardingDetailsBatchTest  
                        Database.executebatch(new CSG_UpdateOnboardingDetailsBatch(),200);
*/

public class CSG_UpdateOnboardingDetailsBatch implements Database.Batchable<sObject>, Database.stateful {
    
    //The custom label "Last_Profile_Skills_Update_Frequency" stores the value 10, which indicates minutes
    public Static final Integer SKILL_FREQUENCY = Integer.valueof(String.escapeSingleQuotes(Label.Last_Profile_Skills_Update_Frequency)) ;
    
    public Static DateTime currentTime = System.now();
  
    /**
    @description : Start method of the batch class to get the latest ProfileSkillUserTax external object records
    @return : Database.QueryLocator
    @param bc - Database.BatchableContext
    */
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        //This is to run the execute method logic one time 
        DateTime earlierTime = currentTime.addMinutes(-SKILL_FREQUENCY);
        
        //This is to run the execute method for all the Profile skill user records modified in 10 minutes
        String query = 'select UserId__c,Last_Modified_Date__c from ProfileSkillUserTax__x   where Last_Modified_Date__c >= '+earlierTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss')+'.000+0000'+' Order by UserId__c ';
        
        return Database.getQueryLocator(query);
        
    }
    
    /**
    @description : Execute method of the batch class to update Taxonomy
    @param  bc - Database.BatchableContext
    @param  scope  - List<Sobject>
    */
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        //Map to store the Org62's userID as key and the latest date time stamp
        Map<ID,Datetime> userDateMap = new Map<Id,Datetime>();
        
        ProfileSkillUserTax__x eachTax ;
        for( Sobject eachSkill :  scope){
            eachTax = (ProfileSkillUserTax__x)eachSkill;
            Datetime tobecompared = userDateMap.get(eachTax.UserId__c);
            if(!userDateMap.containskey(eachTax.UserId__c)){
                userDateMap.put(eachTax.UserId__c,eachTax.Last_Modified_Date__c);
            }
            else if(eachTax.Last_Modified_Date__c > tobecompared  ){
                //Check if the record's Last modified date is latest than the existing Last modified value
                 userDateMap.put(eachTax.UserId__c,eachTax.Last_Modified_Date__c);
            } 
        }
        
        if(!scope.isEmpty() && !userDateMap.isEmpty()){ 
            performExecution(scope,userDateMap);
        }
    }
    
    /**
    @description : Logic which updates the onboaring records with the updated time stamp on the field "Last_Profile_Skills_Update__c"
    @return : string
    @param scope - List<Sobject>
    @param userDateMap - Map<ID,Datetime>  
    */
    public string performExecution(List<sObject> scope, Map<ID,Datetime>  userDateMap){
       
         String result = 'Success';
            //Query the onboarding records using Org62 userid 
            List<PA_Onboarding__c> onboardingList = [select id,Last_Profile_Skills_Update__c,Candidate__r.Org62Id__c 
                                                     FROM PA_Onboarding__c 
                                                     WHERE Candidate__r.Org62Id__c =:userDateMap.keySet() ];
            if(!onboardingList.isEmpty()){
                List<PA_Onboarding__c> onboaridngToUpsert = new List<PA_Onboarding__c>();
                for(PA_Onboarding__c eachOnboarding : onboardingList){
                    DateTime  lastModifiedDate = userDateMap.get(eachOnboarding.Candidate__r.Org62Id__c);
                    if(lastModifiedDate != null && eachOnboarding.Last_Profile_Skills_Update__c != lastModifiedDate){
                        eachOnboarding.Last_Profile_Skills_Update__c = lastModifiedDate;
                        onboaridngToUpsert.add(eachOnboarding);
                    }
                }
                result = upsertOnboardingRecords(onboaridngToUpsert);
                
            } 
        return result;
       
    }


    
    /**
    @description : To upsert onboarding records
    @param onboaridngToUpsert - onboarding records list to be updated
    @return : String
*/
    public string upsertOnboardingRecords(List<PA_Onboarding__c> onboaridngToUpsert){
        string isSuccess = 'Success';
        try{
            if(!onboaridngToUpsert.isEmpty()){
                Database.UpsertResult[] results = Database.upsert( onboaridngToUpsert, false ) ;
                
                for(Integer i=0;i<results.size();i++){
                    if (!results.get(i).isSuccess()){
                        Database.Error err = results.get(i).getErrors().get(0);
                        isSuccess = 'fail'+err.getMessage();
                        System.debug(Logginglevel.ERROR,'Error - '+err.getMessage() + '\nStatus Code : '+err.getStatusCode()+'\n Fields : '+err.getFields());
                    }
                }
            }
        }
        catch(Exception e){
           System.debug(Logginglevel.ERROR,'Error - '+e.getMessage() );
        }
         return 'Success';
    }
    
    /**
    @description : Finish method of the batch class
    @param bc - Database.BatchableContext
    */
    public void finish(Database.BatchableContext bc){
    }

    
}