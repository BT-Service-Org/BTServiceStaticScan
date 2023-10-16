//TJ USe this class to Assign Last Board Coach 
//AssignLastCoachToJudge.AssignLastCoachToJudge('a1m3A000001NiXO');
public class AssignLastCoachToJudge {
    public static void AssignLastCoachToJudge(String boardId) {
        List < CTA_Board_Candidate__c > ctaBoradCandIds = [Select Coach__c from CTA_Board_Candidate__c where CTA_Board__c =: boardId];
        Set < Id > ctaIds = new Set < Id > (); 

        for (Integer i = 0; i < ctaBoradCandIds.size(); i++) {
            ctaIds.add(ctaBoradCandIds[i].Coach__c);
        }

        List < Judge__c > judges = [Select Id, User__c from Judge__c where Is_Active__c = TRUE And Is_CTA__c = TRUE AND Supported_Regions__c = 'AMER'
            AND Judge_Dept__c = '3090-Program Architects'
            AND User__c IN: ctaIds
        ];
        List < Judge__c > judgeUpd = new List < Judge__c > ();

        for (Judge__c judge: judges) {
            judge.Last_Board_Coach__c = 'a1m3A000001NiXO';
            judgeUpd.add(judge);

        }
        update judgeUpd;

    }
}