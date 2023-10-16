/**
* @author: Rohan Saxena
* @description: This is a handler class for ContributionTeamTrigger
*/
public without sharing class ContributionTeamTriggerHandler {
    /* Constant Start*/
    public static final String  LEADER = 'Leader';
    static final String  EDIT = 'Edit';
    static final String  MANUAL = 'Manual';
    public static Id COMMUNITY_RECORD_TYPE = Schema.SObjectType.Contribution_Team__c.getRecordTypeInfosByName().get('Community of Practice').getRecordTypeId();
    static final set<String> PS_NAME= new set<String>{'Services_Central_Community_Admin', 'Services_Central_Page_Base'};
        /* Constant End*/
        
        public static void shareQuestionwithLeaders(List<Contribution_Team__c> newlst){
            try{
                List<PSC_Page__Share> lstPageshare = new List<PSC_Page__Share>();
                for(Contribution_Team__c CT : newlst){
                    if(CT.psc_Role__c == LEADER && CT.psc_Team_Member__c != null && CT.Community__c != null && CT.RecordTypeId ==COMMUNITY_RECORD_TYPE && CT.Community_Owner__c){
                        lstPageshare.add(getPageShare(CT.Community__c, CT.psc_Team_Member__c));
                    }
                }
                if(!lstPageshare.isEmpty()){
                    insert lstPageshare;
                }
            }
            catch(Exception ex){
                throw new PSCException(ex.getMessage());
            }
            
        }
    
    public static void shareCTwithLeaders(List<Contribution_Team__c> newlst){
        try{
            Map<Id, List<Id>> communityAndUsers= new Map<Id, List<Id>>();
            Map<Id, Id> communityAndMemberUsers= new Map<Id, Id>();
            List<Contribution_Team__Share> lstCTshare = new List<Contribution_Team__Share>();
            for(Contribution_Team__c CT : newlst){
                if(CT.psc_Role__c == LEADER && CT.psc_Team_Member__c != null && CT.Community__c != null && CT.RecordTypeId ==COMMUNITY_RECORD_TYPE ){
                    if (communityAndUsers.containsKey(CT.Community__c)){
                        communityAndUsers.get(CT.Community__c).add(CT.psc_Team_Member__c);
                    }
                    else{
                        communityAndUsers.put(CT.Community__c, new  List <Id> { CT.psc_Team_Member__c });
                    }
                    communityAndMemberUsers.put(CT.Id,CT.Community__c);
                }
                else if(CT.psc_Role__c != LEADER && CT.psc_Team_Member__c != null && CT.Community__c != null && CT.RecordTypeId ==COMMUNITY_RECORD_TYPE){
                    communityAndMemberUsers.put(CT.Id,CT.Community__c);
                }
            }
            if(communityAndUsers != null && !communityAndUsers.isEmpty()){
                for(Contribution_Team__c existingCT:  [SELECT Id,Community__c,psc_Team_Member__c,RecordTypeId FROM Contribution_Team__c WHERE Community__c IN: communityAndUsers.keySet()
                                                       AND psc_Team_Member__c != null 
                                                       AND RecordTypeId =:COMMUNITY_RECORD_TYPE]){
                                                           lstCTshare.addAll(getCTShare(existingCT.Id, communityAndUsers.get(existingCT.Community__c)));
                                                       }
            }
            
            if(communityAndMemberUsers != null && !communityAndMemberUsers.isEmpty()){
                List<Contribution_Team__c> lstCTLeaders = [SELECT Id,Community__c,psc_Team_Member__c,RecordTypeId,psc_Role__c FROM Contribution_Team__c WHERE Community__c IN: communityAndMemberUsers.values() AND psc_Team_Member__c != null AND RecordTypeId =:COMMUNITY_RECORD_TYPE AND psc_Role__c =:LEADER];
                if(!lstCTLeaders.isEmpty()){
                    List<Id> CTLeadersId = new List<Id>();
                    for(Contribution_Team__c CT:lstCTLeaders ){
                        CTLeadersId.add(CT.psc_Team_Member__c);
                    }
                    for(Contribution_Team__c CT : newlst){
                        if(CT.psc_Role__c != LEADER && CT.psc_Team_Member__c != null && CT.Community__c != null && CT.RecordTypeId ==COMMUNITY_RECORD_TYPE){
                            lstCTshare.addAll(getCTShare(CT.Id, CTLeadersId));
                        }
                    }
                }
            }
            if(!lstCTshare.isEmpty()){
                Database.insert( lstCTshare,false);
            }
        }
        catch(Exception ex){
            throw new PSCException(ex.getMessage());
        }
        
    }
    
    public static void unShareQuestionwithLeaders(List<Contribution_Team__c> oldlst){
        try{
            List<PSC_Page__Share> lstpageshare = new List<PSC_Page__Share>();
            Map<Id,Id> userAndPage = new Map<Id,Id>();
            for(Contribution_Team__c CT : oldlst){
                if(CT.psc_Role__c == LEADER && CT.psc_Team_Member__c != null && CT.Community__c != null && CT.RecordTypeId ==COMMUNITY_RECORD_TYPE){
                    userAndPage.put(CT.psc_Team_Member__c, CT.Community__c);
                }
            }
            for(PSC_Page__Share pageShare: [SELECT Id, ParentId, UserOrGroupId, AccessLevel,RowCause FROM PSC_Page__Share WHERE UserOrGroupId IN: userAndPage.keySet() AND ParentId IN:userAndPage.values()] ){
                for(Id userID: userAndPage.keySet()){
                    if(userID == pageShare.UserOrGroupId && userAndPage.get(userID)==pageShare.ParentId && pageShare.AccessLevel==EDIT && pageShare.RowCause==MANUAL){
                        lstpageshare.add(pageShare);
                    }
                }
            }
            if(!lstpageshare.isEmpty()){
                delete lstpageshare;
            }
        }
        catch(Exception ex){
            throw new PSCException(ex.getMessage());
        }
        
    }
    
    public static void unShareCTwithLeaders(List<Contribution_Team__c> oldlst){
        try{
            List<Contribution_Team__Share> lstCTshare = new List<Contribution_Team__Share>();
            Map<Id,Id> userAndPage = new Map<Id,Id>();
            for(Contribution_Team__c CT : oldlst){
                if(CT.psc_Role__c == LEADER && CT.psc_Team_Member__c != null && CT.Community__c != null && CT.RecordTypeId ==COMMUNITY_RECORD_TYPE){
                    userAndPage.put(CT.psc_Team_Member__c, CT.Community__c);
                }
            }
            for(Contribution_Team__Share CTShare: [SELECT Id, ParentId,Parent.Community__c, UserOrGroupId, AccessLevel,RowCause FROM Contribution_Team__Share WHERE Parent.Community__c IN:userAndPage.values()] ){
                for(Id userID: userAndPage.keySet()){
                    if(userID == CTShare.UserOrGroupId && userAndPage.get(userID)==CTShare.Parent.Community__c && CTShare.AccessLevel==EDIT && CTShare.RowCause==MANUAL){
                        lstCTshare.add(CTShare);
                    }
                }
            }
            if(!lstCTshare.isEmpty()){
                delete lstCTshare;
            }
        }
        catch(Exception ex){
            throw new PSCException(ex.getMessage());
        }
        
    }
    
    public static void shareAndUnshareRecords(Map<Id, Contribution_Team__c> newMap, Map<Id, Contribution_Team__c> oldMap){
        try{
            List<Contribution_Team__c> lstCtShare = new List<Contribution_Team__c>();
            List<Contribution_Team__c> lstCtUnShare = new List<Contribution_Team__c>();
            for(Contribution_Team__c CT: newMap.values()){
                if(CT.Community__c != null && CT.RecordTypeId ==COMMUNITY_RECORD_TYPE){
                    if((CT.psc_Team_Member__c != oldMap.get(CT.Id).psc_Team_Member__c || CT.psc_Role__c != oldMap.get(CT.Id).psc_Role__c ) && CT.psc_Role__c == LEADER ){
                        //sharing page with new team members
                        lstCtShare.add(CT);
                        //unshare page with old team members
                        lstCtUnShare.add(oldMap.get(CT.Id));
                    }
                    else if(oldMap.get(CT.Id).psc_Role__c==LEADER &&  CT.psc_Role__c != oldMap.get(CT.Id).psc_Role__c && CT.psc_Role__c != LEADER){
                        //unshare page with old team members
                        lstCtUnShare.add(oldMap.get(CT.Id));
                    }
                }
            }
            if(!lstCtShare.isEmpty()){
                shareQuestionwithLeaders(lstCtShare);
                shareCTwithLeaders(lstCtShare);
            }
            if(!lstCtUnShare.isEmpty()){
                unShareQuestionwithLeaders(lstCtUnShare);
                unShareCTwithLeaders(lstCtUnShare);
            }
        }catch(Exception ex){
            throw new PSCException(ex.getMessage());
        }
    }
    
    public static PSC_Page__Share getPageShare(Id pageId, Id userId){
        PSC_Page__Share objpageshare = new PSC_Page__Share();
        objpageshare.ParentId = pageId;
        objpageshare.UserOrGroupId = userId;
        objpageshare.AccessLevel = EDIT;
        objpageshare.RowCause = MANUAL;
        return objpageshare;
    }
    
    public static List<Contribution_Team__Share> getCTShare(Id ctId, List<Id> userId){
        List<Contribution_Team__Share> lstShareCT = new List<Contribution_Team__Share>();
        for(Id ctUSerID: userId){
            Contribution_Team__Share objCTshare = new Contribution_Team__Share();
            objCTshare.ParentId = ctId;
            objCTshare.UserOrGroupId = ctUSerID;
            objCTshare.AccessLevel = EDIT;
            objCTshare.RowCause = MANUAL;
            lstShareCT.add(objCTshare);
        }
        return lstShareCT;
    }
    
    //Future method because of Mixed DML Error (Setup & Non-Setup object)
    @future
    public static void addPermissionSet(String strContributionTeam){
        List<Contribution_Team__c> newlst = (List<Contribution_Team__c>)JSON.deserialize(strContributionTeam, List<Contribution_Team__c>.class);
        Id Page_Base;
        Id Community_Admin;
        for(PermissionSet PS: [SELECT Id, Name FROM PermissionSet WHERE Name IN :PS_NAME]){
            if(PS.Name=='Services_Central_Community_Admin'){
                Community_Admin=PS.Id;
            }
            else if(PS.Name=='Services_Central_Page_Base'){
                Page_Base=PS.Id;
            }
        }
        List<PermissionSetAssignment> lstPermissionSetAssignment = new List<PermissionSetAssignment>();
        for(Contribution_Team__c CT: newlst){
            if(CT.psc_Role__c == LEADER && CT.psc_Team_Member__c != null && CT.Community__c != null && CT.RecordTypeId ==COMMUNITY_RECORD_TYPE){
                PermissionSetAssignment BaseAssignment = new PermissionSetAssignment();
                BaseAssignment.PermissionSetId = Page_Base;
                BaseAssignment.AssigneeId = CT.psc_Team_Member__c;
                PermissionSetAssignment communityAssignment = new PermissionSetAssignment();
                communityAssignment.PermissionSetId = Community_Admin;
                communityAssignment.AssigneeId = CT.psc_Team_Member__c;
                lstPermissionSetAssignment.add(communityAssignment);
                lstPermissionSetAssignment.add(BaseAssignment);
            }
        }
        if(!lstPermissionSetAssignment.isEmpty()){
            Database.insert(lstPermissionSetAssignment, false);
        }
    }
    
    public static void addAndRemovePermissionSet(List<Contribution_Team__c> newlst, Map<Id,Contribution_Team__c> oldMap){
        List<Contribution_Team__c> sharePermissionCTlst = new List<Contribution_Team__c>();
        List<Contribution_Team__c> unsharePermissionCTlst = new List<Contribution_Team__c>();
        for(Contribution_Team__c CT: newlst){
            if(CT.Community__c != null && CT.RecordTypeId ==COMMUNITY_RECORD_TYPE){
                if(CT.psc_Role__c == LEADER && CT.psc_Role__c != oldMap.get(CT.Id).psc_Role__c && CT.psc_Team_Member__c != null){
                    sharePermissionCTlst.add(CT);
                }
                else if(oldMap.get(CT.Id).psc_Role__c==LEADER &&  CT.psc_Role__c != oldMap.get(CT.Id).psc_Role__c && CT.psc_Role__c != LEADER){
                    unsharePermissionCTlst.add(oldMap.get(CT.Id));
                }
            }
        }
        if(!sharePermissionCTlst.isEmpty()){
            addPermissionSet(JSON.serialize(sharePermissionCTlst));
        }
        if(!unsharePermissionCTlst.isEmpty()){
            removePermissionSet(JSON.serialize(unsharePermissionCTlst));
        }
    }
    @future
    public static void removePermissionSet(String strContributionTeam){
        List<Contribution_Team__c> oldlst= (List<Contribution_Team__c>)JSON.deserialize(strContributionTeam, List<Contribution_Team__c>.class);
        set<Id> teamMemberId = new set<Id>();
        for(Contribution_Team__c CT: oldlst){
            if(CT.psc_Role__c == LEADER && CT.psc_Team_Member__c != null && CT.Community__c != null && CT.RecordTypeId ==COMMUNITY_RECORD_TYPE){
                teamMemberId.add(CT.psc_Team_Member__c);
            }
        }
        //SC-1217
        for(Contribution_Team__c CheckLeaderinAnotherPage : [SELECT Id,psc_Team_Member__c from Contribution_Team__c
                                                                                             WHERE RecordTypeId =:COMMUNITY_RECORD_TYPE 
                                                                                             AND Community__c != null 
                                                                                             AND psc_Role__c =: LEADER
                                                                                             AND psc_Team_Member__c IN:teamMemberId]){
             if(teamMemberId.contains(CheckLeaderinAnotherPage.psc_Team_Member__c)){
                teamMemberId.remove(CheckLeaderinAnotherPage.psc_Team_Member__c);
             }
        }
        List<PermissionSetAssignment> lstPermissionsetAssgn=   [SELECT Id FROM PermissionSetAssignment where AssigneeId IN:teamMemberId AND PermissionSet.name IN: PS_NAME];
        if(!lstPermissionsetAssgn.isEmpty()){
            Delete lstPermissionsetAssgn;
        }
        
    }
}