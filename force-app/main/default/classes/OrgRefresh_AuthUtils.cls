/**
 * ClassName: AuthUtils
 * Purpose: Provide a set of utility method to enable oauth2.0 web auth flow with refresh token
 * Date: Feb 5 2014
 */
public with sharing class OrgRefresh_AuthUtils {
   private static Org_Refresh_Profile__c refreshProfile;
    
    private static string getEndPoint(){ 
        refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile();
        return refreshProfile.Endpoint__c;
    }
    
    private static string AUTH_ENDPOINT { get { return getEndPoint() + '/services/oauth2/authorize';}}
    private static string TOKEN_ENDPOINT { get { return getEndPoint() + '/services/oauth2/token';}}
    

    //Method to authenticate user by redirecting to approrpriate endpoint
    public static PageReference redirectAuthScreen() {
        //fetch the refresh profile settings
        refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile();

        String authURL=AUTH_ENDPOINT + '?response_type=code&client_id='+ refreshProfile.Consumer_Key__c 
                                     + '&redirect_uri=' + refreshProfile.CallBack_URL__c 
                                     + '&display=page&immediate=false'; 

        PageReference authPageRef=new PageReference(authURL);
        authPageRef.setRedirect(true);

        return authPageRef; 
    }

    /**
     * Polymorphic method authenticateUser for various auth flows
     * This method returns the access token and appropriate refresh token for a given authentication code
     */
    public static string authenticateUser( OrgRefresh_AuthFlows authflow
                                         , String authCode
                                         , Boolean updatDBSettings){
        //Web flow scenario. User is authenticating from the web with the auth code.
        //fetch the custom settings value
        refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile();
        if(  OrgRefresh_QueryUtils.validateEnum(authflow, OrgRefresh_AuthFlows.OAUTH_WEBFLOW)){
              String flowSpecificParams='?grant_type=authorization_code&code='+authCode +
                                         '&redirect_uri='+EncodingUtil.urlEncode(refreshProfile.CallBack_URL__c,'UTF-8');
              refreshProfile=fetchAccessToken(authflow,flowSpecificParams,updatDBSettings);
              return refreshProfile.Access_Token__c;
        }
        
        //throw invalid oauth flow exception
        else{
            throw new OrgRefresh_InvalidAuthFlowException('Invalid oauth flow specified');
        }
    }

    
    /**
     * Polymorphic method authenticateUser for various auth flows
     * This method returns the access token if the system has a valid refresh token stored.
     */

    public static string authenticateUser( OrgRefresh_AuthFlows authflow
                                         , Boolean updateDBSettings){
      //Refresh token scenario. System has the refresh token and is trying to obtain an access token using a refresh token
      refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile();



        if(OrgRefresh_QueryUtils.validateEnum(authflow, OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN)
            && refreshProfile!=null
            && refreshProfile.Refresh_Token__c!=null
            && refreshProfile.Refresh_Token__c !=''){
              String flowSpecificParams='?grant_type=refresh_token&refresh_token='+EncodingUtil.urlEncode(refreshProfile.Refresh_Token__c,'UTF-8');
              refreshProfile=fetchAccessToken(authflow,flowSpecificParams,updateDBSettings);
              return refreshProfile.Access_Token__c;
        }
        //throw invalid oauth flow exception
        else{
            throw new OrgRefresh_InvalidAuthFlowException('No Refresh Token or Invalid Refresh Token');
        }
    }

    /**
    * Polymorphic method authenticateUser for various auth flows
    * This method returns the access token if the system has a valid refresh token stored.
    */
    public static string authenticateUser(Org_Refresh_Profile__c refreshProfInstance, Boolean updateDBSettings)
    {
        refreshProfile = refreshProfInstance;

        if(refreshProfInstance != null && string.isNotBlank(refreshProfInstance.Refresh_Token__c))
        {
            string flowSpecificParams = '?grant_type=refresh_token&refresh_token=' + EncodingUtil.urlEncode(refreshProfile.Refresh_Token__c,'UTF-8');
            refreshProfile = fetchAccessToken(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN, flowSpecificParams, updateDBSettings);
            return refreshProfile.Access_Token__c;
        }
        else
        {
            throw new OrgRefresh_InvalidAuthFlowException('No Refresh Token or Invalid Refresh Token');
        }
    }

     /**
     * Polymorphic method authenticateUser for various auth flows
     * This method returns the access token for a given org profile
     */
     public static string authenticateUser(Org_Refresh_Profile__c refreshProfInstance) {
        System.debug('<==authenticateUser: ');
        System.debug(refreshProfInstance);
        String accessToken;
        // first authenticate based on flow.
        if (refreshProfInstance.UserNamePwd_Flow__c!=null && refreshProfInstance.UserNamePwd_Flow__c) {
             accessToken= authenticateUser(OrgRefresh_AuthFlows.USERNAME_PASSWORD,
                                                                    refreshProfInstance.Name,
                                                                    refreshProfInstance.UserName__c,false);
        }
        else {
             accessToken= authenticateUser(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN,false);
        }
        System.debug('accessToken:' + accessToken);
        /*TODO: add error handling */
        return accessToken;
        
     }

     /**
     * Polymorphic method authenticateUser for various auth flows
     * This method returns the access token for a given org name and username
     */

    public static string authenticateUser( OrgRefresh_AuthFlows authflow
                                         , String orgName
                                         , String userName
                                         , Boolean updatDBSettings){
      //Refresh token scenario. System has the refresh token and is trying to obtain an access token using a refresh token
        if(OrgRefresh_QueryUtils.validateEnum(authflow, OrgRefresh_AuthFlows.USERNAME_PASSWORD)
            && orgName!=null
            && userName!=null
            && orgName !=''
            && userName !=''){
              //Query the password for a given org and a user from an encrypted field in DB
             List<Org_Refresh_Creds__c> orgRefreshCred=[select User_Name__c
                                                             , Name
                                                             , Password__c 
                                                        from Org_Refresh_Creds__c
                                                        where User_Name__c=:userName
                                                        and Name =:orgName];
              //there should be one and only one record defined for a username and org name combination
              if(orgRefreshCred!=null && orgRefreshCred.size()==1){
                 String flowSpecificParams='?grant_type=password&username='+EncodingUtil.urlEncode(userName,'UTF-8') + '&password='+ EncodingUtil.urlEncode(orgRefreshCred.get(0).Password__c,'UTF-8');
                 refreshProfile=fetchAccessToken(authflow,flowSpecificParams,updatDBSettings);
                 return refreshProfile.Access_Token__c;
              }
              else{
                throw new OrgRefresh_InvalidAuthFlowException('No credentials defined for username and orgname');
              }
              
        }
        //throw invalid oauth flow exception
        else{
            throw new OrgRefresh_InvalidAuthFlowException('Invalid oauth flow specified');
        }
    }

    /**
     * Method that returns the access token for a specified auth flow.
     * Auth params contains the necessary grant_type and params specific to the requested auth flow.
     * Common auth params are taken care in this method
     * @params - authflow - Enum of requested auth flow. The class lists the supported authentication flows.
     * @params - flowSpecificParams - Params specific to the requested auth flow.
     * @params - updatDBSettings - Should the auth return values be updated to database or not.
     */
    private static Org_Refresh_Profile__c fetchAccessToken( OrgRefresh_AuthFlows authflow
                                         , String flowSpecificParams
                                         , Boolean updatDBSettings){

        //fetch custom setting values
        refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile();
        
        HttpRequest request = new HttpRequest();
        String postParams=flowSpecificParams 
                         + '&client_id='+EncodingUtil.urlEncode(refreshProfile.Consumer_Key__c,'UTF-8')
                         + '&client_secret='+EncodingUtil.urlEncode(refreshProfile.Consumer_Secret__c,'UTF-8');
        request.setEndpoint(TOKEN_ENDPOINT+postParams);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        //set the token request
        String body = (new Http()).send(request).getBody();
        System.debug('>>>>>>>>>> HTTP Body:'+body);
        //parse the response into a map
        Map<String, Object> tokenMap = (Map<String, Object>) JSON.deserializeUntyped(body);

        //store the key values in the custom settings
        refreshProfile.Access_Token__c=(String)tokenMap.get('access_token');
        refreshProfile.Instance_URL__c=(String)tokenMap.get('instance_url');
        //current flow is refresh token flow
        if(OrgRefresh_QueryUtils.validateEnum(authflow, OrgRefresh_AuthFlows.OAUTH_WEBFLOW)){
            refreshProfile.Refresh_Token__c=(String)tokenMap.get('refresh_token');
        }
        if(updatDBSettings!=null && updatDBSettings){
            upsert refreshProfile;
        }
        return refreshProfile;
    }

    

     
}