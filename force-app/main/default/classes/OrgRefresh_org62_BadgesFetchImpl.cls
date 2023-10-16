/**
 * Classes that implement OrgRefresh_FetchInterface have a naming pattern to be followed for the code to function properly.
 * OrgRefresh_<ORGNAME>_<APPNAME>FetchImpl. Please name the appname and org name concise.
 * 
 */
public with sharing class OrgRefresh_org62_BadgesFetchImpl implements OrgRefresh_FetchInterface, OrgRefresh_BatchInterface {
    /**
     * Method to construct the dynamic query based on the settings defined in the custom settings.
     */
    // set this to false if you want to update the timestamp outside of the class
    private List<PA_Onboarding__c> paList {get; set;} 
    private Org_Refresh_Profile__c refreshProfile;

    /* Constructor */  
    // default the pa onboarding list
    public OrgRefresh_org62_BadgesFetchImpl() { 
    }
    
    public string constructSourceQuery() {
        return 'select  id '+
                     ', Contact__c '+
                     ', Contact__r.Email '+
                     ', name ' +
                    'from PA_Onboarding__c '+ 
                    'where Contact__c!=null '+ 
                       'and Contact__r.Email!=null '+ 
                       'and Contact__r.Email!=\'\' '+
                       //'and Program__c in (\'Accelerated Onboarding\', \'PA Track\', \'CTA Prep\', \'Existing PA\',\'Practices\',\'BA Ramp\') ' +
                       'and Active_User__c = true '+
                       'and Exclude_Badge_Updates__c = false';
    }
    
    
    public string constructQuery(String orgAppName, boolean fullRefresh){
        System.debug('====OrgRefresh_CertOrgCertFetchImpl constructQuery====');
          
        String queryStr=OrgRefresh_QueryUtils.constructBaseQuery(fullRefresh);
        
        String queryClause = ' and ';
        String whereClause = '';
        if (queryStr.indexOf('where') < 0) 
            queryClause = ' where ';
        else
            whereClause = queryStr.substring(queryStr.indexOf('where'));

        if(whereClause!=null && !whereClause.contains('User__r.Email')){
            queryStr+= queryClause + constructEmailList();
            queryClause = ' and ';
        }

        /* GR: commented so we can query all badges instead of a fixed list from custom settings.
        if(whereClause!=null && !whereClause.contains('Badge__r.Name')){
            queryStr+= queryClause + constructBadgeList();
        }*/

        System.debug('=====queryStr======' + queryStr);
        return queryStr;
    }

     private String constructEmailList(){
        List<String> contactEmails=new List<String>();
            
        for(PA_Onboarding__c paOnboard: paList){
               contactEmails.add(paOnboard.Contact__r.Email);
        }
        String emailStr=' User__r.Email in ';
        emailStr+=OrgRefresh_QueryUtils.convertListToStr(contactEmails);
        return emailStr;
    }
    
    /*private String constructBadgeList() {
        List<String> badgeList=new List<String>();
        
        for (PA_Badges__c b : [select name, Badge_Name__c, is_learning_path__c from PA_Badges__c]) {
            badgeList.add(b.badge_name__c);         
        }
        String badgeStr=' Badge__r.Name in ';
        badgeStr+=OrgRefresh_QueryUtils.convertListToStr(badgeList);
        return badgeStr;
    }*/

    public void fetchAndUpdateData(String accessToken,String orgAppName){  
        System.debug('inside fetch and update');
        List<SObject> inputList = Database.query(constructSourceQuery());
        List<OrgRefresh_BatchResult> result = 
                fetchAndUpdateData(inputList, accessToken, orgAppName, false);
    } 

    public List<OrgRefresh_BatchResult> fetchAndUpdateData(List<SObject> candidateList, String accessToken,String orgAppName, boolean fullRefresh){
        this.paList = (List<PA_OnBoarding__c>)candidateList;
        System.debug('====OrgRefresh_CertOrgCertFetchImpl fetchAndUpdateData====');
         //set the orgname
        OrgRefresh_QueryUtils.setOrgAppName(orgAppName);
        //final list to store org62 badge information
        final List<OrgRefresh_org62BadgesBean> org62Badges=new List<OrgRefresh_org62BadgesBean>();
        //call out counter
        Integer calloutCntr=0;
         //variable to store the done flag
        Boolean isRecordFetchDone=false;
        //variable to store next set of records in Rest API
        String nextRecordsUrl='';

        List<OrgRefresh_BatchResult> finalResults = new List<OrgRefresh_BatchResult>();
          
        System.debug('===Access_Token__c in HTTP====' + accessToken);
        //fetch the org defaults settings
            
        refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile();

        if(refreshProfile!=null){
            String Url=refreshProfile.Instance_URL__c + '/services/data/v29.0/query/';
            do{
                String body=OrgRefresh_QueryUtils.executeQuery(url,accessToken,constructQuery(orgAppName, fullRefresh));
                System.debug('body after execute Query: ' + body);
                //do regex replace to replace all __c and __r references so that JSON can directly be read into bean class.
                body=body.replace('__c','');
                body=body.replace('__r','');
                  
                JSONParser parser = JSON.createParser(body);
                
                do{
              
                    if(parser.getCurrentName()=='done'){
                        isRecordFetchDone=(parser.getText()=='true');
                    }
              
                    if(parser.getCurrentName()=='nextRecordsUrl'){
                        nextRecordsUrl=parser.getText();
                    }
                    parser.nextToken();
                } while(parser.hasCurrentToken() && !'records'.equals(parser.getCurrentName()));
                    
                parser.nextToken();
            
                //the following line is wicked cool
                final List<OrgRefresh_org62BadgesBean> badgesData = (List<OrgRefresh_org62BadgesBean>) parser.readValueAs(List<OrgRefresh_org62BadgesBean>.class);
                System.debug('badgesData size as native list: ' + badgesData.size());
                System.debug('badgesData size as native list: ' + badgesData);
                org62Badges.addAll(badgesData);
                calloutCntr ++ ;
                Url=refreshProfile.Instance_URL__c + nextRecordsUrl;
                
            }while(calloutCntr< 5 && !isRecordFetchDone);
               
            //transform org62 badge information to services org
            final List<Learning_Domain__c> learningDomains=OrgRefresh_DataTransformUtils.org62BadgesTransform(org62Badges);
 
            //setup upsert for partial success so that one failure doesn't affect other records
            Database.UpsertResult[] results=Database.upsert(learningDomains, Learning_Domain__c.Unique_Id__c, false);
            for(Database.UpsertResult upsertResultInstance:results){
                if(!upsertResultInstance.isSuccess()){
                    System.debug('====UPSERT LEARNING DOMAIN ERRORS======' + upsertResultInstance.getErrors());                 
                }
                finalResults.add(new OrgRefresh_BatchResult(upsertResultInstance.id, upsertResultInstance.created, upsertResultInstance.success, String.valueOf(upsertResultInstance.getErrors())));
                
            }           
            
            // repeat for badge data
            final List<Badge_Data__c> lpBadges=OrgRefresh_DataTransformUtils.org62BadgesLPTransform(org62Badges, paList);

            //setup upsert for partial success so that one failure doesn't affect other records
            results=Database.upsert(lpBadges, Badge_Data__c.Org62_Id__c, false);
            for(Database.UpsertResult upsertResultInstance:results){
                if(!upsertResultInstance.isSuccess()){
                    System.debug('====UPSERT BADGE DATA ERRORS======' + upsertResultInstance.getErrors());
                }
                finalResults.add(new OrgRefresh_BatchResult(upsertResultInstance.id, upsertResultInstance.created, upsertResultInstance.success, String.valueOf(upsertResultInstance.getErrors())));
                
            }   
            
            //GR:update required=false for badges that are not updated
            System.debug('fullRefresh ' + fullRefresh + paList);
            /*if (fullRefresh) {
                final List<Badge_Data__c> lpUnassignedBadges=OrgRefresh_DataTransformUtils.setRequiredBadgeFalse(org62Badges);

                //setup update for partial success so that one failure doesn't affect other records
                Database.update(lpUnassignedBadges);
            }*/
            
            // always execute this outside          
            //refreshProfile.Last_Refreshed__c=System.now();
            //upsert refreshProfile Name;

        }
        return finalResults;
    }
    
}