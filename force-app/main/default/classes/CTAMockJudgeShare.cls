public class CTAMockJudgeShare {
    public static void createShares(List<CTA_Review_Session__c> reviews) {      
        List<CTA_Board_Candidate__Share> shares = new List<CTA_Board_Candidate__Share>();
        for (CTA_Review_Session__c current : reviews) {
            if (current.Evaluator__c != null) {
                CTA_Board_Candidate__Share judgeShare = new CTA_Board_Candidate__Share();
            	judgeShare.ParentId = current.CTA_Board_Candidate__c;
            	judgeShare.UserOrGroupId = current.evaluator__c;
            	judgeShare.AccessLevel = 'edit';
            	judgeShare.RowCause = Schema.CTA_Board_Candidate__Share.RowCause.Evaluator_Access__c;
            	shares.add(judgeShare);
        	}
        }
        
        if (!shares.isEmpty()) {
           upsert shares;
        } 
    }
    
}