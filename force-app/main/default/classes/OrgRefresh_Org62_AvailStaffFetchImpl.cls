/**
 * Classes that implement OrgRefresh_FetchInterface have a naming pattern to be followed for the code to function properly.
 * OrgRefresh_<ORGNAME>_<APPNAME>FetchImpl. Please name the appname and org name concise.
 * 
 */
public with sharing class OrgRefresh_Org62_AvailStaffFetchImpl implements OrgRefresh_FetchInterface, OrgRefresh_BatchInterface {
    /**
     * Method to construct the dynamic query based on the settings defined in the custom settings.
     */
    // set this to false if you want to update the timestamp outside of the class
    private List<PA_Onboarding__c> paList {get; set;} 
    private Org_Refresh_Profile__c refreshProfile;
    private String bodyStr1 = '<?xml version="1.0" encoding="UTF-8"?>' +
                              '<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">' +
                              '<operation>update</operation>' +
                              '<object>Contact</object>' +                      
                              '<contentType>XML</contentType>' +
                              '</jobInfo>';
    /* Constructor */  
    // default the pa onboarding list
    public OrgRefresh_org62_AvailStaffFetchImpl() { 
    }
    // Don't need this since getting the record to update sent to this class
    public string constructSourceQuery() {
        return 'select  id '+
                     ', Contact__c '+
                     ', Contact__r.Email '+
                     ', name ' +
                     ', Next_Available_Date__c ' +
                     ', Available_to_Staff_as_PA__c ' +
                    'from PA_Onboarding__c '+ 
                    'where Contact__c!=null '+ 
                       'and Contact__r.Email!=null '+ 
                       'and Contact__r.Email!=\'\' '+
                       'and Program__c in (\'Accelerated Onboarding\', \'PA Track\', \'CTA Prep\', \'Existing PA\')';
    }
    
    
    public string constructQuery(String orgAppName, boolean fullRefresh){
        System.debug('====OrgRefresh_Org62_AvailStaffFetchImpl constructQuery====');
          
        String queryStr=OrgRefresh_QueryUtils.constructBaseQuery(fullRefresh);
        
        String queryClause = ' and ';
        String whereClause = '';
        if (queryStr.indexOf('where') < 0) 
            queryClause = ' where ';
        else
            whereClause = queryStr.substring(queryStr.indexOf('where'));
/*
        if (whereClause != null && !whereClause.contains('Employee_Number__c')) {
            queryStr+= queryClause + constructEmployeeList();
            
        }
        if(whereClause!=null && !whereClause.contains('User__r.Email')){
            queryStr+= queryClause + constructEmailList();
            queryClause = ' and ';
        }

        if(whereClause!=null && !whereClause.contains('Badge__r.Name')){
            queryStr+= queryClause + constructBadgeList();
        }
*/
        if(whereClause!=null && !whereClause.contains('Email')){
            queryStr+= queryClause + constructEmailList();
        }
        
        System.debug('=====queryStr======' + queryStr);
        return queryStr;
    }

    private String constructEmployeeList() {
        List<String> contactEmpNums = new List<String>();
        
        for (PA_Onboarding__c paOnboard : paList) {
            contactEmpNums.add(paOnboard.Contact__r.Employee_ID__c); // get the lookup of the Contact's Employee ID for finding the right contacts in org62
        }
        String empNumStr = ' Employee_Number__c in ';
        empNumStr+=OrgRefresh_QueryUtils.convertListToStr(contactEmpNums);
        return empNumStr;
    }
    
    private String constructEmailList(){
        List<String> contactEmails=new List<String>();
            
        for(PA_Onboarding__c paOnboard: paList){
               contactEmails.add(paOnboard.Contact__r.Email);
        }
        String emailStr=' Email in ';
        emailStr+=OrgRefresh_QueryUtils.convertListToStr(contactEmails);
        return emailStr;
    }
    
    private String constructBadgeList() {
        List<String> badgeList=new List<String>();
        
        for (PA_Badges__c b : [select name, Badge_Name__c, is_learning_path__c from PA_Badges__c]) {
            badgeList.add(b.badge_name__c);         
        }
        String badgeStr=' Badge__r.Name in ';
        badgeStr+=OrgRefresh_QueryUtils.convertListToStr(badgeList);
        return badgeStr;
    }
// Will re-enable if needed when do batch
    public void fetchAndUpdateData(String accessToken,String orgAppName){  
        System.debug('inside fetch and update');
        List<SObject> inputList = Database.query(constructSourceQuery());
        List<OrgRefresh_BatchResult> result = 
                fetchAndUpdateData(inputList, accessToken, orgAppName, false);
    } 
    
    public String constructPost(String orgAppName, boolean fullRefresh, String recId) {
        String urlUpdate = 'sobjects/';
        urlUpdate+=refreshProfile.Object_Name__c + '/' + recId; // assumes using the Id of the object for upserting
        System.debug('Constructing Post and have:'+urlUpdate);
        return urlUpdate;
    }
    
   /* public String makeJSON(String field, String value) {
        String jsonText = '{ "' + field + '" : "' + value + '" }';
        return jsonText;
    }*/
    
    public String makeJSON(OrgRefresh_Org62AvailStaffBean paRecord) {
        String[] newOrgFieldNameList = refreshProfile.new_Org_Field_Name_List__c.split(',');
        String[] curOrgFieldNameList = refreshProfile.cur_Org_Field_Name_List__c.split(',');
        
        if (newOrgFieldNameList.size() != curOrgFieldNameList.size()) {
            // ERROR!!!
            System.debug('Making JSON and got error!!');
            return null; 
        } else {
            String jsonText = '{ ';
            String tempfieldval = '';
            for (Integer i = 0; i < newOrgFieldNameList.size(); i++) {
                //for (String value : curOrgFieldNameList) {
                    jsonText += '"' + newOrgFieldNameList[i] + '" : ';
                    tempfieldval = paRecord.getField(''+curOrgFieldNameList[i]+'');
                    jsonText += (tempfieldval==null?'null':('"'+tempfieldval+'"'));
                    if ((i+1) != curOrgFieldNameList.size()) {
                        jsonText += ', ';
                    }
                    
                //}
            }
            jsonText += ' }';
            System.debug('Making JSON and have:'+jsonText);
            return jsonText;
        }

    }

    public List<OrgRefresh_BatchResult> fetchAndUpdateData(List<SObject> candidateList, String accessToken,String orgAppName, boolean fullRefresh){
        this.paList = (List<PA_OnBoarding__c>)candidateList;
        System.debug('====OrgRefresh_Org62_AvailStaffFetchImpl fetchAndUpdateData====');
         //set the orgname
        OrgRefresh_QueryUtils.setOrgAppName(orgAppName);
        //final list to store org62 badge information
        final List<OrgRefresh_org62AvailStaffBean> org62ContactIds=new List<OrgRefresh_org62AvailStaffBean>();
        //call out counter
        Integer calloutCntr=0;
         //variable to store the done flag
        Boolean isRecordFetchDone=false;
        //variable to store next set of records in Rest API
        String nextRecordsUrl='';

        List<OrgRefresh_BatchResult> finalResults = new List<OrgRefresh_BatchResult>();
        
        Map<String, Date> availDates = new Map<String, Date>();
        for( PA_Onboarding__c pa : paList ){
            availDates.put(pa.contact__r.Email, pa.Available_to_Staff_as_PA__c);
        }  
        System.debug('===Map of Dates===');
        System.debug(availDates);

        System.debug('===Access_Token__c in HTTP====' + accessToken);
        //fetch the org defaults settings
            
        refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile();

        if(refreshProfile!=null){
            
            // Add the query / lookup functions here
            // 
            String Url=refreshProfile.Instance_URL__c + '/services/data/v29.0/query/';// + refreshProfile.Object_Name__c + '/' + refreshProfile.External_Id_Field_Name__c + '/' + candidateList[0].Contact__r.Employee_ID__c;

            //return finalResults ;
            
            do{
                    String body=OrgRefresh_QueryUtils.executeQuery(url,accessToken,constructQuery(orgAppName, fullRefresh));
                    System.debug('body after execute Query: ' + body);
                                System.debug('body after execute Update: ' + body);
                    // need to determine success/failure from response
                    String[] results = body.split('\n');
                    String[] highlevelResults = results[0].split(' - ');


                  JSONParser parser = JSON.createParser(body);

                  body=body.replaceAll('__c','');
                  body=body.replaceAll('__r','');
                  body=body.replaceAll('__','');


                  //System.debug('body after execute Query: ' + body);
                  //System.debug('body after execute Query: ' + parser);
                
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
                  final List<OrgRefresh_org62AvailStaffBean> contactData = (List<OrgRefresh_org62AvailStaffBean>) parser.readValueAs(List<OrgRefresh_org62AvailStaffBean>.class);
                  System.debug('certData size as native list: ' + contactData.size());

                  org62ContactIds.addAll(contactData);
                  calloutCntr ++ ;
                  Url=refreshProfile.Instance_URL__c + nextRecordsUrl;
               }while(calloutCntr< 5 && !isRecordFetchDone);

               for ( OrgRefresh_Org62AvailStaffBean org62Contact : org62ContactIds){
                    System.debug('Contact Email and Id : ' + org62Contact.account.Name + ' / '
                                 + org62Contact.Email + ' / ' + org62Contact.employee_number + ' / ' 
                                 + org62Contact.pseIs_Resource + ' / ' 
                                 + org62Contact.pseIs_Resource_Active + ' / ' + org62Contact.Id ); 
               }
               

            // Add the matching of the query results with the pa record values onto the OrgRefresh_Org62AvailStaffBean object
            //List<OrgRefresh_Org62AvailStaffBean> ASBeanRecs = new List<OrgRefresh_Org62AvailStaffBean>();
            //ASBeanRecs.add(new OrgRefresh_Org62AvailStaffBean());
            
            // This begins the update to the org62 record for a single or small number of records, done one record at a time
            
            // String Url=refreshProfile.Instance_URL__c + '/services/data/v29.0/';// + refreshProfile.Object_Name__c + '/' + refreshProfile.External_Id_Field_Name__c + '/' + candidateList[0].Contact__r.Employee_ID__c;
            
            if ( fullRefresh ){
                // Reset URL and postStr string
                Url=refreshProfile.Instance_URL__c ;
                String postStr = '/services/async/31.0/job';
                String typeReq = 'XML';
                String nullStr = '#N/A';
                String bodyStr2 = '<sObjects xmlns="http://www.force.com/2009/06/asyncapi/dataload"> ';

                for (OrgRefresh_Org62AvailStaffBean asb : org62ContactIds) {//PA_Onboarding__c c : paList) { // change the c.Contact__r.Employee_ID__c to be the OrgRefresh_Org62AvailStaffBean.ID field instead

                    String nxtAvailDate =  ((availDates.get(asb.email)!=null)?(datetime.newInstance(availDates.get(asb.email), time.newInstance(0,0,0,0)).format('yyyy-MM-dd+/-HHmm')):nullStr) ;
                    bodyStr2 += '<sObject>' + '<Id>' + asb.id + '</Id>' +
                    '<Next_Available_Date__c>' +  nxtAvailDate + 
                    '</Next_Available_Date__c>' + '</sObject>' ;
                }
                bodyStr2 += '</sObjects>';

                String body = OrgRefresh_QueryUtils.executeBulkUpdate(Url, accessToken, postStr, bodyStr1, bodyStr2, typeReq) ;
                System.debug('body after execute Update: ' + body);
                // need to determine success/failure from response
                String[] results = body.split('\n');
                String[] highlevelResults = results[1].split(' - ');
                
                if (highlevelResults[0] == '200' || highlevelResults[0] == '201' || highlevelResults[0] == '204') {
                    // success!!
                   finalresults.add(new OrgRefresh_BatchResult(string.valueof(org62ContactIds[0].Id), true, true, ((results.size()==1)?'SUCCESS':body)));
                } else {
                   // failure, so pass it on!!
                    finalresults.add(new OrgRefresh_BatchResult(string.valueof(org62ContactIds[0].Id), false, false, ((results.size()==1)?'FAILURE':body)));
                }
                

            }
            else {
             
                for (OrgRefresh_Org62AvailStaffBean asb : org62ContactIds) {//PA_Onboarding__c c : paList) { // change the c.Contact__r.Employee_ID__c to be the OrgRefresh_Org62AvailStaffBean.ID field instead
                    asb.Next_Available_Date = availDates.get(asb.email) ;
                    System.debug('Next_Available_Date: ' + asb.Next_Available_Date );
                    System.debug(asb);
                    // need to re-update url since was used in query stuff above
                    Url=refreshProfile.Instance_URL__c + '/services/data/v29.0/';
                    String body = OrgRefresh_QueryUtils.executeUpdate(url, accessToken, constructPost(orgAppName, fullRefresh, string.valueof(asb.Id)), makeJSON(asb) );
                    // process results
                    System.debug('body after execute Update: ' + body);
                    // need to determine success/failure from response
                    String[] results = body.split('\n');
                    String[] highlevelResults = results[0].split(' - ');
                    if (highlevelResults[0] == '200' || highlevelResults[0] == '201' || highlevelResults[0] == '204') {
                       // success!!
                       finalresults.add(new OrgRefresh_BatchResult(string.valueof(asb.Id), true, true, ((results.size()==1)?'SUCCESS':results[1])));
                    } else {
                       // failure, so pass it on!!
                        finalresults.add(new OrgRefresh_BatchResult(string.valueof(asb.Id), false, false, ((results.size()==1)?'FAILURE':results[1])));
                    }
                }
            }

            /*
            do{
                String body=OrgRefresh_QueryUtils.executeUpdate(url,accessToken,constructQuery(orgAppName, fullRefresh)); // should be construct ids then construct json with date formatted to 2012-07-12T17:49:01.000+0000
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
                final List<OrgRefresh_org62AvailStaffBean> ContactData = (List<OrgRefresh_org62AvailStaffBean>) parser.readValueAs(List<OrgRefresh_org62AvailStaffBean>.class);
                System.debug('ContactData size as native list: ' + ContactData.size());
                System.debug('ContactData size as native list: ' + ContactData);
                org62ContactIds.addAll(ContactData);
                calloutCntr ++ ;
                Url=refreshProfile.Instance_URL__c + nextRecordsUrl;
                
            }while(calloutCntr< 5 && !isRecordFetchDone);
            */
               
            /* Now have all my Ids for matching with org62, so do lookup & mashup the Contact Id & Avail Date to JSON to post to org62 */
            
           /* 
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
            final List<Badge_Data__c> lpBadges=OrgRefresh_DataTransformUtils.org62BadgesLPTransform(org62Badges);

            //setup upsert for partial success so that one failure doesn't affect other records
            results=Database.upsert(lpBadges, Badge_Data__c.Unique_Id__c, false);
            for(Database.UpsertResult upsertResultInstance:results){
                if(!upsertResultInstance.isSuccess()){
                    System.debug('====UPSERT BADGE DATA ERRORS======' + upsertResultInstance.getErrors());
                }
                finalResults.add(new OrgRefresh_BatchResult(upsertResultInstance.id, upsertResultInstance.created, upsertResultInstance.success, String.valueOf(upsertResultInstance.getErrors())));
                
            }   
            
            // always execute this outside          
            //refreshProfile.Last_Refreshed__c=System.now();
            //upsert refreshProfile Name;*/

        }
        return finalResults; // these are the results of updating the org62 org as a list of OrgRefresh_BatchResult(id, created, success, errorstring)
    }
    
}