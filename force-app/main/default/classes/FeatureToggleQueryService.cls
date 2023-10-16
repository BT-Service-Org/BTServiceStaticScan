global with sharing class FeatureToggleQueryService {
    private Map<String,List<String>> mdtFieldsDescribe = new Map<String,List<String>>();
    public FeatureToggleQueryService() {
        List<String> types = new List<String> {'Feature_Toggle__mdt','Child_Feature_Toggle__mdt'};
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
		for(Schema.DescribeSobjectResult res : results) {
            List<String> fields = new List<String>();
            for (Schema.SObjectField field : res.fields.getMap().values()) {
                fields.add(field.getDescribe().getName());
            }
            mdtFieldsDescribe.put(res.getName(), fields);
		}
    }

    global class FeatureCondition {
        global String queryOverride = '';
        global FeatureCondition() {}
        global FeatureCondition (String queryOverride) {
            this.queryOverride = queryOverride;
        }
        global void andCondition(String condition) {
            this.queryOverride += ' AND ' + condition;
        }
        global void andCondition(FeatureCondition condition) {
            this.queryOverride += ' AND ' + condition.getQuery();
        }
        global String getQuery() {
            return this.queryOverride;
        }
        global String setQuery(String query) {
            return this.queryOverride = query;
        }        
    }

    global class FeatureFields {
        global Set<String> fields = new Set<String>();
        
        global FeatureFields (List<String> fields) {
            this.fields.addAll(fields);
        }
        global void addField(String field) {
             this.fields.add(field);
        }
        global void addInnerQuery(String field) {
             this.fields.add('('+ field + ')');
        }
        global String toQueryString() {

            return String.join(new List<String>(this.fields), ', ');
        }
    }

    public Map<String,List<String>> getMetadataFieldDescribe(){
        return mdtFieldsDescribe;
    }
    public String buildQuery(FeatureFields fields, String fromX, FeatureCondition condition) {
        system.debug('SELECT '+ (fields == null ? 'Id' : fields.toQueryString()) + ' FROM ' + fromX + (condition == null ? '' :  ' WHERE ' + condition.getQuery()));
        return 'SELECT '+ (fields == null ? 'Id' : fields.toQueryString()) + ' FROM ' + fromX + (condition == null ? '' :  ' WHERE ' + condition.getQuery());
    }
    public List<SObject> runQuery(String query) {
        return Database.query(query);
    }
}