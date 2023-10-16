public without sharing class GDCMSWorkIntakeShare {
    
    @Auraenabled
    public static List<Id> workIntakeShare(List<Id> userIdList,Id recordId, String accessType) {
        List<Id> lstIdsfailed = new List<Id>();
        List<gdc_ms_Work_Intake_Form__Share> lstwifShare = new List<gdc_ms_Work_Intake_Form__Share>();
        List<gdc_ms_Question_Answer__Share> lstqueAnsShare = new List<gdc_ms_Question_Answer__Share>();
        Set<Id> setOfUserIds = new Set<Id>();
        List<Id> listIdsSuccess = new List<Id>();
        
        for (Id userId: userIdList) {
            gdc_ms_Work_Intake_Form__Share wifShare  = new gdc_ms_Work_Intake_Form__Share();
            wifShare.ParentId = recordId;
            wifShare.UserOrGroupId = userId;
            wifShare.AccessLevel = accessType;
            lstwifShare.add(wifShare);
        }
        
        
        Database.SaveResult[] srList = Database.insert(lstwifShare,false);
        
        for (Database.SaveResult sr : srList){
            if (!sr.isSuccess()){
                lstIdsfailed.add(sr.getId());
            }
            if(sr.isSuccess()){
              listIdsSuccess.add(sr.getId());
            }
        }
                
        for(gdc_ms_Work_Intake_Form__Share workIntakeShare : [Select Id,UserOrGroupId, ParentId from gdc_ms_Work_Intake_Form__Share where Id In:listIdsSuccess]){
           setOfUserIds.add(workIntakeShare.UserOrGroupId);
        }

        if(!setOfUserIds.isEmpty()){
          for(gdc_ms_Question_Answer__c que: [Select Id,Name,gdc_ms_Answer__c,gdc_ms_Question__c,
                                            gdc_ms_Question__r.gdc_ms_Question__c,
                                            gdc_ms_Question__r.gdc_ms_Type__c,gdc_ms_Comments__c,
                                            gdc_ms_Question__r.gdc_ms_Options__c
                                            from gdc_ms_Question_Answer__c where gdc_ms_Work_Intake_Form__c=: recordId]){
                                                
                                                for(Id userId: setOfUserIds){
                                                    gdc_ms_Question_Answer__Share queAnsShare = new gdc_ms_Question_Answer__Share();
                                                    queAnsShare.ParentId = que.Id;
                                                    queAnsShare.UserOrGroupId = userId;
                                                    queAnsShare.AccessLevel = accessType;
                                                    lstqueAnsShare.add(queAnsShare);
                                                }
                                            }
          Database.SaveResult[] quelist = Database.insert(lstqueAnsShare,false);
        }

        return lstIdsfailed;
    }
    
}