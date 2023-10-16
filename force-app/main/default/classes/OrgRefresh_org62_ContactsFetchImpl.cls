public with sharing class OrgRefresh_org62_ContactsFetchImpl implements OrgRefresh_FetchInterface, OrgRefresh_BatchInterface {
/**
 * Classes that implement OrgRefresh_FetchInterface have a naming pattern to be followed for the code to function properly.
 * OrgRefresh_<ORGNAME>_<APPNAME>FetchImpl. Please name the appname and org name concise.
 * 
 */

    /**
     * Method to construct the dynamic query based on the settings defined in the custom settings.
     */
    // set this to false if you want to update the timestamp outside of the class
    private List<PA_Onboarding__c> paList {get; set;} 
    private Org_Refresh_Profile__c refreshProfile;

    /* Constructor */  
    public OrgRefresh_org62_ContactsFetchImpl() { 
    }
    
    //query to base the records we want to pull out of org62
    public string constructSourceQuery() {
        return 'select  id '+
                     ', Contact__c '+
                     ', Contact__r.Email '+
                     ', name ' +
                     ', contact__r.org62_Contact_ID__c ' +
                    'from PA_Onboarding__c '+ 
                    'where Contact__c!=null '+ 
                       'and Contact__r.Email!=null '+ 
                       'and Contact__r.org62_Contact_ID__c != null ' +
                       'and Contact__r.Email!=\'\' '+
                       'and Program__c in (\'Accelerated Onboarding\', \'PA Track\', \'CTA Prep\', \'Existing PA\', \'Observer\',\'Existing BA\',\'BA Ramp\',\'Former CST\',\'Services PM\',\'MC Advisor\',\'Practices\')';
    }
    
    
    public string constructQuery(String orgAppName, boolean fullRefresh){
        System.debug('====OrgRefresh_org62_ContactsFetchImpl constructQuery====');
          
        String queryStr=OrgRefresh_QueryUtils.constructBaseQuery(fullRefresh);
        
        String queryClause = ' where ';

        //base th query off of org62 contact ID that is stored on the services contact record
        queryStr+= queryClause + constructContactIDList();

        System.debug('=====contact retr queryStr======' + queryStr);
        return queryStr;
    }

     //leaving the below in the event we want to revert to using email and not contact ID
     private String constructEmailList(){
        List<String> contactEmails=new List<String>();
            
        for(PA_Onboarding__c paOnboard: paList){
               contactEmails.add(paOnboard.Contact__r.Email);
        }
        String emailStr=' User__r.Email in ';
        
        emailStr+=OrgRefresh_QueryUtils.convertListToStr(contactEmails);
        return emailStr;
    }

    //create a string which will be used as the condition of the where clause to query org62
    private String constructContactIDList(){
        List<String> contactIds=new List<String>();
            
        for(PA_Onboarding__c paOnboard: paList){
               contactIds.add(paOnboard.Contact__r.org62_Contact_ID__c);
        }
        String contactStr=' Contact.Id in ';
        contactStr+=OrgRefresh_QueryUtils.convertListToStr(contactIds);
        return contactStr;
    }
    
    public void fetchAndUpdateData(String accessToken,String orgAppName){  
        System.debug('inside fetch and update');
        List<SObject> inputList = Database.query(constructSourceQuery());
        //always doing a full refresh as the modified time doesnt change on contact records when utilization is updated
        List<OrgRefresh_BatchResult> result = 
                fetchAndUpdateData(inputList, accessToken, orgAppName, true); //TODO: revisit full refresh
    } 

    public List<OrgRefresh_BatchResult> fetchAndUpdateData(List<SObject> candidateList, String accessToken,String orgAppName, boolean fullRefresh){
        this.paList = (List<PA_OnBoarding__c>)candidateList;
        System.debug('====OrgRefresh_org62_ContactsFetchImpl fetchAndUpdateData====');
         //set the orgname
        OrgRefresh_QueryUtils.setOrgAppName(orgAppName);
        //final list to store org62 contact information
        final List<OrgRefresh_org62ContactsBean> org62Contacts=new List<OrgRefresh_org62ContactsBean>();
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
                //also replace __ as the PSE objects have __ in their name ie pse__Region__c and __ are illegal in var names
                body=body.replace('__c','');
                body=body.replace('__r','');
                body=body.replace('__','_');

                System.debug('body after stripping chars-->'+body);
                  
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
            
                //the following line is wicked cool - footnote: the first person to create this model wrote that
                final List<OrgRefresh_org62ContactsBean> contactsData = (List<OrgRefresh_org62ContactsBean>) parser.readValueAs(List<OrgRefresh_org62ContactsBean>.class);
                System.debug('contactsData size as native list: ' + contactsData.size());
                System.debug('contactsData size as native list: ' + contactsData);

                org62Contacts.addAll(contactsData);
                calloutCntr ++ ;
                Url=refreshProfile.Instance_URL__c + nextRecordsUrl;
                
            }while(calloutCntr< 5 && !isRecordFetchDone);
               
            //transform org62 contact information to services org
            final List<Contact> contacts=OrgRefresh_DataTransformUtils.org62ContactsTransform(org62Contacts);
 
            //setup upsert for partial success so that one failure doesn't affect other records

            Database.SaveResult[] results=Database.update(contacts, false);
            for(Database.SaveResult updateResultInstance:results){
                if(!updateResultInstance.isSuccess()){
                    System.debug('====UPDATE Contact ERRORS======' + updateResultInstance.getErrors());                 
                }
                finalResults.add(new OrgRefresh_BatchResult(updateResultInstance.id, false, updateResultInstance.isSuccess(), String.valueOf(updateResultInstance.getErrors())));
                
            }       

            System.Debug( 'Final Results-->' + finalResults);    
            
            // always execute this outside          
            refreshProfile.Last_Refreshed__c=System.now();
            upsert refreshProfile Name;

        }
        return finalResults;
    }
    
}