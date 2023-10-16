/**
 * Classes that implement OrgRefresh_FetchInterface have a naming pattern to be followed for the code to function properly.
 * OrgRefresh_<ORGNAME>_<APPNAME>FetchImpl. Please name the appname and org name concise.
 * 
 */
public with sharing class OrgRefresh_org62_CSATFetchImpl implements OrgRefresh_FetchInterface, OrgRefresh_BatchInterface{
    private Org_Refresh_Profile__c refreshProfile; 
    List<PA_Onboarding__c> paList;
    private List<String> contactEmails=new List<String>();
    private List<Id> paIds=new List<Id>();
    
    
    public OrgRefresh_org62_CSATFetchImpl() {
                                      
    }
    
    
    // From OrgRefresh_BatchInterface
    public List<OrgRefresh_BatchResult> fetchAndUpdateData(List<SObject>candidateList, String accessToken,String orgAppName, Boolean fullRefresh){
    
        List<OrgRefresh_BatchResult> finalResults = new List<OrgRefresh_BatchResult>();
        this.paList = (List<PA_OnBoarding__c>)candidateList;
        
        //call out counter
        Integer calloutCntr=0;
         //variable to store the done flag
        Boolean isRecordFetchDone=false;
        
        //set the orgname
        OrgRefresh_QueryUtils.setOrgAppName(orgAppName);
        
        for(PA_Onboarding__c paOnboard: paList){
            contactEmails.add(paOnboard.Contact__r.Email);
            paIds.add(paOnboard.Id);
        }
        //fetch the org defaults settings    
        refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile();
         if(refreshProfile!=null){
             String Url=refreshProfile.Instance_URL__c + '/services/data/v29.0/query/';
             String queryToBeExecuted = constructQuery(orgAppName, fullRefresh);
              //variable to store next set of records in Rest API
             String nextRecordsUrl='';
             List<OrgRefresh_org62CSATBean> org62CSATData = new List<OrgRefresh_org62CSATBean>();
                 
             System.debug('OrgRefresh_org62_CSATFetchImpl.fetchAndUpdateData queryToBeExecuted :' + queryToBeExecuted);
             do
             {
                //Execute the query
                 String body=OrgRefresh_QueryUtils.executeQuery(url,accessToken,constructQuery(orgAppName, fullRefresh));
                 System.debug('body after execute Query: ' + body);
                 //do regex replace to replace all __c and __r references so that JSON can directly be read into bean class.
                 body=body.replace('__c','');
                 body=body.replace('__r','');
                 body=body.replaceAll('__','');
                 
                 
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
                  
                final List<OrgRefresh_org62CSATBean> CSATData = (List<OrgRefresh_org62CSATBean>) parser.readValueAs(List<OrgRefresh_org62CSATBean>.class);
                System.debug('CSATData size as native list: ' + CSATData.size());
                System.debug('CSATData as native list: ' + CSATData);
                
                 org62CSATData.addAll(CSATData);
                calloutCntr ++ ;
                Url=refreshProfile.Instance_URL__c + nextRecordsUrl;
                 
             } while(calloutCntr< 5 && !isRecordFetchDone);
             
             //Transform the data into PA_Customer_Survey__c data format
             final List<PA_Customer_Survey__c> customerSurveys =OrgRefresh_DataTransformUtils.org62CSATTransform(org62CSATData);
            
             Database.UpsertResult[] results=Database.upsert(customerSurveys, PA_Customer_Survey__c.Org62_Survey_Id__c, false);
             for(Database.UpsertResult upsertResultInstance:results){
                if(!upsertResultInstance.isSuccess()){
                    System.debug('====UPSERT CUSTOMER SURVEYS ERRORS======' + upsertResultInstance.getErrors());                 
                }
                finalResults.add(new OrgRefresh_BatchResult(upsertResultInstance.id, upsertResultInstance.created, upsertResultInstance.success, String.valueOf(upsertResultInstance.getErrors())));
                
            } 
             //Spot bonus calculation
            // lp_Spot_Bonus_Svc.CalculateSpotBonus(contactEmails);
            
             
             
             
              
         }
        return finalResults;
    }
    
    // From OrgRefresh_BatchInterface
    public string constructSourceQuery() {
        return 'select  id '+
                     ', Contact__c '+
                     ', Contact__r.Email '+
                      ', name ' +
                    'from PA_Onboarding__c '+ 
                    'where Contact__c!=null '+ 
                       'and Contact__r.Email!=null '+ 
                       'and Contact__r.Email!=\'\' ';
                       //+'and Status__c in (\'Deployed\')';  
    }

    
    //From OrgRefresh_FetchInterface
    public string constructQuery(String orgAppName, boolean fullRefresh) {
        String queryStr=OrgRefresh_QueryUtils.constructBaseQuery(fullRefresh);
        String queryClause = ' and ';
        String whereClause = '';
        String orderbyClause = ' ORDER BY Resource_Name__r.Email, completiontime__c desc';
       
        if (queryStr.indexOf('where') < 0) 
            queryClause = ' where ';
        else
            whereClause = queryStr.substring(queryStr.indexOf('where'));

        if(whereClause!=null && !whereClause.contains('Resource_Name__r.Email')){
            queryStr+= queryClause + constructEmailList();
            queryClause = ' and ';
        }

        queryStr+= orderbyClause;
        
        return queryStr;
    }
    
      //From OrgRefresh_FetchInterface
    public void fetchAndUpdateData( String accessToken,String orgAppName){
        List<SObject> paList = Database.query(constructSourceQuery());
        fetchAndUpdateData(paList, accessToken, orgAppName, false);
    }
    
     private String constructEmailList(){
        String emailStr=' Resource_Name__r.Email in ';
        emailStr+=OrgRefresh_QueryUtils.convertListToStr(contactEmails);
        return emailStr;
    }
}