public with sharing class OrgRefresh_Util {
    
    //List of criteria from metadatatype
    public static Map<String, List<UserSync__mdt>> getCommunities() {
        
        Map<String, List<UserSync__mdt>> config = new Map<String, List<UserSync__mdt>>();
        List<UserSync__mdt> ls = new List<UserSync__mdt>();
        for (UserSync__mdt m : [select Field_API_name__c, Role__c,Field_operator__c, Field_Values__c,Type__c from 
                UserSync__mdt where Active__c = true order by Type__c, Role__c]) {
            if (!config.containsKey(m.Type__c)) {
                ls = new List<UserSync__mdt>();
                ls.add(m);
                config.put(m.Type__c, ls);
            } else {
                ls = config.get(m.Type__c);
                ls.add(m);
                config.put(m.Type__c, ls);
            }
        }
        System.debug('config ' + config);
        return config;
    }
    
    //List of criteria from metadatatype
    public static Map<String, List<UserSync__mdt>> getRoles(String community) {
        
        Map<String, List<UserSync__mdt>> config = new Map<String, List<UserSync__mdt>>();
        List<UserSync__mdt> ls = new List<UserSync__mdt>();
        for (UserSync__mdt m : [select Field_API_name__c, Role__c,Field_operator__c, Field_Values__c,Type__c from 
                UserSync__mdt where Active__c = true and Type__c =: community order by Developername]) {
            if (!config.containsKey(m.Role__c)) {
                ls = new List<UserSync__mdt>();
                ls.add(m);
                config.put(m.Role__c, ls);
            } else {
                ls = config.get(m.Role__c);
                ls.add(m);
                config.put(m.Role__c, ls);
            }
        }
        
        return config;
    }
    
    public static Map<String, List<UserSync__mdt>> getRoles(List<UserSync__mdt> mdtls) {
        
        Map<String, List<UserSync__mdt>> config = new Map<String, List<UserSync__mdt>>();
        List<UserSync__mdt> ls = new List<UserSync__mdt>();
        for (UserSync__mdt m : mdtls) {
            if (!config.containsKey(m.Role__c)) {
                ls = new List<UserSync__mdt>();
                ls.add(m);
                config.put(m.Role__c, ls);
            } else {
                ls = config.get(m.Role__c);
                ls.add(m);
                config.put(m.Role__c, ls);
            }
        }
        
        return config;
    }
    
    //List of criteria from metadatatype
    public static Map<String, List<UserSync__mdt>> getAllRoles() {
        
        Map<String, List<UserSync__mdt>> config = new Map<String, List<UserSync__mdt>>();
        List<UserSync__mdt> ls = new List<UserSync__mdt>();
        for (UserSync__mdt m : [select Field_API_name__c, Role__c,Field_operator__c, Field_Values__c,Type__c from 
                UserSync__mdt where Active__c = true order by Developername]) {
            if (!config.containsKey(m.Role__c)) {
                ls = new List<UserSync__mdt>();
                ls.add(m);
                config.put(m.Role__c, ls);
            } else {
                ls = config.get(m.Role__c);
                ls.add(m);
                config.put(m.Role__c, ls);
            }
        }
        
        return config;
    }
    
    public static OnboardingBean getBean(String community, String role) {

        UserSync__mdt m = [select Record_Type_Id__c, Program_Option__c from 
                UserSync__mdt where Active__c = true and Type__c =: community and Role__c =: role limit 1]; 
            
        OnboardingBean b = new OnboardingBean(m.Role__c, m.Type__c, m.Program_Option__c, m.Record_Type_ID__c);
        
        return b;
    }
    
    public static Map<String,Id> getRecordTypes() {
        Map<String, Id> idmap = new Map<String, Id>();
        for (UserSync__mdt m : [select Type__c, Role__c, Record_Type_Id__c from UserSync__mdt  where Active__c = true order by Type__c]) { 
            if (!idmap.containsKey(m.Type__c+m.Role__c)) {
                idmap.put(m.Type__c+m.Role__c, m.Record_Type_Id__c);
            }
        }
        return idmap;
    }
    
    //Matches the record against the criteria.
    public static Boolean matchRuleCriteria(String operation, String fldname, String value, String fld) {
        value = value.toLowercase();
        
        if (fldname != null) {
            fldname = fldname.toLowercase();
        }
        
        if (operation == '=') {
            if ((fldname == '' || fldname == null) && value != '') {
                return false;
            }        
            if (value.contains(',')) {
                return value.contains(fldname);
            } else {
                return (fldname == value);
            }
        } if (operation == '!=') {
            if ((fldname == '' || fldname == null) && value != '') {
                return false;
            }        
            if (value.contains(',')) {
                return !value.contains(fldname);
            } else {
                return (fldname != value);
            }
        } if (operation == 'like') {
            System.debug('like');
            if ((fldname == '' || fldname == null) && value != '') {
                return false;
            }        
            if (value.contains(',')) {
                System.debug('values ' + fldname + '::' +value.split(','));
                for (String v: value.split(',')) {
                    if (fldname.contains(v)) {
                        return true;
                    }
                }
                return false;
            } else {
                return (fldname.contains(value));
            } 
        } if (operation == 'not like') {
            System.debug('not like');
            if ((fldname == '' || fldname == null) && value != '') {
                return true;
            }        
            if (value.contains(',')) {
                System.debug('values ' + fldname + '::' +value.split(',')); 
                for (String v: value.split(',')) {
                    if (fldname.contains(v)) {
                        return false;
                    }
                }
                return true;
            } else if (fldname.contains(value)) { 
                return false;
            } else {
                return true;
            }
        } else if (operation == 'in') {
            System.debug('fld value ' + fldname);
            System.debug('rule value ' + value);
            System.debug('match res: ' + value.contains(fldname));
            if ((fldname == '' || fldname == null) && value != '') {
                return false;
            }        

            if (fldname != null) {
                if (fldname == '' && value != '') {
                    return false;
                }
                
                return (value.contains(fldname));
            }
        } else if (operation == 'not in') {
            if ((fldname == '' || fldname == null) && value != '') {
                return true;
            }        
            
            if (fldname != null) {
                if (fldname == '' && value != '') {
                    return true;
                }
                
                return (!value.contains(fldname));
            }
        }
        return false;
    }    
   
    
    class OnboardingBean {
        String role;
        String community;
        String program;
        String recordtype;
        
        public OnboardingBean (String role, String community, String program, String recordType) {
            this.role = role;
            this.community = community;
            this.program = program;
            this.recordtype = recordtype;
        }
    }
    
}