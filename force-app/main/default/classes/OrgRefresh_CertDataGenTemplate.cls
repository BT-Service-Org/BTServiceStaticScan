public with sharing class OrgRefresh_CertDataGenTemplate {

    private static Certification_Data__c generateCertInstance( String certName
                                                      , Map<String,Certification_Data__c> certDataMap
                                                      , PA_Onboarding__c paOnboardInstance
                                                      , String oldPARecordContactEmail
                                                      , String candidateEmail
                                                      , String mentorEmail
                                                      , Boolean isUpdate
                                                      , Integer expectedNoOfDays
                                                      ){

        //CERT:BEGIN
        Certification_Data__c certInstance=certDataMap.get(candidateEmail+certName);
        System.debug('>>>>>>1: generateCertInstance().certInstance='+certInstance);
        System.debug('>>>>>>1: generateCertInstance().certDataMap='+certDataMap);
        if(certInstance==null){
            //update scenario and the contact has changed. Hence couldn't find the cert record.
            if(isUpdate){
               Certification_Data__c oldCertInstance=certDataMap.get(oldPARecordContactEmail+certName);
               //override existing instance
               certInstance=oldCertInstance;
            }
            //If there is no Cert record, then create a new one
            if(certInstance==null){
                certInstance=new Certification_Data__c(Contact__c=paOnboardInstance.Contact__c);
                certInstance.Certification_Type_Name__c=certName;
            }
            
        }
        System.debug('>>>>>>2: generateCertInstance().certInstance='+certInstance);
        System.debug('>>>>>>generateCertInstance.paOnboardInstance='+paOnboardInstance);
        certInstance.PA_Onboarding__c=paOnboardInstance.Id;
        certInstance.Mentor_Email__c=mentorEmail;
        certInstance.Candidate_Email__c=candidateEmail;
        certInstance.Cert_Unique_Id__c=certInstance.Candidate_Email__c + certInstance.Certification_Type_Name__c;
        certInstance.Expected_Completion_Date__c=paOnboardInstance.Program_Start_Date__c.addDays(expectedNoOfDays);
        return certInstance;
        //CERT:END

          
    }

    private static boolean doesPARecordNeedsUpdate(PA_Onboarding__c newInstance, PA_Onboarding__c oldInstance){
        if(newInstance!=null && oldInstance!=null){
            if( (newInstance.Contact__c!=oldInstance.Contact__c
                || newInstance.Mentor__c!=oldInstance.Mentor__c
                || newInstance.Program_Start_Date__c!=oldInstance.Program_Start_Date__c)
                //|| (newInstance.Program__c!=oldInstance.Program__c && 'Accelerated Onboarding'.equals(newInstance.Program__c))){
                || (newInstance.Program__c!=oldInstance.Program__c && (newInstance.Program__c != null && !newInstance.Program__c.equals('Observer')))){ //GR
                return true;
            }
            else{
                return false;
            }
        }
        else{
            return false;
        }
    }
    /**
     * Method that takes the list of new pa onboarding records.
     * The second parameter is the trigger old map passed in case of updates and is null for inserts.
     */
    public static List<Badge_Data__c> genBaseCertTemplate( List<PA_Onboarding__c> paOnboardList
                                                                 , Map<Id,PA_Onboarding__c> oldMap){
            
            //gather the list of contacts
            List<String> contactIds=new List<String>();
            List<String> mentorIds=new List<String>();

            Boolean isUpdate=(oldMap!=null);

            //create a list of pa onboarding to store the pa onboarding records of interest.
            List<PA_Onboarding__c> affectedPArecords=new List<PA_Onboarding__c>();

            //Get the map between certification data and cert unique id
            //Map<String,Certification_Data__c> certDataMap=new Map<String,Certification_Data__c>();

            //delete certification data records when candidate changes, but preserve the info
            //List<Certification_Data__c> certDataToBeDeleted=new List<Certification_Data__c>();
            
            PA_Onboarding_Property__c paTemplate = PA_Onboarding_Property__c.getValues('Template PA Onboarding Id'); 
            String templateRecordId = paTemplate.Value__c;
            
            for(PA_Onboarding__c paOnboardInstance:paOnboardList){
                   //If the template record is being udpated, skip the cert baseline date calculation.
                   if(paOnboardInstance.Id == templateRecordId){
                        continue;
                   }
                   
                   //if pa record needs update then add
                   //if( (!isUpdate && 'Accelerated Onboarding'.equals(paOnboardInstance.Program__c)) || 
                   if (!isUpdate && (paOnboardInstance.Program__c != null && !paOnboardInstance.Program__c.equals('Observer')) || //GR
                       (isUpdate && 
                        doesPARecordNeedsUpdate( paOnboardInstance
                                                ,oldMap.get(paOnboardInstance.Id)
                                               )
                       )
                      )
                   {
                      mentorIds.add(paOnboardInstance.Mentor__c);
                      affectedPArecords.add(paOnboardInstance);
                   }
                   //both old and new contacts needs to be queried.
                   contactIds.add(paOnboardInstance.Contact__c);
                     
                   
            }

            /* GR:for(Certification_Data__c certDataInstance: [select  Id
                                                                , Candidate_Email__c
                                                                , Certification_Status__c
                                                                , Certification_Type_Name__c
                                                                , Cert_Unique_Id__c
                                                                , Contact__c
                                                                , Expected_Completion_Date__c
                                                                , Mentor_Email__c
                                                                , Original_Certification_Date__c
                                                        from Certification_Data__c
                                                        where Contact__c in :contactIds]){
                  certDataMap.put(certDataInstance.Cert_Unique_Id__c,certDataInstance);
            }*/


            

          
            //query contact for email
            Map<Id,Contact> contactMap=new Map<Id,Contact>([select Email from Contact where Id in :contactIds]);
            //query user for email
            Map<Id,User> mentorMap=new Map<Id,User>([select Email from User where Id in :mentorIds]);

            //List<Certification_Data__c> certDataGenTemplateList=new List<Certification_Data__c>();
            List<Badge_Data__c> lpBadgeData = new List<Badge_Data__c>(); //GR

            System.debug('>>>>>>>>>affectedPArecords>>>>>>>>>>>>>>:'+affectedPArecords);
            for(PA_Onboarding__c paOnboardInstance:affectedPArecords){

                if(paOnboardInstance.Program_Start_Date__c!=null && paOnboardInstance.Contact__c!=null && paOnboardInstance.Mentor__c!=null){
                    /*
                     * create/update certification data instances for all 
                     */
                    String candidateEmail= contactMap.get(paOnboardInstance.Contact__c).Email;
                    String mentorEmail=mentorMap.get(paOnboardInstance.Mentor__c).Email;
                    String oldPARecordContactEmail=null;
                    System.debug('>>>>>>>>contactMap:'+contactMap);
                    System.debug('>>>>>>>>oldMap:'+oldMap);
                    System.debug('>>>>>>>>paOnboardInstance.Contact__c:'+paOnboardInstance.Contact__c);
                    if(isUpdate){
                        oldPARecordContactEmail=contactMap.get(oldMap.get(paOnboardInstance.Id).Contact__c).Email;
                    }
                    //GR
                    for (Ramp_Milestones__mdt m : getConfig(paOnboardInstance.Level__c)) {
                        Integer noofdays = Integer.valueOf(m.No_of_days__c);
                        Badge_Data__c lpBadge = new Badge_Data__c (
                                                        Name=m.Milestone_name__c,
                                                        Quiz_Complete__c=false,
                                                        PA_Onboarding__c=paOnboardInstance.Id,
                                                        Contact__c = paOnboardInstance.Contact__c,
                                                        Unique_Id__c=candidateEmail + m.Milestone_name__c,
                                                        Cert__c=(m.type__c=='Certification'?true:false),
                                                        Expected_Completion_date__c=paOnboardInstance.Program_Start_Date__c.addDays(noofdays),
                                                        X90_day_learning_path__c=m.X90_day_learning_path__c,
                                                        Reqd_PA_Path__c=m.Critical_for_deployment__c,
                                                        X9_Domain_Badge__c=m.X9_Domain_Badge__c
                                                    );
                        
                        lpBadgeData.add(lpBadge);
                        System.debug('>>>>> lpBadge:'+lpBadge);
                                  
                    }
                    /* GR: Integer nbrOfDays = -1;
                    //generate cert instance for Administrator
                    if(paOnboardInstance.Program__c.equals('Accelerated Onboarding')){
                        nbrOfDays=14;
                    }
                    if(paOnboardInstance.Program__c.equals('PA Track')){
                        nbrOfDays=28;
                    }
                    Certification_Data__c certInstance=generateCertInstance( 'Certified Administrator'
                                                                            , certDataMap
                                                                            , paOnboardInstance
                                                                            , oldPARecordContactEmail
                                                                            , candidateEmail
                                                                            , mentorEmail
                                                                            , isUpdate
                                                                            , nbrOfDays);
                     certDataGenTemplateList.add(certInstance);

                    //generate cert instance for Administrator
                    if(paOnboardInstance.Program__c.equals('Accelerated Onboarding')){
                        nbrOfDays=42;
                    }
                    if(paOnboardInstance.Program__c.equals('PA Track')){
                        nbrOfDays=56;
                    }
                    certInstance=generateCertInstance( 'Certified Developer'
                                                                            , certDataMap
                                                                            , paOnboardInstance
                                                                            , oldPARecordContactEmail
                                                                            , candidateEmail
                                                                            , mentorEmail
                                                                            , isUpdate
                                                                            , nbrOfDays);
                     certDataGenTemplateList.add(certInstance);
                    
                    //generate cert instance for Administrator
                    if(paOnboardInstance.Program__c.equals('Accelerated Onboarding')){
                        nbrOfDays=42;
                    }
                    if(paOnboardInstance.Program__c.equals('PA Track')){
                        nbrOfDays=56;
                    }
                    certInstance=generateCertInstance( 'Certified Advanced Administrator'
                                                                            , certDataMap
                                                                            , paOnboardInstance
                                                                            , oldPARecordContactEmail
                                                                            , candidateEmail
                                                                            , mentorEmail
                                                                            , isUpdate
                                                                            , nbrOfDays);
                     certDataGenTemplateList.add(certInstance);
                    //generate cert instance for Administrator
                    if(paOnboardInstance.Program__c.equals('Accelerated Onboarding')){
                        nbrOfDays=70;
                    }
                    if(paOnboardInstance.Program__c.equals('PA Track')){
                        nbrOfDays=84;
                    }
                     certInstance=generateCertInstance( 'Certified Service Consultant'
                                                                            , certDataMap
                                                                            , paOnboardInstance
                                                                            , oldPARecordContactEmail
                                                                            , candidateEmail
                                                                            , mentorEmail
                                                                            , isUpdate
                                                                            , nbrOfDays);
                      certDataGenTemplateList.add(certInstance);

                      //generate cert instance for Administrator
                    if(paOnboardInstance.Program__c.equals('Accelerated Onboarding')){
                        nbrOfDays=70;
                    }
                    if(paOnboardInstance.Program__c.equals('PA Track')){
                        nbrOfDays=84;
                    }
                     certInstance=generateCertInstance( 'Certified Sales Consultant'
                                                                            , certDataMap
                                                                            , paOnboardInstance
                                                                            , oldPARecordContactEmail
                                                                            , candidateEmail
                                                                            , mentorEmail
                                                                            , isUpdate
                                                                            , nbrOfDays);
                      certDataGenTemplateList.add(certInstance);*/
                                  
                }
            }
       return lpBadgeData;     
    }
    
    private static List<Ramp_Milestones__mdt> getConfig(String level) {
        
        List<Ramp_Milestones__mdt> config = new List<Ramp_Milestones__mdt>();
        for (Ramp_Milestones__mdt m : [select Role__c, Milestone_name__c, No_of_days__c,Required__c,Type__c,X9_Domain_Badge__c,X90_day_learning_path__c,Critical_for_deployment__c from Ramp_Milestones__mdt 
                where X90_day_learning_path__c=true and (Role__c='All' or Role__c=:level)]) {
            config.add(m);
        }
            
        return config;
    } 
    
}