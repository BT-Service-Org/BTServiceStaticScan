public with sharing class OrgRefresh_DataTransformUtils {
    /**
     * Given a list of badges in org62, return a list of learning domains records for services org
     */
    static Map<String,String> skillMap;
    
    public static List<Learning_Domain__c> org62BadgesTransform(List<OrgRefresh_org62BadgesBean> org62Badges){
        
        List<Learning_Domain__c> servicesLearningDomains=new List<Learning_Domain__c>();

        for(OrgRefresh_org62BadgesBean orgBadgeBean:org62Badges){
            // don't add to learning domain if not in the list or if they have not passed
            System.debug('org62Badge bean ' + orgBadgeBean);
            System.debug('org62Badge bean info:' + orgBadgeBean.Badge);
            if (orgBadgeBean.Badge != null && orgBadgeBean.Badge.Name != null) {
                if (getSkill(orgBadgeBean.Badge.Name) != null && (orgBadgeBean.Quiz_Result == 'Pass' || orgBadgeBean.State == 'Acquired')) {
                    /* TODO: SKILLS MAPPING SHOULD BE MOVED TO CUSTOM SETTINGS */
    
                    Learning_Domain__c servicesLearningDomain=new Learning_Domain__c(  Skill__c=getSkill(orgBadgeBean.Badge.Name)
                                                                                 , Category__c=getCategory(orgBadgeBean.Badge.Name)
                                                                                 , Quiz_Complete__c=true
                                                                                 , Status__c=('Acquired'.equals(orgBadgeBean.State)?'Badged':'Ready')
                                                                                 , End_Date__c=orgBadgeBean.Date_Badge_Acquired!=null?orgBadgeBean.Date_Badge_Acquired.date():null
                                                                                 , PA_Onboarding__r=new PA_Onboarding__c(Candidate_Email__c=orgBadgeBean.User.Email)
                                                                                 , Unique_Id__c=orgBadgeBean.User.Email + getCategory(orgBadgeBean.Badge.Name) + getSkill(orgBadgeBean.Badge.Name)
                                                                                );
                    servicesLearningDomains.add(servicesLearningDomain);
                    System.debug('>>>>> LDomain:'+servicesLearningDomain);
                } 
            }
        }
        return servicesLearningDomains;
    }
    
    public static List<Contact> org62ContactsTransform(List<OrgRefresh_org62ContactsBean> org62Contacts){
        /**
        *  Update services org with relevant details from org62 contact
        */
        
        List<Contact> servicesContacts = new List<Contact>();

        //get a map of all contacts with their org 62 contact ID to be used for the update
        //need to construct the map as ID is not the Key
        Map<ID, ID> ContactIDMap = new Map<ID, ID>();

        for( Contact c : [select org62_Contact_ID__c, ID from Contact])
        {
            if( c.org62_Contact_ID__c != null )
                ContactIDMap.put( (ID)c.org62_Contact_ID__c, c.ID );
        }

        list<User> Manager;

        for(OrgRefresh_org62ContactsBean orgContactBean:org62Contacts){

            System.Debug( 'Bean-->'+ orgContactBean);

            //only update the record if all the relevant details are available from org62 bean 
            if( orgContactBean.pse_Utilization_Details != null && orgContactBean.pse_Region != null ){
                //check if untilization details are returned for this contact.  0 if nothing in org62
                Double utilization = ( orgContactBean.pse_Utilization_Details.records.size() > 0 ) ? orgContactBean.pse_Utilization_Details.records[0].Billable_Utilization_Total  : 0;
                String region = orgContactBean.pse_Region.Name;
      
                //all regions currenlty contain the name after a - i.e AS - AMER 
                //if(region.contains('-')) 
                //    region = region.split('-')[1].trim();
                //create a record for the contacts that we want to update

                //get the user of the person the contact reports to
                //handle the case where a contact doesnt have an employee usee i.e ID 0033000000DCGkr    
                /*if( orgContactBean.Employee_User == null ){
                    Manager = null;
                }
                else if (orgContactBean.Employee_User.sf62user_manager != null) {
                    Manager = [ select ID from User where FederationIdentifier=: orgContactBean.Employee_User.sf62user_manager.Email LIMIT 1];
                }

                System.Debug( 'Manager-->'+Manager);*/

                Contact servicesContact = new Contact(  ID = ContactIDMap.get( orgContactBean.Id ), 
                                                        //always use the first record returned as we are only pulling in 1 record via LIMIT in the query
                                                        FYTD_Util__c = utilization,
                                                        Is_Active_User__c = orgContactBean.pse_Is_Resource_Active,
                                                        Region__c = region,
                                                        //Manager__c = ( Manager != null && Manager.Size() >0 ) ? Manager[0].ID : null,
                                                        Default_Cost_Rate__c = orgContactBean.pse_Default_Cost_Rate,
                                                        Department = orgContactBean.department,
                                                        Employee_ID__c = orgContactBean.Employee_Number,
                                                        Hire_Date__c = orgContactBean.pse_Start_Date!=null?orgContactBean.pse_Start_Date.date():null
          
                                                   );
                servicesContacts.add(servicesContact);
                System.debug('>>>>> serviceContact:'+servicesContact);     
            }
        }
        //return the list of contacts that we want to update in the services org
        return servicesContacts;
    }
    
    public static List<Badge_Data__c> org62BadgesLPTransform(List<OrgRefresh_org62BadgesBean> org62Badges, List<PA_Onboarding__c> paList) {
        List<Badge_Data__c> lpBadgeData = new List<Badge_Data__c>();
        //Set<String> reqdPABadgeNames=new Set<String>();
        /*Fetch the Reqd PA Badges from the custom settings and populate the badge data required*/
        /* To satisfy Srin's reporting needs to measure whether a candidate has done the required badges*/
        /* PA_Badges custom settings is queried twice. Need to look for ways to optimize it*/
        /* GR:for(PA_Badges__c paBadgeInstance:[select Badge_Name__c 
                                          from PA_Badges__c 
                                          where Is_Learning_Path__c =true]){
            reqdPABadgeNames.add(paBadgeInstance.Badge_Name__c);
        }*/
        Map<Id, Badge_Data__c> bdmap = new Map<Id, Badge_Data__c>(); 
        /* TODO: skills mapping move to custom setting */
        for (OrgRefresh_org62BadgesBean orgBadgeBean:org62Badges) {
            //Commented out by anand to get badges for 9 domain badges
            //if (getSkill(orgBadgeBean.Badge.Name) == null) { // only if not a 9 domain badge
            if (orgBadgeBean.Badge != null && orgBadgeBean.Badge.Name != null) {
                Badge_Data__c lpBadge = new Badge_Data__c (
                                                        Name=orgBadgeBean.Badge.Name,
                                                        Quiz_Complete__c=(orgBadgeBean.Quiz_Result == 'Pass' ? true:false),
                                                        Acquired_Date__c=orgBadgeBean.Date_Badge_Acquired,
                                                        PA_Onboarding__r=new PA_Onboarding__c(Candidate_Email__c=orgBadgeBean.User.Email),
                                                        Unique_Id__c=orgBadgeBean.User.Email + orgBadgeBean.Badge.Name,
                                                        State__c=orgBadgeBean.State,
                                                        Cert__c=((orgBadgeBean.Badge.Name.startsWith('Certified'))?true:false),
                                                        /* To satisfy Srin's reporting needs to measure whether a candidate has done the required badges*/
                                                        X90_day_learning_path__c=orgBadgeBean.Required_Training,
                                                        X9_Domain_Badge__c=(getSkill(orgBadgeBean.Badge.Name)==null?false:true),
                                                        org62_Id__c=orgBadgeBean.Id
                                                    );
                Datetime dt = (Datetime) orgBadgeBean.CreatedDate; 
                //temporary fix - to be removed later
                Date dt1 = Date.newInstance(2018,5,15);
                Date dt2 = Date.newInstance(2018,8,15);
                
                Date dt3 = Date.newInstance(2018,1,1);
                Date dt4 = Date.newInstance(2018,2,28);

                System.Debug(dt.date() >= dt1 && dt < dt2);
                if (orgBadgeBean.State != 'Acquired' && orgBadgeBean.Required_Training == true 
                        && dt != null && ((dt >= dt1 && dt < dt2) || (dt >= dt3 && dt < dt4) || 
                        (dt < Date.newInstance(2018,8,15) && orgBadgeBean.Badge.Name=='Marketing Cloud Technical Easy Hike L1')) ) {
                    lpBadge.Date_Assigned__c = Date.newInstance(2018,8,15);
                } else {
                    lpBadge.Date_Assigned__c = dt.date();
                } 
                    
                
                //GR: 5/23/18 - if hide on profile is true, set required false
                //8/8/18 - Exception - Badges starting with Specialist, GCSC, Accelerator and Success Agent are marked required in org62
                // but are optional for baseline compliance. 
                if (orgBadgeBean.Badge.Type == 'Retired' || orgBadgeBean.Badge.Hide_on_Profile == true || orgBadgeBean.Badge.Name.startsWith('Success Agent') ||
                        orgBadgeBean.Badge.Name.startsWith('Specialist') ||
                        orgBadgeBean.Badge.Name.startsWith('Success Specialist') ||
                        orgBadgeBean.Badge.Name.startsWith('Support Manager') ||    //GR: 1/15/19 #06298021
                        orgBadgeBean.Badge.Name.startsWith('GCSC') ||
                        orgBadgeBean.Badge.Name.startsWith('Accelerator') ) {
   
                    lpBadge.X90_day_learning_path__c = false;
                }
                //set badge url
                if (orgBadgeBean.Badge.Learning_Goals != null && !lpBadge.X9_Domain_Badge__c) {
                    String url = orgBadgeBean.Badge.Learning_Goals.replaceAll('<[^>]+>',' ');
                    if (url.length() >= 250) {
                        lpBadge.Badge_URL__c = url.substring(0,200); 
                    } else {
                        lpBadge.Badge_URL__c = url;
                    }
                    
                }
                lpBadgeData.add(lpBadge);
                bdmap.put(orgBadgeBean.Id, lpBadge);
                System.debug('>>>>> lpBadge:'+lpBadge);
            }
            //Commented out by anand to get badges for 9 domain badges
            //}
        }
        
        Set<Id> onbset = new Set<Id>();
        for (PA_Onboarding__c onb : paList) {
            onbset.add(onb.Id);
        }
        
        System.debug('data transform util badge data ' + paList + lpBadgeData.size());
        for (Badge_Data__c bd : [select Id, Org62_Id__c, PA_Onboarding__c, X90_day_learning_path__c, State__c from Badge_Data__c 
                where PA_Onboarding__c in: onbset and Org62_Id__c != null and Org62_Id__c not in: bdmap.keySet() 
                and X90_day_learning_path__c =: true and State__c != 'Acquired']) {
            System.debug('data transform util ' + bd.Id);
            bd.X90_day_learning_path__c = false;
            lpBadgeData.add(bd);
        }
        System.debug('data transform util badge data after size ' + lpBadgeData.size());
        return lpBadgeData;
    }

    public static List<PA_Onboarding_Project__c> org62ProjectsTransform(List<OrgRefresh_org62ProjectsBean> org62Projects){
        
        List<PA_Onboarding_Project__c> servicesPAprojects=new List<PA_Onboarding_Project__c>();
        List<String> consultantEmails=new List<String>();
        List<Id> OptyIds = new List<Id>();
        List<Id> AcctIds = new List<Id>();
        for(OrgRefresh_org62ProjectsBean org62Project: org62Projects){
            consultantEmails.add(org62Project.pseResource.Email);
             OptyIds.add(org62Project.pseProject.pseOpportunity);
             if (org62Project.pseProject.pseAccount != null) AcctIds.add(org62Project.pseProject.pseAccount.Id);
        }
        Map<String,Id> consultantEmailIdMap = new Map<String,Id>();
        for(Contact consultant: [SELECT Id,Email FROM CONTACT WHERE EMAIL in :consultantEmails]){
            consultantEmailIdMap.put(consultant.Email,consultant.Id);
        }
        
        
        Map<Id,Id> OptyIdMap = new Map <Id,Id> ();
        Map<Id,Id> AcctIdMap = new Map <Id,Id> ();
        
        
          for(Account acc: [SELECT Id,Org62_Id__c FROM Account WHERE Org62_Id__c in :AcctIds]){
            AcctIdMap.put(acc.Org62_Id__c,acc.Id);
        } 
        
        for(Opportunity opty: [SELECT Id,Org62_Id__c FROM Opportunity WHERE Org62_Id__c in :OptyIds]){
            OptyIdMap.put(opty.Org62_Id__c,opty.Id);
        }
        
        

        for(OrgRefresh_org62ProjectsBean orgProjectBean:org62Projects){
          if(orgProjectBean!=null){
  
              PA_Onboarding_Project__c servicesPAProject=new PA_Onboarding_Project__c( PSE_Project_ID__c=orgProjectBean.id
                                                                             , Project_Role__c=orgProjectBean.pseRole
                                                                             , Project_Name__c=orgProjectBean.Name
                                                                             , Consultant__c = consultantEmailIdMap.get(orgProjectBean.pseResource.Email)
                                                                             , Customer_Name__c=((orgProjectBean.pseProject!=null && orgProjectBean.pseProject.pseAccount!=null) ? orgProjectBean.pseProject.pseAccount.Name : orgProjectBean.Name)
                                                                             , Project_Start_Date__c=orgProjectBean.pseStart_Date
                                                                             , Project_End_Date__c=orgProjectBean.pseEnd_Date
                                                                             , Project_Status__c=orgProjectBean.pseStatus
                                                                             , Non_Billable_Hours__c=orgProjectBean.pseNon_Billable_Hours_Submitted
                                                                             , Billable_Hours__c=orgProjectBean.pseBillable_Hours_Submitted
                                                                             , PA_Onboarding__r=new PA_Onboarding__c(Candidate_Email__c=orgProjectBean.pseResource.Email)
                                                                             , Unique_Id__c= orgProjectBean.pseResource.Email +  orgProjectBean.Name + orgProjectBean.pseStart_Date
                                                                             , Type__c=getType(orgProjectBean)
                                                                             , Region__c=((orgProjectBean.pseProject!=null && orgProjectBean.pseProject.pseRegion!=null) ? orgProjectBean.pseProject.pseRegion.Name : orgProjectBean.Name)
                                                                             , Franchise__c=((orgProjectBean.pseProject!=null) ? orgProjectBean.pseProject.Franchise : orgProjectBean.Name)
                                                                             , Description__c = orgProjectBean.pseDescription
                                                                             , Opportunity__c = OptyIdMap.get(orgProjectBean.pseProject.pseOpportunity)
                                                                             , Account__c = (orgProjectBean.pseProject.pseAccount != null ? AcctIdmap.get(orgProjectBean.pseProject.pseAccount.Id) : null)
                                                                             ,Project_ID__c = orgProjectBean.pseProject.id
                                                                             ,Project_Manager__c = (orgProjectBean.pseProject.pseProject_Manager != null ? orgProjectBean.pseProject.pseProject_Manager.name : '')
                                                                            ,   Reason_for_Swap__c = orgProjectBean.Reason_for_Swap
                                                                         );
              servicesPAprojects.add(servicesPAProject);
              System.debug('>>>>> SvsProject:'+servicesPAProject);
          }
        }
        return servicesPAprojects;
        

    }

    public static List<PA_Customer_Survey__c> org62CSATTransform(List<OrgRefresh_org62CSATBean> org62CSATs)
    {
        List<PA_Customer_Survey__c> customerSurveys = new List<PA_Customer_Survey__c>();
        ProjectDummyKeys__c customSetting = ProjectDummyKeys__c.getInstance('pseAccount');
        System.debug(customSetting.Pse_Account_Id__c);
        for (OrgRefresh_org62CSATBean orgCSATBean:org62CSATs) {
            
            //SCT adding debugs
            system.debug('orgCSATBean ' + orgCSATBean);
            if(orgCSATBean!=null)
            system.debug('orgCSATBean.pse_Project ' + orgCSATBean.pse_Project);
            if(orgCSATBean.pse_Project!=null)
            system.debug('orgCSATBean.pse_Project.pseAccount ' + orgCSATBean.pse_Project.pseAccount);
            if(orgCSATBean.pse_Project.pseAccount!=null)
            system.debug('orgCSATBean.pse_Project.pseAccount.Id ' + orgCSATBean.pse_Project.pseAccount.Id);

            //system.debug('AcctRef '+ AcctRef);
            Account AcctRef = new Account(Org62_Id__c = ((orgCSATBean.pse_Project!=null && orgCSATBean.pse_Project.pseAccount!=null) ? orgCSATBean.pse_Project.pseAccount.Id : customSetting.Pse_Account_Id__c));
            //SCT adding debugs
            system.debug('orgCSATBean ' + orgCSATBean);
            system.debug('orgCSATBean.pse_Project ' + orgCSATBean.pse_Project);
            system.debug('orgCSATBean.pse_Project.pseAccount ' + orgCSATBean.pse_Project.pseAccount);
          //  system.debug('orgCSATBean.pse_Project.pseAccount.Id ' + orgCSATBean.pse_Project.pseAccount.Id);
            system.debug('AcctRef '+ AcctRef);
            PA_Customer_Survey__c customerSurvey = new PA_Customer_Survey__c (
                                                                                Account__r = AcctRef,
                                                                                Account_Id__c = (orgCSATBean.pse_Project.pseAccount !=null ? orgCSATBean.pse_Project.pseAccount.Id : customSetting.Pse_Account_Id__c),
                                                                                Account_Name__c = (orgCSATBean.pse_Project.pseAccount!=null ? orgCSATBean.pse_Project.pseAccount.Name : ''),
                                                                                Overall_Score__c = orgCSATBean.US_Overall_Satisfaction,
                                                                                Contact__r=new Contact(Email=orgCSATBean.Resource_Name.Email),
                                                                                Project_Id__c = orgCSATBean.pse_Project.Id,
                                                                                Project_Start_Date__c = orgCSATBean.pse_Project.pseStart_Date,
                                                                                Project_End_Date__c = orgCSATBean.pse_Project.pseEnd_Date,
                                                                                Survey_Completed_Date__c  = orgCSATBean.CompletionTime,
                                                                                Survey_Sent_Date__c = orgCSATBean.Survey_Sent_Date,
                                                                                Org62_Survey_Id__c = orgCSATBean.Id,
                                                                                Timeliness__c = orgCSATBean.Timeliness,
                                                                                Value_Achieved__c = orgCSATBean.Value_Achieved,
                                                                                Likelihood_to_Recommend__c = orgCSATBean.Likelihood_to_Recommend_to_Others,
                                                                                Services_Team_s_Competency__c = orgCSATBean.Services_Team_s_Professionalism_Knowle,
                                                                                Region__c=((orgCSATBean.pse_Project!=null && orgCSATBean.pse_Project.pseRegion!=null) ? orgCSATBean.pse_Project.pseRegion.Name : orgCSATBean.Name)
                                                                             );
            
            system.debug('customerSurvey'+ customerSurvey);
            customerSurveys.add(customerSurvey);
        }
        return customerSurveys;
    }
    private static string getType(OrgRefresh_org62ProjectsBean orgProjectBean){
        if(orgProjectBean.Name != null && orgProjectBean.Name.contains('Foundation')){
            return 'Foundation';
        }
        if(orgProjectBean.pseRole != null && orgProjectBean.pseRole.contains('Shadow')){
            return 'Shadow';
        }
        
        System.debug('>>>>>>> orgProjectBean = '+orgProjectBean);
        System.debug('>>>>>>> orgProjectBean = '+orgProjectBean.pseProject);

        //if(orgProjectBean.Name != null && orgProjectBean.Name.contains('Internal')){return 'Investment';}
        if(orgProjectBean.pseProject!= null && orgProjectBean.pseProject.RecordType!=null &&
           orgProjectBean.pseProject.RecordType.name != null && 
           orgProjectBean.pseProject.RecordType.name.contains('Internal')
        ){
            return 'Investment';
        }if(orgProjectBean.pseProject!= null && orgProjectBean.pseProject.RecordType!=null &&
           orgProjectBean.pseProject.RecordType.name != null && 
           orgProjectBean.pseProject.RecordType.name=='Z - code'
        ){
            return 'Self';
        }
        return 'Billable';
    }
    
    /*
    private static string getType(OrgRefresh_org62ProjectsBean orgProjectBean){
        return ((orgProjectBean.pseBillable_Hours_Submitted > 0) ? 'Billable' 
                                                             : ((orgProjectBean.Name.contains('Foundation')) ? 'Foundation' 
                                                                                                                      : null));
    }
    */
    
    private static String getSkill(String badgeName){
       if(skillMap!=null){
            System.debug('badge name '+ skillMap.get(badgeName));
            return skillMap.get(badgeName);
       }
       else{
         skillMap=new Map<String,String>();
/* Sriram Venkatraman 12/19/2017: Replacing old domain names to new names post Bedrock launch
         skillMap.put('Program Architect: SSO', 'Single Sign On');
         skillMap.put('Program Architect: Sharing & Visibility', 'Sharing & Security');
         //skillMap.put('Program Architect Methodology', 'Business Process');
         skillMap.put('Program Architect: Tools & Environment Management', 'Change Management');
         skillMap.put('Program Architect: Scalability & Large Data Volumes', 'Large Data Volume');
         skillMap.put('Program Architect: Declarative App Design', 'Application Design');
         skillMap.put('Program Architect: Mobile', 'Mobile');
         skillMap.put('Program Architect: Communities & Sites', 'Communities & Sites');
         skillMap.put('Program Architect: Integration', 'Integration');
         skillMap.put('Program Architect: Apex', 'Apex & VF');
*/
         skillMap.put('Program Architect: SSO', 'Identity & Access Management');
         skillMap.put('Program Architect: Sharing & Visibility', 'Sharing & Visibility');
         skillMap.put('Program Architect: Tools & Environment Management', 'Development Lifecycle & Deployment');
         skillMap.put('Program Architect: Scalability & Large Data Volumes', 'Data Architecture & Management');
         skillMap.put('Program Architect: Declarative App Design', 'Application Design');
         skillMap.put('Program Architect: Mobile', 'Mobile Strategy Architecture');
         skillMap.put('Program Architect: Communities & Sites', 'Communities Architecture');
         skillMap.put('Program Architect: Integration Strategy', 'Integration Architecture');
         skillMap.put('Program Architect: Integration', 'Integration Architecture');
         skillMap.put('Program Architect: Apex', 'Apex & Visualforce');
         // Geeta: Added the 2 new domains 
         skillMap.put('Program Architect: Marketing Automation', 'Marketing Cloud');
         skillMap.put('Program Architect: Analytics Architecture', 'Analytics Architecture');
         
     
         return  skillMap.get(badgeName);
       }
    }

    private static String getCategory(String badgeName){
        if('Program Architect Methodology'.equals(badgeName)){
            return 'Business Skill';
        }
        else{
            return 'Technical Skill';
        }
    }

  /*private static Date parseDate(String dtStr){
        //assumes incoming format is yyyy-mm-ddThh:mm:ss.000+0000
        return (dtStr!=null?Date.valueOf(dtStr.substring(0,10)+' '+dtStr.substring(11,19)):null);
  }*/
}