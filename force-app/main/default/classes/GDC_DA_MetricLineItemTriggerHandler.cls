public class GDC_DA_MetricLineItemTriggerHandler {
    
     public static void updateStatus(Map<Id,GDC_DA_Metric_Line_Items__c> oldMap,Map<Id,GDC_DA_Metric_Line_Items__c> newMap) {
         List<String> fieldsToRollup = new List<String>();
        List<Schema.FieldSetMember> fieldSetMemberList =  getFieldSetDetails('Roll_Up_Fields','GDC_DA_Metric_Line_Items__c');
        String queryFields = '';
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
        {
            fieldsToRollup.add(fieldSetMemberObj.getFieldPath());
        }
        
        for(GDC_DA_Metric_Line_Items__c item: newMap.values()){
            Boolean changeStatus = true;
            for(String field: fieldsToRollup){
                if( oldMap.get(item.id).get(field) != item.get(field)  && item.get(field) == null){
                    changeStatus = false;
                }
            }
            if(item.Status__c=='Draft' && changeStatus){
                item.Status__c = 'Submitted';
            }           
        }         
     }
	
    public static void updateParentMetrics(Map<Id,GDC_DA_Metric_Line_Items__c> oldMap,Map<Id,GDC_DA_Metric_Line_Items__c> newMap) {
        List<String> fieldsToRollup = new List<String>();
        List<Schema.FieldSetMember> fieldSetMemberList =  getFieldSetDetails('Roll_Up_Fields','GDC_DA_Metric_Line_Items__c');
        String queryFields = '';
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
        {
            fieldsToRollup.add(fieldSetMemberObj.getFieldPath());
            queryFields = queryFields + fieldSetMemberObj.getFieldPath() +',';
        }
        
        queryFields = queryFields.removeEnd(',');
        SET<Id> metricIds = new SET<Id>();
        for(GDC_DA_Metric_Line_Items__c item: newMap.values()){
            metricIds.add(item.GDC_DA_Metric__c);
        }
        
       String query = 'SELECT id,(SELECT id,'+queryFields+' from GDC_DA_Metric_Line_Items__r) from GDC_DA_Metric__c where id IN: metricIds'; 
      List<GDC_DA_Metric__c> lstMetrics = Database.query(query);
       List<GDC_DA_Metric__c> updatedMetrics = new List<GDC_DA_Metric__c>();

        for(GDC_DA_Metric__c metric : lstMetrics){
            Map<String,Integer> rollupData = getRollUpFieldData('SUM',metric.GDC_DA_Metric_Line_Items__r,fieldsToRollup);
            for(String fieldApi: fieldsToRollup){
                metric.put(fieldApi,rollupData.get(fieldApi));
            }
            updatedMetrics.add(metric);
        } 
        
        update updatedMetrics;    
        
    }
    
    public static Map<String,Integer> getRollUpFieldData(String Type,List<sObject> recordsToRollup, List<String> fieldsToRollup){
        Map<String,Integer> rollupData = new Map<String,Integer>();
        
        Switch on type{
            when 'SUM'{
                for(sObject obj: recordsToRollup){
                    for(String fieldApi : fieldsToRollup){
                        if(!rollupData.containsKey(fieldApi)){
                            rollupData.put(fieldApi,0);
                        }
                        Integer currentValue = obj.get(fieldApi)!=null ? Integer.valueOf(obj.get(fieldApi)): 0;
                        rollupData.put(fieldApi,rollupData.get(fieldApi) + Integer.valueOf(currentValue));
                    }
                }
            }
            when else{
                
            }
        }       
        return rollupData;
    }
    
    
    public static List<Schema.FieldSetMember> getFieldSetDetails(String fieldSetName, String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();    
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }  
}