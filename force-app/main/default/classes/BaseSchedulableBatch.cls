public abstract with sharing class BaseSchedulableBatch implements Database.Batchable<SObject>,Schedulable {
    
    public void scheduleNext(Type targetType){
        MethodologyBatchSchedulerConfig__mdt batchConfigRec = MethodologyBatchSchedulerConfig__mdt.getInstance(targetType.getName());
        
        if(batchConfigRec != null && batchConfigRec.IsActive__c && !Test.isRunningTest()){
            Integer batchsize = (String.isBlank(batchConfigRec.Batch_Size__c )) ? MethodologyConstants.DEFAULT_BATCH_SIZE  :  Integer.valueOf(batchConfigRec.Batch_Size__c);
            Integer minutes =  String.isBlank(batchConfigRec.Every_X_Minutes__c) ? -1  :  Integer.valueOf(batchConfigRec.Every_X_Minutes__c);
            if(minutes > 0){
                System.scheduleBatch(((Database.Batchable<SObject>)targetType.newInstance()), targetType.getName(), minutes, batchsize);
            }
        }
    }

    public void handleException(Exception ex){
        // TODO: Log implementation for the errors raised
        System.debug('ERROR-->'+ex.getMessage());
    }
}