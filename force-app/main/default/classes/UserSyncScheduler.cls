/**
Class Name      : UserSyncScheduler
@description    : Schedulable class to submit batch jobs for user sync
*/
 public class UserSyncScheduler implements Schedulable { 
 
    /**
    @description : execute method
    @param sc - SchedulableContext
    */
    public void execute (SchedulableContext sc){
        String selectString = 'select Alias__c,CommunityNickname__c,LanguageLocaleKey__c,LocaleSidKey__c,TimeZoneSidKey__c,'+
            'FirstName__c, LastName__c,Title__c,Username__c,Email__c,EmailEncodingKey__c,ExternalId,Support_Subgroup_c__c,' +
            'Street__c, City__c, State__c, PostalCode__c, Country__c,Phone__c,Business_Unit_c__c,Cost_Center_c__c,' +
            'Department__c,IsActive__c,Mgmt_Chain_Level_02_c__c,Mgmt_Chain_Level_03_c__c,Mgmt_Chain_Level_04_c__c,Mgmt_Chain_Level_05_c__c, ' +
            'Mgmt_Chain_Level_06_c__c,Mgmt_Chain_Level_07_c__c, Mgmt_Chain_Level_08_c__c, Mgmt_Chain_Level_09_c__c,' +
            'Mgmt_Chain_Level_10_c__c,Mgmt_Chain_Level_11_c__c, Mgmt_Chain_Level_12_c__c,' +
            'Acquired_Company_c__c,Sick_Leave_c__c,Continuous_Service_Date_c__c ,FederationIdentifier__c,' +
            'ManagerId__c,BU_c__c, Hire_Date_c__c,JobCode_c__c,JobFamily_c__c,JobGrade_c__c,Skill_Type_c__c,JobProfile_c__c, Coverage_Country_c__c ' +
            'from User__x where ( LastModifiedDate__c = YESTERDAY and  ( (  '; //LAST_N_DAYS:7 and '; //= YESTERDAY and '; //> LAST_MONTH and '; //LAST_90_DAYS and ';

        Map<String, List<UserSync__mdt>> config = OrgRefresh_Util.getCommunities(); 
        //get criteria that applies to all communities 
        List<UserSync__mdt> allcsg = config.get('CSG');
        //add general criteria
        String query = selectString + buildQuery(allcsg, false); 
        //System.debug('query csg ' + query);
                
        /*/loop thru all communities    
        for (String key : config.keySet()) {
            System.debug('key  ' + key);
            String query1 = query;
            if (key != 'CSG') {
                //add specific criteria for roles
                List<UserSync__mdt> cls = config.get(key);
                System.debug('non csg ' + cls);
                query += ' and ' + buildQuery(cls, false);
                System.debug('non csg query ' + query);
            }
        }*/
        query += ' and (NOT Title__c Like \'%paren%\') ) ' ;
					
        
        string endQuery = 'order by Mgmt_Chain_Level_12_c__c,Mgmt_Chain_Level_11_c__c,Mgmt_Chain_Level_10_c__c,Mgmt_Chain_Level_09_c__c,Mgmt_Chain_Level_08_c__c,Mgmt_Chain_Level_07_c__c, Mgmt_Chain_Level_06_c__c,Mgmt_Chain_Level_05_c__c, Mgmt_Chain_Level_04_c__c, Mgmt_Chain_Level_03_c__c,Mgmt_Chain_Level_02_c__c ';
                
        System.debug(LoggingLevel.INFO,'execute query ::' + query);
        Org62UserSync s = new  Org62UserSync(selectString, query, 'CSG', true,endQuery);
        Database.executeBatch(s,100);
            //}
        //}
    }
        
   /**
    @description :mthod
    @param ls - List<UserSync__mdt>
    @param toplevel - Boolean
    @return : String
    
    */
    public String buildQuery(List<UserSync__mdt> ls, Boolean toplevel) {
        String query = '';
        
        if (!toplevel) {
            //create a map of role and list of criteria
            Map<String, List<UserSync__mdt>> config = new Map<String, List<UserSync__mdt>>();
            List<UserSync__mdt> rls = new List<UserSync__mdt>();
            for (UserSync__mdt m : ls) {
                if (!config.containsKey(m.Role__c)) {
                    rls = new List<UserSync__mdt>();
                    rls.add(m);
                    config.put(m.Role__c, rls);
                } else {
                    rls = config.get(m.Role__c);
                    rls.add(m);
                    config.put(m.Role__c, rls);
                }
            }
            Integer index = 0; 
            query += '(';
            for (String role : config.keySet()) {
                if (index > 0){
                    query += ' or ';
                } 
                
                query += buildQuery(config.get(role));
                index++;
            } 
            query += ')';
            
        } else {
            query = buildQuery(ls);
        }
        return query; 
    }
    /**
    @description : Method
    @param ls - List<UserSync__mdt>
    @return : String
    */
    public String buildQuery(List<UserSync__mdt> ls) {    
        Integer index1 = 0;
        String query = '';
        if (ls != null && ls.size() > 1) {
            query += ' (';
        }
        for (UserSync__mdt m : ls){
            
            if (index1 > 0) {
                query += ' and '; 
            }
            String fldName = m.Field_API_name__c;
            String fldOp = m.Field_Operator__c;
            String fldVal = m.Field_Values__c;
           // System.debug(' flds: ' + fldname + ' :op:  ' + fldOp + ':val: ' + fldVal);
            Integer index2 = 0;
            String inval = '';
            for (String val : fldVal.split(',')) {
                val = val.trim();
                if (fldOp == 'like') {
                    if (index2 > 0) {
                        query += ' or ';
                    }
                    if (index2 == 0) {
                        query += '(';
                    }
                    query += fldName + ' ' + fldOp + ' \'%' + val + '%\'' ;
                } else if (fldOp == 'not like') {
                    if (index2 > 0) {
                        query += ' and ';
                    } 
                    query += ' ('+ fldName + ' != '  + ' \'%' + val + '%\') ';
                } else if (fldOp == '=' ) {
                    if (index2 == 0) {
                        query += '('; 
                    }
                    if (index2 > 0) {
                        query += ' or ';
                    }
                    query += fldName + ' ' +  fldOp  + ' \'' + val + '\' ' ;
                } else if (fldOp == '!=') {
                    if (index2 == 0) {
                        query += '('; 
                    }
                    if (index2 > 0) {
                        query += ' and ';
                    }
                    query += fldName + ' ' +  fldOp  + ' \'' + val + '\' ' ; 
                } else if (fldOp == 'in' || fldOp == 'not in') {
                    inval += '\''+val+'\',';
                }  
                index2++;  
            }
            //System.debug(fldOp + ' inval ' + inval);
            if (fldOp == 'in') {
                inval.removeEnd(',');
                query += fldName + ' ' +  fldOp  + ' (' + inval+ ')';
            } else if (fldOp == 'not in') {
                 
                inval = inval.substring(0,inval.length()-1);
                //System.debug(fldOp + ' inval remove end comma ' + inval);
                query += fldName + ' ' +  fldOp + ' (' + inval+ ')';
            }
            if (fldOp == '=' || fldOp == 'like' || fldOp == '!=') {
                query += ') ';  
            }
            index1++;
        }
        if (ls != null && ls.size() > 1) {
            query += ' )';
        }
        //System.debug(' buildquery ' + query);   
        return query;
    }
        
    
 }