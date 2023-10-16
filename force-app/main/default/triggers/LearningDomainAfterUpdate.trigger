trigger LearningDomainAfterUpdate on Learning_Domain__c (after update) {
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