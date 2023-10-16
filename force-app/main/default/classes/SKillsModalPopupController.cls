/**
Class Name : SKillsModalPopupController
@description    : This is the controller class for the SkillsModalPopup lwc component
Created Date	: June 9th, 2022  
*/
public with sharing class SKillsModalPopupController {
    /**
    Method Name  : getLearningResourceRecs
    @description : This method is to pull the learning Resource skills of a CSGprofileskill record
    @return      : List<Learning_Resource_Skill__c>
    @param parentid - CSGProfileSkill id
    */
    @AuraEnabled(cacheable=true)
    public static List<Learning_Resource_Skill__c> getLearningResourceRecs(String parentid) {
        List<Learning_Resource_Skill__c> lrList = new List<Learning_Resource_Skill__c>();
        Id parentRecId = Id.valueOf(parentid);
        try{
            lrList = [SELECT Id, Learning_Resource__c,Learning_Resource__r.name, Learning_Resource__r.Duration__c, Learning_Resource__r.Link__c, Learning_Resource__r.Source__c
                                                            FROM Learning_Resource_Skill__c WHERE CSGProfileSkill__c=:parentRecId WITH SECURITY_ENFORCED];
            
        }Catch(Exception ex){
                System.debug(logginglevel.ERROR,'Error occured is'+ex.getMessage()); // NOPMD
                
            }
        
        return lrList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Learning_Resource_Skill__c> getAllLearningResourceRecs() {
        List<Learning_Resource_Skill__c> lrList = new List<Learning_Resource_Skill__c>();
       
            try{
                
                lrList = [SELECT Id, Learning_Resource__c,Learning_Resource__r.Name, Learning_Resource__r.Duration__c, Learning_Resource__r.Link__c, Learning_Resource__r.Source__c,
                          Learning_Resource__r.Description__c,CSGProfileSkill__r.Category__c,CSGProfileSkill__r.Type__c,CSGProfileSkill__r.Name
                                                            FROM Learning_Resource_Skill__c WITH SECURITY_ENFORCED];
            
            
            }Catch(Exception ex){
                System.debug(logginglevel.ERROR,'Error occured is'+ex.getMessage()); // NOPMD
                
        }
        return lrList;
    }
}