public with sharing class UpdateRelatedListOnMethodUpdate {
    public UpdateRelatedListOnMethodUpdate() {}

    @InvocableMethod(label='Update Related Lists' description='Update the related lists of a method during Update Method')
    public static void createEnrolments(List<RelatedListsRequest> request) {
        String methodRecordId = request.get(0).methodRecordId;
        String groupingIds = request.get(0).groupingIds;
        String oldGroupingIds = request.get(0).oldGroupingIds;
        String stagesIds = request.get(0).stagesIds;
        String oldStagesIds = request.get(0).oldStagesIds;
        String industryIds = request.get(0).industryIds;
        String oldIndustryIds = request.get(0).oldIndustryIds;
        String serviceProductIds = request.get(0).serviceProductIds;
        String oldServiceProductIds = request.get(0).oldServiceProductIds;
        String productIds = request.get(0).productIds;
        String oldProductIds = request.get(0).oldProductIds;
        String oldRoleVal = request.get(0).oldRole;
        String newRoleVal = request.get(0).newRole;
        String[] outcomeIdsToBeAdded = request.get(0).outcomeIdsToBeAdded;
        String[] outcomeIdsToBeRemoved = request.get(0).outcomeIdsToBeRemoved;
         
        //String specialistCloudIds = request.get(0).specialistCloudIds;
        //String oldspecialistCloudIds = request.get(0).oldspecialistCloudIds;
        System.debug('Request Data: '+groupingIds+':'+stagesIds+':'+industryIds);

        /** MethodOutcomes creation */
        updateMethodOutcomes(methodRecordId, outcomeIdsToBeAdded, outcomeIdsToBeRemoved);
        /**Business Logic #WIP */
        /**1. Method_by_Grouping__c */
        oldGroupingIds = oldGroupingIds==null ? '': oldGroupingIds ;
        groupingIds = groupingIds==null ? '': groupingIds ;
        updateGroupingRecs(oldGroupingIds, groupingIds, methodRecordId);
        /**2. stagging */
        oldStagesIds = oldStagesIds==null ? '': oldStagesIds ;
        stagesIds = stagesIds==null ? '': stagesIds ;
        updateStaggingRecs(oldStagesIds, stagesIds, methodRecordId);
        /**3. industry */
        oldIndustryIds = oldIndustryIds==null ? '': oldIndustryIds ;
        industryIds = industryIds==null ? '': industryIds ;
        updateIndustryRecs(oldIndustryIds, industryIds, methodRecordId);
        /**4. service products - Method_Ownership_by_Product__c  */
        oldServiceProductIds = oldServiceProductIds==null ? '': oldServiceProductIds ;
        serviceProductIds = serviceProductIds==null ? '': serviceProductIds ;
        //if (newRoleVal != oldRoleVal) oldServiceProductIds = '';
        updateMethodOwnershipByProductRecs(oldServiceProductIds, serviceProductIds, newRoleVal, methodRecordId);
        /**5. products - Method_by_Product__c */
        oldProductIds = oldProductIds==null ? '': oldProductIds ;
        productIds = productIds==null ? '': productIds ;
        updateMethodByProductRecs(oldProductIds, productIds, methodRecordId);
        /**6. specialist cloud */
       /* oldspecialistCloudIds = oldspecialistCloudIds==null ? '': oldspecialistCloudIds ;
        specialistCloudIds = specialistCloudIds==null ? '': specialistCloudIds ;
        updateSpecialistCloudRecs(oldspecialistCloudIds, specialistCloudIds, methodRecordId);*/
    }

    public static void updateMethodOutcomes(String methodRecordId, String[] outcomeIdsToBeAdded, String[] outcomeIdsToBeRemoved){
      if(outcomeIdsToBeAdded != null && !outcomeIdsToBeAdded.isEmpty() && !String.isBlank(methodRecordId)){
        List<Method_Outcome__c> methodOutcomes = new List<Method_Outcome__c>();
        for(String outcomeId : outcomeIdsToBeAdded){
            Method_Outcome__c methodOutcome = new Method_Outcome__c(Outcome__c = outcomeId, Method__c = methodRecordId);
            methodOutcomes.add(methodOutcome);
        }
        Database.insert(methodOutcomes);
      }

      if(outcomeIdsToBeRemoved != null && !outcomeIdsToBeRemoved.isEmpty()){
        List<Method_Outcome__c> methodOutcomesToBeRemoved = [SELECT Id FROM Method_Outcome__c WHERE Outcome__c IN :outcomeIdsToBeRemoved];
        if(!methodOutcomesToBeRemoved.isEmpty()){
            Database.delete(methodOutcomesToBeRemoved);
        }
      }
    }

    public static void updateGroupingRecs(String oldGroupingIds, String groupingIds, String methodRecordId) {
        Map<String ,List<String>> newOpsItems = updateChildRecordHelper(oldGroupingIds, groupingIds);
        List<Method_by_Grouping__c> newGroupingRecs = new List<Method_by_Grouping__c>();
        List<Method_by_Grouping__c> oldGroupingRecs = new List<Method_by_Grouping__c>();
        if(newOpsItems.containsKey('Create Record')){
          for(String item: newOpsItems.get('Create Record')) {
            Method_by_Grouping__c mtdGrp = new Method_by_Grouping__c();
            mtdGrp.Grouping__c = item;
            mtdGrp.Method__c = methodRecordId;
            newGroupingRecs.add(mtdGrp);
        }  
        }
         if(newOpsItems.containsKey('Delete Record')){
        for(String item: newOpsItems.get('Delete Record')) {
            List<Method_by_Grouping__c> mtdGrp = [select Id from Method_by_Grouping__c where Grouping__c=:item and Method__c =:methodRecordId limit 1];
            oldGroupingRecs.addAll(mtdGrp);
        }
        } 
        if(newGroupingRecs.size()>0) Database.insert(newGroupingRecs);
        if(oldGroupingRecs.size()>0) Database.delete(oldGroupingRecs);
    }

    public static void updateStaggingRecs(String oldStagesIds, String stagesIds, String methodRecordId) {
        Map<String ,List<String>> newOpsItems = updateChildRecordHelper(oldStagesIds, stagesIds);
        List<Method_with_Stage__c> newGroupingRecs = new List<Method_with_Stage__c>();
        List<Method_with_Stage__c> oldGroupingRecs = new List<Method_with_Stage__c>();
        if(newOpsItems.containsKey('Create Record')){
          for(String item: newOpsItems.get('Create Record')) {
            Method_with_Stage__c mtdGrp = new Method_with_Stage__c();
            mtdGrp.Stage__c = item;
            mtdGrp.Method__c = methodRecordId;
            newGroupingRecs.add(mtdGrp);
          }  
        }
        if(newOpsItems.containsKey('Delete Record')){
        for(String item: newOpsItems.get('Delete Record')) {
            List<Method_with_Stage__c> mtdGrp = [select Id from Method_with_Stage__c where Stage__c=:item and Method__c =:methodRecordId limit 1];
            oldGroupingRecs.addAll(mtdGrp);
        }
        } 
        if(newGroupingRecs.size()>0) Database.insert(newGroupingRecs);
        if(oldGroupingRecs.size()>0) Database.delete(oldGroupingRecs);
    }

    public static void updateIndustryRecs(String oldIndustryIds, String industryIds, String methodRecordId) {
        Map<String ,List<String>> newOpsItems = updateChildRecordHelper(oldIndustryIds, industryIds);
        List<Method_Industry__c> newGroupingRecs = new List<Method_Industry__c>();
        List<Method_Industry__c> oldGroupingRecs = new List<Method_Industry__c>();
        if(newOpsItems.containsKey('Create Record')){
          for(String item: newOpsItems.get('Create Record')) {
            Method_Industry__c mtdGrp = new Method_Industry__c();
            mtdGrp.Industry__c = item;
            mtdGrp.Method__c = methodRecordId;
            newGroupingRecs.add(mtdGrp);
          }  
        }
        if(newOpsItems.containsKey('Delete Record')){
        for(String item: newOpsItems.get('Delete Record')) {
            List<Method_Industry__c> mtdGrp = [select Id from Method_Industry__c where Industry__c=:item and Method__c =:methodRecordId limit 1];
            oldGroupingRecs.addAll(mtdGrp);
        }
        } 
        if(newGroupingRecs.size()>0) Database.insert(newGroupingRecs);
        if(oldGroupingRecs.size()>0) Database.delete(oldGroupingRecs);
    }

    public static void updateMethodOwnershipByProductRecs(String oldServiceProductIds, String serviceProductIds, String newRoleVal, String methodRecordId) {
        Map<String ,List<String>> newOpsItems = updateChildRecordHelper(oldServiceProductIds, serviceProductIds);
        List<Method_Ownership_by_Product__c> newGroupingRecs = new List<Method_Ownership_by_Product__c>();
        List<Method_Ownership_by_Product__c> oldGroupingRecs = new List<Method_Ownership_by_Product__c>();
        if(newOpsItems.containsKey('Create Record')){
          for(String item: newOpsItems.get('Create Record')) {
            Method_Ownership_by_Product__c mtdGrp = new Method_Ownership_by_Product__c();
            mtdGrp.Product__c = item;
            mtdGrp.Role__c = newRoleVal;
            mtdGrp.Method__c = methodRecordId;
            newGroupingRecs.add(mtdGrp);
          }  
        }
        if(newOpsItems.containsKey('Delete Record')){
        for(String item: newOpsItems.get('Delete Record')) {
            List<Method_Ownership_by_Product__c> mtdGrp = [select Id from Method_Ownership_by_Product__c where Product__c=:item and Method__c =:methodRecordId limit 1];
            oldGroupingRecs.addAll(mtdGrp);
        }
        } 
        if(newGroupingRecs.size()>0) Database.insert(newGroupingRecs);
        if(oldGroupingRecs.size()>0) Database.delete(oldGroupingRecs);
    }

    public static void updateMethodByProductRecs(String oldProductIds, String productIds, String methodRecordId) {
        Map<String ,List<String>> newOpsItems = updateChildRecordHelper(oldProductIds, productIds);
        List<Method_by_Product__c> newGroupingRecs = new List<Method_by_Product__c>();
        List<Method_by_Product__c> oldGroupingRecs = new List<Method_by_Product__c>();
        if(newOpsItems.containsKey('Create Record')){
          for(String item: newOpsItems.get('Create Record')) {
            Method_by_Product__c mtdGrp = new Method_by_Product__c();
            mtdGrp.Product__c = item;
            mtdGrp.Method__c = methodRecordId;
            newGroupingRecs.add(mtdGrp);
          }  
        }
        if(newOpsItems.containsKey('Delete Record')){
        for(String item: newOpsItems.get('Delete Record')) {
            List<Method_by_Product__c> mtdGrp = [select Id from Method_by_Product__c where Product__c=:item and Method__c =:methodRecordId limit 1];
            oldGroupingRecs.addAll(mtdGrp);
        }
        } 
        if(newGroupingRecs.size()>0) Database.insert(newGroupingRecs);
        if(oldGroupingRecs.size()>0) Database.delete(oldGroupingRecs);
    }

    public static void updateSpecialistCloudRecs(String oldspecialistCloudIds, String specialistCloudIds, String methodRecordId) {
        Map<String ,List<String>> newOpsItems = updateChildRecordHelper(oldspecialistCloudIds, specialistCloudIds);
        List<Method_by_Specialist_Cloud__c> newGroupingRecs = new List<Method_by_Specialist_Cloud__c>();
        List<Method_by_Specialist_Cloud__c> oldGroupingRecs = new List<Method_by_Specialist_Cloud__c>();
        if(newOpsItems.containsKey('Create Record')){
          for(String item: newOpsItems.get('Create Record')) {
            Method_by_Specialist_Cloud__c mtdGrp = new Method_by_Specialist_Cloud__c();
            mtdGrp.Specialist_Cloud__c = item;
            mtdGrp.Method__c = methodRecordId;
            newGroupingRecs.add(mtdGrp);
          }  
        }
        if(newOpsItems.containsKey('Delete Record')){
        for(String item: newOpsItems.get('Delete Record')) {
            List<Method_by_Specialist_Cloud__c> mtdGrp = [select Id from Method_by_Specialist_Cloud__c where Specialist_Cloud__c=:item and Method__c =:methodRecordId limit 1];
            oldGroupingRecs.addAll(mtdGrp);
        }
        } 
        if(newGroupingRecs.size()>0) Database.insert(newGroupingRecs);
        if(oldGroupingRecs.size()>0) Database.delete(oldGroupingRecs);
    }
    
    
    public class RelatedListsRequest {    
        @InvocableVariable
        public String methodRecordId;
        @InvocableVariable
        public String groupingIds;
        @InvocableVariable
        public String oldGroupingIds;
        @InvocableVariable
        public String stagesIds;
        @InvocableVariable
        public String oldStagesIds;
        @InvocableVariable
        public String industryIds;
        @InvocableVariable
        public String oldIndustryIds;
        @InvocableVariable
        public String serviceProductIds;
        @InvocableVariable
        public String oldServiceProductIds;
        @InvocableVariable
        public String productIds;
        @InvocableVariable
        public String oldProductIds;
        @InvocableVariable
        public String newRole;
        @InvocableVariable
        public String oldRole;
        @InvocableVariable
        public String specialistCloudIds;
        @InvocableVariable
        public String oldspecialistCloudIds;
        @InvocableVariable
        public String[] outcomeIdsToBeAdded;
         @InvocableVariable
        public String[] outcomeIdsToBeRemoved;
    }
    
    public class UpdateResult {}

    public static Map<String ,List<String>> updateChildRecordHelper( String oldIds,String newIds ) {
        Map<String ,List<String>> result = new Map<String ,List<String>>();
        List<String> oIds = oldIds?.split(';');
        List<String> nIds = newIds?.split(';');        
        List<String> addNew = new List<String>();
        List<String> deleteOld = new List<String>();
        for( String id: nIds) {
            if(!oIds?.contains(id)) {
                addNew.add(id);
            }
        }
        for( String id: oIds) {
            if(!nIds?.contains(id)) {
                deleteOld.add(id);
            }
        }
        if(addNew?.size()>0) result.put('Create Record', addNew);
        if(deleteOld?.size()>0) result.put('Delete Record', deleteOld);
        return result;
    }

}