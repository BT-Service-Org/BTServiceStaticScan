public with sharing class GDC_MS_QuestionAnswerFormController {
    @AuraEnabled
    public static list<gdc_ms_Question__c> getQuestions(String objectName) {
        
        String category='';
        
        String objName = objectName.replace('__c','');
        List<gdc_ms_FormCategoryMapping__mdt> listOfCS = [SELECT Id,gdc_ms_Category__c,developerName
                                                          FROM gdc_ms_FormCategoryMapping__mdt
                                                          where developerName=: objName];
        
        
        if(!listOfCS.isEmpty()){
            category = listOfCS[0].gdc_ms_Category__c;
        }
        
        try{
            if(String.isNotBlank(category)){
                return [Select Id,Name,gdc_ms_Options__c,gdc_ms_Type__c,
                        gdc_ms_Question__c,gdc_ms_Required__c,gdc_ms_Category__c 
                        from gdc_ms_Question__c 
                        where gdc_ms_Category__c=:category AND 
                        gdc_ms_Is_Active__c=true ORDER BY gdc_ms_Order__c ];
            }
            else{
                return null;
            }
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String createRecords(String records, String engagementName, String workIntakeFormId) {
        try{
            String externalId;
            list<ObjRecords> listOfRecords = (list<ObjRecords>) JSON.deserialize(records, list<ObjRecords>.class);
            
            List<Sobject> listOfsObject = new list<Sobject>();
            List<Sobject> objListForQueAns = new list<Sobject>();
            Boolean showRecords= false;
            
            
            gdc_ms_Work_Intake_Form__c newWorkIntakeForm = new gdc_ms_Work_Intake_Form__c();
            if(workIntakeFormId != null){
                newWorkIntakeForm.Id = workIntakeFormId;
                if(!engagementName?.equals(newWorkIntakeForm.Name)){
                    newWorkIntakeForm.Name = engagementName;
                    listOfsObject.add(newWorkIntakeForm);
                }
            }else{
            	newWorkIntakeForm.Name= engagementName;
                externalId = String.valueOf(System.now());
                newWorkIntakeForm.gdc_ms_External_Id__c = externalId;
                insert newWorkIntakeForm;
                workIntakeFormId = newWorkIntakeForm.Id;
            	//listOfsObject.add(newWorkIntakeForm);
            }
            
            for(ObjRecords obj:listOfRecords){
                gdc_ms_Question_Answer__c queAns = new gdc_ms_Question_Answer__c(
                    gdc_ms_Answer__c= obj.value,
                    gdc_ms_Question__c= obj.label,
                    gdc_ms_Comments__c=obj.comments
                );
                if(String.isNotBlank(obj.questionAnswerId)){
                    queAns.Id = obj.questionAnswerId;
                }
                
                if(String.isNotBlank(workIntakeFormId)){
                	queAns.gdc_ms_Work_Intake_Form__c = workIntakeFormId;
                }/*else{
                  	gdc_ms_Work_Intake_Form__c workIntakeform = new gdc_ms_Work_Intake_Form__c(gdc_ms_External_Id__c = externalId);  
        			queAns.gdc_ms_Work_Intake_Form__r = workIntakeform;
                }*/               
                objListForQueAns.add(queAns);
            }
            
            listOfsObject.addAll(objListForQueAns);
            
            Database.upsertResult[] results = Database.upsert(listOfsObject);
            
            for (Database.upsertResult sr : results) {
                if (sr.isSuccess()) {
                    showRecords=true;
                    if(sr.isCreated()){
                    	System.debug(sr.getId() + ' was created');
                    } else {
                        System.debug(sr.getId() + ' was updated');
                	}
                }
                
            }
            
            if(showRecords){
                if(String.isNotBlank(workIntakeFormId)){
                	return workIntakeFormId;
                }else{
                    return null;
                }
            }else{
                return null;
            }
        }catch(Exception ex){
            System.debug('Error Occurred in creating records '+ex.getMessage() + ' ' + ex.getStackTraceString());
            throw new CustomException('Error Occurred in creating records '+ex.getMessage());
            //return ex.getMessage();
        }
    }
    
    @AuraEnabled
    public static gdc_ms_Work_Intake_Form__c  getQuestionAnswers(String recordId){
        
        list<gdc_ms_Question_Answer__c> questionAnswerList = new list<gdc_ms_Question_Answer__c>();
        
        
        gdc_ms_Work_Intake_Form__c  workIntake =[Select Id,Name,CreatedBy.FirstName,
                                                 CreatedBy.LastName,CreatedById,
                                                 (Select Id,Name,gdc_ms_Answer__c,gdc_ms_Question__c,
                                                  gdc_ms_Question__r.gdc_ms_Question__c,
                                                  gdc_ms_Question__r.gdc_ms_Type__c,gdc_ms_Comments__c,
                                                  gdc_ms_Question__r.gdc_ms_Options__c
                                                  from Question_Answers__r 
                                                  where gdc_ms_Question__c!=null ORDER BY gdc_ms_Question__r.gdc_ms_Order__c)
                                                 from gdc_ms_Work_Intake_Form__c 
                                                 where Id=:recordId WITH SECURITY_ENFORCED LIMIT 1];
        
        
        if(workIntake!=null){
            return workIntake;
        }
        else{
            return null;
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static ListView getListViewId(String objectApiName){
        return[SELECT Id, Name, DeveloperName, SobjectType
               FROM ListView 
               WHERE SobjectType = :objectApiName AND DeveloperName='All' LIMIT 1];
    }
    
    public class ObjRecords {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String comments;
        @AuraEnabled public String questionAnswerId;
    }
    
}