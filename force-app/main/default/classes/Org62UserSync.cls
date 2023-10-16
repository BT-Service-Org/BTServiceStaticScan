/**
	Apex class Name : Org62UserSync
	@description		: This class automates the sync users between the external User object records
	Test Class		:  
	Created Date	:  
*/

global class Org62UserSync implements Database.Batchable<User__x>,Database.Stateful  {
        
        global String defaultProfile;
        global String community;
        global String query;
    	global String endQuery;
        global String selectString; 
        global System.LoggingLevel level = LoggingLevel.ERROR;
        
        global Boolean isNightly;
        global Integer jobno;
        private static Id jobId;
        private String errorLog = '';
        Map<String, List<UserSync__mdt>> config = null;
        //List<User> uls = new List<User>();
        
        
        //Overloaded constructor 
        /**
        @description : constructor of the batch class to get the info
        @param scope - String, String , String , Boolean , String
        */
        public Org62UserSync(String selectString, String userQuery, String community, Boolean isNightly, String endQuery) {    
            if (isNightly) {
                defaultProfile = [select Id from Profile where name =: 'CSG Base Profile'].Id;
                query = userQuery;
            }
            System.debug(LoggingLevel.INFO,'community ' + community);
            this.selectString = selectString;
            this.community = community;  
            this.config = OrgRefresh_Util.getCommunities();
            this.endQuery = endQuery;
        }
    
        /**
         @description : Execute method of the batch class to trigger batch
          @param sc - schedulableContext
         */
        global void execute(schedulableContext sc)
        {
            Database.executebatch(this);
        }
        
    	/**
         @description : Start method of the batch class to get the latest User external object records
         @return : Iterable<User__x> 
         @param batchableContext - Database.BatchableContext
         */
        global Iterable<User__x> start(Database.BatchableContext batchableContext) {
            
            return new UserIterable(query,endQuery); 
        }
        
        /**
         @description : Execute method of the batch class to sync users
         @param scope -  List<sobject>
         @param bc - Database.BatchableContext  
         */
        global void execute(Database.BatchableContext bc,List<sobject> scope) {
            
            //get mgr ids for the entire mgmt chain starting at level 03
            //create a map of external user id and services org user id for the mgr users
            List<User__x> extUsers = scope;
            System.debug(LoggingLevel.INFO,'scope ' + scope);

            Set<Id> extorg62Id = new Set<Id>();
            for (User__x ux : extUsers ) {
                
                if (ux.ExternalId != null) {
                    extorg62Id.add(ux.ExternalId);
                    extorg62Id.add(ux.ManagerId__c);
                    extorg62Id.add(ux.Mgmt_Chain_Level_02_c__c);
                    extorg62Id.add(ux.Mgmt_Chain_Level_03_c__c);
                    extorg62Id.add(ux.Mgmt_Chain_Level_04_c__c);
                    extorg62Id.add(ux.Mgmt_Chain_Level_05_c__c);
                    extorg62Id.add(ux.Mgmt_Chain_Level_06_c__c);
                    extorg62Id.add(ux.Mgmt_Chain_Level_07_c__c);
                    extorg62Id.add(ux.Mgmt_Chain_Level_08_c__c);
                    extorg62Id.add(ux.Mgmt_Chain_Level_09_c__c);
                    extorg62Id.add(ux.Mgmt_Chain_Level_10_c__c);
                    extorg62Id.add(ux.Mgmt_Chain_Level_11_c__c);
                    extorg62Id.add(ux.Mgmt_Chain_Level_12_c__c);
                }
            }


            Map<Id,User> existingUsersMap = new Map<Id,User>();
            Map<String,User> existingFedId = new Map<String,User>();
            Map<String,User> existingUsersNoExternalIdMap = new Map<String,User>();
            for (User u: [select Id, Email, FirstName, LastName,FederationIdentifier,org62Id__c,LastModifiedDate,IsActive from User where (org62Id__c in: extorg62Id) ]) { 
                if (u.org62Id__c != null) {
                    existingUsersMap.put(u.org62Id__c, u);
                } else {
                    //TODO: find org62Id by matching on first/last name
                    existingUsersNoExternalIdMap.put(u.FirstName+u.LastName,u);
                }
                if (u.FederationIdentifier != null) {
                    existingFedId.put(u.FederationIdentifier,u);
                }
            }
            System.debug(LoggingLevel.INFO,'existing users '+existingUsersMap.size());
            System.debug(LoggingLevel.INFO,'existing fed id '+existingFedId.size());
            Util.inFutureContext = true;
            UserContactUtil.doNotExecuteTrigger = true;
            
            //sync mgr users first 
            syncMgrUsers(extUsers, existingUsersMap, existingFedId);
            System.debug(LoggingLevel.INFO,'mgrs synced');
            
            //Map<String, List<UserSync__mdt>> config = OrgRefresh_Util.getCommunities(); 
            
            //sync users
            List<User> updLs = new List<User>();
            List<User> insLs = new List<User>();
            List<Id> freezeIds = new List<Id>();
            for (User__x externalUser : extUsers) { 
                System.debug(LoggingLevel.INFO,'existingUsersMap.containsKey(externalUser.ExternalId) ' + externalUser.ExternalId + externalUser.FederationIdentifier__c +
                        ' user map:: ' + existingUsersMap.containsKey(externalUser.ExternalId) + 
                        ' fed id map:: ' + existingFedId.containsKey(externalUser.FederationIdentifier__c));
                if (existingUsersMap.containsKey(externalUser.ExternalId) || existingFedId.containsKey(externalUser.FederationIdentifier__c)) { 
                    System.debug(LoggingLevel.INFO,'user exists ' + externalUser.ExternalId + externalUser.FederationIdentifier__c);
                    User existingUser = existingUsersMap.get(externalUser.ExternalId); 
                    if (existingUser == null) {
                        existingUser = existingFedId.get(externalUser.FederationIdentifier__c); 
                    }
                    
                    setupUser(existingUser, externalUser, false);
                        
                    setManagerIds(existingUser, existingUsersMap, externalUser);
                    if (externalUser.IsActive__c) {
                        getCommunityRole(existingUser, externalUser, config);
                    }
                    
                    updLs.add(existingUser);  
                } else if (externalUser.IsActive__c) {
                    System.debug(LoggingLevel.INFO,'user does not exist ' + externalUser);
                    
                    User u = setupUser(new User(), externalUser, true);
                    
                    setManagerIds(u, existingUsersMap, externalUser);    
                    getCommunityRole(u, externalUser, config);    
                    insLs.add(u);
                }
            }
            
            //updateusers
            if (updLs.size() > 0) {
                System.debug(LoggingLevel.INFO,'update users ' + updLs);
                try {
                    Database.update(updLs, false);
                } catch (Exception e) {
                    System.debug(LoggingLevel.INFO,'update users error ' + e);
                    errorLog += 'User update failed: '+e+'\n ';
                }
            } 
            if (insLs.size() > 0) {
                System.debug(LoggingLevel.INFO,'insert users ' + insLs);
                //insert insLs; 
                Database.SaveResult[] srList = Database.insert(insLs, false);

                // Iterate through each returned result
                Set<Id> userSet = new Set<Id>();
                Integer i = 0;
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug(LoggingLevel.INFO,'Successfully inserted user. User ID: ' + sr.getId());
                        userSet.add(sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                           System.debug(LoggingLevel.ERROR,'The following error has occurred. ' + insLs.get(i));                    
                            System.debug(LoggingLevel.ERROR,err.getStatusCode() + ': ' + err.getMessage());
                            System.debug(LoggingLevel.ERROR,'User fields that affected this error: ' + err.getFields());
                            errorLog += err.getStatusCode() + ': ' + err.getMessage();
                        }
                    }
                    i++;
                }
                
                List<User> failedLineItems = new List<User>();
                for (User  li : insLs) {
                    if (!userSet.contains(li.Id)) {
                        failedLineItems.add(li);
                        System.debug(LoggingLevel.ERROR,'User insert failed ' + li);
                        errorLog += 'User insert failed '+li.username+li.email+'\n ';
                    }
                }
                
            }
            
            System.debug(LoggingLevel.INFO,'execute end job id ' + jobId);
        }
        
    /**
     @description : Finish method of the batch class
     @param bc - Database.BatchableContext
     */
        global void finish(Database.BatchableContext bc) {
             
            if (jobId == null) {
                jobId = lp_JobStatus_SVC.createJobStatus('User sync');
            }
            System.debug(LoggingLevel.INFO,'job id ' + jobId);
           
            updateJobStatusLog(jobId, bc, errorLog);
            System.debug(LoggingLevel.INFO,'in finish method - updating onboarding records');
            Org62OnboardingSync onboarding = new Org62OnboardingSync();
            //onboarding.query = 'SELECT Id, Name, User_Record__c, User_Record__r.IsActive, (SELECT Id, Name, Candidate__c, Contact__c, Level__c, CSG_Role_Community__c FROM PA_Onboarding__r) ' + 
            //        ' FROM Contact WHERE User_Record__r.LastModifiedDate = TODAY and User_Record__r.JobCode__c != null'; 
            
            onboarding.query = 'SELECT Id, Name, IsActive, CSG_Role__c, Community__c, (SELECT Id, Name, Candidate__c, Contact__c, Level__c, CSG_Role_Community__c FROM PA_Onboardings__r), ' +
                      ' (SELECT Id, Name, User_Record__c from ContactRecord__r) FROM User WHERE LastModifiedDate =TODAY and JobCode__c != null'; 
            Database.executeBatch(onboarding, 5);
        }

         /**
         @description : updateJobStatusLog
 		 @param jobId - Id
         @param bc - Database.BatchableContext
         @param errorLog - String
        */    
        public static void updateJobStatusLog(Id jobId, Database.BatchableContext bc, String errorLog) {
            String resultString = '';
            
            // Query the AsyncApexJob object to retrieve the current job's information.
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus
                              FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                              
            // Construct results string
            // Add First Error
            if (a != null && a.ExtendedStatus != null)
                resultString = a.ExtendedStatus + '\n\n';
            else
                resultString = '';
                
            // Add Rest of Errors
            if (errorLog != ''){
                resultString = resultString + 'ErrorLog: \n' + errorLog + '\n\n';
            }
            
            // Add Final Results
            resultString = resultString + 'The batch Apex job processed ' + a.TotalJobItems +
                             ' batches with '+ a.NumberOfErrors + ' failures.';
                             
            // Construct status string
            String status = a.NumberOfErrors > 0 ? 'Failed' : 'Completed';
            
            // Update Job Status Job 
            lp_JobStatus_SVC.finishJobStatus(jobId, status, resultString, a.TotalJobItems, a.NumberOfErrors);
        }
        
        global class UserIterable implements Iterable<User__x> {
            
            public String query; 
            public String endQuery; 
            
            global UserIterable (String query,String endQuery){
                 this.query = query;
                 this.endQuery = endQuery;
             }
             /**
             @description : iterator
             @return : Iterator<User__x> 
            */  
            global Iterator<User__x> iterator(){
                return new UserIterator(query,endQuery);
            }
        }
 
        global class UserIterator implements Iterator<User__x> {
            User__x[] results {get;set;}
            Integer index {get; set;} 
     
            global UserIterator(String query,String endQuery) {
                index = 0;
                System.debug(LoggingLevel.INFO,'iterator query ' + query);
                query += 'OR ( is_SSO_User__c = true ) )) ';
		    
                query += endQuery;
                System.debug(LoggingLevel.INFO,'Where query is: '+query.substring(801, query.length()-1));
                results = Database.query(query); 
                if(Test.isRunningTest()){ 
                    //Query Users 
                    results = ObjectManagerMock.records([SELECT Id, FirstName__c,LastName__c,Title__c, Username__c,Email__c,externalId FROM User__x]); 
                }

                System.debug(LoggingLevel.INFO,'iterator query size ' + results.size());    
            } 
 			
            /**
            @description : hasNext
		    @return : boolean
            */ 
            global boolean hasNext(){ 
               return results != null && !results.isEmpty() && index < results.size(); 
            }  
            
 			 /**
            @description : next
			@return : User__x
            */ 
            global User__x next(){ 
                System.debug(LoggingLevel.INFO,'iterator next'+ results.size()+':index:'+index);
                return results[index++];      
                /*if (index == 100) {return null;} 
                   index++; 
                   return results[index-1]; */      
            }       
        } 
        
         /**
         @description : getManagerDetails
 		 @param mgrs - Set<Id>
        */ 
        private Map<Id, User__x> getManagerDetails(Set<Id> mgrs) {
            Map<Id, User__x> mgrmap = new Map<Id, User__x>();
            //updated the query to include double right paranthesis
            String qry = selectString + ' ExternalId in : mgrs )) )  ';
            System.debug(LoggingLevel.INFO,'getManagerDetails qry : ' + qry);
            List<User__x> uls = Database.query(qry);
            for (User__x ux : uls) {
                mgrmap.put(ux.ExternalId, ux);
            }
            return mgrmap;
        }  
		
         /**
         @description : syncMgrUsers 
         @param scope - List<User__x> 
         @param existingUsers - Map<Id,User>
         @param existingFedId - Map<String,User>
		 @return - Map<Id,User>
         */
        private Map<Id,User> syncMgrUsers(List<User__x> scope, Map<Id,User> existingUsers, Map<String,User> existingFedId) {
            Set<Id> mgrs = new Set<Id>();
            Set<Id> insLs = new Set<Id>();
            List<User> users = new List<User>();
            for (User__x externalUser : scope) {
                //insert update list
                System.debug(LoggingLevel.INFO,'sync mgr ::mgr user id ' + externalUser.ManagerId__c);
                
                if (externalUser.ManagerId__c != null) {
                    System.debug(LoggingLevel.INFO,'sync mgr :: mgr org62 id ' +  externalUser.ManagerId__c);
                    //System.debug('sync mgr ::fed id ' + externalUser.FederationIdentifier__c);
                    if (!existingUsers.containsKey(externalUser.ManagerId__c)) { 
                        insLs.add(externalUser.ManagerId__c);
                    } else {
                        mgrs.add(externalUser.ManagerId__c);
                    }
                }
                System.debug(LoggingLevel.INFO,'mgmt chain users ' + externalUser.Mgmt_Chain_Level_04_c__c + externalUser.Mgmt_Chain_Level_05_c__c
                    + externalUser.Mgmt_Chain_Level_06_c__c + externalUser.Mgmt_Chain_Level_07_c__c);
                    
                 if (externalUser.Mgmt_Chain_Level_02_c__c != null) {
                    if (!existingUsers.containsKey(externalUser.Mgmt_Chain_Level_02_c__c)) {
                        insLs.add(externalUser.Mgmt_Chain_Level_02_c__c); 
                    } else {
                        mgrs.add(externalUser.Mgmt_Chain_Level_02_c__c);
                    }
                }
                
                if (externalUser.Mgmt_Chain_Level_03_c__c != null) {
                    if (!existingUsers.containsKey(externalUser.Mgmt_Chain_Level_03_c__c)) {
                        insLs.add(externalUser.Mgmt_Chain_Level_03_c__c); 
                    } else {
                        mgrs.add(externalUser.Mgmt_Chain_Level_03_c__c);
                    }
                }
                if (externalUser.Mgmt_Chain_Level_04_c__c != null) {
                    if (!existingUsers.containsKey(externalUser.Mgmt_Chain_Level_04_c__c)) {
                        System.debug(LoggingLevel.INFO,'mgr users insert 4' + externalUser.Mgmt_Chain_Level_04_c__c );
                        insLs.add(externalUser.Mgmt_Chain_Level_04_c__c);
                    } else {
                        mgrs.add(externalUser.Mgmt_Chain_Level_04_c__c);
                    }
                }
                    
                if (externalUser.Mgmt_Chain_Level_05_c__c != null) {
                    if (!existingUsers.containsKey(externalUser.Mgmt_Chain_Level_05_c__c)) {
                        System.debug(LoggingLevel.INFO,'mgr users insert 5' + externalUser.Mgmt_Chain_Level_05_c__c );
                        insLs.add(externalUser.Mgmt_Chain_Level_05_c__c);
                    } else {
                        mgrs.add(externalUser.Mgmt_Chain_Level_05_c__c);
                    }
                }
                
                if (externalUser.Mgmt_Chain_Level_06_c__c != null) {
                    if (!existingUsers.containsKey(externalUser.Mgmt_Chain_Level_06_c__c)) {
                        insLs.add(externalUser.Mgmt_Chain_Level_06_c__c);
                    } else {
                        mgrs.add(externalUser.Mgmt_Chain_Level_06_c__c);
                    }
                }
                
                if (externalUser.Mgmt_Chain_Level_07_c__c != null) {
                    if (!existingUsers.containsKey(externalUser.Mgmt_Chain_Level_07_c__c)) {
                        insLs.add(externalUser.Mgmt_Chain_Level_07_c__c);
                    } else {
                        mgrs.add(externalUser.Mgmt_Chain_Level_07_c__c);
                    }
                }
                
                if (externalUser.Mgmt_Chain_Level_08_c__c != null) {
                    if (!existingUsers.containsKey(externalUser.Mgmt_Chain_Level_08_c__c)) {
                        insLs.add(externalUser.Mgmt_Chain_Level_08_c__c);
                    } else {
                        mgrs.add(externalUser.Mgmt_Chain_Level_08_c__c);
                    }
                }
                if (externalUser.Mgmt_Chain_Level_09_c__c != null) {
                    if (!existingUsers.containsKey(externalUser.Mgmt_Chain_Level_09_c__c)) {
                        insLs.add(externalUser.Mgmt_Chain_Level_09_c__c);
                    } else {
                        mgrs.add(externalUser.Mgmt_Chain_Level_09_c__c);
                    }
                }
                if (externalUser.Mgmt_Chain_Level_10_c__c != null) {
                    if (!existingUsers.containsKey(externalUser.Mgmt_Chain_Level_10_c__c)) {
                        insLs.add(externalUser.Mgmt_Chain_Level_10_c__c);
                    } else {
                        mgrs.add(externalUser.Mgmt_Chain_Level_10_c__c);
                    }
                }
                if (externalUser.Mgmt_Chain_Level_11_c__c != null) {
                    if (!existingUsers.containsKey(externalUser.Mgmt_Chain_Level_11_c__c)) {
                        insLs.add(externalUser.Mgmt_Chain_Level_11_c__c);
                    } else {
                        mgrs.add(externalUser.Mgmt_Chain_Level_11_c__c);
                    }
                }
                if (externalUser.Mgmt_Chain_Level_12_c__c != null) {
                    if (!existingUsers.containsKey(externalUser.Mgmt_Chain_Level_12_c__c)) {
                        insLs.add(externalUser.Mgmt_Chain_Level_12_c__c);
                    } else {
                        mgrs.add(externalUser.Mgmt_Chain_Level_12_c__c);
                    }
                }
                
            }
            System.debug(LoggingLevel.INFO,'sync mgr :: ins list :: '+ insLs);
            System.debug(LoggingLevel.INFO,'sync mgr :: upd list :: '+ mgrs);
            if (insLs.size() > 0) {
                System.debug(LoggingLevel.INFO,'mgr ins size ' + insLs.size());
                insertMgrUsers(existingUsers, insLs);
            } 
            
            if (mgrs.size() > 0) {
               System.debug(LoggingLevel.INFO,'mgr upd size ' + mgrs.size());
                //updateMgrUsers(existingUsers, mgrs);
            }
            
            return existingUsers;
        }
        
        /**
         @description : insertMgrUsers 
         @param existingUsers - Map<Id,User>
         @param mgrs - Set<Id>
         */
		@testVisible
        private void insertMgrUsers(Map<Id,User> existingUsers, Set<Id> mgrs) {
            //get Manager name/email/title
            Map<Id,User__x> mgrUsers = getManagerDetails(mgrs);

            List<User> users = new List<User>();
            
            for (Id key : mgrUsers.keySet()) {
                User__x externalUser = mgrUsers.get(key);
                if (externalUser.IsActive__c) {
                    User u = setupUser(new User(), externalUser, true);
                
                    setManagerIds(u, existingUsers, externalUser);
                
                    users.add(u);
                }
            }
            //insert mgr users
            if (users.size() > 0) {
                System.debug(LoggingLevel.INFO,'insert mgr users ' + users); 
                //insert users;
                //System.debug('mgrs inserted ');
                Database.SaveResult[] srList = Database.insert(users, false);

                // Iterate through each returned result
                Set<Id> userSet = new Set<Id>();
                Integer i=0;
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug(LoggingLevel.INFO,'Successfully inserted user. user ID: ' + sr.getId());
                        User u = users.get(i);
                        u.Id = sr.getId();
                        existingUsers.put(u.Org62Id__c, u);
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(LoggingLevel.ERROR,'The following error has occurred.' + users.get(i));                    
                            System.debug(LoggingLevel.ERROR,err.getStatusCode() + ': ' + err.getMessage());
                            System.debug(LoggingLevel.ERROR,'Mgr User fields that affected this error: ' + err.getFields());
                            errorLog += 'Mgr insert failed '+err.getStatusCode() + ': ' + err.getMessage()+'\n ';
                        }
                    }
                    i++;
                }
                
            }
            
        }
        
        /**
         @description : setupUser 
         @param u - User
         @param externalUser - User__x
		 @param ins - Boolean
         */
        public User setupUser(User u, User__x externalUser, Boolean ins) {
            if (ins) {
                String un = externalUser.Username__c;
                un = un.replace('@salesforce.com', '@sfservices.com');
                u.FirstName = externalUser.FirstName__c;
                u.LastName = externalUser.lastName__c;
                u.Username = un;
                u.Email = externalUser.Email__c;
                u.Alias = externalUser.Alias__c;
                u.ProfileId = defaultProfile;
                u.CommunityNickname = externalUser.CommunityNickname__c;
                u.LanguageLocaleKey = externalUser.LanguageLocaleKey__c;
                u.LocaleSidKey = externalUser.LocaleSidKey__c;
                u.TimeZoneSidKey = externalUser.TimeZoneSidKey__c;
                u.EmailEncodingKey = externalUser.EmailEncodingKey__c;
            }
            if (!ins && u.Email != externalUser.Email__c) {
                u.Email = externalUser.Email__c;
            }
            u.FederationIdentifier = externalUser.FederationIdentifier__c;
            u.Department = externalUser.Department__c;
            u.IsActive = externalUser.IsActive__c;
            u.Title = externalUser.Title__c;
            u.Hire_Date__c = externalUser.Hire_Date_c__c;
            u.JobCode__c = externalUser.JobCode_c__c;
            u.BU__c = externalUser.BU_c__c;
            u.Business_Unit__c = externalUser.Business_Unit_c__c;
            u.JobFamily__c = externalUser.JobFamily_c__c;
            u.JobProfile__c = externalUser.JobProfile_c__c; //GR:Sep 17, 2018 to map XD
            u.Support_Subgroup__c = externalUser.Support_Subgroup_c__c; //GR:Nov 26, 2018 to map specialists
            u.JobGrade__c = externalUser.JobGrade_c__c;
            u.Street = externalUser.Street__c;
            u.City = externalUser.City__c;
            u.State = externalUser.State__c;
            u.PostalCode = externalUser.PostalCode__c;
            u.Country = externalUser.Country__c;
            u.Org62Id__c = externalUser.ExternalId;
            u.Continuous_Service_Date__c = externalUser.Continuous_Service_Date_c__c;
            u.Phone = externalUser.Phone__c;
            u.Is_LOA__c = externalUser.Sick_Leave_c__c;
            u.Acquired_Company__c = externalUser.Acquired_Company_c__c;
            u.Skill_Type__c = externalUser.Skill_Type_c__c;
            u.Primary_Coverage_Country__c = externalUser.Coverage_Country_c__c;//SCT 08-27-2020 add map to PCC data
            
            System.debug(LoggingLevel.INFO,'setup user for insert ' + ins + '::' + u);
            return u;
        }
        
        /**
         @description : updateMgrUsers 
         @param existingUsers - Map<Id,User>
		 @param mgrs - Set<Id>
         */
		@testVisible
        private void updateMgrUsers(Map<Id,User> existingUsers, Set<Id> mgrs) {
            System.debug(LoggingLevel.INFO,'updateMgrUsers ' + mgrs);
            //get Manager name/email/title
            Map<Id,User__x> mgrUsers = getManagerDetails(mgrs);
            List<User> users = new List<User>();
            List<Id> freezeIds = new List<Id>();
            for (Id key : mgrUsers.keySet()) {
            
                User__x externalUser = mgrUsers.get(key); 
            
                User u = existingUsers.get(key);
                
                setupUser(u, externalUser, false);
                setManagerIds(u, existingUsers, externalUser);
                
                users.add(u);
            }
            //update mgr users
            if (users.size() > 0) {
                System.debug(LoggingLevel.INFO,'update mgr users ' + users);
                try {
                    Database.update(users, false);
                } catch (Exception e) {
                    System.debug(LoggingLevel.ERROR,'Mgr update error ' + e);
                    errorLog += 'Mgr update failed: '+e+'\n ';
                }
            }

        }
        
        /**
         @description : getCommunityRole 
         @param u - User
		 @param extU - User__x
		 @param config - Map<String, List<UserSync__mdt>>
         */
        public void getCommunityRole(User u, User__x extU, Map<String, List<UserSync__mdt>> config) {
            Boolean match = false;
            String role = '';
            //Map<String, List<UserSync__mdt>> config = OrgRefresh_Util.getCommunities(); 
            //Map<String, List<UserSync__mdt>> roles = OrgRefresh_Util.getRoles(key);
            System.debug(LoggingLevel.INFO,'getcommunity role  ' + u );
            for (String community : config.keySet()) {
                if (community != 'CSG') {
                    System.debug(LoggingLevel.INFO,'getcommunity role :: community: ' + community );
                    //Map<String, List<UserSync__mdt>> roles = OrgRefresh_Util.getRoles(community);
                    Map<String, List<UserSync__mdt>> roles = OrgRefresh_Util.getRoles(config.get(community));
                    for (String r : roles.keySet()) {
                        for (UserSync__mdt m : roles.get(r)) {
                            String fldName = m.Field_API_name__c;
                            String fldOp = m.Field_Operator__c;
                            String fldVal = m.Field_Values__c;
                            role = m.Role__c; 
                           System.debug(LoggingLevel.INFO,  'match ' + m.Field_API_name__c + 'fldop '+m.Field_Operator__c+' fldval '+m.Field_Values__c);
                            if (String.valueOf(extU.get(fldName)) != null) {
                                match = OrgRefresh_Util.matchRuleCriteria(fldOp, String.valueOf(extU.get(fldName)), fldVal, fldName);
                                System.debug(LoggingLevel.INFO,'matched ' + match);
                            }
                            if (!match) {
                                break; 
                             }
                        }
                        System.debug(LoggingLevel.INFO,'match role ' + r + match); 
                        if (match) {
                            System.debug(LoggingLevel.INFO,'community role ' + role);
                            u.Community__c = community;
                            u.CSG_Role__c = role;
                            break; 
                        }
                    }
                    if (match) {
                        System.debug(LoggingLevel.INFO,'community role match found ' + community + role);
                        break;
                    }
                }
            }
            
            System.debug(LoggingLevel.INFO,'community role ' + role);  
            return;
            
        }
        
        /**
         @description : setManagerIds 
         @param existingUser - User
		 @param existingUsersMap - Map<Id,User>
		 @param externalUser - User__x
         */
        private void setManagerIds(User existingUser, Map<Id,User> existingUsersMap, User__x externalUser) {
           
            existingUser.Mgmt_Chain_Hierarchy_Level_02__c = externalUser.Mgmt_Chain_Level_02_c__c !=null ? (existingUsersMap.get(externalUser.Mgmt_Chain_Level_02_c__c) != null ? existingUsersMap.get(externalUser.Mgmt_Chain_Level_02_c__c).Id :  existingUser.Mgmt_Chain_Hierarchy_Level_02__c    ) : null ;
            
            existingUser.Mgmt_Chain_Hierarchy_Level_03__c = externalUser.Mgmt_Chain_Level_03_c__c !=null ? (existingUsersMap.get(externalUser.Mgmt_Chain_Level_03_c__c) != null ? existingUsersMap.get(externalUser.Mgmt_Chain_Level_03_c__c).Id :  existingUser.Mgmt_Chain_Hierarchy_Level_03__c    ) : null ;
            
            existingUser.Mgmt_Chain_Hierarchy_Level_04__c = externalUser.Mgmt_Chain_Level_04_c__c !=null ? (existingUsersMap.get(externalUser.Mgmt_Chain_Level_04_c__c) != null ? existingUsersMap.get(externalUser.Mgmt_Chain_Level_04_c__c).Id :  existingUser.Mgmt_Chain_Hierarchy_Level_04__c    ) : null ;
            
	    existingUser.Mgmt_Chain_Hierarchy_Level_05__c = externalUser.Mgmt_Chain_Level_05_c__c !=null ? (existingUsersMap.get(externalUser.Mgmt_Chain_Level_05_c__c) != null ? existingUsersMap.get(externalUser.Mgmt_Chain_Level_05_c__c).Id :  existingUser.Mgmt_Chain_Hierarchy_Level_05__c ) : null ;
         
            existingUser.Mgmt_Chain_Hierarchy_Level_06__c = externalUser.Mgmt_Chain_Level_06_c__c !=null ? (existingUsersMap.get(externalUser.Mgmt_Chain_Level_06_c__c) != null ? existingUsersMap.get(externalUser.Mgmt_Chain_Level_06_c__c).Id :  existingUser.Mgmt_Chain_Hierarchy_Level_06__c ) : null ;
            
            existingUser.Mgmt_Chain_Hierarchy_Level_07__c = externalUser.Mgmt_Chain_Level_07_c__c !=null ? (existingUsersMap.get(externalUser.Mgmt_Chain_Level_07_c__c) != null ? existingUsersMap.get(externalUser.Mgmt_Chain_Level_07_c__c).Id :  existingUser.Mgmt_Chain_Hierarchy_Level_07__c ) : null ;
          
            existingUser.Mgmt_Chain_Hierarchy_Level_08__c = externalUser.Mgmt_Chain_Level_08_c__c !=null ? (existingUsersMap.get(externalUser.Mgmt_Chain_Level_08_c__c) != null ? existingUsersMap.get(externalUser.Mgmt_Chain_Level_08_c__c).Id :  existingUser.Mgmt_Chain_Hierarchy_Level_08__c ) : null ;
            
            existingUser.Mgmt_Chain_Hierarchy_Level_09__c = externalUser.Mgmt_Chain_Level_09_c__c !=null ? (existingUsersMap.get(externalUser.Mgmt_Chain_Level_09_c__c) != null ? existingUsersMap.get(externalUser.Mgmt_Chain_Level_09_c__c).Id :  existingUser.Mgmt_Chain_Hierarchy_Level_09__c ) : null ;
            
            existingUser.Mgmt_Chain_Hierarchy_Level_10__c = externalUser.Mgmt_Chain_Level_10_c__c !=null ? (existingUsersMap.get(externalUser.Mgmt_Chain_Level_10_c__c) != null ? existingUsersMap.get(externalUser.Mgmt_Chain_Level_10_c__c).Id :  existingUser.Mgmt_Chain_Hierarchy_Level_10__c ) : null ;
            
            
            existingUser.Mgmt_Chain_Hierarchy_Level_11__c = externalUser.Mgmt_Chain_Level_11_c__c !=null ? (existingUsersMap.get(externalUser.Mgmt_Chain_Level_11_c__c) != null ? existingUsersMap.get(externalUser.Mgmt_Chain_Level_11_c__c).Id :  existingUser.Mgmt_Chain_Hierarchy_Level_11__c ) : null ;

            
            existingUser.Mgmt_Chain_Hierarchy_Level_12__c = externalUser.Mgmt_Chain_Level_12_c__c !=null ? (existingUsersMap.get(externalUser.Mgmt_Chain_Level_12_c__c) != null ? existingUsersMap.get(externalUser.Mgmt_Chain_Level_12_c__c).Id :  existingUser.Mgmt_Chain_Hierarchy_Level_12__c ) : null ;

            
            if (externalUser.ManagerId__c !=null && existingUsersMap.get(externalUser.ManagerId__c) != null)  {
                existingUser.ManagerId = existingUsersMap.get(externalUser.ManagerId__c).Id;
            }  
                
        }
        
        
    }