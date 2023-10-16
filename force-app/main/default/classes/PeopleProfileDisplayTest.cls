@IsTest private class PeopleProfileDisplayTest {

    public static testMethod void testPeople() {
        try{
             
            PeopleProfileDisplayController people= new PeopleProfileDisplayController();
            PeopleProfileDisplayController.PeopleSearch search= new PeopleProfileDisplayController.PeopleSearch();
            PeopleProfileDisplayController.Profile profile = people.getProfile();
            PeopleProfileDisplayController.Profile profile2= new PeopleProfileDisplayController.Profile();     
            
            // Status Instance
            PeopleProfileDisplayController.Status status= new PeopleProfileDisplayController.Status();
            status.setMessage('fdafadsfdsa fdsa fd saf');
            String mess = status.getMessage();
            status.setModified(System.now());
            String statusmodified = status.getModified();
            status.setModified((System.now()).addDays(3213));
            
            DateTime now = System.now();
            status.setModified(now);
            
            String time = people.getCurrentTime();
            String profileId = people.getProfileUserId();
            Boolean currentuser = people.getIsCurrentUser();
            Boolean getHasDirectReportsExpand = people.getHasDirectReportsExpand();
            Boolean getShowSubscribedPeople = people.getShowSubscribedPeople();
            Integer getCountSubscribedToMe = people.getCountSubscribedToMe();
            integer getCountImSubscribedTo = people.getCountImSubscribedTo();
            people.subscriptionCounts();        
            
            boolean getShowAboutMe = people.getShowAboutMe();
            boolean getShowDirectRepots = people.getShowDirectRepots();
            boolean getShowMiniFeeds = people.getShowMiniFeeds();
            boolean getShowEmploymentHistories = people.getShowEmploymentHistories();
            boolean getShowEducationHistories = people.getShowEducationHistories();
            boolean getShowOtherNetworks = people.getShowOtherNetworks();
            PeopleProfileDisplayController.PeopleSearch searchobj = new PeopleProfileDisplayController.PeopleSearch();
            searchobj.setKeyword('k');
            PageReference findpeople = people.findPeople();
            String searchobjKey = searchobj.getKeyword();
            
            String picture = people.getPicture();
            PeopleProfile__c userId = [select User__c from PeopleProfile__c LIMIT 1];
            
            PeopleProfileDisplayController.Profile buildProfile = new PeopleProfileDisplayController.Profile();
            buildProfile.setYahooIM('aa');
            buildProfile.setSkype('aa');
            buildProfile.setGtalk('aa');
            buildProfile.setAol('aa');
            buildProfile.setUserId(userId.User__c);
            buildProfile.setName('aa');
            buildProfile.setStatus('aa');
            buildProfile.setFirstName('aa');
            buildProfile.setLastName('aa');
            buildProfile.setTitle('aa');
            buildProfile.setDivision('aa');
            buildProfile.setDepartment('aa');
            buildProfile.setMobilePhone('aa');
            buildProfile.setPhone('aa');
            buildProfile.setFax('aa');
            buildProfile.setEmail('aa');
            buildProfile.setAboutMe('aa');
            buildProfile.setPhone('aa');
            
            boolean statusBoolean = people.getShowStatus();
            PeopleProfileDisplayController.Status statusInstance = people.getStatus();
            statusInstance.setModified(System.now());
            String getModifiedStatus =  statusInstance.getModified();
            List<PeopleProfileDisplayController.Connection> mostConnectedUserlist = people.getMostConnectedUsers(); 
            List<PeopleProfileDisplayController.Connection> mostConnectedSortedUserlist = people.sortConnections(mostConnectedUserlist);
            List<PeopleProfileDisplayController.educationHistories> listEducationHistories= people.getEducationHistories();
            PeopleProfileDisplayController.educationHistories educationHistories= new PeopleProfileDisplayController.educationHistories();
            List<PeopleProfileDisplayController.employmentHistory> listEmploymentHistories = people.getEmploymentHistories();
            PeopleProfileDisplayController.employmentHistory employmentHistory= new PeopleProfileDisplayController.employmentHistory();
            List<PeopleProfileDisplayController.PersonProfile> listDirectReports = people.getDirectReports();
            List<PeopleProfileDisplayController.miniFeed> listMiniFeeds = people.getMiniFeeds();
            PeopleProfileDisplayController.miniFeed miniFeed= new PeopleProfileDisplayController.miniFeed();
            List<PeopleProfileDisplayController.ExternalNetworks> listOtherNetworks = people.getOtherNetworks();
            PeopleProfileDisplayController.ExternalNetworks externalNetworks = new PeopleProfileDisplayController.ExternalNetworks();
            //List<PeopleProfileDisplayController.TeamMember> listTeamspaces = people.getTeamspaces();
            //PeopleProfileDisplayController.TeamMember teamMember= new PeopleProfileDisplayController.TeamMember();
            Integer getNumberOfDirectReports = people.getNumberOfDirectReports();
            Integer getCompetenciesNumber = people.getCompetenciesNumber();
            List<UserCompetencies__c> getCompetencies = people.getCompetencies();
            
            people.setProfileUserId(userId.User__c);
            
            profileId = people.getProfileUserId();
            currentuser = people.getIsCurrentUser();
            getHasDirectReportsExpand = people.getHasDirectReportsExpand();
            getShowSubscribedPeople = people.getShowSubscribedPeople();
            getCountSubscribedToMe = people.getCountSubscribedToMe();
            getCountImSubscribedTo = people.getCountImSubscribedTo();
            people.subscriptionCounts();
            getShowAboutMe = people.getShowAboutMe();
            getShowDirectRepots = people.getShowDirectRepots();
            getShowMiniFeeds = people.getShowMiniFeeds();
            getShowEmploymentHistories = people.getShowEmploymentHistories();
            getShowEducationHistories = people.getShowEducationHistories();
            getShowOtherNetworks = people.getShowOtherNetworks();
            picture = people.getPicture();
            profile = people.getProfile();
            
            listEducationHistories= people.getEducationHistories();
            educationHistories= new PeopleProfileDisplayController.educationHistories();
            listEmploymentHistories = people.getEmploymentHistories();
            employmentHistory= new PeopleProfileDisplayController.employmentHistory();
            listDirectReports = people.getDirectReports();
            listMiniFeeds = people.getMiniFeeds();
            miniFeed= new PeopleProfileDisplayController.miniFeed();
            listOtherNetworks = people.getOtherNetworks();
            externalNetworks = new PeopleProfileDisplayController.ExternalNetworks();
            //listTeamspaces = people.getTeamspaces();
            //teamMember= new PeopleProfileDisplayController.TeamMember();
            getNumberOfDirectReports = people.getNumberOfDirectReports();
            getCompetenciesNumber = people.getCompetenciesNumber();
            getCompetencies = people.getCompetencies();
           
            List<PeopleProfile__c> userIds = [select User__c from PeopleProfile__c LIMIT 3];
          
            //String getTeamsBullet = people.getTeamsBullet();
            
            // employmentHistory inner
            PeopleProfileDisplayController.employmentHistory employmentHistoryInstance = new PeopleProfileDisplayController.employmentHistory();
            employmentHistoryInstance.setId(userIds[0].User__c);
            Id idEmp = employmentHistoryInstance.getId();
            employmentHistoryInstance.setName('aa');
            String geteducationName = employmentHistoryInstance.getName();
            employmentHistoryInstance.setPosition('aa');
            String getposition = employmentHistoryInstance.getPosition();
            employmentHistoryInstance.setDescription('aa');
            String getDescriptioninHistory = employmentHistoryInstance.getDescription();
            employmentHistoryInstance.setEmployerCityTown('aa');
            String getEmployerCityTown = employmentHistoryInstance.getEmployerCityTown();
            employmentHistoryInstance.setCurrentJob(true);          
            Date nowInDateFormat = Date.newInstance(12,6,12);
            Date otherDateFormat = Date.newInstance(12,6,6);
            employmentHistoryInstance.setWorkedFrom(nowInDateFormat);
            String employmenthstoryworkedfrom = employmentHistoryInstance.getWorkedFrom();      
            employmentHistoryInstance.setWorkedTo(otherDateFormat);         
            PeopleProfileDisplayController.Connection connectionInnerInstance = new PeopleProfileDisplayController.Connection();
            connectionInnerInstance.setStatus(userIds[0].User__c);
            String constats = connectionInnerInstance.getStatus();
            connectionInnerInstance.setMatches(56454);
            Integer conmatchs = connectionInnerInstance.getMatches();
            connectionInnerInstance.setName('fdsafdsa');
            String conName = connectionInnerInstance.getName();
            connectionInnerInstance.setId(userIds[0].User__c);
            String Id = connectionInnerInstance.getId();
            connectionInnerInstance.setUserPicture(userIds[0].User__c);
            
            // education History inner
            PeopleProfileDisplayController.educationHistories edHistoryInstance = new PeopleProfileDisplayController.educationHistories();
            edHistoryInstance.setId(userIds[0].User__c);
            String edHistorId = edHistoryInstance.getId();
            edHistoryInstance.setName('dsjhdkjsa');
            String edHistoryName = edHistoryInstance.getName();
            edHistoryInstance.setSchool('dsjhdkjsa');
            String edHistorySchool = edHistoryInstance.getSchool();
            edHistoryInstance.setDegree('dsjhdkjsa');
            String edHistoryDegree = edHistoryInstance.getDegree();
            edHistoryInstance.setFieldsOfStudy('dsjhdkjsa');
            String edHistoryfieldsofstudy = edHistoryInstance.getFieldsOfStudy();
            edHistoryInstance.setDateAttendedFrom(2.34);
            Integer edHistoryInstancegetDateAttendedFrom = edHistoryInstance.getDateAttendedFrom();
            edHistoryInstance.setDateAttendedTo(34324.232);
            Integer edHistoryInstancegetDateAttendedTo = edHistoryInstance.getDateAttendedTo();
          
            // Team Member Inner Class
            /*
            PeopleProfileDisplayController.TeamMember teamMemberInstance = new PeopleProfileDisplayController.TeamMember();
            teamMemberInstance.setId(userIds[0].User__c);
            String tmId = teamMemberInstance.getId();
            teamMemberInstance.setName('sadsadsadsa');
            String tmIda = teamMemberInstance.getName();
            teamMemberInstance.setDescription('fdasfdsafdsaf');
            String tmIdv = teamMemberInstance.getDescription();
            teamMemberInstance.setCreatedDate(System.now());            
            String tmIdd = teamMemberInstance.getCreatedDate(); 
            */
            
            // Other Networks Inner Class
            PeopleProfileDisplayController.ExternalNetworks exNetsInstance = new PeopleProfileDisplayController.ExternalNetworks();
            exNetsInstance.setLink('fsadfdsa');
            exNetsInstance.setNetName('fdasfdsaf');
            String netInstNetName = exNetsInstance.getNetName();
            String netInstNetLink = exNetsInstance.getLink();
            
        }catch(Exception e){
            throw e;
        }
    }

}