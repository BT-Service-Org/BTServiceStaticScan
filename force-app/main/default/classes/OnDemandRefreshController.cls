public class OnDemandRefreshController {
        public PA_Onboarding__c paRecord {get; set;}
        
        public List<OrgRefresh_BatchResult> finalResults {get; set;}
        public Boolean completed {get; set;}
        public Boolean recalculationDone {get; set;}
    

// CJT Adding field for Next Available PA Staff date: Contact__r.Employee_ID__c
        private static string query='select  id, Contact__c, Contact__r.Employee_ID__c, Contact__r.Email, ' +
                    ' Mentor__c, Mentor__r.Email, name, Next_Available_Date__c , Available_to_Staff_as_PA__c ' +
                    'from PA_Onboarding__c ' +
                    'where Contact__c!=null ' + 
                            'and Contact__r.Email!=null ' +
                            'and Contact__r.Email!=\'\'' +
                            'and (not Name like \'%Template%\')';

        public OnDemandRefreshController(ApexPages.StandardController stdCtlr){
                String soqlStr = query+' and Id=:recId';
                String recId =stdCtlr.getId();
                this.paRecord = Database.query(soqlStr);        
                completed = false;
        recalculationDone = false;
        }
        
        public PageReference refreshCerts(){
        initDisplay();
                String orgAppName ='Cert Org_Cert';
                return refresh(orgAppName);
        }
        
        public PageReference refreshBadges(){
                initDisplay();
        String orgAppName ='org62_Badges';
                return refresh(orgAppName);
        }


        public PageReference refreshProjects(){
                initDisplay();
        String orgAppName ='org62_Projects';
                return refresh(orgAppName);
        }

        public PageReference updateOrg62(){
        initDisplay();
                System.debug('============= Update Org62 Contact Rec ===================' );
                String orgAppName ='org62_AvailStaff';
                return refresh(orgAppName);
        }
        
        public PageReference refreshCSAT(){
                initDisplay();
        String orgAppName ='org62_CSAT';
                return refresh(orgAppName);
        }
                
        public PageReference refreshCSATMultiple(){
                initDisplay();
                String orgAppName ='org62_CSAT';
                return refreshMultiple(orgAppName);
        }
    
    public PageReference recalculateMissedMilestones()
    {
        initDisplay();
        List<Id> consultantIds = new List<Id>();
        consultantIds.add(this.paRecord.id);
        
        lp_ConsultantMilestone_SVC.recalulateMilestoneByConsultant(consultantIds);
        recalculationDone  = true;
        return null;
    }
        
    private PageReference refresh(String orgAppName){
        
        OrgRefresh_QueryUtils.setOrgAppName(orgAppName);
        Org_Refresh_Profile__c refreshProfInstance=OrgRefresh_QueryUtils.getRefreshProfile();                   
        String accessToken=OrgRefresh_AuthUtils.authenticateUser(refreshProfInstance);
        System.debug('accessToken:' + accessToken);
                /*
                        if (accessToken == null)
                                throw new OrgRefresh_CertOrg_CertBatchFetch_Exception('Could not retrieve access token.');
                */
        List<PA_Onboarding__c> paList = new List<PA_Onboarding__c>();
        paList.add(paRecord);
        OrgRefresh_BatchInterface fetcher = OrgRefresh_QueryUtils.getBatchInstance(orgAppName); 
        finalResults = fetcher.fetchAndUpdateData(paList, accessToken, orgAppName,true);
        completed = true;
        return null;
    }       
        
    
    private PageReference refreshMultiple(String orgAppName){
        
        List<String> emailList = new List<String> {'anarasimhan@salesforce.com', 'mnewman@salesforce.com', 'jonathan.reed@salesforce.com', 'dthong@salesforce.com'};
            
        OrgRefresh_QueryUtils.setOrgAppName(orgAppName);
        Org_Refresh_Profile__c refreshProfInstance=OrgRefresh_QueryUtils.getRefreshProfile();                   
        String accessToken=OrgRefresh_AuthUtils.authenticateUser(refreshProfInstance);
        System.debug('accessToken:' + accessToken);
                /*
                        if (accessToken == null)
                                throw new OrgRefresh_CertOrg_CertBatchFetch_Exception('Could not retrieve access token.');
                */
                List<PA_Onboarding__c> paList = (List<PA_Onboarding__c>) [Select id, Available_to_Staff_as_PA__c, Next_Available_Date__c, 
                                                                                 contact__r.email, Contact__r.LastName 
                                                        from PA_Onboarding__c 
                                                        where Contact__c!=null 
                                                        and Contact__r.Email!=null 
                                                        and Status__c = 'Deployed PA'
                                                        and Contact__r.Email IN :emailList 
                                                        and (not Name like '%Template%')];
                        
                OrgRefresh_BatchInterface fetcher = OrgRefresh_QueryUtils.getBatchInstance(orgAppName); 
                finalResults = fetcher.fetchAndUpdateData(paList, accessToken, orgAppName,true);
                completed = true;
                return null;
    }    

    private void initDisplay() 
    {
        completed = false;
        recalculationDone = false;
    }
}