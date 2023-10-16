global class The_Station_ContentSearchCloudProdVals extends VisualEditor.DynamicPickList{
    String objectName = 'Station_Pages__c';
    String cloudProductField = 'Cloud_Product__c';

    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('Sales Cloud', 'Sales Cloud');
        return defaultValue;
    }
    
    global override VisualEditor.DynamicPickListRows getValues() {
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(cloudProductField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();                
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            VisualEditor.DataRow value = new VisualEditor.DataRow(pickListVal.getLabel(), pickListVal.getValue());
            myValues.addRow(value);            
        }        
        return myValues;
    }
}