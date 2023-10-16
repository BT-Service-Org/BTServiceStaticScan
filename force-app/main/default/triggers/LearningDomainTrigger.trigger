trigger LearningDomainTrigger on Learning_Domain__c (after update, before insert, before update) {
  static final Integer NO_OF_DAYS_PER_DOMAIN = 20;
  
  if (Trigger.isAfter && Trigger.isUpdate) {
    List<Id> casesToBeClosed = new List<Id>();

    for(Learning_Domain__c learningDomain: Trigger.new){
      Learning_Domain__c oldLearningDomain = Trigger.oldMap.get(learningDomain.id);
      
      if ((oldLearningDomain.Status__c == null || oldLearningDomain.Status__c!='Badged') &&
           (learningDomain.Status__c!=null && learningDomain.Status__c=='Badged'))
              casesToBeClosed.add(learningDomain.id);      
        
    }
       
    if (casesToBeClosed.size() > 0) {
        BadgeAssessmentRequestUtil requestUtil = new BadgeAssessmentRequestUtil();
        requestUtil.closeAssociatedCases(casesToBeClosed);   
    }
  }

  if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
    //Date: March 17, 2018 - Amar Kumthekar
    //Update List Survey URL into a list for Learning Domain    
    //Date: Mar 27 - Amar Kumthekar 
    // - Update: Use Custom Metadata for storing URL's
    // - Update Learning Domain URL's from Custom Meta data to the Survey URL
   
    for (Learning_Domain__c learningDomain: Trigger.new) {
      for (Bedrock_Survey_Link__mdt BedrockSurveys : [SELECT  Candidate_URL__c, Judge_URL__c, X1_Prefix_C_Email_C__c, X2_Prefix_Learning_Domain_C__c 
                                                      FROM    Bedrock_Survey_Link__mdt
                                                      WHERE   Label = :'Learning Domain Survey']){
      //Add old learning domain to the URL
      // Mar 27, 2018 - Judge URL can be enabled by update URL in Custom Metadata - Bedrok Survey Link - Judge URL and uncommenting last line                                                                                      
      // learningDomain.Bedrock_Candidate_Survey_Link__c = BedrockSurveys.Candidate_URL__c + BedrockSurveys.X1_Prefix_C_Email_C__c + learningDomain.Candidate_Email__c + BedrockSurveys.X2_Prefix_Learning_Domain_C__c + learningDomain.Name + '&entry.';
      // learningDomain.Bedrock_Judge_Survey_Link__c = BedrockSurveys.Judge_URL__c + '?usp=pp_url&entry.1216964658=' + learningDomain.Candidate_Email__c + '&entry.18116662=' + learningDomain.Name + '&entry.';

        learningDomain.Bedrock_Candidate_Survey_Link__c = BedrockSurveys.Candidate_URL__c + BedrockSurveys.X1_Prefix_C_Email_C__c + learningDomain.Candidate_Email__c + BedrockSurveys.X2_Prefix_Learning_Domain_C__c + EncodingUtil.urlEncode(learningDomain.Skill__c, 'UTF-8');
      }
    }
  }

  // Set Target Start and End Dates only for the core 9 Domain badges as identified by their Sequence #
  if (Trigger.isBefore && (Trigger.isInsert)) {
    for (Learning_Domain__c ld : Trigger.new) {
      if (ld.Sequence__c != null && ld.Sequence__c >= 1 && ld.Sequence__c <= 9) {
        ld.Target_Start_Date__c = Date.today().addDays(Integer.valueOf(NO_OF_DAYS_PER_DOMAIN + (NO_OF_DAYS_PER_DOMAIN * (ld.Sequence__c - 1))));
        ld.Target_End_Date__c = ld.Target_Start_Date__c.addDays(NO_OF_DAYS_PER_DOMAIN);
      }
    }
  }
    
  // Create Milestone records for Specialization
    if(Trigger.new.size() <= 99){
     //   if (Utility_CreateSpecializationMilestones.runOnce()){
            for(Learning_Domain__c ld : Trigger.new){
                if(ld.Skill__c  == 'EA Specialization'){
                    if(Trigger.isInsert && Trigger.IsAfter && ld.Target_End_Date__c != null){
                        Utility_CreateSpecializationMilestones.createSpecializationMilestones('EA Specialization',ld);
                    }else if(Trigger.IsUpdate && Trigger.isAfter){
                        Learning_Domain__c oldld = Trigger.oldMap.get(ld.Id);
                        if(ld.Total_EA_Milestones__c == 0){
                            system.debug('no of milestones ==' + ld.Total_EA_Milestones__c );
                            Utility_CreateSpecializationMilestones.createSpecializationMilestones('EA Specialization',ld);
                        }else if(oldld.Target_End_Date__c != ld.Target_End_Date__c){
                            system.debug('target date is not the same');
                            Utility_CreateSpecializationMilestones.updateSpecializationMilestones('EA Specialization', ld);
                        }
                    }
                }
            }   
      //  }
    }
}