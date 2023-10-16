public with sharing class GDC_MS_ScoreCalculation {

    @AuraEnabled
    public static ScoreWrapper getCount(String strId) {
        List<gdc_ms_Question_Answer__c> lstTotalApplicable = new List<gdc_ms_Question_Answer__c>();
        Integer intAnsweredQ = 0;
        Integer intUnAnsweredQ = 0;
        Integer intFavourableQ = 0;
        Integer intUnFavourableQ = 0;
        Integer intApplicableQ = 0; 
        ScoreWrapper objScoreWrapper = new ScoreWrapper();
        List<gdc_ms_Question_Answer__c> lstQA = [SELECT Id, gdc_ms_Question__c, gdc_ms_Answer__c,gdc_ms_Question__r.gdc_ms_Type__c FROM gdc_ms_Question_Answer__c 
                                         			WHERE gdc_ms_Work_Intake_Form__c =: strId AND gdc_ms_Question__c != null];
        for(gdc_ms_Question_Answer__c objQA : lstQA) {
            if(objQA.gdc_ms_Answer__c != 'N/A') {
                lstTotalApplicable.add(objQA);
                intApplicableQ++;
            }
        }
        for(gdc_ms_Question_Answer__c objQA : lstTotalApplicable) {
            if(String.isBlank(objQA.gdc_ms_Answer__c) && objQA.gdc_ms_Question__r.gdc_ms_Type__c != 'Checkbox') {
                intUnAnsweredQ++;
            } else if(objQA.gdc_ms_Answer__c == 'No' || 
                      (objQA.gdc_ms_Answer__c != 'true'  && objQA.gdc_ms_Question__r.gdc_ms_Type__c == 'Checkbox')
                     ) {
                intUnFavourableQ++;
            } else {
                intFavourableQ++;
            }
        }
        intAnsweredQ = intApplicableQ-intUnAnsweredQ;
        objScoreWrapper.intScore = intAnsweredQ;
        objScoreWrapper.intApplicable = intApplicableQ;
        objScoreWrapper.intPercentage = (Integer)((((Decimal)intFavourableQ/intApplicableQ)*100).setScale(0));
        return objScoreWrapper;
     
    }
    
    public class ScoreWrapper {
        @Auraenabled public Integer intScore;
        @Auraenabled public Integer intApplicable;
        @Auraenabled public Integer intPercentage;
    } 
    
}