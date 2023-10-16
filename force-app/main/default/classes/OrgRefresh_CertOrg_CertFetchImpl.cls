/**
 * Classes that implement OrgRefresh_FetchInterface have a naming pattern to be followed for the code to function properly.
 * OrgRefresh_<ORGNAME>_<APPNAME>FetchImpl. Please name the appname and org name concise.
 * 
 */
public with sharing class OrgRefresh_CertOrg_CertFetchImpl implements OrgRefresh_FetchInterface, OrgRefresh_BatchInterface {
    /**
     * Method to construct the dynamic query based on the settings defined in the custom settings.
     */
    private Org_Refresh_Profile__c refreshProfile;
    
    private Map<String, PA_Onboarding__c> paList;   
        
    public string constructSourceQuery() {
        return 'select  id '+
                     ', Contact__c '+
                     ', Contact__r.Email '+
                     ', Mentor__c '+
                      ', Mentor__r.Email '+ 
                          ', name ' +
                    'from PA_Onboarding__c '+ 
                    'where Contact__c!=null '+ 
                       'and Contact__r.Email!=null '+ 
                       'and Contact__r.Email!=\'\' '+
                       'and Program__c in (\'Accelerated Onboarding\', \'PA Track\', \'CTA Prep\', \'Existing PA\',\'Existing BA\',\'BA Ramp\',\'Former CST\',\'MC Advisor\',\'Practices\')';
    }

    public void setSoureCandidateList(List<SObject> candidateList) {
        this.paList = new Map<String, PA_Onboarding__c>();
        for (PA_Onboarding__c pa:(List<PA_Onboarding__c>)candidateList) 
            this.paList.put(pa.Contact__r.Email, pa); // used to lookup mentor information for new Certification data
    }


    public string constructQuery(String orgAppName, boolean fullRefresh){ 
       System.debug('====OrgRefresh_CertOrgCertFetchImpl constructQuery====');
      
       String queryStr=OrgRefresh_QueryUtils.constructBaseQuery(fullRefresh);
       System.debug('====OrgRefresh_CertOrgCertFetchImpl queryStr===='+queryStr);

       String whereClause=queryStr.indexOf('where')>-1?queryStr.substring(queryStr.indexOf('where')):null;

       if(whereClause!=null){
          if (!whereClause.contains('Contact__r.Email'))
                queryStr+= ' and ' + constructEmailList();
       } else {
          queryStr+=' where ' + constructEmailList();   
       }
       
       System.debug('=====queryStr======' + queryStr);
       return queryStr;
    }

     private String constructEmailList(){
        List<String> contactEmails=new List<String>();
            
        for(PA_Onboarding__c paOnboard:paList.values())
        {                 
               contactEmails.add(paOnboard.Contact__r.Email);
        }
        String emailStr=' Contact__r.Email in ';
        emailStr+=OrgRefresh_QueryUtils.convertListToStr(contactEmails);
        return emailStr;
    }
    
    public void fetchAndUpdateData(String accessToken,String orgAppName){
        List<SObject> candidateList = Database.query(constructSourceQuery());
        fetchAndUpdateData(candidateList, accessToken, orgAppName,false);
    }
 
  
    public List<OrgRefresh_BatchResult> fetchAndUpdateData(List<SObject> candidateList, String accessToken,String orgAppName,Boolean fullRefresh){
         setSoureCandidateList(candidateList);
 
         System.debug('====OrgRefresh_CertOrgCertFetchImpl fetchAndUpdateData====' + orgAppName);
          //set the orgname
          OrgRefresh_QueryUtils.setOrgAppName(orgAppName);
          //final list to store certifications
            List<Certification_Data__c> finalCertList=new List<Certification_Data__c>();
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
            system.debug('Test Dalia ::: '+ refreshProfile);
          if(refreshProfile!=null){
              String Url=refreshProfile.Instance_URL__c + '/services/data/v54.0/query/';
              /*String Url='https://org62.my.salesforce.com/services/data/v54.0/query/';*/
              system.debug ('Test Dalia'+Url);
              do{
                  String body=OrgRefresh_QueryUtils.executeQuery(url,accessToken,constructQuery(orgAppName, fullRefresh));
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
                   certInstance.Mentor_Email__c = paList.get(certInstance.Contact__r.Email).Mentor__r.Email;
                   certInstance.PA_Onboarding__c = paList.get(certInstance.Contact__r.Email).id;
                   System.debug('cert details ' +  certInstance.Cert_Unique_Id__c +' Mentor email ' + certInstance.Mentor_Email__c );
               }
               
               
                
             
                  //setup upsert for partial success so that one failure doesn't affect other records
                  Database.UpsertResult[] results=Database.upsert(finalCertList, Certification_Data__c.Cert_Unique_Id__c, false);
                  refreshProfile.Last_Refreshed__c=System.now();
                  upsert refreshProfile Name;

                  for(Database.UpsertResult upsertResultInstance:results){
                    if(!upsertResultInstance.isSuccess()){
                      System.debug('====UPSERT ERRORS======' + upsertResultInstance.getErrors()); 
                    }
                    finalResults.add(new OrgRefresh_BatchResult(upsertResultInstance.id, upsertResultInstance.created, upsertResultInstance.success, String.valueOf(upsertResultInstance.getErrors())));
                  }
             
            }
            
            /* New code added by SD - 02/18/2015 */
            updateIntegrationLog(paList, finalCertList);
            /* End of code added by SD */
            
            return finalResults;
    }
    
    /*************************************************************************************************
    * The following method adds debug information for the certification integration to the PA record 
    **************************************************************************************************/
    private static void updateIntegrationLog(Map<String, PA_Onboarding__C> paMap, List<Certification_Data__c> certList)
    {
         System.Debug('****************** Integration Cert Log ********************');
         //System.Debug('PAList: \n' + paMap);
         //System.Debug('Cert Data: \n' + certList);  
              
         // Map that stores certs retrieved per PA
         Map<String, Integer> paCertMap = new Map<String, Integer>();
         
         // Get list of all PAs
         Set<String> paEmailSet = paMap.Keyset();
         
         // Initiatize Map
         for (String e : paEmailSet)
         {
             paCertMap.put(e, 0);        
         }
         
         // Update Map with Certs for each PA
         for (Certification_Data__c cert : certList)
         {
             String paEmail = cert.Contact__r.Email;
             Integer numCerts = paCertmap.get(paEmail);
             if (numCerts == null)
                 numCerts = 0;
             else
                 numCerts = numCerts + 1;
             paCertMap.put(paEmail, numCerts);
         }
         //System.Debug('********paCertMap**********: ' + paCertMap);
         
         // Update PA Onboarding record
         List<PA_Onboarding__c> paToUpdate = new List<PA_Onboarding__c>();
         paToUpdate = paMap.values();
         for (PA_Onboarding__c p : paToUpdate)
         {
             String certLog = String.valueOf(DateTime.now()) + ': Retrieved ' + paCertMap.get(p.Contact__r.Email) + ' Certifications for email address ' + p.Contact__r.Email;
             System.Debug('**************certLog***********: ' + certLog);
             p.Certification_Integration_Log__c = certLog;
         }
         
         //System.Debug('********paToUpdate**********: ' + paToUpdate);
         // Update PA Onboarding record
         if (!paToUpdate.isEmpty())
             update paToUpdate;
         
    }
    
}