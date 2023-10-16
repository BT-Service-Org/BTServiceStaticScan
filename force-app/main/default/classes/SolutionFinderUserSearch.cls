public class SolutionFinderUserSearch {
    
    private final static String SOBJECT_TYPE = 'User';
    private final static String FIELD_IS_ACTIVE = 'IsActive';
    private final static String FIELDSET_SEARCH_RESULT_COLUMNS = 'User_Search_Result_Columns';
    private final static String FIELDSET_TYPE_TEXT = 'text';
    private final static String FIELDSET_TYPE_DATE = 'date';

    private static List<Schema.FieldSetMember> fieldSetMembers;

    public class ResultColumn {
    
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        //@AuraEnabled public Boolean sortable;
        @AuraEnabled public String type;
        //@AuraEnabled public ColumnTypeAttributes typeAttributes;

        public ResultColumn(String label, String fieldName, Boolean sortable, String type, ColumnTypeAttributes typeAttributes){
            this.label = label;
            this.fieldName = fieldName;
            //this.sortable = sortable;
            this.type = type;
            //this.typeAttributes = typeAttributes;
        }

        public ResultColumn(String label, String fieldName, Boolean sortable, String type){
            this(label, fieldName, sortable, type, null);
        }
    }
    
    public class ColumnTypeAttributes {
        
        @AuraEnabled public String value;
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String iconName;
        @AuraEnabled public Boolean disabled;
        
        public ColumnTypeAttributes(String value, String name, String label, String iconName, Boolean disabled) {
            this.value = value;
            this.name = name;
            this.label = label;
            this.iconName = iconName;
            this.disabled = disabled;
        }
    }
    
    @Auraenabled
    public static List<User> search(string searchCriteria) {
        List<String> fieldsToQuery = new List<String>();
        for (Schema.FieldSetMember fieldSetMember : getFieldSetMembers()) {
            fieldsToQuery.add(fieldSetMember.getFieldPath());
        }
        String whereClause =  buildWhereClause(searchCriteria);
        String query = 'SELECT ' + String.join(fieldsToQuery, ',')
            + ' FROM ' + SOBJECT_TYPE
            + ' ' +  whereClause
            + ' LIMIT 500';
        
        List<User> userlist = database.query(query);        
        return userlist;
    }

    private static string buildWhereClause(string searchCriteria){
    
        String whereClause = ' WHERE ' + FIELD_IS_ACTIVE + ' = true';
        
        String searchWhere = '';
        
        if (searchCriteria <> null && searchCriteria <> '') {
            for (Schema.FieldSetMember fieldSetMember : getFieldSetMembers()) {
                System.debug('fieldSetMember: ' + fieldSetMember.getFieldPath() + ' - ' + fieldSetMember.getType());
                if (fieldSetMember.getType() == Schema.DisplayType.String) {
                    if (searchWhere != '') {
                        searchWhere += ' OR ';
                    }
                    searchWhere += fieldSetMember.getFieldPath() + ' LIKE ' + '\'%' + searchCriteria + '%\'';
                }
            }
        }
        
        if (searchWhere != '') {
            whereClause += ' AND  (' + searchWhere + ')';
        }
        
        return whereClause;
    }
    
    private static List<Schema.FieldSetMember> getFieldSetMembers() {
        if (fieldSetMembers == null) {
            fieldSetMembers = SolutionFinderFieldSetUtilities.getFieldSetMembers(SOBJECT_TYPE, FIELDSET_SEARCH_RESULT_COLUMNS);
        }
        return fieldSetMembers;
    }
    
    private static String getFieldSetType(Schema.FieldSetMember fieldSetMember) {
        String fieldSetType = FIELDSET_TYPE_TEXT;
        if (fieldSetMember != null &&
            	fieldSetMember.getType() == Schema.DisplayType.DATE) {
            fieldSetType = FIELDSET_TYPE_DATE;
        }
        return fieldSetType;
    }
    
    @AuraEnabled
    public static string getSearchResultColumns() {

        List<ResultColumn> resultColumns = new List<ResultColumn>();
        for (Schema.FieldSetMember fieldSetMember : getFieldSetMembers()) {
            resultColumns.add(new ResultColumn(fieldSetMember.getLabel(),
                                               fieldSetMember.getFieldPath(),
                                               false,
                                               getFieldSetType(fieldSetMember)));
        }
        System.debug(resultColumns);
        return JSON.serialize(resultColumns);
    }
}