public with sharing class PSCDatatableCtrl {

    @AuraEnabled (cacheable=true)
    public static String getFieldsAndRecords(String strObjectApiName, String strfieldSetName,String criteriaField, String criteriaFieldValue,String getAllArticleVersionData){
        Map<String, String> returnMap = new Map<String,String>();
        if(!String.isEmpty(strObjectApiName) && !String.isEmpty(strfieldSetName)){
            //get fields from FieldSet
            String escapedCriteriaField = String.escapeSingleQuotes(criteriaField);
            SObject sObj = (SObject)(Type.forName('Schema.'+ strObjectApiName).newInstance());
            List<Schema.FieldSetMember> lstFSMember = 
                sObj.getSObjectType().getDescribe().fieldSets.getMap().get(strfieldSetName).getFields();
            
            //prepare SOQL query based on fieldAPIs	
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : lstFSMember) {
                query += f.getFieldPath() + ', ';
            }
            query = String.escapeSingleQuotes(query);
            query += 'Id FROM ' + String.escapeSingleQuotes(strObjectApiName) ;
            
            //Just in case criteria field not specified then it will return all records
            if(criteriaField != null && !(String.isEmpty(criteriaField) && String.isEmpty(criteriaFieldValue))){
                String escapedCriteriaFieldValue = String.escapeSingleQuotes(criteriaFieldValue);
                if(getAllArticleVersionData != null && getAllArticleVersionData == 'Yes'){
                    
                    String articleNumber = PSCKnowledgeArticlesService.getAllKnowledgeArticleNumber(escapedCriteriaFieldValue);
                     
                    query += ' WHERE ' + escapedCriteriaField + ' =:  articleNumber'; // for getting all the version data, create a formula field on child object and use that as criteria field
                }
                else{
                    query += ' WHERE ' + escapedCriteriaField + '=: escapedCriteriaFieldValue';
                }
            }
            System.debug('query->'+query);
            //execute query
            List<SObject> lstRecords = Database.query(String.escapeSingleQuotes(query));
            
            //prepare a map which will hold fieldList and recordList and return it
            returnMap.put('FIELD_LIST', JSON.serialize(lstFSMember));
            returnMap.put('RECORD_LIST', JSON.serialize(lstRecords));
            return JSON.serialize(returnMap);
        }
        return null;
    }
}