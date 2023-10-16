public with sharing class PSCMethodCardService {
    public static List<Method__C> getValue(List<String> key) {
        List<String> strList = new List<String>();
        List<Decimal> dcmlList = new List<Decimal>();
        for(String each:key){
            if(each.isNumeric()){
                dcmlList.add(decimal.valueOf(each));
            }
            else{
                strList.add(each);
                strList.add(each.replace(' and ',' & '));
            }
        }

        List<Method__C> methodData = [SELECT Name, Ownership__r.FirstName,Ownership__r.LastName, Method_Headline__c, Agile__c, 
                                    Waterfall__c, Method_Number__c, Micro__c, Small__c, Medium__c, 
                                    Large__c, Program__c, Tier_1__c,Tier_2__c,Description__c,Community_URL__c,
                                        (SELECT Grouping__r.Name 
                                        FROM Method_by_Grouping__r 
                                        LIMIT 3), 
                                        (SELECT Stage__r.Name 
                                        FROM Method_with_Stages__r 
                                        LIMIT 3),
                                        (SELECT Id, Product__r.Name, Role__r.Name
                                        FROM Method_Ownerships_by_Product__r
                                        WHERE Product__r.RecordType.DeveloperName = 'Service_Offering')
                                    FROM Method__C 
                                    WHERE (Method_Number__c IN :dcmlList
                                    OR Name IN :strList)
                                    AND Status__c = 'Published'];

        return methodData;
    }

    public static String getMethodId(String key) {
        List<String> strList = new List<String>();
        Decimal methodNumber;
        if(key.isNumeric()){
            methodNumber = decimal.valueOf(key);
        } else{
            strList.add(key);
            strList.add(key.replace(' and ',' & '));
        }
        String methodData = [SELECT Id 
                            FROM Method__C 
                            WHERE (Method_Number__c = :methodNumber
                            OR Name IN :strList)
                            AND Status__c = 'Published'
                            LIMIT 1]?.Id;

        return methodData;
    }
}