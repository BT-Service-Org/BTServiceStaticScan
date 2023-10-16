public class MethodTriggerController {
    private static final String manualRowCause = 'Manual';
    public static void fieldTracking(List<Method__c> updatedMethodList, Map<Id, Method__c> oldMethodMap){
        List<Field_History_Tracking__mdt> fieldsToBeTrackedList = new List<Field_History_Tracking__mdt>([SELECT Field_Tracked_API__c 
                                                                                                     FROM Field_History_Tracking__mdt
                                                                                                     WHERE Active__c = TRUE AND Object_API__c = 'Method__c']);
        Set<String> fieldsToBeTracked = new Set<String>();
        for(Field_History_Tracking__mdt trackedFields: fieldsToBeTrackedList){
            fieldsToBeTracked.add(trackedFields.Field_Tracked_API__c);
        }
        List<Method_History__c> mHistryToInsert = new List<Method_History__c>();
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Method__c.fields.getMap();
        
        //Updated Method's Ids to get their respective Method History
        List<Id> updtMethodIdList = new List<Id>(oldMethodMap.keySet());
        List<Method_History__c> mHistoryToBeDeleted = new List<Method_History__c>([SELECT Id, Method__c FROM Method_History__c
                                                                                        WHERE Method__c =: updtMethodIdList]);
        Map<Id, List<Method_History__c>> methodToHistoryMap = new Map<Id, List<Method_History__c>>();
        for(Method_History__c mHistory: mHistoryToBeDeleted){
            if(methodToHistoryMap.containsKey(mHistory.Method__c)){
                methodToHistoryMap.get(mHistory.Method__c).add(mHistory);
            }
            else{
                methodToHistoryMap.put(mHistory.Method__c, new List<Method_History__c>{mHistory});
            }
        }
        List<Method_History__c> methodHistoryToDelete = new List<Method_History__c>();
        
        for(Method__c updtMethod: updatedMethodList){
            if(updtMethod.Status__c == 'Draft'){
                Method__c oldMethod = oldMethodMap.get(updtMethod.Id);
                for(String fieldName: mapFields.keyset()){
                    try{
                        if(fieldsToBeTracked.contains(String.valueOf(mapFields.get(fieldName)))){
                            if(updtMethod.get(fieldName) != oldMethod.get(fieldName)){
                                Method_History__c mhistory = new Method_History__c();
                                mhistory.Field_Changed__c = String.valueOf(mapFields.get(fieldName));
                                mhistory.Previous_Value__c = String.valueOf(oldMethod.get(fieldName));
                                mhistory.Updated_Value__c = String.valueOf(updtMethod.get(fieldName));
                                mhistory.Changed_By__c = UserInfo.getUserId();
                                mhistory.Method__c = updtMethod.Id;
                                mHistryToInsert.add(mhistory);
                            }
                        }
                    }
                    catch(Exception e){
                        System.debug('Error: '+e);
                    }
                }
            }
            if(updtMethod.Status__c == 'Published'){
                Method__c oldMethod = oldMethodMap.get(updtMethod.Id);
                if(updtMethod.get('Status__c') != oldMethod.get('Status__c')){
                    if(methodToHistoryMap != null && !methodToHistoryMap.isEmpty())
                   		methodHistoryToDelete.addAll(methodToHistoryMap.get(updtMethod.Id));
                }
            }
        }
        try{
            if(!mHistryToInsert.isEmpty()){
                insert mHistryToInsert;
            	System.debug('MH Created');
            }
            if(!methodHistoryToDelete.isEmpty()){
                Delete methodHistoryToDelete;
                System.debug('MH Deleted');
            }
        }
        catch(system.Dmlexception e){
            System.debug('DML Error:'+ e);
        }
    }
    
    public static void addParentMethod(List<Method__c> insertedMethodList){
        List<String> methodNameList = new List<String>();
        for(Method__c insMethod: insertedMethodList){
            methodNameList.add(insMethod.Name);
        }
        Map<Id, Method__c> findMethodVersionMap = new Map<Id, Method__c>([SELECT Id, Name, Method_Version__c  FROM Method__c WHERE Name IN :methodNameList ORDER By Method_Version__c DESC NULLS LAST]);
        Map<Id, Method__c> parentMethod = new Map<Id, Method__c>([Select Id, Name FROM Method__c WHERE Status__c  = 'Published' AND Name IN :methodNameList]);
        for(Method__c methodToUpdate: insertedMethodList){
            if(findMethodVersionMap == NULL || findMethodVersionMap.isEmpty()){
                methodToUpdate.Method_Version__c = 'MV-001';
            }
            else{
                for(Id latestMethodId: findMethodVersionMap.keySet()){
                    if(methodToUpdate.Name == findMethodVersionMap.get(latestMethodId).Name){
                        if(findMethodVersionMap.get(latestMethodId).Method_Version__c != NULL){
                            String[] mVersion = findMethodVersionMap.get(latestMethodId).Method_Version__c.split('-');
                            if(mVersion.size() > 0){
                                Integer versionNum = Integer.valueOf(mVersion[1]) + 1;
                                if(versionNum <= 9){
                                    methodToUpdate.Method_Version__c = 'MV-00'+ String.valueOf(versionNum);
                                }
                                else if(versionNum > 9 && versionNum <= 99){
                                    methodToUpdate.Method_Version__c = 'MV-0'+ String.valueOf(versionNum);
                                }
                                else{
                                    methodToUpdate.Method_Version__c = 'MV-'+ String.valueOf(versionNum);
                                }
                                break;
                            }
                        }
                    }
                }
            }
            for(Id parentMethodId: parentMethod.keySet()){
                if(methodToUpdate.Status__c != 'Published' && methodToUpdate.Name == parentMethod.get(parentMethodId).Name){
                    methodToUpdate.Parent_Method__c = parentMethod.get(parentMethodId).Id;
                }
            }
        }
    }

    /* *If there is an update in SME field then share the method record with the associated SME Lookup user.*/
    public static void shareRecord(List<Method__c> newMethod, Map<Id, Method__c> oldMethod) {
        for (Method__c mthd: newMethod) {
            Method__c oldMthd = oldMethod.get(mthd.ID);
            
            /* *This is to add Sharing Rule for the current SME user! */
            if ( mthd.SME__c != oldMthd.SME__c && mthd.SME__c != null ) {
                try {
                    MethodSharing.manualShareWrite(mthd.ID, mthd.SME_Lookup__c);
                }catch(Exception ex) {
                    System.debug('Error: '+ex.getMessage());
                }              
            }
            
            /* *This is to delete Existing Sharing Rule for the previous SME user! */
            if ( mthd.SME__c != oldMthd.SME__c && oldMthd.SME__c != null ) {
                try{
                	MethodSharing.deleteSharing(mthd.ID, oldMthd.SME_Lookup__c, manualRowCause);
                }catch(Exception ex) {
                    System.debug('Error: '+ex.getMessage());
                } 

            }
        }
    }
}