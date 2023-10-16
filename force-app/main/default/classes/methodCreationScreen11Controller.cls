public with sharing class methodCreationScreen11Controller {
    public methodCreationScreen11Controller() {
        
    }
    @AuraEnabled
    public static List<Method_by_Specialist_Cloud__c> getSpecialistCloudRecords(String methodRecordId){
        
        List<Method_by_Specialist_Cloud__c> methodBySpecialistCloudList = new List<Method_by_Specialist_Cloud__c>();
        if(!String.isBlank(methodRecordId)){
            methodBySpecialistCloudList = [Select Id, method__c, Specialist_Cloud__c, Specialist_Cloud__r.Name, Status__c from Method_by_Specialist_Cloud__c where method__c =:methodRecordId];
        }
        else{
            List<Specialist_Cloud__c> specialistCloudsList = [Select id, Name from Specialist_Cloud__c];
            for(Specialist_Cloud__c specialistCloud : specialistCloudsList){
                Method_by_Specialist_Cloud__c methodBySpecialistCloud = new Method_by_Specialist_Cloud__c();
                methodBySpecialistCloud.Specialist_Cloud__c = specialistCloud.Id;
                methodBySpecialistCloud.Specialist_Cloud_Name__c = specialistCloud.Name;
                methodBySpecialistCloud.Status__c  = 'Does not apply';
                methodBySpecialistCloudList.add(methodBySpecialistCloud);
            }
        }
        System.debug('methodBySpecialistCloudList'+methodBySpecialistCloudList);
        return methodBySpecialistCloudList;
    }
}