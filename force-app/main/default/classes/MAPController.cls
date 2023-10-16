/*------------------------------------------------------------------------------------
Author:        Sumit Gupta
Company:       Salesforce
Description:   MAP Controller

History
Date            Author             Comments
--------------------------------------------------------------------------------------
01-03-2018     Sumit Gupta       	Initial Release
------------------------------------------------------------------------------------*/

public with sharing class MAPController {

    @AuraEnabled
    public static String getPersonaData(String personaId){
        try{
            if(String.isBlank(personaId)) {
                throw new AuraHandledException('personaId is required to fetch persona data');
            }
            return JSON.serialize(MAPDataUtility.getPersonaData(personaId));
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String createNewAssessment(String customerId, String summary){
        try{
            if(String.isBlank(customerId)) {
                throw new AuraHandledException('customerId is required to create new assessment');
            }
            return JSON.serialize(MAPDataUtility.createNewAssessment(customerId, summary));
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String createNewInterview(String personaId, String assessmentId){
        try{
            if(String.isBlank(personaId) || String.isBlank(assessmentId)) {
                throw new AuraHandledException('personaId and assessmentId are required to create new interview');
            }
            return JSON.serialize(MAPDataUtility.createNewInterview(personaId, assessmentId));
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String saveInterview(String interviewJSONString){
        try{
            if(String.isBlank(interviewJSONString)) {
                throw new AuraHandledException('interviewJSONString is required to save interview');
            }
            MAPDataUtility.Interview interview = (MAPDataUtility.Interview)JSON.deserialize(interviewJSONString, MAPDataUtility.Interview.class);
            return JSON.serialize(MAPDataUtility.saveInterview(interview));
        } catch(Exception ex){
            system.debug(ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }
}