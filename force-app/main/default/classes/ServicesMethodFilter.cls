/*******************************************************************************************************
Name          : ServicesMethodFilter
:
@description  : Controller class that holds all the logic for Stage Landing Page feature
:
Revision Log  : 
:


********************************************************************************************************/
public with sharing class ServicesMethodFilter {
    
    
    
    /**
* @description fetch the data from UI initially while the component loads
* @param filterString - string containing stage filters
* @return wrapper list that holds the generated response for table
*/
    @AuraEnabled
    public static List<methodwithStageData> fetchData(string filter){
        Map<Id, List<Method_with_Stage__c>> methodWithStageMap = new Map<Id,List<Method_with_Stage__c>>();
        Map<Id, List<Method_by_Grouping__c>> methodWithGroupingMap = new Map<Id,List<Method_by_Grouping__c>>();
        Map<Id, List<Method_by_Deliverables__c>> methodWithDeliveryMap = new Map<Id,List<Method_by_Deliverables__c>>();
        List<methodwithStageData> methodWithStageDataList = new List<methodwithStageData>();
        List<Method_with_Stage__c> methodWithStageList = [SELECT id,Name, Stage__c,Stage__r.Name, Method__c, Method__r.Name, Method__r.Waterfall__c, Method__r.Agile__c,Method__r.Micro__c,Method__r.Small__c,Method__r.Medium__c,Method__r.Large__c,Method__r.Tier_1__c,Method__r.Tier_2__c,Method__r.Program__c,Method__r.Method_Number__c  
                                                          FROM Method_with_Stage__c where Stage__r.Name =:filter];
        
        for(Method_with_Stage__c methodStg :methodWithStageList ){
            methodWithStageMap.put(methodStg.Method__c, new List<Method_with_Stage__c>{methodStg});
        }
        List<Method_by_Grouping__c> methodGroupingList = [SELECT id, Name, Method__c, Grouping__c, Grouping__r.Name FROM Method_by_Grouping__c 
                                                          WHERE Method__c in :methodWithStageMap.keySet()];
        for(Method_by_Grouping__c methodGrp :methodGroupingList ){
            if(!methodWithGroupingMap.containsKey(methodGrp.Method__c)){
                methodWithGroupingMap.put(methodGrp.Method__c, new List<Method_by_Grouping__c>{methodGrp});
            }
            else{
                methodWithGroupingMap.get(methodGrp.Method__c).add(methodGrp);
            }
        }
        List<Method_by_Deliverables__c> methodDeliveryList = [SELECT id,Owner.Name, Name, Method__c,Deliverable__r.Name FROM Method_by_Deliverables__c 
                                                              WHERE Method__c in :methodWithStageMap.keySet()];
        for(Method_by_Deliverables__c methodDlvry :methodDeliveryList ){
            if(!methodWithDeliveryMap.containsKey(methodDlvry.Method__c)){
                methodWithDeliveryMap.put(methodDlvry.Method__c, new List<Method_by_Deliverables__c>{methodDlvry});
            }
            else{
                methodWithDeliveryMap.get(methodDlvry.Method__c).add(methodDlvry);
            }
        }
        for(Method_with_Stage__c methodStg :methodWithStageList){
            methodwithStageData methodStageData = new methodwithStageData();
            methodStageData.stage = methodStg.Stage__r.Name;
            methodStageData.methodNumber = methodStg.Method__r.Method_Number__c;
            methodStageData.methodName = methodStg.Method__r.Name;
            methodStageData.methodNameUrl = '/'+methodStg.Method__r.Id;
            methodStageData.waterfall = methodStg.Method__r.Waterfall__c;
            methodStageData.agile = methodStg.Method__r.Agile__c;
            methodStageData.micro = methodStg.Method__r.Micro__c;
            methodStageData.small = methodStg.Method__r.Small__c;
            methodStageData.medium = methodStg.Method__r.Medium__c;
            methodStageData.large = methodStg.Method__r.Large__c;
            methodStageData.program = methodStg.Method__r.Program__c ;
            methodStageData.tier1 = methodStg.Method__r.Tier_1__c ;
            methodStageData.tier2 = methodStg.Method__r.Tier_2__c ;
            
            if(methodWithGroupingMap.containskey(methodStg.Method__c)){
                for(Method_by_Grouping__c methodGrouping :methodWithGroupingMap.get(methodStg.Method__c)){
                    
                    methodStageData.grouping = (methodStageData.grouping !=null)? methodGrouping.Grouping__r.Name +', '+methodStageData.grouping : methodGrouping.Grouping__r.Name;
                    
                }
            }
            if(methodWithDeliveryMap.containsKey(methodStg.Method__c)){
                for(Method_by_Deliverables__c methodDelivery :methodWithDeliveryMap.get(methodStg.Method__c)){
                    
                    methodStageData.deliveryOwnerRole = (methodStageData.deliveryOwnerRole !=null)? methodDelivery.Deliverable__r.Name +', '+methodStageData.deliveryOwnerRole : methodDelivery.Deliverable__r.Name;
                }
            }
            methodWithStageDataList.add(methodStageData);
        }
        
        return methodWithStageDataList;
        
    }
    
    /**
* @description - Wrapper class for datatable columns.
*/
    
    public class methodwithStageData {
        /**
* @description - specifies the name of the field for the Label
*/
        @AuraEnabled
        public String Stage {get;set;}
        @AuraEnabled
        public Decimal methodNumber {get;set;}
        @AuraEnabled
        public String methodName {get;set;}
        @AuraEnabled
        public String methodNameUrl {get;set;}
        @AuraEnabled
        public String grouping {get;set;}
        @AuraEnabled
        public String deliveryOwnerRole {get;set;}
        @AuraEnabled
        public boolean waterfall {get;set;}
        @AuraEnabled
        public boolean agile {get;set;}
        @AuraEnabled
        public String micro {get;set;}
        @AuraEnabled
        public String small {get;set;}
        @AuraEnabled
        public String medium {get;set;}
        @AuraEnabled
        public String large {get;set;}
        @AuraEnabled
        public String program {get;set;}
        @AuraEnabled
        public String tier1 {get;set;}
        @AuraEnabled
        public String tier2 {get;set;}
    }
    
}