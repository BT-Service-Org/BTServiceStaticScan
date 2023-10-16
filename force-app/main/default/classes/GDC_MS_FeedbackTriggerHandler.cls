public class GDC_MS_FeedbackTriggerHandler {
    public static void afterInsert(List<gdc_ms_Feedback__c> newList){  
        Set<Id> assetIds = new Set<Id>();
        for(gdc_ms_Feedback__c fdb : newList){
            if(fdb.gdc_ms_AssetTitle__c != null){
                assetIds.add(fdb.gdc_ms_AssetTitle__c);
            }
        }
         averageRating(assetIds);
    }
    public static void afterUpdate(List<gdc_ms_Feedback__c> oldList){  
        Set<Id> assetIds = new Set<Id>();
        for(gdc_ms_Feedback__c fdb : oldList){
            if(fdb.gdc_ms_AssetTitle__c != null){
                assetIds.add(fdb.gdc_ms_AssetTitle__c);
            }
        }
         averageRating(assetIds);
    }
    
    public static void averageRating(Set<ID> assetIds){
        if(!assetIds.isEmpty()){
            Integer sum =0;
            Integer loopCount = 0;
            List<gdc_ms_Feedback__c> feedBList = [SELECT gdc_ms_AssetTitle__c,gdc_ms_AssetUsageRating__c  
                                                  FROM gdc_ms_Feedback__c 
                                                  WHERE gdc_ms_AssetTitle__c IN : assetIds];
            if(!feedBList.isEmpty()){
                for(gdc_ms_Feedback__c res : feedBList) {
                    sum = sum + Integer.valueof(res.gdc_ms_AssetUsageRating__c);
                    loopCount++;
                }
            }
            List<gdc_ms_ReusableAsset__c> updateAssetList = new List<gdc_ms_ReusableAsset__c>();
            for(gdc_ms_ReusableAsset__c rAsset : [SELECT id,gdc_ms_Asset_Rating__c, gdc_ms_Feedback_Count__c    
                                                  FROM gdc_ms_ReusableAsset__c 
                                                  WHERE id IN : assetIds]) {
                                                      if(loopCount>0){ 
                                                          rAsset.gdc_ms_Asset_Rating__c = sum/loopCount;
                                                      }
                                                      else{
                                                          rAsset.gdc_ms_Asset_Rating__c = sum;
                                                      }
                                                      rAsset.gdc_ms_Feedback_Count__c = loopCount;
                                                      updateAssetList.add(rAsset);                    
                                                  }
            if(!updateAssetList.isEmpty()){
                UPDATE updateAssetList;
            }
        }
    }
}