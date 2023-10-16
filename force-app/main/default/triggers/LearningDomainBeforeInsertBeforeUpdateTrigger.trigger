trigger LearningDomainBeforeInsertBeforeUpdateTrigger on Learning_Domain__c (before insert, before update) {
 
   //Date: March 17, 2018 - Amar Kumthekar
   //Update List Survey URL into a list for Learning Domain    
   //Date: Mar 27 - Amar Kumthekar 
   // - Update: Use Custom Metadata for storing URL's
   // - Update Learning Domain URL's from Custom Meta data to the Survey URL
  
     
     for(Learning_Domain__c learningDomain: Trigger.new){
            
 
        for(Bedrock_Survey_Link__mdt BedrockSurveys : [SELECT Candidate_URL__c, Judge_URL__c, X1_Prefix_C_Email_C__c, X2_Prefix_Learning_Domain_C__c 
                                                 FROM Bedrock_Survey_Link__mdt
                                                 WHERE Label = :'Learning Domain Survey'
                                                 ]){
  
          //Add old learning domain to the URL

// Mar 27, 2018 - Judge URL can be enabled by update URL in Custom Metadata - Bedrok Survey Link - Judge URL and uncommenting last line                                                                                      
//        learningDomain.Bedrock_Candidate_Survey_Link__c = BedrockSurveys.Candidate_URL__c + BedrockSurveys.X1_Prefix_C_Email_C__c + learningDomain.Candidate_Email__c + BedrockSurveys.X2_Prefix_Learning_Domain_C__c + learningDomain.Name + '&entry.';
//        learningDomain.Bedrock_Judge_Survey_Link__c = BedrockSurveys.Judge_URL__c + '?usp=pp_url&entry.1216964658=' + learningDomain.Candidate_Email__c + '&entry.18116662=' + learningDomain.Name + '&entry.';
        learningDomain.Bedrock_Candidate_Survey_Link__c = BedrockSurveys.Candidate_URL__c + BedrockSurveys.X1_Prefix_C_Email_C__c + learningDomain.Candidate_Email__c + BedrockSurveys.X2_Prefix_Learning_Domain_C__c + EncodingUtil.urlEncode(learningDomain.Skill__c, 'UTF-8');

    }
   }
  }