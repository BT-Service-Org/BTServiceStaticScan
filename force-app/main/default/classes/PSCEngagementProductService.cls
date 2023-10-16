public with sharing class PSCEngagementProductService {
    public static List<Product_Custom__c> getValue(List<String> keyList, String recordTypeName) {
        Decimal methodNumber;
        for(String key:keyList){
            if(key.isNumeric()){
                methodNumber = decimal.valueOf(key);
            }
        }
        List<Product_Custom__c> productData = [SELECT Name, Special_Considerations_Apply__c,
                                                    (SELECT Method__r.Name 
                                                    FROM Method_Ownerships_by_Product__r 
                                                    WHERE Method__r.Method_Number__c=:methodNumber
                                                    OR Method__r.Name IN :keyList) 
                                                FROM Product_Custom__c 
                                                WHERE recordType.Name =:recordTypeName
                                                ];

        return productData;
    }

    public static List<Industry__c> getIndustryValue(List<String> keyList) {
        Decimal methodNumber;
        for(String key:keyList){
            if(key.isNumeric()){
                methodNumber = decimal.valueOf(key);
            }
        }
        List<Industry__c> industryData = [SELECT Name,
                                            (SELECT Method__r.Name 
                                            FROM Method_Industries__r 
                                            WHERE Method__r.Method_Number__c=:methodNumber
                                            OR Method__r.Name IN :keyList) 
                                        FROM Industry__c 
                                        ];

        return industryData;
    }

    public static List<Specialist_Cloud__c> getSplCloudValue(List<String> keyList) {
        Decimal methodNumber;
        for(String key:keyList){
            if(key.isNumeric()){
                methodNumber = decimal.valueOf(key);
            }
        }
        List<Specialist_Cloud__c> splCloudData = [SELECT Name,
                                                    (SELECT Method__r.Name ,Status__c
                                                    FROM Method_by_Specialist_Clouds__r 
                                                    WHERE Method__r.Method_Number__c=:methodNumber
                                                    OR Method__r.Name IN :keyList) 
                                                FROM Specialist_Cloud__c 
                                                ];

        return splCloudData;
    }
}