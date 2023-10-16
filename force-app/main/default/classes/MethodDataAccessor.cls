public with sharing class MethodDataAccessor implements MethodDAI {
    public Method__c getMethodByMethodId(Id methodId) {
        Method__c method = [
            SELECT Name, Method_Number__c, Waterfall__c, Agile__c, Large__c, Medium__c, Small__c, Micro__c, Program__c, Tier_1__c
            FROM Method__c 
            WHERE Id = :methodId 
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        method.Large__c = convertUseFieldToEmoji(method.Large__c);
        method.Medium__c = convertUseFieldToEmoji(method.Medium__c);
        method.Small__c = convertUseFieldToEmoji(method.Small__c);
        method.Micro__c = convertUseFieldToEmoji(method.Micro__c);
        method.Program__c = convertUseFieldToEmoji(method.Program__c);
        method.Tier_1__c = convertUseFieldToEmoji(method.Tier_1__c);
        return method;
    }

    public Method__c[] getMethodListByMethodIds(Set<Id> methodIds) {
        return [
            Select Id, Name, Community_URL__c  FROM Method__c 
            WHERE Id IN :methodIds
        ];
    }
    
    private String convertUseFieldToEmoji(String useField) {
        switch on useField {
            when 'Won\'t Use' {
                return ':wont-use:';
            }
            when 'Nice to Use' {
                return ':nice-to-use:';
            }
            when 'Should Use' {
                return ':should-use:';
            }
            when 'Must Use' {
                return ':must-use:';
            }
            when else {
                return '';
            }
        }
    }
}