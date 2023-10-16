public with sharing class OrgRefresh_QueryUtils {
   private static Org_Refresh_Profile__c refreshProfile;

   //variable to store the org name of interest. Either the controller or the batch job will set the value.
   private static string ORG_APP_NAME;
   
    public static void setOrgAppName(String orgAppName){
          ORG_APP_NAME=orgAppName;
    }

    public static string getOrgAppName(){
       return ORG_APP_NAME;
    }

    public static Org_Refresh_Profile__c getRefreshProfile(){
      System.debug('=====ORG_APP_NAME in getRefreshProfile=====' + ORG_APP_NAME);
             //check if org name is defined.
             if(ORG_APP_NAME==null || ORG_APP_NAME==''){
                throw new OrgRefresh_SettingsUndefinedException('ORG_APP_NAME of interest is not set.');
             }
             //fetch the settings for the org of interest.
             refreshProfile=Org_Refresh_Profile__c.getInstance(ORG_APP_NAME);

             //if the settings does not exist throw an exception.
             if(refreshProfile==null){
                throw new OrgRefresh_SettingsUndefinedException('Settings is not defined for ' + ORG_APP_NAME);
             }
            System.debug('=====refreshProfile.Last_Refreshed__c=====' + refreshProfile.Last_Refreshed__c);
            
             return refreshProfile;
   }   
    
    /**
     * Given a list of strings, convert them to a comma seperated string value.
     */
    public static String convertListToStr(List<String> strList){
         String returnStr='( ';

       Integer count=0;

         if(strList!=null && strList.size()>0){
              for(String strValue:strList){
                returnStr+='\'' + strValue + '\'';
                count++;
                //all strings processed
                if(count==strList.size()){
                   returnStr+=' ) ';
                }
                else{
                   returnStr+=' , ';
                }
            }

        }
        return returnStr;
    }

    /**
     * Construct the base query string irrespective of app specific conditions for data fetch
     */
     
    public static String constructbaseQuery() {
        return constructBaseQuery(false);
    }

    public static String constructBaseQuery(boolean fullRefresh){
      //variable to store the query string to be returned.
      String queryStr='';
      //variable to store user defined query
      String userDefinedQuery='';
      //query the refresh profile settings
      refreshProfile=getRefreshProfile();

      //string variable to store the string versions of the date.
      String dateStr='';

      //string variable to store the string versions of the end date.
      String endDateStr='';

    if(refreshProfile.Query_2__c !=null && refreshProfile.Query_2__c.length()>0 && refreshProfile.Query_Condition__c!=null && refreshProfile.Query_Condition__c.length()>0){
           userDefinedQuery=refreshProfile.Query__c + ' ' + refreshProfile.Query_2__c + ' ' + refreshProfile.Query_Condition__c;
       }
       else if(refreshProfile.Query_Condition__c!=null && refreshProfile.Query_Condition__c.length()>0){
           userDefinedQuery=refreshProfile.Query__c + ' ' + refreshProfile.Query_Condition__c;
       }
       else{
          userDefinedQuery=refreshProfile.Query__c;
       }
       // Sriram: Ignore all dates for full refresh
       if (fullRefresh)
            return userDefinedQuery;
            
      //check if the data has been refreshed already & auto refresh is checked
      if( refreshProfile!=null && 
          refreshProfile.Auto_Refresh__c
        ) 
      {
       
          if(refreshProfile.Last_Refreshed__c!=null){
               dateStr=refreshProfile.Last_Refreshed__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
           }
           
           //auto refresh checked, but the last refreshed time stamp is not updated
          else{
               System.debug('>>>>>> setting default time for Last_Modified_By');
               Datetime initDate=Datetime.newInstance(1970,1,1);
               dateStr=initDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
          }
       }
     // auto refresh flag is turned off. Need to use the date fields defined.
      else{
           if((refreshProfile!=null) && (refreshProfile.Start_Date__c!=null)){
              dateStr=refreshProfile.Start_Date__c.format();
           }

           if((refreshProfile!=null) && (refreshProfile.End_Date__c!=null)){
              endDateStr=refreshProfile.End_Date__c.format();
           }
      }
        
        //construct the query string using the above date strings
      if(dateStr!=null && dateStr !=''){
          if(userDefinedQuery!=null && userDefinedQuery.contains('where')) { 
               queryStr+=userDefinedQuery + ' and LastModifiedDate >= ' + dateStr;
           }
           else{
              queryStr+=userDefinedQuery + ' where LastModifiedDate >= ' + dateStr;
           }
      }else{
        queryStr+=userDefinedQuery;
      }
      queryStr=(endDateStr.length()>0)? (queryStr+' and LastModifiedDate <= ' + endDateStr) : queryStr;
         //return the constructed base query string  
      System.debug('>>>>>> returning queryStr:'+queryStr);
      return queryStr;
    }


    public static boolean validateEnum(OrgRefresh_AuthFlows source,OrgRefresh_AuthFlows target){
        return (  (source!=null && target!=null)
                && (source.name().equalsIgnoreCase(target.name()))
                ?true:false);
    }

    public static string executeQuery(String url,String accessToken, String queryStr){
          final PageReference theUrl = new PageReference(url);
            theUrl.getParameters().put('q',queryStr);
            HttpRequest request = new HttpRequest();
            request.setEndpoint(theUrl.getUrl());
            request.setMethod('GET');
            request.setHeader('Authorization', 'OAuth ' + accessToken);
            request.setTimeOut(60000);

            System.debug('===Access_Token__c in query====' + accessToken);
             
            String body = (new Http()).send(request).getBody();
            return body;
    }
    
    /* CJT Added for executing an update to a single record in the external org
        url is for the org, 
        accesstoken for security, 
        postStr is the object, externalid field, and id path url
        bodystr is the json request
    */
    public static string executeUpdate(String url, String accessToken, String postStr, String bodyStr) {
        final PageReference theUrl = new PageReference(url+postStr);
        
        theUrl.getParameters().put('_HttpMethod', 'PATCH'); // put the parameters for posting to org62
        HttpRequest request = new HttpRequest();
        request.setEndpoint(theUrl.getUrl()); // need to be sure this includes our external id name
        request.setMethod('POST'); // this does an update to the existing record
        request.setBody(bodyStr); // this is the JSON body to send in message
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'OAuth ' + accessToken);
        request.setTimeOut(60000);
        
        System.debug('===Access_Token__c in post====' + accessToken);
        HttpResponse response = (new Http()).send(request);
        String body = response.getBody();
        body = response.getStatusCode() + ' - ' + response.getStatus() + '\n' + body; // append overall status too
        return body;
    }

    public static String[] getOrgAppArray(String orgAppName){
      if(orgAppName!=null && orgAppName.contains('_')){
         String[] orgAppArr=orgAppName.split('_');
         System.debug('====orgAppArr in getOrgAppArray====' + orgAppArr);
         if(orgAppArr!=null && orgAppArr.size()==2){
           return orgAppArr;
         }
         else{
          return null;
         }

       }
      else{
        return null;
      }
    }

    public static String getOrgName(String orgAppName){
       System.debug('====orgAppName in getOrgName====' + orgAppName);
       String[] orgAppArr=getOrgAppArray(orgAppName);
       System.debug('====orgAppArr in getOrgName====' + orgAppArr);
       
       return orgAppArr[0];
    }

    public static String getAppName(String orgAppName){
       System.debug('====orgAppName in getAppName====' + orgAppName);
      
       String[] orgAppArr=getOrgAppArray(orgAppName);
          System.debug('====orgAppArr in getOrgName====' + orgAppArr);
    
       return orgAppArr[1];
    }



    @future(callout=true)
    public static void authenticateandFetch(String authFlowName,String orgAppName, String userName){
       //set the orgname
       ORG_APP_NAME=orgAppName;

       String accessToken='';
       // first authenticate based on flow.
        if( authFlowName.equalsIgnoreCase(OrgRefresh_AuthFlows.USERNAME_PASSWORD.name())){
  //           accessToken=OrgRefresh_AuthUtils.authenticateUser(OrgRefresh_AuthFlows.USERNAME_PASSWORD,getOrgName(orgAppName),userName,false); // Sriram commented
             accessToken=OrgRefresh_AuthUtils.authenticateUser(OrgRefresh_AuthFlows.USERNAME_PASSWORD,orgAppName,userName,false);
        }
        else if(authFlowName.equalsIgnoreCase(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN.name())){
             accessToken=OrgRefresh_AuthUtils.authenticateUser(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN,false);
        }
        else{

        }
        if(accessToken!=null && accessToken.length()>0){
           fetchDataLogic(accessToken,orgAppName);
        }
         
    }

    /* Dennis Thong - added utility to fetch target org userid by username */
    public static Id fetchUserIdbyName(String accessToken, String userName) {
        if (accessToken== null) return null;
        
        //variable to store the done flag
        Boolean isRecordFetchDone=false;
        //variable to store next set of records in Rest API
        String nextRecordsUrl='';       
        Id userId;
        String Url=getRefreshProfile().Instance_URL__c + '/services/data/v54.0/query/';
        String body=OrgRefresh_QueryUtils.executeQuery(url,accessToken,'select id, username from user where username = \'' + userName + '\'');
        System.debug('== body of userid query ==: ' + body);

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

        // parse into the userbean
        List<UserBean> userData = (List<UserBean>) parser.readValueAs(List<UserBean>.class);
        
        system.debug(userData);
        if (!userData.isEmpty())
            userId = (Id)userData[0].Id;
        
        return userId;  
    }
    
    /* Sriram Added Method to obtain batch class instance */
    
    public static OrgRefresh_BatchInterface getBatchInstance(String orgAppName) {
       String trimmedOrgAppName= orgAppName.replaceAll('\\s+',''); 
        String implClassName='OrgRefresh_'+trimmedOrgAppName+'FetchImpl';
        System.debug('=====implClassName====' + implClassName);
        Type batchInterface=Type.forName(implClassName);
           
        System.debug('=====batchInterface====' + batchInterface);
           
        if(batchInterface==null){
              throw new OrgRefresh_SettingsUndefinedException('No batch implementation defined for org app combination ' + orgAppName );
        }
        OrgRefresh_BatchInterface implClass=(OrgRefresh_BatchInterface)batchInterface.newInstance();
        return implClass;       
    }

    private class UserBean {
        public String Id;
        public String username;
    }


    private static void fetchDataLogic(String accessToken,String orgAppName){
           if(accessToken==null || orgAppName==null || orgAppName==null){
              return;
           }
           String trimmedOrgAppName= orgAppName.replaceAll('\\s+',''); 
           String implClassName='OrgRefresh_'+trimmedOrgAppName+'FetchImpl';
           System.debug('=====implClassName====' + implClassName);
           Type fetchInterface=Type.forName(implClassName);
           
           System.debug('=====fetchInterface====' + fetchInterface);
           
           if(fetchInterface==null){
              throw new OrgRefresh_SettingsUndefinedException('No refresh implementation defined for org app combination ' + orgAppName );
           }
          
           OrgRefresh_FetchInterface interfaceInstance=(OrgRefresh_FetchInterface)fetchInterface.newInstance();
           interfaceInstance.fetchAndUpdateData(accessToken,orgAppName);
    }

    
    /**
     * Method to fetch the data from remote org using rest api
     */
    @future(callout=true)
    public static void fetchData(String accessToken, String orgAppName){
      fetchDataLogic(accessToken,orgAppName);
    }

    /**
     * Method to kick of a batch job (update or query) in another org using the bulk rest api CJT 8/22/14
     */
    public static string executeBulkUpdate(String url, String accessToken, String postStr, String bodyStr1, String bodyStr2, String typeReq) {
        // url should be the salesforce instance
        // access Token is the oauth token
        // postStr should be 'services/async/xx.x/job' where xx.x is the version - 30?
        // bodyStr1 should be the job request XML:
        /*
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">' +
            '<operation>update</operation>' +
            '<object>Contact</object>' +                      
            '<contentType>XML</contentType>' +
        '</jobInfo>';
        */
        // bodyStr2 should be for creating the object xml for what to update & objects, like:
        /*
        '<sObjects xmlns="http://www.force.com/2009/06/asyncapi/dataload">' + 
        '<sObject>' +
       '<Id>' + id + '</Id>' +
       '<Next_Available_Date__c>' + availDate + '</Next_Available_Date__c>' +
        '</sObject>'+
        '<sObject>' +
       '<Id>' + id + '</Id>' +
       '<Next_Available_Date__c>' + availDate + '</Next_Available_Date__c>' +
        '</sObject>'
        . . . . .
        + '</sObjects>';
        */
        // OR bodyStr2 should be for querying the objects, like:
        /*
        SELECT Id, EmailAddress FROM Contact WHERE EmailAddress IN ('12345@gmail.com', '1232@abc.com')
        */
        // typeReq should be either XML (for updating) or Query (for querying) - be sure bodyStr2 corresponds to this!!
        //===============================
        
        System.debug('######################BODYSTR1# ' + bodyStr1 + ' ##############################');
        System.debug('######################BODYSTR2# ' + bodyStr2 + ' ##############################');
    //  System.debug('######################TYPEREQ# ' + typeReq + ' ##############################');
        JobAndResponse fullResponse = createJob(url, postStr, accessToken, bodyStr1);
    //  System.debug('######################FULLRESP# ' + fullResponse + ' ################################');
        JobAndResponse batchResponse = createBatch(url, postStr, fullResponse.jobId, accessToken, typeReq, bodyStr2); // should make this an array of bodyStr2 to send multiple batches
        System.debug('######################NEXTRESP# ' + batchResponse.status + ' ################################');
        fullResponse.status = fullResponse.status + batchResponse.status;
        fullResponse.batchId = batchResponse.batchId;
        System.debug('######################BATCHID# ' + batchResponse.batchId + ' ################################');
    //  System.debug('######################FULLRESP2# ' + fullResponse + ' ################################');
        String nextResponse = closeBatch(url, postStr, fullResponse.jobId, accessToken);
    //  System.debug('######################NEXTRESP2# ' + nextResponse + ' ################################');
        fullResponse.status = fullResponse.status + nextResponse;
    //  System.debug('######################FULLRESP3# ' + fullResponse + ' ################################');
        
        // check the status of the job & include in the status results!!
        String batchstatus = getStatusResults(url, postStr, fullResponse.jobId, accessToken, fullResponse.batchId, typeReq);
        fullResponse.status = fullResponse.status + batchstatus;
        
        return fullResponse.status;
        
    }
    
    public static String getStatusResults(String url, String postStr, String jobId, String accessToken, String batchId, String typeReq) {
            
        // Add this to the url we used before:   "/" + jobId + "/batch" + batchId + "/result"
        PageReference batchUrl = new PageReference(url+postStr+'/'+jobId+'/batch/'+batchId+'/result');
        Http batchhttp = new Http();
        HttpRequest batchreq = new HttpRequest();
        HttpResponse batchres = new HttpResponse();
        batchreq.setMethod('GET');
        batchreq.setEndpoint(batchUrl.getUrl());
        batchreq.setHeader('X-SFDC-Session', ' ' + accessToken); // USE ACCESS TOKEN
        if (typeReq == 'XML') {
            batchreq.setHeader('Content-Type', ' application/xml; charset=UTF-8');
        } else {
            batchreq.setHeader('Content-Type', ' text/csv; charset=UTF-8');
        }
        batchreq.setTimeOut(60000);
        batchres = null;
        //String batchXml = bodyStr2;
        //batchreq.setBody(batchXml);
        batchres = batchhttp.send(batchreq);
        System.debug('################## ' + batchres.getBody() + ' headers ' + batchres.getHeaderKeys());
        
        String body = 'JOB\'S BATCH DETAILED RESULTS:\n' + batchres.getStatusCode() + ' - ' + batchres.getStatus() + '\n' + batchres.getBody() + '\n'; // append status to previous status
        
        return body;
        
    }
    
    public static JobAndResponse createJob (String url, String postStr, String accessToken, String bodyStr1) {
        
        
        final PageReference theUrl = new PageReference(url+postStr);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('POST');
        req.setEndpoint(theUrl.getUrl());//'https://ap1.salesforce.com/services/async/28.0/job');
        req.setHeader('X-SFDC-Session', ' ' + accessToken); // USE ACCESS TOKEN
        req.setHeader('Content-Type', ' application/xml; charset=UTF-8');
        req.setTimeOut(60000);
        res = null;
        String jobXml = bodyStr1;

        req.setBody(jobXml);
        res = http.send(req); // HTTP response will return JOB ID
        SYstem.debug('##################### '  +  res.getBody()+'jobid*******'+res.getHeaderKeys());
        
        //String[] jobId = res.getHeaderKeys(); // need to figure out how to get the right element for the id!!
        
        String body = res.getBody();
        
        String jobId = getJobId(body);
        
        body = 'CREATE JOB RESPONSE:\n' + res.getStatusCode() + ' - ' + res.getStatus() + '\n' + body + '\n'; // append overall status too
        
        // stop here for creating the job
        JobAndResponse toreturn = new JobAndResponse();
        toreturn.jobId = jobId;
        toreturn.status = body;
        
        return toreturn;
        
    }
    
    public static JobAndResponse createBatch(String url, String postStr, String jobId, String accessToken, String typeReq, String bodyStr2) {
        // begin here for creating the batch
        
        // use same url for this post & keep the jobid from the res.getHeaderKeys()
        String batchXml = '<?xml version="1.0" encoding="UTF-8"?>' + bodyStr2;
//              '<sObjects xmlns="http://www.force.com/2009/06/asyncapi/dataload">' + 
//          bodyStr2 + '</sObjects>';
            
        // Add this to the url we used before:   "/" + jobId + "/batch"
        PageReference batchUrl = new PageReference(url+postStr+'/'+jobId+'/batch');
        Http batchhttp = new Http();
        HttpRequest batchreq = new HttpRequest();
        HttpResponse batchres = new HttpResponse();
        batchreq.setMethod('POST');
        batchreq.setEndpoint(batchUrl.getUrl());
        batchreq.setHeader('X-SFDC-Session', ' ' + accessToken); // USE ACCESS TOKEN
        if (typeReq == 'XML') {
            batchreq.setHeader('Content-Type', ' application/xml; charset=UTF-8');
        } else {
            batchreq.setHeader('Content-Type', ' text/csv; charset=UTF-8');
        }
        batchreq.setTimeOut(60000);
        batchres = null;
        //String batchXml = bodyStr2;
        batchreq.setBody(batchXml);
        batchres = batchhttp.send(batchreq);
        System.debug('################## ' + batchres.getBody() + ' headers ' + batchres.getHeaderKeys());
        
        String body = 'CREATE BATCH RESPONSE:\n' + batchres.getStatusCode() + ' - ' + batchres.getStatus() + '\n' + batchres.getBody() + '\n'; // append status to previous status
        
        String batchId = getJobId(batchres.getBody());
        
        // stop here for creating batch
        JobAndResponse toreturn = new JobAndResponse();
        toreturn.batchid = batchid;
        toreturn.status = body;
        return toreturn;
        
    }
    
    public static String closeBatch(String url, String postStr, String jobId, String accessToken) {
        // begin here for closing batch (starting execution)
        
        // use same url for this post & keep the jobid from the res.getHeaderKeys()
        String closeXml = '<?xml version="1.0" encoding="UTF-8"?>' + 
            '<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">' +
            '<state>Closed</state>' + 
            '</jobInfo>';
            
        // Add this to the url we used before:   "/" + jobId 
        PageReference closeUrl = new PageReference(url+postStr+'/'+jobId);
        Http closehttp = new Http();
        HttpRequest closereq = new HttpRequest();
        HttpResponse closeres = new HttpResponse();
        closereq.setMethod('POST');
        closereq.setEndpoint(closeUrl.getUrl());
        closereq.setHeader('X-SFDC-Session', ' ' + accessToken); // USE ACCESS TOKEN
        closereq.setHeader('Content-Type', ' application/xml; charset=UTF-8');
        closereq.setTimeOut(60000);
        closeres = null;
        //String batchXml = bodyStr2;
        closereq.setBody(closeXml);
        closeres = closehttp.send(closereq);
        System.debug('################## ' + closeres.getBody() + ' headers ' + closeres.getHeaderKeys());
        
        String body = 'CLOSE JOB RESPONSE:\n' + closeres.getStatusCode() + ' - ' + closeres.getStatus() + '\n' + closeres.getBody() + '\n'; // append status to previous status
        
        return body;
    }
    
    public static String getJobId (String body) {
        String jobId = '';
        DOM.Document doc = new DOM.Document();
        doc.load(body);
        DOM.XMLNode root = doc.getRootElement();
        for (DOM.XMLNode child : root.getChildElements()) {
            if (child.getName() == 'id') {
                jobId = child.getText().trim();
                break; // exit for loop
            }
        }
        return jobId;
    }
    
    private class JobAndResponse {
        public String jobId {get;set;}
        public String status {get;set;}
        public String batchId {get;set;}
        
        public JobAndResponse() {
            jobId = '';
            status = '';
            batchId = '';
        }
    }

}