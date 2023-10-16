public with sharing class PSCImportantNoteCtrl {
    @AuraEnabled(Cacheable=true)
    public static List<Method__C> getImportantNoteText(Double key) {
        
        List<Method__C> importantNoteText = [SELECT Method_Notification_Box__c, Name FROM Method__C
                                             WHERE Method_Number__c =:key
                                             AND Status__c = 'Published'];

        return importantNoteText;
    }
}