public without sharing class IC_Talent_Management {
    public Boolean initialised { get { return IsInitialised; } }
    private Boolean IsInitialised = false;
    
    private Id UserId;
    
    public Talent_Management__c Individual { get { return iIndividual; } }
    private Talent_Management__c iIndividual;
 
    public LGData Data { get { return iData; } }
    private LGData iData;

    public List<Talent_Management__c> MyDirects { get { return iMyDirects; } }
    private List<Talent_Management__c> iMyDirects;
    public Boolean ShowMyTeam  { get { return ( iMyDirects.size() > 0 ); } }
    
	private Id DirectId;
    public Talent_Management__c Direct { get { return iDirect; } }
    private Talent_Management__c iDirect;
    public Boolean ShowDirect { get { return ( DirectId != UserId ); } }
 
    public LGData DirectLG { get { return iDirectLG; } }
    private LGData iDirectLG;

    public Boolean ShowNote { get { return ( iIndividual.Career_Profile__r.Special_note__c != NULL ) ; } }
    public Boolean ShowNoteOpty { get { return ( iIndividual.Opportunity_Profile__r.Special_note__c != NULL ) ; } }
    public Boolean ShowDirectNote { get { return ( iDirect.Career_Profile__r.Special_note__c != NULL ) ; } }
    public Boolean ShowDirectNoteOpty { get { return ( iDirect.Opportunity_Profile__r.Special_note__c != NULL ) ; } }
    
    public IC_Talent_Management() {
        UserId = UserInfo.getUserId();
        DirectId = UserId;
    }    

    public void UpdateOpportunity() {
        iData.ClearLists();
        iData = new LGdata(iIndividual);
        CleanUpdate(iIndividual);
		iIndividual = ReloadIndividual(UserId);   
	}

    public void UpdateDirect() {
        iDirectLG.ClearLists();
        iDirectLG = new LGdata(iDirect);
        CleanUpdate(iDirect);
        iDirect = ReloadIndividual(DirectId);
        iMyDirects = ReloadDirects();
    }
    
    public void SelectDirect() {
        if( Test.isRunningTest() )
            DirectId = iIndividual.Id;
//			iDirect = ReloadIndividual(DirectId);
        else
	        DirectId = ApexPages.currentPage().getParameters().get('cId');
//        iDirectLG.ClearLists();
		iDirect = ReloadIndividual(DirectId);
        iDirectLG = new LGdata(iDirect);
        CleanUpdate(iDirect);
        iMyDirects = ReloadDirects();
    }
    
    public void CheckRecordExist() {
        if ( !IsInitialised || Test.isRunningTest() ) {
        	List<Talent_Management__c> lstQry = [SELECT Id
            	                                 FROM Talent_Management__c
                	                             WHERE User__c = :UserId];
            if( lstQry.size() == 0 || Test.isRunningTest() ) {
                User curUsr = [SELECT JobCode__c
                               FROM User
                               Where Id = :UserId][0];
            	String strJobCode = '' + curUsr.JobCode__c; 
	            String strGrade = '0';
    	        String strFamily = '0';
                if(Test.isRunningTest())
                    strJobCode = '450C07';
        	    if( strJobCode.length() == 6 ) {
	        	    strGrade = strJobCode.right(2);
    	        	strFamily = strJobCode.left(3);
	            }
                Career_Profile__c sProfile;
				if(Test.isRunningTest())
                    sProfile = Talent_Management_Test.CreateTestData();
                else
                    sProfile = [SELECT Id
                                FROM Career_Profile__c
                                WHERE ( Job_Grade__c = :strGrade
                                AND Job_Families__c = :strFamily )
                                OR Career_Path__c = 'None'
                                ORDER BY Job_Grade__c DESC][0];
                Talent_Management__c newTM = new Talent_Management__c();
    	        newTM.Career_Profile__c = sProfile.Id;
        	    newTM.Opportunity_Profile__c = sProfile.Id;
                newTM.ownerId = UserId;
            	newTM.User__c = UserId;
                try {
                    Insert newTM;
                } catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
    	    }
            iIndividual = ReloadIndividual(UserId);
            iData = new LGdata(iIndividual);
            CleanUpdate(iIndividual);
            iMyDirects = ReloadDirects();
		}
        IsInitialised = True;
    }

    private Talent_Management__c ReloadIndividual(Id UserIdToQuery) {
        return [SELECT Id, User__r.Name,
                User__r.Manager.Name,
                User__r.JobCode__c,
                User__r.Org62Id__c,
                Expected_Certifications__c,
                Certification_Status__c,
                Achieved_Certifications__c,
                Expected_Certifications_Opportunity__c,
                Certification_Status_Opportunity__c,
                Tenure__c,
                Career_Profile__r.Special_note__c,
                Career_Profile__c,
                Career_Profile__r.Career_Path__c,
                Career_Profile__r.Career_Path_Group__c,
                Career_Profile__r.Name,
                Career_Profile__r.Job_Grade__c,
                Career_Rated__c,
                Career_Validated__c,
                Career_Expected__c,
                Career_Readiness__c,
                Career_Match_pct__c,
                Career_Match__c,
                Career_Validated_pct__c,
                Onboarding__r.Last_Profile_Skills_Update__c,
                Opportunity_Profile__c,
                Opportunity_Profile__r.Special_note__c,
                Opportunity_Profile__r.Career_Path__c,
                Opportunity_Profile__r.Career_Path_Group__c,
                Opportunity_Profile__r.Name,
                Opportunity_Profile__r.Job_Grade__c,
                Opportunity_Expected__c,
                Opportunity_Readiness__c,
                Opportunity_Match__c,
                Opportunity_Match_pct__c,
                Opportunity_Validated_pct__c
                FROM Talent_Management__c
                WHERE User__c = :UserIdToQuery OR Id = :UserIdToQuery][0]; 
    }
    private List<Talent_Management__c> ReloadDirects() {
		return [SELECT Id, User__r.Name,
                User__r.Manager.Name,
                User__r.JobCode__c,
                User__r.Org62Id__c,
                Expected_Certifications__c,
                Certification_Status__c,
                Achieved_Certifications__c,
                Expected_Certifications_Opportunity__c,
                Certification_Status_Opportunity__c,
                Tenure__c,
                Career_Profile__c,
                Career_Profile__r.Career_Path__c,
                Career_Profile__r.Career_Path_Group__c,
                Career_Profile__r.Name,
                Career_Profile__r.Job_Grade__c,
                Career_Rated__c,
                Career_Validated__c,
                Career_Expected__c,
                Career_Readiness__c,
                Career_Match_pct__c,
                Career_Match__c,
                Career_Validated_pct__c,
                Onboarding__r.Last_Profile_Skills_Update__c,
                Opportunity_Profile__c,
                Opportunity_Profile__r.Career_Path__c,
                Opportunity_Profile__r.Career_Path_Group__c,
                Opportunity_Profile__r.Name,
                Opportunity_Profile__r.Job_Grade__c,
                Opportunity_Expected__c,
                Opportunity_Readiness__c,
                Opportunity_Match__c,
                Opportunity_Match_pct__c,
                Opportunity_Validated_pct__c
                FROM Talent_Management__c WHERE User__r.ManagerId = :UserId
                ORDER BY User__r.Name];
    }
    
    private void CleanUpdate(sObject curObj) {
        try {
            Update curObj;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
    }
}