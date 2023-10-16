//Assign Coaches (Past & Present to Judge)
// For Coaching Assignment  
//AssignCoachToJudge.AssignCoachToJudge();
global class AssignCoachToJudge implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        AssignCoachToJudge();
    }
    
    public static void AssignCoachToJudge() {

        List < CTA_Boards_Coached__c > trunBoardCoached = [Select Id from CTA_Boards_Coached__c];
        delete trunBoardCoached;

        List < CTA_Board_Candidate__c > ctaBoradCands = [Select Coach__c, Candidate__c, CTA_Board__c from CTA_Board_Candidate__c];

        Set < Id > coachIds = new Set < Id > ();
        for (Integer i = 0; i < ctaBoradCands.size(); i++) {
            coachIds.add(ctaBoradCands[i].Coach__c);
        }
        List < Judge__c > judges = [Select Id, User__c from Judge__c where User__c IN: coachIds];

        List < CTA_Boards_Coached__c > boardsCoached = new List < CTA_Boards_Coached__c > ();


        if (ctaBoradCands.size() > 0) {
            for (CTA_Board_Candidate__c ctaBoradCand: ctaBoradCands) {
                for (Judge__c judge: judges) {
                    if (ctaBoradCand.Coach__c == judge.User__c) {
                        CTA_Boards_Coached__c boardsCoach = new CTA_Boards_Coached__c();
                        boardsCoach.Candidate__c = ctaBoradCand.Candidate__c;
                        boardsCoach.CTA_Board__c = ctaBoradCand.CTA_Board__c;
                        boardsCoach.Judge__c = judge.Id;
                        boardsCoached.add(boardsCoach);
                    }
                }

            }
        }
        insert boardsCoached;
    }
}