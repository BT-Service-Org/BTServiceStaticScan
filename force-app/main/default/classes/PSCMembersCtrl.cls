/**
 * @author piyush.jindal@salesforce.com
 * @since August 2023
 * @description Controller class for pscAllMembers and pscMembersData component
 * @group Services Central
 */
public class PSCMembersCtrl {
    /**
     * @param  settingNameStr `String`
     * @return  `String`
     */
    @AuraEnabled(cacheable=true)
    public static String getSetting(String settingNameStr) {
        String tabToMemberRoleSetting = PSCSettingService.getValue(settingNameStr);
        
        return tabToMemberRoleSetting;
    }

    /**
     * @param memberRoleStr  `String`
     * @return  `List <Contribution_Team__c>`
     */
    @AuraEnabled(cacheable=true)
    public static List <Contribution_Team__c> getMembers(String memberRoleStr, String communityPageNameStr, String searchKeyStr){
        List <Contribution_Team__c> membersList = new List <Contribution_Team__c> ();
        String queryStr = '';
        String finalQueryStr = '';
        String memberRoleEscapedStr = String.escapeSingleQuotes(memberRoleStr);
        String communityPageNameEscapedStr = String.escapeSingleQuotes(communityPageNameStr);
        String searchKeyEscapedStr = String.escapeSingleQuotes(searchKeyStr);

        try{
            queryStr = 'SELECT Id, psc_Role__c, Community_Title__c, psc_Team_Member__r.Name,psc_Team_Member__r.Title, psc_Team_Member__r.MediumPhotoUrl FROM Contribution_Team__c WHERE RecordType.DeveloperName = \'Community_of_Practice\'';
            if(String.isBlank(searchKeyEscapedStr)) {
                queryStr += (String.isBlank(memberRoleEscapedStr) || memberRoleEscapedStr.toLowerCase() == 'all' ? '': ' AND psc_Role__c = :memberRoleEscapedStr');
            } else{
                searchKeyEscapedStr = '%' + searchKeyEscapedStr + '%';
                queryStr += ' AND psc_Team_Member__r.Name LIKE :searchKeyEscapedStr';
            }
            queryStr += (String.isBlank(communityPageNameEscapedStr) ? '': ' AND Community__r.URLName__c = :communityPageNameEscapedStr');
            finalQueryStr = queryStr + ' ORDER BY psc_Team_Member__r.Name ASC, psc_Role__c ASC';
            system.debug('finalQueryStr : '+finalQueryStr);
            membersList = Database.query(finalQueryStr);
        } catch (Exception e) {
            system.debug('Error in PSCMembersCtrl.getMembers : '+ e.getStackTraceString());
        }

        return membersList;
    }
}