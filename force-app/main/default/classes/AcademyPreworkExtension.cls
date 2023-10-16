global with sharing class AcademyPreworkExtension{

    public List<Academy_Question__c> questions {get; set;}
    private Academy_Prework__c theRec;
    public AcademyPreworkExtension(ApexPages.StandardController controller) {
        theRec = (Academy_Prework__c) controller.getRecord();
        System.debug('>>>>>>>>>>> Subject Area:'+theRec.Subject_Area__c);
        this.questions = [select Id,Question__c,Subject_Area__c,(select Id,Answer_Text__c,Selected__c from Candidate_Answers__r order by Option__c asc)
                         from Academy_Question__c where Subject_Area__c = :theRec.Subject_Area__c];
        
    }

    
     global class LinkInput{

        public String recordId {get; set;}
        public String linkUrl {get; set;}
        public String linkType {get; set;}
    }


    @RemoteAction
    global static String updatePreworkStatus(LinkInput input) {
        Academy_Prework__c preWork = [select Id, Content_Link__c,Video_Recording_Link__c,Exercise_Link__c
                                      from Academy_Prework__c
                                      where Id= :input.recordId];
        
        if(preWork.Exercise_Link__c==null){
            preWork.Exercise_Status__c=1;
        }
        if(input.linkType=='Video'){
            preWork.Video_Status__c=1;
        }
        if(input.linkType=='Content'){
            preWork.Content_Status__c=1;
        }
        if(input.linkType=='Exercise'){
            preWork.Exercise_Status__c=1;
        }
        preWork.Status__c='In-Progress';
        update preWork;
        return input.linkUrl;      

    }
    
    public PageReference saveAnswers(){
        List<Candidate_Answer__c> answerToUpdt = new List<Candidate_Answer__c>();
        for(Academy_Question__c question: questions){
            answerToUpdt.addAll(question.Candidate_Answers__r);
        }
        Database.update(answerToUpdt);
        System.debug('Answers updated');
        return new PageReference('/'+theRec.Id);
    }

}