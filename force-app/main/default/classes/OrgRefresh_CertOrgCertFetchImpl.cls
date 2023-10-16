/**
 * Classes that implement OrgRefresh_FetchInterface have a naming pattern to be followed for the code to function properly.
 * OrgRefresh_<ORGNAME><APPNAME>FetchImpl. Please name the appname and org name concise.
 * 
 */
public with sharing class OrgRefresh_CertOrgCertFetchImpl implements OrgRefresh_FetchInterface{
    /**
     * Method to construct the dynamic query based on the settings defined in the custom settings.
     */
    private Org_Refresh_Profile__c refreshProfile;
    
    // New Method added due to requirement by inteface
    public String constructQuery(String orgAppName, boolean fullRefresh)
    {
        // Do Nothing
        return null;
    }
    
    // New Method added due to requirement by inteface
    public void fetchAndUpdateData(LIST<PA_Onboarding__c> paList, String accessToken,String orgAppName)
    {
        // Do Nothing
    }
    
    // Something is clearly not right, but I am adding this so I can continue
    public void fetchAndUpdateData(String accessToken,String orgAppName)
    {
        // Do Nothing
    }
    
    public string constructQuery(String orgName,String appName){
       System.debug('====OrgRefresh_CertOrgCertFetchImpl constructQuery====');
          
           PA_Onboarding_Property__c queryProperty=PA_Onboarding_Property__c.getInstance(orgName+'_'+appName); 
           //no value defined
           if(queryProperty==null || queryProperty.Value__c==null || queryProperty.Value__c==''){
              throw new OrgRefresh_SettingsUndefinedException('No query defined for ' + appName + 'app in ' +orgName);
           }

           //String queryStr=OrgRefresh_QueryUtils.constructBaseQuery(queryProperty.Value__c);
           String queryStr=OrgRefresh_QueryUtils.constructBaseQuery(); // Updated by SD - 06/24/2014
           
           String whereClause=queryStr.substring(queryStr.indexOf('where'));

           if(whereClause!=null && !whereClause.contains('Contact__r.Email')){
            queryStr+= 'and ' + constructEmailList();
           }
           System.debug('=====queryStr======' + queryStr);
           return queryStr;
    }

     private String constructEmailList(){
        List<String> contactEmails=new List<String>();
        for(PA_Onboarding__c paOnboard:[select  id
                                              , Contact__c
                                              , Contact__r.Email
                                              , name 
                                        from PA_Onboarding__c 
                                        where Contact__c!=null 
                                        and Contact__r.Email!=null 
                                        and Contact__r.Email!=''
                                        and Program__c='Accelerated Onboarding']){
               contactEmails.add(paOnboard.Contact__r.Email);
        }
        String emailStr=' Contact__r.Email in ';
        emailStr+=OrgRefresh_QueryUtils.convertListToStr(contactEmails);
        return emailStr;
    }

    public void fetchAndUpdateData(String accessToken,String orgName,String appName){
         System.debug('====OrgRefresh_CertOrgCertFetchImpl fetchAndUpdateData====');
          //set the orgname
          //OrgRefresh_QueryUtils.setOrgName(orgName);
          OrgRefresh_QueryUtils.setOrgAppName(orgName); // Updated by SD - 06/24/2014
          //final list to store certifications
            List<Certification_Data__c> finalCertList=new List<Certification_Data__c>();
            //call out counter
          Integer calloutCntr=0;
          //variable to store the done flag
          Boolean isRecordFetchDone=false;
          //variable to store next set of records in Rest API
          String nextRecordsUrl='';

          
          System.debug('===Access_Token__c in HTTP====' + accessToken);
          //fetch the org defaults settings
            
          //refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile(true);
          refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile(); // Updated by SD - 06/24

          if(refreshProfile!=null){
              String Url=refreshProfile.Instance_URL__c + '/services/data/v50.0/query/';
              do{
                  String body=OrgRefresh_QueryUtils.executeQuery(url,accessToken,constructQuery(orgName,appName));
                  System.debug('body after execute Query: ' + body);
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
                  final List<Certification_Data__c> certData = (List<Certification_Data__c>) parser.readValueAs(List<Certification_Data__c>.class);
                  System.debug('certData size as native list: ' + certData.size());

                  finalCertList.addAll(certData);
                  calloutCntr ++ ;
                  Url=refreshProfile.Instance_URL__c + nextRecordsUrl;
               }while(calloutCntr< 5 && !isRecordFetchDone);

               for(Certification_Data__c certInstance:finalCertList){
                   certInstance.Candidate_Email__c=certInstance.Contact__r.Email;
                   certInstance.Cert_Unique_Id__c=certInstance.Contact__r.Email + certInstance.Certification_Type_Name__c;
               }
                
               try{
                  //setup upsert for partial success so that one failure doesn't affect other records
                  Database.upsert(finalCertList, Certification_Data__c.Cert_Unique_Id__c, false);
                  refreshProfile.Last_Refreshed__c=System.now();
                  upsert refreshProfile Name;
               }
          
                catch(Exception e){
                   //TODO: per Anand to ignore any DML exceptions for now. To be handled in next release by another resource. 
                }

            }
    }
}