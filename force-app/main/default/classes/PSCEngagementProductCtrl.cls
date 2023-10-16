public with sharing class PSCEngagementProductCtrl {
    @AuraEnabled(Cacheable=true)
    public static EnagagementWrapperParent getProductData(String key, String recordTypeName, String title , String statImgPath) {
        List<String> keyList = new List<String>();
        Decimal methodNumber;
        if(key.isNumeric()){
            methodNumber = decimal.valueOf(key);
            keyList.add(key);
        }
        else{
            keyList.add(key);
            keyList.add(key.replace(' and ',' & '));
        }
        String fallbackIconPath = '/product/Core.png';
        Map<String,String> mapOfProdToImg = new Map<String,String>{
            'core'=>'/engagement-product/badge-stages-deploy.png'
        };
        EnagagementWrapperParent engagementList = new EnagagementWrapperParent();
        List<EnagagementWrapper> trueValueList = new List<EnagagementWrapper>();
        List<EnagagementWrapper> falseValueList = new List<EnagagementWrapper>();
        List<EnagagementWrapper> maybeValueList = new List<EnagagementWrapper>();

        if(recordTypeName=='Product'||recordTypeName=='Service Offering'){
            List<Product_Custom__c> productList = PSCEngagementProductService.getValue(keyList,recordTypeName);

            for(Product_Custom__c each:productList){
                EnagagementWrapper enagagementWrapperObj = new EnagagementWrapper();
                enagagementWrapperObj.productName = each.Name;
                if(each?.Method_Ownerships_by_Product__r.size()>0 && each.Special_Considerations_Apply__c){
                    maybeValueList.add(enagagementWrapperObj);
                }
                else if(each?.Method_Ownerships_by_Product__r.size()>0 && !each.Special_Considerations_Apply__c){
                    trueValueList.add(enagagementWrapperObj);
                }
                else{
                    falseValueList.add(enagagementWrapperObj);
                }
            }
            engagementList.imagePathData = PSCSettingService.getValue('Product_Offering_Images'); 
        }
        else if(title=='Specialized Resources'){
            Schema.DescribeSObjectResult objSchema = Method__c.sObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
            List<Schema.Picklistentry>fld =fieldmap.get('Specialized_Resources__c').getDescribe().getpicklistValues();
            
            List<String> pickList = new List<String>();

            for(Schema.Picklistentry pl : fld)
            {
                pickList.add(pl.getValue());
            }
 
            String selectedResource = [SELECT Specialized_Resources__c
                                        FROM Method__c
                                        WHERE (Method_Number__c =: methodNumber
                                        OR Name IN :keyList)
                                        AND Status__c = 'Published'
                                        LIMIT 1]?.Specialized_Resources__c;

            if(selectedResource != null && selectedResource != ''){
                List<String> selectedValueList = selectedResource.split(';');
                for(String eachValue:pickList){
                    EnagagementWrapper enagagementWrapperObj = new EnagagementWrapper();
                    enagagementWrapperObj.productName = eachValue;
                    enagagementWrapperObj.productImg = statImgPath + (mapOfProdToImg.containsKey(eachValue)?mapOfProdToImg.get(eachValue):fallbackIconPath);
                    if(selectedValueList.contains(eachValue)){
                        trueValueList.add(enagagementWrapperObj);
                    }
                    else{
                        falseValueList.add(enagagementWrapperObj);
                    }
                }
            }
            else{
                for(String eachValue:pickList){
                    EnagagementWrapper enagagementWrapperObj = new EnagagementWrapper();
                    enagagementWrapperObj.productName = eachValue;
                    enagagementWrapperObj.productImg = statImgPath + (mapOfProdToImg.containsKey(eachValue)?mapOfProdToImg.get(eachValue):fallbackIconPath);
                    falseValueList.add(enagagementWrapperObj);
                }
            }
            engagementList.imagePathData = PSCSettingService.getValue('Product_Offering_Images'); 
        }
        else if(title=='Industries'){
            List<Industry__c> industryList = PSCEngagementProductService.getIndustryValue(keyList);
            for(Industry__c each:industryList){
                EnagagementWrapper enagagementWrapperObj = new EnagagementWrapper();
                enagagementWrapperObj.productName = each.Name;
                if(each?.Method_Industries__r.size()>0){
                    trueValueList.add(enagagementWrapperObj);
                }
                else{
                    falseValueList.add(enagagementWrapperObj);
                }
            }
            engagementList.imagePathData = PSCSettingService.getValue('Industries_Images'); 
        }
        else if(title=='Specialist Cloud Considerations'){
            List<Specialist_Cloud__c> splCloudList = PSCEngagementProductService.getSplCloudValue(keyList);
            for(Specialist_Cloud__c each:splCloudList){
                EnagagementWrapper enagagementWrapperObj = new EnagagementWrapper();
                enagagementWrapperObj.productName = each.Name;
                for(Method_by_Specialist_Cloud__c eachInner:each.Method_by_Specialist_Clouds__r){
                    if(eachInner.Status__c=='Standard'){
                        trueValueList.add(enagagementWrapperObj);
                    }
                    else if(eachInner.Status__c=='Specialist'){
                        maybeValueList.add(enagagementWrapperObj);
                    }
                    else if(eachInner.Status__c=='Does not apply'){
                        falseValueList.add(enagagementWrapperObj);
                    }
                }
            }
            engagementList.imagePathData = PSCSettingService.getValue('Product_Offering_Images'); 
        }
        engagementList.trueValues = trueValueList;
        engagementList.falseValues = falseValueList;
        engagementList.maybeValues = maybeValueList;
        
        return engagementList;
    }

    public class EnagagementWrapperParent{
        @AuraEnabled
        public List<EnagagementWrapper> trueValues{get;set;}
        @AuraEnabled
        public List<EnagagementWrapper> falseValues{get;set;}
        @AuraEnabled
        public List<EnagagementWrapper> maybeValues{get;set;}
        @AuraEnabled
        public String imagePathData{get;set;}
    }

    public class EnagagementWrapper{
        @AuraEnabled
        public String productName{get;set;}
        @AuraEnabled
        public String productImg{get;set;}
    }
}