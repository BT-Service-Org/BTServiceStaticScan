/**
 * @Date   October 2021
 * @Group  Services Org
 * Description - Called this apex class from GDC_DA_Approval_Initiator to check currentUser a Part of TeamMember or not.
 */
public class GDC_DA_ProjectTeamMemberCheck {

    @InvocableMethod(label = 'Metric Approval Team Member Check' description = 'Metric Approval Team Member Check')
    public static List < List < String >> checkApprovalAccess(List < string > metricRecordId) {
        try{
            System.debug('metricId -->'+metricRecordId);
            List < GDC_DA_Metric__c > projs = [select ProjectName__c,ProjectName__r.Project_Owner__c from GDC_DA_Metric__c where Id =: metricRecordId[0]];
            String projectId = projs[0].ProjectName__c;
            //List < String > memberLists = new List < String > ();
            set <String> memberLists = new Set<String>();
            memberLists.add(projs[0].ProjectName__r.Project_Owner__c );
            List < List < String >> returnParam = new List < List < String >> ();
            for (GDC_DA_Team_Member__c tm: [select Name__c,Project__r.Project_Owner__c from GDC_DA_Team_Member__c where Project__c =: projectId]) {
                memberLists.add(tm.Name__c);
            }
            System.debug('-->Memebers List-->'+memberLists);
            if (memberLists.contains(userInfo.getUserId())) {
                returnParam.add(new List < String > {'true'});
            } else {
                returnParam.add(new List < String > {'false'});
            }
            return returnParam;
        }
        catch(Exception e)
        {
            System.debug('Exception caught '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
}