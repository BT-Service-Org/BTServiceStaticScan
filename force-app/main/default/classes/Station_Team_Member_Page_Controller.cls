/**Name: Station_Team_Member_Page_Controller
*  Description : This class is controller for The_Station_Team_member_Page
*  @author : Vishwas ( Salesforce)
*  Date : 11/06/2019
* */
public class Station_Team_Member_Page_Controller {
    public class StationTeamMember {
        @AuraEnabled public String sImageURL='';
        @AuraEnabled public String sTitle='';
        @AuraEnabled public String sSubTitle='';
        @AuraEnabled public String sLink='';
    }

    @AuraEnabled(cacheable=true)
    public static Station_Pages__c getGroupName(String groupId) {
        Station_Pages__c grouping = [SELECT Id, Name, Group_Subtitle__c FROM Station_Pages__c WHERE Id = :groupId LIMIT 1];
        return grouping;
    }

    @AuraEnabled
    public static List<StationTeamMember> getMemberDetails(Id recordId,Integer numLeader) {
        //System.debug('recordId: ' + recordId);
        //System.debug('numLeader: ' + numLeader);

        List<StationTeamMember> memberList= new List<StationTeamMember>();
        List<StationGroupingAssociation__c> userList1 =[SELECT Id,Order__c,Station_Content__r.Name,Station_Content__r.Org62_User__c, Station_Content__r.Job_Title__c
                                                        FROM StationGroupingAssociation__c
                                                        WHERE Station_Page__c = :recordId AND Order__c > :numLeader ORDER BY Order__c];
        //System.debug('userList: ' + userList1);

        for (Integer memberIndex = 0; memberIndex < userList1.size(); memberIndex++) {
            StationTeamMember stmr = new StationTeamMember();
            Id usr = userList1[memberIndex].Station_Content__r.Org62_User__c;
            //System.debug(usr);
            List<Org62_User__x> u = [SELECT FirstName__c,FullPhotoUrl__c,SmallPhotoUrl__c,ExternalId,LastName__c,Title__c FROM Org62_User__x WHERE Id=:usr LIMIT 1];
            String sImageURL = '';

            if (u.size() > 0) {
                sImageURL = u[0].FullPhotoUrl__c.replace('/F','/M');
                stmr.sImageURL=sImageURL;
                stmr.sTitle = u[0].FirstName__c + ' ' + u[0].LastName__c;
                //stmr.sSubTitle = u[0].Title__c;
                String title = userList1[memberIndex].Station_Content__r.Job_Title__c;
                if (String.isEmpty(title)) {
                    title = u[0].Title__c;
                }
                stmr.sSubTitle = title;
                stmr.sLink = u[0].ExternalId;
            } else {
                stmr.sImageURL = 'https://org62.lightning.force.com/img/setup/tiles/community-tile.png';
            }

            //system.debug('Station Team Member:'+JSON.serialize(stmr));
            memberList.add(stmr);
        }
        return memberList;
    }


    @AuraEnabled
    public static List<StationTeamMember> getLeaderDetails(Id recordId,Integer numLeader) {
        //System.debug('recordId: ' + recordId);
        //System.debug('numLeader: ' + numLeader);

        List<StationTeamMember> leaderList= new List<StationTeamMember>();
        List<StationGroupingAssociation__c> userList =[SELECT Id,Order__c,Station_Content__r.Name,Station_Content__r.Org62_User__c, Station_Content__r.Job_Title__c
                                                       FROM StationGroupingAssociation__c
                                                       WHERE Station_Page__c = :recordId AND Order__c < :numLeader+1
                                                       ORDER BY Order__c];

        //System.debug('userList: ' + userList);

        for (Integer leaderIndex=0; leaderIndex<userList.size(); leaderIndex++){
            StationTeamMember stmr= new StationTeamMember();
            Id usr = userList[leaderIndex].Station_Content__r.Org62_User__c;
            //system.debug(usr);
            List<Org62_User__x> u = [SELECT FirstName__c,FullPhotoUrl__c,SmallPhotoUrl__c,ExternalId,LastName__c,Title__c FROM Org62_User__x WHERE Id = :usr Limit 1];
            String sImageURL='';
            if (u.size()>0) {
                sImageURL=u[0].FullPhotoUrl__c.replace('/F','/M');
                stmr.sImageURL=sImageURL;
                stmr.sTitle=u[0].FirstName__c+' '+u[0].LastName__c;
                //stmr.sSubTitle=u[0].Title__c;
                String title = userList[leaderIndex].Station_Content__r.Job_Title__c;
                if (String.isEmpty(title)) {
                    title = u[0].Title__c;
                }
                stmr.sSubTitle = title;
                stmr.sLink=u[0].ExternalId;
            } else {
                stmr.sImageURL='https://org62.lightning.force.com/img/einstein/einstein_header_icon.svg';
            }
            //System.debug('Leader image URL: ' + stmr.sImageURL);
            //system.debug('Station Team Member:'+JSON.serialize(stmr));
            leaderList.add(stmr);
        }
        return leaderList;
    }
}